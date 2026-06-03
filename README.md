# Docker base images

<div align="center">
 <img src=".github/logo.svg" width="60px" align="center" alt="Logo for Docker base images" />
</div>

---

![GitHub Verified Creator](https://img.shields.io/badge/GitHub-Verified%20Creator-4493F8?logo=data:image/svg%2bxml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxNiAxNiIgd2lkdGg9IjE2IiBoZWlnaHQ9IjE2IiBmaWxsPSJyZ2IoNjgsIDE0NywgMjQ4KSI+CiAgPHBhdGggZD0ibTkuNTg1LjUyLjkyOS42OGMuMTUzLjExMi4zMzEuMTg2LjUxOC4yMTVsMS4xMzguMTc1YTIuNjc4IDIuNjc4IDAgMCAxIDIuMjQgMi4yNGwuMTc0IDEuMTM5Yy4wMjkuMTg3LjEwMy4zNjUuMjE1LjUxOGwuNjguOTI4YTIuNjc3IDIuNjc3IDAgMCAxIDAgMy4xN2wtLjY4LjkyOGExLjE3NCAxLjE3NCAwIDAgMC0uMjE1LjUxOGwtLjE3NSAxLjEzOGEyLjY3OCAyLjY3OCAwIDAgMS0yLjI0MSAyLjI0MWwtMS4xMzguMTc1YTEuMTcgMS4xNyAwIDAgMC0uNTE4LjIxNWwtLjkyOC42OGEyLjY3NyAyLjY3NyAwIDAgMS0zLjE3IDBsLS45MjgtLjY4YTEuMTc0IDEuMTc0IDAgMCAwLS41MTgtLjIxNUwzLjgzIDE0LjQxYTIuNjc4IDIuNjc4IDAgMCAxLTIuMjQtMi4yNGwtLjE3NS0xLjEzOGExLjE3IDEuMTcgMCAwIDAtLjIxNS0uNTE4bC0uNjgtLjkyOGEyLjY3NyAyLjY3NyAwIDAgMSAwLTMuMTdsLjY4LS45MjhjLjExMi0uMTUzLjE4Ni0uMzMxLjIxNS0uNTE4bC4xNzUtMS4xNGEyLjY3OCAyLjY3OCAwIDAgMSAyLjI0LTIuMjRsMS4xMzktLjE3NWMuMTg3LS4wMjkuMzY1LS4xMDMuNTE4LS4yMTVsLjkyOC0uNjhhMi42NzcgMi42NzcgMCAwIDEgMy4xNyAwWk03LjMwMyAxLjcyOGwtLjkyNy42OGEyLjY3IDIuNjcgMCAwIDEtMS4xOC40ODlsLTEuMTM3LjE3NGExLjE3OSAxLjE3OSAwIDAgMC0uOTg3Ljk4N2wtLjE3NCAxLjEzNmEyLjY3NyAyLjY3NyAwIDAgMS0uNDg5IDEuMThsLS42OC45MjhhMS4xOCAxLjE4IDAgMCAwIDAgMS4zOTRsLjY4LjkyN2MuMjU2LjM0OC40MjQuNzUzLjQ4OSAxLjE4bC4xNzQgMS4xMzdjLjA3OC41MDkuNDc4LjkwOS45ODcuOTg3bDEuMTM2LjE3NGEyLjY3IDIuNjcgMCAwIDEgMS4xOC40ODlsLjkyOC42OGMuNDE0LjMwNS45NzkuMzA1IDEuMzk0IDBsLjkyNy0uNjhhMi42NyAyLjY3IDAgMCAxIDEuMTgtLjQ4OWwxLjEzNy0uMTc0YTEuMTggMS4xOCAwIDAgMCAuOTg3LS45ODdsLjE3NC0xLjEzNmEyLjY3IDIuNjcgMCAwIDEgLjQ4OS0xLjE4bC42OC0uOTI4YTEuMTc2IDEuMTc2IDAgMCAwIDAtMS4zOTRsLS42OC0uOTI3YTIuNjg2IDIuNjg2IDAgMCAxLS40ODktMS4xOGwtLjE3NC0xLjEzN2ExLjE3OSAxLjE3OSAwIDAgMC0uOTg3LS45ODdsLTEuMTM2LS4xNzRhMi42NzcgMi42NzcgMCAwIDEtMS4xOC0uNDg5bC0uOTI4LS42OGExLjE3NiAxLjE3NiAwIDAgMC0xLjM5NCAwWk0xMS4yOCA2Ljc4bC0zLjc1IDMuNzVhLjc1Ljc1IDAgMCAxLTEuMDYgMEw0LjcyIDguNzhhLjc1MS43NTEgMCAwIDEgLjAxOC0xLjA0Mi43NTEuNzUxIDAgMCAxIDEuMDQyLS4wMThMNyA4Ljk0bDMuMjItMy4yMmEuNzUxLjc1MSAwIDAgMSAxLjA0Mi4wMTguNzUxLjc1MSAwIDAgMSAuMDE4IDEuMDQyWiI+PC9wYXRoPgo8L3N2Zz4K)
[![Continuous Integration](https://github.com/hoverkraft-tech/docker-base-images/actions/workflows/__main-ci.yml/badge.svg)](https://github.com/hoverkraft-tech/docker-base-images/actions/workflows/__main-ci.yml)
[![GitHub tag](https://img.shields.io/github/tag/hoverkraft-tech/docker-base-images?include_prereleases=&sort=semver&color=blue)](https://github.com/hoverkraft-tech/docker-base-images/releases/)
[![License](https://img.shields.io/badge/License-MIT-blue)](#license)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)

## Overview

Opinionated Docker base images.

This repository offers:

- a set of Docker base images that can be used as a foundation for building other Docker images.
- GitHub Actions and reusable workflows to help you build and publish your own "Docker base images" repository.

## Our images

### [argocd-cmp-hk-deployment](images/argocd-cmp-hk-deployment/README.md)

### [ci-helm](images/ci-helm/README.md)

A Docker image with all the tools needed to validate an helm chart

- helm chart-testing (aka ct)
- helm kubeconform plugin

### [codespace-like](images/codespace-like/README.md)

A tailored build of VS code-server instance.
Used for our labs and workshops.

### [mydumper](images/mydumper/README.md)

An image with an opiniated mydumper command as entrypoint

### [super-linter](images/super-linter/README.md)

An opinionated Super-Linter image with safer local defaults and toolchain-conflict guards

### [testcontainers-node](images/testcontainers-node/README.md)

A Docker image for running testcontainers tests with Node.js

## Actions

_Actions that you can plug directly into your own Docker images repository._

### - [Get available images](actions/get-available-images/README.md)

### - [Should build images](actions/should-build-images/README.md)

## Reusable Workflows

### Get available images matrix

_Orchestrated workflows you can plug directly into your own Docker images repository._

### - [Continuous Integration](.github/workflows/continuous-integration.md)

### - [Prune pull requests images tags](.github/workflows/prune-pull-requests-images-tags.md)

### - [Get available images matrix](.github/workflows/get-available-images-matrix.md)

## Contributing

Contributions are welcome! Please see the [contributing guidelines](https://github.com/hoverkraft-tech/docker-base-images/blob/main/CONTRIBUTING.md) for more details.

### Action Structure Pattern

All actions follow this consistent structure:

```text
actions/{category}/{action-name}/
├── action.yml          # Action definition with inputs/outputs
├── README.md          # Usage documentation
└── *.js              # Optional Node.js scripts (e.g., prepare-site.js)
```

### Development Standards

#### Action Definition Standards

1. **Consistent branding**: All actions use `author: hoverkraft`, `icon: <specific-icon>`, `color: blue`
2. **Composite actions**: Use `using: "composite"` with GitHub Script for complex logic
3. **Pinned dependencies**: Always pin action versions with SHA (e.g., `@ed597411d8f924073f98dfc5c65a23a2325f34cd`)
4. **Input validation**: Validate inputs early in GitHub Script steps

#### JavaScript Patterns

- **Class-based architecture**: Use classes like `AssetManager` for complex functionality
- **Path utilities**: Extensive use of Node.js `path` module for cross-platform compatibility
- **Regular expression patterns**: Define constants for reusable patterns (`MARKDOWN_IMAGE_REGEX`, `HTML_IMAGE_REGEX`)
- **Caching**: Implement Map-based caching for expensive operations

### Development Workflow

#### Prerequisites

- [Docker](https://docs.docker.com/get-docker/)
- Make

#### Linting & Testing

```bash
make lint        # Run Super Linter (dockerized)
make lint-fix    # Auto-fix issues where possible

# Run tests for a specific image
make test ci-helm      # Build and test ci-helm image
make test mydumper     # Build and test mydumper image

# Run tests for all images
make test-all          # Build and test all images

# Use GitHub Actions locally with `act`
gh act -W .github/workflows/workflow-file-to-test.yml
```

**Testing Infrastructure:**

Tests use [testcontainers](https://testcontainers.com/modules/nodejs/) for Node.js to validate Docker images. The test framework:

- Requires only Docker and Make (no local Node.js installation needed for `make test`)
- Runs tests in a containerized environment for consistency
- Tests are colocated with their respective images (e.g., `images/ci-helm/ci-helm.test.js`)
- Each test validates: command availability, file existence, metadata, and environment variables
- All tests share a single Node.js module in `images/testcontainers-node/`

How tests are executed in this repository:

- `make test <image>` builds the image and runs tests inside the `images/testcontainers-node` runner image.
- Each test run also writes a JUnit report to `images/<image>/junit.xml`.
- The harness injects:
  - `TESTED_IMAGE_REF`: the image ref to test (e.g. `ci-helm:latest` locally, or an OCI ref in CI)

**Writing good image tests (recommended):**

- Keep tests **black-box**: validate behavior via commands, files, users, workdir, and env.
- Make tests **deterministic**: avoid network calls and time-based assertions when possible.
- Start the container once per suite (`before`/`after`) and **always clean up**.
- Prefer `container.exec(cmd, { env, workingDir })` over shell string interpolation for env handling.
- Use a long-running command like `sleep infinity` so you can run multiple `exec` checks.

Basic example (`images/<image>/<image>.test.js`):

```js
import { after, before, describe, it } from "node:test";
import assert from "node:assert";
import { GenericContainer } from "testcontainers";

describe("My Image", () => {
  const testedImageRef = process.env.TESTED_IMAGE_REF;
  let container;

  if (!testedImageRef) {
    throw new Error("TESTED_IMAGE_REF environment variable is required");
  }

  before(async () => {
    container = await new GenericContainer(testedImageRef)
      .withCommand(["sleep", "infinity"])
      .start();
  });

  after(async () => {
    await container?.stop();
  });

  it("has the expected tool", async () => {
    const { exitCode, output } = await container.exec(["mytool", "--version"], {
      env: { MY_FLAG: "1" },
      workingDir: "/",
    });

    assert.strictEqual(exitCode, 0);
    assert.match(output, /mytool/i);
  });

  it("runs as the expected user", async () => {
    const { exitCode, output } = await container.exec(["id", "-un"]);
    assert.strictEqual(exitCode, 0);
    assert.strictEqual(output.trim(), "myuser");
  });
});
```

#### File Conventions

- **Dockerfile**: Uses Super Linter slim image for consistent code quality
- **Tests**: Located in each image directory (e.g., `images/*/<image>.test.js`) using [testcontainers](https://testcontainers.com/modules/nodejs/) for Node.js
- **Workflows**: Private workflows prefixed with `__` (e.g., `__main-ci.yml`)

#### Action Development Conventions

**Always follow these patterns when creating/modifying actions:**

1. **Pinned Dependencies**: Use exact SHA commits for all action dependencies:

   ```yaml
   uses: actions/github-script@ed597411d8f924073f98dfc5c65a23a2325f34cd # v8.0.0
   ```

2. **Consistent Branding**: Every action.yml must include:

   ```yaml
   author: hoverkraft
   branding:
     icon: <specific-icon>
     color: blue
   ```

3. **Input Validation**: Always validate inputs early in GitHub Script steps:
   ```javascript
   const urlInput = ${{ toJson(inputs.url ) }};
   if (!urlInput) {
     return core.setFailed("URL input is required.");
   }
   ```

#### JavaScript Development Patterns

**For `actions/github-script` steps (composite actions):**

- Prefer small, focused scripts with early input validation.
- Use Node.js built-ins via `node:` (e.g., `node:path`).
- Keep outputs stable and JSON-encoded when returning structured data.
- Favor readable helpers (small functions) over clever one-liners.

#### File Structure Understanding

```text
actions/                              # Composite actions (using actions/github-script)
├── get-available-images/
│   ├── action.yml
│   └── README.md
└── ***/
  ├── action.yml
  └── README.md

.github/workflows/                    # Reusable workflows (+ their .md docs)
├── continuous-integration.yml
├── continuous-integration.md
├── ***.yml
├── ***.md
└── __*.yml                           # Private/internal workflows

images/                               # Docker images (each image is self-contained)
└── <image>/
  ├── Dockerfile
  ├── README.md
  ├── <image-name>.test.js          # Node.js tests (run via make/CI)
  └── tests/                        # Optional fixtures used by some tests
```

### Continuous Integration

#### Pull requests

##### Pull requests checks

- Validate that pull request title respects conventional commit
- Run linters against modified files

##### Pull requests build

- Build images that have been modified
- Tag with Pull request number and commit sha

##### Pull requests cleaning

- Remove all tags create during Pull request builds

##### Release

###### Release checks

- Run linters against modified files

##### Release build

- Build images that have been modified
- Tag respecting sementic versioning

## Author

🏢 **Hoverkraft <contact@hoverkraft.cloud>**

- Site: [https://hoverkraft.cloud](https://hoverkraft.cloud)
- GitHub: [@hoverkraft-tech](https://github.com/hoverkraft-tech)

## License

This project is licensed under the MIT License.

SPDX-License-Identifier: MIT

Copyright © 2025 hoverkraft-tech

For more details, see the [license](http://choosealicense.com/licenses/mit/).
