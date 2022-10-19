# This Makefile is for developers working on template-infra itself
# and is not intended to be used by projects that are using the template

PROJECT_NAME ?= platform-template-infra
ACCOUNT ?= account
ACCOUNT_ID ?= 368823044688
GITHUB_ACTIONS_ROLE ?= arn:aws:iam::$(ACCOUNT_ID):role/$(PROJECT_NAME)-github-actions

.PHONY : \
	test \
	set-up-account \
	setup-app-backends \
	check-github-actions-auth \
	destroy-account \
	tmp

test:
	cd template-only-test && PROJECT_NAME=$(PROJECT_NAME) go test -v -timeout 30m

set-up-account:
	./template-only-bin/set-up-account.sh $(PROJECT_NAME) $(ACCOUNT)

set-up-app-backends:
	./template-only-bin/set-up-app-backends.sh $(PROJECT_NAME)

set-up-app-build-repository:
	./template-only-bin/set-up-app-build-repository.sh $(PROJECT_NAME)

check-github-actions-auth:
	./bin/check-github-actions-auth.sh $(GITHUB_ACTIONS_ROLE)

destroy-account:
	./template-only-bin/destroy-account.sh
