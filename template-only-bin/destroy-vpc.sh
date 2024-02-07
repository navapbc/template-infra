#!/bin/bash

# Set the VPC ID as an argument
VPC_ID=$1

if [ -z "$VPC_ID" ]; then
  echo "VPC ID is required"
  exit 1
fi

# Detach and delete all internet gateways associated with the VPC
for igw in $(aws ec2 describe-internet-gateways --filters Name=attachment.vpc-id,Values=$VPC_ID --query 'InternetGateways[*].InternetGatewayId' --output text); do
    aws ec2 detach-internet-gateway --internet-gateway-id $igw --vpc-id $VPC_ID
    aws ec2 delete-internet-gateway --internet-gateway-id $igw
done

# Delete subnets
for subnet in $(aws ec2 describe-subnets --filters Name=vpc-id,Values=$VPC_ID --query 'Subnets[*].SubnetId' --output text); do
    aws ec2 delete-subnet --subnet-id $subnet
done

# Delete custom route tables
for rt in $(aws ec2 describe-route-tables --filters Name=vpc-id,Values=$VPC_ID --query 'RouteTables[?Associations[?Main!=`true`]].RouteTableId' --output text); do
    aws ec2 delete-route-table --route-table-id $rt
done

# Delete security groups (skip the default one)
for sg in $(aws ec2 describe-security-groups --filters Name=vpc-id,Values=$VPC_ID --query 'SecurityGroups[?GroupName!=`default`].GroupId' --output text); do
    aws ec2 delete-security-group --group-id $sg
done

# Delete network ACLs (skip the default one)
for acl in $(aws ec2 describe-network-acls --filters Name=vpc-id,Values=$VPC_ID --query 'NetworkAcls[?IsDefault!=`true`].NetworkAclId' --output text); do
    aws ec2 delete-network-acl --network-acl-id $acl
done

# Delete VPC endpoints
for vpce in $(aws ec2 describe-vpc-endpoints --filters Name=vpc-id,Values=$VPC_ID --query 'VpcEndpoints[*].VpcEndpointId' --output text); do
    aws ec2 delete-vpc-endpoints --vpc-endpoint-ids $vpce
done

# Delete NAT Gateways
for natgw in $(aws ec2 describe-nat-gateways --filter Name=vpc-id,Values=$VPC_ID --query 'NatGateways[*].NatGatewayId' --output text); do
    aws ec2 delete-nat-gateway --nat-gateway-id $natgw
    # Wait for NAT Gateway to be deleted
    aws ec2 wait nat-gateway-available --nat-gateway-ids $natgw
done

# Finally, delete the VPC
aws ec2 delete-vpc --vpc-id $VPC_ID

echo "VPC $VPC_ID and its components have been deleted."
