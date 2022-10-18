# Terraform module architecture

This doc describes how Terraform modules are structured.

## Code structure

The infrastructure code is organized as follows. [Root modules](https://www.terraform.io/language/modules#the-root-module) are modules that are deployed separately from each other, whereas child modules are reusable modules that are called from root modules.

```text
infra/                  Infrastructure code
  accounts/             Account root modules for IaC and IAM resources
  app/                  Application-specific infrastructure
    build-repository/   Root module for resources storing built release candidates used for deploys
    env-template        Child module defining resources needed to run the application
    envs/               Root modules for each environment
      dev/              Dev environment root module
      staging/          Staging environment root module
      prod/             Prod environment root module
  modules/              Reusable child modules
```

## Module calling structure

The following diagram describes the relationship between modules and their child modules. Arrows go from the caller module to the child module.

Note that `static-app` does not currently exist, but is provided as an example of what the module architecture would look like if additional applications were added to the project repo.

```mermaid
flowchart TB

  subgraph accounts
    account
  end

  subgraph app
    app/build-repository[build-repository]
    app/env-template[env-template]

    subgraph app/envs[envs]
      app/envs/dev[dev]
      app/envs/prod[prod]
    end

    app/envs/dev --> app/env-template
    app/envs/prod --> app/env-template
  end

  subgraph static-app
    static-app/build-repository[build-repository]
    static-app/env-template[env-template]

    subgraph static-app/envs[envs]
      static-app/envs/dev[dev]
      static-app/envs/prod[prod]
    end

    static-app/envs/dev --> static-app/env-template
    static-app/envs/prod --> static-app/env-template
  end

  subgraph modules
    modules/terraform-backend-s3
    auth-github-actions
    container-image-repository
    web-app
    database
    static-bundle-repository
    modules/static-app[static-app]
  end

  account --> modules/terraform-backend-s3
  account --> auth-github-actions
  app/build-repository --> container-image-repository
  app/env-template --> web-app
  app/env-template --> database
  static-app/build-repository --> static-bundle-repository
  static-app/env-template --> modules/static-app
```

## Module dependencies

The following diagram illustrates the dependency structure of the root modules.

1. Account root modules need to be deployed first to create the S3 bucket and DynamoDB tables needed to configure the Terraform backends in the rest of the root modules.
2. The application's build repository needs to be deployed next to create the resources needed to store the built release candidates that are deployed to the application environments.
3. The individual application environment root modules are deployed last once everything else is set up. These root modules are the ones that are deployed regularly as part of application deployments.

```mermaid
flowchart RL

app/envs/* --> app/build-repository --> accounts/*
app/envs/* --> accounts/*
```
