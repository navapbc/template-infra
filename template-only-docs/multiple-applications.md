# Multiple Applications

You can use this template with multiple applications. By default, this template assumes your project has one application named `app`. However, it's straightforward to add additional applications.

## Prerequisites

* None

## Instructions to add an additional application

### 1. Ensure the application meets the Application Requirements

Applications must meet [these requirements](/template-only-docs/application-requirements.md) to be used with this template. If you're using a [Platform application template](https://github.com/navapbc/platform?tab=readme-ov-file#platform-templates), these requirements are already met.

### 2. Add the application to the root directory

Add the application's source code to a folder in the project's root folder (e.g. `/second-app`).

⚠️ Warning: In general, it's best to use short, descriptive one-word names because some AWS resources have character limits. If you must use multiple words, use hyphens (not underscores) to separate each word.

### 3. Add infrastructure support for the application

To add the Terraform modules for the application, run:

```bash
curl https://raw.githubusercontent.com/navapbc/template-infra/main/template-only-bin/download-and-install-app.sh | bash -s -- <APP_NAME>
```

`<APP_NAME>` must be the name of the application you chose in the previous step.

This will add a new terraform module at `/infra/<APP_NAME>` and create the following CI/CD workflows:

* `/.github/workflows/cd-<APP_NAME>.yml`
* `/.github/workflows/ci-<APP_NAME>-vulnerability-scans.yml`

### 4. Configure the application as usual

Follow the per-application steps in [`/infra/README.md`](/infra/README.md) to complete setup.