# argocd-cmp-hk-deployment

Docker base image for the Hoverkraft ArgoCD custom CMP (Config Management Plugin) deployment integration.

## Overview

- **Image purpose:** Provides a containerized environment for ArgoCD to render and manage Hoverkraft deployments using Helm and Kustomize, with support for multi-source and single-source workflows.
- **Key scripts:**
  - `single-source.sh`: Renders a Helm chart and applies Kustomize overlays, outputting the final Kubernetes manifests. Supports injection of deployment ID and ArgoCD environment variables.
  - `multi-sources.sh`: Generates a ConfigMap manifest for multi-source deployments, propagating the deployment ID.
- **Kustomize template:** `kustomize-template.yaml` is used by the scripts to inject deployment-specific configuration.

## Scripts

- `single-source.sh`: Entrypoint for single-source ArgoCD CMP integration. Expects a Helm chart in the working directory and outputs manifests to stdout. Honors the following environment variables:
  - `ARGOCD_ENV_HOVERKRAFT_DEPLOYMENT_ID`
  - `ARGOCD_APP_NAME`
  - `ARGOCD_APP_NAMESPACE`
  - `KUBE_VERSION`
- `multi-sources.sh`: Outputs a ConfigMap manifest with the deployment ID, suitable for multi-source workflows.
