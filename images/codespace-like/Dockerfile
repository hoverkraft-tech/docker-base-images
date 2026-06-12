#checkov:skip=CKV_DOCKER_2
#checkov:skip=CKV_DOCKER_3
#checkov:skip=CKV2_DOCKER_1
FROM ghcr.io/coder/code-server:trixie

LABEL org.opencontainers.image.description="vscode web server image with some quality of life improvements"

COPY src /build

USER root

# this is the setup part
# hadolint ignore=DL3004
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
  --mount=type=cache,target=/var/lib/apt,sharing=locked \
  echo "+ starting setup" && \
  for script in /build/scripts/root/*.sh; do \
  echo "running $script (as root)"; \
  bash "$script"; \
  done

USER coder

# this is the user config part
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
  --mount=type=cache,target=/var/lib/apt,sharing=locked \
  echo "+ starting user config" && \
  for script in /build/scripts/user/*.sh; do \
  echo "running $script"; \
  bash "$script"; \
  done

USER root

# cleaning
# hadolint ignore=DL3004
RUN \
  set -eu && \
  export DEBIAN_FRONTEND=noninteractive && \
  rm -rf /build && \
  apt-get autoclean && \
  rm -rf /var/lib/apt/lists/*

USER coder

HEALTHCHECK --interval=1m --timeout=10s --start-period=30s --retries=3 CMD code-server --version >/dev/null || exit 1

VOLUME /home/coder/work
