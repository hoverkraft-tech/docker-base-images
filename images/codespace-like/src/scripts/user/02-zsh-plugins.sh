#!/bin/bash

set -eu -o pipefail

export DEBIAN_FRONTEND=noninteractive

mkdir -p "${HOME}/.oh-my-zsh/custom/plugins"
cd "${HOME}/.oh-my-zsh/custom/plugins"

git clone https://github.com/zsh-users/zsh-autosuggestions.git
git clone https://github.com/zsh-users/zsh-completions.git
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git
git clone https://github.com/joshskidmore/zsh-fzf-history-search
