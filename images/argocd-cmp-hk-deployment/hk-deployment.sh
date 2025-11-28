#!/bin/bash

# save stdout descriptor
exec 3>&1
# redirect all output to stderr
exec 1>&2

SOURCE_DIR="$(realpath "$(dirname "${BASH_SOURCE[0]}")")"

echo "hk-deployment"
echo "version 0.1.0"

echo "+ init"
cp "$SOURCE_DIR/kustomize-template.yaml" ./kustomization.yaml
if [ -z "${ARGOCD_ENV_HOVERKRAFT_DEPLOYMENT_ID}" ]; then
	ARGOCD_ENV_HOVERKRAFT_DEPLOYMENT_ID="unknown"
fi
sed -i'' -e "s/<HK_DEPLOYMENT_ID>/${ARGOCD_ENV_HOVERKRAFT_DEPLOYMENT_ID}/" kustomization.yaml

echo "+ running helm"
/usr/local/bin/helm template . \
	--name-template "${ARGOCD_APP_NAME:-unknown}" \
	--namespace "${ARGOCD_APP_NAMESPACE:-default}" \
	--kube-version "${KUBE_VERSION:-1.31.0}" >all.yaml

echo "+ running kustomize"
# this is the only command that should write to the saved stdout
/usr/local/bin/kustomize build >&3

echo "+ finished"
exit 0
