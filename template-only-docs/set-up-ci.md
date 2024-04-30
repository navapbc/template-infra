# Set up CI

## Static analysis checks

CI should automatically be set up once the CI files in `.github/workflows` are committed and pushed to the remote repository in GitHub.

Some checks are disabled until you've completed certain setup steps:

### After completing infra setup

After completing the [infra setup](/infra/README.md#instructions):

* Uncomment the infra end-to-end tests by searching for `!!` in [ci-infra-service.yml](/.github/workflows/ci-infra-service.yml). You can verify that CI is running and passing by clicking into the Actions tab in GitHub.
    * Note that this repo only contains CI for infra. If you're using one of the [Platform application templates](https://github.com/navapbc/platform?tab=readme-ov-file#platform-templates), then the application CI (`/.github/workflows/ci-app.yml`) is already included. Otherwise, you'll need to create one.
* If you setup your AWS account in a different region than `us-east-1`, update the `aws-region` workflow settings in [`/.github/workflows/check-infra-auth.yml`](/.github/workflows/check-infra-auth.yml) to match your region.
