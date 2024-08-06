# Set up PR environments

[Pull request environments](/docs/infra/pull-request-environments.md) are temporary environments that exist during a pull request. Enable them after [setting up the app environment](/docs/infra/set-up-app-env.md):

- In [ci-app-pr-environment-checks.yml](/.github/workflows/ci-app-pr-environment-checks.yml) and [ci-app-pr-environment-destroy.yml](/.github/workflows/ci-app-pr-environment-destroy.yml), search for `!!`.
- Uncomment the PR environment triggers. 

You can verify that PR environments are working by opening a new PR and waiting for the "PR Environment Update" job to finish.
