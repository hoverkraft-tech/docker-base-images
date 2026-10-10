# super-linter

An opinionated Super-Linter image shared by local linting and GitHub Actions.

It extends `ghcr.io/super-linter/super-linter:slim` and runs its stock linter after applying shared toolchain defaults and installing fallback commitlint rules. Explicit environment variables take precedence over the image defaults.

The published image runs as root, as required by GitHub Docker actions. For local use, pass the host `UID` and `GID` as build arguments so fixes preserve file ownership. When used as a base image, `ONBUILD` hooks apply the child build’s `UID` and `GID` to `/github/home` and its runtime user; both default to `1000`.

## Included behavior

- defaults `RUN_LOCAL=false` when `GITHUB_ACTIONS=true`, otherwise `RUN_LOCAL=true`
- defaults `USE_FIND_ALGORITHM=true` for local runs; CI uses Super-Linter's Git discovery and summary defaults
- defaults `LOG_LEVEL=WARN`
- uses Super-Linter's `LOG_FILE=super-linter.log` default; enable file logging with `CREATE_LOG_FILE=true`
- defaults `IGNORE_GITIGNORED_FILES=true`
- defaults `KUBERNETES_KUBECONFORM_SCHEMA_LOCATIONS="https://raw.githubusercontent.com/hoverkraft-tech/crds-catalog/main/{{.Group}}/{{.ResourceKind}}_{{.ResourceAPIVersion}}.json https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/{{.Group}}/{{.ResourceKind}}_{{.ResourceAPIVersion}}.json"`
- defaults `KUBERNETES_KUBECONFORM_OPTIONS` from `KUBERNETES_KUBECONFORM_SCHEMA_LOCATIONS` as `-schema-location default` plus one `-schema-location` per entry
- defaults `VALIDATE_JAVASCRIPT_TOOLCHAIN=biome`
- defaults `VALIDATE_PYTHON_TOOLCHAIN=ruff-format`
- supports overriding `VALIDATE_JAVASCRIPT_TOOLCHAIN=biome|eslint-prettier`
- supports overriding `VALIDATE_PYTHON_TOOLCHAIN=black|ruff-format`
- fails fast on unsupported toolchain names
- supplies conventional commit rules as a global fallback without writing configuration in the workspace
- respects `VALIDATE_GIT_COMMITLINT=false`; with toolchain selectors enabled, explicit `true` keeps commitlint enabled without restricting other validators
- accepts `$/` self-repository action and reusable workflow references with both default and project-provided Actionlint configurations

## JSCPD configuration

Configure copy/paste detection in your project's `.github/linters/.jscpd.json`:

```json
{
  "noGitignore": false
}
```

Set `noGitignore` to `false` to exclude Git-ignored files, or `true` to include them.
This setting operates independently of `IGNORE_GITIGNORED_FILES`.

## Testing

Run `make test super-linter` from the repository root.
JSCPD checks run the image entrypoint at container startup, with a fresh container for each configuration.
Each check has a 60-second startup deadline and verifies the linter exit code and duplication report.

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
FROM ghcr.io/hoverkraft-tech/docker-base-images/super-linter:2.0.0
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

To use Super-Linter's native validator allowlist, set both toolchain selectors to
empty strings and enable the desired `VALIDATE_*` variables. For example,
`VALIDATE_GIT_COMMITLINT=true` then selects only commit message validation.
Super-Linter accepts either `true` flags (an allowlist) or `false` flags (exclusions),
not a mixture of both. The automatic toolchain selectors use exclusions.

## GitHub Actions

Use the same image release as local linting. GitHub provides the workspace, event
metadata, and command files to the Docker action:

```yaml
- uses: docker://ghcr.io/hoverkraft-tech/docker-base-images/super-linter:2.0.0
  env:
    GITHUB_TOKEN: ${{ github.token }}
    DEFAULT_BRANCH: ${{ github.event.repository.default_branch }}
    VALIDATE_ALL_CODEBASE: "false"
```

Check out the full Git history before running the image when validating changed
files. The reusable [linter workflow](https://github.com/hoverkraft-tech/ci-github-common/blob/main/.github/workflows/linter.yml)
provides checkout, input mapping, dependency installation for Prettier plugins,
and additional CodeQL and action-pinning jobs.

Install project dependencies before local linting when configuration references
Prettier plugins. The image uses those dependencies from the mounted workspace.

### Actionlint self-repository references

The image adds two narrow Actionlint `-ignore` patterns for the unsupported
`$/` reference-format diagnostics described in [actionlint#711](https://github.com/rhysd/actionlint/issues/711).
They apply to step actions and reusable workflow calls, including projects with
their own Actionlint configuration. Other diagnostics remain enabled, and
arguments supplied through `GITHUB_ACTIONS_COMMAND_ARGS` are preserved.

## Commitlint configuration

Commitlint discovers project configuration itself, including parent directories
and the `commitlint` field in `package.json` or `package.yaml`. Project rules take
precedence over the bundled rules.

The entrypoint installs the bundled rules in
`${XDG_CONFIG_HOME:-$HOME/.config}/commitlint/config.cjs` when no global
configuration exists. This supports GitHub Actions' mounted home directory and
leaves the workspace untouched. Existing global configuration is preserved.
Set `VALIDATE_GIT_COMMITLINT=false` to disable commit message validation and
fallback installation.
