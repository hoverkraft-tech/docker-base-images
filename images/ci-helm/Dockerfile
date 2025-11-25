FROM quay.io/helmpack/chart-testing:v3.14.0

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
  # Should be updated via dependabot. See https://github.com/jtyr/kubeconform-helm/tags
  helm plugin install https://github.com/jtyr/kubeconform-helm --version 0.2.0; \
  # Should be updated via dependabot. See https://github.com/losisin/helm-values-schema-json/releases
  helm plugin install https://github.com/losisin/helm-values-schema-json.git --version 2.3.0;

HEALTHCHECK --interval=1m --timeout=10s --start-period=30s --retries=3 CMD helm version
