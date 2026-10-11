---
apiVersion: v1
kind: ConfigMap
metadata:
  name: kubeconform-test
data:
  message: {{ .Values.message | default "hello" | toJson }}
