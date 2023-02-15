module "weekly_backups" {
    source = "../modules/tf-aws-backup/terraform"

    environment_name = var.environment_name
    aws_region       = var.aws_region
    application_name = "example-app-backups"
    resource_arns    = [ module.rds_aurora.cluster_resource_arn ]
    schedule         = "0 13 ? * SUN *" # 8am EST, on Sundays every week
    retention        = 90
}
