package tests

import (
	"context"
	"os"
	"strings"
	"testing"

	"github.com/testcontainers/testcontainers-go"
)

func TestArgoCDCmpHkDeployment(t *testing.T) {
	ctx := context.Background()
	imageName := os.Getenv("IMAGE_NAME")
	if imageName == "" {
		imageName = "argocd-cmp-hk-deployment:latest"
	}

	req := testcontainers.ContainerRequest{
		Image: imageName,
		Cmd:   []string{"sleep", "infinity"},
	}

	container, err := testcontainers.GenericContainer(ctx, testcontainers.GenericContainerRequest{
		ContainerRequest: req,
		Started:          true,
	})
	if err != nil {
		t.Fatalf("Failed to start container: %s", err)
	}
	defer func() {
		if err := container.Terminate(ctx); err != nil {
			t.Fatalf("Failed to terminate container: %s", err)
		}
	}()

	t.Run("single-source renders helm output with provided deployment id", func(t *testing.T) {
		script := `
set -euo pipefail
WORKDIR="$(mktemp -d)"
cd "$WORKDIR"
cat <<'EOF' > Chart.yaml
apiVersion: v2
name: hk-deployment-fixture
description: Fixture chart for container tests
type: application
version: 0.1.0
appVersion: "1.0.0"
EOF
cat <<'EOF' > values.yaml
replicaCount: 1
EOF
mkdir -p templates
cat <<'EOF' > templates/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: sample-config
  labels:
    app.kubernetes.io/name: sample-config
data:
  foo: bar
EOF
/hk-tools/single-source.sh
`
		code, reader, err := container.Exec(ctx, []string{"bash", "-c", script}, testcontainers.WithEnv(map[string]string{
			"ARGOCD_ENV_HOVERKRAFT_DEPLOYMENT_ID": "4242",
			"ARGOCD_APP_NAME":                     "hk-app",
			"ARGOCD_APP_NAMESPACE":                "hk-namespace",
			"KUBE_VERSION":                        "1.31.0",
		}))
		if err != nil {
			t.Fatalf("Failed to execute command: %s", err)
		}
		if code != 0 {
			t.Fatalf("Expected exit code 0, got %d", code)
		}

		output := readOutput(t, reader)
		expectedStrings := []string{`deploymentId: "4242"`, "name: sample-config", "foo: bar"}
		for _, expected := range expectedStrings {
			if !strings.Contains(output, expected) {
				t.Errorf("Expected output to contain '%s', got: %s", expected, output)
			}
		}
	})

	t.Run("single-source falls back to unknown deployment id", func(t *testing.T) {
		script := `
set -euo pipefail
WORKDIR="$(mktemp -d)"
cd "$WORKDIR"
cat <<'EOF' > Chart.yaml
apiVersion: v2
name: hk-deployment-fixture
description: Fixture chart for container tests
type: application
version: 0.1.0
appVersion: "1.0.0"
EOF
cat <<'EOF' > values.yaml
replicaCount: 1
EOF
mkdir -p templates
cat <<'EOF' > templates/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: sample-config
data:
  foo: bar
EOF
/hk-tools/single-source.sh
`
		code, reader, err := container.Exec(ctx, []string{"bash", "-c", script}, testcontainers.WithEnv(map[string]string{
			"ARGOCD_APP_NAME":      "hk-app",
			"ARGOCD_APP_NAMESPACE": "hk-namespace",
			"KUBE_VERSION":         "1.31.0",
		}))
		if err != nil {
			t.Fatalf("Failed to execute command: %s", err)
		}
		if code != 0 {
			t.Fatalf("Expected exit code 0, got %d", code)
		}

		output := readOutput(t, reader)
		expectedStrings := []string{"deploymentId: unknown", "name: sample-config"}
		for _, expected := range expectedStrings {
			if !strings.Contains(output, expected) {
				t.Errorf("Expected output to contain '%s', got: %s", expected, output)
			}
		}
	})

	t.Run("multi-sources propagates deployment id", func(t *testing.T) {
		code, reader, err := container.Exec(ctx, []string{"/hk-tools/multi-sources.sh"}, testcontainers.WithEnv(map[string]string{
			"ARGOCD_ENV_HOVERKRAFT_DEPLOYMENT_ID": "7777",
		}))
		if err != nil {
			t.Fatalf("Failed to execute command: %s", err)
		}
		if code != 0 {
			t.Fatalf("Expected exit code 0, got %d", code)
		}

		output := readOutput(t, reader)
		expectedStrings := []string{`deploymentId: "7777"`, "name: hoverkraft-deployment"}
		for _, expected := range expectedStrings {
			if !strings.Contains(output, expected) {
				t.Errorf("Expected output to contain '%s', got: %s", expected, output)
			}
		}
	})

	t.Run("multi-sources defaults deployment id", func(t *testing.T) {
		code, reader, err := container.Exec(ctx, []string{"/hk-tools/multi-sources.sh"})
		if err != nil {
			t.Fatalf("Failed to execute command: %s", err)
		}
		if code != 0 {
			t.Fatalf("Expected exit code 0, got %d", code)
		}

		output := readOutput(t, reader)
		expectedStrings := []string{`deploymentId: "unknown"`, "name: hoverkraft-deployment"}
		for _, expected := range expectedStrings {
			if !strings.Contains(output, expected) {
				t.Errorf("Expected output to contain '%s', got: %s", expected, output)
			}
		}
	})

	t.Run("single-source script is present", func(t *testing.T) {
		code, _, err := container.Exec(ctx, []string{"test", "-x", "/hk-tools/single-source.sh"})
		if err != nil {
			t.Fatalf("Failed to execute command: %s", err)
		}
		if code != 0 {
			t.Fatalf("Expected /hk-tools/single-source.sh to exist and be executable")
		}
	})

	t.Run("multi-sources script is present", func(t *testing.T) {
		code, _, err := container.Exec(ctx, []string{"test", "-x", "/hk-tools/multi-sources.sh"})
		if err != nil {
			t.Fatalf("Failed to execute command: %s", err)
		}
		if code != 0 {
			t.Fatalf("Expected /hk-tools/multi-sources.sh to exist and be executable")
		}
	})

	t.Run("kustomize template exists", func(t *testing.T) {
		code, _, err := container.Exec(ctx, []string{"test", "-f", "/hk-tools/kustomize-template.yaml"})
		if err != nil {
			t.Fatalf("Failed to execute command: %s", err)
		}
		if code != 0 {
			t.Fatalf("Expected /hk-tools/kustomize-template.yaml to exist")
		}
	})

	t.Run("metadata: user is argocd", func(t *testing.T) {
		code, reader, err := container.Exec(ctx, []string{"id", "-un"})
		if err != nil {
			t.Fatalf("Failed to execute command: %s", err)
		}
		if code != 0 {
			t.Fatalf("Expected exit code 0, got %d", code)
		}
		username := strings.TrimSpace(readOutput(t, reader))
		if username != "argocd" {
			t.Errorf("Expected user 'argocd', got: %s", username)
		}
	})
}
