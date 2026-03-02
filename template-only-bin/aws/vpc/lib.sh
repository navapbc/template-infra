#!/usr/bin/env bash

function aws::vpc::cleanup() {
  local arns=("$@")

  # Security Groups need to be deleted before the associated VPC can be deleted
  local security_group_arns
  readarray -t security_group_arns < <(printf "%s\n" "${arns[@]}" | grep '^arn:aws:ec2:.*:security-group/')

  if [ "${#security_group_arns[@]}" -ne 0 ]; then
    echo "Cleaning up Security Groups..."
    aws::vpc::security_group::delete "${security_group_arns[@]}"
  fi

  # Subnets need to be deleted before the associated VPC can be deleted
  local subnet_arns
  readarray -t subnet_arns < <(printf "%s\n" "${arns[@]}" | grep '^arn:aws:ec2:.*:subnet/')

  if [ "${#subnet_arns[@]}" -ne 0 ]; then
    echo "Cleaning up Subnets..."
    aws::vpc::subnet::delete "${subnet_arns[@]}"
  fi

  # Internet Gateways need to be deleted before the associated VPC can be deleted
  local igw_arns
  readarray -t igw_arns < <(printf "%s\n" "${arns[@]}" | grep '^arn:aws:ec2:.*:internet-gateway/')

  if [ "${#igw_arns[@]}" -ne 0 ]; then
    echo "Cleaning up Internet Gateways..."
    aws::vpc::igw::delete "${igw_arns[@]}"
  fi

  local vpc_arns
  readarray -t vpc_arns < <(printf "%s\n" "${arns[@]}" | grep '^arn:aws:ec2:.*:vpc/')

  if [ "${#vpc_arns[@]}" -ne 0 ]; then
    echo "Cleaning up VPCs..."
    aws::vpc::delete "${vpc_arns[@]}"
  fi
}

function aws::vpc::security_group::delete() {
  local security_group_arns=("$@")

  for security_group_arn in "${security_group_arns[@]}"; do
    local security_group_id
    security_group_id=$(echo "${security_group_arn}" | awk -F'/' '{print $NF}')

    local security_group_region
    security_group_region=$(aws::extract_region_from_arn "${security_group_arn}")

    # Check if this is a default security group, which we can't delete
    # separately, will be removed with the VPC itself
    local security_group_description
    security_group_description=$(aws ec2 describe-security-groups --group-ids "${security_group_id}" --region "${security_group_region}" --query='SecurityGroups[0].Description' --output text 2>&1)
    if [[ "${security_group_description}" = "default VPC security group" ]]; then
      echo "Default security group, can't delete individually: ${security_group_id}"
      continue
    fi

    if [[ "${security_group_description}" = *InvalidGroup.NotFound* ]]; then
      echo "Security group not found/already queued for deletion: ${security_group_id}"
      continue
    fi

    echo "Deleting Security Group: ${security_group_id}"
    aws ec2 delete-security-group --group-id "${security_group_id}" --region "${security_group_region}" || echo "Failed to delete Security Group ${security_group_id}"
  done
}

function aws::vpc::subnet::delete() {
  local subnet_arns=("$@")

  for subnet_arn in "${subnet_arns[@]}"; do
    local subnet_id
    subnet_id=$(echo "${subnet_arn}" | awk -F'/' '{print $NF}')

    local subnet_region
    subnet_region=$(aws::extract_region_from_arn "${subnet_arn}")

    echo "Deleting Subnet: ${subnet_id}"
    aws ec2 delete-subnet --subnet-id "${subnet_id}" --region "${subnet_region}" || echo "Failed to delete Subnet ${subnet_id}"

    # Give it a second to delete before proceeding
    sleep 1
  done

}

function aws::vpc::igw::delete() {
  local igw_arns=("$@")

  for igw_arn in "${igw_arns[@]}"; do
    local igw_id
    igw_id=$(echo "${igw_arn}" | awk -F'/' '{print $NF}')

    local igw_region
    igw_region=$(aws::extract_region_from_arn "${igw_arn}")

    # Need to detach the gateway before deleting
    igw_vpc_ids=$(aws ec2 describe-internet-gateways --internet-gateway-ids "${igw_id}" --region "${igw_region}" --query 'InternetGateways[0].Attachments[*].VpcId' --output text | tr '\t' '\n')
    for igw_vpc_id in ${igw_vpc_ids}; do
      echo "Detaching Internet Gateway ${igw_id} from VPC ${igw_vpc_id}"
      aws ec2 detach-internet-gateway --internet-gateway-id "${igw_id}" --vpc-id "${igw_vpc_id}" --region "${igw_region}" || echo "Failed to detach Internet Gateway ${igw_id}"
    done

    echo "Deleting Internet Gateway: ${igw_id}"
    aws ec2 delete-internet-gateway --internet-gateway-id "${igw_id}" --region "${igw_region}" || echo "Failed to delete Internet Gateway ${igw_id}"

    # Give it a second to delete before proceeding
    sleep 1
  done
}

function aws::vpc::delete() {
  local vpc_arns=("$@")

  for vpc_arn in "${vpc_arns[@]}"; do
    local vpc_id
    vpc_id=$(echo "${vpc_arn}" | awk -F'/' '{print $NF}')

    local vpc_region
    vpc_region=$(aws::extract_region_from_arn "${vpc_arn}")

    echo "Deleting VPC: ${vpc_id}"
    aws ec2 delete-vpc --vpc-id "${vpc_id}" --region "${vpc_region}" || echo "Failed to delete VPC ${vpc_id}"
  done
}
