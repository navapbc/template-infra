# Template repository for application infrastructure

## Overview

This is a template repository to set up foundational infrastructure for your application in AWS. It is part of a collection of interoperable [Platform templates](https://github.com/navapbc/platform).

This template includes setup for:

- **Team workflows** - templates for pull requests (PRs), architecture decision records (ADRs), and Makefiles.
- **Account level foundational infrastructure** - infrastructure for terraform backends, including an S3 bucket and DynamoDB table for storing and managing terraform state files.
- **Application infrastructure** - the infrastructure you need to set up a basic web app, such as a image container repository, load balancer, web service, and database.
- **CI for infra** - GitHub action that performs infra code checks, including linting, validation, and security compliance checks.
- **CD / Deployments** - infrastructure for continuous deployment, including: AWS account access for Github actions, scripts for building and publishing release artifacts, and a Github action for automated deployments from the main branch.
- **Documentation** - technical documentation for the decisions that went into all the defaults that come with the template.

The system architecture will look like this (see [system architecture documentation](/docs/system-architecture.md) for more information):
![System architecture](https://lucid.app/publicSegments/view/e5a36152-200d-4d95-888e-4cdbdab80d1b/image.png)

## Application Requirements

This template assumes that you have an application to deploy. See [application requirements](./template-only-docs/application-requirements.md) for more information on what is needed to use the infrastructure template. If you're using one of the [Platform application templates](https://github.com/navapbc/platform?tab=readme-ov-file#platform-templates), these requirements are already met.

## Installation

To get started using the infrastructure template on your project, clone this
repository to a local directory next to your project, [install the nava-platform
tool](https://github.com/navapbc/platform-cli), and then run the following
command in your project's root directory:

```sh
nava-platform infra install --template-uri ../template-infra .
```

Now you're ready to set up the various pieces of your infrastructure.

## Setup

After downloading and installing the template into your project:

1. Follow the steps in [infra/README.md](/infra/README.md) to setup the infrastructure for your application.
2. After setting up AWS resources, you can [set up GitHub Actions workflows](./template-only-docs/set-up-ci.md).
3. After configuring GitHub Actions, you can [set up continuous deployment](./template-only-docs/set-up-cd.md).
4. After setting up continuous deployment, you can optionally [set up pull request environments](./template-only-docs/set-up-pr-environments.md)
5. At any point, [set up your team workflow](./template-only-docs/set-up-team-workflow.md).

## Updates

With the [nava-platform tool
installed](https://github.com/navapbc/platform-cli), pull updates to your local
`template-infra` repository, then run the following in your project's root
directory:

```sh
nava-platform infra update .
```

If the update fails, the tool will provide some guidance, but effectively the
next step will be apply the updates in smaller pieces with manual merge conflict
resolution.

**Remember:** Make sure to read the release notes in case there are breaking changes you need to address.
