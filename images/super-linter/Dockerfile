FROM ghcr.io/super-linter/super-linter:slim-v8.7.0

USER root
RUN sed -i '/LINTER_COMMANDS_ARRAY_JSCPD+=("${JSCPD_GITIGNORE_OPTION}")/d' /action/lib/functions/linterCommands.sh

HEALTHCHECK --interval=5m --timeout=10s --start-period=30s --retries=3 CMD ["/bin/sh", "-c", "test -d /github/home"]

COPY entrypoint.sh /usr/local/bin/super-linter-entrypoint
RUN chmod 755 /usr/local/bin/super-linter-entrypoint

ARG UID=1000
ARG GID=1000
RUN chown -R ${UID}:${GID} /github/home

USER ${UID}:${GID}

ENTRYPOINT ["/usr/local/bin/super-linter-entrypoint"]

ONBUILD USER root
ONBUILD ARG UID=1000
ONBUILD ARG GID=1000
ONBUILD RUN chown -R ${UID}:${GID} /github/home
ONBUILD USER ${UID}:${GID}
