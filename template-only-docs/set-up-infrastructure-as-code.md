# Set up infrastructure as code (IaC) management resources

This doc explains how to set up infrastructure resources that Terraform needs to manage your project's infrastructure.

## Project setup

Before you start, first set up your project configuration values in [infra/project-config/main.tf](../infra/project-config/main.tf). You'll set values like the project name, project owner, etc. These values will be used in subsequent infra setup steps to namespace resources and add infrastructure tags.

## Account setup

Follow the instructions in [Set up AWS account](../docs/infra/set-up-aws-account.md).

Some projects may choose to [organize their AWS cloud using multiple AWS accounts](https://docs.aws.amazon.com/whitepapers/latest/organizing-your-aws-environment/organizing-your-aws-environment.html). For this set up, you will want to follow the [Set up AWS account](../docs/infra/set-up-aws-account.md) instructions for each account. You may choose to set up other accounts at a later time.
