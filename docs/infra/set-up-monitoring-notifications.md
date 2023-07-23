# Set up monitoring notifications

## Overview 

The Monitoring Module is responsible for presenting monitoring information from our application and infrastructure. It helps us identify performance bottlenecks, potential issues, and overall system health. With this module, we gain valuable insights to make data-driven decisions and ensure the reliability and availability of our services.

## Features

* Real time alerts: Module supports alerting rules to notify stakeholders when specific thresholds are breached.
* Notification channels: it supports various notification channels, specifically email alerts notifications and integration with external Incident management tools like Splunk-On-Call or Pagerduty.

## Requirements

Before proceeding with setting up monitoring notifications, ensure that you have completed the setup for your application environment. Refer to the following guide for the necessary steps:

[Set up application environment](./set-up-app-env.md)

## Configure monitoring alerts

### Setting up email alerts.

The Monitoring Module is an integral part of the application environment setup, and any changes to it can be applied by running the following command to create or update application resources:

```
TF_CLI_ARGS_apply="-var=image_tag=<IMAGE_TAG>" make infra-update-app-service APP_NAME=app ENVIRONMENT=<ENVIRONMENT>
```

To enable email alerts, you need to add the `email_alerts_subscription_list` variable to monitoring module call from [application code](../../infra/app/service/main.tf)

Example of the module call in the application code:

```
module "monitoring" {
  source = "../../modules/monitoring"
  #Email subscription list:
  email_alerts_subscription_list = ["email1@email.com", "email2@email.com"]

  # Module takes service and ALB names to link all alerts with corresponding targets
  service_name                                = local.service_name
  load_balancer_arn_suffix                    = module.service.load_balancer_arn_suffix
  incident_management_service_integration_url = module.app_config.has_incident_management_service ? data.aws_ssm_parameter.incident_management_service_integration_url[0].value : null
}
``` 

When any of the alerts described by the module are triggered notification will be send to all email specified in the `email_alerts_subscription_list`

### Setting up External incident management service integration.

1. Enable external incident management integration by modifying [application config](../infra/app/app-config/main.tf) 
Set `has_incident_management_service = true`

2. Create or modify SSM secret with webhook URL of the external service that should recieve alerts from Cloudwatch.
```
make infra-configure-monitoring-secrets APP_NAME=<APP_NAME> ENVIRONMENT=<ENVIRONMENT> URL=<WEBHOOK_URL>
```


### Additional monitoring alerts.

You can add additional alerts and use the same notification channel provided by the module. As an output, the module returns the SNS ARN, which is used for alerting. You can fetch this output from the appicaltion environment [code](../../infra/app/service/) using the following method.
```
module.monitoring.sns_notification_channel
```

This allows you to extend the monitoring capabilities and integrate with other tools seamlessly.
