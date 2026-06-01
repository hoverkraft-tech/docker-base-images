#!/bin/bash

set -eu -o pipefail
set -x

export DEBIAN_FRONTEND="noninteractive"

echo "+ setup zsh for ${USER} user"
ZSH="${HOME}/.oh-my-zsh" sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
