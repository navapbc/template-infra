#!/usr/bin/env bash

function aws::sns::cleanup() {
  local arns=("$@")

  local sns_topic_arns
  readarray -t sns_topic_arns < <(printf "%s\n" "${arns[@]}" | grep '^arn:aws:sns:.*')

  if [ "${#sns_topic_arns[@]}" -ne 0 ]; then
    echo "Cleaning up SNS..."
    aws::sns::delete_topic "${sns_topic_arns[@]}"
  fi
}

function aws::sns::delete_topic() {
  local sns_topic_arns=("$@")

  for sns_topic_arn in "${sns_topic_arns[@]}"; do
    echo "Deleting SNS Topic: ${sns_topic_arn}"

    local sns_topic_region
    sns_topic_region=$(aws::extract_region_from_arn "${sns_topic_arn}")

    aws sns delete-topic --topic-arn "${sns_topic_arn}" --region "${sns_topic_region}" || echo "Failed to delete SNS Topic ${sns_topic_arn}"
  done
}
