#!/bin/bash

set -eu -o pipefail

export DEBIAN_FRONTEND=noninteractive

# --- functions
#
function mise-activation() {
	local lshell="$1"
	local file="$2"

	if [ ! -f "$file" ] || (! grep -q "mise activate $lshell" "$file" 2>/dev/null); then
		echo "+ activating mise in $file (shell=$lshell)"
		touch "$file"
		echo -e '\n# mise-en-place config' >>"$file"
		echo "eval \"\$(mise activate $lshell)\"" >>"$file"
	else
		echo "+ skipping $file (shell=$lshell)"
	fi
}

echo "+ activating mise"
mise-activation bash "${HOME}/.bashrc"
mise-activation zsh "${HOME}/.zshrc"

echo "+ running mise install"
cd "${HOME}"
# shellcheck disable=SC1091
source .bashrc
mise install
