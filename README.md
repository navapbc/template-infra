# Template repository for application infrastructure

## Overview

This is a template repository for a to set up foundational infrastructure for your application in AWS. This template includes setup for:

* **Team workflows** - PR template, architecture decision record (ADR) template, Makefile.
* **Infrastructure as code** - infrastructure for terraform backends, including S3 buckets and DynamoDB table for locking terraform state
* **CI for infra** - GitHub action that performs infra code checks, including linting, validation, and security compliance checks.
* **Application infrastructure** - the infrastructure you need to set up a basic web app, such as a image container repository, load balancer, web service, and database.
* **CD / Deployments** - infrastructure to set up AWS account access for GitHub actions, Makefile commands for building and publishing release candidates, and a GitHub action for deploying on merges to main.
* **Documentation** - technical documentation for the decisions that went into all the defaults that come with the template.

The template infra is intended to work with multiple application templates. See [template-application-flask](https://github.com/navapbc/template-application-flask) and [template-application-nextjs](https://github.com/navapbc/template-application-nextjs).

## Installation

To get started using the template infrastructure on your project, install the template by cloning the template repository and copying the following folders/files to your repository and removing any files that are only relevant to the template itself:

```bash
# fetch latest version of template-infra
git clone --single-branch --branch main --depth 1 git@github.com:navapbc/template-infra.git

cp -r \
  template-infra/.github \
  template-infra/bin \
  template-infra/docs \
  template-infra/infra \
  template-infra/docker-compose.yml \
  Makefile \
  .

rm .github/workflows/template-only-*

# clean up template-infra folder
rm -fr template-infra
```

Now you're ready to set up the various pieces of your infrastructure.

## Setup

1. [Set up team workflow](./template-only-docs/set-up-team-workflow.md)
2. [Set up resources needed to manage infrastructure as code (IaC)](./template-only-docs/set-up-infrastructure-as-code.md)
3. [Set up continuous integration](./template-only-docs/set-up-ci.md)
4. [Set up application](./docs/infra/set-up-app.md)
5. [Set up application environments](./docs/infra/set-up-app-env.md)

### Clone the repo to your local development environment

Deploy the infrastructure from the infra folder by following the README.md instructions... I need to create the CD from [WMDP-96 Setup github actions for CD](https://wicmtdp.atlassian.net/browse/WMDP-96) then redo the steps above to verify if cd.yml will run, should also consider renaming ci.yml
