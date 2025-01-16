locals {
  incident_management_service_integration_config = local.environment_config.incident_management_service_integration
}

# Retrieve url for external incident management tool (e.g. Pagerduty, Splunk-On-Call)

data "aws_ssm_parameter" "incident_management_service_integration_url" {
  count = module.app_config.has_incident_management_service ? 1 : 0
  name  = local.incident_management_service_integration_config.integration_url_param_name
}

module "monitoring" {
  source = "../../modules/monitoring"
  #Email subscription list:
  #email_alerts_subscription_list = ["email1@email.com", "email2@email.com"]

  # Module takes service and ALB names to link all alerts with corresponding targets
  service_name                                = local.service_name
  load_balancer_arn_suffix                    = module.service.load_balancer_arn_suffix
  incident_management_service_integration_url = module.app_config.has_incident_management_service && !local.is_temporary ? data.aws_ssm_parameter.incident_management_service_integration_url[0].value : null
}
