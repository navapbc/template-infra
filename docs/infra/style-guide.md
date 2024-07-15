# Style guide

## Table of contents

- [Style guide](#style-guide)
  - [Table of contents](#table-of-contents)
  - [Terraform code style](#terraform-code-style)
    - [Exceptions and additions to Hashicorp's Terraform style guide](#exceptions-and-additions-to-hashicorps-terraform-style-guide)
      - [Modules](#modules)
      - [Variables](#variables)
      - [.gitignore](#gitignore)
      - [Integration and unit testing](#integration-and-unit-testing)
      - [Policy](#policy)
  - [Shell script style](#shell-script-style)

## Terraform code style

Follow [Hashicorp's Terraform style guide](https://developer.hashicorp.com/terraform/language/style) when writing Terraform code, with a few exceptions (see below).

### Exceptions and additions to Hashicorp's Terraform style guide

Here are some exceptions (and additions) to Hashicorp's Terraform style guide.

#### Modules

- Use module names based on the logical function of the module rather than the underlying proprietary service used for implementing the module. For example, use "database" instead of "rds", or "storage" instead of "s3".
- Organize resources according to the infrastructure layers described in [module architecture](/docs/infra/module-architecture.md).
- [Use shared configuration](/docs/infra/module-dependencies.md) instead of the [tfe_outputs data source](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/data-sources/outputs) to share state between two state files.

#### Variables

- Include additional type information in string variable names to clarify the value being stored. For example, use `access_policy_arn` instead of `access_policy`. Common examples of suffixes include: `_id`, `_arn`, and `_name`.
- Include units in numerical variable names. For example, use `max_request_seconds` instead of `max_request_time`.
- Use plural nouns for lists. For example, use `subnet_ids` to represent a list of subnet ids.
- Use `values_by_key` for maps that map keys to values. For example use `account_ids_by_name` to represent a map from account names to account ids.
- For boolean feature flags, use the prefix `enable_`, as in `enable_https`.

#### .gitignore

- Do not commit the `.terraform.lock.hcl` dependency lock file. As of Feb 2023, Terraform lock files, while well intentioned, have a tendency to get into a confusing state that requires recreating the lock file, which defeats the purpose. Moreover, lock files are per environment, which can make it difficult for people to upgrade dependencies (e.g. upgrade an AWS provider) across environments if certain environments are locked down (e.g. production).

#### Integration and unit testing

- For testing, use [Terratest](https://terratest.gruntwork.io/docs/) instead of the [Terraform test framework](https://developer.hashicorp.com/terraform/language/tests).

#### Policy

- For policy enforcement and compliance checks, [Tfsec](https://github.com/aquasecurity/tfsec) is used instead of [Terraform's policy enforcement framework](https://developer.hashicorp.com/terraform/cloud-docs/policy-enforcement)

## Shell script style

Follow [Google's Shell Style Guide](https://google.github.io/styleguide/shellguide.html).
