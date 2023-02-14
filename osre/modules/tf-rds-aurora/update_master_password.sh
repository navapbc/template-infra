#!/bin/bash
#
# This script is run after an RDS cluster is provisioned via Terraform.
# This is necessary to prevent database passwords from being persisted
# in Terraform state files.
#
# cluster_id is "${var.vpc_name}-${var.application_name}"
# secret_name is "/mpsm/${var.environment_name}/${var.application_name}/db_master_password"
#

set -euo pipefail

if [ $# -lt 2 ]; then
  cat 1>&2 <<EOF
Usage: $0 <cluster_id> <secret_name>
  - <cluster_id> is the id of the RDS cluster in RDS
  - <secret_name> is the name of the secret in AWS Secrets Manager
  
  Generates a new master password for an RDS cluster and updates it with 
  the new password. The password will then be saved in Secrets Manager.
EOF
  exit 1
fi


if ! which aws > /dev/null; then
  cat 1>&2 <<EOF
$0 requires you to have the AWS CLI installed and available on your \$PATH as "aws"
EOF
  exit 1
fi

CLUSTER_ID=$1
SECRET=$2
set -euo pipefail

echo "Updating master password for RDS cluster - $CLUSTER_ID"

# generate new master password
PASSWORD=$(aws secretsmanager get-random-password --password-length 16 --exclude-punctuation --query "RandomPassword" --output text)

# set master user password for RDS cluster
RESP=$(aws rds modify-db-cluster --db-cluster-identifier $CLUSTER_ID \
  --master-user-password $PASSWORD --apply-immediately)

# store password in Secrets Manager
if [ $? -eq 0 ]; then
  echo "Saving password in Secrets Manager as $SECRET"
  aws secretsmanager update-secret --secret-id $SECRET \
    --secret-string $PASSWORD
  echo "Password has been saved in Secrets Manager."
else
  echo "Failed to update master password for RDS cluster - $CLUSTER_ID."
  echo "Try again or update the master password manually."
fi
