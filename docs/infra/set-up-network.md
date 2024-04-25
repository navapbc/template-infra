# Set up network

The network setup process will configure and deploy network resources needed by other modules. In particular, it will:

1. Create a nondefault VPC
2. Create public subnets for publicly accessible resources such as the application load balancer, private subnets for the application service, and private subnets for the database.
3. Create VPC endpoints for the AWS services needed by ECS Fargate to fetch the container image and log to AWS CloudWatch. If your application has a database, it will also create VPC endpoints for the AWS services needed by the database layer and a security group to contain those VPC endpoints.

This setup process applies to each AWS account in the project.

## Prerequisites

* You'll need to have [set up the AWS account(s)](./set-up-aws-accounts.md).
* You'll need to have configured [all applications](./set-up-app-config.md).

## Instructions

### 1. Make sure you're authenticated into the AWS account you want to configure

The network is set up for whatever account you're authenticated into. To see which account that is, run

```bash
aws sts get-caller-identity
```

To see a more human readable account alias instead of the account, run

```bash
aws iam list-account-aliases
```

### 2. Configure the project's network

Modify the [project-config module](/infra/project-config/networks.tf) to ensure the environments match what you decided in the [set up AWS accounts](./set-up-aws-accounts.md) step.

By default there are three networks defined, one for each application environment. You can add additional additional networks as desired.

If you have multiple applications and want your applications in separate networks within the same AWS account, you may want to give the networks differentiating names (e.g. "foo-dev", "foo-prod", "bar-dev", "bar-prod", instead of just "dev", "prod").

Skip the `domain_config` config for now. This is addressed in [setting up custom domains](./set-up-custom-domains.md).

### 3. Configure backend

To create the tfbackend file for the new network, run

```bash
make infra-configure-network NETWORK_NAME=<NETWORK_NAME>
```

### 4. Create network resources

Now run the following commands to create the resources. Review the terraform before confirming "yes" to apply the changes.

```bash
make infra-update-network NETWORK_NAME=<NETWORK_NAME>
```

## Updating the network

If you make changes to your application's configuration that impacts the network (such as `has_database` and `has_external_non_aws_service`), make sure to update the network before you update or deploy subsequent infrastructure layers.
