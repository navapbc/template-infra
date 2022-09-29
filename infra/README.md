# Getting Started With Terraform

## Install Terraform CLI
&nbsp;&nbsp;Terraform is an infrastructure as code (IaC) tool that allows you to build, change, and version infrastructure safely and efficiently. This includes both low-level components like compute instances, storage, and networking, as well as high-level components like DNS entries and SaaS features.

You may need different versions of Terraform since different projects may require different versions of Terraform. The best way to manage Terraform versions is with [Terraform Version Manager](https://github.com/tfutils/tfenv).

To install via [Homebrew](https://brew.sh/)
```bash
brew install tfenv
```

Then install the version of Terraform you need.
```bash
tfenv install 1.2.1
```

## Install AWS CLI
&nbsp;&nbsp;The AWS Command Line Interface (AWS CLI) is a unified tool to manage your AWS services. With just one tool to download and configure, you can control multiple AWS services from the command line and automate them through scripts. Install the aws commmand line tool by following the instructions found here:

- [Install AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

## AWS Authentication

&nbsp;&nbsp;In order for Terraform to authenticate with your accounts you will need to configure your aws credentials using the AWS CLI or manually create your config and credentials file. If you need to manage multiple credentials or create named profiles for use with different environments you can add the `--profile` option.

There are multiple ways to authenticate, but we recommend creating a separate profile for your project in your AWS credentials file, and setting your local environment variable `AWS_PROFILE` to the profile name. We recommend using [direnv](https://direnv.net/) to manage local environment variables.
**Credentials should be located in ~/.aws/credentials** (Linux & Mac) or **%USERPROFILE%\.aws\credentials** (Windows)

### Examples:
```
$ aws configure
AWS Access Key ID [None]: AKIAIOSFODNN7EXAMPLE
AWS Secret Access Key [None]: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
Default region name [None]: us-east-2
Default output format [None]: json
```
**Using the above command will create a [default] profile.**  
```
$ aws configure --profile dev
AWS Access Key ID [None]: AKIAIOSFODNN7EXAMPLE
AWS Secret Access Key [None]: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
Default region name [None]: us-east-2
Default output format [None]: json
```
**Using the above command will create a [dev] profile.**  

### References:

- [Configuration basics][1]
- [Named profiles for the AWS CLI][2]
- [Configuration and credential file settings][3]

[1]: https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html
[2]: https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-profiles.html
[3]: https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html

## Basic Terraform Commands 

&nbsp;&nbsp;The `terraform init` command is used to initialize a working directory containing Terraform configuration files. This is the first command that should be run after writing a new Terraform configuration or cloning an existing one from version control.

&nbsp;&nbsp;The `terraform plan` command creates an execution plan, which lets you preview the changes that Terraform plans to make to your infrastructure. By default, when Terraform creates a plan it:

- Reads the current state of any already-existing remote objects to make sure that the Terraform state is up-to-date.
- Compares the current configuration to the prior state and noting any differences.
- Proposes a set of change actions that should, if applied, make the remote objects match the configuration.

&nbsp;&nbsp;The `terraform apply` command executes the actions proposed in a Terraform plan deploying the infrastructure specified in the configuration. Use with caution. The configuration becomes idempotent once a subsequent apply returns 0 changes.

&nbsp;&nbsp; The `terraform destroy` command is a convenient way to destroy all remote objects managed by a particular Terraform configuration. Use `terraform plan -destroy` to preview what remote objects will be destroyed if you run `terraform destroy`.

⚠️ WARNING! ⚠️ This is a destructive command! As a best practice, it's recommended that you comment out resources in non-development environments rather than running this command. `terraform destroy` should only be used as a way to cleanup a development environment. e.g. a developers workspace after they are done with it.

For more information about terraform commands follow the link below:

- [Basic CLI Features](https://www.terraform.io/cli/commands)
## Terraform Dependency Lock File

&nbsp;&nbsp;  The [dependency lock file](https://www.terraform.io/language/files/dependency-lock) tracks provider dependencies. It belongs to the configuration as a whole and is created when running `terraform ini`. The lock file is always named `.terraform.lock.hcl`, and this name is intended to signify that it is a lock file for various items that Terraform caches in the `.terraform` subdirectory of your working directory. You should include this file in your version control repository so that you can discuss potential changes to your external dependencies via code review, just as you would discuss potential changes to your configuration itself.  

## Terraform Backend Management

&nbsp;&nbsp;The approach to backend management allows Terraform to both create the resources needed for a remote backend as well as allow terraform to store that configuration state in that newly created backend. This also allows us to seperate infrastructure required to support terraform from infrastructure required to support the application. Because each backend, bootstrap or environment, store their own terraform.tfstate in these buckets, ensure that any backends that are shared use a unique key. When using a non-default workspace, the state path will be `/workspace_key_prefix/workspace_name/key`, `workspace_key_prefix` default is `env:`


### infra/bootstrap/account

1. Rename account to the name of the aws account alias or account id where this infrastructure will be hosted. e.g. `./bootstrap/account` becomes `./bootstrap/aws_account_id`.
2. Customize the variables in locals{} at the top of main.tf to match the desired deployment setup.
3. Open a terminal and cd into the infra/bootstrap/account directory and run the following commands:
    - `terraform init`
    - `terraform plan`
    - `terrafrom apply`
4. Uncomment out the backend "s3" {} block, fill in the appropriate information from outputs and run `terraform init -force-copy` from **Step 3.** to copy the terraform.tfstate from local to remote backend.

``` tf
  backend "s3" {
    bucket         = "<TF_STATE_BUCKET_NAME>"
    dynamodb_table = "<TF_LOCKS_TABLE_NAME>"
    ...
  }
```
5. Once these steps are complete, this should not need to be touched again, application infrastructure is managed under its envs/environment as described below.

<img src="../docs/imgs/initial_setup.svg" width="50%"/>

### infra/envs/environment

&nbsp;&nbsp;Specify different environments for the application in this section. This template repo includes three example environments: dev, staging, and prod. 

To get started with an environment, copy the backend configuration information created in the "infra/bootstrap/account" instructions above into the terraform { backend "s3" {} } block to setup the remote backend for the environment. This is where all of the infrastructure for the application will be managed. 

### Multi-Cloud Accounts vs Single Cloud Accounts

&nbsp;&nbsp;In a simpler single cloud account setup, there is one cloud account that contains the resources created for managing terraform itself, as well as the resources created for each environment. If in a single-cloud account, multi-environment setup ensure that the backend "s3" { key = path/to/terraform.tfstate} is unique for the backend, as well as each environment.

<img src="../docs/imgs/single_cloud.svg" width="50%"/>

In a multi-cloud account, multi-environment setup, the relationship between the bootstrap/account(s) and envs/environement(s) should be 1:1 for easiest management. If there are less accounts than envirnonments ensure the backend "s3" { key = path/to/terraform.tfstate} is unique from all backends in the shared account. 

<img src="../docs/imgs/multi_cloud.svg" width="50%"/>

# Workspaces
&nbsp;&nbsp; Terraform workspaces are created by default, the default workspace is named "default." Workspaces are used to allow multiple engineers to deploy their own stacks for development and testing. This allows multiple engineers to develop new features in parallel using a single environment without destroying each others infrastructure. Separate resources will be created for each engineer when using the prefix variable.

### Terraform workspace commands:

`terraform workspace show [Name]`   - This command will show the workspace you working in.

`terraform workspace list [Name]`   - This command will list all workspaces.

`terraform workspace new [Name]`    - This command will create a new workspace.

`terraform workspace select [Name]` - This command will switch your workspace to the workspace you select.

`terraform workspace delete [Name]` - This command will delete the specified workspace. (does not delete infrastructure, that step will done first)

## Workspaces and prefix - A How To

&nbsp;&nbsp; Workspaces are used to allow multiple developers to deploy their own stacks for development and testing. By default "prefix~ is set to `terraform.workspace` in the envs/dev environment, it is `staging` and `prod` in those respective environments.

### envs/dev/main.tf
``` tf
locals {
  prefix = terraform.workspace
}

module "example" {
  source  = "../../modules/example"
  prefix  = local.prefix
}

```

### modules/example/variables.tf - When creating a new module create the variable "prefix" in your variables.tf
``` tf

variable "prefix" {
  type        = string
  description = "prefix used to uniquely identify resources, allows parallel development"

}

```
### modules/example/main.tf - Use var.prefix to uniquely name resources for parallel development.
``` tf

# Create the S3 bucket with a unique prefix from terraform.workspace.
resource "aws_s3_bucket" "example" {
  bucket = "${var.prefix}-bucket"

}

```

When in the workspace "shawn", the resulting bucket name created in the aws account will be `shawn-bucket`. This prevents the following undesirable situation: If resources are not actively prefixed and two developers deploy the same resource, the developer who runs their deployment second will overwrite the deployment of the first.

## Modules

&nbsp;&nbsp;A module is a container for multiple resources that are used together. Modules can be used to create lightweight abstractions, so that you can describe your infrastructure in terms of its architecture, rather than directly in terms of physical objects. The .tf files in your working directory when you run `terraform plan` or `terraform apply` together form the root module. In this root module you will call modules that you create from the module directory to build the infrastructure required to provide any functionality needed for the application.

### infra/modules/bootstrap/
Module required to create the infrastructure that hosts all terraform backends.

### infra/modules/common/
The purpose of this module is to contain environment agnostic items. e.g. tags that are common to all environments are stored here. Example usage:


``` tf
# Import the common module

module "common" {
  source = "../../modules/common"

}

# Combine common tags with environment specific tags.
tags = merge(module.common.default_tags, {
  environment = "dev"
  description = "Backend resources required for terraform state management."

})
```
## Troubleshooting

For use later.