FROM golang:1.25-alpine

WORKDIR /workspace

# Install docker cli (needed for testcontainers)
RUN apk add --no-cache docker-cli \
    && addgroup -S tester \
    && adduser -S -G tester tester

# Copy go module files and install tools
COPY images/testcontainers-go/go.mod images/testcontainers-go/go.sum ./
RUN go mod download \
    && go install gotest.tools/gotestsum

# Drop privileges
USER tester

HEALTHCHECK --interval=5m --timeout=10s --start-period=30s --retries=3 CMD ["go", "version"]
