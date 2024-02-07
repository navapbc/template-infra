# Environment variables and secrets

Many applications require custom environment variables for application configuration and for access to secrets. This document describes how to configure application-specific environment variables and secrets. It also describes how to override those environment variables for a specific environment.

## Application-specific extra environment variables

Application-specific environment variables are defined in the [environment-variables.tf](/infra/app/app-config/env-config/environment-variables.tf) file in the app-config module in a variable called `default_extra_environment_variables`. This is a map from environment variable names to the default values for those environment variables across environments.

If you want to override the default values for a particular environment, you pass a `service_override_extra_environment_variables` variable to the [env-config module](/infra/app/app-config/env-config/variables.tf) in your `app-config/[environment].tf` file.

## Secrets

Secrets are defined in in the [environment-variables.tf](/infra/app/app-config/env-config/environment-variables.tf) file in the app-config module in a variable called `secrets`. Each secret configuration defines the environment variable name and the SSM parameter name for the secret. The SSM parameter name can include the environment, which is a way you can have different secrets for different environments.
