# super-linter

An opinionated Super-Linter image with safer local defaults and explicit toolchain conflict guards.

It extends `ghcr.io/super-linter/super-linter` and keeps the stock linter entrypoint, while applying runtime defaults only when you did not set them yourself.

For direct local use, the image still supports `UID` and `GID` build args so the container can run as the host user. When this image is used as a base image, matching `ONBUILD` hooks apply the same `UID` and `GID` to `/github/home` and to the child image runtime user.

## Included behavior

- defaults `RUN_LOCAL=true`
- defaults `USE_FIND_ALGORITHM=true`
- defaults `LOG_LEVEL=WARN`
- defaults `LOG_FILE=/github/home/logs`
- defaults `IGNORE_GITIGNORED_FILES=true`
- defaults `KUBERNETES_KUBECONFORM_OPTIONS="-schema-location default -schema-location https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/{{.Group}}/{{.ResourceKind}}_{{.ResourceAPIVersion}}.json"`
- defaults `VALIDATE_JAVASCRIPT_TOOLCHAIN=biome`
- defaults `VALIDATE_PYTHON_TOOLCHAIN=ruff-format`
- supports overriding `VALIDATE_JAVASCRIPT_TOOLCHAIN=biome|eslint-prettier`
- supports overriding `VALIDATE_PYTHON_TOOLCHAIN=black|ruff-format`
- fails fast on unsupported toolchain names

## Usage

Build the image with the current host UID and GID so bind-mounted files stay writable:

```bash
docker build \
  --platform linux/amd64 \
  --build-arg UID="$(id -u)" \
  --build-arg GID="$(id -g)" \
  --tag linter:latest \
  images/super-linter
```

When you build a child image from this base, pass the same build args to the child build and the `ONBUILD` hooks will apply them automatically:

```dockerfile
FROM ghcr.io/hoverkraft-tech/docker-base-images/super-linter:latest
```

```bash
docker build \
  --platform linux/amd64 \
  --build-arg UID="$(id -u)" \
  --build-arg GID="$(id -g)" \
  --tag my-super-linter-child:latest \
  .
```

Run it against the current workspace:

```bash
DEFAULT_WORKSPACE="$(pwd)"; \
LINTER_IMAGE="linter:latest"; \
VOLUME="$DEFAULT_WORKSPACE:$DEFAULT_WORKSPACE"; \
docker run \
  --platform linux/amd64 \
  -v "$VOLUME" \
  --rm \
  -e DEFAULT_WORKSPACE="$DEFAULT_WORKSPACE" \
  -e FILTER_REGEX_INCLUDE='.*' \
  "$LINTER_IMAGE"
```

That matches the intended Makefile-style invocation:

```make
DEFAULT_WORKSPACE="$(CURDIR)"; \
LINTER_IMAGE="linter:latest"; \
VOLUME="$$DEFAULT_WORKSPACE:$$DEFAULT_WORKSPACE"; \
docker build --platform linux/amd64 --build-arg UID=$(shell id -u) --build-arg GID=$(shell id -g) --tag $$LINTER_IMAGE images/super-linter; \
docker run \
 --platform linux/amd64 \
 -v $$VOLUME \
 --rm \
 -e DEFAULT_WORKSPACE="$$DEFAULT_WORKSPACE" \
 -e FILTER_REGEX_INCLUDE="$(filter-out $@,$(MAKECMDGOALS))" \
 $$LINTER_IMAGE
```

## Toolchain selectors

Set one of these environment variables when you want the image to disable conflicting validators for you:

```bash
docker run \
  --platform linux/amd64 \
  -e DEFAULT_WORKSPACE="$(pwd)" \
  -e VALIDATE_JAVASCRIPT_TOOLCHAIN=biome \
  -v "$(pwd):$(pwd)" \
  --rm \
  linter:latest
```

Available values:

- `VALIDATE_JAVASCRIPT_TOOLCHAIN=biome`
- `VALIDATE_JAVASCRIPT_TOOLCHAIN=eslint-prettier`
- `VALIDATE_PYTHON_TOOLCHAIN=black`
- `VALIDATE_PYTHON_TOOLCHAIN=ruff-format`
