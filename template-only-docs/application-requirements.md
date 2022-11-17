# Application Requirements

In order to use the template infrastructure, you need an application in a folder that lives in the project root folder e.g. `/app`. The application folder needs to have a `Makefile` that has a build target `release-build` that takes in a Makefile variable `OPTS`, and passes those `OPTS` as options to the `docker build` command. The top level [Makefile](./Makefile) in this repo will call the application's `release-build` make target passing in release tags to tag the docker image with.

## Example Application

The infra template includes an example "hello, world" application that works with the template. This application is fully deployed and can be viewed at the endpoint <http://platform-test-app-dev-751272791.us-east-1.elb.amazonaws.com/>. The source code for this test application is at <https://github.com/navapbc/platform-test>.

## Template Applications

You can the following template applications with the template infrastructure

* [template-application-nextjs](https://github.com/navapbc/template-application-nextjs)
* [template-application-flask](https://github.com/navapbc/template-application-flask)
