# This Makefile is for developers working on template-infra itself
# and is not intended to be used by projects that are using the template

# PROJECT_NAME defaults to name of the current directory.
PROJECT_NAME ?= $(notdir $(PWD))

.PHONY : \
	test \
	set-up-account \
	setup-app-backends \
	check-github-actions-auth \
	destroy-account \
	tmp

test:
	cd test && PROJECT_NAME=$(PROJECT_NAME) go test -v -timeout 30m

set-up-account:
	./bin/set-up-account.sh $(PROJECT_NAME) account

set-up-app-backends:
	./bin/set-up-app-backends.sh

set-up-app-build-repository:
	./bin/set-up-app-build-repository.sh $(PROJECT_NAME)

check-github-actions-auth:
	./bin/check-github-actions-auth.sh arn:aws:iam::368823044688:role/$(PROJECT_NAME)-github-actions

create-distribution-resources:
	./bin/create-distribution-resources.sh

destroy-account:
	./bin/template-only-destroy-account.sh
