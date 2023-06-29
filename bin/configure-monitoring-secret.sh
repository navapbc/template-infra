#!/bin/bash
# -----------------------------------------------------------------------------
# This script creates SSM parameter for storing integration URL for incident management
# services. Script creates new SSM attribute or updates existing. 
#
# Positional parameters:
#   APP_NAME (required) – the name of subdirectory of /infra that holds the
#     application's infrastructure code.
#   ENVIRONMENT is the name of the application environment (e.g. dev, staging, prod)
#   URL is the url for te integration endpoint for external incident management
#     tools (e.g. Pagerduty, Splunk-On-Call
# -----------------------------------------------------------------------------
set -euo pipefail

APP_NAME=$1
ENVIRONMENT=$2
URL=$3

REGION="$(./bin/current-region.sh)"

SECRET_NAME="Incident-management-integration-url-$APP_NAME-$ENVIRONMENT"

echo "====================="
echo "Setting up SSM secret"
echo "====================="
echo "APPLICATION_NAME=$APP_NAME"
echo "ENVIRONMENT=$ENVIRONMENT"
echo "INTEGRATION_URL=$URL" 
echo "REGION=$REGION"
echo
echo "Creating SSM secret: $SECRET_NAME"

aws ssm put-parameter \
    --name "$SECRET_NAME" \
    --value "$URL" \
    --type String \
    --overwrite

