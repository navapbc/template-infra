# Set up application environment

## 1. Configure backend

To set up To get started with an environment, copy the backend configuration information created from the relevant account

```bash
cd infra/accounts/account
terraform output -raw tf_state_bucket_name
terraform output -raw tf_locks_table_name
terraform output -raw region
```

Now navigate to the environment module of the application you want to set up (e.g. `infra/app/envs/dev`)

```terraform
# infra/app/envs/dev.tf

backend "s3" {
  bucket         = "<TF_STATE_BUCKET_NAME>"
  key            = "infra/<APP_NAME>/envs/dev.tfstate"
  dynamodb_table = "<TF_LOCKS_TABLE_NAME>"
  region         = "<REGION>"
  encrypt        = "true"
}
```

Then initialize terraform

```bash
terraform init
```

## 2. Create application resources

Now run the following commands to create the resources, making sure to verify the plan very applying.

```bash
terraform plan -out=plan.out
terraform apply plan.out
```
