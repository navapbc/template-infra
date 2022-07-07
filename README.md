# Template repository for a Next.js application

This is a template repository for a Next.js-based application. While this template should be opinionated in some ways in order to reduce setup overhead where possible, it should be application-agnostic, meaning that any type of Next.js application should be able to be created from this template.

## Contents

This template includes setup for:

- `.github`: common GitHub configuration such as an empty PR template and a directory for GitHub workflows
- `app`: setup for the Next.js application should go here
- `docs`: a directory for project documentation
- `infra`: a directory for common infrastructure

## How to Run

The Next.js application is dockerized. Take a look at `./app/Dockerfile` to see how it works.

A `docker-compose.yml` has been included to support local development and deployment. Take a look at `./docker-compose.yml` for more information.

1. In your terminal, `cd` to this repo.
2. Make sure you have [Docker Desktop](https://www.docker.com/products/docker-desktop/) installed & running.
3. Run `docker-compose up -d --build` to build the image and start the container.
4. Navigate to `localhost:3000` in your browser to view the application.
5. Navigate to `localhost:6006` in your browser to view storybook.
6. Run `docker-compose down` when you are done to delete the container.

To support local development, the `docker-compose.yml` does the following:

1. The `nextjs` container runs Next.js in development mode (i.e. `yarn dev`) instead of production mode (i.e. `yarn start`). This allows Next.js to do things like hot reload.
2. It includes a container that runs storybook. Note that storybook takes several seconds to finish building before it's accessible in the browser. Be patient. Check `docker-compose logs storybook` to view storybook's current status and see if it's ready to access.
3. It also includes a container that runs `gulp watch` and recompiles the css files whenever there are changes to any of the sass files. This also takes some time. In your browser, Next.js signals that it has detected a change and is attempting to hot reload by displaying a triangle animation in the bottom right corner of the browser window.

This workflow is pretty slow. There is probably room for improvement here!
