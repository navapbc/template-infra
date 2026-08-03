# AWS infrastructure template

_Part of [Nava Strata](https://github.com/navapbc/strata)._

<p align="center">
  <a href="https://github.com/navapbc/template-infra/blob/main/LICENSE">
    <img src="https://img.shields.io/badge/license-apache_2.0-red" alt="Nava Strata is released under the Apache 2.0 license" >
  </a>
  <a href="https://github.com/navapbc/template-infra/blob/main/CONTRIBUTING.md">
    <img src="https://img.shields.io/badge/PRs-Welcome-brightgreen" alt="PRs welcome!" />
  </a>
  <a href="https://github.com/navapbc/template-infra/commits/main">
    <img src="https://img.shields.io/github/commit-activity/m/navapbc/template-infra" alt="git commit activity" />
  </a>
</p>

This template repository provides **foundational AWS infrastructure** for
deploying modern web applications.

## What's Included

This template provides everything you need to deploy a production-ready web application:

- **Team Workflows** – Pull request templates, architecture decision records (ADRs), and Makefiles for streamlined development
- **Account Level Foundational Infrastructure** – Infrastructure for terraform backends, including an S3 bucket for storing and managing terraform state files.
- **Application Infrastructure** – Container registry, load balancers, web services, and databases for your web app
- **Continuous Integration** – GitHub Actions for automated linting, validation, and security compliance checks
- **Continuous Deployment** – infrastructure for continuous deployment, including: AWS account access for Github actions, scripts for building and publishing release artifacts, and a Github action for automated deployments from the main branch.
- **Comprehensive Documentation** – Technical documentation explaining all architectural decisions and defaults

## System Architecture

The infrastructure creates a robust, scalable system architecture:

![System architecture](https://lucid.app/publicSegments/view/e5a36152-200d-4d95-888e-4cdbdab80d1b/image.png)

> See the [system architecture documentation](/docs/system-architecture.md) for detailed information.

## Prerequisites

Before using this template, you need an application ready to deploy.

- **Have an existing application?** Review the [application requirements](./template-only-docs/application-requirements.md) to ensure compatibility
- **Starting from scratch?** Use one of the [Platform application templates](https://github.com/navapbc/platform?tab=readme-ov-file#platform-templates) – they're pre-configured to work with this infrastructure template

---

## Getting Started

### Installation

Install the template into your project using the Nava Platform CLI:

1. **Install the nava-platform tool**:
Follow the instructions at [github.com/navapbc/platform-cli](https://github.com/navapbc/platform-cli)

2. **Run the installation command**
in your project's root directory:

   ```sh
   nava-platform infra install .
   ```

3. **You're ready to go!**
Proceed to the setup steps below.

### Setup Guide

Follow these steps in order to set up your complete infrastructure:

#### Step 1: Infrastructure Setup
Follow the instructions in [infra/README.md](/infra/README.md) to setup the infrastructure for your application.

#### Step 2: Configure CI
After setting up AWS resources, [set up GitHub Actions workflows](./template-only-docs/set-up-ci.md) for automated testing and validation

#### Step 3: Enable Continuous Deployment
After configuring GitHub Actions, [set up continuous deployment](./template-only-docs/set-up-cd.md) for automated deployments from the main branch

#### Step 4: Pull Request Environments (Optional)
After setting up continuous deployment, you can optionally [set up pull request environments](./template-only-docs/set-up-pr-environments.md) for testing changes in isolation

#### Step 5: Team Workflow
[Set up your team workflow](./template-only-docs/set-up-team-workflow.md) – this can be done at any point in the process

## Keeping Your Infrastructure Up to Date
With the [nava-platform tool installed](https://github.com/navapbc/platform-cli), run the following in your project's root directory:

```sh
nava-platform infra update .
```

### Handling Update Conflicts
If the update fails, the tool will provide some guidance, but effectively the
next step will be apply the updates in smaller pieces with manual merge conflict
resolution.

> **Important:** Always read the [release notes](https://github.com/navapbc/template-infra/releases) before updating to check for breaking changes that may affect your infrastructure.

---

## Documentation

Comprehensive guides and architectural decisions are available in
[docs/](/docs/). These are included in generated projects as well.

Topics related to the template itself and its development are in
[template-only-docs/](/template-only-docs/). These do not get included in
generated projects.

---

## License

This project is licensed under the Apache 2.0 License. See the
[LICENSE](LICENSE) file for details.

## Community

- [Code of Conduct](CODE_OF_CONDUCT.md)
- [Contributing Guidelines](CONTRIBUTING.md)
- [Security Policy](SECURITY.md)
