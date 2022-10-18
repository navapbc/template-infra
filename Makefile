# PROJECT_NAME defaults to name of the current directory.
PROJECT_NAME ?= $(notdir $(PWD))

# For now only support a single app in the folder `app/` within the repo
# In the future, support multiple apps, and which app is being operated
# on will be determined by the APP_NAME Makefile argument
APP_NAME ?= app

# The name of the account folder under accounts
ACCOUNT ?= account

# Get the list of reusable terraform modules by getting out all the modules
# in infra/modules and then stripping out the "infra/modules/" prefix
MODULES := $(notdir $(wildcard infra/modules/*))


.PHONY : \
	infra-validate-modules \
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

# Validate all infra modules. The prerequisite for this rule is obtained by
# prefixing each module with the string "infra-validate-module-"
infra-validate-modules: $(patsubst %, infra-validate-module-%, $(MODULES))

infra-validate-module-%:
	@echo "Validate module: $*"
	terraform -chdir=infra/modules/$* init -backend=false
	terraform -chdir=infra/modules/$* validate

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

release-publish: get-image-registry ecr-login
	$(eval IMAGE_REPOSITORY := $(terraform -chdir=infra/$(APP_NAME)/build-repository output -raw image_repository_name))
	docker tag $(APP_NAME):$(IMAGE_TAG) $(IMAGE_REGISTRY)/$(IMAGE_REPOSITORY):$(IMAGE_TAG)
	docker push $(IMAGE_REGISTRY)/$(IMAGE_REPOSITORY):$(IMAGE_TAG)

release-deploy:

ecr-login: get-image-registry
	@echo "Authenticating Docker with ECR"
	aws ecr get-login-password --region 'us-east-1' | \
	docker login --username AWS --password-stdin $(IMAGE_REGISTRY)

# Define the IMAGE_REGISTRY variable dynamically since it is different for each account
get-container-image-registry:
	$(eval AWS_ACCOUNT_ID := $(terraform -chdir=infra/accounts/$(ACCOUNT) output -raw account_id))
	$(eval REGION := $(terraform -chdir=infra/accounts/$(ACCOUNT) output -raw region))
	$(eval IMAGE_REGISTRY ?= $(AWS_ACCOUNT_ID).dkr.ecr.$(REGION).amazonaws.com)
