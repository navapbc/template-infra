#!/bin/bash
#
# Given a user, this script updates the password for that user in a postgres database
# If an existing Secrets Manager secret is specified, it will use the value of
# that secret as the password. Otherwise, it will create a new secret in Secrets Manager
# and use that secret as the password.
#

set -euo pipefail

# Note the use of heredoc in the psql command. This is to run multiple queries with the same invocation
# to ensure that queries are run in the same context
psql_cmd() {
  echo
  echo "+" "$1" 1>&2
  psql -v "ON_ERROR_STOP=1" <<EOF
$1
EOF
}

if ! which aws > /dev/null; then
  cat 1>&2 <<EOF
$0 requires you to have the AWS CLI installed and available on your \$PATH as "aws"
EOF
  exit 1
fi

if [ -z "${UPDATE_SECRETS_MANAGER}" ]; then
  # this will error out if secret does not exist, that's intentional
  # the resource will be tainted until a valid secret is provided
  echo "Using existing secret ${SECRET_NAME}"
  USER_PASSWORD=$(aws secretsmanager get-secret-value --secret-id ${SECRET_NAME} --query SecretString --output text)
else
  echo "Creating new secret..."
  USER_PASSWORD=$(aws secretsmanager get-random-password --password-length 16 --exclude-punctuation --query "RandomPassword" --output text)
  echo "Saving password in Secrets Manager as $SECRET_NAME"
  aws secretsmanager update-secret --secret-id $SECRET_NAME --secret-string $USER_PASSWORD
  echo "Password for user $USER has been saved in Secrets Manager." 
fi

HASHED_USER_PASSWORD=$(echo -n "${USER_PASSWORD}${USER}" | md5 | awk '{print "md5" $1}')

psql_cmd "ALTER ROLE $USER WITH PASSWORD '$HASHED_USER_PASSWORD'"
