# tf-postgresql-admin

This module provides a consistent baseline for setting up roles, privileges and extensions in all MPSE postgres databases.

To use this module, you must already have a postgres database provisioned:
- Create a new RDS Postgres instance or cluster using the `tf-rds` or `tf-rds-aurora` modules
- Ensure that the master password for the database has been updated. You will need the master password to use this module.

First define a provider resource to establish a connection to your database:

```
provider "postgresql" {
  scheme    = "awspostgres"
  host      = local.db_host
  username  = "osre" <-- master username
  port      = 5432
  password  = var.db_master_password <-- master user password
  superuser = false
}
```

Notice we specify a variable in order to pass in the master user password.

**Do not reference secret strings from AWS Secrets Manager directly. Doing so will persist the secret string in plaintext in the Terraform state file.**

Next, create the module:

```
module "postges_mgt" {
  source = "../../../modules/tf-postgresql-admin/terraform"

  environment_name   = var.environment_name
  aws_region         = var.aws_region
  admin_user         = "osre"
  db_host            = local.db_host
  pg_password        = var.db_master_password
  db_name            = "osre"
  secret_namespace   = "/mpsm/${var.environment_name}/mpsmcd-2542"
  create_dmod_user   = true
  create_nessus_user = true

  db_users = {
    new_role = {
      name  = "new_role"
    }
    new_role_with_login = {
      name  = "new_role_with_login"
      login = true
      roles = ["readonly", "rds_iam"]
    }
  }
}
```

The `db_user` map provides the ability to dynamically add new roles/users to the database.

When applying changes for the first time, it is possible to run into race conditions for the setup of privileges. When such cases are encountered, try re-applying. It should only take about two tries to get a successful apply.


## Requirements

| Name       | Version |
| ---------- | ------- |
| postgresql | 1.16.0  |

## Providers

| Name       | Version |
| ---------- | ------- |
| postgresql | 1.16.0  |

## Modules

| Name        | Source  | Version |
| ----------- | ------- | ------- |
| base\_roles | ./roles | n/a     |
| roles       | ./roles | n/a     |

## Resources

| Name                                                                                                                                                                                                     | Type     |
| -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- |
| [postgresql_default_privileges.def_privs_flyway_user_schema_public_sel_in_up_del_tables_readwrite](https://registry.terraform.io/providers/cyrilgdn/postgresql/1.16.0/docs/resources/default_privileges) | resource |
| [postgresql_default_privileges.def_privs_flyway_user_schema_public_select_tables_readonly](https://registry.terraform.io/providers/cyrilgdn/postgresql/1.16.0/docs/resources/default_privileges)         | resource |
| [postgresql_default_privileges.def_privs_flyway_user_schema_public_usage_seqs_readwrite](https://registry.terraform.io/providers/cyrilgdn/postgresql/1.16.0/docs/resources/default_privileges)           | resource |
| [postgresql_default_privileges.def_privs_readwrite_schema_public_select_tables_readonly](https://registry.terraform.io/providers/cyrilgdn/postgresql/1.16.0/docs/resources/default_privileges)           | resource |
| [postgresql_default_privileges.def_privs_schema_public_sel_in_up_del_tables_db_admin](https://registry.terraform.io/providers/cyrilgdn/postgresql/1.16.0/docs/resources/default_privileges)              | resource |
| [postgresql_default_privileges.def_privs_schema_public_sel_in_up_del_tables_readwrite](https://registry.terraform.io/providers/cyrilgdn/postgresql/1.16.0/docs/resources/default_privileges)             | resource |
| [postgresql_default_privileges.def_privs_schema_public_select_tables_readonly](https://registry.terraform.io/providers/cyrilgdn/postgresql/1.16.0/docs/resources/default_privileges)                     | resource |
| [postgresql_default_privileges.def_privs_schema_public_usage_seqs_db_admin](https://registry.terraform.io/providers/cyrilgdn/postgresql/1.16.0/docs/resources/default_privileges)                        | resource |
| [postgresql_default_privileges.def_privs_schema_public_usage_seqs_readwrite](https://registry.terraform.io/providers/cyrilgdn/postgresql/1.16.0/docs/resources/default_privileges)                       | resource |
| [postgresql_extension.pg_stat_statements](https://registry.terraform.io/providers/cyrilgdn/postgresql/1.16.0/docs/resources/extension)                                                                   | resource |
| [postgresql_grant.grant_connect_db_db_admin](https://registry.terraform.io/providers/cyrilgdn/postgresql/1.16.0/docs/resources/grant)                                                                    | resource |
| [postgresql_grant.grant_connect_db_readonly](https://registry.terraform.io/providers/cyrilgdn/postgresql/1.16.0/docs/resources/grant)                                                                    | resource |
| [postgresql_grant.grant_connect_db_readwrite](https://registry.terraform.io/providers/cyrilgdn/postgresql/1.16.0/docs/resources/grant)                                                                   | resource |
| [postgresql_grant.grant_sel_ins_up_del_tables_schema_public_db_admin](https://registry.terraform.io/providers/cyrilgdn/postgresql/1.16.0/docs/resources/grant)                                           | resource |
| [postgresql_grant.grant_sel_ins_up_del_tables_schema_public_readwrite](https://registry.terraform.io/providers/cyrilgdn/postgresql/1.16.0/docs/resources/grant)                                          | resource |
| [postgresql_grant.grant_select_all_tables_schema_public_readonly](https://registry.terraform.io/providers/cyrilgdn/postgresql/1.16.0/docs/resources/grant)                                               | resource |
| [postgresql_grant.grant_usage_all_seqs_schema_public_db_admin](https://registry.terraform.io/providers/cyrilgdn/postgresql/1.16.0/docs/resources/grant)                                                  | resource |
| [postgresql_grant.grant_usage_all_seqs_schema_public_readwrite](https://registry.terraform.io/providers/cyrilgdn/postgresql/1.16.0/docs/resources/grant)                                                 | resource |
| [postgresql_grant.grant_usage_create_schema_public_db_admin](https://registry.terraform.io/providers/cyrilgdn/postgresql/1.16.0/docs/resources/grant)                                                    | resource |
| [postgresql_grant.grant_usage_create_schema_public_readwrite](https://registry.terraform.io/providers/cyrilgdn/postgresql/1.16.0/docs/resources/grant)                                                   | resource |
| [postgresql_grant.grant_usage_schema_public_readonly](https://registry.terraform.io/providers/cyrilgdn/postgresql/1.16.0/docs/resources/grant)                                                           | resource |
| [postgresql_grant.revoke_db_public](https://registry.terraform.io/providers/cyrilgdn/postgresql/1.16.0/docs/resources/grant)                                                                             | resource |
| [postgresql_grant.revoke_public](https://registry.terraform.io/providers/cyrilgdn/postgresql/1.16.0/docs/resources/grant)                                                                                | resource |

## Inputs

| Name                 | Description                                          | Type   | Default | Required |
| -------------------- | ---------------------------------------------------- | ------ | ------- | :------: |
| admin\_user          | Name of the master (admin) user                      | `any`  | n/a     |   yes    |
| aws\_region          | AWS Region                                           | `any`  | n/a     |   yes    |
| create\_dmod\_user   | Whether to create the DMOD user in this database     | `bool` | `false` |    no    |
| create\_nessus\_user | Whether to create the nessusdb user in this database | `bool` | `false` |    no    |
| db\_host             | Database host                                        | `any`  | n/a     |   yes    |
| db\_name             | Database of the RDS instance/cluster                 | `any`  | n/a     |   yes    |
| db\_users            | Map of users to add to the postgres database         | `any`  | `{}`    |    no    |
| environment\_name    | n/a                                                  | `any`  | n/a     |   yes    |
| pg\_password         | Password of the master user                          | `any`  | n/a     |   yes    |
| secret\_namespace    | Secret namespace where new secret will be created    | `any`  | n/a     |   yes    |

## Outputs

No outputs.
