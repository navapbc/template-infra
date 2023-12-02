# Design of network layer

* Deciders: TBD
* Date: 2023-12-01

## Context and Problem Statement

Most projects will need to deploy their applications into custom VPCs. The policies around VPCs can vary. For example, some projects might require each application environment to be in its own VPC, while other projects might have all lower environments share a VPC. Some projects might have all resources live in one AWS account, while others might isolate resources into separate accounts. Some projects might have permission to create and configure the VPCs (according to agency security policies), while other projects might have the VPC created by the agency's shared infrastructure team before it's provided to the project team to use. This technical specification proposes a design of the network layer that accommodates these various configurations in a simple modular manner.

## Requirements

1. The project team can create any number of networks, or VPCs, independently of the number of AWS accounts or the number of applications or application environments.
2. Created VPCs can be mapped arbitrarily to AWS accounts. They can all be created in a single AWS account or separated across multiple AWS accounts.
3. An application environment can map to any of the created VPCs, or to a VPC that is created outside of the project.

We aim to achieve these requirements without adding complexity to the other layers. The network layer should be decoupled from the other layers.

## Approach

Define and configure networks in [project-config module](/infra/project-config/main.tf).

```terraform
network_configs = {
  network_1 = { ... }
  network_2 = { ... }
  ...
}
```

Each network config will have the following properties:

* **account_name** — Name of AWS account that the VPC should be created in. Used to document which AWS account the network lives in and to determine which AWS account to authenticate into when making modifications to the network in scripts such as CI/CD 
* ... TODO work with @shawnvanderjagt on this section

### Add network_name tag to VPC

Add a "network_name" name tag to the VPC. The value of the tag is the key in `network_configs`. The VPC tag will be used by the service layer to identify the VPC in an [aws_vpc data source](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc). Tags are used because at this time AWS VPCs do not have any user-provided identifiers such as a VPC name. Generated identifiers like `vpc_id` cannot be used because `vpc_id` is not known statically at configuration time, and we are following the pattern of [using configuration and data sources to manage dependencies between different infrastructure layers](/docs/infra/module-dependencies.md#use-config-modules-and-data-resources-to-manage-dependencies-between-root-modules).

## Service layer changes

Currently [the service layer](/infra/app/service/main.tf) references the default VPC in the AWS account. In order to determine which VPC to use, we will add a `networks_by_environment` property to [app-config](/infra/app/app-config/) that maps application environments to networks, similar to how the `accounts_names_by_environment` property maps application environments to AWS accounts.

We can then update the `aws_vpc` data source to reference the appropriate network as such:

```terraform
data "aws_vpc" "network" {
  id = local.environment_config
}
```


### Example: Project with a multi-account setup

```terraform
# project-config
network_configs = {
  dev = {
    account_name = "dev"
  }
  staging = {
    account_name = "staging"
  }
  prod = {
    account_name = "prod"
  }
}

# app-config
networks_by_environment = {
  dev = "dev"
  staging = "staging"
  prod = "prod"
}
```

### Example: Project with a single account, and a shared VPC "lowers" for lower environments

```terraform
# project-config
network_configs = {
  lowers = {
    account_name = "shared"
  }
  prod = {
    account_name = "shared"
  }
}

# app-config
networks_by_environment = {
  dev = "lowers"
  staging = "lowers"
  prod = "prod"
}
```

Each network will have three subnets:

* public subnet
* private subnet for the application layer
* private subnet for the data layer

## Decision Outcome

Chosen option: "[option 1]", because [justification. e.g., only option, which meets k.o. criterion decision driver | which resolves force force | … | comes out best (see below)].

### Positive Consequences <!-- optional -->

* [e.g., improvement of quality attribute satisfaction, follow-up decisions required, …]
* …

### Negative Consequences <!-- optional -->

* [e.g., compromising quality attribute, follow-up decisions required, …]
* …

## Pros and Cons of the Options <!-- optional -->

### [option 1]

[example | description | pointer to more information | …] <!-- optional -->

* Good, because [argument a]
* Good, because [argument b]
* Bad, because [argument c]
* … <!-- numbers of pros and cons can vary -->

### [option 2]

[example | description | pointer to more information | …] <!-- optional -->

* Good, because [argument a]
* Good, because [argument b]
* Bad, because [argument c]
* … <!-- numbers of pros and cons can vary -->

### [option 3]

[example | description | pointer to more information | …] <!-- optional -->

* Good, because [argument a]
* Good, because [argument b]
* Bad, because [argument c]
* … <!-- numbers of pros and cons can vary -->

## Links <!-- optional -->

* [Link type] [Link to ADR] <!-- example: Refined by [ADR-0005](0005-example.md) -->
* … <!-- numbers of links can vary -->
