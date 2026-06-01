FROM ghcr.io/coder/code-server:trixie

LABEL org.opencontainers.image.description="vscode web server image with some quality of life improvements"

COPY src /build

# this is the setup part
# hadolint ignore=DL3004
RUN \
  echo "+ stating setup" && \
  for script in /build/scripts/root/*.sh; do \
    echo "running $script (as root)"; \
    sudo bash "$script"; \
  done

# this is the user config part
RUN \
  echo "+ stating user config" && \
  for script in /build/scripts/user/*.sh; do \
    echo "running $script"; \
    bash "$script"; \
  done

# cleaning
# hadolint ignore=DL3004
RUN \
  set -eu && \
  export DEBIAN_FRONTEND=noninteractive && \
  sudo rm -rf /build; \
  sudo apt autoclean; \
  sudo rm -rf /var/cache/apt/archives/*
