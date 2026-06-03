#!/bin/bash

set -eu -o pipefail

export DEBIAN_FRONTEND="noninteractive"

echo "+ setup zsh for ${USER} user"
ZSH="${HOME}/.oh-my-zsh" sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

rsync -a "${HOME}/_oh-my-zsh/custom/" "${HOME}/.oh-my-zsh/custom/"
cp "${HOME}/_oh-my-zsh/.zshrc" "${HOME}/.zshrc"
rm -rf "${HOME}/_oh-my-zsh/"
