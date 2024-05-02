# Set up AWS accounts

The infrastructure supports managing resources across different [AWS accounts](https://docs.aws.amazon.com/accounts/latest/reference/accounts-welcome.html) by mapping different environments (e.g. `dev`, `staging`, `prod`) to specified AWS accounts. Resources that are shared across environments, such as build repositories, are also deployed into a specified AWS account.

The environment-to-AWS-account mapping is specified for each application deployed by this infrastructure. This means that multiple applications can share AWS accounts or be deployed into different AWS accounts.

The AWS accounts setup process will:

1. Help you decide on your environments
2. Help you decide on your AWS account strategy
3. Configure all AWS accounts

## Prerequisites

* You'll need to have [set up infrastructure tools](./set-up-infrastructure-tools.md), like Terraform, AWS CLI, and AWS authentication

## Instructions

### 1. Decide on environments

Even though environment-to-AWS-account mapping is specified per-application, the names of the environments must be consistent across applications. Decide now what you would like the environments in your project to be. By default, the environments are:

* dev
* staging
* prod

You can always add new environments or delete existing environments later.

### 2. Decide on AWS account strategy

Some resources, such as a build repository, are shared across environments. These resources can be deployed to the same AWS account as any of the other environments or they can be deployed to a separate environment. In the following diagrams, these are represented by the box labeled `shared`.

A simple project might have only one AWS account and all environments should be deployed to this environment. This mapping might look like this:

```mermaid
flowchart TD
  shared --> my_aws_account
  dev --> my_aws_account
  staging --> my_aws_account
  prod --> my_aws_account
```

A more complex project might have separate AWS accounts for environment, enhancing security by isolating each environment into completely separate AWS accounts. This mapping might look like this:

```mermaid
flowchart TD
  shared --> shared_aws_account
  dev --> dev_aws_account
  staging --> staging_aws_account
  prod --> prod_aws_account
```

A project could also isolate just the `prod` environment and group the lower environments:

```mermaid
flowchart TD
  shared --> shared_aws_account
  dev --> lower_aws_account
  staging --> lower_aws_account
  prod --> prod_aws_account
```

Decide on the strategy that is appropriate for your project.

### 3. Ensure AWS account(s) have been created

For **each AWS account** you wish to use, ensure it has been created in AWS and you are able to authenticate to it.

### 4. Set up AWS account

For **each AWS account** you wish to use, [set up the AWS account](./set-up-aws-account.md).