FROM ghcr.io/super-linter/super-linter:slim-v8.0.0 AS linter

HEALTHCHECK --interval=5m --timeout=10s --start-period=30s --retries=3 CMD ["/bin/sh","-c","test -d /github/home"]
ARG UID=1000
ARG GID=1000
RUN chown -R ${UID}:${GID} /github/home
USER ${UID}:${GID}

ENV RUN_LOCAL=true 
ENV USE_FIND_ALGORITHM=true
ENV LOG_LEVEL=WARN
ENV LOG_FILE="/github/home/logs"

FROM golang:1.23-alpine AS testcontainers

WORKDIR /tests

# Install docker cli (needed for testcontainers)
RUN apk add --no-cache docker-cli

# Copy test files
COPY tests/go.mod tests/go.sum ./
RUN go mod download

COPY tests/*.go ./

# Build test binaries
RUN go test -c -o /tests/test.bin

HEALTHCHECK --interval=5m --timeout=10s --start-period=30s --retries=3 CMD ["go", "version"]
