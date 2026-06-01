# codespace-like

A web-based Visual Studio Code environment built on top of [`coder/code-server`](https://github.com/coder/code-server), enriched with developer tooling for Kubernetes and container workflows.

## What's included

**System packages** (via apt): `docker`, `git`, `make`, `curl`, `wget`, `rsync`, `zsh`

**Shell**: Oh My Zsh (default shell)

**Command-line tools** (via [mise](https://mise.jdx.dev/) + aqua):

| Tool                  | Version               |
| --------------------- | --------------------- |
| chezmoi               | 2.70.1                |
| cosign                | 3.0.6                 |
| crane                 | 0.21.5                |
| helm + ct + docs      | 4.x / 3.14.0 / 1.14.2 |
| kubectl               | 1.35.3                |
| kubeconform / kubeval | 0.7.0 / 0.16.1        |
| kustomize             | 5.8.1                 |
| oras                  | 1.3.1                 |
| devcontainer CLI      | 0.85.0                |
