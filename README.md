# Template repository for application infrastructure

## Overview

This is a template repository to set up foundational infrastructure for your application in AWS. This template includes setup for:

* **Team workflows** - templates for pull requests (PRs), architecture decision records (ADRs), and Makefiles.
* **Account level foundational infrastructure** - infrastructure for terraform backends, including an S3 bucket and DynamoDB table for storing and managing terraform state files.
* **Application infrastructure** - the infrastructure you need to set up a basic web app, such as a image container repository, load balancer, web service, and database.
* **CI for infra** - GitHub action that performs infra code checks, including linting, validation, and security compliance checks.
* **CD / Deployments** - infrastructure for continuous deployment, including: AWS account access for Github actions, scripts for building and publishing release artifacts, and a Github action for automated deployments from the main branch.
* **Documentation** - technical documentation for the decisions that went into all the defaults that come with the template.

The template infra is intended to work with multiple application templates. See [template-application-flask](https://github.com/navapbc/template-application-flask) and [template-application-nextjs](https://github.com/navapbc/template-application-nextjs).

## Installation

To get started using the template infrastructure on your project, run the following command in your project's directory to execute the [install script](https://github.com/navapbc/template-infra/tree/main/template-only-bin/install-template.sh), which clones the template repository, copies the template files to your repository, and removes any files that are only relevant to the template itself:

```bash
curl https://raw.githubusercontent.com/navapbc/template-infra/main/template-only-bin/download-and-install-template.sh | bash -s
```

Now you're ready to set up the various pieces of your infrastructure.

## Application Requirements

This template assumes that you have an application to deploy. See [application requirements](./template-only-docs/application-requirements.md) for more information on what is needed to use the infrastructure template. If you're using one of the Platform application templates, these requirements are already met.

## Setup

After downloading and installing the template into your project:

1. Follow the steps in `docs/infra/README.md` to setup the infrastructure for your application.
1. [Set up team workflow](./template-only-docs/set-up-team-workflow.md)
1. [Set up GitHub Actions workflows](./template-only-docs/set-up-ci.md)
1. [Set up continuous deployment](./template-only-docs/set-up-cd.md)
