# Database Migration Infrastructure and Deployment

* Status: proposed
* Deciders: @lorenyu, @daphnegold, @chouinar, @Nava-JoshLong, @addywolf-nava, @sawyerh, @acouch, @SammySteiner
 
 <!-- optional -->
* Date: 2023-06-05 <!-- optional -->

## Context and Problem Statement

What is the most optimal setup for database migrations infrastructure and deployment?
This will break down the different options for how the migration is run, but not the
tools or languages the migration will be run with, that will be dependent on the framework the application is using.

Questions that need to be addressed:
 1. How will the method get the latest migration code to run?
 2. What infrastructure is required to use this method?
 3. How is the migration deployment re-run in case of errors?

## Decision Drivers <!-- optional -->

* Scalability: the accepted solution would ideally scale for the needs of large projects (ie, large database)
* Simplicity: the accepted solution should be easy possible to update and maintain
* Security: The solution should be prevent malicious action and provide auditable history of database activity
* Flexibility: the accepted solution would ideally incorporate structural changes to the project (ie, connecting to multiple services like logging or caching tools) 
* Cost

## Considered Options

* Execute migrations via direct database connection from Github Actions
* Execute migrations via a Lambda Function
* Execute migrations via an ECS Fargate Task

## Decision Outcome

Chosen option: "[option 1]", because [justification. e.g., only option, which meets k.o. criterion decision driver | which resolves force force | … | comes out best (see below)].

### Positive Consequences <!-- optional -->

* [e.g., improvement of quality attribute satisfaction, follow-up decisions required, …]
* …

### Negative Consequences <!-- optional -->

* [e.g., compromising quality attribute, follow-up decisions required, …]
* …

## Pros and Cons of the Options <!-- optional -->

### Execute via a Direct Database Connection in Github Action

In this method, the github action runner connects to the database directly to run migrations as part of the ci/cd workflow. There is no cost associated with connecting to the database via github actions.

This method gets the necessary permissions, packages, and versions from the github action runner and the necessary scripts can be written in the Makefile.  <!-- optional -->

#### Pros
This approach uses existing scripts from the application codebase and is quick and simple to set up.

#### Cons


### Execute via a Lambda Function

In this method, a Lambda function is used as the primary method of migration. Either the Lambda is the only compute infrastructure, or it works in conjunction with an EC2 instance or ECS task running something like Flyway. The Lambda needs some sort of stateful supporting infrastructure (like S3 or EC2) for saving the state of the migration, as Lambdas are inherently stateless.

#### Infrastructure Required

- Lambda function to run the migration code
- Log group for storing logs
- IAM role for the Lambda to use
- Some other infrastructure to store the state of the migration (S3, EC2, ECS)
- Any associated IAM roles for the state-storing infrastructure to use
- Security group that allows connection to the database
- IAM role that Github can assume to run the task
- (optional) A queueing method for the Lambda to feed off of, like SQS

#### Pros

Lambda functions can be very cost effective and fast, as well as simple to use.

Lambdas are low maintenance, and don't stick around after the task.

Even though this solution requires additional support, the compute portion of the task run by AWS Lambda is very simple.

#### Cons

By nature, database migrations need to keep track of state--changes between the previous version, the next version, and at what point the migration is currently at. Lambda functions are stateless by design, so an additional component will be needed to keep track of state.

Lambdas have a comparatively short running time. Either find a way to split up the migrations into small tasks, or extend the running time of the Lambda. This might not scale well with large changesets.


### Execute via an ECS Fargate Task

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
