<!-- header:start -->

# GitHub Reusable Workflow: Release

<div align="center">
  <img src="https://opengraph.githubassets.com/d9f8169450fbf604c0b6df55b8597e1f3d53ba81716246e23e884d75c053a34c/hoverkraft-tech/docker-base-images" width="60px" align="center" alt="Release" />
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
name: Release
on:
  push:
    branches:
      - main
permissions: {}
jobs:
  release:
    uses: hoverkraft-tech/docker-base-images/.github/workflows/release.yml@ec2269e2e489498080257a6db32669072d7ceac8 # main
    permissions: {}
    secrets:
      # GitHub token with permissions `contents: read`.
      github-token: ""

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

      # Whether the release is a prerelease
      prerelease: false
```

<!-- usage:end -->
<!-- inputs:start -->

## Inputs

### Workflow Call Inputs

| **Input**          | **Description**                                                                        | **Required** | **Type**    | **Default**                     |
| ------------------ | -------------------------------------------------------------------------------------- | ------------ | ----------- | ------------------------------- |
| **`runs-on`**      | JSON array of runner(s) to use.                                                        | **false**    | **string**  | `["ubuntu-latest"]`             |
|                    | See <https://docs.github.com/en/actions/using-jobs/choosing-the-runner-for-a-job>.     |              |             |                                 |
| **`oci-registry`** | OCI registry where to pull and push images.                                            | **false**    | **string**  | `ghcr.io`                       |
| **`platforms`**    | JSON array of platforms to build images for.                                           | **false**    | **string**  | `["linux/amd64","linux/arm64"]` |
|                    | See <https://docs.docker.com/buildx/working-with-buildx/#build-multi-platform-images>. |              |             |                                 |
| **`prerelease`**   | Whether the release is a prerelease                                                    | **false**    | **boolean** | `false`                         |

<!-- inputs:end -->
<!-- secrets:start -->

## Secrets

| **Secret**                  | **Description**                                                                                          | **Required** |
| --------------------------- | -------------------------------------------------------------------------------------------------------- | ------------ |
| **`github-token`**          | GitHub token with permissions `contents: read`.                                                          | **false**    |
| **`oci-registry-password`** | Password or GitHub token (packages:read and packages:write scopes) used to log against the OCI registry. | **false**    |
|                             | Defaults to GITHUB_TOKEN if not provided.                                                                |              |

<!-- secrets:end -->
<!-- outputs:start -->
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
