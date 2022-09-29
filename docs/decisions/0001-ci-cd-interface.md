# CI/CD Interface

* Status: proposed
* Deciders: [list everyone involved in the decision] <!-- optional -->
* Date: [YYYY-MM-DD when the decision was last updated] <!-- optional -->

Technical Story: Define Makefile interface between infra and application [#105](https://github.com/navapbc/template-infra/issues/105)

## Context and Problem Statement

In order to reuse CI and CD logic for different tech stacks, we need to establish a consistent interface by which different applications can hook into the common CI/CD infrastructure.

## Proposal

Create a `Makefile` in `template-infra` repo that defines the following make targets:

```makefile
############
# Validation
############

check: check-static test
check-static: lint type-check

lint: # add application specific test commands here e.g. cd app && $(MAKE) lint

type-check: # add application specific test commands here e.g. cd app && $(MAKE) type-check

test: # add application specific test commands here e.g. cd app && $(MAKE) test

###################
# Building and deploying
##################

# Generate an informational tag so we can see where every image comes from.
DATE := $(shell date -u '+%Y%m%d.%H%M%S')
INFO_TAG := $(DATE).$(USER)

GIT_REPO_AVAILABLE := $(shell git rev-parse --is-inside-work-tree 2>/dev/null)

# Generate a unique tag based solely on the git hash.
# This will be the identifier used for deployment via terraform.
ifdef GIT_REPO_AVAILABLE
IMAGE_TAG := $(shell git rev-parse HEAD)
else
IMAGE_TAG := "unknown-dev.$(DATE)"
endif

build-image: # assumes there is a Dockerfile in `app` folder
  ... code that builds image from app/Dockerfile

publish-image:
  ... code that publishes to ecr

deploy:
  ... code that restarts ecs service with new image
```

Then each of the template applications (template-application-nextjs, template-application-flask) can define a separate Makefile in `app/` e.g. `template-application-flask/app/Makefile`, and they can define specific implementations of the make targets e.g.

```makefile
# template-application-flask/app/Makefile

test:
  poetry run test

type-check:
  poetry run type-check

lint:
  poetry run lint
```

And for NextJS

```makefile
# template-application-nextjs/app/Makefile

test:
  npm test

type-check:
  npm run type-check

lint:
  npm run lint
```

Alternatively, we can ignore the separate Makefile in each of the application templates, and just hook in directly to poetry/npm in the top level Makefile.

In either case, we could have instructions in each application template that instructs the user to add the appropriate hook into the top level Makefile to call into the application-specific targets. In theory this could also be done via a script:

```bash
# temporarily fetch latest version of application template
git clone --single-branch --branch main --depth 1 git@github.com:navapbc/template-application-flask.git

# install application template
./template-application-flask/scripts/install-template.sh

# clean up temporary folder
rm -fr template-application-flask
```

Where install-template.sh could do something like add the appropriate commands to the top level Makefile.

Reference: [Recursively calling Make](https://www.gnu.org/software/make/manual/make.html#Recursion)

## Decision Outcome

Chosen option: "[option 1]", because [justification. e.g., only option, which meets k.o. criterion decision driver | which resolves force force | … | comes out best (see below)].

### Positive Consequences <!-- optional -->

* [e.g., improvement of quality attribute satisfaction, follow-up decisions required, …]
* …

### Negative Consequences <!-- optional -->

* [e.g., compromising quality attribute, follow-up decisions required, …]
* …

## Pros and Cons of the Options
