# Feature flags system design

* Deciders: @aligg @Nava-JoshLong @lorenyu
* Date: 2023-11-28

## Context

All projects should have some sort of feature flag mechanism for controlling the release and activation of features. This accelerates product development by unblocking developers from being able to deploy continuously while still providing business owners with control over when features are visible to end users. More advanced feature flag systems can also provide the ability to do gradual rollouts to increasing percentages of end users and to do split tests (also known as A/B tests) to evaluate the impact of different feature variations on user behavior and outcomes, which provide greater flexibility on how to reduce the risk of launching features.

## Requirements

1. The project team can define feature flags, or feature toggles, that enable/disable a set of functionality in an environment, depending on whether the flag is enabled or disabled.
2. The feature flagging system should support gradual rollouts, the ability to roll out a feature incrementally to a percentage of users.
3. Separate feature flag configuration from implementation of the feature flags, so that feature flags can be changed frequently through configuration without touching the underlying feature flag infrastructure code.

## Approach

This tech spec explores the use of [AWS CloudWatch Evidently](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch-Evidently.html), a service that provides functionality for feature flags, gradual rollouts, and conducting split testing (A/B testing) experiments.

## Feature management

One key design question is how features should be managed once defined. How should a team go about enabling and disabling the feature flags and adjusting the percentage of traffic to send to a new feature during a feature launch?

### Option 1. Manage features using app-config module as part of service layer

Define features in [app-config](/infra/app/app-config/), and use that configuration in the [service layer](/infra/app/service/) to create and configure the features in AWS Evidently.

* Everything is defined in code and in one place.
* Feature and feature configurations are updated automatically as part of service deploys or can be done manually via a terraform apply.

The configuration in the app-config module might look something like the following:

```terraform
features = {
  some_disabled_feature = {}

  some_enabled_feature = {
    enabled_variation = 1
  }

  simple_ab_test = {
    throttle_percentages = [0.5]
  }

  test_with_multiple_variations = {
    throttle_percentages = [0.33, 0.33, 0.33]
  }
}
```

### Option 2. Manage features using app-config as part of a separate infrastructure layer

Define features in [app-config](/infra/app/app-config/main.tf). Create the features in the [service layer](/infra/app/service/) but set things like throttle percentages (for gradual rollouts) in a separate infrastructure layer.

* Allows for separation of permissions. For example, individuals can have permission to update feature launch throttle percentages without having permission to create, edit, or delete the features themselves.

### Option 3. Manage features in AWS Console outside of terraform

Define features in [app-config](/infra/app/app-config/main.tf) and create them in the [service layer](/infra/app/service), but set things like throttle percentages (for gradual rollouts) outside of terraform (e.g. via AWS Console). Use `lifecycle { ignore_changes = [entity_overrides] }` in the terraform configuration for the `aws_evidently_feature` resources to ignore settings that are managed via AWS Console.

* Empowers non-technical roles like business owners and product managers to set enable and disable feature flags and adjust feature launch throttle percentages without needing to depend on the development team.
* A no-code approach using the AWS Console GUI means that it's possible to leverage the full set of functionality offered by AWS CloudWatch Evidently, including things like scheduled launches, with minimal training and without needing to learn how to do it in code.

A reduced configuration in the app-config module that just defines the features might look something like the following:

```terraform
feature_flags = [
  "some_new_feature_1", "some_new_feature_2"
]

experiments = [
  {
    name = "ab_test"
    treatments = ["red-button"]
  },
  {
    name = "test_with_multiple_variations"
    treatments = ["red-button", "green-button", "blue-button"] 
  }
]
```

## Decision Outcome

Chosen option: "Option 3: Manage features in AWS Console outside of terraform". The ability to empower business and product roles to control launches and experiiments without depending on engineering team maximizes autonomy and allows for the fastest delivery.
