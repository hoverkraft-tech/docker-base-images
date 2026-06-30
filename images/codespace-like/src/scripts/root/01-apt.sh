#!/bin/bash

set -eu -o pipefail
set -x

export DEBIAN_FRONTEND="noninteractive"

echo "+ configuring apt"
cat <<'_EOF' >>/etc/apt/apt.conf
APT::Install-Recommends "false";
APT::Install-Suggests "false";
_EOF

echo "+ upgrading os packages"
apt update
apt full-upgrade -y

echo "+ installing base os packages"
apt install -y --no-install-recommends --no-install-suggests \
	bash-completion \
	ca-certificates \
	curl \
	docker.io \
	docker-buildx \
	docker-cli \
	docker-compose \
	fish \
	git git-lfs \
	gnupg \
	jq \
	liquidprompt \
	make \
	pass \
	pipx python3 python3-pip python3.13-venv \
	python3-yamale \
	rsync \
	tmux \
	wget \
	yamllint \
	yq \
	zsh
