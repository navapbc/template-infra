#!/usr/bin/env bash

function aws::ecs::arn_regex() {
  echo "arn:.*:ecs:"
}

function aws::ecs::cleanup() {
  local arns=("$@")

  local cluster_arns
  readarray -t cluster_arns < <(printf "%s\n" "${arns[@]}" | grep "^$(aws::ecs::cluster::arn_regex)")

  if [ "${#cluster_arns[@]}" -ne 0 ]; then
    echo "Cleaning up ECS services and clusters..."
    aws::ecs::cluster::delete "${cluster_arns[@]}"
  fi

  local task_def_arns
  readarray -t task_def_arns < <(printf "%s\n" "${arns[@]}" | grep "^$(aws::ecs::task_definition::arn_regex)")

  if [ "${#task_def_arns[@]}" -ne 0 ]; then
    echo "Cleaning up ECS task definitions..."
    aws::ecs::task_definition::delete "${task_def_arns[@]}"
  fi
}

function aws::ecs::cluster::arn_regex() {
  echo "$(aws::ecs::arn_regex).*:cluster/"
}

function aws::ecs::cluster::delete() {
  local cluster_arns=("$@")

  for cluster_arn in "${cluster_arns[@]}"; do
    aws::ecs::cluster::_delete "${cluster_arn}"
  done
}

function aws::ecs::cluster::_delete() {
  local cluster_arn=$1
  local cluster_name
  cluster_name=$(echo "${cluster_arn}" | awk -F/ '{print $NF}')
  echo "Deleting ECS cluster: ${cluster_name}"

  local cluster_region
  cluster_region=$(aws::extract_region_from_arn "${cluster_arn}")

  # Delete services in cluster first
  local services
  services=$(aws ecs list-services --cluster "${cluster_name}" --region "${cluster_region}" --query 'serviceArns[]' --output text || echo "")
  for service in ${services}; do
    aws ecs delete-service --cluster "${cluster_name}" --service "${service}" --force --region "${cluster_region}" || echo "Failed to delete service"
  done

  # Then delete cluster
  aws ecs delete-cluster --cluster "${cluster_name}" --region "${cluster_region}" || echo "Failed to delete cluster"
}

function aws::ecs::task_definition::arn_regex() {
  echo "$(aws::ecs::arn_regex).*:task-definition/"
}

function aws::ecs::task_definition::delete() {
  local task_def_arns=("$@")

  for task_def_arn in "${task_def_arns[@]}"; do
    aws::ecs::task_definition::_delete "${task_def_arn}"
  done
}

function aws::ecs::task_definition::_delete() {
  local task_def_arn=$1
  local task_region
  task_region=$(aws::extract_region_from_arn "${task_def_arn}")

  # Check current status
  local status
  status=$(aws ecs describe-task-definition --region "${task_region}" --task-definition "${task_def_arn}" --query 'taskDefinition.status' --output text 2>/dev/null || echo "")

  if [ "${status}" = "DELETE_IN_PROGRESS" ]; then
    echo "Task definition already being deleted: ${task_def_arn}"
    return 0
  fi

  if [ "${status}" = "ACTIVE" ]; then
    echo "Deregistering task definition: ${task_def_arn}"
    aws ecs deregister-task-definition --region "${task_region}" --task-definition "${task_def_arn}" || echo "Failed to deregister ${task_def_arn}"
    sleep 2
  elif [ "${status}" = "INACTIVE" ]; then
    echo "Task definition already inactive: ${task_def_arn}"
  fi

  # Delete the task definition (works for INACTIVE status)
  if [ "${status}" = "ACTIVE" ] || [ "${status}" = "INACTIVE" ]; then
    echo "Deleting task definition: ${task_def_arn}"
    aws ecs delete-task-definitions --region "${task_region}" --task-definitions "${task_def_arn}" || echo "Failed to delete ${task_def_arn}"
  fi
}
