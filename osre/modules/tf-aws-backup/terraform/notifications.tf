resource "aws_backup_vault_notifications" "notifications" {
  count = var.notifications_sns_topic_arn == null ? 0 : 1

  backup_vault_name   = aws_backup_vault.vault.name
  sns_topic_arn       = var.notifications_sns_topic_arn
  # Available event types documented here https://docs.aws.amazon.com/aws-backup/latest/devguide/sns-notifications.html
  backup_vault_events = [ "BACKUP_JOB_STARTED", "BACKUP_JOB_COMPLETED" ]
}