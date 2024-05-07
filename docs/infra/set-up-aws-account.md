# Set up AWS account

Follow these instructions for **each AWS account** you want to configure (you can have one or more in your project).

The AWS account setup process will:

* Create the [Terraform backend](https://www.terraform.io/language/settings/backends/configuration) resources needed to store Terraform's infrastructure state files using an [S3 backend](https://www.terraform.io/language/settings/backends/s3).
* Create the [OpenID connect provider in AWS](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html) to allow GitHub Actions to access AWS account resources.
* Create the IAM role and policy that GitHub Actions will use to manage infrastructure resources.

## Prerequisites

* You have [set up infrastructure developer tools](/docs/infra/set-up-infrastructure-tools.md).
* You have [configured the project](/infra/project-config/main.tf).
* You have [decided on your environment and AWS account strategy](./set-up-aws-accounts.md).

## Instructions

### 1. Make sure you're authenticated into the AWS account you want to configure

This setup applies to the account you're authenticated into. To see which account that is, run:

```bash
aws sts get-caller-identity
```

To see a more human readable account alias instead of the account, run:

```bash
aws iam list-account-aliases
```

### 2. Create backend resources and tfbackend config file

Run the following command, replacing `<ACCOUNT_NAME>` with a human readable name for the AWS account that you're authenticated into. The account name will be used to prefix the tfbackend file. For example, if you have an account per environment, the account name can be the name of the environment (e.g. "prod" or "staging"). Or if you are setting up an account for all lower environments, the account name can be "lowers". If your AWS account has an account alias, you can also use that.

```bash
make infra-set-up-account ACCOUNT_NAME=<ACCOUNT_NAME>
```

This command will create the S3 tfstate bucket and the GitHub OIDC provider. It will also create a `[account name].[account id].s3.tfbackend` file in the `infra/accounts` directory.

## Making changes to an AWS account

If you make changes to an account, apply those changes by running:

```bash
make infra-update-current-account
```

## Destroying infrastructure

To undeploy and destroy infrastructure, see [instructions on destroying infrastructure](./destroy-infrastructure.md).
