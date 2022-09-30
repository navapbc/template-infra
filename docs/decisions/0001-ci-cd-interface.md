# CI/CD Interface

* Status: proposed
* Deciders: @lorenyu @kyeah <!-- optional -->
* Date: [YYYY-MM-DD when the decision was last updated] <!-- optional -->

Technical Story: Define Makefile interface between infra and application [#105](https://github.com/navapbc/template-infra/issues/105)

## Context and Problem Statement

In order to reuse CI and CD logic for different tech stacks, we need to establish a consistent interface by which different applications can hook into the common CI/CD infrastructure.

## Proposal

### CD interface

Create a `Makefile` in `template-infra` repo that defines the following make targets:

```makefile
###################
# Building and deploying
##################

# Generate an informational tag so we can see where every image comes from.
release-build: # assumes there is a Dockerfile in `app` folder
  ... code that builds image from app/Dockerfile

release-publish:
  ... code that publishes to ecr

release-deploy:
  ... code that restarts ecs service with new image
```

Each of the template applications (template-application-nextjs, template-application-flask) needs to have a `Dockerfile` in `app/` e.g. `template-application-flask/app/Dockerfile`. The Dockerfile needs to have a named stage called `release` e.g.

```Dockerfile
# template-application-flask/app/Dockerfile
...
FROM scratch AS release
...
```

### CI interface

Each application will have their own CI workflow that gets copied into the project's workflows folder as part of installation. `template-application-nextjs` and `template-application-flask` will have `.github/workflows/ci-app.yml`, and `template-infra` will have `.github/workflows/ci-infra.yml`.

Installation would look something like:

```bash
cp template-infra/.github/workflows/* .github/workflows/
cp template-application-nextjs/.github/workflows/* .github/workflows/
```

CI in `template-application-next` might be something like:

```yml
# template-application-nextjs/.github/workflows/ci-app.yml

jobs:
  lint:
    steps:
      - run: npm run lint
  type-check:
    steps:
      - run: npm run type-check
  test:
    steps:
      - run: npm test
```

CI in `template-application-flask` might be something like:

```yml
# template-application-nextjs/.github/workflows/ci-app.yml

jobs:
  lint:
    steps:
      - run: poetry run black
  type-check:
    steps:
      - run: poetry run mypy
  test:
    steps:
      - run: poetry run pytest
```

For now we are assuming there's only one deployable application service per repo, but we could evolve this architecture to have the project rename `app` as part of the installation process to something specific like `api` or `web`, and rename `ci-app.yml` appropriately to `ci-api.yml` or `ci-web.yml`, which would allow for multiple application folders to co-exist.

## Decision Outcome

Chosen option: "[option 1]", because [justification. e.g., only option, which meets k.o. criterion decision driver | which resolves force force | … | comes out best (see below)].

### Positive Consequences <!-- optional -->

* [e.g., improvement of quality attribute satisfaction, follow-up decisions required, …]
* …

### Negative Consequences <!-- optional -->

* [e.g., compromising quality attribute, follow-up decisions required, …]
* …

## Pros and Cons of the Options
