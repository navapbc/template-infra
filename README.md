# Template repository for application infrastructure

## Overview

This template sets up foundational infrastructure for applications hosted on Amazon Web Services (AWS). It belongs to a collection of interoperable [Platform templates](https://github.com/navapbc/platform).

This template includes:

* **Team workflows** - templates for pull requests (PRs), architecture decision records (ADRs), and Makefiles
* **Account level foundational infrastructure** - infrastructure for Terraform backends, including an S3 bucket and DynamoDB table for storing and managing Terraform state files
* **Application infrastructure** - the infrastructure you need to set up a basic web app, including container image repository, load balancer, web service, and database
* **Continuous integration (CI) for infrastructure** - GitHub action that performs infrastructre code checks, including linting, validation, and security compliance checks
* **Continous deployment (CD)** - infrastructure for continuous deployment, including AWS account access for Github actions, scripts for building and publishing release artifacts, and a Github action for automated deployments from the main branch
* **Documentation** - technical documentation for the decisions that went into all the defaults that come with the template

By default, the system architecture looks like this (for more information, see [system architecture documentation](/docs/system-architecture.md)):
![System architecture](https://lucid.app/publicSegments/view/e5a36152-200d-4d95-888e-4cdbdab80d1b/image.png)

## Application Requirements

Applications must meet [these requirements](/template-only-docs/application-requirements.md) to be used with this template. If you're using a [Platform application template](https://github.com/navapbc/platform?tab=readme-ov-file#platform-templates), these requirements are already met.

### Multiple Applications

You can use this template with multiple applications. By default, this template assumes your project has one application named `app`. However, it's straightforward to [add additional applications](/template-only-docs/multiple-applications.md).

## Installation

This template assumes that you already have an application to deploy.

To install this template to your project, run the following command in your project's root directory:

```bash
curl https://raw.githubusercontent.com/navapbc/template-infra/main/template-only-bin/download-and-install-template.sh | bash -s
```

The [download and install script](/template-only-bin/download-and-install-template.sh) clones this template repository, copies the template files to your repository, and removes files that are only relevant to the template itself.

Now you're ready to set up the various pieces of your infrastructure.

## Setup

After downloading and installing this template into your project, take the following steps to complete setup:

1. Follow the "First time initialization" steps in [infra/README.md](/infra/README.md).
2. [Set up continuous integration](./template-only-docs/set-up-ci.md).
3. [Set up continuous deployment](./template-only-docs/set-up-cd.md).
4. At any point, [set up your team workflow](./template-only-docs/set-up-team-workflow.md).

## Updates

This template includes a script to update your project to a newer version of the template.  To update your project to a newer version of this template, follow the [update template instructions](/template-only-docs/update-template.md).