data "aws_vpc" "network" {
  tags = {
    project      = module.project_config.project_name
    network_name = local.environment_config.network_name
  }
}

data "aws_subnets" "public" {
  tags = {
    project      = module.project_config.project_name
    network_name = local.environment_config.network_name
    subnet_type  = "public"
  }
}

data "aws_subnets" "private" {
  tags = {
    project      = module.project_config.project_name
    network_name = local.environment_config.network_name
    subnet_type  = "private"
  }
}

locals {
  # Add environment specific tags
  tags = merge(module.project_config.default_tags, {
    environment = var.environment_name
    description = "Application resources created in ${var.environment_name} environment"
  })

  is_temporary = startswith(terraform.workspace, "t-")

  environment_config                             = module.app_config.environment_configs[var.environment_name]
  service_config                                 = local.environment_config.service_config
  database_config                                = local.environment_config.database_config
  storage_config                                 = local.environment_config.storage_config
  incident_management_service_integration_config = local.environment_config.incident_management_service_integration

  network_config = module.project_config.network_configs[local.environment_config.network_name]
}

terraform {
  required_version = "~>1.8.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.56.0, < 5.0.0"
    }
  }

  backend "s3" {
    encrypt = "true"
  }
}

provider "aws" {
  region = local.service_config.region
  default_tags {
    tags = local.tags
  }
}

module "project_config" {
  source = "../../project-config"
}

module "app_config" {
  source = "../app-config"
}

data "aws_rds_cluster" "db_cluster" {
  count              = module.app_config.has_database ? 1 : 0
  cluster_identifier = local.database_config.cluster_name
}

data "aws_iam_policy" "app_db_access_policy" {
  count = module.app_config.has_database ? 1 : 0
  name  = local.database_config.app_access_policy_name
}

data "aws_iam_policy" "migrator_db_access_policy" {
  count = module.app_config.has_database ? 1 : 0
  name  = local.database_config.migrator_access_policy_name
}

# Retrieve url for external incident management tool (e.g. Pagerduty, Splunk-On-Call)

data "aws_ssm_parameter" "incident_management_service_integration_url" {
  count = module.app_config.has_incident_management_service ? 1 : 0
  name  = local.incident_management_service_integration_config.integration_url_param_name
}

data "aws_security_groups" "aws_services" {
  filter {
    name   = "group-name"
    values = ["${module.project_config.aws_services_security_group_name_prefix}*"]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.network.id]
  }
}

data "aws_acm_certificate" "certificate" {
  count  = local.service_config.enable_https ? 1 : 0
  domain = local.service_config.domain_name
}

data "aws_route53_zone" "zone" {
  count = local.service_config.domain_name != null ? 1 : 0
  name  = local.network_config.domain_config.hosted_zone
}

module "service" {
  source       = "../../modules/service"
  service_name = local.service_config.service_name

  image_repository_name = module.app_config.image_repository_name
  image_tag             = local.image_tag

  vpc_id             = data.aws_vpc.network.id
  public_subnet_ids  = data.aws_subnets.public.ids
  private_subnet_ids = data.aws_subnets.private.ids

  domain_name     = local.service_config.domain_name
  hosted_zone_id  = local.service_config.domain_name != null ? data.aws_route53_zone.zone[0].zone_id : null
  certificate_arn = local.service_config.enable_https ? data.aws_acm_certificate.certificate[0].arn : null

  cpu                      = local.service_config.cpu
  memory                   = local.service_config.memory
  desired_instance_count   = local.service_config.desired_instance_count
  enable_command_execution = local.service_config.enable_command_execution

  aws_services_security_group_id = data.aws_security_groups.aws_services.ids[0]

  file_upload_jobs = local.service_config.file_upload_jobs

  db_vars = module.app_config.has_database ? {
    security_group_ids         = data.aws_rds_cluster.db_cluster[0].vpc_security_group_ids
    app_access_policy_arn      = data.aws_iam_policy.app_db_access_policy[0].arn
    migrator_access_policy_arn = data.aws_iam_policy.migrator_db_access_policy[0].arn
    connection_info = {
      host        = data.aws_rds_cluster.db_cluster[0].endpoint
      port        = data.aws_rds_cluster.db_cluster[0].port
      user        = local.database_config.app_username
      db_name     = data.aws_rds_cluster.db_cluster[0].database_name
      schema_name = local.database_config.schema_name
    }
  } : null

  extra_environment_variables = merge({
    FEATURE_FLAGS_PROJECT = module.feature_flags.evidently_project_name
    BUCKET_NAME           = local.storage_config.bucket_name
  }, local.service_config.extra_environment_variables)

  secrets = [
    for secret_name in keys(local.service_config.secrets) : {
      name      = secret_name
      valueFrom = module.secrets[secret_name].secret_arn
    }
  ]

  extra_policies = {
    feature_flags_access = module.feature_flags.access_policy_arn,
    storage_access       = module.storage.access_policy_arn
  }

  is_temporary = local.is_temporary
}

module "monitoring" {
  source = "../../modules/monitoring"
  #Email subscription list:
  #email_alerts_subscription_list = ["email1@email.com", "email2@email.com"]

  # Module takes service and ALB names to link all alerts with corresponding targets
  service_name                                = local.service_config.service_name
  load_balancer_arn_suffix                    = module.service.load_balancer_arn_suffix
  incident_management_service_integration_url = module.app_config.has_incident_management_service && !local.is_temporary ? data.aws_ssm_parameter.incident_management_service_integration_url[0].value : null
}

module "feature_flags" {
  source        = "../../modules/feature-flags"
  service_name  = local.service_config.service_name
  feature_flags = module.app_config.feature_flags
}

module "storage" {
  source = "../../modules/storage"
  name   = local.storage_config.bucket_name
}
