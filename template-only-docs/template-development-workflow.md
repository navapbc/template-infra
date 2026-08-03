# Template development workflow

This is the workflow for developers making changes to the infrastructure template.

## Prerequisites

For most infrastructure changes, you will need an environment to work with.
Since template-infra is a template and not a live project, it doesn't have any
long-lived environments.

For Nava employees, generally this should be in
[platform-test](https://github.com/navapbc/platform-test). This is a test
project that uses [template-infra](https://github.com/navapbc/template-infra),
the [example
app](https://github.com/navapbc/template-infra/tree/main/template-only-app), and
instances of various other Strata application templates to provide a broad
integration test environment using the latest (unreleased) code from each. You
should develop and test your infrastructure changes using the `dev` environment
there.

For non-Nava employees, generally you'd be working on a project using the Strata
template, and so sharing your development and testing results from that project
usually suffices. If you'd like to contribute long term and/or larger changes
and don't have a suitable test environment, reach out via email to
<strata@navapbc.com> and we can figure something out.

## Developing infrastructure changes

This is the most common workflow:

### 1. Develop and test your changes on one of the platform-test repos

On the [platform-test](https://github.com/navapbc/platform-test) repo, you'll do the following:

1. Create a feature branch. The naming convention for feature branches is `<your name>/<feature name>`. You can optionally include the ticket number in `<feature name>`.
2. Create a terraform workspace that you will use for [developing and testing your infrastructure changes](/docs/infra/develop-and-test-infrastructure-in-isolation-using-workspaces.md). Using a workspace avoids conflicting with other developers and avoids CD overwriting any changes you've applied while developing.
3. Develop and test your infrastructure changes using the `dev` environment
4. Create a pull request
5. Iterate until all CI checks pass on your PR and you’ve also done additional testing that you need to validate. _Do not merge the PR._

### 2. Create a pull request on infra template repo

1. Once you've completed development and testing, create a pull request on the [template-infra](https://github.com/navapbc/template-infra) repo with the same changes you made on the platform test repo.
2. In the "Testing" section of the PR description, link to the PR on the platform test repo as evidence of the testing you did to verify your changes.
3. After the PR is approved and you merge the PR, the [template's CD workflow](/.github/workflows/template-only-cd.yml) will push the changes to the platform test repos.

### 3. Push changes to platform test repos

In most cases, after you merge changes to the infra template, the changes will be automatically pushed to the various platform test repos. However, some changes require manual intervention due to merge conflicts when the template deployment workflow attempts to apply the patch. In those cases you will need to manually make those changes on the `main` branch of the platform test repos.

### 4. Clean up: Close the pull request on the platform test repo

Now that the change has been merged to the template and propagated to the platform test repos, you can close the pull request that you created on the platform test repo as it is no longer needed. It is helpful to link to the pull request on the template repo in a comment.
