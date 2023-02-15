resource "aws_backup_vault" "vault" {
  name = local.name
}

resource "aws_backup_plan" "plan" {
  name = local.name

  rule {
    rule_name         = "basic-cron-backup"
    target_vault_name = aws_backup_vault.vault.name
    schedule          = "cron(${var.schedule})"

    lifecycle {
      delete_after = var.retention
    }
  }
}

resource "aws_backup_selection" "backup" {
  name         = local.name
  plan_id      = aws_backup_plan.plan.id
  iam_role_arn = aws_iam_role.backup.arn

  resources = var.resource_arns
}