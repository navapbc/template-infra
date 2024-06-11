#!/bin/bash
# -----------------------------------------------------------------------------
# Script that invokes the database role-manager AWS Lambda function to create
# or update the Postgres user roles for a particular environment.
# The Lambda function is created by the infra/app/database root module and is
# defined in the infra/app/database child module.
#
# Positional parameters:
#   app_name (required) – the name of subdirectory of /infra that holds the
#     application's infrastructure code.
#   environment (required) - the name of the application environment (e.g. dev,
#     staging, prod)
# -----------------------------------------------------------------------------
set -euo pipefail

app_name=$1
environment=$2

./bin/terraform-init.sh "infra/$app_name/database" "$environment"
db_role_manager_function_name=$(terraform -chdir="infra/$app_name/database" output -raw role_manager_function_name)

echo "================================"
echo "Creating/updating database users"
echo "================================"
echo "Input parameters"
echo "  app_name=$app_name"
echo "  environment=$environment"
echo
echo "Invoking Lambda function: $db_role_manager_function_name"
cli_response=$(aws lambda invoke \
  --function-name "$db_role_manager_function_name" \
  --no-cli-pager \
  --log-type Tail \
  --output json \
  response.json)

# Print logs out (they are returned base64 encoded)
echo "$cli_response" | jq -r '.LogResult' | base64 --decode
echo
echo "Lambda function response:"
cat response.json
rm response.json

# Exit with nonzero status if function failed
function_error=$(echo "$cli_response" | jq -r '.FunctionError')
if [ "$function_error" != "null" ]; then
  exit 1
fi
