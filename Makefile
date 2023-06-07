# PROJECT_NAME defaults to name of the current directory.
PROJECT_NAME ?= $(notdir $(PWD))

# For now only support a single app in the folder `app/` within the repo
# In the future, support multiple apps, and which app is being operated
# on will be determined by the APP_NAME Makefile argument
APP_NAME ?= app

# Use `=` instead of `:=` so that we only execute `./bin/current-account-alias.sh` when needed
# See https://www.gnu.org/software/make/manual/html_node/Flavors.html#Flavors
CURRENT_ACCOUNT_ALIAS = `./bin/current-account-alias.sh`

CURRENT_ACCOUNT_ID = $(./bin/current-account-id.sh)

# Get the list of reusable terraform modules by getting out all the modules
# in infra/modules and then stripping out the "infra/modules/" prefix
MODULES := $(notdir $(wildcard infra/modules/*))

# Check that given variables are set and all have non-empty values,
# die with an error otherwise.
#
# Params:
#   1. Variable name(s) to test.
#   2. (optional) Error message to print.
# Based off of https://stackoverflow.com/questions/10858261/how-to-abort-makefile-if-variable-not-set
check_defined = \
	$(strip $(foreach 1,$1, \
        $(call __check_defined,$1,$(strip $(value 2)))))
__check_defined = \
	$(if $(value $1),, \
		$(error Undefined $1$(if $2, ($2))$(if $(value @), \
			required by target `$@')))


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

infra-set-up-account:  # Set up the AWS account for the first time
	@:$(call check_defined, ACCOUNT_NAME, human readable name for account e.g. "prod" or the AWS account alias)
	./bin/set-up-current-account.sh $(ACCOUNT_NAME)

infra-configure-app-build-repository:
	./bin/configure-app-build-repository.sh $(APP_NAME)

infra-configure-app-database:
	# APP_NAME has a default value defined above, but check anyways in case the default is ever removed
	@:$(call check_defined, APP_NAME, the name of subdirectory of /infra that holds the application's infrastructure code)
	@:$(call check_defined, ENVIRONMENT, the name of the application environment e.g. "prod" or "staging")
	./bin/configure-app-database.sh $(APP_NAME) $(ENVIRONMENT)

infra-configure-app-service:
	# APP_NAME has a default value defined above, but check anyways in case the default is ever removed
	@:$(call check_defined, APP_NAME, the name of subdirectory of /infra that holds the application's infrastructure code)
	@:$(call check_defined, ENVIRONMENT, the name of the application environment e.g. "prod" or "staging")
	./bin/configure-app-service.sh $(APP_NAME) $(ENVIRONMENT)

infra-update-current-account:
	./bin/terraform-init-and-apply.sh infra/accounts `./bin/current-account-config-name.sh`

infra-update-app-build-repository:
	# APP_NAME has a default value defined above, but check anyways in case the default is ever removed
	@:$(call check_defined, APP_NAME, the name of subdirectory of /infra that holds the application's infrastructure code)
	./bin/terraform-init-and-apply.sh infra/$(APP_NAME)/build-repository shared

infra-update-app-database:
	# APP_NAME has a default value defined above, but check anyways in case the default is ever removed
	@:$(call check_defined, APP_NAME, the name of subdirectory of /infra that holds the application's infrastructure code)
	@:$(call check_defined, ENVIRONMENT, the name of the application environment e.g. "prod" or "staging")
	./bin/terraform-init-and-apply.sh infra/$(APP_NAME)/database $(ENVIRONMENT)

infra-update-app-database-roles:
	@:$(call check_defined, APP_NAME, the name of subdirectory of /infra that holds the application's infrastructure code)
	@:$(call check_defined, ENVIRONMENT, the name of the application environment e.g. "prod" or "staging")
	./bin/create-or-update-database-roles.sh $(APP_NAME) $(ENVIRONMENT)


infra-update-app-service:
	# APP_NAME has a default value defined above, but check anyways in case the default is ever removed
	@:$(call check_defined, APP_NAME, the name of subdirectory of /infra that holds the application's infrastructure code)
	@:$(call check_defined, ENVIRONMENT, the name of the application environment e.g. "prod" or "staging")
	./bin/terraform-init-and-apply.sh infra/$(APP_NAME)/service $(ENVIRONMENT)


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
	@:$(call check_defined, ENVIRONMENT, the name of the application environment e.g. "prod" or "dev")
	./bin/deploy-release.sh $(APP_NAME) $(IMAGE_TAG) $(ENVIRONMENT)

release-image-name: ## Prints the image name of the release image
	@echo $(IMAGE_NAME)

release-image-tag: ## Prints the image tag of the release image
	@echo $(IMAGE_TAG)

########################
## Scripts and Helper ##
########################

help: ## Prints the help documentation and info about each command
	@grep -E '^[/a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
