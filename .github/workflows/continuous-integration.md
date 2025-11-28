<!-- header:start -->

# GitHub Reusable Workflow: Continuous Integration

<div align="center">
  <img src="https://opengraph.githubassets.com/9565476f005871806c94e4706c94afdf476b35461ae854e19f08f3eb4fcacbfb/hoverkraft-tech/docker-base-images" width="60px" align="center" alt="Continuous Integration" />
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

A comprehensive CI workflow that performs linting, builds Docker images, and runs tests against the built images using testcontainers.

### Jobs

1. **linter**: Runs code linting using the shared linter workflow
2. **build-images**: Builds Docker images (depends on linter)
3. **prepare-test-matrix**: Prepares the matrix for test jobs
4. **test-images**: Runs tests for each image that has a tests directory

### Permissions

- **`actions`**: `read`
- **`contents`**: `read`
- **`id-token`**: `write`
- **`issues`**: `read`
- **`packages`**: `write`
- **`pull-requests`**: `write`
- **`security-events`**: `write`
- **`statuses`**: `write`

<!-- overview:end -->
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
  ci:
    uses: hoverkraft-tech/docker-base-images/.github/workflows/continuous-integration.yml@main
    permissions:
      actions: read
      contents: read
      id-token: write
      issues: read
      packages: write
      pull-requests: write
      security-events: write
      statuses: write
    secrets:
      # Password or GitHub token (packages:read and packages:write scopes)
      # used to log against the OCI registry.
      # Defaults to GITHUB_TOKEN if not provided.
      oci-registry-password: ${{ github.token }}
    with:
      # JSON array of runner(s) to use.
      # See https://docs.github.com/en/actions/using-jobs/choosing-the-runner-for-a-job.
      #
      # Default: `["ubuntu-latest"]`
      runs-on: '["ubuntu-latest"]'

      # OCI registry where to pull and push images.
      # Default: `ghcr.io`
      oci-registry: ghcr.io

      # JSON array of platforms to build images for.
      # Default: `["linux/amd64","linux/arm64"]`
      platforms: '["linux/amd64","linux/arm64"]'

      # JSON array of images to build.
      # If not provided, all available images will be considered.
      # Example: `["php-8", "nodejs-24"]`
      images: ""
```

<!-- usage:end -->
<!--
// jscpd:ignore-start
-->
<!-- inputs:start -->

## Inputs

### Workflow Call Inputs

| **Input**          | **Description**                                                                               | **Required** | **Type**   | **Default**                     |
| ------------------ | --------------------------------------------------------------------------------------------- | ------------ | ---------- | ------------------------------- |
| **`runs-on`**      | JSON array of runner(s) to use.                                                               | **false**    | **string** | `["ubuntu-latest"]`             |
|                    | See <https://docs.github.com/en/actions/using-jobs/choosing-the-runner-for-a-job>.            |              |            |                                 |
| **`oci-registry`** | OCI registry where to pull and push images.                                                   | **false**    | **string** | `ghcr.io`                       |
| **`platforms`**    | JSON array of platforms to build images for.                                                  | **false**    | **string** | `["linux/amd64","linux/arm64"]` |
|                    | See <https://docs.docker.com/buildx/working-with-buildx/#build-multi-platform-images>.        |              |            |                                 |
| **`images`**       | JSON array of images to build. If not provided, all available images will be considered.      | **false**    | **string** |                                 |

<!-- inputs:end -->
<!-- secrets:start -->

## Secrets

| **Secret**                  | **Description**                                                                              | **Required** |
| --------------------------- | -------------------------------------------------------------------------------------------- | ------------ |
| **`oci-registry-password`** | Password or GitHub token (packages:read and packages:write scopes) for OCI registry access.  | **false**    |
|                             | Defaults to GITHUB_TOKEN if not provided.                                                    |              |

<!-- secrets:end -->
<!-- outputs:start -->

## Outputs

| **Output**         | **Description**                                                                               |
| ------------------ | --------------------------------------------------------------------------------------------- |
| **`built-images`** | Built images data. See docker-build-images.md for the format.                                 |

<!-- outputs:end -->

## Testing

Tests are located in `images/<image-name>/tests/` and use [testcontainers](https://node.testcontainers.org/).

### Test Structure

Each image can have a `tests` directory with:

- `package.json` - Node.js dependencies including testcontainers
- `*.test.js` - Test files using Node.js built-in test runner

### Running Tests Locally

```bash
# Test a specific image
make test ci-helm

# Test all images
make test-all
```

<!--
// jscpd:ignore-end
-->
<!-- contributing:start -->

## Contributing

Contributions are welcome! Please see the [contributing guidelines](https://github.com/hoverkraft-tech/docker-base-images/blob/main/CONTRIBUTING.md) for more details.

<!-- contributing:end -->
<!-- license:start -->

## License

This project is licensed under the MIT License.

SPDX-License-Identifier: MIT

Copyright © 2025 hoverkraft-tech

For more details, see the [license](http://choosealicense.com/licenses/mit/).

<!-- license:end -->
