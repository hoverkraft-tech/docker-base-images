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
	@image_name=$(filter-out $@,$(MAKECMDGOALS)); \
	if [ -z "$$image_name" ]; then \
		echo "Error: Please specify an image name. Usage: make test <image-name>"; \
		exit 1; \
	fi; \
	echo "Building $$image_name for testing...\n"; \
	$(MAKE) build $$image_name || exit 1; \
	echo "Building testcontainers test image...\n"; \
	docker build -f images/testcontainers-node/Dockerfile --tag testcontainers:latest images/testcontainers-node || exit 1; \
	echo "\nTesting $$image_name...\n"; \
	docker run --rm \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v $(PWD):$(PWD):ro \
		-v $(PWD)/images/$$image_name:/workspace/image:ro \
		-e IMAGE_NAME="$$image_name:latest" \
		-e HOST_TESTS_DIR="/workspace/image/tests" \
		-w /workspace/image \
		-u root \
		testcontainers:latest \
		sh -c 'if [ -f test.spec.js ]; then node --test test.spec.js; else echo "No test.spec.js found; skipping"; fi' || exit 1; \
	echo "\nTests passed for $$image_name.\n";
	
test-all: ## Run tests for all images
	$(MAKE) build testcontainers-node
	@for image_dir in images/*/; do \
		image_name=$$(basename "$$image_dir"); \
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

#############################
# Argument fix workaround
#############################
%:
	@: