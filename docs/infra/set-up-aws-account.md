# Set up AWS account

The AWS account setup process will:

1. Create the [Terraform backend](https://www.terraform.io/language/settings/backends/configuration) resources needed to store Terraform's infrastructure state files. The project uses an [S3 backend](https://www.terraform.io/language/settings/backends/s3).
2. Create the [OpenID connect provider in AWS](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html) to allow GitHub actions to access AWS account resources.

## Prerequisites

First, [set up infrastructure tools](./set-up-infrastructure-tools.md), like Terraform, AWS CLI, and AWS authentication.

## Overview of Terraform backend management

The approach to backend management allows Terraform to both create the resources needed for a remote backend as well as allow terraform to store that configuration state in that newly created backend. This also allows us to seperate infrastructure required to support terraform from infrastructure required to support the application. Because each backend, bootstrap or environment, stores their own terraform.tfstate in these buckets, ensure that any backends that are shared use a unique key. When using a non-default workspace, the state path will be `/workspace_key_prefix/workspace_name/key`, `workspace_key_prefix` default is `env:`

## Instructions

### 1. Configure backend resources

In your account module's `main.tf` file, replace the placeholders in the `locals {}` block at the top of main.tf to match the desired deployment setup. Update the region if you want to use a region other than what is there by default.

### 2. Review the backend resources that will be created

Open a terminal and cd into your infra/accounts/account directory and run the following commands:

```bash
terraform init
terraform plan -out=plan.out
```

Review the plan to make sure that the resources look correct.

### 3. Create the backend resources

```bash
terraform apply plan.out
```

### 4. Reconfigure backend to use S3 backend

Now that the S3 bucket for storing Terraform state files and the DynamoDB table for managing tfstate locks have been created, reconfigure the backend in `main.tf` to use the S3 bucket as a backend. To do this, uncomment out the `backend "s3" {}` block and fill in the appropriate information from the outputs from the previous step.

```terraform
  # infra/accounts/account/main.tf

  backend "s3" {
    bucket         = "<TF_STATE_BUCKET_NAME>"
    dynamodb_table = "<TF_LOCKS_TABLE_NAME>"
    region         = "<REGION>"
    ...
  }
```

### 5. Copy local tfstate file to remote backend

Now run following command to copy the `terraform.tfstate` file from your local machine to the remote backend.

```bash
terraform init -force-copy
```

Once these steps are complete, this should not need to be touched again.

## Destroying infrastructure

To undeploy and destroy infrastructure, see [instructions on destroying infrastructure](./destroy-infrastructure.md).
