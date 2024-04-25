# Set up application config

The application config setup process will configure the application. These values will be used in subsequent infra setup steps to determine which resources to deploy and how they will be configured.

This setup process applies to each application in the project.

## Prerequisites

1. You'll need to have [configured the project](/infra/project-config/main.tf)
2. You'll need to have [set up the AWS account(s)](./set-up-aws-accounts.md)

## Instructions

### 1. Edit the app-config

Modify the following values in the application's `app-config`. For instance, in `/infra/app/app-config/main.tf`.

### 2. Determine environments

Set the `environments` array to list the names of the environments for this application.

By default, this is set to `["dev", "staging", "prod"]`.

### 3. Indicate whether or not the application has a database

Set `has_database` to `true` or `false` to indicate whether a database is needed.

By default, this is set to `false`.

### 4. Indicate whether or not the application has external services

Set `has_external_non_aws_service` to `true` or `false` to indicate whether the network should allow the application to access to resources outside of the VPC.

By default, this is set to `false`.

### 5. Indicate whether or not the application should integrate with an incident management service

Set `has_incident_management_service` to `true` or `false` to indicate whether the application should integrate with an incident management service.

By default, this is set to `false`.

### 6. Configure the environments

Set the `account_names_by_environment` hash to map environments to AWS accounts. See [set up AWS accounts](./set-up-aws-accounts.md) for more information.
