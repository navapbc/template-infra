# tf-aws-backup

Creates a backup vault and backup plan, and assigns the designated resources to it. Currently this module only supports RDS resources, though more can be added in the future.

To avoid name conflicts, if you want to specify separate backup plans that operate on different schedules, you should pass in distinct `application_name` inputs. 

Attempting to delete a backup vault will fail unless all the recovery points within have been separately deleted, similar to an S3 bucket. This manual step would involve OSRE involvement. 

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| aws | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_backup_plan.plan](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_plan) | resource |
| [aws_backup_selection.backup](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_selection) | resource |
| [aws_backup_vault.vault](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_vault) | resource |
| [aws_backup_vault_notifications.notifications](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_vault_notifications) | resource |
| [aws_iam_role.backup](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.backup](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.backup_rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.aws_backup_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.aws_rds_backup_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.backup_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| application\_name | App name to distinguish resources | `string` | n/a | yes |
| aws\_region | n/a | `any` | n/a | yes |
| environment\_name | n/a | `any` | n/a | yes |
| notifications\_sns\_topic\_arn | SNS Topic ARN to receive notifications, see notifications.tf for current event list | `string` | `null` | no |
| resource\_arns | List of ARNs for resources to backup | `list(string)` | n/a | yes |
| retention | Number of days to preserve backups | `number` | `14` | no |
| schedule | Cron schedule to run backups (evaluated UTC) | `string` | `"0 5 1-31/2 * ? *"` | no |

## Outputs

No outputs.
