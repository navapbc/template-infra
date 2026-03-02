#!/usr/bin/env bash

function aws::logs::cleanup() {
  local arns=("$@")

  local log_group_arns
  readarray -t log_group_arns < <(printf "%s\n" "${arns[@]}" | grep '^arn:aws:logs:.*:log-group:')

  if [ "${#log_group_arns[@]}" -ne 0 ]; then
    echo "Cleaning up logs..."
    aws::logs::delete_group "${log_group_arns[@]}"
  fi
}

function aws::logs::delete_group() {
  local log_group_arns=("$@")

  for log_group_arn in "${log_group_arns[@]}"; do
    local log_group_name
    log_group_name=$(echo "${log_group_arn}" | awk -F'log-group:' '{print $NF}')

    local log_group_region
    log_group_region=$(aws::extract_region_from_arn "${log_group_arn}")

    echo "Deleting Log Group: ${log_group_name}"
    aws logs delete-log-group --log-group-name "${log_group_name}" --region "${log_group_region}" || echo "Failed to delete Log Group ${log_group_name}"
  done
}
