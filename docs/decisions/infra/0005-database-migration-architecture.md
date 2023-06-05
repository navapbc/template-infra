# Database Migration Infrastructure and Deployment

* Status: proposed
* Deciders: Loren Yu, Daphne Gold, Michael Chouinard, Josh Long, Addy Wolf, Sawyer Hollenshead, Aaron Couch, Sammy Steiner
 <!-- optional -->
* Date: 2023-06-05 <!-- optional -->

## Context and Problem Statement

What is the most optimal setup for database migrations infrastructure and deployment?
This will break down the different options for how the migration is run, but not the
tools or languages the migration will be run with, that will be dependent on the framework the application is using.

Questions that need to be addressed:
 1. How will the method get the latest migration code to run?
 2. What infrastructure is required to use this method?
 3. How is the migration deployment re-ran in case of errors?

## Decision Drivers <!-- optional -->

* [driver 1, e.g., a force, facing concern, …]
* [driver 2, e.g., a force, facing concern, …]
* … <!-- numbers of drivers can vary -->

## Considered Options

* Ran via a Lambda Function
* Ran via an ECS Fargate Task

## Decision Outcome

Chosen option: "[option 1]", because [justification. e.g., only option, which meets k.o. criterion decision driver | which resolves force force | … | comes out best (see below)].

### Positive Consequences <!-- optional -->

* [e.g., improvement of quality attribute satisfaction, follow-up decisions required, …]
* …

### Negative Consequences <!-- optional -->

* [e.g., compromising quality attribute, follow-up decisions required, …]
* …

## Pros and Cons of the Options <!-- optional -->

### Ran via a Lambda Function

[example | description | pointer to more information | …] <!-- optional -->

#### Pros



#### Cons



### Ran via an ECS Fargate Task

In this method, the migration is ran by an ECS task that spins up in a cluster.
This task will be destroyed once the migration is completed, so it will not need to be
a long running service.

This method gets the latest configuration by creating a Dockerized image from the
workflow and pushing it to AWS ECR. This image has a function that will be called
from the ECS task's configuration JSON.

#### Infrastructure Required

 - ECS cluster to run the task in, which can be the same cluster as the application
 - Log group for storing logs
 - IAM role for the task to use
 - (Optional) IAM policy with permission to connection if using IAM authentication on the database
 - (Optional) ECR to store the image. This is dependent on the application used
 - Security group that allows connection to the database
 - IAM role that GitHub can assume to run the task

#### Pros

Depending on the application, you can overload the ECS task configuration to run
the migration command and use the same app image, so there is no need to maintain
a different image. This allows you to run the same code locally as in AWS to try
and catches errors before merging. (An example of this is the flask application)

Cheaper to run compared to Lambda, ~$0.015/hour vs ~$0.06/hour

#### Cons

The only way to re-run migrations if there is a failure, is to re-run the workflow from GitHub.

Start-up time is slower compared to Lambda

## Links <!-- optional -->

* [Link type] [Link to ADR] <!-- example: Refined by [ADR-0005](0005-example.md) -->
* … <!-- numbers of links can vary -->
