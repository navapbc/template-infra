Specify different environments for the application in this section. This template repo includes three example environments: dev, staging, and prod.

To get started with an environment, copy the backend configuration information created in the "infra/accounts/account" instructions above into the terraform { backend "s3" {} } block to setup the remote backend for the environment. This is where all of the infrastructure for the application will be managed.
