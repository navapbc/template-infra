# Set up application

To application setup process will:

1. Create infrastructure resources needed to store built release candidate artifacts used to deploy the application to an environment.
2. Create one or more application environmnets for running the application.

## Set up application deployment process

### 1. Configure backend

Get the backend configration values for the S3 backend in production. If your prod account is in `infra/accounts/prod`, you would do

```bash
cd infra/accounts/prod
terraform output -raw tf_state_bucket_name
terraform output -raw tf_locks_table_name
terraform output -raw region
```

Now navigate to the `build-repository` module of the application you want to set up (e.g. `infra/app/build-repository`)

```terraform
# infra/app/build-repository/main.tf

backend "s3" {
  bucket         = "<TF_STATE_BUCKET_NAME>"
  key            = "infra/<APP_NAME>/build-repository.tfstate"
  dynamodb_table = "<TF_LOCKS_TABLE_NAME>"
  region         = "<REGION>"
  encrypt        = "true"
}
```

Then initialize terraform

```bash
terraform init
```

### 2. Create build repository resources

Now run the following commands to create the resources, making sure to verify the plan very applying.

```bash
terraform plan -out=plan.out
terraform apply plan.out
```

## Set up application environments

Once you set up the deployment process, you can proceed to [set up application environments](./set-up-app-env.md)
