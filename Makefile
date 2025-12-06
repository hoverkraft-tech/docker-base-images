.PHONY: help test test-all

help: ## Display help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

lint: ## Execute linting
	$(call run_linter,)

lint-fix: ## Execute linting and fix
	$(call run_linter, \
		-e FIX_JSON_PRETTIER=true \
		-e FIX_JAVASCRIPT_PRETTIER=true \
		-e FIX_YAML_PRETTIER=true \
		-e FIX_MARKDOWN=true \
		-e FIX_MARKDOWN_PRETTIER=true \
		-e FIX_NATURAL_LANGUAGE=true \
		-e FIX_SHELL_SHFMT=true \
	)

build: ## Build an image (usage: make build <image-name>)
	@docker buildx build images/$(filter-out $@,$(MAKECMDGOALS)) --tag $(filter-out $@,$(MAKECMDGOALS)):latest --load

test: ## Run tests for an image (usage: make test <image-name>)
	$(MAKE) build $(filter-out $@,$(MAKECMDGOALS))
	$(call run_testcontainers_tests,$(filter-out $@,$(MAKECMDGOALS)))

test-all: ## Run tests for all images
	@for image_dir in images/*/; do \
		image_name=$$(basename "$$image_dir"); \
		echo "Testing $$image_name..."; \
		$(MAKE) test "$$image_name" || exit 1; \
	done

define run_linter
	DEFAULT_WORKSPACE="$(CURDIR)"; \
	LINTER_IMAGE="linter:latest"; \
	VOLUME="$$DEFAULT_WORKSPACE:$$DEFAULT_WORKSPACE"; \
	docker build --platform linux/amd64 \
			--target linter \
			--build-arg UID=$(shell id -u) \
			--build-arg GID=$(shell id -g) \
			--tag $$LINTER_IMAGE .; \
	docker run \
		--platform linux/amd64 \
		-e DEFAULT_WORKSPACE="$$DEFAULT_WORKSPACE" \
		-e FILTER_REGEX_INCLUDE="$(filter-out $@,$(MAKECMDGOALS))" \
		-e IGNORE_GITIGNORED_FILES=true \
		$(1) \
		-v $$VOLUME \
		--rm \
		$$LINTER_IMAGE
endef

define run_testcontainers_tests
	@IMAGE_NAME=$(1); \
	if [ -z "$$IMAGE_NAME" ]; then \
		echo "Error: Please specify an image name. Usage: make test <image-name>"; \
		exit 1; \
	fi; \
	echo "Building testcontainers test image..."; \
	docker build -f images/testcontainers-go/Dockerfile --tag testcontainers:latest . || exit 1; \
	echo "Running tests for $$IMAGE_NAME..."; \
	docker run --rm \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v $(PWD):$(PWD):ro \
		-v $(PWD)/images/$$IMAGE_NAME:/workspace \
		-v $(PWD)/images/testcontainers-go/go.mod:/workspace/go.mod:ro \
		-v $(PWD)/images/testcontainers-go/go.sum:/workspace/go.sum:ro \
		-e GOTOOLCHAIN=local \
		-e GOMODCACHE=/tmp/go-mod \
		-e IMAGE_NAME="$$IMAGE_NAME:latest" \
		-e HOST_TESTS_DIR="$(PWD)/images/$$IMAGE_NAME/tests" \
		-w /workspace \
		-u root \
		testcontainers:latest \
		gotestsum --format testname -- -v ./...
endef

#############################
# Argument fix workaround
#############################
%:
	@: