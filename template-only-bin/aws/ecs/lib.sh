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

# Clean up orphaned inactive task definitions
# The Resource Groups Tagging API may not return INACTIVE task definitions,
# and some task definitions may remain if a previous cleanup was interrupted.
# This function scans ECS directly to find any remaining task definitions
# tagged with plt-tst-act-* projects.
function aws::ecs::task_definition::cleanup_inactive() {
  local region=$1
  local project_tag_filter=$2 # can be a glob

  echo "Finding inactive task definitions in ${region}$([ -n "${project_tag_filter}" ] && echo "(filtered to project tag: ${project_tag_filter})")..."

  # TODO: skip the families part? Just `list-task-definitions --status INACTIVE`
  # and paginate?

  # Get all task definition families
  local families
  readarray -t families < <(aws ecs list-task-definition-families \
    --region "${region}" \
    --status ALL \
    --query 'families[]' \
    --output text 2>/dev/null)

  if [ "${#families[@]}" -eq 0 ]; then
    echo "No task definition families found"
    return 0
  fi

  local inactive_count=0
  local checked_families=0
  for family in "${families[@]}"; do
    [ -z "${family}" ] && continue
    checked_families=$((checked_families + 1))

    # Get all inactive task definitions for this family
    local inactive_arns
    readarray -t inactive_arns < <(aws ecs list-task-definitions \
      --region "${region}" \
      --family-prefix "${family}" \
      --status INACTIVE \
      --query 'taskDefinitionArns[]' \
      --output text 2>/dev/null)

    if [ "${#inactive_arns[@]}" -ne 0 ]; then
      for task_arn in "${inactive_arns[@]}"; do
        [ -z "${task_arn}" ] && continue

        # If we have a filter, get the value and skip if the task doesn't match
        if [[ -n "${project_tag_filter}" ]]; then
          local project_tag
          project_tag=$(aws ecs list-tags-for-resource \
            --resource-arn "${task_arn}" \
            --region "${region}" \
            --query "tags[?key=='project'].value" \
            --output text 2>/dev/null || echo "")

          if [[ "${project_tag}" != ${project_tag_filter} ]]; then
            continue
          fi
        fi

        inactive_count=$((inactive_count + 1))
        if [ "${DRY_RUN}" = "true" ]; then
          echo "Would delete inactive task definition: ${task_arn}"
        else
          echo "Deleting inactive task definition: ${task_arn}"
          aws ecs delete-task-definitions \
            --region "${region}" \
            --task-definitions "${task_arn}" 2>/dev/null || echo "Failed to delete ${task_arn}"
        fi
      done
    fi
  done

  echo "Checked ${checked_families} task definition families"
  echo "Found ${inactive_count} inactive task definitions"
}
