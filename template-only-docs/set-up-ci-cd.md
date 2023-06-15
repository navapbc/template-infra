# Set up CI/CD

After [setting up a dev environment](/docs/infra/set-up-app-env.md), you can complete the CI/CD setup by doing the following:

* Uncomment the infra end-to-end tests in [ci-infra.yml](/.github/workflows/ci-infra.yml). You can verify that CI is running and passing by clicking into the Actions tab in GitHub. Note that this repo only contains CI for infra (`ci-infra.yml`). Application CI (`ci-app.yml`) is included as part of the application templates.
* Enable continuous deployment in [cd.yml](../.github/workflows/cd.yml) by searching for `!!` and following the instructions to uncomment the `on: push: ["main]` workflow trigger. This will trigger the deployment workflow on every merge to `main`.
