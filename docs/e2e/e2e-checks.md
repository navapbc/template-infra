# End-to-End (E2E) Tests

## Overview

This repository uses [Playwright](https://playwright.dev/) to perform end-to-end (E2E) tests. The tests can be run locally (natively or within Docker), but they also run on [Pull Request preview environments](../infra/pull-request-environments.md). This ensures that any new code changes are validated through E2E tests before being merged.

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
- By default, the base config is defined to run on a minimal browser-set (desktop and mobile chrome). Browsers can be added in the app-specific playwright config.
- Snapshots will be output locally or in the artifacts of the CI job
- HTML reports are output to the `playwright-report` folder
- Parallelism limited on CI to ensure stable execution
- Accessibility testing can be performed using the `@axe-core/playwright` package (https://playwright.dev/docs/accessibility-testing)

### Running with Docker




## How to Run Tests
<table border="1" style="width:100%; text-align:center;">
  <tr>
    <th></th>
    <th>Local Natively Without Docker</th>
    <th>Local With Docker</th>
    <th>CI / Github Actions</th>
  </tr>
  <tr>
  <td>Location App is Running</td>
  <td colspan="2" style="vertical-align:top;">Locally (*port 3000 in examples) </td>
  <td>PR Preview Environment</td>
  </tr>
  <tr>
    <td style="vertical-align:top;">With make commands</td>
    <td style="vertical-align:top;">
      From root folder:<br>
      <ul style="list-style-position:inside; text-align:left;">
        <li><code>make e2e-setup-native</code></li>
        <li><code>make e2e-test APP_NAME=app BASE_URL=http://localhost:3000</code></li>
        <li><code>make e2e-copy-report</code></li>
      </ul>
    </td>
    <td style="vertical-align:top;">
      From root folder:<br>
      <ul style="list-style-position:inside; text-align:left;">
        <li><code>make e2e-run APP_NAME=app BASE_URL=http://host.docker.internal:3000</code></li>
        <br />
        <em>* BASE_URL cannot use localhost</em>
      </ul>
    </td>
    <td style="vertical-align:top;">
      <em>* uses make commands <br /><br /> see the relevant <a href="../../.github/workflows/e2e-tests.yml">e2e Github Actions workflow file</a>
    </em>
    </td>
  </tr>

  <tr>
    <td style="vertical-align:top;">Show Report</td>
    <td colspan="2" style="vertical-align:top;">From the root: <br /><code>make e2e-show-report</code></td>
    <td style="vertical-align:top;">View Artifacts of Github Actions job</td>
  </tr>
</table>

- Running local with Docker is the preferred approach
    - When running locally with Docker, the `playwright-report` will be copied to your local `./e2e/` folder
- For all local runs, your application needs to be running


### PR Environments

The E2E tests are triggered in PR preview environments on each PR update. For more information on how PR environments work, please refer to [PR Environments Documentation](../infra/pull-request-environments.md).

### Workflows

The following workflows trigger E2E tests:
- [PR Environment Update](../../.github/workflows/pr-environment-checks.yml)
- [E2E Tests Workflow](../../.github/workflows/e2e-tests.yml)

The [E2E Tests Workflow](../../.github/workflows/e2e-tests.yml) takes a `service_endpoint` URL and an `app_name` to run the tests against specific configurations for your app.

## Configuration

The E2E tests are configured using the following files:
- [Base Configuration](../../e2e/playwright.config.js)
- [App-specific Configuration](../../e2e/app/playwright.config.js)

The app-specific configuration files extend the common base configuration.

By default when running `make e2e-test APP_NAME=app BASE_URL=http://localhost:3000 ` - you don't necessarily need to pass an `BASE_URL` since the default is defined in the app-specific playwright config (`./e2e/app/playwright.config.js`).
