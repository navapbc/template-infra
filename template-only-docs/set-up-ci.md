# Set up CI

## Static analysis checks

CI should automatically be set up once the CI files in `.github/workflows` are committed and pushed to the remote repository in GitHub.

Some checks are disabled until you've completed certain setup steps:

### After setting up the application environment

After [setting up the app environment](/docs/infra/getting-started/set-up-app-env.md), run:

```sh
nava-platform infra update --answers-only --data app_has_dev_env_setup=true .
```

If you setup your AWS account in a different region than `us-east-1`, update the `aws-region` workflow settings to match your region.
