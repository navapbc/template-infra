# Application Requirements

In order to use the template infrastructure, you need an application that meets the following requirements.

* The application's source code lives in a folder that lives in the project root folder e.g. `/app`.
* The application folder needs to have a `Makefile` that has a build target `release-build` that takes in a Makefile variable `OPTS`, and passes those `OPTS` as options to the `docker build` command. The top level [Makefile](/Makefile) in this repo will call the application's `release-build` make target passing in release tags to tag the docker image with.
* The web application needs to listen on the port defined by the environment variable `PORT`, rather than hardcode the `PORT`. This allows the infrastructure to configure the application to listen on a container port specified by the infrastructure. See [The Twelve-Factor App](https://12factor.net/) to learn more about designing applications to be portable to different infrastructure environments using environment variables.
* The web application needs to have a health check endpoint `GET /health` that returns an HTTP 200 OK response when the application is healthy and ready to accept requests.
* Provide an executable named `healthcheck` in container's `$PATH` which exits with code `0` if your service is healthy, and non-zero if not healthy (some examples in `/template-only-app/bin/`). Or have `wget`, `curl`, or `bash+grep` available, in which case the application's `/health` endpoint will be pinged for container healthchecks.

## Database Requirements

If your application needs a database, it must also:

* Have a `db-migrate` command available in the container's `$PATH` for running migrations. If you use a migration framework like [Alembic](https://alembic.sqlalchemy.org/) or [Flyway](https://flywaydb.org/) you can create a `db-migrate` script that then calls your framework's binary.
* Both the application service container and the container running the `db-migrate` script will receive the following environment variables that are needed to [connect to the database using IAM authentication](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/UsingWithRDS.IAMDBAuth.Connecting.html):
  * `DB_HOST` - the hostname to connect to
  * `DB_PORT` - the port that the database is listening on
  * `DB_NAME` - the PostgreSQL database to connect to
  * `DB_USER` - the username to log in as. For the application it will be `app`, and for the database migrations it will be `migrator`
  * `DB_SCHEMA` - the name of the PostgreSQL schema to be used by the application

## Example Application

The infra template includes an example "hello, world" application that works with the template. The source code for this test application is at [template-only-app](/template-only-app).

A live demo of the test application is fully deployed by the <https://github.com/navapbc/platform-test> repo, which is used for testing the infra template. Please check [that repo's README](https://github.com/navapbc/platform-test?tab=readme-ov-file#environment-urls) to locate a URL for seeing the live demo.

## Template Applications

You can use the following template applications with the template infrastructure. Each of these includes a script to generate a working application that works with this infra template.

* [template-application-nextjs](https://github.com/navapbc/template-application-nextjs)
* [template-application-flask](https://github.com/navapbc/template-application-flask)
