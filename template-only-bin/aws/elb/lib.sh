#!/usr/bin/env bash

function aws::elb::arn_regex() {
  echo "arn:.*:elasticloadbalancing:"
}

function aws::elb::cleanup() {
  local arns=("$@")

  # Delete load balancers
  local lb_arns
  readarray -t lb_arns < <(printf "%s\n" "${arns[@]}" | grep "^$(aws::elb::load_balancer::arn_regex)")

  if [ "${#lb_arns[@]}" -ne 0 ]; then
    echo "Cleaning up load balancers..."
    aws::elb::load_balancer::delete "${lb_arns[@]}"

    # Wait a bit for LB deletion
    sleep 5
  fi

  # Delete target groups
  local tg_arns
  readarray -t tg_arns < <(printf "%s\n" "${arns[@]}" | grep "^$(aws::elb::target_group::arn_regex)")

  if [ "${#tg_arns[@]}" -ne 0 ]; then
    echo "Cleaning up load balancer target groups..."
    aws::elb::target_group::delete "${tg_arns[@]}"
  fi
}

function aws::elb::load_balancer::arn_regex() {
  echo "$(aws::elb::arn_regex).*:loadbalancer/"
}

function aws::elb::load_balancer::delete() {
  local lb_arns=("$@")

  for lb_arn in "${lb_arns[@]}"; do
    echo "Deleting load balancer: ${lb_arn}"

    local lb_region
    lb_region=$(aws::extract_region_from_arn "${lb_arn}")

    aws elbv2 delete-load-balancer --load-balancer-arn "${lb_arn}" --region "${lb_region}" || echo "Failed to delete LB"
  done
}

function aws::elb::target_group::arn_regex() {
  echo "$(aws::elb::arn_regex).*:targetgroup/"
}

function aws::elb::target_group::delete() {
  local tg_arns=("$@")

  for tg_arn in "${tg_arns[@]}"; do
    echo "Deleting target group: ${tg_arn}"

    local tg_region
    tg_region=$(aws::extract_region_from_arn "${tg_arn}")

    aws elbv2 delete-target-group --target-group-arn "${tg_arn}" --region "${tg_region}" 2>&1 | grep -v "TargetGroupInUse" || echo "Skipping in-use target group"
  done
}
