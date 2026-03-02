#!/usr/bin/env bash

function aws::bedrock::arn_regex() {
  echo "arn:.*:bedrock:"
}

function aws::bedrock::cleanup() {
  local arns=("$@")

  local bedrock_da_arns
  readarray -t bedrock_da_arns < <(printf "%s\n" "${arns[@]}" | grep "^$(aws::bedrock::data_automation::arn_regex)")

  if [ "${#bedrock_da_arns[@]}" -ne 0 ]; then
    echo "Cleaning up Bedrock Data Automation..."
    aws::bedrock::data_automation::delete "${bedrock_da_arns[@]}"
  fi

  local bedrock_blueprint_arns
  readarray -t bedrock_blueprint_arns < <(printf "%s\n" "${arns[@]}" | grep "^$(aws::bedrock::blueprint::arn_regex)")

  if [ "${#bedrock_blueprint_arns[@]}" -ne 0 ]; then
    aws::bedrock::blueprint::delete "${bedrock_blueprint_arns[@]}"
  fi
}

function aws::bedrock::data_automation::arn_regex() {
  echo "$(aws::bedrock::arn_regex).*:data-automation-project/"
}

function aws::bedrock::data_automation::delete() {
  local bedrock_da_arns=("$@")

  for bda_project_arn in "${bedrock_da_arns[@]}"; do
    echo "Deleting Bedrock Data Automation project: ${bda_project_arn}"

    local bda_region
    bda_region=$(aws::extract_region_from_arn "${bda_project_arn}")

    aws bedrock-data-automation delete-data-automation-project --project-arn "${bda_project_arn}" --region "${bda_region}" || echo "Failed to delete BDA ${bda_project_arn}"
  done

}

function aws::bedrock::blueprint::arn_regex() {
  echo "$(aws::bedrock::arn_regex).*:blueprint/"
}

function aws::bedrock::blueprint::delete() {
  local bedrock_blueprint_arns=("$@")

  for bedrock_blueprint_arn in "${bedrock_blueprint_arns[@]}"; do
    echo "Deleting BDA Blueprint: ${bedrock_blueprint_arn}"

    local bedrock_blueprint_region
    bedrock_blueprint_region=$(aws::extract_region_from_arn "${bda_project_arn}")

    aws bedrock-data-automation delete-blueprint --blueprint-arn "${bedrock_blueprint_arn}" --region "${bedrock_blueprint_region}" || echo "Failed to delete BDA Blueprint ${bedrock_blueprint_arn}"
  done
}
