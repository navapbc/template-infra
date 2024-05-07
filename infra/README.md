# Overview

This project practices infrastructure-as-code and uses the [Terraform framework](https://www.terraform.io). This directory contains the infrastructure code for this project, including infrastructure for all application resources. This terraform project uses the [AWS provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs).

## 📂 Directory structure

The directory structure looks like this:

```text
infra/                  Infrastructure code
  accounts/             [Root module] IaC and IAM resources
  [APP_NAME]/           Application directory: infrastructure for the [APP_NAME] application
  modules/              Reusable child modules
  networks/             [Root module] Account level network config (shared across all apps, environments, and terraform workspaces)
```

Each application directory contains the following:

```text
  app-config/         Application-level configuration for the application resources (different config for different environments)
  build-repository/   [Root module] Docker image repository for the application (shared across environments and terraform workspaces)
  database/           [Root module] Configuration for database (different config for different environments)
  service/            [Root module] Configuration for containers, such as load balancer, application service (different config for different environments)
```

Details about terraform root modules and child modules are documented in [module-architecture](/docs/infra/module-architecture.md).

## 🏗️ Project architecture

### 🧅 Infrastructure layers

The infrastructure operates on different layers:

- Account layer
- Network layer
- Build repository layer (per application)
- Database layer (per application)
- Service layer (per application)

### 🏜️ Application environments

This project has the following AWS environments:

- `dev`
- `staging`
- `prod`

The environments share the same root modules but have different configurations. Backend configuration is saved as [`.tfbackend`](https://developer.hashicorp.com/terraform/language/settings/backends/configuration#file) files. Most `.tfbackend` files are named after the environment. For example, the `<APP_NAME>/service` infrastructure resources for the `dev` environment are configured via `dev.s3.tfbackend`. Resources for modules that are shared across environments (e.g. `<APP_NAME>/build-repository`), use `shared.s3.tfbackend`. Resources that are shared across an entire AWS account (e.g. `/infra/accounts`) use `<account name>.<account id>.s3.tfbackend`.

### 🔀 Project workflow

This project relies on Make targets in the [root Makefile](/Makefile), which in turn call shell scripts in [./bin](/bin). The shell scripts call terraform commands. Many of the shell scripts are also called by the [Github Actions CI/CD](/.github/workflows).

Generally, you should use the Make targets or the underlying bin scripts, but, if needed, you can call the underlying terraform commands. For more details, see [making-infra-changes](/docs/infra/making-infra-changes.md).

## 💻 Development

### 1️⃣ First time initialization

#### Prerequisites

* You'll need to have [installed this template](/README.md#installation) into an application that meets the [Application Requirements](/README.md#application-requirements).

#### Instructions

If this project has never been deployed to the target AWS account(s), complete the following steps:

1. [Configure the project](/infra/project-config/main.tf).
2. [Set up infrastructure developer tools](/docs/infra/set-up-infrastructure-tools.md).
3. [Set up AWS account(s)](/docs/infra/set-up-aws-accounts.md).
4. For each application:
    1. [Configure the application](/docs/infra/set-up-app-config.md).
5. [Set up network(s)](/docs/infra/set-up-networks.md).
6. For each application:
    1. [Configure environment variables and secrets](/docs/infra/set-up-environment-variables-and-secrets.md).
    2. [Set up application build repository](/docs/infra/set-up-app-build-repository.md).
    3. For each environment:
        1. [Set up application database](/docs/infra/set-up-app-database.md).
        2. [Set up application service](/docs/infra/set-up-app-service.md).
        3. (Optional) [Set up application monitoring alerts](/docs/infra/set-up-app-monitoring-alerts.md).
        4. (Optional) [Set up application background jobs](/docs/infra/background-jobs.md).
7. (Optional) [Set up custom domains](/docs/infra/set-up-network-custom-domains.md).
8. (Optional) [Set up HTTPS support](/docs/infra/set-up-network-https.md).

### 🆕 New developer

If you are a new developer on this project and this project has already been deployed to the target AWS account(s), complete the following steps to set up your local development environment:

1. [Set up infrastructure developer tools](/docs/infra/set-up-infrastructure-tools.md).
2. [Review how to make changes to infrastructure](/docs/infra/making-infra-changes.md).
3. (Optional) [Set up a terraform workspace](/docs/infra/intro-to-terraform-workspaces.md).

## 📇 Additional reading

Additional documentation is located in [documentation directory](/docs/infra).
