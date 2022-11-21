# Set up CI

## Static analysis checks

CI should automatically be set up once the CI files in `.github/workflows` are committed and pushed to the remote repository in GitHub.

Some checks are disabled until you've completed certain setup steps:

* After doing the [project setup step](./set-up-infrastructure-as-code.md), look for `!!` in the [Makefile](../Makefile) and uncomment the check for validating the application's env-template module
* After [setting up the dev environment](../docs/infra/set-up-app-env.md), look for `!!` in [ci-infra.yml](../.github/workflows/ci-infra.yml), update the `role-to-assume` with the GitHub actions ARN, and uncomment the infra end-to-end tests.

You can verify that CI is running and passing by clicking into the Actions tab in GitHub.

Note that this repo only contains CI for infra (`ci-infra.yml`). Application CI (`ci-app.yml`) is included as part of the application templates.
