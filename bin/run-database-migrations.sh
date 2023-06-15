#!/bin/bash
# -----------------------------------------------------------------------------
# Run database migrations
# 1. Update the application's task definition with the latest build, but
#    do not update the service
# 2. Run the "db-migrate" command in the container as a new task
#
# Positional parameters:
#   APP_NAME (required) – the name of subdirectory of /infra that holds the
#     application's infrastructure code.
#   IMAGE_TAG (required) – the tag of the latest build
#   ENVIRONMENT (required) – the name of the application environment (e.g. dev,
#     staging, prod)
# -----------------------------------------------------------------------------
set -euo pipefail

APP_NAME="$1"
IMAGE_TAG="$2"
ENVIRONMENT="$3"

echo "=================="
echo "Running migrations"
echo "=================="
echo "Input parameters"
echo "  APP_NAME=$APP_NAME"
echo "  IMAGE_TAG=$IMAGE_TAG"
echo "  ENVIRONMENT=$ENVIRONMENT"
echo
echo "Step 0. Check if app has a database"

terraform -chdir=infra/$APP_NAME/app-config init > /dev/null
terraform -chdir=infra/$APP_NAME/app-config refresh > /dev/null
HAS_DATABASE=$(terraform -chdir=infra/$APP_NAME/app-config output -raw has_database)
if [ $HAS_DATABASE = "false" ]; then
  echo "Application does not have a database, no migrations to run"
  exit 0
fi

echo
echo "Step 1. Update task definition without updating service"

MODULE_DIR="infra/$APP_NAME/service"
CONFIG_NAME="$ENVIRONMENT"
TF_CLI_ARGS_apply="-input=false -auto-approve -target=module.service.aws_ecs_task_definition.app -var=image_tag=$IMAGE_TAG" ./bin/terraform-init-and-apply.sh $MODULE_DIR $CONFIG_NAME

echo
echo 'Step 2. Run "db-migrate" command'

./bin/terraform-init.sh infra/$APP_NAME/database $ENVIRONMENT
DB_HOST=$(terraform -chdir=infra/$APP_NAME/database output -raw database_host)
DB_PORT=$(terraform -chdir=infra/$APP_NAME/database output -raw database_port)
DB_MIGRATOR_USER=$(terraform -chdir=infra/$APP_NAME/database output -raw migrator_username)
DB_NAME=$(terraform -chdir=infra/$APP_NAME/database output -raw database_name)
DB_SCHEMA=$(terraform -chdir=infra/$APP_NAME/database output -raw schema_name)

COMMAND='["db-migrate"]'

# Indent the later lines more to make the output of run-command prettier
ENVIRONMENT_VARIABLES=$(cat << EOF
[
        { "name" : "DB_HOST", "value" : "$DB_HOST" },
        { "name" : "DB_PORT", "value" : "$DB_PORT" },
        { "name" : "DB_USER", "value" : "$DB_MIGRATOR_USER" },
        { "name" : "DB_NAME", "value" : "$DB_NAME" },
        { "name" : "DB_SCHEMA", "value" : "$DB_SCHEMA" }
      ]
EOF
)

./bin/run-command.sh $APP_NAME $ENVIRONMENT "$COMMAND" "$ENVIRONMENT_VARIABLES"
