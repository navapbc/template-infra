# Set up CI

## Static analysis checks

CI should automatically be set up once the CI files in `.github/workflows` are committed and pushed to the remote repository in GitHub.

You can verify that CI is running and passing by clicking into the Actions tab in GitHub.

Note that this repo only contains CI for infra (`ci-infra.yml`). Application CI is included as part of the application templates.

## Unit tests

Currently, we do not use any infrastructure unit or integration testing tools like terratest and kitchen terraform as mentioned in [Terraform: Module Testing Experiments](https://www.terraform.io/language/modules/testing-experiment).
