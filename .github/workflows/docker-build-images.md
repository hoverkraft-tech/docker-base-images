<!-- header:start -->

# GitHub Reusable Workflow: Build Docker images

<div align="center">
  <img src="../logo.svg" width="60px" align="center" alt="Build Docker images" />
</div>

---

<!-- header:end -->
<!-- badges:start -->

[![Release](https://img.shields.io/github/v/release/hoverkraft-tech/docker-base-images)](https://github.com/hoverkraft-tech/docker-base-images/releases)
[![License](https://img.shields.io/github/license/hoverkraft-tech/docker-base-images)](http://choosealicense.com/licenses/mit/)
[![Stars](https://img.shields.io/github/stars/hoverkraft-tech/docker-base-images?style=social)](https://img.shields.io/github/stars/hoverkraft-tech/docker-base-images?style=social)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](https://github.com/hoverkraft-tech/docker-base-images/blob/main/CONTRIBUTING.md)
![GitHub Verified Creator](https://img.shields.io/badge/GitHub-Verified%20Creator-4493F8?logo=data:image/svg%2bxml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxNiAxNiIgd2lkdGg9IjE2IiBoZWlnaHQ9IjE2IiBmaWxsPSJyZ2IoNjgsIDE0NywgMjQ4KSI+CiAgPHBhdGggZD0ibTkuNTg1LjUyLjkyOS42OGMuMTUzLjExMi4zMzEuMTg2LjUxOC4yMTVsMS4xMzguMTc1YTIuNjc4IDIuNjc4IDAgMCAxIDIuMjQgMi4yNGwuMTc0IDEuMTM5Yy4wMjkuMTg3LjEwMy4zNjUuMjE1LjUxOGwuNjguOTI4YTIuNjc3IDIuNjc3IDAgMCAxIDAgMy4xN2wtLjY4LjkyOGExLjE3NCAxLjE3NCAwIDAgMC0uMjE1LjUxOGwtLjE3NSAxLjEzOGEyLjY3OCAyLjY3OCAwIDAgMS0yLjI0MSAyLjI0MWwtMS4xMzguMTc1YTEuMTcgMS4xNyAwIDAgMC0uNTE4LjIxNWwtLjkyOC42OGEyLjY3NyAyLjY3NyAwIDAgMS0zLjE3IDBsLS45MjgtLjY4YTEuMTc0IDEuMTc0IDAgMCAwLS41MTgtLjIxNUwzLjgzIDE0LjQxYTIuNjc4IDIuNjc4IDAgMCAxLTIuMjQtMi4yNGwtLjE3NS0xLjEzOGExLjE3IDEuMTcgMCAwIDAtLjIxNS0uNTE4bC0uNjgtLjkyOGEyLjY3NyAyLjY3NyAwIDAgMSAwLTMuMTdsLjY4LS45MjhjLjExMi0uMTUzLjE4Ni0uMzMxLjIxNS0uNTE4bC4xNzUtMS4xNGEyLjY3OCAyLjY3OCAwIDAgMSAyLjI0LTIuMjRsMS4xMzktLjE3NWMuMTg3LS4wMjkuMzY1LS4xMDMuNTE4LS4yMTVsLjkyOC0uNjhhMi42NzcgMi42NzcgMCAwIDEgMy4xNyAwWk03LjMwMyAxLjcyOGwtLjkyNy42OGEyLjY3IDIuNjcgMCAwIDEtMS4xOC40ODlsLTEuMTM3LjE3NGExLjE3OSAxLjE3OSAwIDAgMC0uOTg3Ljk4N2wtLjE3NCAxLjEzNmEyLjY3NyAyLjY3NyAwIDAgMS0uNDg5IDEuMThsLS42OC45MjhhMS4xOCAxLjE4IDAgMCAwIDAgMS4zOTRsLjY4LjkyN2MuMjU2LjM0OC40MjQuNzUzLjQ4OSAxLjE4bC4xNzQgMS4xMzdjLjA3OC41MDkuNDc4LjkwOS45ODcuOTg3bDEuMTM2LjE3NGEyLjY3IDIuNjcgMCAwIDEgMS4xOC40ODlsLjkyOC42OGMuNDE0LjMwNS45NzkuMzA1IDEuMzk0IDBsLjkyNy0uNjhhMi42NyAyLjY3IDAgMCAxIDEuMTgtLjQ4OWwxLjEzNy0uMTc0YTEuMTggMS4xOCAwIDAgMCAuOTg3LS45ODdsLjE3NC0xLjEzNmEyLjY3IDIuNjcgMCAwIDEgLjQ4OS0xLjE4bC42OC0uOTI4YTEuMTc2IDEuMTc2IDAgMCAwIDAtMS4zOTRsLS42OC0uOTI3YTIuNjg2IDIuNjg2IDAgMCAxLS40ODktMS4xOGwtLjE3NC0xLjEzN2ExLjE3OSAxLjE3OSAwIDAgMC0uOTg3LS45ODdsLTEuMTM2LS4xNzRhMi42NzcgMi42NzcgMCAwIDEtMS4xOC0uNDg5bC0uOTI4LS42OGExLjE3NiAxLjE3NiAwIDAgMC0xLjM5NCAwWk0xMS4yOCA2Ljc4bC0zLjc1IDMuNzVhLjc1Ljc1IDAgMCAxLTEuMDYgMEw0LjcyIDguNzhhLjc1MS43NTEgMCAwIDEgLjAxOC0xLjA0Mi43NTEuNzUxIDAgMCAxIDEuMDQyLS4wMThMNyA4Ljk0bDMuMjItMy4yMmEuNzUxLjc1MSAwIDAgMSAxLjA0Mi4wMTguNzUxLjc1MSAwIDAgMSAuMDE4IDEuMDQyWiI+PC9wYXRoPgo8L3N2Zz4K)

<!-- badges:end -->
<!-- overview:start -->

## Overview

### Permissions

- **`contents`**: `read`
- **`id-token`**: `write`
- **`issues`**: `read`
- **`packages`**: `write`
- **`pull-requests`**: `write`

<!-- overview:end -->
<!-- usage:start -->

## Usage

```yaml
name: Build Docker images
on:
  push:
    branches:
      - main
permissions: {}
jobs:
  docker-build-images:
    uses: hoverkraft-tech/docker-base-images/.github/workflows/docker-build-images.yml@75c563e455402a2aad0e925a8df78ecf719551c7 # 0.6.0
    permissions:
      contents: read
      id-token: write
      issues: read
      packages: write
      pull-requests: write
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

      # JSON array of platforms to build images for by default.
      # Can be overridden per image with `images/<image>/build.json` or an image object in `images`.
      # See https://docs.docker.com/buildx/working-with-buildx/#build-multi-platform-images.
      #
      # Default: `["linux/amd64","linux/arm64"]`
      platforms: '["linux/amd64","linux/arm64"]'

      # JSON array of image names or image objects to build.
      # If not provided, all available images will be considered.
      # Examples: `["php-8", "nodejs-24"]`, `[{"name":"ci-helm","platforms":["linux/amd64"]}]`
      images: ""
```

<!-- usage:end -->

<!--
// jscpd:ignore-start
-->

<!-- inputs:start -->

## Inputs

### Workflow Call Inputs

| **Input**                   | **Description**                                                                              | **Required** | **Type**   | **Default**                      |
| --------------------------- | -------------------------------------------------------------------------------------------- | ------------ | ---------- | -------------------------------- |
| **`runs-on`**               | JSON array of runner(s) to use.                                                              | **false**    | **string** | `["ubuntu-latest"]`              |
|                             | See <https://docs.github.com/en/actions/using-jobs/choosing-the-runner-for-a-job>.           |              |            |                                  |
| **`oci-registry`**          | OCI registry where to pull and push images.                                                  | **false**    | **string** | `ghcr.io`                        |
| **`oci-registry-username`** | Username used to log against the OCI registry.                                               | **false**    | **string** | `${{ github.repository_owner }}` |
|                             | See <https://github.com/docker/login-action#usage>.                                          |              |            |                                  |
| **`platforms`**             | JSON array of platforms to build images for by default.                                      | **false**    | **string** | `["linux/amd64","linux/arm64"]`  |
|                             | Can be overridden per image with `images/<image>/build.json` or an image object in `images`. |              |            |                                  |
|                             | See <https://docs.docker.com/buildx/working-with-buildx/#build-multi-platform-images>.       |              |            |                                  |
| **`images`**                | JSON array of image names or image objects to build.                                         | **false**    | **string** | -                                |
|                             | If not provided, all available images will be considered.                                    |              |            |                                  |
|                             | Examples: `["php-8", "nodejs-24"]`, `[{"name":"ci-helm","platforms":["linux/amd64"]}]`       |              |            |                                  |

<!-- inputs:end -->

<!--
// jscpd:ignore-end
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

Copyright © 2026 hoverkraft-tech

For more details, see the [license](http://choosealicense.com/licenses/mit/).

<!-- license:end -->
<!-- generated:start -->

---

This documentation was automatically generated by [CI Dokumentor](https://github.com/hoverkraft-tech/ci-dokumentor).

<!-- generated:end -->

<!--
// jscpd:ignore-end
-->
