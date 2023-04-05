# Notes

For creating accounts, can't use the .tfbackend backend config file approach because the main.tf file can only have one backend configuration, so if we have the backend configuration as a partial configuration of `backend "s3" {}`, then we can't use that same module to configure a new account, since the process for configuring a new account
requires setting the backend configuration to `backend "local" {}`. We could have a separate duplicate module that's has backend set to local. or we could also temporarily update the backend from `"s3"` to `"local"`, but both of those approaches seem confusing.

Another alternative is to go back to the old way of bootstrapping an account i.e. to do it via a script that creates an S3 bucket via AWS CLI. The bootstrap script would only do the minimal configuration for the S3 bucket, and let terraform handle the remainder of the configuration, such as creating the dynamodb tables. At this point, there is no risk of not having state locking in place since the account infrastructure has not yet been checked into the repository. This might be the cleanest way to have accounts follow the same pattern of using tfbackend config files.

## Benefits of separate tfvars and tfbackend files

Makes updating the template more robust. Currently updating the template involves copying over template files but reverting files that projects are expected to change. With the separation of config files, projects are no longer expected to change the main.tf files, so we can safely update the main.tf files in `infra/app/build-repository/`, `infra/project-config/`, `infra/app/app-config/`, etc.

With the previous approach we would need two additional folders for the database layer: a `db-env-template` module and a `db-envs` folder with separate root modules for each environment. With separate backend config and tfvar files we only need a single `db` module with separate `.tfbackend` and `.tfvars` files for each environment.
