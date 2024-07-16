# End-to-End (E2E) Tests

## Overview

This repository uses [Playwright](https://playwright.dev/) to perform end-to-end (E2E) tests. The tests can be run locally, but also run on [Pull Request preview environments](../infra/pull-request-environments.md). This ensures that any new code changes are validated through E2E tests before being merged.

## Folder Structure
In order to support e2e for multiple apps, the folder structure will include a base playwright config (`./e2e/playwright.config.js`), and app-specific derived playwright config that override the base config. See the example folder structure below:
```
- e2e
  - playwright.config.js
  - app/
    - playwright.config.js
    - tests/
      - index.spec.js
  - app2/
    - playwright.config.js
    - tests/
      - index.spec.js
```

Some highlights:
- By default, the base config is defined to run on a minimal browser-set (desktop and mobile chrome)
- Snapshots will be output locally or in the artifacts of the CI job
- HTML reports are output to the `playwright-report` folder
- Parallelism limited on CI to ensure stable execution
- Accessibility testing can be performed using the `@axe-core/playwright` package (https://playwright.dev/docs/accessibility-testing)


## Running Locally

### Running Locally From the Root Directory

Make targets are setup to easily pass in a particular app name and URL to run tests against

```
make e2e-setup # install playwright deps
make e2e-test APP_NAME=app BASE_URL=http://localhost:3000 # run tests on a particular app
```

### Running Locally From the `./e2e` Directory

If you prefer to run package.json run scripts, you can do so by creating a `./e2e/.env` file with an `APP_NAME` and `BASE_URL`

```
cd e2e

# Create .env file with BASE_URL and APP_NAME
echo "BASE_URL=http://127.0.0.1:3000" > .env
echo "APP_NAME=your-app-name" >> .env

npm install
npm run e2e-test
```

### PR Environments

The E2E tests are triggered in PR preview environments on each PR update. For more information on how PR environments work, please refer to [PR Environments Documentation](../infra/pull-request-environments.md).

### Workflows

The following workflows trigger E2E tests:
- [PR Environment Update](../../.github/workflows/pr-environment-update.yml)
- [E2E Tests Workflow](../../.github/workflows/e2e-tests.yml)

The [E2E Tests Workflow](../../.github/workflows/e2e-tests.yml) takes a `service_endpoint` URL and an `app_name` to run the tests against specific configurations for your app.

## Configuration

The E2E tests are configured using the following files:
- [Base Configuration](../../e2e/playwright.config.js)
- [App-specific Configuration](../../e2e/app/playwright.config.js)

The app-specific configuration files extend the common base configuration.

By default when running `make e2e-test APP_NAME=app BASE_URL=http://localhost:3000 ` - you don't necessarily need to pass an `BASE_URL` since the default is defined in the app-specific playwright config (`./e2e/app/playwright.config.js`).
