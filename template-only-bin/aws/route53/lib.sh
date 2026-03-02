#!/usr/bin/env bash

function aws::route53::arn_regex() {
  echo "arn:.*:route53:"
}

function aws::route53::cleanup() {
  local arns=("$@")

  local hosted_zone_arns
  readarray -t hosted_zone_arns < <(printf "%s\n" "${arns[@]}" | grep "^$(aws::route53::hosted_zone::arn_regex)")

  if [ "${#hosted_zone_arns[@]}" -ne 0 ]; then
    echo "Cleaning up Route 53 hosted zones..."
    aws::route53::hosted_zone::delete "${hosted_zone_arns[@]}"
  fi
}

function aws::route53::hosted_zone::arn_regex() {
  echo "$(aws::route53::arn_regex).*:hostedzone/"
}

function aws::route53::hosted_zone::delete() {
  local hosted_zone_arns=("$@")

  for hosted_zone_arn in "${hosted_zone_arns[@]}"; do
    local hosted_zone_arn=$1
    local hosted_zone_id
    hosted_zone_id=$(echo "${hosted_zone_arn}" | awk -F'/' '{print $NF}')

    aws route53 delete-hosted-zone --id "${hosted_zone_id}" || echo "Failed to delete hosted zone ${hosted_zone_id}"
  done
}
