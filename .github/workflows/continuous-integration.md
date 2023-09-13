<!-- start title -->

# GitHub Reusable Workflow: Continuous Integration for Docker images

<!-- end title -->
<!-- start description -->

Workflow to perform CI tasks:

- Linting
- Build images
- Update Pull Request with built images
- Delete built images once Pull Request is merged

<!-- end description -->
<!-- start contents -->
<!-- end contents -->
<!-- start usage -->

```yaml
name: Pull request - Continuous Integration

on:
  pull_request:
    branches: [main]

jobs:
  ci:
    uses: hoverkraft-tech/docker-base-images/.github/workflows/continous-integration.yml@0.1.0
    with:
      oci-registry: ${{ vars.OCI_REGISTRY }}
    secrets:
      oci-registry-password: ${{ secrets.GHCR_PAT_TOKEN }}
```

<!-- end usage -->

<!-- start secrets -->

| **Secret**                             | **Description**                                                                                                                                                                                                                                                                                                                      |
| -------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **<code>oci-registry-password</code>** | Password or GitHub token (packages:read and packages:write scopes) used to log against the OCI registry. See [https://github.com/hoverkraft-tech/ci-github-container/blob/main/.github/workflows/docker-build-images.md](https://github.com/hoverkraft-tech/ci-github-container/blob/main/.github/workflows/docker-build-images.md). |

<!-- end secrets -->
<!-- start inputs -->

| **Input**                              | **Description**                                                                                                                                                                                                                                                           | **Default**                                               | **Required** |
| -------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------- | ------------ |
| **<code>oci-registry</code>**          | OCI registry where to pull and push images                                                                                                                                                                                                                                | <code>ghcr.io</code>                                      | **false**    |
| **<code>oci-registry-username</code>** | Username used to log against the OCI registry. See [https://github.com/hoverkraft-tech/ci-github-container/blob/main/.github/workflows/docker-build-images.md](https://github.com/hoverkraft-tech/ci-github-container/blob/main/.github/workflows/docker-build-images.md) | <code>${{ github.repository_owner }}</code>               | **false**    |
| **<code>platforms</code>**             | Platforms to build images for</code>                                                                                                                                                                                                                                      | <code>["linux/amd64","linux/arm64","linux/arm/v7"]</code> | **true**     |

<!-- end inputs -->

<!-- start outputs -->

| **Output**                | **Description**                                                                                                                                                                                                                                         |
| ------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| <code>built-images</code> | Built images names and tags. See [https://github.com/hoverkraft-tech/ci-github-container/blob/main/.github/workflows/docker-build-images.md](https://github.com/hoverkraft-tech/ci-github-container/blob/main/.github/workflows/docker-build-images.md) |

<!-- end outputs -->

<!-- start [.github/ghadocs/examples/] -->
<!-- end [.github/ghadocs/examples/] -->
