#!/bin/bash
set -euo pipefail

GITHUB_ACTIONS_ROLE=$1

echo "Run check-infra-auth workflow with role-to-assume=$GITHUB_ACTIONS_ROLE"
gh workflow run check-infra-auth.yml --field role-to-assume=$GITHUB_ACTIONS_ROLE

echo "Get workflow run id"
WORKFLOW_RUN_ID=$(gh run list --workflow check-infra-auth.yml --limit 1 --json databaseId --jq ".[].databaseId")
echo "Workflow run id: $WORKFLOW_RUN_ID"

echo "Watch workflow run until it exits"
# --exit-status causes command to exit with non-zero status if run fails
gh run watch $WORKFLOW_RUN_ID --exit-status
