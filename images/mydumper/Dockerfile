FROM ubuntu:jammy

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=UTC \
    MYSQL_HOST=mysql \
    MYSQL_PORT=3306 \
    MYSQL_USER=root \
    MYSQL_PASSWORD=root \
    MYSQL_DATABASE="app" \
    MYDUMPER_THREADS=4 \
    MYDUMPER_COMPRESS=1 \
    MYDUMPER_EXTRA_OPTIONS="-e -F 100 --use-savepoints --less-locking" \
    KEEP_BACKUPS=7

# hadolint ignore=DL3008
RUN set -eux; \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        bzip2 ca-certificates mydumper pigz wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
VOLUME /backup
