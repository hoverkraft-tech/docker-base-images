ARG version=v3.12.0
FROM quay.io/helmpack/chart-testing:${version}

LABEL org.opencontainers.image.source="https://github.com/hoverkraft-tech/docker-base-images"

# we can probably ignore warning about versions of such packages
# hadolint ignore=DL3018
RUN --mount=type=cache,target=/var/cache/apt \
  set -ex \
  apk add jq yq curl openssl git

COPY scripts/ /usr/local/bin/

RUN \
  set ex; \
  addgroup -g 1000 helm && \
  adduser -u 1000 -G helm -s /bin/ash -D helm

USER helm:helm
WORKDIR /home/helm

RUN --mount=type=cache,target=/home/.cache \
  set -ex; \
  helm plugin install https://github.com/jtyr/kubeconform-helm --version 0.1.17; \
  helm plugin install https://github.com/losisin/helm-values-schema-json.git --version 1.6.4;
