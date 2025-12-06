#!/bin/bash

# save stdout descriptor
exec 3>&1
# redirect all output to stderr
exec 1>&2

echo "hoverkraft-deployment-multi"

echo "+ pre-checks"
if [ -z "${ARGOCD_ENV_HOVERKRAFT_DEPLOYMENT_ID}" ]; then
	echo "WARN: HOVERKRAFT_DEPLOYMENT_ID is empty"
	ARGOCD_ENV_HOVERKRAFT_DEPLOYMENT_ID="unknown"
fi

cat <<_EOF >&3
apiVersion: v1
kind: ConfigMap
metadata:
  name: hoverkraft-deployment
  annotations:
    argocd.argoproj.io/sync-wave: "0"
data:
  deploymentId: "${ARGOCD_ENV_HOVERKRAFT_DEPLOYMENT_ID}"
_EOF

echo "+ finished"
exit 0
