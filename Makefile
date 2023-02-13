# PROJECT_NAME defaults to name of the current directory.
PROJECT_NAME ?= $(notdir $(PWD))

# For now only support a single app in the folder `app/` within the repo
# In the future, support multiple apps, and which app is being operated
# on will be determined by the APP_NAME Makefile argument
APP_NAME ?= app

# Get the list of reusable terraform modules by getting out all the modules
# in infra/modules and then stripping out the "infra/modules/" prefix
MODULES := $(notdir $(wildcard infra/modules/*))

# Get the list of accounts and environments in a manner similar to MODULES above
ACCOUNTS := $(notdir $(wildcard infra/accounts/*))
ENVIRONMENTS := $(notdir $(wildcard infra/app/envs/*))


.PHONY : \
	infra-validate-modules \
	infra-validate-env-template \
	infra-check-compliance \
	infra-check-compliance-checkov \
	infra-check-compliance-tfsec \
	infra-lint \
	infra-format \
	release-build \
	release-publish \
	release-deploy \
	image-registry-login \
	db-migrate \
	db-migrate-down \
	db-migrate-create

# Validate all infra root and child modules.
infra-validate: \
	infra-validate-modules \
	# !! Uncomment the following line once you've set up the infra/project-config module
	# infra-validate-env-template

# Validate all infra root and child modules.
# Validate all infra reusable child modules. The prerequisite for this rule is obtained by
# prefixing each module with the string "infra-validate-module-"
infra-validate-modules: $(patsubst %, infra-validate-module-%, $(MODULES))

infra-validate-module-%:
	@echo "Validate library module: $*"
	terraform -chdir=infra/modules/$* init -backend=false
	terraform -chdir=infra/modules/$* validate

infra-validate-env-template:
	@echo "Validate module: env-template"
	terraform -chdir=infra/app/env-template init -backend=false
	terraform -chdir=infra/app/env-template validate

infra-check-compliance: infra-check-compliance-checkov infra-check-compliance-tfsec

infra-check-compliance-checkov:
	checkov --directory infra

infra-check-compliance-tfsec:
	tfsec infra

infra-lint:
	terraform fmt -recursive -check infra

infra-format:
	terraform fmt -recursive infra

infra-test:
	cd infra/test && go test -v -timeout 30m

########################
## Release Management ##
########################

# Include project name in image name so that image name
# does not conflict with other images during local development
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
	./bin/publish-release.sh $(APP_NAME) $(IMAGE_NAME) $(IMAGE_TAG)

release-deploy:
# check the varaible against the list of enviroments and suggest one of the correct envs.
ifneq ($(filter $(ENV_NAME),$(ENVIRONMENTS)),)
	./bin/deploy-release.sh $(APP_NAME) $(IMAGE_TAG) $(ENV_NAME)
else
	@echo "Please enter: make release-deploy ENV_NAME=<env_name>. The value for env_name must be one of these: $(ENVIRONMENTS)"
	exit 1
endif

release-image-name: ## Prints the image name of the release image
	@echo $(IMAGE_NAME)

release-image-tag: ## Prints the image tag of the release image
	@echo $(IMAGE_TAG)

########################
## Scripts and Helper ##
########################

help: ## Prints the help documentation and info about each command
	@grep -E '^[/a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
