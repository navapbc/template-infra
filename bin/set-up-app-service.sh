#!/bin/bash
set -euo pipefail

# APP_NAME is the name of the directory that holds the application code,
# as well as the subdirectory of /infra that holds the application
# infrastructure code. Defaults to "app".
APP_NAME=$1

# ENVIRONMENT is the name of the environment that will be created.
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

# Get the name of the S3 bucket that was created to store the tf state
# and the name of the DynamoDB table that was created for tf state locks.
# This will be used to configure the S3 backends in all the application
# modules
TF_STATE_BUCKET_NAME=$(terraform -chdir=infra/accounts output -raw tf_state_bucket_name)
TF_LOCKS_TABLE_NAME=$(terraform -chdir=infra/accounts output -raw tf_locks_table_name)
TF_STATE_KEY="$MODULE_DIR/$BACKEND_CONFIG_NAME.tfstate"
REGION=$(terraform -chdir=infra/accounts output -raw region)


echo "======================================"
echo "Setting up tfvars file for app service"
echo "======================================"
echo "Input parameters"
echo "  APP_NAME=$APP_NAME"
echo "  ENVIRONMENT=$ENVIRONMENT"
echo

cp $MODULE_DIR/example.tfvars $TF_VARS_FILE
sed -i.bak "s/<ENVIRONMENT>/$ENVIRONMENT/g" $TF_VARS_FILE
sed -i.bak "s/<TF_STATE_BUCKET_NAME>/$TF_STATE_BUCKET_NAME/g" $TF_VARS_FILE
sed -i.bak "s|<TF_STATE_KEY>|$TF_STATE_KEY|g" $TF_VARS_FILE
sed -i.bak "s/<REGION>/$REGION/g" $TF_VARS_FILE
rm $TF_VARS_FILE.bak

echo "Created file: $TF_VARS_FILE"
echo "---------------------- start ----------------------"
cat $TF_VARS_FILE
echo "----------------------- end -----------------------"
