{{- if .Values.networkPolicy.enabled }}
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: {{ include "myapp.fullname" . }}
  namespace: {{ include "myapp.namespace" . }}
  labels:
    {{- include "myapp.labels" . | nindent 4 }}
spec:
  podSelector:
    matchLabels:
      {{- include "myapp.selectorLabels" . | nindent 6 }}
  policyTypes:
    - Ingress
    - Egress
  ingress:
{{- toYaml .Values.networkPolicy.ingress | nindent 4 }}
  egress:
{{- toYaml .Values.networkPolicy.egress | nindent 4 }}
{{- end }}
