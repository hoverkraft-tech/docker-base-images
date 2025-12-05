# argocd-cmp-hk-deployment

Docker base image for the Hoverkraft ArgoCD custom CMP (Config Management Plugin) deployment integration.

## Overview

- **Image purpose:** Provides a containerized environment for ArgoCD to render and manage Hoverkraft deployments using Helm and Kustomize, with support for multi-source and single-source workflows.
- **Key scripts:**
  - `entrypoint.sh`: call correct script depending of the argocd context
  - `single-source.sh`: Renders a Helm chart and applies Kustomize overlays, outputting the final Kubernetes manifests. Supports injection of deployment ID and ArgoCD environment variables.
  - `multi-sources.sh`: Generates a ConfigMap manifest for multi-source deployments, propagating the deployment ID.
- **Kustomize template:** `kustomize-template.yaml` is used by the scripts to inject deployment-specific configuration.

## Scripts

- `entrypoint.sh`: Honors the following environment variables:
  - `ARGOCD_APP_NAME`: name of the argocd application
  - `ARGOCD_ENV_ARGOCD_MULTI_SOURCES`: is the argocd app multi-sources or not (0 or 1)
  - `ARGOCD_ENV_DEBUG`: enable debug env output (0 or 1)
- `single-source.sh`: Expects a Helm chart in the working directory and outputs manifests to stdout. Honors the following environment variables:
  - `ARGOCD_ENV_HOVERKRAFT_DEPLOYMENT_ID`
- `multi-sources.sh`: Outputs a ConfigMap manifest with the deployment ID, suitable for multi-source workflows. Honors the following environment variables:
