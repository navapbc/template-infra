#!/usr/bin/env bash

function aws::kms::cleanup() {
  local arns=("$@")

  local kms_arns
  readarray -t kms_arns < <(printf "%s\n" "${arns[@]}" | grep '^arn:aws:kms:')

  if [ "${#kms_arns[@]}" -ne 0 ]; then
    echo "Scheduling KMS keys for deletion..."
    aws::kms::delete_key "${kms_arns[@]}"
  fi
}

function aws::kms::delete_key() {
  local key_arns=("$@")

  for key_arn in "${key_arns[@]}"; do
    local key_id
    key_id=$(echo "${key_arn}" | awk -F'/' '{print $NF}')

    local key_region
    key_region=$(aws::extract_region_from_arn "${key_arn}")

    local key_state
    key_state=$(aws kms describe-key --key-id "${key_id}" --region "${key_region}" --query 'KeyMetadata.KeyState' --output text)
    if [[ "${key_state}" = "PendingDeletion" ]]; then
      local key_delete_time
      key_delete_time=$(aws kms describe-key --key-id "${key_id}" --region "${key_region}" --query 'KeyMetadata.DeletionDate' --output text)
      echo "KMS key already scheduled for deletion: ${key_id} at ${key_delete_time}"
      continue
    fi

    echo "Scheduling KMS key for deletion: ${key_id}"
    aws kms schedule-key-deletion --key-id "${key_id}" --pending-window-in-days 7 --region "${key_region}" || echo "Failed to schedule deletion for key ${key_id}"
  done
}
