# docker-base-images

Opinionated Docker base images crafted by Hoverkraft.

## Builded Images

## Managing a docker-base-images for an organization

### Grant Dependabot access to private repositories

- Go to [Code security and analysis](https://github.com/organizations/xxx/settings/security_analysis)
- Grant Dependabot access to private repositories: add the repository `docker-base-images`

### Actions

#### - [Should build image](actions/should-build-image/README.md)

### Reusable Workflows

#### - [Continuous integration](.github/workflows/continuous-integration.md)

#### - [Generate release config](.github/workflows/generate-release-config.md)

#### - [Get available images](.github/workflows/get-available-images.md)

#### - [Release](.github/workflows/release.md)

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/)
- Make

## Linting

- Lint all files: `make lint`
- Lint a specific file: `make lint images/.../Dockerfile`

## Continuous Integration

### Pull requests

#### Pull requests checks

- Validate that pull request title respects conventional commit
- Run linters against modified files

#### Pull requests build

- Build images that have been modified
- Tag with Pull request number and commit sha

#### Pull requests cleaning

- Remove all tags create during Pull request builds

### Release

#### Release checks

- Run linters against modified files

#### Release build

- Build images that have been modified
- Tag respecting sementic versioning
