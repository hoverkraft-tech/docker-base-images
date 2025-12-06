# Testcontainers Migration Guide

This document describes the migration from container-structure-test to testcontainers-go.

## Overview

The repository has migrated from using [container-structure-test](https://github.com/GoogleContainerTools/container-structure-test) to [testcontainers-go](https://golang.testcontainers.org/) for testing Docker images.

## Why Testcontainers?

- **More flexible**: Go-based tests provide more control and flexibility than YAML configs
- **Better integration**: Native Go test framework with better CI/CD integration
- **Maintainable**: Code-based tests are easier to maintain and extend
- **Industry standard**: Testcontainers is widely adopted across multiple languages

## Architecture

### Test Structure

```text
tests/
├── go.mod                              # Go module definition
├── go.sum                              # Go dependencies
├── helpers.go                          # Shared test utilities
├── ci_helm_test.go                     # Tests for ci-helm image
├── argocd_cmp_hk_deployment_test.go   # Tests for argocd-cmp-hk-deployment image
└── mydumper_test.go                    # Tests for mydumper image
```

### Test Pattern

Each test file follows this pattern:

```go
func TestImageName(t *testing.T) {
    ctx := context.Background()
    imageName := os.Getenv("IMAGE_NAME")
    if imageName == "" {
        imageName = "default-name:latest"
    }

    req := testcontainers.ContainerRequest{
        Image: imageName,
        Cmd:   []string{"sleep", "infinity"},
    }

    container, err := testcontainers.GenericContainer(ctx, ...)
    defer container.Terminate(ctx)

    t.Run("test case name", func(t *testing.T) {
        // Test implementation
    })
}
```

## Running Tests

### Local Development

Using Make (recommended):

```bash
make test ci-helm      # Test specific image
make test-all          # Test all images
```

Using the test script:

```bash
./run-tests.sh ci-helm
```

### CI/CD

Tests run automatically in GitHub Actions using the `continuous-integration.yml` workflow:

1. Images are built and pushed to the registry
2. Tests are executed using `setup-go` action
3. Results are reported in JUnit XML format

## Migration from container-structure-test

### Command Tests

**Before (YAML):**

```yaml
commandTests:
  - name: "helm is installed"
    command: "helm"
    args: ["version"]
    exitCode: 0
    expectedOutput: ["version"]
```

**After (Go):**

```go
t.Run("helm is installed", func(t *testing.T) {
    code, reader, err := container.Exec(ctx, []string{"helm", "version"})
    if err != nil {
        t.Fatalf("Failed to execute command: %s", err)
    }
    if code != 0 {
        t.Fatalf("Expected exit code 0, got %d", code)
    }
    output := readOutput(t, reader)
    if !strings.Contains(output, "version") {
        t.Errorf("Expected output to contain 'version', got: %s", output)
    }
})
```

### File Existence Tests

**Before (YAML):**

```yaml
fileExistenceTests:
  - name: "script exists and is executable"
    path: "/usr/local/bin/script.sh"
    shouldExist: true
    isExecutableBy: "any"
```

**After (Go):**

```go
t.Run("script exists and is executable", func(t *testing.T) {
    code, _, err := container.Exec(ctx, []string{"test", "-x", "/usr/local/bin/script.sh"})
    if err != nil {
        t.Fatalf("Failed to execute command: %s", err)
    }
    if code != 0 {
        t.Fatalf("Expected script to exist and be executable")
    }
})
```

### Metadata Tests

**Before (YAML):**

```yaml
metadataTest:
  user: "helm:helm"
  workdir: "/home/helm"
```

**After (Go):**

```go
t.Run("metadata: user is helm", func(t *testing.T) {
    code, reader, err := container.Exec(ctx, []string{"id", "-un"})
    if err != nil {
        t.Fatalf("Failed to execute command: %s", err)
    }
    if code != 0 {
        t.Fatalf("Expected exit code 0, got %d", code)
    }
    username := strings.TrimSpace(readOutput(t, reader))
    if username != "helm" {
        t.Errorf("Expected user 'helm', got: %s", username)
    }
})

t.Run("metadata: workdir is /home/helm", func(t *testing.T) {
    code, reader, err := container.Exec(ctx, []string{"pwd"})
    if err != nil {
        t.Fatalf("Failed to execute command: %s", err)
    }
    if code != 0 {
        t.Fatalf("Expected exit code 0, got %d", code)
    }
    workdir := strings.TrimSpace(readOutput(t, reader))
    if workdir != "/home/helm" {
        t.Errorf("Expected workdir '/home/helm', got: %s", workdir)
    }
})
```

### Environment Variable Tests

**Before (YAML):**

```yaml
commandTests:
  - name: "test with env vars"
    command: "script.sh"
    envVars:
      - key: "VAR1"
        value: "value1"
```

**After (Go):**

```go
t.Run("test with env vars", func(t *testing.T) {
    code, reader, err := container.Exec(ctx,
        []string{"script.sh"},
        testcontainers.WithEnv(map[string]string{
            "VAR1": "value1",
        }))
    // ... rest of test
})
```

## Developer Experience

### Prerequisites

- Docker
- Make

No Go installation is required for local testing when using `make test`, as tests run in a containerized environment.

### Adding New Tests

1. Create a new test file in the `tests/` directory (e.g., `tests/new_image_test.go`)
2. Follow the test pattern shown above
3. Run `make test new_image` to verify
4. Tests will automatically run in CI for built images

### Test Utilities

The `tests/helpers.go` file provides shared utilities:

- `readOutput(t, reader)`: Reads command output from a container

Add more utilities as needed to keep tests DRY.

## Troubleshooting

### Docker Socket Issues

If tests fail with "Cannot connect to Docker daemon":

- Ensure Docker is running
- Check that `/var/run/docker.sock` is accessible
- On CI, ensure the Docker socket is mounted correctly

### Image Not Found

If tests fail with image not found:

- Ensure the image is built first: `make build <image-name>`
- Check that the IMAGE_NAME environment variable is set correctly
- Verify the image exists: `docker images | grep <image-name>`

### Go Module Issues

If you see module resolution errors:

```bash
cd tests
go mod tidy
go mod download
```

## References

- [Testcontainers Go Documentation](https://golang.testcontainers.org/)
- [Go Testing Package](https://pkg.go.dev/testing)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
