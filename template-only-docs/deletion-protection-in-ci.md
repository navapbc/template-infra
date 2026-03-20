# Deletion protection in template-only CI

Template-only CI (`.github/workflows/template-only-ci-infra.yml`) provisions real AWS resources, runs Terratest against them, and tears them down — all within a single workflow run. This document explains how deletion protection works in that context and what to do when adding new deletion-protected resources.

## How template-only CI creates and destroys resources

Each CI run follows this lifecycle:

1. **Install** — `nava-platform infra install` creates a fresh project directory with a randomized project name (`plt-tst-act-XXXXX`)
2. **Set up** — Terratest creates infrastructure layers in order: account → network → build-repository → service
3. **Test** — Terratest validates the deployed resources (e.g. hitting the service endpoint)
4. **Destroy** — Go `defer` functions tear down each layer in reverse order using the `template-only-bin/destroy-*` scripts

All of this runs in the **default Terraform workspace**. This is different from PR environments (documented separately), which use temporary workspaces.

## The `is_temporary` pattern

Many resources in template-infra use an `is_temporary` variable to gate deletion protection:

```hcl
# infra/modules/service/load_balancer.tf
enable_deletion_protection = !var.is_temporary

# infra/modules/database/resources/main.tf
deletion_protection = !var.is_temporary

# infra/modules/service/access_logs.tf
force_destroy = var.is_temporary

# infra/modules/identity-provider/resources/main.tf
deletion_protection = var.is_temporary ? "INACTIVE" : "ACTIVE"
```

In project repos, `is_temporary` is typically derived from the workspace:

```hcl
is_temporary = terraform.workspace != "default"
```

This means temporary/PR workspaces get deletion protection disabled automatically. But template-only CI runs in the **default workspace**, so `is_temporary` evaluates to `false` — deletion protection stays **enabled**. The destroy scripts must explicitly override this.

## How destroy scripts handle deletion protection

The `template-only-bin/destroy-*` scripts use `sed` to replace `is_temporary`-based expressions with hardcoded values that disable protection, then run a targeted `terraform apply` to apply those overrides before running `terraform destroy`.

### `template-only-bin/destroy-app-service`

```bash
sed -i.bak 's/force_destroy = var.is_temporary/force_destroy = true/g' infra/modules/service/access_logs.tf
sed -i.bak 's/force_destroy = var.is_temporary/force_destroy = true/g' infra/modules/storage/main.tf
sed -i.bak 's/enable_deletion_protection = !var.is_temporary/enable_deletion_protection = false/g' infra/modules/service/load_balancer.tf
sed -i.bak 's/deletion_protection = var.is_temporary ? "INACTIVE" : "ACTIVE"/deletion_protection = "INACTIVE"/g' infra/modules/identity-provider/resources/main.tf

terraform init -reconfigure -backend-config="${backend_config_file}"
terraform apply -auto-approve \
  -target="module.service.aws_s3_bucket.access_logs" \
  -target="module.service.aws_lb.alb" \
  -target="module.identity_provider.aws_cognito_user_pool.main" \
  -var="environment_name=${environment}"
terraform destroy -auto-approve -var="environment_name=${environment}"
```

### `template-only-bin/destroy-app-database`

```bash
sed -i.bak 's/deletion_protection = !var.is_temporary/deletion_protection = false/g' infra/modules/database/main.tf
sed -i.bak 's/force_destroy = var.is_temporary/force_destroy = true/g' infra/modules/database/backups.tf

terraform init -reconfigure -backend-config="${backend_config_file}"
terraform apply -auto-approve \
  -target="module.database.aws_backup_vault.backup_vault" \
  -target="module.database.aws_rds_cluster.db" \
  -var="environment_name=${environment}"
terraform destroy -auto-approve -var="environment_name=${environment}"
```

### `template-only-bin/destroy-account`

Uses a different pattern — adds `force_destroy = true` to S3 bucket resource blocks and flips `prevent_destroy = true` to `false` for the Terraform backend S3 buckets. See the script for details.

### `template-only-bin/destroy-network` and `template-only-bin/destroy-app-build-repository`

These layers have no deletion-protected resources, so their destroy scripts run `terraform destroy` directly without any sed overrides.

## Resources with deletion protection

| Resource | Terraform file | Expression | Destroy script |
|---|---|---|---|
| ALB | `infra/modules/service/load_balancer.tf` | `enable_deletion_protection = !var.is_temporary` | `destroy-app-service` |
| ALB access logs S3 bucket | `infra/modules/service/access_logs.tf` | `force_destroy = var.is_temporary` | `destroy-app-service` |
| Storage S3 bucket | `infra/modules/storage/main.tf` | `force_destroy = var.is_temporary` | `destroy-app-service` |
| Cognito user pool | `infra/modules/identity-provider/resources/main.tf` | `deletion_protection = var.is_temporary ? "INACTIVE" : "ACTIVE"` | `destroy-app-service` |
| RDS cluster | `infra/modules/database/resources/main.tf` | `deletion_protection = !var.is_temporary` | `destroy-app-database` |
| Backup vault | `infra/modules/database/resources/backups.tf` | `force_destroy = var.is_temporary` | `destroy-app-database` |
| Terraform state S3 buckets | `infra/modules/terraform-backend-s3/main.tf` | `prevent_destroy = true` (lifecycle rule) | `destroy-account` |

## Adding a new deletion-protected resource

When you add a resource that has deletion protection or `force_destroy` behavior:

1. **Use the `is_temporary` pattern in Terraform.** Gate the protection attribute on `var.is_temporary`, following the conventions above. Add a comment like `# Use a separate line to support automated terraform destroy commands` so the intent is clear.

2. **Update the relevant `template-only-bin/destroy-*` script.** Add a `sed` command that replaces your `is_temporary` expression with a hardcoded value that disables protection. Add a matching `-target` to the `terraform apply` command so the override is applied before `terraform destroy` runs.

3. **Test it.** Run the template-only CI workflow to verify that the destroy step completes successfully. A failed destroy leaves orphaned resources in AWS that need manual cleanup.

## Detecting orphaned resources

If a CI run fails or is cancelled before the destroy step completes, resources are left behind in AWS. The `scan-orphaned-environments` workflow (`.github/workflows/scan-orphaned-environments.yml`) runs daily to detect these. It runs the `bin/stale-test-environments` script, which checks for Terraform workspaces older than 24 hours.

For template-only CI specifically, orphaned resources are tagged with the `plt-tst-act-*` project name pattern. If the scan detects stale environments, it sends a notification to the `workflow-failures` Slack channel. Cleaning up these resources currently requires manual intervention — running the appropriate destroy scripts or deleting resources directly in the AWS console.
