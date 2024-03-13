#!/bin/bash

set -euo pipefail

TIME=$(date +%Y%m%d%H%M%S)
BACKUP_DIR="/backup"
KEEP_BACKUPS=${KEEP_BACKUPS:-7}

# build extra args to mydumper
EXTRA_ARGS=""
if [[ -n "${MYDUMPER_THREADS}" ]]; then EXTRA_ARGS="${EXTRA_ARGS} -t ${MYDUMPER_THREADS}"; else EXTRA_ARGS="${EXTRA_ARGS} -t $(nproc)"; fi
if [[ -n "${MYDUMPER_COMPRESS}" ]]; then EXTRA_ARGS="${EXTRA_ARGS} --compress"; fi
if [[ -n "${MYDUMPER_EXTRA_OPTIONS}" ]]; then EXTRA_ARGS="${EXTRA_ARGS} ${MYDUMPER_EXTRA_OPTIONS}"; fi

mkdir -p /backup/${TIME}

mydumper -h ${MYSQL_HOST}   \
  -P ${MYSQL_PORT}          \
  -u "${MYSQL_USER}"        \
  -p "${MYSQL_PASSWORD}"    \
  -B "${MYSQL_DATABASE}"    \
  ${EXTRA_ARGS}             \
  -o /backup/${TIME}

if [[ $? -ne 0 ]]; then
  echo "Backup failed"
  rm -rf /backup/${TIME}
  exit 1
fi

# List all directories, sort by modification time, reverse, skip the first N, and remove the rest
ls -1trd ${BACKUP_DIR}/* | head -n -${KEEP_BACKUPS} | xargs -d '\n' rm -rf
