# Set up networks

The network setup process will configure and deploy network resources needed by other modules. In particular, for each network, it will:

1. Create a nondefault VPC
2. Create public subnets for publicly accessible resources such as the application load balancer, private subnets for the application service, and private subnets for the database.
3. Create VPC endpoints for the AWS services needed by ECS Fargate to fetch the container image and log to AWS CloudWatch. If your application has a database, it will also create VPC endpoints for the AWS services needed by the database layer and a security group to contain those VPC endpoints.

## Prerequisites

* You'll need to have [set up the AWS account(s)](./set-up-aws-accounts.md).
* You'll need to have [configured all applications](./set-up-app-config.md).

## Instructions

### 1. Configure the project's networks

Modify [`/infra/project-config/networks.tf`](/infra/project-config/networks.tf) to ensure the environments listed match what you decided in the [set up AWS accounts](./set-up-aws-accounts.md) step.

By default there are three networks defined, one for each application environment. You can add additional additional networks as desired.

If you have multiple applications and want your applications in separate networks within the same AWS account, you may want to give the networks differentiating names (e.g. "foo-dev", "foo-prod", "bar-dev", "bar-prod", instead of just "dev", "prod").

Skip the `domain_config` config for now. These settings are optionally configured later when [setting up custom domains](./set-up-custom-domains.md) and when [setting up HTTPS](./https-support.md).

### 2. Set up each network

For **each network** listed in `/infra/project-config/networks.tf`, [set up the network](./set-up-network.md).