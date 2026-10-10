#!/bin/sh
set -eu

workspace=$(mktemp -d)
cd "$workspace"
git init --quiet --initial-branch=main
mkdir -p .github/workflows .github/linters

cat >.github/workflows/example.yml <<'YAML'
name: Self repository
on: workflow_dispatch
permissions: {}
jobs:
  action:
    runs-on: ubuntu-latest
    steps:
      - uses: $/.github/actions/example
  workflow:
    uses: $/.github/workflows/reusable.yml
YAML

export DEFAULT_WORKSPACE="$workspace"
export VALIDATE_JAVASCRIPT_TOOLCHAIN='' VALIDATE_PYTHON_TOOLCHAIN=''
export VALIDATE_GITHUB_ACTIONS=true
log_file=$(mktemp)

run_linter() {
	if ! /usr/local/bin/super-linter-entrypoint >"$log_file" 2>&1; then
		cat "$log_file"
		exit 1
	fi
}

run_linter

cat >.github/linters/actionlint.yml <<'YAML'
self-hosted-runner:
  labels: [custom-runner]
YAML
sed -i 's/runs-on: ubuntu-latest/runs-on: [self-hosted, custom-runner]/' .github/workflows/example.yml

GITHUB_ACTIONS_COMMAND_ARGS=null run_linter

# Exercise custom arguments and retain unrelated diagnostics in the same file.
export GITHUB_ACTIONS_COMMAND_ARGS='-oneline -shellcheck= -pyflakes='
cat >>.github/workflows/example.yml <<'YAML'
  shell:
    runs-on: ubuntu-latest
    steps:
      - run: echo $unquoted
YAML
run_linter
cat >>.github/workflows/example.yml <<'YAML'
  invalid_action:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout
      - run: echo '${{ unknown_context.value }}'
  invalid_workflow:
    uses: example/repository/.github/workflows/reusable.yml
YAML

if /usr/local/bin/super-linter-entrypoint >"$log_file" 2>&1; then
	echo 'Expected unrelated workflow errors to fail validation' >&2
	exit 1
fi
for expected in 'specifying action "actions/checkout"' 'reusable workflow call "example/repository/' 'unknown_context'; do
	if ! grep -Fq "$expected" "$log_file"; then
		cat "$log_file"
		exit 1
	fi
done
if grep -Fq 'specifying action "$/' "$log_file" || grep -Fq 'reusable workflow call "$/' "$log_file"; then
	cat "$log_file"
	exit 1
fi
