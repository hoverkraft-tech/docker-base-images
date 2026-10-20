#!/bin/sh
set -eu

workspace=$(mktemp -d)
cd "$workspace"
git init --quiet --initial-branch=main
git config user.name Test
git config user.email test@example.com

# A valid tracked shell file keeps the Bash validator active for this run.
printf '#!/usr/bin/env bash\necho "hello"\n' >valid.sh
git add valid.sh
git commit --quiet -m 'feat: add valid shell file'

# Simulate a package-manager content store. It is intentionally NOT Git-ignored
# so this exercises the find-prune, independently of IGNORE_GITIGNORED_FILES.
# The broken shell file would fail Bash validation if it were ever linted.
mkdir -p .pnpm-store/v10
printf '#!/usr/bin/env bash\nif then; fi\n' >.pnpm-store/v10/broken.sh

export DEFAULT_WORKSPACE="$workspace" GITHUB_WORKSPACE="$workspace"
export VALIDATE_JAVASCRIPT_TOOLCHAIN='' VALIDATE_PYTHON_TOOLCHAIN=''
export VALIDATE_BASH=true RUN_LOCAL=true
export GITHUB_STEP_SUMMARY="$workspace/summary.md"
export MULTI_STATUS=false ENABLE_GITHUB_PULL_REQUEST_SUMMARY_COMMENT=false

log_file=$(mktemp)
if ! /usr/local/bin/super-linter-entrypoint >"$log_file" 2>&1; then
	echo 'Expected linting to pass because .pnpm-store must be pruned from file discovery' >&2
	cat "$log_file"
	exit 1
fi

if grep -q 'broken.sh' "$log_file"; then
	echo 'Expected .pnpm-store/v10/broken.sh to be excluded from the file list' >&2
	cat "$log_file"
	exit 1
fi
