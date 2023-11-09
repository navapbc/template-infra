## Overview

- This is a [terraform project](https://www.terraform.io) that uses the [AWS provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs).
- It is based on the [Nava platform infrastructure template](https://github.com/navapbc/template-infra).
- As currently deployed, this project has the following AWS environments:
    - `dev`
    - `staging`
    - `prod`

### 📂 Directory structure

The infrastructure for this project has extended the Nava platform infrastructure template's [module architecture](../docs/infra/module-architecture.md). It currently looks like this:

```text
infra/                  Infrastructure code
  accounts/             Root module for IaC and IAM resources
  [app_name]/           Application directory: infrastructure for the main application
  modules/              Reusable child modules
  networks/             Account level network config (shared across all apps, environments, and terraform workspaces)
```

Each application directory contains the following:

```text
  app-config/         Application-level configuration for the application resources (different config for different environments)
  build-repository/   Docker image repository for the application (shared across environments and terraform workspaces)
  database/           Configuration for database (different config for different environments)
  service/            Configuration for containers (load balancer, application service) (different config for different environments)
```

### 🏗️ Project architecture

#### 🥞 Infrastructure layers

The infrastructure template is designed to operate on different layers.

- Account layer
- Network layer
- Build repository layer (per application)
- Database layer (per application)
- Service layer (per application)

### 🔀 Project workflow

This project relies on Make targets in the [root Makefile](../Makefile), which in turn call shell scripts in [./bin](../bin). The shell scripts call terraform commands. Many of the shell scripts are also called by the [Github Actions CI/CD](../.github/workflows).

Backend configuration is saved as [`.tfbackend`](https://developer.hashicorp.com/terraform/language/settings/backends/configuration#file) files. Most `.tfbackend` files are named after the environment. For example, the `[app_name]/service` infrastructure resources for the `dev` environment are configured via `dev.s3.tfbackend`. Resources for a module that are shared across environments, such as the build-repository, use `shared.s3.tfbackend`. Resources that are shared across the entire account (e.g. /infra/accounts) use `<account name>.<account id>.s3.tfbackend`.

Generally you should use the Make targets or the underlying bin scripts, but if you want to directly use the `terraform` cli, you need to pass in the `.tfbackend` file to init commands and the `.tfvars` file to other commands:

```sh
infra/portal/service$ terraform init -backend-config=dev.s3.tfbackend
infra/portal/service$ terraform apply -var="environment_name=dev"
```

## 💻 Development

### 1️⃣ First time initialization

To set up this project for the first time (aka it has never been deployed to the target AWS account):

1. Follow the steps as outlined in the [infrastructure documentation README](../docs/infra/README.md) for:
    1. Configure the project
    1. Set up infrastructure developer tools
    1. Set up AWS account
1. [Set up the network](../docs/infra/set-up-network.md)
1. Go through the [infrastructure documentation README](../docs/infra/README.md) application steps for each [app]

### 🆕 New developer

To get set up as a new developer to a project that has already been deployed to the target AWS account:

1. [Set up infrastructure developer tools](../docs/infra/set-up-infrastructure-tools.md)
2. [Review how to make changes to infrastructure](../docs/infra/making-infra-changes.md)
3. (Optional) Set up a [terraform workspace](../docs/infra/intro-to-terraform-workspaces.md)
