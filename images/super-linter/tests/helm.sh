#!/bin/sh

set -eu

workspace="$(mktemp -d)"
trap 'rm -rf "$workspace"' EXIT
cd "$workspace"
mkdir -p 'chart with spaces/templates' 'chart with spaces/ci'
cat >'chart with spaces/Chart.yaml' <<'YAML'
apiVersion: v2
name: example
version: 1.0.0
YAML
cat >'chart with spaces/templates/configmap.yaml' <<'YAML'
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ .Release.Name }}
data:
  setting: {{ .Values.setting | toJson }}
YAML
printf 'setting: valid\n' >'chart with spaces/values.yaml'
cat >schema.json <<'JSON'
{"type":"object","required":["apiVersion","kind","metadata","data"],"properties":{"apiVersion":{"type":"string"},"kind":{"const":"ConfigMap"},"metadata":{"type":"object"},"data":{"type":"object","additionalProperties":{"type":"string"}}},"additionalProperties":false}
JSON

kubeconform -strict -schema-location "$workspace/schema.json" \
	'chart with spaces/templates/configmap.yaml'

# Locked local dependencies are restored in the isolated copy.
mkdir -p 'chart with spaces/dependencies/child'
cat >'chart with spaces/dependencies/child/Chart.yaml' <<'YAML'
apiVersion: v2
name: child
version: 1.0.0
YAML
cat >>'chart with spaces/Chart.yaml' <<'YAML'
dependencies:
  - name: child
    version: 1.0.0
    repository: file://dependencies/child
YAML
helm dependency update 'chart with spaces' >/dev/null
rm -r 'chart with spaces/charts'
printf 'setting: valid\n' >'chart with spaces/ci/test-values.yaml'
kubeconform -strict --schema-location "$workspace/schema.json" \
	'chart with spaces/templates/configmap.yaml'
test ! -d 'chart with spaces/charts'

# A second scenario must be checked, even when the first one is valid.
printf 'setting: [invalid]\n' >'chart with spaces/ci/invalid-values.yaml'
if kubeconform -strict -schema-location "$workspace/schema.json" \
	'chart with spaces/templates/configmap.yaml' >result 2>&1; then
	cat result
	exit 1
fi
grep -q 'got array, want string' result
rm 'chart with spaces/ci/invalid-values.yaml'

# Rendering failures must not turn an empty input stream into a success.
printf '{{ fail "rendering rejected" }}\n' >>'chart with spaces/templates/configmap.yaml'
if kubeconform -schema-location "$workspace/schema.json" \
	'chart with spaces/templates/configmap.yaml' >result 2>&1; then
	cat result
	exit 1
fi
grep -q 'rendering rejected' result

# Regular manifests, CLI options and standard input keep native semantics.
cat >plain.yaml <<'YAML'
apiVersion: v1
kind: ConfigMap
metadata:
  name: plain
data:
  setting: valid
YAML
kubeconform -strict -schema-location "$workspace/schema.json" plain.yaml
kubeconform -strict -schema-location "$workspace/schema.json" <plain.yaml
test ! -d 'chart with spaces/charts'
