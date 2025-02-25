# Feature flags and partial releases

Feature flags are an important tool that enables [trunk-based development](https://trunkbaseddevelopment.com/). They allow in-progress features to be merged into the main branch while still allowing that branch to be deployed to production at any time, thus decoupling application deploys from feature releases. For a deeper introduction, [Martin Fowler's article on Feature Toggles](https://martinfowler.com/articles/feature-toggles.html) and [LaunchDarkly's blog post on feature flags](https://launchdarkly.com/blog/what-are-feature-flags/) are both great articles that explain the what and why of feature flags.

## How it works

This project stores feature flags in AWS Parameter Store and injects them into the application as environment variables. See the [feature_flags module](/infra/modules/feature_flags/).

## Creating feature flags

The list of feature flags for an application is defined in the `feature_flags` property in its app-config module (in `/infra/<APP_NAME>/app-config/feature_flags.tf`). The set of feature flags will be updated on the next `terraform apply` of the service layer, or during the next deploy of the application.

## Querying feature flags in the application

To determine whether a particular feature should be enabled or disabled for a given user, check for an environment variable `FF_<FEATURE_FLAG_NAME>`. If the feature flag is enabled the environment variable will be set to the string `"true"`, otherwise it will be set to the string `"false"`.
