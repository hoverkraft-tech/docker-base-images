#!/bin/bash

set -eu -o pipefail

export DEBIAN_FRONTEND=noninteractive

if [ ! -f "/home/coder/work/.ssh/id_ed25519" ]; then
	mise run generate-ssh-key
else
	echo "ssh-key exist skipping..."
fi
