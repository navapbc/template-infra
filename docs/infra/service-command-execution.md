# Running commands on the service

The infrastructure supports developer access to a running application's service container using [ECS Exec](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-exec.html). You can run commands in or get a shell to an actively running container, allowing you to quickly debug issues or to use the container to access an attached database. Once you create an interactive shell, you will be operating with the same permissions as the container (e.g. you may access any database the container has access to, but you cannot access databases within the same account that the container does not have access to).

⚠️ **Warning: It is not recommended to enable service access in a production environment!**

## Prerequisites

* You have [set up infrastructure tools](./set-up-infrastructure-tools.md), like Terraform, AWS CLI, and AWS authentication.
* You are [authenticated into the AWS account](./set-up-infrastructure-tools.md#authenticate-with-aws) you want to configure.
* You have [set up the application service](./set-up-app-service.md).
* You have [installed the Session Manager plugin for the AWS CLI](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html).

## Instructions

### 1. Enable service execution access

Within the `app-config` directory (e.g. `infra/<APP_NAME>/app-config`), each environment has its own config file named after the environment. For example, if the application has three environments `dev`, `staging`, and `prod`, it should have corresponding `dev.tf`, `staging.tf`, and `prod.tf` files.

In the environment config file for the environment that you want to enable service access, set `enable_command_execution` to `true`.

### 2. Update the network

The VPC requires an additional VPC endpoint. To update the network, run:

```bash
make infra-update-network NETWORK_NAME=<NETWORK_NAME>
```

`<NETWORK_NAME>` must be the name of the network that the application is running in.

### 3. Update the application service

To update the ECS Task Definition to allow command execution, run:

```bash
make infra-update-app-service APP_NAME=<APP_NAME> ENVIRONMENT=<ENVIRONMENT>
```

`<APP_NAME>` must be the name of the application folder within the `/infra` folder.

`<ENVIRONMENT>` must be the name of the environment to update.

### 4. Execute commands

To create an interactive shell, run:

```bash
aws ecs execute-command --cluster <CLUSTER_NAME> \
    --task <TASK_ID> \
    --container <CONTAINER_NAME> \
    --interactive \
    --command "/bin/sh"
```

To run other commands, modify the `--command` flag to execute the command, rather than starting a shell.
