#!/usr/bin/env bash

function aws::s3::arn_regex() {
  echo "arn:.*:s3:::"
}

function aws::s3::cleanup() {
  local arns=("$@")

  local s3_arns
  readarray -t s3_arns < <(printf "%s\n" "${arns[@]}" | grep "^$(aws::s3::arn_regex)")

  for s3_arn in "${s3_arns[@]}"; do
    local bucket_name
    bucket_name=$(aws::s3::get_bucket_name_from_arn "${s3_arn}")

    echo "Deleting S3 bucket: ${bucket_name}"
    aws::s3::delete_bucket "${bucket_name}"
  done
}

function aws::s3::get_bucket_name_from_arn() {
  local s3_arn=$1

  echo "${s3_arn#arn:aws:s3:::}"
}

function aws::s3::get_bucket_region() {
  local bucket_name=$1

  aws s3api head-bucket --bucket "${bucket_name}" --query "BucketRegion" --output text
}

function aws::s3::delete_bucket() {
  local bucket_name=$1
  local bucket_region=${2:-"$(aws::s3::get_bucket_region "${bucket_name}")"}

  # Empty bucket first (required before deletion)
  aws::s3::empty_bucket "${bucket_name}" "${bucket_region}"

  # Delete bucket
  aws s3api delete-bucket --bucket "${bucket_name}" --region "${bucket_region}" || echo "Failed to delete bucket ${bucket_name}"
}

# Derived from https://stackoverflow.com/a/61123579
function aws::s3::empty_bucket() {
  local bucket_name=$1
  local aws_region=${2:-"$(aws::s3::get_bucket_region "${bucket_name}")"}

  aws s3 rm "s3://${bucket_name}" --recursive --region "${aws_region}" 2>/dev/null || echo "Bucket already empty or inaccessible"

  # shellcheck disable=SC2016
  num_objects=$(aws s3api list-object-versions --bucket "${bucket_name}" --region "${aws_region}" --query='length(Versions[*] || `[]` )' | awk '{ print $1 }')
  echo "'${num_objects}' objects to remove"
  if [[ "${num_objects}" != "0" ]]; then
    start=$SECONDS
    while [[ $num_objects -gt 0 ]]
    do
      # shellcheck disable=SC2016
      aws s3api delete-objects --bucket "${bucket_name}" --delete "$(aws s3api list-object-versions --bucket "${bucket_name}" --region "${aws_region}" --max-items 500 --query='{Objects: Versions[0:500].{Key:Key,VersionId:VersionId}}')" --query 'length(Deleted[*] || `[]` )' > /dev/null
      num_objects=$((num_objects  > 500 ? num_objects - 500 : 0))
      echo "Removed batch of Objects... Remaining : ${num_objects} ($(( SECONDS - start ))s)"
    done
  fi

  # shellcheck disable=SC2016
  num_objects=$(aws s3api list-object-versions --bucket "${bucket_name}" --region "${aws_region}" --query='length(DeleteMarkers[*] || `[]` )' | awk '{ print $1 }')
  echo "'${num_objects}' markers to remove"
  if [[ "$num_objects" != "0" ]]; then
    start=$SECONDS
    while [[ $num_objects -gt 0 ]]
    do
      # shellcheck disable=SC2016
      aws s3api delete-objects --bucket "${bucket_name}" --delete "$(aws s3api list-object-versions --bucket "${bucket_name}" --region "${aws_region}" --max-items 500 --query='{Objects: DeleteMarkers[0:500].{Key:Key,VersionId:VersionId}}')" --query 'length(Deleted[*] || `[]` )' > /dev/null
      num_objects=$((num_objects  > 500 ? num_objects - 500 : 0))
      echo "Removed batch of Markers... Remaining : ${num_objects} (took $(( SECONDS - start ))s)"
    done
  fi
}
