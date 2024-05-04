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

By default, the system architecture will look like this (see [system architecture documentation](/docs/system-architecture.md) for more information):
![System architecture](https://lucid.app/publicSegments/view/e5a36152-200d-4d95-888e-4cdbdab80d1b/image.png)

## Application Requirements

This template assumes that you have an application to deploy. See [application requirements](https://github.com/navapbc/template-infra/tree/main/template-only-docs/application-requirements.md) for more information on what is needed to use the infrastructure template. If you're using one of the [Platform application templates](https://github.com/navapbc/platform?tab=readme-ov-file#platform-templates), these requirements are already met.

### Multiple Applications

This infrastructure supports deployment and CI/CD for projects with multiple applications. By default, the infrastructure assumes the project only has one application, named `app`. However, it's straightforward to include additional applications. See [how to add multiple applications](https://github.com/navapbc/template-infra/tree/main/template-only-docs/multiple-applications.md).

## Installation

To get started using the infrastructure template on your project, run the following command in your project's directory to execute the [download and install script](https://github.com/navapbc/template-infra/tree/main/template-only-bin/download-and-install-template.sh), which clones the template repository, copies the template files to your repository, and removes any files that are only relevant to the template itself:

```bash
curl https://raw.githubusercontent.com/navapbc/template-infra/main/template-only-bin/download-and-install-template.sh | bash -s
```

Now you're ready to set up the various pieces of your infrastructure.

## Setup

After downloading and installing the template into your project:

1. Follow the steps in [infra/README.md](/infra/README.md) to setup the infrastructure for your application.
2. After setting up AWS resources, you can [set up GitHub Actions workflows for continuous integration](./template-only-docs/set-up-ci.md).
3. After configuring GitHub Actions, you can [set up continuous deployment](./template-only-docs/set-up-cd.md).
4. At any point, [set up your team workflow](./template-only-docs/set-up-team-workflow.md).

## Updates

To apply template updates to your project, run

```bash
curl https://raw.githubusercontent.com/navapbc/template-infra/main/template-only-bin/update-template.sh | bash -s -- <APP_NAMES>
```

<APP_NAMES> is a required argument. It must be a comma-separated list (no spaces) of the apps in `/infra`. App names are expected to be hyphen-separated (i.e. kebab-case).
  Examples: `app`, `app,app2`, `my-app,your-app`

By default, the update script will update to the latest commit on the `main` branch in the template repo. If you want to update to a different branch, a specific commit, or a specific tag (e.g. a release tag), run this instead

```bash
curl https://raw.githubusercontent.com/navapbc/template-infra/main/template-only-bin/update-template.sh | bash -s -- <APP_NAMES> <TARGET_VERSION> <TARGET_VERSION_TYPE>
```
<TARGET_VERSION> should be the version of the template to install. This can be a branch, commit hash, or tag.
<TARGET_VERSION_TYPE> should be the type of <TARGET_VERSION> provided. Defaults to `branch`. This can be: `branch`, `commit`, or `tag`.

Examples:
- To update a project with one application named `app` to `main` in the template repo:
    ```bash
    curl https://raw.githubusercontent.com/navapbc/template-infra/main/template-only-bin/update-template.sh | bash -s -- app
    ```
- To update a project with two applications to a specific commit:
    ```bash
    curl https://raw.githubusercontent.com/navapbc/template-infra/main/template-only-bin/update-template.sh | bash -s -- app,app2 d42963d007e55cc37ef666019428b1d06a25cf71 commit
    ```

- To update a project with three applications to a tag:
    ```bash
    curl https://raw.githubusercontent.com/navapbc/template-infra/main/template-only-bin/update-template.sh | bash -s -- alpha,beta,gamma-three v0.8.0 tag
    ```

**Remember:** Make sure to read the release notes in case there are breaking changes you need to address.
