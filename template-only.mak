# This Makefile is for developers working on template-infra itself
# and is not intended to be used by projects that are using the template

PROJECT_NAME ?= platform-template-infra
PROJECT_OWNER ?= platform-admins
PROJECT_REGION ?= us-east-1
ACCOUNT ?= account
ACCOUNT_ID ?= 368823044688
GITHUB_ACTIONS_ROLE ?= arn:aws:iam::$(ACCOUNT_ID):role/$(PROJECT_NAME)-github-actions

.PHONY : \
  clean \
	test \
	setup-app-backends \
	check-github-actions-auth \
	destroy-account

test:
	cd template-only-test && PROJECT_NAME=$(PROJECT_NAME) go test -v -timeout 30m

set-up-project:
	./template-only-bin/set-up-project.sh $(PROJECT_NAME) $(PROJECT_OWNER) $(PROJECT_REGION)

clean:
	rm -fr infra/accounts/account/.terraform infra/app/envs/dev/.terraform infra/app/envs/staging/.terraform infra/app/envs/prod/.terraform infra/app/build-repository/.terraform
	rm -f infra/accounts/account/terraform.tfstate* infra/app/envs/dev/terraform.tfstate* infra/app/envs/staging/terraform.tfstate* infra/app/envs/prod/terraform.tfstate* infra/app/build-repository/terraform.tfstate*
	git reset --hard HEAD
	git clean -f

check-github-actions-auth:
	./bin/check-github-actions-auth.sh $(GITHUB_ACTIONS_ROLE)

destroy-app-service:
	./template-only-bin/destroy-app-service.sh

destroy-app-build-repository:
	./template-only-bin/destroy-app-build-repository.sh

destroy-account:
	./template-only-bin/destroy-account.sh
