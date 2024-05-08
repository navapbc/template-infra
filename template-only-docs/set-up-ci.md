# Set up CI

## Static analysis checks

CI should automatically be set up once the CI files in `.github/workflows` are committed and pushed to the remote repository in GitHub.

### Instructions

Some checks are disabled until you've completed all set up steps:

1. Uncomment the infrastructure end-to-end tests by searching for `!!` in [`.github/workflows/ci-infra-service.yml`](/.github/workflows/ci-infra-service.yml). After uncommenting, verify that the CI is running and passing by clicking the Actions tab in GitHub.
    * Note that this repo only contains CI for the infrastracture. If you're using one of the [Platform application templates](https://github.com/navapbc/platform?tab=readme-ov-file#platform-templates), then the application CI workflow (`/.github/workflows/ci-app.yml`) is already included. Otherwise, you'll need to create one.
2. If you setup your AWS account in a region other than `us-east-1`, update the `aws-region` workflow settings in [`/.github/workflows/check-infra-auth.yml`](/.github/workflows/check-infra-auth.yml) to match your region.
