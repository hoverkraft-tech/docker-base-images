# testcontainers-go

Docker image for running testcontainers-go tests.

## Features

- Go 1.23 Alpine base
- Docker CLI installed for testcontainers
- gotestsum for test execution and reporting
- Pre-configured for running container tests

## Usage

This image is used internally for testing Docker images with testcontainers-go.

### Local Testing

```bash
make test <image-name>
```

### In CI

The image is built and used automatically in the CI pipeline to run tests against built images.

## Contents

- Go 1.23
- Docker CLI
- gotestsum
- Go module dependencies for testcontainers-go

Test files are mounted at runtime from each image directory (e.g., `images/ci-helm/test.go`).
