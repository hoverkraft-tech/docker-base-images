#!/bin/sh
set -eu

test "$(id -u)" = 2345
test "$(id -g)" = 3456
test "$(stat -c '%u:%g' /github/home)" = 2345:3456

workspace=$(mktemp -d)
cd "$workspace"
git init --quiet
printf '#!/bin/sh\nif true;then\necho hi\nfi\n' >example.sh
export DEFAULT_WORKSPACE="$workspace"
export VALIDATE_JAVASCRIPT_TOOLCHAIN='' VALIDATE_PYTHON_TOOLCHAIN=''
export VALIDATE_SHELL_SHFMT=true FIX_SHELL_SHFMT=true
export CREATE_LOG_FILE=true
/usr/local/bin/super-linter-entrypoint
test "$(stat -c '%u:%g' example.sh)" = 2345:3456
test -f super-linter.log
test "$(stat -c '%u:%g' super-linter.log)" = 2345:3456
grep -q 'if true; then' example.sh

LOG_FILE=custom.log /usr/local/bin/super-linter-entrypoint
test -f custom.log

readonly_workspace=$(mktemp -d)
chmod 555 "$readonly_workspace"
DEFAULT_WORKSPACE="$readonly_workspace" SUPER_LINTER_ENTRYPOINT=/bin/sh \
	/usr/local/bin/super-linter-entrypoint <<'SH'
printf 'feat: read-only workspace\n' | commitlint --cwd "$DEFAULT_WORKSPACE"
SH
test -z "$(ls -A "$readonly_workspace")"
