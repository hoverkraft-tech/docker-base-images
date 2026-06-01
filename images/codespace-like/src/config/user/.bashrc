#!/usr/bin/env bash

if [ -f "/etc/bash.bashrc" ]; then
	# shellcheck disable=SC1091
	. "/etc/bash.bashrc"
fi

# bash completion
if ! shopt -oq posix; then
	if [ -f /usr/share/bash-completion/bash_completion ]; then
		# shellcheck disable=SC1091
		. /usr/share/bash-completion/bash_completion
	elif [ -f /etc/bash_completion ]; then
		# shellcheck disable=SC1091
		. /etc/bash_completion
	fi
fi

# aliases
if [ -f "/etc/bash.aliases" ]; then
	# shellcheck disable=SC1091
	. "/etc/bash.aliases"
fi

# extras
if [ -f "/etc/bash.extras" ]; then
	# shellcheck disable=SC1091
	. "/etc/bash.extras"
fi
