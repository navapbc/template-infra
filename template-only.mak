.PHONY = \
	set-up-account \
	setup-app-backends \
	destroy-account

set-up-account:
	./bin/set-up-account.sh account

setup-app-backends:
	./bin/setup-app-backends.sh

destroy-account:
	./bin/template-only-destroy-account.sh
