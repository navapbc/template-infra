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

A very simple `docker-compose.yml` has been included to support local development and deployment. Take a look at `./docker-compose.yml` for more information.

How to run:

1. In your terminal, `cd` to this repo.
2. Make sure you have [Docker Desktop](https://www.docker.com/products/docker-desktop/) installed & running.
3. Run `docker-compose up -d --build` to build the image and start the container.
4. Navigate to `localhost:3000` in your browser to view the application.
5. Run `docker-compose down` when you are done to delete the container.
