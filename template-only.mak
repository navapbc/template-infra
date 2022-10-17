# This Makefile is for developers working on template-infra itself
# and is not intended to be used by projects that are using the template

.PHONY : \
	test \
	set-up-account \
	setup-app-backends \
	destroy-account

test:
	cd test && go test -v -timeout 30m

set-up-account:
	./bin/set-up-account.sh account

set-up-app-backends:
	./bin/set-up-app-backends.sh

check-github-actions-auth:
	./bin/check-github-actions-auth.sh arn:aws:iam::368823044688:role/template-infra-github-actions

destroy-account:
	./bin/template-only-destroy-account.sh
