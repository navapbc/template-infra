#!/bin/bash
# -----------------------------------------------------------------------------
# This script configures the service module for the specified application
# and environment by creating the .tfvars file and .tfbackend file for the module.
#
# Positional parameters:
#   APP_NAME (required) – the name of subdirectory of /infra that holds the
#     application's infrastructure code.
#   ENVIRONMENT is the name of the application environment (e.g. dev, staging, prod)
# -----------------------------------------------------------------------------
set -euo pipefail

APP_NAME=$1
ENVIRONMENT=$2

#--------------------------------------
# Create terraform backend config file
#--------------------------------------

MODULE_DIR="infra/$APP_NAME/service"
BACKEND_CONFIG_NAME="$ENVIRONMENT"

./bin/create-tfbackend.sh $MODULE_DIR $BACKEND_CONFIG_NAME

#--------------------
# Create tfvars file
#--------------------

TF_VARS_FILE="$MODULE_DIR/$ENVIRONMENT.tfvars"

# Get values needed to populate the tfvars file (see infra/app/service/example.tfvars)
TF_STATE_BUCKET_NAME=$(terraform -chdir=infra/accounts output -raw tf_state_bucket_name)
TF_LOCKS_TABLE_NAME=$(terraform -chdir=infra/accounts output -raw tf_locks_table_name)
TF_STATE_KEY="$MODULE_DIR/$BACKEND_CONFIG_NAME.tfstate"
REGION=$(terraform -chdir=infra/accounts output -raw region)

terraform -chdir=infra/$APP_NAME/app-config init > /dev/null
terraform -chdir=infra/$APP_NAME/app-config refresh > /dev/null
HAS_DATABASE=$(terraform -chdir=infra/$APP_NAME/app-config output -raw has_database)

if [ $HAS_DATABASE = "true" ]; then
  DB_ACCESS_POLICY_ARN=$(terraform -chdir=infra/$APP_NAME/database output -raw access_policy_arn)
  DB_SECURITY_GROUP_ID=$(terraform -chdir=infra/$APP_NAME/database output -raw cluster_security_group_id)
  DB_HOST=$(terraform -chdir=infra/$APP_NAME/database output -raw database_host)
  DB_PORT=$(terraform -chdir=infra/$APP_NAME/database output -raw database_port)
  DB_USER=$(terraform -chdir=infra/$APP_NAME/database output -raw app_username)
  DB_NAME=$(terraform -chdir=infra/$APP_NAME/database output -raw database_name)
  DB_SCHEMA_NAME=$(terraform -chdir=infra/$APP_NAME/database output -raw schema_name)
fi


echo "======================================"
echo "Setting up tfvars file for app service"
echo "======================================"
echo "Input parameters"
echo "  APP_NAME=$APP_NAME"
echo "  ENVIRONMENT=$ENVIRONMENT"
echo

EXAMPLE_TFVARS_FILE="$MODULE_DIR/example.tfvars"
if [ $HAS_DATABASE = "true" ]; then
  EXAMPLE_TFVARS_FILE="$MODULE_DIR/example-has-db.tfvars"
fi

cp $EXAMPLE_TFVARS_FILE $TF_VARS_FILE
sed -i.bak "s/<ENVIRONMENT>/$ENVIRONMENT/g" $TF_VARS_FILE
sed -i.bak "s/<TF_STATE_BUCKET_NAME>/$TF_STATE_BUCKET_NAME/g" $TF_VARS_FILE
sed -i.bak "s|<TF_STATE_KEY>|$TF_STATE_KEY|g" $TF_VARS_FILE
sed -i.bak "s/<REGION>/$REGION/g" $TF_VARS_FILE

if [ $HAS_DATABASE = "true" ]; then
  sed -i.bak "s|<DB_ACCESS_POLICY_ARN>|$DB_ACCESS_POLICY_ARN|g" $TF_VARS_FILE
  sed -i.bak "s/<DB_SECURITY_GROUP_ID>/$DB_SECURITY_GROUP_ID/g" $TF_VARS_FILE
  sed -i.bak "s/<DB_HOST>/$DB_HOST/g" $TF_VARS_FILE
  sed -i.bak "s/<DB_PORT>/$DB_PORT/g" $TF_VARS_FILE
  sed -i.bak "s/<DB_USER>/$DB_USER/g" $TF_VARS_FILE
  sed -i.bak "s/<DB_NAME>/$DB_NAME/g" $TF_VARS_FILE
  sed -i.bak "s/<DB_SCHEMA_NAME>/$DB_SCHEMA_NAME/g" $TF_VARS_FILE
fi
rm $TF_VARS_FILE.bak

echo "Created file: $TF_VARS_FILE"
echo "------------------ file contents ------------------"
cat $TF_VARS_FILE
echo "----------------------- end -----------------------"
