package ci_helm_test

import (
	"context"
	"io"
	"os"
	"strings"
	"testing"
	"unicode"

	"github.com/testcontainers/testcontainers-go"
)

// jscpd:ignore-start
// readOutput reads all output from a reader and returns it as a string
func readOutput(t *testing.T, reader io.Reader) string {
	t.Helper()
	if reader == nil {
		return ""
	}
	output, err := io.ReadAll(reader)
	if err != nil {
		t.Fatalf("Failed to read output: %s", err)
	}
	return string(output)
}
// jscpd:ignore-end

func trimmed(output string) string {
	cleaned := strings.Map(func(r rune) rune {
		if unicode.IsPrint(r) || unicode.IsSpace(r) {
			return r
		}
		return -1
	}, output)
	return strings.TrimSpace(cleaned)
}

func TestCiHelm(t *testing.T) {
	ctx := context.Background()
	imageName := os.Getenv("IMAGE_NAME")
	if imageName == "" {
		imageName = "ci-helm:latest"
	}

	// jscpd:ignore-start
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
	// jscpd:ignore-end

	t.Run("helm is installed", func(t *testing.T) {
		code, reader, err := container.Exec(ctx, []string{"helm", "version"})
		if err != nil {
			t.Fatalf("Failed to execute command: %s", err)
		}
		if code != 0 {
			t.Fatalf("Expected exit code 0, got %d", code)
		}

		output := readOutput(t, reader)
		if !strings.Contains(output, "version") {
			t.Errorf("Expected output to contain 'version', got: %s", output)
		}
	})

	t.Run("ct (chart-testing) is installed", func(t *testing.T) {
		code, _, err := container.Exec(ctx, []string{"ct", "version"})
		if err != nil {
			t.Fatalf("Failed to execute command: %s", err)
		}
		if code != 0 {
			t.Fatalf("Expected exit code 0, got %d", code)
		}
	})

	t.Run("kubeconform-helm plugin is installed", func(t *testing.T) {
		code, reader, err := container.Exec(ctx, []string{"helm", "plugin", "list"})
		if err != nil {
			t.Fatalf("Failed to execute command: %s", err)
		}
		if code != 0 {
			t.Fatalf("Expected exit code 0, got %d", code)
		}

		output := readOutput(t, reader)
		if !strings.Contains(output, "kubeconform") {
			t.Errorf("Expected output to contain 'kubeconform', got: %s", output)
		}
	})

	t.Run("helm-values-schema-json plugin is installed", func(t *testing.T) {
		code, reader, err := container.Exec(ctx, []string{"helm", "plugin", "list"})
		if err != nil {
			t.Fatalf("Failed to execute command: %s", err)
		}
		if code != 0 {
			t.Fatalf("Expected exit code 0, got %d", code)
		}

		output := readOutput(t, reader)
		if !strings.Contains(output, "schema") {
			t.Errorf("Expected output to contain 'schema', got: %s", output)
		}
	})

	t.Run("jq is installed", func(t *testing.T) {
		code, _, err := container.Exec(ctx, []string{"jq", "--version"})
		if err != nil {
			t.Fatalf("Failed to execute command: %s", err)
		}
		if code != 0 {
			t.Fatalf("Expected exit code 0, got %d", code)
		}
	})

	t.Run("yq is installed", func(t *testing.T) {
		code, _, err := container.Exec(ctx, []string{"yq", "--version"})
		if err != nil {
			t.Fatalf("Failed to execute command: %s", err)
		}
		if code != 0 {
			t.Fatalf("Expected exit code 0, got %d", code)
		}
	})

	t.Run("helm-deps.sh script exists and is executable", func(t *testing.T) {
		code, _, err := container.Exec(ctx, []string{"test", "-x", "/usr/local/bin/helm-deps.sh"})
		if err != nil {
			t.Fatalf("Failed to execute command: %s", err)
		}
		if code != 0 {
			t.Fatalf("Expected /usr/local/bin/helm-deps.sh to exist and be executable")
		}
	})

	t.Run("metadata: user is helm:helm", func(t *testing.T) {
		code, reader, err := container.Exec(ctx, []string{"id", "-un"})
		if err != nil {
			t.Fatalf("Failed to execute command: %s", err)
		}
		if code != 0 {
			t.Fatalf("Expected exit code 0, got %d", code)
		}
		username := trimmed(readOutput(t, reader))
		if username != "helm" {
			t.Errorf("Expected user 'helm', got: %q", username)
		}
	})

	t.Run("metadata: workdir is /home/helm", func(t *testing.T) {
		code, reader, err := container.Exec(ctx, []string{"pwd"})
		if err != nil {
			t.Fatalf("Failed to execute command: %s", err)
		}
		if code != 0 {
			t.Fatalf("Expected exit code 0, got %d", code)
		}
		workdir := trimmed(readOutput(t, reader))
		if workdir != "/home/helm" {
			t.Errorf("Expected workdir '/home/helm', got: %q", workdir)
		}
	})
}
