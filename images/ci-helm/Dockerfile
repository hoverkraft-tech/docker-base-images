ARG version=v3.12.0
FROM quay.io/helmpack/chart-testing:${version}

LABEL org.opencontainers.image.source="https://github.com/hoverkraft-tech/docker-base-images"

# we can probably ignore warning about versions of such packages
# hadolint ignore=DL3018
RUN apk add --no-cache jq yq curl openssl git

COPY scripts/ /usr/local/bin/
