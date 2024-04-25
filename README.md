# Template repository for application infrastructure

## Overview

This is a template repository to set up foundational infrastructure for your application in AWS. It is part of a collection of interoperable [Platform templates](https://github.com/navapbc/platform).

This template includes setup for:

* **Team workflows** - templates for pull requests (PRs), architecture decision records (ADRs), and Makefiles.
* **Account level foundational infrastructure** - infrastructure for terraform backends, including an S3 bucket and DynamoDB table for storing and managing terraform state files.
* **Application infrastructure** - the infrastructure you need to set up a basic web app, such as a image container repository, load balancer, web service, and database.
* **CI for infra** - GitHub action that performs infra code checks, including linting, validation, and security compliance checks.
* **CD / Deployments** - infrastructure for continuous deployment, including: AWS account access for Github actions, scripts for building and publishing release artifacts, and a Github action for automated deployments from the main branch.
* **Documentation** - technical documentation for the decisions that went into all the defaults that come with the template.

The system architecture will look like this (see [system architecture documentation](/docs/system-architecture.md) for more information):
![System architecture](https://lucid.app/publicSegments/view/e5a36152-200d-4d95-888e-4cdbdab80d1b/image.png)

## Application Requirements

This template assumes that you have an application to deploy. See [application requirements](./template-only-docs/application-requirements.md) for more information on what is needed to use the infrastructure template. If you're using one of the [Platform application templates](https://github.com/navapbc/platform?tab=readme-ov-file#platform-templates), these requirements are already met.

## Installation

To get started using the infrastructure template on your project, run the following command in your project's directory to execute the [download and install script](https://github.com/navapbc/template-infra/tree/main/template-only-bin/download-and-install-template.sh), which clones the template repository, copies the template files to your repository, and removes any files that are only relevant to the template itself:

```bash
curl https://raw.githubusercontent.com/navapbc/template-infra/main/template-only-bin/download-and-install-template.sh | bash -s
```

Now you're ready to set up the various pieces of your infrastructure.

## Setup

After downloading and installing the template into your project:

1. Follow the steps in [infra/README.md](/infra/README.md) to setup the infrastructure for your application.
1. After setting up AWS resources, you can [set up GitHub Actions workflows](./template-only-docs/set-up-ci.md).
1. After configuring GitHub Actions, you can [set up continuous deployment](./template-only-docs/set-up-cd.md).
1. At any point, [set up your team workflow](./template-only-docs/set-up-team-workflow.md).

## Updates

There are multiple ways to receive template updates on your project. For most updates, you can simply run the [update-template.sh](/template-only-bin/update-template.sh) script

```bash
curl https://raw.githubusercontent.com/navapbc/template-infra/main/template-only-bin/update-template.sh | bash -s
```

If the update fails the simplest option may be to re-run the installation script above and manually review the changes.

**Remember:** Make sure to read the release notes in case there are breaking changes you need to address.

### Renamed applications

If you renamed your application from `infra/app` to something else like `infra/foo`, then first rename your app back to `infra/app` before applying the updates e.g.

```bash
mv foo app
mv infra/foo infra/app
curl https://raw.githubusercontent.com/navapbc/template-infra/main/template-only-bin/update-template.sh | bash -s
mv infra/app infra/foo
mv app foo
```
