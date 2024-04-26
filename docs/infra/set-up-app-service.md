# Set up application service

Follow these instructions for **each application** (you can have one or more in your project) and **each environment** in your project.

The application service setup process will:

1. Configure an ECS Fargate Service and Task to host the application
2. Creates a load balancer for the application
2. Create an S3 bucket for general object storage
3. Set up CloudWatch for logging, monitoring, and alerts
3. Optionally, configure CloudWatch Evidently to support [feature flags](/docs/feature-flags.md)

## Prerequisites

* You'll need to have [set up the AWS account(s)](./set-up-aws-accounts.md)
* You'll need to have [configured the application](/infra/app/app-config/main.tf)
* You'll need to have [set up the network(s)](./set-up-networks.md)
* Optionally, if you need a container build repository, you'll need to have [set up the build repository](./set-up-app-build-repository.md)
* Optionally, if you need a database for the application, you'll need to have [set up the database](./set-up-app-database.md)

## Instructions

### 1. Make sure you're authenticated into the AWS account where you want to deploy this environment

This set up takes effect in whatever account you're authenticated into. To see which account that is, run

```bash
aws sts get-caller-identity
```

To see a more human readable account alias instead of the account, run

```bash
aws iam list-account-aliases
```

### 2. Configure backend

To create the tfbackend and tfvars files for the new application environment, run

```bash
make infra-configure-app-service APP_NAME=<APP_NAME> ENVIRONMENT=<ENVIRONMENT>
```

`APP_NAME` needs to be the name of the application folder within the `infra` folder. It defaults to `app`.

`ENVIRONMENT` needs to be the name of the environment you are creating. This will create a file called `<ENVIRONMENT>.s3.tfbackend` in the `infra/<APP_NAME>/service` module directory.

### 3. Build and publish the application to the application build repository

Before creating the application resources, you'll need to first build and publish at least one image to the application build repository.

There are two ways to do this:

1. Trigger the "Build and Publish" workflow from your repo's GitHub Actions tab. This option requires that the `role-to-assume` GitHub workflow variable has already been setup as part of the overall infra account setup process.
1. Alternatively, run the following from the root directory. This option can take much longer than the GitHub workflow, depending on your machine's architecture.

    ```bash
    make release-build APP_NAME=<APP_NAME>
    make release-publish APP_NAME=<APP_NAME>
    ```

Copy the image tag name that was published. You'll need this in the next step.

### 4. Create application resources with the image tag that was published

Now run the following commands to create the resources, using the image tag that was published from the previous step. Review the terraform before confirming "yes" to apply the changes.

```bash
TF_CLI_ARGS_apply="-var=image_tag=<IMAGE_TAG>" make infra-update-app-service APP_NAME=<APP_NAME> ENVIRONMENT=<ENVIRONMENT>
```