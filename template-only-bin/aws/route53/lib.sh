#!/usr/bin/env bash

function aws::route53::arn_regex() {
  echo "arn:.*:route53:"
}

function aws::route53::cleanup() {
  local arns=("$@")

  echo "Cleaning up Route 53 hosted zones..."
  local hosted_zone_arns
  readarray -t hosted_zone_arns < <(printf "%s\n" "${arns[@]}" | grep "^$(aws::route53::hosted_zone::arn_regex)")

  for hosted_zone_arn in "${hosted_zone_arns[@]}"; do
    aws::route53::hosted_zone::delete "${hosted_zone_arn}"
  done

}

function aws::route53::hosted_zone::arn_regex() {
  echo "$(aws::route53::arn_regex).*:hostedzone/"
}

function aws::route53::hosted_zone::delete() {
  local hosted_zone_arn=$1
  local hosted_zone_id
  hosted_zone_id=$(echo "${hosted_zone_arn}" | awk -F'/' '{print $NF}')

  aws route53 delete-hosted-zone --id "${hosted_zone_id}" || echo "Failed to delete hosted zone ${hosted_zone_id}"
}
