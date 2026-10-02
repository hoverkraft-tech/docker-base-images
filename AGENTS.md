# AGENTS.md — agent instructions and operational contract

This file is written for automated coding agents (for example: Copilot coding agents). It exists to provide a concise operational contract and guardrails for agents working in this repository. It is not the canonical source for design or style rules. Those live in the developer documentation linked below.

## Organization-wide guidelines (required)

- Follow the prioritized shared instructions in [hoverkraft-tech/.github/AGENTS.md](https://github.com/hoverkraft-tech/.github/blob/main/AGENTS.md) before working in this repository.

## Quick Start

This project is a collection of opinionated Docker base images and related GitHub Actions. For comprehensive documentation, see the main [README.md](./README.md).

### Key Sections to Reference

- [Our images](./README.md#our-images) - Catalog of available Docker images
- [Actions](./README.md#actions) - Catalog of available actions
- [Reusable Workflows](./README.md#reusable-workflows) - Orchestration workflows
- [Contributing](./README.md#contributing) - Guidelines for contributing to the project

## Agent-Specific Development Patterns

### Documentation and tests (required)

Follow the [documentation and test rules](./CONTRIBUTING.md#documentation-and-tests).
Documentation, examples, test names, fixtures, and assertions must describe only the current supported codebase.
Do not add migration narratives, historical comparisons, or tests for unsupported behavior or deleted implementation details.
Review changed documentation and tests against this rule before finishing any task, including dependency upgrades.

### Critical Workflow Knowledge

```bash
# Essential commands for development
make lint        # Run Super Linter (dockerized)
make lint-fix    # Auto-fix linting issues
make build <path/to/image> # Build a specific image
```
