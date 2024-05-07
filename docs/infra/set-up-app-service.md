# Set up application service

Follow these instructions for **each application** (you can have one or more in your project) and **each environment** in your project.

The application service set up process will:

* Configure an ECS Fargate Service and Task to host the application
* Create a load balancer for the application
* Create an S3 bucket for general object storage
* Set up CloudWatch for logging, monitoring, and alerts
* Configure CloudWatch Evidently to support feature flags

## Prerequisites

* You have [set up the AWS account(s)](./set-up-aws-accounts.md).
* You have [configured the application](/infra/app/app-config/main.tf).
* You have [set up the network(s)](./set-up-networks.md).
* Optionally, if you need a container build repository, you have [set up the build repository](./set-up-app-build-repository.md).
* Optionally, if you need a database for the application, you have [set up the database](./set-up-app-database.md).

## Instructions

### 1. Make sure you're authenticated into the AWS account where you want to deploy this environment

This setup applies to the account you're authenticated into. To see which account that is, run:

```bash
aws sts get-caller-identity
```

To see a more human readable account alias instead of the account, run:

```bash
aws iam list-account-aliases
```

### 2. Configure backend

To create the `.tfbackend` and `.tfvars` files for the new application service, run:

```bash
make infra-configure-app-service APP_NAME=<APP_NAME> ENVIRONMENT=<ENVIRONMENT>
```

`APP_NAME` must be the name of the application folder within the `infra` folder.

`ENVIRONMENT` must be the name of the environment to update. This will create a file called `<ENVIRONMENT>.s3.tfbackend` in `infra/<APP_NAME>/service`.

### 3. Build and publish the application to the build repository

Before creating the application resources, you need to build and publish at least one image to the build repository. This step does not need to be run per environment.

Run the following commands from the project's root directory:

```bash
make release-build APP_NAME=<APP_NAME>
make release-publish APP_NAME=<APP_NAME>
```

Copy the image tag name that is output. You'll need this in the next step.

### 4. Create application resources with the image tag that was published

To create the resources, run the following command using the image tag from the previous step. Review the Terraform output carefully before typing "yes" to apply the changes. This can take over 5 minutes.

```bash
TF_CLI_ARGS_apply="-var=image_tag=<IMAGE_TAG>" make infra-update-app-service APP_NAME=<APP_NAME> ENVIRONMENT=<ENVIRONMENT>
```