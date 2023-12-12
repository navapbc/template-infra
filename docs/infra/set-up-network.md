# Set up network

The network setup process will configure and deploy network resources needed by other modules. In particular, it will:

1. Create a nondefault VPC
2. Create public subnets for publicly accessible resources such as the application load balancer, private subnets for the application service, and private subnets for the database.
3. Create VPC endpoints for the AWS services needed by ECS Fargate to fetch the container image and log to AWS CloudWatch. If your application has a database, it will also create VPC endpoints for the AWS services needed by the database layer and a security group to contain those VPC endpoints.

## Requirements

Before setting up the database you'll need to have:

1. [Set up the AWS account](./set-up-aws-account.md)
2. Optionally configure the networks you want to have on your project in the [project-config module](/infra/project-config/main.tf). By default there is configuration for three networks, one for each application environment.

## 1. Configure backend

To create the tfbackend file for the new network, run

```bash
make infra-configure-network NETWORK_NAME=<NETWORK_NAME>
```

## 2. Create network resources

Now run the following commands to create the resources. Review the terraform before confirming "yes" to apply the changes.

```bash
make infra-update-network NETWORK_NAME=<NETWORK_NAME>
```
