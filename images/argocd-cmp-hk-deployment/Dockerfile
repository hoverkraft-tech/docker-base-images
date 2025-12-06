FROM quay.io/argoproj/argocd:v3.2.0

USER root
COPY . /hk-tools/
RUN chown -R argocd:argocd /hk-tools

USER argocd

HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
    CMD argocd version --client
