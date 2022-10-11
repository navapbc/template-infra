# PROJECT_NAME defaults to name of the current directory.
PROJECT_NAME := $(notdir $(PWD))

# For now only support a single app in the folder `app/` within the repo
# In the future, support multiple apps, and which app is being operated
# on will be determined by the APP_NAME Makefile argument
APP_NAME := app

.PHONY : \
	infra-lint \
	infra-format \
	release-build \
	release-publish \
	release-deploy \
	image-registry-login \
	db-migrate \
	db-migrate-down \
	db-migrate-create

infra-check-compliance: infra-check-compliance-checkov infra-check-compliance-tfsec

infra-check-compliance-checkov:
	checkov --directory infra

infra-check-compliance-tfsec:
	tfsec infra

infra-lint:
	terraform fmt -recursive -check infra

infra-format:
	terraform fmt -recursive infra

########################
## Release Management ##
########################

IMAGE_NAME := $(PROJECT_NAME)-$(APP_NAME)

GIT_REPO_AVAILABLE := $(shell git rev-parse --is-inside-work-tree 2>/dev/null)

# Generate a unique tag based solely on the git hash.
# This will be the identifier used for deployment via terraform.
ifdef GIT_REPO_AVAILABLE
IMAGE_TAG := $(shell git rev-parse HEAD)
else
IMAGE_TAG := "unknown-dev.$(DATE)"
endif

# Generate an informational tag so we can see where every image comes from.
DATE := $(shell date -u '+%Y%m%d.%H%M%S')
INFO_TAG := $(DATE).$(USER)

release-build:
	cd $(APP_NAME) && $(MAKE) release-build \
		OPTS="--tag $(IMAGE_NAME):latest --tag $(IMAGE_NAME):$(IMAGE_TAG)"

release-publish:

release-deploy:
