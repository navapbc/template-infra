# Set up monitoring notifications

Follow these instructions for **each application** (you can have one or more in your project) and **each environment** in your project. If the application does not need a monitoring notifications, skip to the bottom of this document.

The monitoring module defines metric-based alerting policies that provides awareness into issues with the cloud application. The module supports integration with external incident management tools like Splunk-On-Call or Pagerduty. It also supports email alerts.

## Prerequisites

* You'll need to have [set up the AWS account(s)](./set-up-aws-accounts.md)
* You'll need to have [configured the application](/infra/app/app-config/main.tf)
* You'll need to have [set up the network(s)](./set-up-networks.md)
* If the application needs custom-built container images, you'll need to have [set up the build repository](./set-up-app-build-repository.md)

## Instructions

### To set up email alerts

When any of the alerts described by the module are triggered, a notification will be send to all emails specified in the `email_alerts_subscription_list`.

#### 1. Update the application's service layer

--- @TODO move to app-config

In the application's service module (e.g. `/infra/<APP_NAME>/service/main.tf`), uncomment the `email_alerts_subscription_list` key and add the emails that should be notified.

For example:

```
module "monitoring" {
  source = "../../modules/monitoring"
  email_alerts_subscription_list = ["email1@email.com", "email2@email.com"]
  ...
}
```

#### 2. Update the application service

To apply the changes, run the following command for each environment:

```bash
make infra-update-app-service APP_NAME=<APP_NAME> ENVIRONMENT=<ENVIRONMENT>
```

`APP_NAME` needs to be the name of the application folder within the `infra` folder.

`ENVIRONMENT` needs to be the name of the environment to update.

### To set up external incident management service integration

#### 1. Update the application config

Modify the `has_incident_management_service` in the application's `app-config/main.tf` (e.g. in `/infra/<APP_NAME>/app-config/main.tf`) and set it to `true`.

#### 2. Add the external url as a secret

Get the integration URL for the incident management service and store it in AWS SSM Parameter Store by running the following command

```bash
make infra-configure-monitoring-secrets APP_NAME=<APP_NAME> ENVIRONMENT=<ENVIRONMENT> URL=<WEBHOOK_URL>
```

#### 3. Update the application service

To apply the changes, run the following command

```bash
make infra-update-app-service APP_NAME=<APP_NAME> ENVIRONMENT=<ENVIRONMENT>
```

## If the application does not need monitoring notifications

If the application does not need monitoring notifications, ensure that:

* the application's service module (e.g. `/infra/<APP_NAME>/service/main.tf`) has the `email_alerts_subscription_list` commented out
* the application's `app-config` (e.g. in `/infra/<APP_NAME>/app-config/main.tf`) has `has_incident_management_service` set to `false`