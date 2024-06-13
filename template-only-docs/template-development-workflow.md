# Template development workflow

This is the workflow for developers making changes to the infrastructure template.

## Prerequisites

For most infrastructure changes, you will need an environment to work with. Since template-infra is a template and not a live project, it doesn't have any long-lived environments. Thus, you should develop and test your infrastructure changes using the `dev` environment on one of the following test repos:

* [platform-test](https://github.com/navapbc/platform-test) – Test project that uses [template-infra](https://github.com/navapbc/template-infra) and the [example app](https://github.com/navapbc/template-infra/tree/main/app) that comes with the template. This is the default project we use for development and testing infrastructure changes.
* [platform-test-flask](https://github.com/navapbc/platform-test-flask) - Test project that uses [template-infra](https://github.com/navapbc/template-infra) and [template-application-flask](https://github.com/navapbc/template-application-flask)
* [platform-test-nextjs](https://github.com/navapbc/platform-test-nextjs) - Test project that uses [template-infra](https://github.com/navapbc/template-infra) and [template-application-nextjs](https://github.com/navapbc/template-application-nextjs)

If you need an AWS IAM user for the AWS account associated with any of the platform test repos, contact @lorenyu.

## Developing infrastructure changes

This is the most common workflow:

### 1. Develop and test your changes on one of the platform-test repos

On the [platform-test](https://github.com/navapbc/platform-test) repo, you'll do the following:

1. Create a feature branch. The naming convention for feature branches is `<your name>/<feature name>`. You can optionally include the ticket number in `<feature name>`.
2. Create a terraform [workspace](/docs/infra/intro-to-terraform-workspaces.md) that you will use for developing and testing your infrastructure changes. Using a workspace avoids conflicting with other developers and avoids CD overwriting any changes you've applied while developing:

   ```zsh
   terraform workspace new <workspace name>
   ```

3. Develop and test your infrastructure changes using the `dev` environment
4. Create a pull request
5. Iterate until all CI checks pass on your PR and you’ve also done additional testing that you need to validate. *Do not merge the PR.*

### 2. Create a pull request on infra template repo

1. Once you've completed development and testing, create a pull request on the [template-infra](https://github.com/navapbc/template-infra) repo with the same changes you made on the platform test repo.
2. In the "Testing" section of the PR description, link to the PR on the platform test repo as evidence of the testing you did to verify your changes.
3. After the PR is approved and you merge the PR, the [template's CD workflow](/.github/workflows/template-only-cd.yml) will push the changes to the platform test repos.

### 3. Push changes to platform test repos

In most cases, after you merge changes to the infra template, the changes will be automatically pushed to the various platform test repos. However, the following changes aren't automatically propagated to the platform test repos:

1. Changes to [this list of files in update-template.sh](https://github.com/navapbc/template-infra/blob/main/template-only-bin/update-template.sh#L17-L28)
2. Deletions of template files

For those changes, you will need to manually make those changes on the `main` branch of the platform test repos.

### 4. Clean up: Close the pull request on the platform test repo

Now that the change has been merged to the template and propogated to the platform test repos, you can close the pull request that you created on the platform test repo as it is no longer needed. It is helpful to link to the pull request on the template repo in a comment.
