# Getting Started With Terraform

## Install Terraform CLI
&nbsp;&nbsp;Terraform is an infrastructure as code (IaC) tool that allows you to build, change, and version infrastructure safely and efficiently. This includes both low-level components like compute instances, storage, and networking, as well as high-level components like DNS entries and SaaS features. Install the terraform commmand line tool by follow the instructions found here:

- [Install Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

## Install AWS CLI
&nbsp;&nbsp;The AWS Command Line Interface (AWS CLI) is a unified tool to manage your AWS services. With just one tool to download and configure, you can control multiple AWS services from the command line and automate them through scripts. Install the aws commmand line tool by following the instructions found here:

- [Install AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

## AWS Authentication

&nbsp;&nbsp;In order for Terraform to authenticate with your accounts you will need to configure your aws credentials using the AWS CLI or manually create your config and credentials file. If you need to manage multiple credentials or create named profiles for use with different environments you can add the `--profile` option.

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

&nbsp;&nbsp;The `terraform init` command is used to initialize a working directory containing Terraform configuration files. This is the first command that should be run after writing a new Terraform configuration or cloning an existing one from version control. It is safe to run this command multiple times.

&nbsp;&nbsp;The `terraform plan` command creates an execution plan, which lets you preview the changes that Terraform plans to make to your infrastructure. By default, when Terraform creates a plan it:

- Reads the current state of any already-existing remote objects to make sure that the Terraform state is up-to-date.
- Compares the current configuration to the prior state and noting any differences.
- Proposes a set of change actions that should, if applied, make the remote objects match the configuration.

&nbsp;&nbsp;The `terraform apply` command executes the actions proposed in a Terraform plan.

&nbsp;&nbsp; The `terraform destroy` command is a convenient way to destroy all remote objects managed by a particular Terraform configuration. Use `terraform plan -destroy` to preview what remote objects will be destroyed if you run `terraform destroy`.

⚠️ WARNING! ⚠️ This is a destructive command! As a best practice, it's recommended that you comment out resources in non-development environments rather than running this command. `terraform destroy` should only be used as a way to cleanup a development environment. e.g. a developers workspace after they are done with it.

For more information about terraform commands follow the link below:

- [Basic CLI Features](https://www.terraform.io/cli/commands)

## Terraform Backend

### infra/bootstrap/account

1. Rename bootstrap/account, account directory to the name of the aws account alias or account id where this infrastructure will be hosted.
2. Customize the variables in locals{} at the top of main.tf to match the desired deployment setup.
3. Open a terminal and cd into the infra/bootstrap/account directory and run the following commands:
    - terraform init
    - terraform plan
    - terrafrom apply
4. Uncomment out the backend "s3" {} block, fill in the appropriate information from outputs and repeate step `3.` to switch from local to remote backend.

``` tf
  backend "s3" {
    bucket         = "AWS_ACCOUNT_ID-AWS_REGION-tf-state"
    key            = "terraform/backend/terraform.tfstate"
    region         = "REGION_OF_BUCKET"
    encrypt        = "true"
    dynamodb_table = "tf_state_locks"
  }
```
5. Once these steps are complete, this should not need to be touched again, application infrastructure is managed under its envs/environment as described below.

Note: For subsequent accounts if using a multi-account setup, copy the entire account directory and repeat the previous steps for each account.

### infra/envs/environment

&nbsp;&nbsp;Specify different environments for the application in this section. This template repo includes three example environments: test, staging, and prod. 

To get started with an environment, copy the backend configuration created in the "infra/bootstrap/account" instructions above into the terraform { backend "s3" {} } block to setup the remote backend for the environment. This is where all of the infrastructure for the application will be managed. 

### Multi-Cloud Accounts vs Single Cloud Accounts

&nbsp;&nbsp;In a simpler single cloud account setup, there is one cloud account that contains the resources created for managing terraform itself, as well as the resources created for each environment.

<insert single cloud diagram here>

In a multi-cloud account, multi-environment setup, the relationship between the bootstrap/account(s) and envs/environement(s) should be 1:1. In a single-cloud account, multi-environment setup ensure that the backend "s3" { key = path/to/terraform.tfstate} is unique for the backend, as well as each environment.

<insert multi-cloud diagram here>

# Diagrams

## Initial Setup
<img src="../docs/imgs/initial_setup.svg" width="50%"/>

## Multi-Cloud
<img src="../docs/imgs/multi_cloud.svg" width="50%"/>

## Single-Cloud
<img src="../docs/imgs/single_cloud.svg" width="50%"/>


# Workspaces
&nbsp;&nbsp; Workspaces can be used here to allow multiple engineers to deploy their own stacks for development and testing. This allows multiple engineers to develop on a single environment's terraform files without overwriting each other. Separate resources will be created for each engineer.
### Terraform workspace commands:

`terraform workspace show [Name]`   - This command will show the workspace you working in.

`terraform workspace list [Name]`   - This command will list all workspaces.

`terraform workspace new [Name]`    - This command will create a new workspace.

`terraform workspace select [Name]` - This command will switch your workspace to the workspace you select.

`terraform workspace delete [Name]` - This command will delete the specified workspace. (does not delete infrastructure, that step will done first)

## Workspaces - Staging Environment
&nbsp;&nbsp; Workspaces can be used here to allow multiple developers to deploy their own stacks for development and testing. If workspaces wont be necessary for this project set the prefix variable to "staging."
``` tf
# Example resource using the prefix
resource "aws_instance" "self" {
  ami           = "ami-0cff7528ff583bf9a"
  instance_type = "t2.micro"
  tags = {
    Name = "${local.prefix}-instance"
  }
}
```
If workspaces wont be necessary for your project, set the prefix variable in the <what file> to "staging."
<insert example of how to do this properly here>

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
tags = merge(module.common.tags, {
  environment = "staging"
  description = "Backend resources required for terraform state management."

})
```
## Troubleshooting

For use later.