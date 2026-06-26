#!/bin/bash

set -eu -o pipefail

export DEBIAN_FRONTEND=noninteractive

# be sure we have the recents changes before using binaries (mise and krew path)
# shellcheck disable=SC1091
source "${HOME}/.bashrc"

# need that to have the correct kubectl integration (https://github.com/jdx/mise/discussions/6690)
echo "+ setup krew using the krew binary"
krew install krew
hash -r

# install plugins
echo "+ installing krew plugins through kubectl"
kubectl krew install gadget
kubectl krew install neat
kubectl krew install ctx
kubectl krew install df-pv
kubectl krew install deprecations
kubectl krew install get-all
kubectl krew install ns
kubectl krew install rbac-view
kubectl krew install resource-capacity
kubectl krew install view-utilization
kubectl krew install whoami
