PROJECT_ROOT ?= $(notdir $(PWD))

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
			required by target '$@')))


.PHONY : \
	help \
	infra-check-app-database-roles \
	infra-check-compliance-checkov \
	infra-check-compliance-tfsec \
	infra-check-compliance \
	infra-configure-app-build-repository \
	infra-configure-app-database \
	infra-configure-app-service \
	infra-configure-monitoring-secrets \
	infra-configure-network \
	infra-format \
	infra-lint \
	infra-lint-scripts \
	infra-lint-terraform \
	infra-lint-workflows \
	infra-set-up-account \
	infra-test-service \
	infra-update-app-build-repository \
	infra-update-app-database-roles \
	infra-update-app-database \
	infra-update-app-service \
	infra-update-current-account \
	infra-update-network \
	infra-validate-modules \
	lint-markdown \
	release-build \
	release-deploy \
	release-image-name \
	release-image-tag \
	release-publish \
	release-run-database-migrations

APP_NAME_HELP := "the name of subdirectory of /infra that holds the application's infrastructure code"
ENVIRONMENT_HELP := "the name of the application environment e.g. 'prod' or 'staging'"
NETWORK_NAME_HELP := "the name of the network in /infra/networks"

require-%:
	@:$(call check_defined, $*, $($*_HELP))

infra-set-up-account: ## Configure and create resources for current AWS profile and save tfbackend file to infra/accounts/$ACCOUNT_NAME.ACCOUNT_ID.s3.tfbackend
	@:$(call check_defined, ACCOUNT_NAME, human readable name for account e.g. "prod" or the AWS account alias)
	./bin/set-up-current-account.sh $(ACCOUNT_NAME)

infra-configure-network: ## Configure network $NETWORK_NAME
infra-configure-network: require-NETWORK_NAME
	./bin/create-tfbackend.sh infra/networks $(NETWORK_NAME)

infra-configure-app-build-repository: ## Configure infra/$APP_NAME/build-repository tfbackend and tfvars files
infra-configure-app-build-repository: require-APP_NAME
	./bin/create-tfbackend.sh "infra/$(APP_NAME)/build-repository" shared

infra-configure-app-database: ## Configure infra/$APP_NAME/database module's tfbackend and tfvars files for $ENVIRONMENT
infra-configure-app-database: require-APP_NAME require-ENVIRONMENT
	./bin/create-tfbackend.sh "infra/$(APP_NAME)/database" "$(ENVIRONMENT)"

infra-configure-monitoring-secrets: ## Set $APP_NAME's incident management service integration URL for $ENVIRONMENT
infra-configure-monitoring-secrets: require_APP_NAME require_ENVIRONMENT
	@:$(call check_defined, URL, incident management service (PagerDuty or VictorOps) integration URL)
	./bin/configure-monitoring-secret.sh $(APP_NAME) $(ENVIRONMENT) $(URL)

infra-configure-app-service: ## Configure infra/$APP_NAME/service module's tfbackend and tfvars files for $ENVIRONMENT
infra-configure-app-service: require_APP_NAME require_ENVIRONMENT
	./bin/create-tfbackend.sh "infra/$(APP_NAME)/service" "$(ENVIRONMENT)"

infra-update-current-account: ## Update infra resources for current AWS profile
	./bin/terraform-init-and-apply.sh infra/accounts `./bin/current-account-config-name.sh`

infra-update-network: ## Update network
infra-update-network: require-NETWORK_NAME
	terraform -chdir="infra/networks" init -input=false -reconfigure -backend-config="$(NETWORK_NAME).s3.tfbackend"
	terraform -chdir="infra/networks" apply -var="network_name=$(NETWORK_NAME)"

infra-update-app-build-repository: ## Create or update $APP_NAME's build repository
infra-update-app-build-repository: require-APP_NAME
	./bin/terraform-init-and-apply.sh infra/$(APP_NAME)/build-repository shared

infra-update-app-database: ## Create or update $APP_NAME's database module for $ENVIRONMENT
infra-update-app-database: require-APP_NAME require-ENVIRONMENT
	terraform -chdir="infra/$(APP_NAME)/database" init -input=false -reconfigure -backend-config="$(ENVIRONMENT).s3.tfbackend"
	terraform -chdir="infra/$(APP_NAME)/database" apply -var="environment_name=$(ENVIRONMENT)"

infra-update-app-database-roles: ## Create or update database roles and schemas for $APP_NAME's database in $ENVIRONMENT
infra-update-app-database-roles: require-APP_NAME require-ENVIRONMENT
	./bin/create-or-update-database-roles.sh $(APP_NAME) $(ENVIRONMENT)

infra-update-app-service: ## Create or update $APP_NAME's web service module
infra-update-app-service: require-APP_NAME require-ENVIRONMENT
	terraform -chdir="infra/$(APP_NAME)/service" init -input=false -reconfigure -backend-config="$(ENVIRONMENT).s3.tfbackend"
	terraform -chdir="infra/$(APP_NAME)/service" apply -var="environment_name=$(ENVIRONMENT)"

# The prerequisite for this rule is obtained by
# prefixing each module with the string "infra-validate-module-"
infra-validate-modules: ## Run terraform validate on reusable child modules
infra-validate-modules: $(patsubst %, infra-validate-module-%, $(MODULES))

infra-validate-module-%:
	@echo "Validate library module: $*"
	terraform -chdir=infra/modules/$* init -backend=false
	terraform -chdir=infra/modules/$* validate

infra-check-app-database-roles: ## Check that app database roles have been configured properly
infra-check-app-database-roles: require-APP_NAME require-ENVIRONMENT
	./bin/check-database-roles.sh $(APP_NAME) $(ENVIRONMENT)

infra-check-compliance: ## Run compliance checks
infra-check-compliance: infra-check-compliance-checkov infra-check-compliance-tfsec

infra-check-compliance-checkov: ## Run checkov compliance checks
	checkov --directory infra

infra-check-compliance-tfsec: ## Run tfsec compliance checks
	tfsec infra

infra-lint: ## Lint infra code
infra-lint: lint-markdown infra-lint-scripts infra-lint-terraform infra-lint-workflows

infra-lint-scripts: ## Lint shell scripts
	shellcheck bin/**

infra-lint-terraform: ## Lint Terraform code
	terraform fmt -recursive -check infra

infra-lint-workflows: ## Lint GitHub actions
	actionlint

infra-format: ## Format infra code
	terraform fmt -recursive infra

infra-test-service: ## Run service layer infra test suite
	cd infra/test && go test -run TestService -v -timeout 30m

lint-markdown: ## Lint Markdown docs for broken links
	./bin/lint-markdown.sh

########################
## Release Management ##
########################

# Include project name in image name so that image name
# does not conflict with other images during local development
IMAGE_NAME := $(PROJECT_ROOT)-$(APP_NAME)

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

release-build: ## Build release for $APP_NAME and tag it with current git hash
release-build: require-APP_NAME
	cd $(APP_NAME) && $(MAKE) release-build \
		OPTS="--tag $(IMAGE_NAME):latest --tag $(IMAGE_NAME):$(IMAGE_TAG)"

release-publish: ## Publish release to $APP_NAME's build repository
release-publish: require-APP_NAME
	./bin/publish-release.sh $(APP_NAME) $(IMAGE_NAME) $(IMAGE_TAG)

release-run-database-migrations: ## Run $APP_NAME's database migrations in $ENVIRONMENT
release-run-database-migrations: require-APP_NAME require-ENVIRONMENT
	./bin/run-database-migrations.sh $(APP_NAME) $(IMAGE_TAG) $(ENVIRONMENT)

release-deploy: ## Deploy release to $APP_NAME's web service in $ENVIRONMENT
release-deploy: require-APP_NAME require-ENVIRONMENT
	./bin/deploy-release.sh $(APP_NAME) $(IMAGE_TAG) $(ENVIRONMENT)

release-image-name: ## Prints the image name of the release image
release-image-name: require-APP_NAME
	@echo $(IMAGE_NAME)

release-image-tag: ## Prints the image tag of the release image
	@echo $(IMAGE_TAG)

########################
## Scripts and Helper ##
########################

help: ## Prints the help documentation and info about each command
	@grep -Eh '^[[:print:]]+:.*?##' $(MAKEFILE_LIST) | \
	sort -d | \
	awk -F':.*?## ' '{printf "\033[36m%s\033[0m\t%s\n", $$1, $$2}' | \
	column -t -s "$$(printf '\t')"
	@echo ""
	@echo "APP_NAME=$(APP_NAME)"
	@echo "ENVIRONMENT=$(ENVIRONMENT)"
	@echo "IMAGE_NAME=$(IMAGE_NAME)"
	@echo "IMAGE_TAG=$(IMAGE_TAG)"
	@echo "INFO_TAG=$(INFO_TAG)"
	@echo "GIT_REPO_AVAILABLE=$(GIT_REPO_AVAILABLE)"
	@echo "SHELL=$(SHELL)"
	@echo "MAKE_VERSION=$(MAKE_VERSION)"
	@echo "MODULES=$(MODULES)"
