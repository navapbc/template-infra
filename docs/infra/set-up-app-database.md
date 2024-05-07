# Set up database

Follow these instructions for **each application** (you can have one or more in your project) and **each environment** in your project. If the application does not need a database, skip to the bottom of this document.

The database setup process will:

1. Configure and deploy an application database cluster using [Amazon Aurora Serverless V2](https://aws.amazon.com/rds/aurora/serverless/)
2. Create a [PostgreSQL schema](https://www.postgresql.org/docs/current/ddl-schemas.html) `app` to contain tables used by the application
3. Create an IAM policy that allows IAM roles with that policy attached to [connect to the database using IAM authentication](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/UsingWithRDS.IAMDBAuth.Connecting.html)
4. Create an [AWS Lambda function](https://docs.aws.amazon.com/lambda/latest/dg/welcome.html), the "role manager", for provisioning the [PostgreSQL database users](https://www.postgresql.org/docs/8.0/user-manag.html) that will be used by the application service and by the migrations task
5. Invoke the role manager function to create the `app` and `migrator` Postgres users

## Prerequisites

* You'll need to have [set up the AWS account(s)](./set-up-aws-accounts.md)
* You'll need to have [configured the application](/infra/app/app-config/main.tf)
* You'll need to have [set up the network(s)](./set-up-networks.md)
* You'll need to have [pip](https://pypi.org/project/pip/) installed (pip is needed to download dependencies for the role manager Lambda function)

## Instructions

### 1. Make sure you're authenticated into the AWS account where you want to deploy this environment

This set up takes effect in whatever account you're authenticated into. To see which account that is, run

```bash
aws sts get-caller-identity
```

To see a more human readable account alias instead of the account, run

```bash
aws iam list-account-aliases
```

### 2. Configure backend

To create the tfbackend file for the new application environment, run

```bash
make infra-configure-app-database APP_NAME=<APP_NAME> ENVIRONMENT=<ENVIRONMENT>
```

`APP_NAME` needs to be the name of the application folder within the `infra` folder.

`ENVIRONMENT` needs to be the name of the environment to update. This will create a file called `<ENVIRONMENT>.s3.tfbackend` in the `infra/<APP_NAME>/database` module directory.

### 3. Create database resources

Now run the following commands to create the resources. Review the Terraform before confirming "yes" to apply the changes. This can take over 5 minutes.

```bash
make infra-update-app-database APP_NAME=<APP_NAME> ENVIRONMENT=<ENVIRONMENT>
```

### 4. Create Postgres users

Trigger the role manager Lambda function that was created in the previous step in order to create the application and migrator Postgres users.

```bash
make infra-update-app-database-roles APP_NAME=<APP_NAME> ENVIRONMENT=<ENVIRONMENT>
```

The Lambda function's response should describe the resulting PostgreSQL roles and groups that are configured in the database. It should look like a minified version of the following:

```json
{
  "roles": [
    "postgres",
    "migrator",
    "app"
  ],
  "roles_with_groups": {
    "rds_superuser": "rds_password",
    "pg_monitor": "pg_read_all_settings,pg_read_all_stats,pg_stat_scan_tables",
    "postgres": "rds_superuser",
    "app": "rds_iam",
    "migrator": "rds_iam"
  },
  "schema_privileges": {
    "public": "{postgres=UC/postgres,=UC/postgres}",
    "app": "{migrator=UC/migrator,app=U/migrator}"
  }
}
```

#### Important note on Postgres table permissions

Before creating migrations that create tables, first create a migration that includes the following SQL command (or equivalent if your migrations are written in a general purpose programming language):

```sql
ALTER DEFAULT PRIVILEGES GRANT ALL ON TABLES TO app
```

This will cause all future tables created by the `migrator` user to automatically be accessible by the `app` user. See the [Postgres docs on ALTER DEFAULT PRIVILEGES](https://www.postgresql.org/docs/current/sql-alterdefaultprivileges.html) for more info. As an example see the example app's migrations file [migrations.sql](https://github.com/navapbc/template-infra/blob/main/app/migrations.sql).

Why is this needed? The reason is because the `migrator` role will be used by the migration task to run database migrations (creating tables, altering tables, etc.), while the `app` role will be used by the web service to access the database. Moreover, in Postgres, new tables won't automatically be accessible by roles other than the creator unless specifically granted, even if those other roles have usage access to the schema that the tables are created in. In other words if the `migrator` user created a new table `foo` in the `app` schema, the `app` user will not have automatically be able to access it by default.

### 5. Check that database roles have been configured properly

```bash
make infra-check-app-database-roles APP_NAME=<APP_NAME> ENVIRONMENT=<ENVIRONMENT>
```

## If the application does not need a database

If the application does not need a database (such as if the project uses an alternative for data persistence), delete the application's database module (e.g. `/infra/<APP_NAME>/database`) and ensure that the application's `app-config` sets `has_database` to `false` (see [set up app config](./set-up-app-config.md)).