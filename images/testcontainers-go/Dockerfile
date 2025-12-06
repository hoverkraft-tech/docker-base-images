FROM golang:1.23-alpine

WORKDIR /workspace

# Install docker cli (needed for testcontainers)
RUN apk add --no-cache docker-cli

# Copy go module files from testcontainers-go (for gotestsum)
COPY images/testcontainers-go/go.mod images/testcontainers-go/go.sum ./testcontainers-go/
WORKDIR /workspace/testcontainers-go
RUN go mod download

# Copy go module files and test files from each image
WORKDIR /workspace
COPY images/ci-helm/go.mod images/ci-helm/go.sum images/ci-helm/test.go ./ci-helm/
COPY images/mydumper/go.mod images/mydumper/go.sum images/mydumper/test.go ./mydumper/
COPY images/argocd-cmp-hk-deployment/go.mod images/argocd-cmp-hk-deployment/go.sum images/argocd-cmp-hk-deployment/test.go ./argocd-cmp-hk-deployment/

# Download dependencies for each module
RUN cd ci-helm && go mod download && \
    cd ../mydumper && go mod download && \
    cd ../argocd-cmp-hk-deployment && go mod download

# Install gotestsum from testcontainers-go module
WORKDIR /workspace/testcontainers-go
RUN go install gotest.tools/gotestsum@v1.13.0

WORKDIR /workspace

HEALTHCHECK --interval=5m --timeout=10s --start-period=30s --retries=3 CMD ["go", "version"]
