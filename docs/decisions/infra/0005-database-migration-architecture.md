# Database Migration Infrastructure and Deployment

* Status: proposed
* Deciders: [list everyone involved in the decision] <!-- optional -->
* Date: [YYYY-MM-DD when the decision was last updated] <!-- optional -->

## Context and Problem Statement

What is the most optimal setup for database migrations infrastructure and deployment?
This will break down the different options for how the migration is ran, but not the
tools or languages the migration will be ran with, that will be dependent on the framework
the application is using.

<!-- Might remove this part since part is in this ADR, part is in app specific -->
Questions that need to be addressed:
 1. How will the method get the latest migration code to run?
 2. What infrastructure is required to use this method?
 3. How is the migration deployment triggered?

Questions that will be addressed in application repos:
 1. How to implement rollbacks?
<!-- to here -->

## Decision Drivers <!-- optional -->

* [driver 1, e.g., a force, facing concern, …]
* [driver 2, e.g., a force, facing concern, …]
* … <!-- numbers of drivers can vary -->

## Considered Options

* Ran Directly via GitHub Workflow
* Ran via a Lambda Function
* Ran via an ECS Task

## Decision Outcome

Chosen option: "[option 1]", because [justification. e.g., only option, which meets k.o. criterion decision driver | which resolves force force | … | comes out best (see below)].

### Positive Consequences <!-- optional -->

* [e.g., improvement of quality attribute satisfaction, follow-up decisions required, …]
* …

### Negative Consequences <!-- optional -->

* [e.g., compromising quality attribute, follow-up decisions required, …]
* …

## Pros and Cons of the Options <!-- optional -->

### Ran Directly via GitHub Workflow

In this method, the database migration would be ran directly from a GitHub workflow
instead of within the AWS account.

#### Pros

This method would require the least amount of infrastructure required to perform the migration.

#### Cons

Depending on the configuration, there could be an external firewall configured on the AWS account.
For this to work, you would need to open firewall access from GitHub to the account, which opens the
account to a larger surface where unwanted access can occur.

The database must have a public IP or DNS record so that Github can connect to it.

Ingesting the logs from the migration to a tool like Datadog and Splunk would require additional
configuration compared to the other options. Certain tools could also charge for using this
functionality.

### Ran via a Lambda Function

[example | description | pointer to more information | …] <!-- optional -->

#### Pros



#### Cons



### Ran via an ECS Task

In this method, the migration is ran by an ECS task that spins up in a cluster.
This task will be destroyed once the migration is completed, so it will not need to be
a long running service.

#### Infrastructure Required

 - ECS cluster to run the task in, which can be the same cluster as the application
 - Log group for storing logs
 - IAM role for the task to use
 - (Optional) IAM policy with permission to connection if using IAM authentication on the database
 - (Optional) ECR to store the image. If using flask template repo, the task can use the same image as the application, so this won't be needed
 - Security group that allows connection to the database
 - IAM role that GitHub can assume to run the task

#### Pros

If the application is using the flask template, you can overload the ECS task
configuration to run the migration command and use the same image, so there is no
need to maintain a different image. This allows you to run the same code locally as
in AWS to try and catches errors before merging.

#### Cons



## Links <!-- optional -->

* [Link type] [Link to ADR] <!-- example: Refined by [ADR-0005](0005-example.md) -->
* … <!-- numbers of links can vary -->
