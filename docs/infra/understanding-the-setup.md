# Understanding the infra setup

The infrastructure code is modularized and a bit abstracted for greater re-use.
It can be overwhelming at first to fit how it's all connected in your head. The
[/infra/README.md](/infra/README.md) doc has a lot of good overview info. This
doc aims to provide a little better connective tissue between the architectural
concepts and the concrete things you'll interact with.

If you want deeper background rational for the current setup:

- [/docs/decisions/infra/2023-05-09-separate-terraform-backend-configs-into-separate-config-files.md](/docs/decisions/infra/2023-05-09-separate-terraform-backend-configs-into-separate-config-files.md)
- [/docs/decisions/infra/2023-09-07-consolidate-infra-config-from-tfvars-files-into-config-module.md](/docs/decisions/infra/2023-09-07-consolidate-infra-config-from-tfvars-files-into-config-module.md)
- [/docs/decisions/infra/2023-09-11-separate-app-infrastructure-into-layers.md](/docs/decisions/infra/2023-09-11-separate-app-infrastructure-into-layers.md)

TL;DR for the why: group resources with a similar lifecycle and scope, reduce
code duplication and drift between environments, help streamline receiving
updates from upstream

It's important to understand most of the actual resource code [lives in
re-usable modules under `/infra/modules/`](/docs/infra/module-architecture.md).
Everything else largely exists to call that re-usable code with the correct
parameters at the correct time, [in a well structured
way](/docs/infra/module-dependencies.md). That "everything else" can be broken
down into three high-level "slices" (some with further internal divisions).

One last bit of exposition, as yet more new terminology has been introduced with
"slice". If you've read other documentation already you'll have likely seen
references to infrastructure "layers", but there are some conceptual
psuedo-layers that for clarity that this document calls a "slice". Some slices
directly correspond to a layer, other slices correspond to multiple layers. In
summary:

- Slice: Conceptual or organizational grouping, it does not directly correspond
  to infrastructure resources itself, though may be expressed in the file
  structure.
- Layer: Corresponds to root modules and actual resources.

![Visualization of infra code
layers](https://lucid.app/publicSegments/view/623affad-8b51-4482-86e2-f1a3ad1bd623/image.png)

([visualization source](https://lucid.app/lucidchart/19108167-39ee-48fb-b9ac-85465ce4403a/edit), note there are multiple image layers that can be toggled)

Specifics are shown in the above visualization and will be given in the sections
to follow, but _in general_ there are make targets to interact with different
bits of this, following the pattern of:

```
make infra-<action>-<layer>
```

## Account Layer/Slice

After initial set up of an account, you'll likely rarely need to deal with this.

The layer's source code is under `/infra/accounts/`. And primary config at
`/infra/project-config/main.tf`.

For each account in your project, there will be an `<account name>.<account
id>.<terraform backend type>.tfbackend` file under `/infra/accounts/`.

Common make targets to interact with it:

- `make infra-set-up-account ACCOUNT_NAME=<ACCOUNT_NAME>`
- `make infra-update[-current]-account [ACCOUNT_NAME=<ACCOUNT_NAME>]`

Set up docs:
[/docs/infra/set-up-aws-account.md](/docs/infra/set-up-aws-account.md)

## Network Layer/Slice

After initial set up, you'll less frequently need to deal with this, only when
there are network/cross-application resource changes.

The layer's source code is under `/infra/networks/`. And primary config at
`/infra/project-config/networks.tf`.

For each network in your project, there will be an `<network name>.<terraform
backend type>.tfbackend` file under `/infra/networks/`.

Common make targets to interact with it:

- `make infra-configure-network NETWORK_NAME=<NETWORK_NAME>`
- `make infra-update-network NETWORK_NAME=<NETWORK_NAME>`

Set up docs: [/docs/infra/set-up-network.md](/docs/infra/set-up-network.md)

## App Slice

*This is where you'll spend most of your time as a developer.*

This slice is composed of a layer, a build repository, and another slice, the
application environment.

- `build-repository` layer for AWS, holds resources for the container build of
  the application code. After initial setup, you probably won't deal with this.
- Application Environments

Of these, `build-repository` is they only one that exists at the bare app slice,
the others exist in an environment, discussed next. This is because the
applications build repo is shared across all environments and accounts that run
the application.

The slice's "source code" is under `/infra/<APP_NAME>/`. And primary config at
`/infra/<APP_NAME>/app-config/main.tf`.

### Build repository layer

The layer's source code is under `/infra/<APP_NAME>/build-repository/`. And
primary config at `/infra/<APP_NAME>/app-config/build_repository.tf`.

Common make targets to interact with it:

- `infra-configure-app-build-repository APP_NAME=<APP_NAME>`
- `infra-update-app-build-repository APP_NAME=<APP_NAME>`

Set up docs: [/docs/infra/set-up-build-repository.md](/docs/infra/set-up-build-repository.md)

Note, this layer does not exist in the Azure template.

### Environment Slice

The environment slice encompasses a couple layers:

- `service` for the application code, storage, monitoring, etc. **This is likely
  where you'll be doing the most work.**
- `database` for the application's database

The slice's "source code" is under `/infra/<APP_NAME>/(service,database)/`. And
primary config at `/infra/<APP_NAME>/app-config/<ENV_NAME>.tf`.

#### Service layer

The layer's source code is under `/infra/<APP_NAME>/service/`. And primary config
at `/infra/<APP_NAME>/app-config/env-config/*.tf`.

For each environment for the app, there will be an `<ENV_NAME>.<terraform
backend type>.tfbackend` file under `/infra/<APP_NAME>/service/`.

Common make targets to interact with it:

- `infra-configure-app-service APP_NAME=<APP_NAME> ENVIRONMENT=<ENV_NAME>`
- `infra-update-app-service APP_NAME=<APP_NAME> ENVIRONMENT=<ENV_NAME>`

Set up docs: [/docs/infra/set-up-app-env.md](/docs/infra/set-up-app-env.md)

#### Database layer

The layer's source code is under `/infra/<APP_NAME>/database/`. And primary
config at `/infra/<APP_NAME>/app-config/env-config/database.tf`.

The resources in this layer may or may not exist for a given app, generally
controlled by the `has_database` setting in the app slice or app environment
slice config.

For each environment for the app (that has a database), there will be an
`<ENV_NAME>.<terraform backend type>.tfbackend` file under
`/infra/<APP_NAME>/database/`.

Common make targets to interact with it:

- `infra-configure-app-database APP_NAME=<APP_NAME> ENVIRONMENT=<ENV_NAME>`
- `infra-update-app-database APP_NAME=<APP_NAME> ENVIRONMENT=<ENV_NAME>`
- `infra-update-app-database-roles APP_NAME=<APP_NAME> ENVIRONMENT=<ENV_NAME>`
- `infra-check-app-database-roles APP_NAME=<APP_NAME> ENVIRONMENT=<ENV_NAME>`

Set up docs: [/docs/infra/set-up-database.md](/docs/infra/set-up-database.md)
