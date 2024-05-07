# Template repository for application infrastructure

## Overview

This template sets up foundational infrastructure for applications hosted on Amazon Web Services (AWS). It belongs to a collection of interoperable [Platform templates](https://github.com/navapbc/platform).

This template includes:

* **Team workflows** - templates for pull requests (PRs), architecture decision records (ADRs), and Makefiles
* **Account level foundational infrastructure** - infrastructure for terraform backends, including an S3 bucket and DynamoDB table for storing and managing terraform state files
* **Application infrastructure** - the infrastructure you need to set up a basic web app, including container image repository, load balancer, web service, and database
* **Continuous integration (CI) for infrastructure** - GitHub action that performs infra code checks, including linting, validation, and security compliance checks
* **Continous deployment (CD)** - infrastructure for continuous deployment, including AWS account access for Github actions, scripts for building and publishing release artifacts, and a Github action for automated deployments from the main branch
* **Documentation** - technical documentation for the decisions that went into all the defaults that come with the template

By default, the system architecture looks like this (for more information, see [system architecture documentation](/docs/system-architecture.md)):
![System architecture](https://lucid.app/publicSegments/view/e5a36152-200d-4d95-888e-4cdbdab80d1b/image.png)

## Application Requirements

Applications must meet [these requirements](/template-only-docs/application-requirements.md) to be used with this template. If you're using a [Platform application template](https://github.com/navapbc/platform?tab=readme-ov-file#platform-templates), these requirements are already met.

### Multiple Applications

You can use this template with multiple applications. By default, this template assumes your project has one application named `app`. However, it's straightforward to [add additional applications](https://github.com/navapbc/template-infra/tree/main/template-only-docs/multiple-applications.md).

## Installation

This template assumes that you already have an application to deploy.

To install this template to your project, run the following command in your project's root directory:

```bash
curl https://raw.githubusercontent.com/navapbc/template-infra/main/template-only-bin/download-and-install-template.sh | bash -s
```

The [download and install script](https://github.com/navapbc/template-infra/tree/main/template-only-bin/download-and-install-template.sh) clones this template repository, copies the template files to your repository, and removes files that are only relevant to the template itself.

Now you're ready to set up the various pieces of your infrastructure.

## Setup

After downloading and installing this template into your project, take the following steps to complete setup:

1. Follow the "First time initialization" steps in [infra/README.md](/infra/README.md).
2. [Set up continuous integration](./template-only-docs/set-up-ci.md).
3. [Set up continuous deployment](./template-only-docs/set-up-cd.md).
4. At any point, [set up your team workflow](./template-only-docs/set-up-team-workflow.md).

## Updates

This template includes a bash script to update your project to a newer version of the template. The [update script](/template-only-bin/update-template.sh) assumes that your project is version-controlled using `git`. The script will edit your project files, but it will not run `git commit`. After running the script, use `git diff` to review all changes carefully.

To update your project to a newer version of this template, run the following command in your project's root directory:

```bash
curl https://raw.githubusercontent.com/navapbc/template-infra/main/template-only-bin/update-template.sh | bash -s -- <APP_NAMES>
```

`<APP_NAMES>` is a required argument. It must be a comma-separated list (no spaces) of the apps in `/infra`. App names must be hyphen-separated (i.e. kebab-case). Examples: `app`, `app,app2`, `my-app,your-app`.

By default, the update script will apply changes from the `main` branch of this template repo. If you want to update to a different branch, a specific commit, or a specific tag (e.g. a release tag), run this instead:

```bash
curl https://raw.githubusercontent.com/navapbc/template-infra/main/template-only-bin/update-template.sh | bash -s -- <APP_NAMES> <TARGET_VERSION> <TARGET_VERSION_TYPE>
```
`<TARGET_VERSION>` should be the version of the template to install. This can be a branch, commit hash, or tag.
`<TARGET_VERSION_TYPE>` should be the type of `<TARGET_VERSION>` provided. Defaults to `branch`. This can be: `branch`, `commit`, or `tag`.

Examples:

* If your project has one application named `app` and you want to update it to the `main`  branch of this template repo, run:
    ```bash
    curl https://raw.githubusercontent.com/navapbc/template-infra/main/template-only-bin/update-template.sh | bash -s -- app
    ```
* If your project has two applications named `app, app2` and you want to update to the commit `d42963d007e55cc37ef666019428b1d06a25cf71`, run:
    ```bash
    curl https://raw.githubusercontent.com/navapbc/template-infra/main/template-only-bin/update-template.sh | bash -s -- app,app2 d42963d007e55cc37ef666019428b1d06a25cf71 commit
    ```

* If your project has three applications named `foo,bar,baz` and you want to update to the `v.0.8.0` release tag, run:
    ```bash
    curl https://raw.githubusercontent.com/navapbc/template-infra/main/template-only-bin/update-template.sh | bash -s -- foo,bar,baz v0.8.0 tag
    ```

**Remember:** Read the release notes in case there are breaking changes you need to address.
