# Set up application

To application setup process will:

1. Create infrastructure resources needed to store built release candidate artifacts used to deploy the application to an environment.
2. Create one or more application environmnets for running the application.

## Set up application deployment process

Navigate to the `build-repository` module of the application you want to set up (e.g. `infra/app/build-repository`)

Update the backend configration to use the S3 backend for production. Then run the following commands to create the resources, making sure to verify the plan very applying.

```bash
cd infra/app/build-repository
terraform init
terraform plan -out=plan.out
terraform apply plan.out
```

## Set up application environments

Once you set up the deployment process, you can proceed to [set up application environments](./set-up-app-env.md)
