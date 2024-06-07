#!/bin/bash
set -euo pipefail

github_actions_role=$1

# This is used later to determine the run id of the workflow run
# See comment below about "Getting workflow run id"
prev_run_create_time=$(gh run list --workflow check-infra-auth.yml --limit 1 --json createdAt --jq ".[].createdAt")

echo "Run check-infra-auth workflow with role_to_assume=$github_actions_role"
gh workflow run check-infra-auth.yml --field role_to_assume="$github_actions_role"

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

echo "Previous workflow run created at $prev_run_create_time"
echo "Check workflow run create time until we find a newer workflow run"
while : ; do
  echo -n "."
  run_create_time=$(gh run list --workflow check-infra-auth.yml --limit 1 --json createdAt --jq ".[].createdAt")
  [[ $run_create_time > $prev_run_create_time ]] && break
done
echo "Found newer workflow run created at $run_create_time"

echo "Get id of workflow run"
workflow_run_id=$(gh run list --workflow check-infra-auth.yml --limit 1 --json databaseId --jq ".[].databaseId")
echo "Workflow run id: $workflow_run_id"

echo "Watch workflow run until it exits"
# --exit-status causes command to exit with non-zero status if run fails
gh run watch "$workflow_run_id" --exit-status
