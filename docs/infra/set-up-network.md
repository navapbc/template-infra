# Set up network

The network setup process will configure and deploy network resources needed by other modules for one network. In particular, it will:

1. Create a nondefault VPC
2. Create public subnets for publicly accessible resources such as the application load balancer, private subnets for the application service, and private subnets for the database.
3. Create VPC endpoints for the AWS services needed by ECS Fargate to fetch the container image and log to AWS CloudWatch. If your application has a database, it will also create VPC endpoints for the AWS services needed by the database layer and a security group to contain those VPC endpoints.

## Prerequisites

* You'll need to have [set up the AWS account(s)](./set-up-aws-accounts.md).
* You'll need to have [configured all applications](./set-up-app-config.md).
* You'll need to have [configured the project's networks](./set-up-networks.md).

## Instructions

Follow these instructions for **each network** in your project (this can be one or more).

### 1. Make sure you're authenticated into the AWS account you want to configure

The network is set up for whatever account you're authenticated into. To see which account that is, run

```bash
aws sts get-caller-identity
```

To see a more human readable account alias instead of the account, run

```bash
aws iam list-account-aliases
```

### 2. Configure backend

To create the tfbackend file for the new network, run

```bash
make infra-configure-network NETWORK_NAME=<NETWORK_NAME>
```

### 3. Create network resources

Now run the following commands to create the resources. Review the terraform before confirming "yes" to apply the changes.

```bash
make infra-update-network NETWORK_NAME=<NETWORK_NAME>
```

## Updating the network

If you make changes to your application's configuration that impacts the network (such as `has_database` and `has_external_non_aws_service`), make sure to update the network before you update or deploy subsequent infrastructure layers.
