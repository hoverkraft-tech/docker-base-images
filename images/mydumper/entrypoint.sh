#!/bin/bash

set -euo pipefail

TIME=$(date +%Y%m%d%H%M%S)
BACKUP_DIR="/backup"
KEEP_BACKUPS="${KEEP_BACKUPS:-7}"

# build extra args to mydumper
EXTRA_ARGS=()
thread_count="${MYDUMPER_THREADS:-}"
if [[ -n "${thread_count}" ]]; then
	EXTRA_ARGS+=(-t "${thread_count}")
else
	EXTRA_ARGS+=(-t "$(nproc)")
fi
if [[ -n "${MYDUMPER_COMPRESS:-}" ]]; then
	EXTRA_ARGS+=(--compress)
fi
if [[ -n "${MYDUMPER_EXTRA_OPTIONS:-}" ]]; then
	# Split string of extra options into an array to preserve quoting
	extra_options="${MYDUMPER_EXTRA_OPTIONS}"
	read -r -a user_extra <<<"${extra_options}"
	EXTRA_ARGS+=("${user_extra[@]}")
fi

mkdir -p "/backup/${TIME}"

if ! mydumper -h "${MYSQL_HOST}" \
	-P "${MYSQL_PORT}" \
	-u "${MYSQL_USER}" \
	-p "${MYSQL_PASSWORD}" \
	-B "${MYSQL_DATABASE}" \
	"${EXTRA_ARGS[@]}" \
	-o "/backup/${TIME}"; then
	echo "Backup failed"
	rm -rf "/backup/${TIME}"
	exit 1
fi

# Remove oldest backups while keeping the most recent ones
if [[ -d "${BACKUP_DIR}" ]]; then
	mapfile -d '' -t backup_entries < <(
		find "${BACKUP_DIR}" -mindepth 1 -maxdepth 1 -type d -printf '%T@ %p\0' | sort -z -n
	) || true
	total_backups=${#backup_entries[@]}
	keep_count=${KEEP_BACKUPS}
	if [[ ${keep_count} -lt 0 ]]; then
		keep_count=0
	fi
	remove_count=$((total_backups - keep_count))
	if ((remove_count > 0)); then
		for ((i = 0; i < remove_count; i++)); do
			dir="${backup_entries[i]#* }"
			rm -rf -- "${dir}"
		done
	fi
fi
