#!/bin/bash
# -----------------------------------------------------------------------------
# This script configures the database module for the specified application
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

# This is used later to determine the run id of the workflow run
# See comment below about "Getting workflow run id"
PREV_RUN_CREATE_TIME=$(gh run list --workflow check-infra-auth.yml --limit 1 --json createdAt --jq ".[].createdAt")

echo "========================="
echo "Check GitHub Actions Auth"
echo "========================="
echo "Input parameters"
echo "  APP_NAME=$APP_NAME"
echo "  ENVIRONMENT=$ENVIRONMENT"
echo


echo "Run check-infra-auth workflow with app_name=$APP_NAME and environment=$ENVIRONMENT"
gh workflow run check-infra-auth.yml --field app_name=$APP_NAME --field environment=$ENVIRONMENT

#########################
## Get workflow run id ##
#########################

echo "Get workflow run id"
# The following commands aims to get the workflow run id of the run that was
# just triggered by the previous workflow dispatch event. There's currently no
# simple and reliable way to do this, so for now we are going to accept that
# there is a race condition.
#
# The current implementation involves getting the create time of the previous
# run. Then continuously checking the list of workflow runs until we see a
# newly created run. Then we get the id of this new run.
# 
# References:
# * This stack overflow article suggests a complicated overengineered approach:
# https://stackoverflow.com/questions/69479400/get-run-id-after-triggering-a-github-workflow-dispatch-event
# * This GitHub community discussion also requests this feature:
# https://github.com/orgs/community/discussions/17389

echo "Previous workflow run created at $PREV_RUN_CREATE_TIME"
echo "Check workflow run create time until we find a newer workflow run"
while : ; do
  echo -n "."  
  RUN_CREATE_TIME=$(gh run list --workflow check-infra-auth.yml --limit 1 --json createdAt --jq ".[].createdAt")
  [[ $RUN_CREATE_TIME > $PREV_RUN_CREATE_TIME ]] && break
done
echo "Found newer workflow run created at $RUN_CREATE_TIME"

echo "Get id of workflow run"
WORKFLOW_RUN_ID=$(gh run list --workflow check-infra-auth.yml --limit 1 --json databaseId --jq ".[].databaseId")
echo "Workflow run id: $WORKFLOW_RUN_ID"

echo "Watch workflow run until it exits"
# --exit-status causes command to exit with non-zero status if run fails
gh run watch $WORKFLOW_RUN_ID --exit-status
