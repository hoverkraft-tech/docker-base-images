#!/bin/bash

# save stdout descriptor
exec 3>&1
# redirect all output to stderr
exec 1>&2

echo "+ hoverkraft-deployment CMP plugin"
echo "+ application: ${ARGOCD_APP_NAME}"

echo "+ init"

if [ -n "${ARGOCD_ENV_DEBUG}" ]; then
	echo "+ DEBUG: current environment:"
	printenv | grep "ARGOCD_ENV_"
	echo "+++"
fi

# ARGOCD_ENV_ARGOCD_MULTI_SOURCES is a boolean that can be either 0 or 1
if [ -z "${ARGOCD_ENV_ARGOCD_MULTI_SOURCES}" ]; then
	echo "WARN: ARGOCD_MULTI_SOURCES is not set (expected 0 or 1, got empty string)"
	echo "WARN: defaulting to single source mode"
elif [ "${ARGOCD_ENV_ARGOCD_MULTI_SOURCES}" != "0" ] && [ "${ARGOCD_ENV_ARGOCD_MULTI_SOURCES}" != "1" ]; then
	echo "WARN: ARGOCD_MULTI_SOURCES is invalid (expected 0 or 1, got '${ARGOCD_ENV_ARGOCD_MULTI_SOURCES}')"
	echo "WARN: defaulting to single source mode"
fi

case "${ARGOCD_ENV_ARGOCD_MULTI_SOURCES}" in
1)
	echo "+ multi-sources application"
	/hk-tools/multi-sources.sh >&3
	;;
*)
	echo "+ single-source application"
	/hk-tools/single-source.sh >&3
	;;
esac
