# Contributing to the infrastructure template

## Getting started

If you are looking to contribute, get started by reading the following docs.

- Read about the [infrastructure's module architecture](/docs/infra/module-architecture.md) to learn how the architecture of the infrastructure code is designed and how the modules interact with each other.
- Read the [template development workflow](/template-only-docs/template-development-workflow.md) to understand how to develop and test changes to the template because working on the platform templates is unlike working on most other applications.
- Read the [infrastructure style guide](/docs/infra/style-guide.md) to understand best practices for Terraform and shell scripts.

## Pay attention to testing and rollout process when reviewing PRs

When reviewing template PRs, in addition to the usual things you look for, pay particular attention to:

### Manual testing

Unlike application development, the automated test suite for infrastructure has much less coverage, so it is more important than usual to review test plans and evidence of successful testing to demonstrate that things work. Ask yourself the following questions:
What evidence would I need to see to be confident that things are working as intended?
In what ways could things be working differently as intended under the hood but still look the same based on the evidence provided?

### Rollout process

Sometimes template changes do not propagate cleanly to the platform test repos. See Platform test repo(s) do not have the latest changes from template-infra.

Also, unlike application changes, infrastructure changes aren't always automatically applied. Make sure to think about how the changes will be applied before merging and make sure the changes get applied after merge. Double check by making sure the latest deploys (including in platform-test-nextjs and platform-test-flask test repos) completed successfully and that the terraform plans on main show no configuration changes.

```bash
platform-test$ git pull
platform-test$ make infra-update-app-database APP_NAME=app ENVIRONMENT=dev # should show no configuration changes
platform-test$ make infra-update-app-service APP_NAME=app ENVIRONMENT=dev # should show no configuration changes
```

## Make note of breaking changes

If your PR will introduce a breaking change, then after the PR is approved, but before you merge it into main:

1. Prefix the commit title with ⚠️. This indicates to the Platform Admins who will make the next release that there is a breaking change included in the release.
2. Add a section in the commit description for "Release notes" and indicate what needs to be included in the release notes on how to handle the breaking change.

## Troubleshooting

See the [troubleshooting guide](/template-only-docs/troubleshooting.md) for common issues and how to resolve them.
