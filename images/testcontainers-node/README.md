# Testcontainers Node.js

Node.js-based test runner for Docker images using [Testcontainers](https://testcontainers.com/modules/nodejs/).

## Purpose

This image provides a consistent test execution environment for all Docker images in this repository. It includes Node.js and the testcontainers library for running integration tests against Docker containers.

## Contents

- **Node.js 20 Alpine**: Lightweight Node.js runtime
- **Docker CLI**: Required for testcontainers to interact with Docker
- **testcontainers**: Node.js library for container-based testing
- **Go module dependencies**: Pre-installed testcontainers dependencies for faster test execution

Test files are mounted at runtime from each image directory (e.g., `images/ci-helm/test.spec.js`).

## Usage

### Local Development

Run tests for a specific image:

```bash
make test <image-name>
```

This will:

1. Build the image to test
2. Build the testcontainers-node Docker image
3. Mount the test file and run tests

### CI/CD

Tests are automatically run in CI for each image. The testcontainers-node image is built once and used to test all images.

## Test File Structure

Each image that has tests should include a `test.spec.js` file in its directory:

```
images/
├── ci-helm/
│   ├── Dockerfile
│   └── test.spec.js
├── mydumper/
│   ├── Dockerfile
│   └── test.spec.js
└── testcontainers-node/
    ├── Dockerfile
    ├── package.json
    └── README.md
```

## Writing Tests

Tests use Node.js built-in test runner with testcontainers:

```javascript
import { describe, it } from 'node:test';
import assert from 'node:assert';
import { GenericContainer } from 'testcontainers';

describe('My Image', () => {
  it('should have required tool installed', async () => {
    const imageName = process.env.IMAGE_NAME || 'my-image:latest';
    
    const container = await new GenericContainer(imageName)
      .withCommand(['sleep', 'infinity'])
      .start();
    
    try {
      const { exitCode, output } = await container.exec(['tool', '--version']);
      assert.strictEqual(exitCode, 0);
      assert.match(output, /version/);
    } finally {
      await container.stop();
    }
  });
});
```

## Architecture

- **Dedicated Docker image**: Contains Node.js runtime and testcontainers dependencies
- **Runtime mounting**: Test files are mounted at runtime, not copied into the image
- **Single package.json**: All test dependencies managed in one place
- **Docker-based execution**: Tests always run via Docker (both locally and in CI)

This approach ensures:

- ✅ Simple DevX (Docker + Make only)
- ✅ Consistent test environment
- ✅ Fast test execution with pre-installed dependencies
- ✅ Easy maintenance with colocated tests
