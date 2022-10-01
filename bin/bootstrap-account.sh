#!/bin/bash
set -euxo pipefail

# PROJECT_NAME defaults to name of the current directory.
PROJECT_NAME=$(basename $(PWD))

cd infra/bootstrap/account

cat main.tf \
  | sed "s/<PROJECT_NAME>/$PROJECT_NAME/" \
  > tmp.tf
mv tmp.tf main.tf

terraform init

terraform apply -auto-approve

TF_STATE_BUCKET_NAME=$(terraform output -raw tf_state_bucket_name)
TF_LOCKS_TABLE_NAME=$(terraform output -raw tf_locks_table_name)

cat main.tf \
  | sed "s/<TF_STATE_BUCKET_NAME>/$TF_STATE_BUCKET_NAME/" \
  | sed "s/<TF_LOCKS_TABLE_NAME>/$TF_LOCKS_TABLE_NAME/" \
  | sed 's/#uncomment# //g' \
  > tmp.tf
mv tmp.tf main.tf

terraform init -force-copy
