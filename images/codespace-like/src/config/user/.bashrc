#!/usr/bin/env bash

if [ -f "${HOME}/bash.bashrc" ]; then
	# shellcheck disable=SC1091
	. "${HOME}/bash.bashrc"
fi

# bash completion
if ! shopt -oq posix; then
	if [ -f /usr/share/bash-completion/bash_completion ]; then
		# shellcheck disable=SC1091
		. /usr/share/bash-completion/bash_completion
	elif [ -f "${HOME}/bash_completion" ]; then
		# shellcheck disable=SC1091
		. "${HOME}/bash_completion"
	fi
fi

# aliases
if [ -f "${HOME}/bash.aliases" ]; then
	# shellcheck disable=SC1091
	. "${HOME}/bash.aliases"
fi

# extras
if [ -f "${HOME}/bash.extras" ]; then
	# shellcheck disable=SC1091
	. "${HOME}/bash.extras"
fi

# PATH additions
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
