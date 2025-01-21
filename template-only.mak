# This Makefile is for developers working on template-infra itself
# and is not intended to be used by projects that are using the template

PROJECT_NAME ?= platform-template-infra

MODULES := $(notdir $(wildcard templates/base/infra/modules/*))

.PHONY : \
  clean \
	test \
	setup-app-backends \
	destroy-account

infra-lint-scripts: ## Lint shell scripts
	shellcheck templates/*/bin/**

infra-lint-terraform: ## Lint Terraform code
	terraform fmt -recursive -check templates/*/infra

# The prerequisite for this rule is obtained by
# prefixing each module with the string "infra-validate-module-"
infra-validate-modules: ## Run terraform validate on reusable child modules
infra-validate-modules: $(patsubst %, infra-validate-module-%, $(MODULES))

infra-validate-module-%:
	@echo "Validate library module: $*"
	terraform -chdir=templates/base/infra/modules/$* init -backend=false
	terraform -chdir=templates/base/infra/modules/$* validate

lint-template-scripts: ## Lint template only scripts
	shellcheck template-only-bin/**

test:
	cd template-only-test && PROJECT_NAME=$(PROJECT_NAME) go test -v -timeout 30m

set-up-project:
	./template-only-bin/set-up-project $(PROJECT_NAME)

clean:
	rm -fr infra/accounts/account/.terraform infra/app/envs/dev/.terraform infra/app/envs/staging/.terraform infra/app/envs/prod/.terraform infra/app/build-repository/.terraform
	rm -f infra/accounts/account/terraform.tfstate* infra/app/envs/dev/terraform.tfstate* infra/app/envs/staging/terraform.tfstate* infra/app/envs/prod/terraform.tfstate* infra/app/build-repository/terraform.tfstate*
	git reset --hard HEAD
	git clean -f

destroy-app-service:
	./template-only-bin/destroy-app-service

destroy-app-database:
	./template-only-bin/destroy-app-database

destroy-app-build-repository:
	./template-only-bin/destroy-app-build-repository

destroy-network:
	./template-only-bin/destroy-network

destroy-account:
	./template-only-bin/destroy-account
