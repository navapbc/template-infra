# Set up CI

## Static analysis checks

CI should automatically be set up once the CI files in `.github/workflows` are committed and pushed to the remote repository in GitHub.

Some checks are disabled until you've completed the [project setup step](./set-up-infrastructure-as-code.md). Look for `!!` in the [Makefile](../Makefile) and uncomment the checks assuming you've completed the project setup step.

You can verify that CI is running and passing by clicking into the Actions tab in GitHub.

Note that this repo only contains CI for infra (`ci-infra.yml`). Application CI is included as part of the application templates.
