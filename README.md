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

### - [Should build image](actions/should-build-image/README.md)

## Reusable Workflows

### Get available images matrix

_Orchestrated workflows you can plug directly into your own Docker images repository._

### - [Prune pull requests images tags](.github/workflows/prune-pull-requests-images-tags.yml)

### - [Get available images matrix](.github/workflows/get-available-images-matrix.yml)

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/)
- Make

## Linting

- Lint all files: `make lint`
- Lint a specific file: `make lint images/ci-helm/Dockerfile`

## Building

Build a specific image:

```sh
make build images/ci-helm
```

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
