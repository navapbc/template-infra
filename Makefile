.PHONY : \
	check \
	lint \
	type-check \
	test \
	release-build \
	release-publish \
	release-deploy \
	image-registry-login \
	db-migrate \
	db-migrate-down \
	db-migrate-create

######################
## Automated Checks ##
######################

check: lint type-check test

lint:

type-check:

test:

########################
## Release Management ##
########################

release-build:

release-publish:

release-deploy:

#########################
## Database Management ##
#########################

db-migrate:

db-migrate-down:

db-migrate-create:
