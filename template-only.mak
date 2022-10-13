.PHONY = \
	bootstrap-account

bootstrap-account:
	./bin/bootstrap-account.sh

setup-app-backends:
	./bin/setup-app-backends.sh

create-distribution-resources:
	./bin/create-distribution-resources.sh

destroy-account:
	./bin/template-only-destroy-account.sh
