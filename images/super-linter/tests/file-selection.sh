#!/bin/sh
set -eu

workspace=$(mktemp -d)
cd "$workspace"
git init --quiet --initial-branch=main
git config user.name Test
git config user.email test@example.com
printf '#!/bin/sh\nif true\n' >unchanged.sh
git add unchanged.sh
git commit --quiet -m 'feat: initialize fixture'
base=$(git rev-parse HEAD)
git switch --quiet -c feature
printf '#!/bin/sh\nprintf "hello\\n"\n' >changed.sh
git add changed.sh
git commit --quiet -m 'feat: add valid shell file'
head=$(git rev-parse HEAD)
printf '#!/bin/sh\nif true\n' >untracked.sh
printf '{"number":1,"pull_request":{"head":{"sha":"%s"},"base":{"sha":"%s","ref":"main"}}}' "$head" "$base" >event.json

export DEFAULT_WORKSPACE="$workspace" GITHUB_WORKSPACE="$workspace"
export VALIDATE_JAVASCRIPT_TOOLCHAIN='' VALIDATE_PYTHON_TOOLCHAIN=''
export VALIDATE_BASH=true DEFAULT_BRANCH=main
export GITHUB_ACTIONS=true GITHUB_EVENT_NAME=pull_request
export GITHUB_EVENT_PATH="$workspace/event.json" GITHUB_SHA="$head"
export GITHUB_REPOSITORY=hoverkraft-tech/fixture GITHUB_REF=refs/pull/1/merge GITHUB_RUN_ID=1
export GITHUB_STEP_SUMMARY="$workspace/summary.md"
export MULTI_STATUS=false ENABLE_GITHUB_PULL_REQUEST_SUMMARY_COMMENT=false

log_file=$(mktemp)
if ! VALIDATE_ALL_CODEBASE=false /usr/local/bin/super-linter-entrypoint >"$log_file" 2>&1; then
	cat "$log_file"
	exit 1
fi
grep -q BASH "$GITHUB_STEP_SUMMARY"

if VALIDATE_ALL_CODEBASE=true /usr/local/bin/super-linter-entrypoint >"$log_file" 2>&1; then
	echo 'Expected the unchanged shell file to fail validation' >&2
	exit 1
fi
if ! grep -q unchanged.sh "$log_file"; then
	cat "$log_file"
	exit 1
fi

unset DEFAULT_BRANCH
if RUN_LOCAL=true FILTER_REGEX_INCLUDE='.*/untracked\.sh$' /usr/local/bin/super-linter-entrypoint >"$log_file" 2>&1; then
	echo 'Expected the untracked shell file to fail local validation' >&2
	exit 1
fi
if ! grep -q untracked.sh "$log_file"; then
	cat "$log_file"
	exit 1
fi
