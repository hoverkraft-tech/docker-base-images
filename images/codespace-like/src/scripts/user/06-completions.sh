#!/bin/bash

set -eu -o pipefail

export DEBIAN_FRONTEND=noninteractive

# be sure we have the recents changes before using binaries (mise and krew path)
# shellcheck disable=SC1091
source "${HOME}/.bashrc"

# zsh
argocd completion zsh >"${HOME}/.oh-my-zsh/custom/completions/_argocd.sh"
chezmoi completion zsh >"${HOME}/.oh-my-zsh/custom/completions/_chezmoi.sh"
docker completion zsh >"${HOME}/.oh-my-zsh/custom/completions/_docker.sh"
kubectl completion zsh >"${HOME}/.oh-my-zsh/custom/completions/_kubectl.sh"
