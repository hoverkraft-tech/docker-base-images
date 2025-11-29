.PHONY: help

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

build: ## Build an image (usage: make build images/<image-name>)
	@docker buildx build $(filter-out $@,$(MAKECMDGOALS))

test: ## Run tests for an image (usage: make test <image-name>)
	$(call run_tests,$(filter-out $@,$(MAKECMDGOALS)))

test-all: ## Run tests for all images
	@for image_dir in images/*/; do \
		image_name=$$(basename "$$image_dir"); \
		if [ -f "$$image_dir/container-structure-test.yaml" ]; then \
			echo "Testing $$image_name..."; \
			$(MAKE) test "$$image_name" || exit 1; \
		fi; \
	done

define run_linter
	DEFAULT_WORKSPACE="$(CURDIR)"; \
	LINTER_IMAGE="linter:latest"; \
	VOLUME="$$DEFAULT_WORKSPACE:$$DEFAULT_WORKSPACE"; \
	docker build --target linter --build-arg UID=$(shell id -u) --build-arg GID=$(shell id -g) --tag $$LINTER_IMAGE .; \
	docker run \
		-e DEFAULT_WORKSPACE="$$DEFAULT_WORKSPACE" \
		-e FILTER_REGEX_INCLUDE="$(filter-out $@,$(MAKECMDGOALS))" \
		-e IGNORE_GITIGNORED_FILES=true \
		$(1) \
		-v $$VOLUME \
		--rm \
		$$LINTER_IMAGE
endef

define run_tests
	@IMAGE_NAME=$(1); \
	if [ -z "$$IMAGE_NAME" ]; then \
		echo "Error: Please specify an image name. Usage: make test <image-name>"; \
		exit 1; \
	fi; \
	IMAGE_DIR="$(CURDIR)/images/$$IMAGE_NAME"; \
	TEST_CONFIG="$$IMAGE_DIR/container-structure-test.yaml"; \
	if [ ! -f "$$TEST_CONFIG" ]; then \
		echo "Error: Test config not found at $$TEST_CONFIG"; \
		exit 1; \
	fi; \
	echo "Building image $$IMAGE_NAME..."; \
	docker buildx build -t "$$IMAGE_NAME:test" "$$IMAGE_DIR" || exit 1; \
	echo "Building structure-test image..."; \
	docker build --target structure-test --tag structure-test:latest . || exit 1; \
	echo "Running tests for $$IMAGE_NAME..."; \
	docker run --rm \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v "$$IMAGE_DIR:/workspace" \
		structure-test:latest \
		test --image "$$IMAGE_NAME:test" --config /workspace/container-structure-test.yaml
endef

#############################
# Argument fix workaround
#############################
%:
	@: