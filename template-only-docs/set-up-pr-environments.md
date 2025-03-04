# Set up PR environments

[Pull request environments](/docs/infra/pull-request-environments.md) are temporary environments that exist during a pull request. Enable them after [setting up the app environment](/docs/infra/set-up-app-env.md):

- In [ci-{{app_name}}-pr-environment-checks.yml](/.github/workflows/ci-{{app_name}}-pr-environment-checks.yml.jinja) and [ci-{{app_name}}-pr-environment-destroy.yml](/.github/workflows/ci-{{app_name}}-pr-environment-destroy.yml.jinja), search for `!!`.
- Uncomment the PR environment triggers for spot testing. Run `nava-platform infra update --answers-only --data app_has_dev_env_setup=true .` to consistently enable things.

You can verify that PR environments are working by opening a new PR and waiting for the "PR Environment Update" job to finish.
