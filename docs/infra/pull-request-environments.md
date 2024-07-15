# Pull request environments

A temporary environment is created for each pull request that stays up while the pull request is open. The endpoint for the pull request and the deployed commit are added to the pull request description, and updated when the environment is updated. Use cases for the temporary pull request environment includes:

- Allow other delivery stakeholders—including product managers, designers, and business owners—to review changes before being merged and deployed
- Enable automated end-to-end tests on the pull request
- Enable automated accessibility checks on the pull request
- Facilitate workspace creation for developing and testing service layer infrastructure changes

## Lifecycle of pull request environments

A pull request environment is created when a pull request is opened or reopened, and destroyed when the pull request is merged or closed. When new commits are pushed up to the pull request, the pull request environment is updated.

## Isolate database migrations into separate pull requests

Database migrations are not reflected in PR environments. In particular, PR environments shares the same database with the dev environment, so database migrations that exist in the pull request are not run on the database to avoid impacting the dev environment.

Therefore, isolate database changes in their own pull request and merge that pull request first before opening pull requests with application changes that depend on those database changes. Note that it is still okay and encouraged to develop database and application changes together during local development.

This guidance is not strict. It is still okay to combine database migrations and application changes in a single pull request. However, when doing so, note that the PR environment may not be fully functional if the application changes rely on the database migrations.

## Implementing pull request environments for each application

Pull request environments are created by GitHub Actions workflows. There are two reusable callable workflows that manage pull request environments:

- [pr-environment-update.yml](/.github/workflows/pr-environment-update.yml) - creates or updates a temporary environment in a separate Terraform workspace for a given application and pull request
- [pr-environment-destroy.yml](/.github/workflows/pr-environment-destroy.yml) - destroys a temporary environment and workspace for a given application and pull request

Using these reusable workflows, configure PR environments for each application with application-specific workflows:

- `ci-[app_name]-pr-environment-update.yml`
  - Based on [ci-app-pr-environment-update.yml](https://github.com/navapbc/template-infra/blob/main/.github/workflows/ci-app-pr-environment-update.yml)
- `ci-[app_name]-pr-environment-destroy.yml`
  - Based on [ci-app-pr-environment-destroy.yml](https://github.com/navapbc/template-infra/blob/main/.github/workflows/ci-app-pr-environment-destroy.yml)
