#!/bin/sh
set -eu

# Keep the self-repository exceptions with project-provided configurations too.
# FIXME: Remove when Actionlint supports this syntax: https://github.com/rhysd/actionlint/issues/711
# Pass the regexes directly to Actionlint to preserve quoting through GNU Parallel.
exec /usr/bin/actionlint \
	-ignore '^specifying action "\$/[^"@[:space:]]+" in invalid format because ref is missing\.' \
	-ignore '^reusable workflow call "\$/[^"@[:space:]]+" at "uses" is not following the format ' \
	"$@"
