#!/bin/sh

set -eu

if [ -z "$1" ]; then
  echo "Usage: $0 <helm chart dir>"
  exit 1
fi

HELM_CHART_DIR="$1"
MIN_DEPTH="${2:-1}"

if [ ! -d "${HELM_CHART_DIR}" ]; then
  echo "Error: helm chart dir '${HELM_CHART_DIR}' does not exist"
  exit 1
fi

cd "${HELM_CHART_DIR}"

echo "+ building helm dependencies for subcharts"
INITIAL_DIR="$(realpath .)"

find . -name Chart.yaml -mindepth "${MIN_DEPTH}" -exec dirname {} \; | while read -r chartdir; do
  echo "+ building dependencies for $chartdir"
  cd "$chartdir" || exit 1
  i=0; for url in $(yq '.dependencies' Chart.yaml -o=json | jq -r 'try .[].repository'); do
    echo "${url}" | grep -qE '^(https?|git)://' || continue
    i=$((i+1)); helm repo add repo-${i} "${url}"
    helm repo update repo-${i}
  done
  helm dependency build --skip-refresh .
  cd - || exit 1
done

cd "$INITIAL_DIR" || exit 1

#  building helm dependencies for the umbrella chart
helm dependency build --skip-refresh .

echo "+ exiting successfully"
exit 0
