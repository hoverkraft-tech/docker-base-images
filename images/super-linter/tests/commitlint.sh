#!/bin/sh
set -eu

workspace=$(mktemp -d)
cd "$workspace"
git init --quiet --initial-branch=main
git config user.name Test
git config user.email test@example.com
git commit --quiet --allow-empty -m 'feat: initialize fixture'

export DEFAULT_WORKSPACE="$workspace"
export VALIDATE_JAVASCRIPT_TOOLCHAIN='' VALIDATE_PYTHON_TOOLCHAIN=''
export VALIDATE_GIT_COMMITLINT=true ENFORCE_COMMITLINT_CONFIGURATION_CHECK=true

log_file=$(mktemp)
if ! /usr/local/bin/super-linter-entrypoint >"$log_file" 2>&1; then
	cat "$log_file"
	exit 1
fi

git commit --quiet --allow-empty -m 'invalid commit message'
if /usr/local/bin/super-linter-entrypoint >"$log_file" 2>&1; then
	echo 'Expected the invalid commit message to fail validation' >&2
	exit 1
fi
if ! grep -q 'type-empty' "$log_file"; then
	cat "$log_file"
	exit 1
fi
test -z "$(git status --porcelain)"
