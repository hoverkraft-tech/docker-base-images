FROM golang:1.23-alpine

WORKDIR /tests

# Install docker cli (needed for testcontainers)
RUN apk add --no-cache docker-cli

# Copy test files
COPY tests/go.mod tests/go.sum ./
RUN go mod download

COPY tests/*.go ./

# Install gotestsum
RUN go install gotest.tools/gotestsum@v1.13.0

HEALTHCHECK --interval=5m --timeout=10s --start-period=30s --retries=3 CMD ["go", "version"]
