#!/usr/bin/env bash

function aws::iam::cleanup() {
  local arns=("$@")

  # Policies are returned via the Resource Groups Tagging API, Roles/Users are
  # not, so get at things via the Policy
  local iam_policy_arns
  readarray -t iam_policy_arns < <(printf "%s\n" "${arns[@]}" | grep '^arn:aws:iam:.*:policy/')

  if [ "${#iam_policy_arns[@]}" -ne 0 ]; then
    echo "Cleaning up IAM..."

    # Track the roles the project policies are attached to for later deletion
    # without having to loop through _all_ roles in the account, may do this
    # different in the future
    iam_role_names=()

    for iam_policy_arn in "${iam_policy_arns[@]}"; do
      local attached_role_names
      attached_role_names=$(aws iam list-entities-for-policy --policy-arn "${iam_policy_arn}" --entity-filter Role --query 'PolicyRoles[*].RoleName' --output text | tr '\t' '\n')

      for role_name in ${attached_role_names}; do
        iam_role_names+=("${role_name}")
        echo "Detaching policy from IAM Role: ${role_name}"
        aws iam detach-role-policy --policy-arn "${iam_policy_arn}" --role-name "${role_name}" || echo "Failed to detach IAM policy from role: ${iam_policy_arn} from ${role_name}"
      done

      echo "Deleting IAM Policy: ${iam_policy_arn}"
      aws iam delete-policy --policy-arn "${iam_policy_arn}" || echo "Failed to delete IAM Policy ${iam_policy_arn}"
    done

    readarray -t unique_iam_role_names < <(printf "%s\n" "${iam_role_names[@]}" | sort -u)
    aws::iam::role::delete_by_name "${unique_iam_role_names[@]}"

    # for role_name in ${unique_iam_role_names}; do
    #   # TODO: do we actually care to do this?
    #   # # confirm the role is indeed for the project
    #   # role_project_tag=$(aws iam list-role-tags \
    #   #   --role-name "${role_name}" \
    #   #   --query "tags[?key=='project'].value" \
    #   #   --output text 2>/dev/null || echo "")

    #   # if [[ "${role_project_tag}" == "${project}" ]]; then
    #   #   echo "Deleting IAM Role: ${role_name}"
    #   #   delete-iam-role "${role_name}" || echo "Failed to delete IAM Role ${role_name}"
    #   # fi
    # done
  fi
}

function aws::iam::role::delete_by_name() {
  local role_names=("$@")

  for role_name in "${role_names[@]}"; do
    echo "Deleting IAM Role: ${role_name}"

    attached_policy_arns=$(aws iam list-attached-role-policies --role-name "${role_name}" --query 'AttachedPolicies[*].PolicyArn' --output text)

    for attached_policy_arn in ${attached_policy_arns}; do
      aws iam detach-role-policy --role-name "${role_name}" --policy-arn "${attached_policy_arn}"
    done

    inline_policy_names=$(aws iam list-role-policies --role-name "${role_name}" --query 'PolicyNames[*]' --output text)

    for inline_policy_name in ${inline_policy_names}; do
      aws iam delete-role-policy --role-name "${role_name}" --policy-name "${inline_policy_name}"
    done

    aws iam delete-role --role-name "${role_name}" || echo "Failed to delete IAM Role ${role_name}"
  done
}
