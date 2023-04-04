#!/bin/bash
set -euo pipefail

# APP_NAME is the name of the directory that holds the application code,
# as well as the subdirectory of /infra that holds the application
# infrastructure code. Defaults to "app".
APP_NAME=$1

#--------------------------------------
# Create terraform backend config file
#--------------------------------------

MODULE_DIR="infra/$APP_NAME/build-repository"
BACKEND_CONFIG_NAME="shared"

./bin/create-tfbackend.sh $MODULE_DIR $BACKEND_CONFIG_NAME

#--------------------
# Create tfvars file
#--------------------

TF_VARS_FILE="infra/$APP_NAME/build-repository/terraform.tfvars"
REGION=$(terraform -chdir=infra/accounts output -raw region)

echo "==========================================="
echo "Setting up tfvars file for build-repository"
echo "==========================================="
echo "Input parameters"
echo "  APP_NAME=$APP_NAME"
echo
echo "Output file"
echo "  TF_VARS_FILE=$TF_VARS_FILE"
echo
echo "Variable config values"
echo "  REGION=$REGION"
echo

# Create output file from example file
cp infra/$APP_NAME/build-repository/example.tfvars $TF_VARS_FILE

# Replace the placeholder values
sed -i.bak "s/<REGION>/$REGION/g" $TF_VARS_FILE

# Remove the backup file created by sed
rm $TF_VARS_FILE.bak
