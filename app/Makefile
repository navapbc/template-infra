.PHONY : \
	release-build

release-build:
	docker buildx build \
		--target release \
		--platform=linux/amd64 \
		$(OPTS) \
		.

init:
	@echo "Example command for ci-vulnerability-scans.yml pipeline to build Docker image"
	@echo "If you are using this file, update this command to build your app for testing"

testing:
	@echo "Example command for ci-vulnerability-scans.yml pipeline to run tests"
	@echo "This is where any testing for your CI would go"