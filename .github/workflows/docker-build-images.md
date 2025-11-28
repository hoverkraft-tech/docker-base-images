<!-- header:start -->

# GitHub Reusable Workflow: Build Docker images

<div align="center">
  <img src="https://opengraph.githubassets.com/9565476f005871806c94e4706c94afdf476b35461ae854e19f08f3eb4fcacbfb/hoverkraft-tech/docker-base-images" width="60px" align="center" alt="Build Docker images" />
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
    uses: hoverkraft-tech/docker-base-images/.github/workflows/docker-build-images.yml@7e32f7efd335ebace32a5de08e8ce4c4d55227f2 # 0.1.0
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

| **Input**          | **Description**                                                                        | **Required** | **Type**   | **Default**                     |
| ------------------ | -------------------------------------------------------------------------------------- | ------------ | ---------- | ------------------------------- |
| **`runs-on`**      | JSON array of runner(s) to use.                                                        | **false**    | **string** | `["ubuntu-latest"]`             |
|                    | See <https://docs.github.com/en/actions/using-jobs/choosing-the-runner-for-a-job>.     |              |            |                                 |
| **`oci-registry`** | OCI registry where to pull and push images.                                            | **false**    | **string** | `ghcr.io`                       |
| **`platforms`**    | JSON array of platforms to build images for.                                           | **false**    | **string** | `["linux/amd64","linux/arm64"]` |
|                    | See <https://docs.docker.com/buildx/working-with-buildx/#build-multi-platform-images>. |              |            |                                 |
| **`images`**       | JSON array of images to build.                                                         | **false**    | **string** | -                               |
|                    | If not provided, all available images will be considered.                              |              |            |                                 |
|                    | Example: `["php-8", "nodejs-24"]`                                                      |              |            |                                 |

<!-- inputs:end -->
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
