#!/bin/bash

set -eu -o pipefail

export DEBIAN_FRONTEND=noninteractive

# be sure we have the recents changes before using binaries (mise)
# shellcheck disable=SC1091
source "${HOME}/.bashrc"

if [ ! -d "${GNUPGHOME}" ]; then
	mkdir -p "${GNUPGHOME}"
else
	echo "GNUPGHOME ${GNUPGHOME} exists. skipping..."
fi
