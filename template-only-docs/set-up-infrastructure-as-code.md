# Set up infrastructure as code (IaC) management resources

This doc explains how to set up infrastructure resources that Terraform needs to manage your project's infrastructure.

## Prerequisites

First, [set up infrastructure tools](../docs/infra/set-up-infrastructure-tools.md), like Terraform, AWS CLI, and AWS authentication.

## Single account setup

Follow the instructions in [Set up AWS account](../docs/infra/set-up-aws-account.md) if you want to manage all your resources in a single AWS account (for simple projects or projects that don't need to go to production).

## Multiple account setup

Some projects may choose to [organize their AWS cloud using multiple AWS accounts](https://docs.aws.amazon.com/whitepapers/latest/organizing-your-aws-environment/organizing-your-aws-environment.html). For this set up, you will want to have a copy of the `infra/accounts/account` folder for every AWS account. For example, if you have separate AWS accounts for production and non-production resources, your `infra/accounts` might look like:

```text
  accounts/
    prod/
    non-prod/
```

or if you have an account per application environment, your `infra/accounts` folder might look like:

```text
  accounts/
    dev/
    staging/
    prod/
```

Once you have set up your account folders, follow the [Set up AWS account](../docs/infra/set-up-aws-account.md) instructions for each account.
