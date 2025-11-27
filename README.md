# docker-base-images

Opinionated Docker base images

## Our images

### [ci-helm](images/ci-helm/README.md)

A Docker image with all the tools needed to validate an helm chart

- helm chart-testing (aka ct)
- helm kubeconform plugin

### [mydumper](images/mydumper/README.md)

An image with an opiniated mydumper command as entrypoint

## Actions

_Actions that you can plug directly into your own Docker images repository._

### - [Get available images](actions/get-available-images/README.md)

### - [Should build images](actions/should-build-images/README.md)

## Reusable Workflows

### Get available images matrix

_Orchestrated workflows you can plug directly into your own Docker images repository._

### - [Prune pull requests images tags](.github/workflows/prune-pull-requests-images-tags.md)

### - [Get available images matrix](.github/workflows/get-available-images-matrix.md)

## Contributing

Contributions are welcome! Please see the [contributing guidelines](https://github.com/hoverkraft-tech/ci-github-publish/blob/main/CONTRIBUTING.md) for more details.

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

# Use GitHub Actions locally with `act`
gh act -W .github/workflows/workflow-file-to-test.yml
```

#### File Conventions

- **Dockerfile**: Uses Super Linter slim image for consistent code quality
- **Tests**: Located in `tests/` with expected vs actual file comparisons
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

**For Node.js scripts (like `prepare-site.js`):**

- Use class-based architecture for complex functionality
- Define regular expression patterns as constants (`MARKDOWN_IMAGE_REGEX`, `HTML_IMAGE_REGEX`)
- Implement Map-based caching for expensive operations
- Always use Node.js `path` module for cross-platform compatibility

#### File Structure Understanding

```text
actions/{category}/{action-name}/     # Modular action organization
├── action.yml                        # Action definition with inputs/outputs
├── README.md                         # Usage documentation
└── *.js                             # Optional Node.js scripts

.github/workflows/                    # Reusable workflows
├── deploy-*.yml                      # Deployment orchestration
├── clean-deploy-*.yml               # Cleanup workflows
└── __*.yml                          # Private/internal workflows

tests/                               # Expected vs actual comparisons
└── argocd-app-of-apps/             # Template testing structure
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
