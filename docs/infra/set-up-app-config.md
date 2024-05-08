# Set up application config

Follow these instructions for **each application** in your project (you can have one or more in your project).

## Prerequisites

* You have [configured the project](/infra/project-config/main.tf).
* You have [set up the AWS account(s)](./set-up-aws-accounts.md).

## Instructions

### 1. (Optional) Rename the application

By default, the application module is named `app` in [`/infra`](/infra/). You may want to rename the application to something project-specific.

### 2. Configure app-config

Modify the following values in the application's `app-config/main.tf` (e.g. `/infra/<APP_NAME>/app-config/main.tf`):

* Set the `environments` array to list the names of the environments for this application. By default, this is set to `["dev", "staging", "prod"]`.
* Set `has_database` to `true` or `false` to indicate whether or not the application relies on a database. This setting determines whether or not to create a database and create VPC endpoints needed by the database layer. By default, this is set to `false`.
* Set `has_external_non_aws_service` to `true` or `false` to indicate whether or not your application makes calls to an external non-AWS service. This setting determines whether or not to create NAT gateways, which allows the service in the private subnet to make requests to the internet. By default, this is set to `false`.
* Set `has_incident_management_service` to `true` or `false` to indicate whether the application should integrate with an incident management service. By default, this is set to `false`.
* Set the `account_names_by_environment` hash to map environments to AWS accounts. Use the mapping you decided on in the [set up AWS accounts](./set-up-aws-accounts.md) step.

To use [feature flags](/docs/feature-flags.md), modify the values in the application's `app-config/feature-flags.tf` (e.g. `/infra/<APP_NAME>/app-config/feature-flags.tf`).

### 3. Configure each environment

Within the application's `app-config` directory (e.g. `/infra/<APP_NAME>/app-config`), each environment configured in the `environments` array in the previous step needs its own config file. For example, if the application has three environments `dev`, `staging`, and `prod`, there must be corresponding `dev.tf`, `staging.tf`, and `prod.tf` files.

In each environment config file, modify the following values:

* Set `environment` to the name of the environment. This should match the name of the file.
* Set `network_name`. By default, it should match the name of the environment. This mapping ensures that each network is configured appropriately based on the application(s) in that network (see `local.apps_in_network` in `/infra/networks/main.tf`). Failure to set the network name properly may cause the network layer to use incorrect application configurations for `has_database` and `has_external_non_aws_service`.
* Skip `domain_name` for now.
* Skip `enable_https` for now.

When configuring the production environment, update these settings based on your project's needs:

* `service_cpu`
* `service_memory`
* `service_desired_instance_count`

Consider doing a load test if your application is sensitive to performance.
