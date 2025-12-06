FROM quay.io/argoproj/argocd:v3.2.0

USER root

COPY --chown=argocd:argocd entrypoint.sh kustomize-template.yaml multi-sources.sh single-source.sh /hk-tools/

USER argocd

HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
    CMD argocd version --client
