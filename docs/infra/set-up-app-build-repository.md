# Set up application build repository

Follow these instructions for **each application** in your project (you can have one or more in your project). If the application does not need a build repository, skip to the bottom of this document.

The application build repository setup process will create infrastructure resources needed to store built release-candidate artifacts used to deploy the application to an environment.

## Prerequisites

* You are [authenticated into the AWS account](./set-up-infrastructure-tools.md#authenticate-with-aws) you want to configure.
* You have [set up the AWS account(s)](./set-up-aws-accounts.md).
* You have [configured the application](/infra/app/app-config/main.tf).
* You have [set up the network(s)](./set-up-networks.md).

## Instructions

### 1. Configure backend

To create the `.tfbackend` file for the build repository, run:

```bash
make infra-configure-app-build-repository APP_NAME=<APP_NAME>
```

`<APP_NAME>` must be the name of the application folder within the `/infra` folder.

### 2. Create build repository resources

To create the resources, run the following command. Review the Terraform output carefully before typing "yes" to apply the changes.

```bash
make infra-update-app-build-repository APP_NAME=<APP_NAME>
```

## If the application does not need a build repository

If the application does not need a build repository, such as if the project uses pre-built images hosted in an external container repository, delete the application's build repository module (e.g. `/infra/<APP_NAME>/build-repository`).