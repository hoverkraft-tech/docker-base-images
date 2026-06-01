#!/bin/bash

set -eu -o pipefail

export DEBIAN_FRONTEND="noninteractive"

# --- main
#
echo "+ installing mise"
install -d -m 0755 /etc/apt/keyrings
wget -O /etc/apt/keyrings/mise-archive-keyring.asc "https://mise.jdx.dev/gpg-key.pub"
echo "deb [signed-by=/etc/apt/keyrings/mise-archive-keyring.asc] https://mise.jdx.dev/deb stable main" >/etc/apt/sources.list.d/mise.list
apt update
apt install -y mise
