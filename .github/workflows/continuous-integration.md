<!-- header:start -->

# GitHub Reusable Workflow: Continuous Integration

<div align="center">
  <img src="https://opengraph.githubassets.com/d5e57cf16fc3d73dd526b00fb06db7c968f95945c1de6e550770a5e00494dceb/hoverkraft-tech/docker-base-images" width="60px" align="center" alt="Continuous Integration" />
</div>

---

<!-- header:end -->
<!-- badges:start -->

[![Release](https://img.shields.io/github/v/release/hoverkraft-tech/docker-base-images)](https://github.com/hoverkraft-tech/docker-base-images/releases)
[![License](https://img.shields.io/github/license/hoverkraft-tech/docker-base-images)](http://choosealicense.com/licenses/mit/)
[![Stars](https://img.shields.io/github/stars/hoverkraft-tech/docker-base-images?style=social)](https://img.shields.io/github/stars/hoverkraft-tech/docker-base-images?style=social)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](https://github.com/hoverkraft-tech/docker-base-images/blob/main/CONTRIBUTING.md)

<!-- badges:end -->
<!-- overview:start -->

## Overview

A comprehensive CI workflow that performs linting, builds Docker images,
and runs tests against the built images using [testcontainers-go](https://golang.testcontainers.org/).

### Jobs

1. **linter**: Runs code linting using the shared linter workflow
2. **build-images**: Builds Docker images (depends on linter)
3. **prepare-test-matrix**: Prepares the matrix for test jobs
4. **test-images**: Runs testcontainers tests for each built image

### Permissions

- **`actions`**: `read`
- **`contents`**: `read`
- **`id-token`**: `write`
- **`issues`**: `write`
- **`packages`**: `write`
- **`pull-requests`**: `write`
- **`security-events`**: `write`
- **`statuses`**: `write`

<!-- overview:end -->

## Testing

Tests are defined in the `tests/` directory using [testcontainers-go](https://golang.testcontainers.org/).

### Test Configuration

Each image has corresponding test files in Go that:

- Start containers and execute commands
- Verify file existence and permissions
- Validate container metadata (env vars, user, workdir, etc.)
- Check command outputs and exit codes

### Example Test

```go
func TestCiHelm(t *testing.T) {
    ctx := context.Background()
    imageName := os.Getenv("IMAGE_NAME")
    if imageName == "" {
        imageName = "ci-helm:latest"
    }

    req := testcontainers.ContainerRequest{
        Image: imageName,
        Cmd:   []string{"sleep", "infinity"},
    }

    container, err := testcontainers.GenericContainer(ctx, ...)
    defer container.Terminate(ctx)

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
            t.Errorf("Expected output to contain 'version'")
        }
    })
}
```

<!-- usage:start -->

## Usage

```yaml
name: Continuous Integration
on:
  push:
    branches:
      - main
permissions: {}
jobs:
  continuous-integration:
    uses: hoverkraft-tech/docker-base-images/.github/workflows/continuous-integration.yml@ad965683cf180fd7b09b6bd3948fdc1a164c6661 # 0.2.0
    permissions: {}
    secrets:
      # Password or GitHub token (packages:read and packages:write scopes) used to log against the OCI registry.
      # Defaults to GITHUB_TOKEN if not provided.
      oci-registry-password: ""
    with:
      # JSON array of runner(s) to use.
      # See https://docs.github.com/en/actions/using-jobs/choosing-the-runner-for-a-job.
      #
      # Default: `["ubuntu-latest"]`
      runs-on: '["ubuntu-latest"]'

      # OCI registry where to pull and push images.
      # Default: `ghcr.io`
      oci-registry: ghcr.io

      # Username used to log against the OCI registry.
      # See https://github.com/docker/login-action#usage.
      #
      # Default: `${{ github.repository_owner }}`
      oci-registry-username: ${{ github.repository_owner }}

      # JSON array of platforms to build images for.
      # See https://docs.docker.com/buildx/working-with-buildx/#build-multi-platform-images.
      #
      # Default: `["linux/amd64","linux/arm64"]`
      platforms: '["linux/amd64","linux/arm64"]'

      # JSON array of images to build.
      # If not provided, all available images will be considered.
      # Example: `["php-8", "nodejs-24"]`
      images: ""
```

<!-- usage:end -->
<!-- inputs:start -->

## Inputs

### Workflow Call Inputs

| **Input**                   | **Description**                                                                        | **Required** | **Type**   | **Default**                        |
| --------------------------- | -------------------------------------------------------------------------------------- | ------------ | ---------- | ---------------------------------- |
| **`runs-on`**               | JSON array of runner(s) to use.                                                        | **false**    | **string** | `["ubuntu-latest"]`                |
|                             | See <https://docs.github.com/en/actions/using-jobs/choosing-the-runner-for-a-job>.     |              |            |                                    |
| **`oci-registry`**          | OCI registry where to pull and push images.                                            | **false**    | **string** | `ghcr.io`                          |
| **`oci-registry-username`** | Username used to log against the OCI registry.                                         | **false**    | **string** | `$\{\{ github.repository_owner }}` |
|                             | See <https://github.com/docker/login-action#usage>.                                    |              |            |                                    |
| **`platforms`**             | JSON array of platforms to build images for.                                           | **false**    | **string** | `["linux/amd64","linux/arm64"]`    |
|                             | See <https://docs.docker.com/buildx/working-with-buildx/#build-multi-platform-images>. |              |            |                                    |
| **`images`**                | JSON array of images to build.                                                         | **false**    | **string** | -                                  |
|                             | If not provided, all available images will be considered.                              |              |            |                                    |
|                             | Example: `["php-8", "nodejs-24"]`                                                      |              |            |                                    |

<!-- inputs:end -->

<!--
// jscpd:ignore-start
-->

<!-- secrets:start -->

## Secrets

| **Secret**                  | **Description**                                                                                          | **Required** |
| --------------------------- | -------------------------------------------------------------------------------------------------------- | ------------ |
| **`oci-registry-password`** | Password or GitHub token (packages:read and packages:write scopes) used to log against the OCI registry. | **false**    |
|                             | Defaults to GITHUB_TOKEN if not provided.                                                                |              |

<!-- secrets:end -->
<!-- outputs:start -->

## Outputs

| **Output**         | **Description**                                                                                                          |
| ------------------ | ------------------------------------------------------------------------------------------------------------------------ |
| **`built-images`** | Built images data.                                                                                                       |
|                    | See <https://github.com/hoverkraft-tech/ci-github-container/blob/main/.github/workflows/docker-build-images.md#outputs>. |

<!-- outputs:end -->

<!--
// jscpd:ignore-end
-->

<!-- examples:start -->
<!-- examples:end -->

<!--
// jscpd:ignore-start
-->

<!-- contributing:start -->

## Contributing

Contributions are welcome! Please see the [contributing guidelines](https://github.com/hoverkraft-tech/docker-base-images/blob/main/CONTRIBUTING.md) for more details.

<!-- contributing:end -->
<!-- security:start -->
<!-- security:end -->
<!-- license:start -->

## License

This project is licensed under the MIT License.

SPDX-License-Identifier: MIT

Copyright © 2025 hoverkraft-tech

For more details, see the [license](http://choosealicense.com/licenses/mit/).

<!-- license:end -->
<!-- generated:start -->

---

This documentation was automatically generated by [CI Dokumentor](https://github.com/hoverkraft-tech/ci-dokumentor).

<!-- generated:end -->

<!--
// jscpd:ignore-end
-->
