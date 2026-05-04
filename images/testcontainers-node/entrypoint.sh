#!/bin/sh
set -eu

report_path="${TEST_JUNIT_REPORT_PATH:-junit.xml}"
rm -f "$report_path"

if node --test \
	--test-reporter=spec \
	--test-reporter=junit \
	--test-reporter-destination=stdout \
	--test-reporter-destination="$report_path" \
	"$@"; then
	status=0
else
	status=$?
fi

if [ -f "$report_path" ] && [ -n "${HOST_UID:-}" ] && [ -n "${HOST_GID:-}" ]; then
	chown "$HOST_UID:$HOST_GID" "$report_path"
fi

exit "$status"
