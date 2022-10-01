.PHONY = \
	bootstrap-account

bootstrap-account:
	./bin/bootstrap-account.sh

destroy-account:
	./bin/template-only-destroy-account.sh
