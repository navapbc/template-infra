# Set up application environment

## Requirements

Before setting up the application's environments you'll need to have:

1. [A compatible application in the app folder](./application-requirements.md)
2. [Set up the application build repository](./set-up-app-build-repository.md)

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

## 2. Build and publish the application to the application build repository

```bash
make release-build
make release-publish
```

## 3. Create application resources with the image tag that was published

Now run the following commands to create the resources, using the image tag that was published from the previous step.

```bash
terraform plan -out=plan.out -var image_tag=<IMAGE_TAG>
terraform apply plan.out
```
