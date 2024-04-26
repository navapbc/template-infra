# Set up application build repository

Follow these instructions for **each application** in your project (you can have one or more in your project).

The application build repository setup process will create infrastructure resources needed to store built release candidate artifacts used to deploy the application to an environment.

## Prerequisites

Before setting up the application's build repository you'll need to have:

1. You'll need to have [set up the AWS account(s)](./set-up-aws-accounts.md).
2. You'll need to have [configured the application](/infra/app/app-config/main.tf).

### 1. Make sure you're authenticated into the AWS account where you want to deploy resources shared across environments

The account set up sets up whatever account you're authenticated into. To see which account that is, run

```bash
aws sts get-caller-identity
```

To see a more human readable account alias instead of the account, run

```bash
aws iam list-account-aliases
```

### 2. Configure backend

To create the tfbackend file for the build repository using the backend configuration values from your current AWS account, run

```bash
make infra-configure-app-build-repository APP_NAME=<APP_NAME>
```

Pass in the name of the app folder within `infra`. By default this is `app`.

### 2. Create build repository resources

Now run the following commands to create the resources, making sure to verify the plan before confirming the apply.

```bash
make infra-update-app-build-repository APP_NAME=<APP_NAME>
```