# Service Access

The infrastructure supports developer access to a running application's service container using [ECS Exec](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-exec.html). You can run commands in or get a shell to an actively running container, allowing you to quickly debug issues or to use the container to access an attached database. Once you create an interactive shell, you will be operating with the same permissions as the container (e.g. you may access any database the container has access to, but you cannot access databases within the same account that the container does not have access to).

## Prerequisites

* You'll need to have set up the [app environments](./set-up-app-env.md)

## Instructions

### 1. Make sure you're authenticated into the AWS account that the ECS container is running in

This takes effect in whatever account you're authenticated into. To see which account that is, run

```bash
aws sts get-caller-identity
```

To see a more human readable account alias instead of the account, run

```bash
aws iam list-account-aliases
```

### 2. Execute commands

To create an interactive shell, run

```bash
aws ecs execute-command --cluster <CLUSTER_NAME> \
    --task <TASK_ID> \
    --container <CONTAINER_NAME> \
    --interactive \
    --command "/bin/sh"
```

To run other commands, modify the `--command` flag to execute the command, rather than starting a shell.
