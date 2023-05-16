# Application Requirements

In order to use the template infrastructure, you need an application that meets the following requirements.

* The application's source code lives in a folder that lives in the project root folder e.g. `/app`.
* The application folder needs to have a `Makefile` that has a build target `release-build` that takes in a Makefile variable `OPTS`, and passes those `OPTS` as options to the `docker build` command. The top level [Makefile](./Makefile) in this repo will call the application's `release-build` make target passing in release tags to tag the docker image with.
* The web application needs to listen on the port defined by the environment variable `PORT`, rather than hardcode the `PORT`. This allows the infrastructure to configure the application to listen on a container port specified by the infrastructure. See [The Twelve-Factor App](https://12factor.net/) to learn more about designing applications to be portable to different infrastructure environments using environment variables.
* The web application needs to have a health check endpoint at `/health` that returns an HTTP 200 OK response when the application is healthy and ready to accept requests.

## Example Application

The infra template includes an example "hello, world" application that works with the template. This application is fully deployed and can be viewed at the endpoint <http://app-dev-2068097977.us-east-1.elb.amazonaws.com/>. The source code for this test application is at <https://github.com/navapbc/platform-test>.

## Template Applications

You can the following template applications with the template infrastructure

* [template-application-nextjs](https://github.com/navapbc/template-application-nextjs)
* [template-application-flask](https://github.com/navapbc/template-application-flask)
