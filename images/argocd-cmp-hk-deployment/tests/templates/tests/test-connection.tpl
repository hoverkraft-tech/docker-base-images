apiVersion: v1
kind: Pod
metadata:
  name: "{{ include "myapp.fullname" . }}-test-connection"
  namespace: {{ include "myapp.namespace" . }}
  labels:
    {{- include "myapp.labels" . | nindent 4 }}
  annotations:
    "helm.sh/hook": test
spec:
  serviceAccountName: {{ include "myapp.serviceAccountName" . }}
  automountServiceAccountToken: {{ .Values.automountServiceAccountToken }}
  securityContext:
    runAsNonRoot: true
    fsGroup: 2000
    seccompProfile:
      type: RuntimeDefault
  containers:
    - name: wget
      {{- if .Values.testConnection.image.digest }}
      image: "{{ .Values.testConnection.image.repository }}@{{ .Values.testConnection.image.digest }}"
      {{- else }}
      image: "{{ .Values.testConnection.image.repository }}:{{ .Values.testConnection.image.tag }}"
      {{- end }}
      imagePullPolicy: IfNotPresent
      securityContext:
        allowPrivilegeEscalation: false
        capabilities:
          drop:
            - ALL
        readOnlyRootFilesystem: true
        runAsNonRoot: true
        runAsUser: 10100
        seccompProfile:
          type: RuntimeDefault
      command: ['wget']
      args: ['{{ include "myapp.fullname" . }}:{{ .Values.service.port }}']
      livenessProbe:
        exec:
          command: ['wget', '-qO-', '{{ include "myapp.fullname" . }}:{{ .Values.service.port }}']
      readinessProbe:
        exec:
          command: ['wget', '-qO-', '{{ include "myapp.fullname" . }}:{{ .Values.service.port }}']
      resources:
        {{- toYaml .Values.testConnection.resources | nindent 8 }}
  restartPolicy: Never
