# This Makefile is for developers working on template-infra itself
# and is not intended to be used by projects that are using the template

PROJECT_NAME := platform-template-infra
ACCOUNT := account
ACCOUNT_ID := 368823044688

.PHONY : \
	test \
	set-up-account \
	setup-app-backends \
	check-github-actions-auth \
	destroy-account

test:
	cd template-only-test && go test -v -timeout 30m

set-up-account:
	./template-only-bin/set-up-account.sh $(PROJECT_NAME) $(ACCOUNT)

set-up-app-backends:
	./template-only-bin/set-up-app-backends.sh

check-github-actions-auth:
	./bin/check-github-actions-auth.sh arn:aws:iam::$(ACCOUNT_ID):role/$(PROJECT_NAME)-github-actions

destroy-account:
	./template-only-bin/template-only-destroy-account.sh
