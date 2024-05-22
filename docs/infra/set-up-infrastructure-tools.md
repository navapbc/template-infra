# Set up infrastructure developer tools

Complete these steps to work on the infrastructure.

## Prerequisites

* None

## Instructions

### Install Terraform

[Terraform](https://www.terraform.io/) is an infrastructure as code (IaC) tool that allows you to build, change, and version infrastructure safely and efficiently. This includes both low-level components, like compute instances, storage, and networking, as well as high-level components, like DNS entries and Software-as-a-Service (SaaS) features.

You may need to install different versions of terraform on your machine because different projects may require different versions. We recommend managing terraform with [Terraform Version Manager (tfenv)](https://github.com/tfutils/tfenv).

1. Use [Homebrew](https://brew.sh/) to install tfenv:
    ```bash
    brew install tfenv
    ```
2. Install the version of Terraform you need:
    ```bash
    tfenv install 1.4.6
    ```

If you are unfamiliar with Terraform, check out this [basic introduction](./intro-to-terraform.md).

### Install AWS CLI

The [AWS Command Line Interface (AWS CLI)](https://aws.amazon.com/cli/) is a unified tool to manage your AWS services. With just one tool to download and configure, you can control multiple AWS services from the command line and automate them through scripts.

Install the AWS CLI by following the [AWS installation instructions](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html).

### Install Go

The [Go programming language](https://go.dev/dl/) is required to run [Terratest](https://terratest.gruntwork.io/), the unit test framework for Terraform.

Use Homebrew to install go:

```bash
brew install golang
```

### Install GitHub CLI

The [GitHub CLI](https://cli.github.com/) is useful for automating certain operations on GitHub, such as GitHub actions. For example, you need the Github CLI to run [check-github-actions-auth.sh](/bin/check-github-actions-auth.sh).

Use Homebrew to install the GitHub CLI:

```bash
brew install gh
```

### Install linters

The following linters are run as part of the CI pipeline:

* [Shellcheck](https://github.com/koalaman/shellcheck)
* [actionlint](https://github.com/rhysd/actionlint)
* [markdown-link-check](https://github.com/tcort/markdown-link-check)

To install and run them locally, run:

```bash
brew install shellcheck
brew install actionlint
make infra-lint
```

### Authenticate with AWS

To use Terraform with your AWS accounts, you must configure your AWS credentials. There are multiple ways to authenticate with AWS, but we recommend the following process:

1. Use the AWS CLI command `aws configure --profile <PROFILE_NAME>` to create a separate profile for each AWS account. `aws configure` will store your credentials in `~/.aws/credentials` (Linux & Mac) or `%USERPROFILE%\.aws\credentials` (Windows). For example, to create a profile named `my-aws-account`, run:
    ```bash
    $ aws configure --profile my-aws-account
    AWS Access Key ID [None]: AKIAIOSFODNN7EXAMPLE
    AWS Secret Access Key [None]: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
    Default region name [None]: us-east-2
    Default output format [None]: json
    ```
2. Set the local environment variable `AWS_PROFILE` to the profile name. For example, to set the `AWS_PROFILE` environment variable to `my-aws-account`, run:
   ```bash
   export AWS_PROFILE=my-aws-account
   ```
3. (Optional) Use the [direnv](https://direnv.net/) tool to manage local environment variables. Instead of directly exporting environment variables on your machine, allow direnv to automatically set environment variables depending on the directory you are working in.
4. Verify access by running the following command. It should print out the profile name you set in Step 1.
    ```bash
    aws sts get-caller-identity
    ```
    To see a more human-readable account alias instead of the account, run:
    ```bash
    aws iam list-account-aliases
    ```


### References

- [Configuration basics][1]
- [Named profiles for the AWS CLI][2]
- [Configuration and credential file settings][3]

[1]: https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html
[2]: https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-profiles.html
[3]: https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html
