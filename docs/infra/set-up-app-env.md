# Set up application environment

The application environment setup process will:

1. Create network infrastructure resources (security groups, etc) for the application
2. Create service resources (load balancer, container service) for the application

## Requirements

Before setting up the application's environments you'll need to have:

1. [A compatible application in the app folder](./application-requirements.md)
2. [Set up the application build repository](./set-up-app-build-repository.md)

## 1. Network

### 1.1. Configure backend

To create the tfbackend file for the network using the backend configuration values from your current AWS account, run

```bash
make infra-configure-app-network APP_NAME=app ENVIRONMENT=<ENVIRONMENT>
```

`APP_NAME` needs to be the name of the application folder within the `infra` folder. It defaults to `app`.
`ENVIRONMENT` needs to be the name of the environment you are creating. This will create a file called `<ENVIRONMENT>.s3.tfbackend` in the `infra/app/service` module directory.

### 1.2. Create network resources

Now run the following command to create the resources, making sure to verify the plan before confirming the apply.

```bash
make infra-update-app-network APP_NAME=app ENVIRONMENT=<ENVIRONMENT>
```

## 2. Application Service

### 2.1. Configure backend

To create the tfbackend file for the new application environment, run

```bash
make infra-configure-app-service APP_NAME=app ENVIRONMENT=<ENVIRONMENT>
```

`APP_NAME` needs to be the name of the application folder within the `infra` folder. It defaults to `app`.
`ENVIRONMENT` needs to be the name of the environment you are creating. This will create a file called `<ENVIRONMENT>.s3.tfbackend` in the `infra/app/service` module directory.

### 2.2. Build and publish the application to the application build repository

Before creating the application resources, you'll need to first build and publish at least one image to the application build repository. Do that by running

```bash
make release-build
make release-publish
```

### 2.3. Create application resources with the image tag that was published

Now run the following commands to create the resources, using the image tag that was published from the previous step. Review the terraform before confirming "yes" to apply the changes.

```bash
TF_CLI_ARGS_apply="-var=image_tag=<IMAGE_TAG>" make infra-update-app-service APP_NAME=app ENVIRONMENT=<ENVIRONMENT>
```
