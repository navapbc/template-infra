#!/bin/bash
# Print the config name for the current AWS account
# Do this by getting the current account and searching for a file in
# infra/accounts that matches "<account name>.<account id>.s3.tfbackend".
# The config name is "<account name>.<account id>""
set -euo pipefail

current_account_id=$(./bin/current-account-id.sh)
backend_config_file_path=$(ls -1 infra/accounts/*."$current_account_id".s3.tfbackend)
backend_config_file=$(basename "$backend_config_file_path")
backend_config_name="${backend_config_file/.s3.tfbackend/}"
echo "$backend_config_name"
