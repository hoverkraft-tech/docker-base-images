# docker-base-images

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

### [mydumper](images/mydumper/README.md)

An image with an opiniated mydumper command as entrypoint

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
- Tests are colocated with their respective images (e.g., `images/ci-helm/test.spec.js`)
- Each test validates: command availability, file existence, metadata, and environment variables
- All tests share a single Node.js module in `images/testcontainers-node/`

How tests are executed in this repository:

- `make test <image>` builds the image and runs tests inside the `images/testcontainers-node` runner image.
- The harness injects:
  - `IMAGE_NAME`: the image ref to test (e.g. `ci-helm:latest` locally, or an OCI ref in CI)
  - `HOST_TESTS_DIR`: absolute path to `images/<image>/tests` on the host (useful for bind-mounting fixtures)

**Writing good image tests (recommended):**

- Keep tests **black-box**: validate behavior via commands, files, users, workdir, and env.
- Make tests **deterministic**: avoid network calls and time-based assertions when possible.
- Start the container once per suite (`before`/`after`) and **always clean up**.
- Prefer `container.exec(cmd, { env, workingDir })` over shell string interpolation for env handling.
- Use a long-running command like `sleep infinity` so you can run multiple `exec` checks.

Basic example (`images/<image>/test.spec.js`):

```js
import { after, before, describe, it } from "node:test";
import assert from "node:assert";
import { GenericContainer } from "testcontainers";

describe("My Image", () => {
  const imageName = process.env.IMAGE_NAME || "my-image:latest";
  let container;

  before(async () => {
    container = await new GenericContainer(imageName)
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
- **Tests**: Located in each image directory (e.g., `images/*/test.spec.js`) using [testcontainers](https://testcontainers.com/modules/nodejs/) for Node.js
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
  ├── test.spec.js                  # Node.js tests (run via make/CI)
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
