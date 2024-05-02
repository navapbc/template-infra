# Multiple Applications

This infrastructure supports multiple deployment and CI/CD for projects with multiple applications. By default, the infrastructure assumes the project only has one application, named `app`. However, it's straightforward to include additional applications.

## Prerequisites

* None

## Instructions

### 1. Ensure the application meets the Application Requirements

In order to use this infrastructure, the application must meets the [application requirements](/template-only-docs/application-requirements.md).

### 2. Add the application to the root directory

Add the application's source code to a folder that lives in the project root folder, such as `/second-app`.

⚠️ Warning: In general, it's best to use a short, descriptive one-word name because some AWS resources have character limits. If you must use multiple words, use hyphens (not underscores) to separate each word.

### 3. Add infrastructure support for the application

Run the following to install the application

```bash
curl https://raw.githubusercontent.com/navapbc/template-infra/main/template-only-bin/download-and-install-app.sh | bash -s -- <APP_NAME>
```

`<APP_NAME>` needs to be the name of the application you chose in the previous step.

This will add a new terraform module at `/infra/<APP_NAME>` and create the following CI/CD workflows:

* `/.github/workflows/cd-<APP_NAME>.yml`
* `/.github/workflows/ci-<APP_NAME>-vulnerability-scans.yml`

### 4. Configure the application as usual

Follow the per-application steps in [`/infra/README.md`](/infra/README.md) to configure the application.