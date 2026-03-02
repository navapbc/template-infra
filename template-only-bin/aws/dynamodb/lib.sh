#!/usr/bin/env bash

function aws::dynamodb::arn_regex() {
  echo "arn:.*:dynamodb:"
}

function aws::dynamodb::cleanup() {
  local arns=("$@")

  local dynamodb_arns
  readarray -t dynamodb_arns < <(printf "%s\n" "${arns[@]}" | grep "^$(aws::dynamodb::arn_regex)")

  if [ "${#dynamodb_arns[@]}" -ne 0 ]; then
    echo "Cleaning up DynamoDB tables..."

    aws::dynamodb::delete_table "${dynamodb_arns[@]}"
  fi
}

function aws::dynamodb::delete_table() {
  local table_arns=("$@")

  for table_arn in "${table_arns[@]}"; do
    local table_name
    table_name=$(echo "${table_arn}" | awk -F'/' '{print $NF}')

    local table_region
    table_region=$(aws::extract_region_from_arn "${table_arn}")

    echo "Deleting DynamoDB table: ${table_name}"
    aws dynamodb delete-table --table-name "${table_name}" --region "${table_region}" || echo "Failed to delete table ${table_name}"
  done
}
