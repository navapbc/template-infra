# Set up application config

Follow these instructions for **each application** in your project (you can have one or more in your project).

The application config setup process will configure one application. These values will be used in subsequent infra setup steps to determine which resources to deploy and how they will be configured.

## Prerequisites

* You'll need to have [configured the project](/infra/project-config/main.tf)
* You'll need to have [set up the AWS account(s)](./set-up-aws-accounts.md)

## Instructions

### 1. Optionally, rename the application

By default, the application module is named `app` in [`/infra/app`](/infra/app). You may want to rename the application to something project-specific.

### 2. Optionally, create a terraform module for each additional application

If you have multiple applications in your project, create a terraform module for each additional application by running

```bash
curl https://raw.githubusercontent.com/navapbc/template-infra/main/template-only-bin/download-app-module.sh | bash -s
```

### 3. Configure the app-config

Modify the following values in the application's `app-config` (e.g. in `/infra/app/app-config/main.tf`):

* Set the `environments` array to list the names of the environments for this application. By default, this is set to `["dev", "staging", "prod"]`.
* Set `has_database` to `true` or `false` to indicate whether or not the application has a database to integrate with. This setting determines whether or not to create VPC endpoints needed by the database layer. By default, this is set to `false`.
* Set `has_external_non_aws_service` to `true` or `false` to indicate whether or not your application makes calls to an external non-AWS service. This setting determines whether or not to create NAT gateways, which allows the service in the private subnet to make requests to the internet. By default, this is set to `false`.
* Set `has_incident_management_service` to `true` or `false` to indicate whether the application should integrate with an incident management service. By default, this is set to `false`.
* Set the `account_names_by_environment` hash to map environments to AWS accounts. See [set up AWS accounts](./set-up-aws-accounts.md) for more information.

### 4. Configure each environment

Within the `app-config` directory (e.g. `infra/app/app-config`), each environment configured in the `environments` array in the previous step should have its own config file named after the environment. For example, if the application has three environments `dev`, `staging`, and `prod`, it should have corresponding `dev.tf`, `staging.tf`, and `prod.tf` files.

In each environment config file, modify the following values:

* Set `environment` to the name of the environment. This should match the name of the file.
* Set `network_name`. By default, it should match the name of the environment. This mapping ensures that each network is configured appropriately based on the application(s) in that network (see `local.apps_in_network` in `/infra/networks/main.tf`). Failure to set the network name properly means that the network layer may not receive the correct application configurations for `has_database` and `has_external_non_aws_service`.
* Skip `domain_name` for now
* Skip `enable_https` for now
