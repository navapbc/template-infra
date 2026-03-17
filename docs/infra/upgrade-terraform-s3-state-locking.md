# Upgrade Terraform state locking from DynamoDB to S3

Terraform 1.10+ supports [native S3 state locking](https://developer.hashicorp.com/terraform/language/backend/s3#state-locking) via `use_lockfile = true`, replacing the older DynamoDB-based locking. This guide walks through migrating an existing project that uses DynamoDB state locks to S3 native locking.

## Prerequisites

- Terraform >= 1.10.0
- Your project's template-infra has been updated to include the S3 locking changes (i.e., the `terraform-backend-s3` module no longer creates a DynamoDB table)

## Overview

The migration has three phases:

1. **Update backend config files** — Replace `dynamodb_table` with `use_lockfile = true` in all `.s3.tfbackend` files
2. **Reinitialize and verify** — Run `terraform init -reconfigure` and `terraform plan` for each module
3. **Apply the accounts layer** — Remove the DynamoDB table and related resources from AWS

## Step-by-step instructions

### 1. Confirm no active Terraform state locks

Before starting, make sure no one is currently running Terraform against any module. Check the DynamoDB table for active locks:

```bash
aws dynamodb scan \
  --table-name <your-lock-table> \
  --filter-expression "attribute_exists(LockID)"
```

The lock table name follows the pattern `<project>-<account_id>-<region>-tf-state-locks`. You can find the exact name in any existing `.s3.tfbackend` file under the `dynamodb_table` key.

If any locks are active, wait for them to clear before proceeding.

### 2. Merge the template update

Merge the pull request that updates the template to remove DynamoDB locking. This updates:

- `infra/modules/terraform-backend-s3/main.tf` — Removes the `aws_dynamodb_table` resource
- `infra/modules/terraform-backend-s3/outputs.tf` — Removes the `tf_locks_table_name` output
- `infra/accounts/outputs.tf` — Removes the `tf_locks_table_name` output
- `infra/example.s3.tfbackend` — Replaces `dynamodb_table` with `use_lockfile = true`
- `bin/create-tfbackend` — No longer references DynamoDB
- `bin/migrate-s3-locking` — New script to automate the backend file migration

> **Important:** Do NOT apply the accounts layer yet. Merge the code first, then update the backend files, then apply.

### 3. Run the migration script

The `bin/migrate-s3-locking` script automates updating all `.s3.tfbackend` files. It removes the `dynamodb_table` line and adds `use_lockfile = true`.

```bash
./bin/migrate-s3-locking
```

The script will report which files were migrated and which were already up to date.

To also reinitialize each module and run `terraform plan` automatically, use the `--reinit` flag:

```bash
./bin/migrate-s3-locking --reinit
```

This combines steps 3, 4, and 5 below. The script will iterate over each `.s3.tfbackend` file, run `terraform init -reconfigure` and `terraform plan` for the corresponding module, and report any failures.

If you prefer to do this manually, edit each `.s3.tfbackend` file under `infra/` to:
- Remove the `dynamodb_table = "..."` line
- Add `use_lockfile   = true`

Then follow steps 4 and 5 below.

### 4. Reinitialize each root module

> **Note:** If you used `--reinit` in step 3, skip to step 6.

Run `terraform init -reconfigure` for each root module to pick up the new backend configuration. Use the existing `bin/terraform-init` script:

```bash
# For each account (replace with your account alias)
./bin/terraform-init infra/accounts <account_alias>

# For each network
./bin/terraform-init infra/networks dev
./bin/terraform-init infra/networks staging
./bin/terraform-init infra/networks prod

# For each application module and environment
./bin/terraform-init infra/<app_name>/build-repository shared
./bin/terraform-init infra/<app_name>/database dev
./bin/terraform-init infra/<app_name>/database staging
./bin/terraform-init infra/<app_name>/database prod
./bin/terraform-init infra/<app_name>/service dev
./bin/terraform-init infra/<app_name>/service staging
./bin/terraform-init infra/<app_name>/service prod
```

### 5. Verify with terraform plan

Run `terraform plan` for each module to confirm there are no unexpected changes. For the accounts module specifically, you should see the DynamoDB table marked for destruction:

```bash
terraform -chdir=infra/accounts plan -out=tfplan
```

Expected output for accounts:

```
Plan: 0 to add, 0 to change, 1 to destroy.
```

The one resource to destroy is `aws_dynamodb_table.terraform_lock`.

For all other modules (networks, app modules), the plan should show **no changes**.

### 6. Apply the accounts layer

Once you've verified the plans, apply the accounts layer to remove the DynamoDB table:

```bash
terraform -chdir=infra/accounts apply tfplan
```

### 7. Commit the updated backend files

Commit and push the updated `.s3.tfbackend` files:

```bash
git add infra/**/*.s3.tfbackend
git commit -m "Migrate terraform state locking from DynamoDB to S3"
git push
```

## Repeat for each AWS account

If your project uses multiple AWS accounts (e.g., separate accounts for lower environments and prod), repeat steps 1, 3–7 for each account. You'll need to assume the appropriate role or configure AWS credentials for each account before running the commands.

## Rollback

If you need to roll back, you can re-add the `dynamodb_table` line to your `.s3.tfbackend` files and run `terraform init -reconfigure`. The DynamoDB table will need to be recreated by reverting the accounts module changes and applying.

## Cleanup

After confirming everything works in all environments:

- Verify no `.s3.tfbackend` files reference `dynamodb_table`
- Verify `terraform plan` shows no changes for all modules
- The DynamoDB table has been destroyed and the KMS key will be deleted after its waiting period (10 days by default)
