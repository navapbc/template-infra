.PHONY = \
	bootstrap-account

bootstrap-account:
	./bin/bootstrap-account.sh

setup-app-backends:
	./bin/setup-app-backends.sh

destroy-account:
	./bin/template-only-destroy-account.sh
