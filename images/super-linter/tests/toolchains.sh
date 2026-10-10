#!/bin/sh
set -eu

export SUPER_LINTER_ENTRYPOINT=/bin/bash
for javascript in biome eslint-prettier; do
	for python in black ruff-format; do
		VALIDATE_JAVASCRIPT_TOOLCHAIN="$javascript" VALIDATE_PYTHON_TOOLCHAIN="$python" VALIDATE_GIT_COMMITLINT=true \
			/usr/local/bin/super-linter-entrypoint <<'BASH'
set -e
source /action/lib/functions/log.sh
source /action/lib/globals/languages.sh
source /action/lib/functions/validation.sh
ValidateValidationVariables
ValidateConflictingTools
test "$VALIDATE_GIT_COMMITLINT" = true
case "$VALIDATE_JAVASCRIPT_TOOLCHAIN" in
biome) test "$VALIDATE_BIOME_LINT" = true; test "$VALIDATE_BIOME_FORMAT" = true ;;
eslint-prettier) test "$VALIDATE_JAVASCRIPT_ES" = true; test "$VALIDATE_JAVASCRIPT_PRETTIER" = true ;;
esac
case "$VALIDATE_PYTHON_TOOLCHAIN" in
black) test "$VALIDATE_PYTHON_BLACK" = true ;;
ruff-format) test "$VALIDATE_PYTHON_RUFF_FORMAT" = true ;;
esac
BASH
	done
done

VALIDATE_JAVASCRIPT_TOOLCHAIN='' VALIDATE_PYTHON_TOOLCHAIN='' VALIDATE_GIT_COMMITLINT=true VALIDATE_BASH=true \
	/usr/local/bin/super-linter-entrypoint <<'BASH'
set -e
source /action/lib/functions/log.sh
source /action/lib/globals/languages.sh
source /action/lib/functions/validation.sh
ValidateValidationVariables
ValidateConflictingTools
test "$VALIDATE_GIT_COMMITLINT" = true
test "$VALIDATE_BASH" = true
test "$VALIDATE_PYTHON_BLACK" = false
test "$VALIDATE_BIOME_LINT" = false
BASH
