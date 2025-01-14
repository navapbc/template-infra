.PHONY: \
	release-build

release-build:
	docker buildx build \
		--target release \
		--platform=linux/amd64 \
		$(OPTS) \
		.
