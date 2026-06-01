#checkov:skip=CKV_DOCKER_2
#checkov:skip=CKV_DOCKER_3
#checkov:skip=CKV2_DOCKER_1
FROM ghcr.io/coder/code-server:trixie

LABEL org.opencontainers.image.description="vscode web server image with some quality of life improvements"

COPY src /build

# this is the setup part
# hadolint ignore=DL3004
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
  echo "+ starting setup" && \
  for script in /build/scripts/root/*.sh; do \
    echo "running $script (as root)"; \
    sudo bash "$script"; \
  done

# this is the user config part
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
  echo "+ starting user config" && \
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
  sudo apt autoclean

  VOLUME /home/coder/work
