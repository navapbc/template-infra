# Understanding the infra setup

The infrastructure code is modularized and a bit abstracted for greater re-use.
It can be overwhelming at first to fit how it's all connected in your head. This
doc hopes to help with that.

If you want deeper background rational for the current setup:

- /docs/decisions/infra/2023-09-07-consolidate-infra-config-from-tfvars-files-into-config-module.md
- /docs/decisions/infra/2023-05-09-separate-terraform-backend-configs-into-separate-config-files.md

TL;DR: reduce code duplication and drift between environments, helps streamline receiving updates from upstream

Broken down into three broad layers.

![Vizualization of infra code layers](https://lucid.app/publicSegments/view/29e0e079-df0c-43fd-8449-b85b53592bc2/image.png)

## Account Layer

After initial set up, you'll likely rarely need to deal with this.

infra/accounts/

make infra-set-up-account
make infra-update[-current]-account

/docs/infra/set-up-aws-account.md

## Network Layer

After initial set up, you'll less frequently need to deal with this, only when
there are network/cross-application resource changes.

infra/networks/

/docs/infra/set-up-network.md

make infra-(configure, update)-network
make infra-configure-network
make infra-update-network

## App Layer

infra/<APP_NAME>/

infra-update-app-build-repository
infra-update-app-database-roles
infra-update-app-database
infra-update-app-service

infra-configure-app-build-repository
infra-configure-app-database
infra-configure-app-service

infra-configure-monitoring-secrets ?

This is where you'll spend most of your time as a developer.

This layer itself is composed of multiple root modules for different "sub-layers".

- `service` for the application code, storage, monitoring, etc. **This is likely
  where you'll be doing the most work.**
- `database` for the application's database
- `build-repository` for AWS, holds resources for the container build of the
  application code. After initial setup, you probably won't deal with this.


/infra/README.md
/docs/infra/module-architecture.md
/docs/infra/module-dependencies.md
