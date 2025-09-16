# Template development workflow

This is the workflow for developers making changes to the infrastructure template.

## Prerequisites

For most infrastructure changes, you will need an environment to work with. Since template-infra is a template and not a live project, it doesn't have any long-lived environments. Thus, you should develop and test your infrastructure changes using the `dev` environment on one of the following test repos:

- [platform-test](https://github.com/navapbc/platform-test) – Test project that uses [template-infra](https://github.com/navapbc/template-infra) and the [example app](https://github.com/navapbc/template-infra/tree/main/template-only-app) that comes with the template. This is the default project we use for development and testing infrastructure changes.
- [platform-test-flask](https://github.com/navapbc/platform-test-flask) - Test project that uses [template-infra](https://github.com/navapbc/template-infra) and [template-application-flask](https://github.com/navapbc/template-application-flask)
- [platform-test-nextjs](https://github.com/navapbc/platform-test-nextjs) - Test project that uses [template-infra](https://github.com/navapbc/template-infra) and [template-application-nextjs](https://github.com/navapbc/template-application-nextjs)

If you need an AWS IAM user for the AWS account associated with any of the platform test repos, contact @lorenyu.

## Planning infrastructure changes

### Isolate PRs to a single infrastructure layer and make each individual PR backwards compatible

Each PR should only touch one of [the infrastructure layers](/infra/README.md#infrastructure-layers) at a time.

**If you need to make a change that affects multiple layers, break it down into multiple steps so that each step can be done in a backwards compatible manner that affects one layer at a time.**

For example, if you want to change the name of the ECR image repository, you should break the change down into the following steps involving three PRs.

1. Create PR #1 that adds a new image repository with a new name (This PR only modifies the build repository layer).
2. After merging the PR #1, manually apply the changes to the platform test repos (platform-test, platform-test-nextjs, platform-test-flask) since changes to the build-repository layer aren't automatically applied as part of the CD workflow.
3. Create PR #2 that updates the publish-release.sh script to use the new image repository and modifies the task definition to pull from the new image repository (This PR only modifies the service layer). After merging PR #2, deploys should automatically be publishing builds to the new build repository and the service tasks should be using images from the new build repository
4. Create PR #3 that removes the old build repository(This PR only modifies the build repository layer)
When creating a release that includes a breaking change such as this one, include migration instructions on how to apply the changes without incurring downtime. In this example, the migration notes will look something like:

   Step 1: Do a targeted apply to create the new build repository
   Step 2: Commit and apply the changes to the service layer
   Step 3: Apply the rest of the changes to the build repository layer to remove the old build repository

## Developing and testing infrastructure changes

This is the most common workflow:

### 1. Develop and test your changes on one of the platform-test repos

On the [platform-test](https://github.com/navapbc/platform-test) repo, you'll do the following:

1. Create a feature branch. The naming convention for feature branches is `<your name>/<feature name>`. You can optionally include the ticket number in `<feature name>`.
2. Create a terraform workspace that you will use for [developing and testing your infrastructure changes](/docs/infra/develop-and-test-infrastructure-in-isolation-using-workspaces.md). Using a workspace avoids conflicting with other developers and avoids CD overwriting any changes you've applied while developing.
3. Develop and test your infrastructure changes using the `dev` environment
4. Create a pull request
5. Iterate until all CI checks pass on your PR and you've also done additional testing that you need to validate. _Do not merge the PR._

### 2. Create a pull request on infra template repo

1. Once you've completed development and testing, create a pull request on the [template-infra](https://github.com/navapbc/template-infra) repo with the same changes you made on the platform test repo.
2. In the "Testing" section of the PR description, link to the PR on the platform test repo as evidence of the testing you did to verify your changes.
3. After the PR is approved and you merge the PR, the [template's CD workflow](/.github/workflows/template-only-cd.yml) will push the changes to the platform test repos.

### 3. Push changes to platform test repos

In most cases, after you merge changes to the infra template, the changes will be automatically pushed to the various platform test repos. However, some changes require manual intervention due to merge conflicts when the template deployment workflow attempts to apply the patch. In those cases you will need to manually make those changes on the `main` branch of the platform test repos.

### 4. Clean up: Close the pull request on the platform test repo

Now that the change has been merged to the template and propagated to the platform test repos, you can close the pull request that you created on the platform test repo as it is no longer needed. It is helpful to link to the pull request on the template repo in a comment.
