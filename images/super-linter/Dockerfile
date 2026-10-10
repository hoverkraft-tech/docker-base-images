FROM ghcr.io/super-linter/super-linter:slim-v9.0.0

HEALTHCHECK --interval=5m --timeout=10s --start-period=30s --retries=3 CMD ["/bin/sh", "-c", "test -d /github/home"]

COPY entrypoint.sh /usr/local/bin/super-linter-entrypoint
COPY actionlint.sh /usr/local/bin/actionlint
COPY commitlint.config.cjs /usr/local/lib/super-linter/
RUN chmod 755 /usr/local/bin/super-linter-entrypoint /usr/local/bin/actionlint

ARG UID=0
ARG GID=0
RUN chown -R ${UID}:${GID} /github/home

USER ${UID}:${GID}

ENTRYPOINT ["/usr/local/bin/super-linter-entrypoint"]

ONBUILD USER root
ONBUILD ARG UID=1000
ONBUILD ARG GID=1000
ONBUILD RUN chown -R ${UID}:${GID} /github/home
ONBUILD USER ${UID}:${GID}
