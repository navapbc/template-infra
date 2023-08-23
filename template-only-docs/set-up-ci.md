# Set up CI

## Static analysis checks

CI should automatically be set up once the CI files in `.github/workflows` are committed and pushed to the remote repository in GitHub.

Some checks are disabled until you've completed certain setup steps:

### After setting up the application environment

After [setting up the app environment](/docs/infra/set-up-app-env.md):

- Uncomment the infra end-to-end tests in [ci-infra.yml](/.github/workflows/ci-infra.yml). You can verify that CI is running and passing by clicking into the Actions tab in GitHub. Note that this repo only contains CI for infra (`ci-infra.yml`). Application CI (`ci-app.yml`) is included as part of the application templates.
- Uncomment the push trigger in [cd.yml](/.github/workflows/cd.yml)
- If you setup your AWS account in a different region than `us-east-1`, update the `aws-region` workflow settings to match your region.
