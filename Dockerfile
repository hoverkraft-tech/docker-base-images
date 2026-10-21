FROM ghcr.io/hoverkraft-tech/docker-base-images/super-linter:1.2.0@sha256:bedb8954f0c3e8849b40fd400282bb20a9b3476a1baad37ba7085584156e2a84

HEALTHCHECK --interval=5m --timeout=10s --start-period=30s --retries=3 CMD ["/bin/sh","-c","test -d /github/home"]
ARG UID=1000
ARG GID=1000
USER ${UID}:${GID}
