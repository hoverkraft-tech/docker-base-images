package argocd_cmp_hk_deployment_test

import (
    "bytes"
    "context"
    "fmt"
    "os"
    "path/filepath"
    "strings"
    "testing"

    "github.com/docker/docker/pkg/stdcopy"
    "github.com/testcontainers/testcontainers-go"
    tcexec "github.com/testcontainers/testcontainers-go/exec"
)

// readOutput reads stdout and stderr buffers and returns cleaned strings.
func readOutput(stdout, stderr *bytes.Buffer) (string, string) {
    clean := func(s string) string {
        trimmed := strings.Map(func(r rune) rune {
            if r == '\n' || r == '\r' || r == '\t' {
                return r
            }
            if r < 32 || r == 127 {
                return -1
            }
            return r
        }, s)
        return strings.TrimSpace(trimmed)
    }
    return clean(stdout.String()), clean(stderr.String())
}

type commandResult struct {
    code   int
    stdout string
    stderr string
}

func execCommand(ctx context.Context, t *testing.T, container testcontainers.Container, cmd []string, opts ...tcexec.ProcessOption) commandResult {
    t.Helper()

    var stdout, stderr bytes.Buffer
    code, reader, err := container.Exec(ctx, cmd, opts...)
    if err != nil {
        t.Fatalf("failed to execute command %v: %v", cmd, err)
    }

    if reader != nil {
        if _, err := stdcopy.StdCopy(&stdout, &stderr, reader); err != nil {
            t.Fatalf("failed to read command output for %v: %v", cmd, err)
        }
    }

    cleanStdout, cleanStderr := readOutput(&stdout, &stderr)
    return commandResult{code: code, stdout: cleanStdout, stderr: cleanStderr}
}

func assertContains(t *testing.T, output string, expected ...string) {
    t.Helper()
    for _, value := range expected {
        if !strings.Contains(output, value) {
            t.Fatalf("expected output to contain %q, got %q", value, output)
        }
    }
}

func TestArgoCDCMPHKDeployment(t *testing.T) {
    ctx := context.Background()

    imageName := os.Getenv("IMAGE_NAME")
    if imageName == "" {
        imageName = "argocd-cmp-hk-deployment:latest"
    }

    workdir, err := os.Getwd()
    if err != nil {
        t.Fatalf("failed to get working directory: %v", err)
    }

    hostTestsDir := os.Getenv("HOST_TESTS_DIR")
    if hostTestsDir == "" {
        hostTestsDir = filepath.Join(workdir, "tests")
    }

    if _, err := os.Stat(hostTestsDir); err != nil {
        t.Fatalf("tests directory is required but missing: %v", err)
    }

    req := testcontainers.ContainerRequest{
        Image: imageName,
        Cmd:   []string{"sleep", "infinity"},
        Env: map[string]string{
            "ARGOCD_APP_NAME":      "hk-app",
            "ARGOCD_APP_NAMESPACE": "hk-ns",
            "KUBE_VERSION":         "1.33.0",
        },
        Mounts: testcontainers.ContainerMounts{
            testcontainers.BindMount(hostTestsDir, testcontainers.ContainerMountTarget("/mnt/tests-ro")),
        },
    }

    container, err := testcontainers.GenericContainer(ctx, testcontainers.GenericContainerRequest{
        ContainerRequest: req,
        Started:          true,
    })
    if err != nil {
        t.Fatalf("failed to start container: %v", err)
    }
    defer func() {
        if err := container.Terminate(ctx); err != nil {
            t.Fatalf("failed to terminate container: %v", err)
        }
    }()

    run := func(t *testing.T, script string, env map[string]string) commandResult {
        prep := execCommand(ctx, t, container, []string{"bash", "-c", "rm -rf /tmp/tests && cp -r /mnt/tests-ro /tmp/tests && chown -R argocd:argocd /tmp/tests"})
        if prep.code != 0 {
            t.Fatalf("failed to prepare tests directory: %s", prep.stderr)
        }

        assignments := make([]string, 0, len(env))
        for key, value := range env {
            assignments = append(assignments, fmt.Sprintf("%s=%s", key, value))
        }

        opts := []tcexec.ProcessOption{
            tcexec.WithEnv(assignments),
            tcexec.WithWorkingDir("/tmp/tests"),
        }

        return execCommand(ctx, t, container, []string{script}, opts...)
    }

    t.Run("single-source renders helm output with provided deployment id", func(t *testing.T) {
        result := run(t, "/hk-tools/single-source.sh", map[string]string{
            "ARGOCD_ENV_HOVERKRAFT_DEPLOYMENT_ID": "4242",
        })
        if result.code != 0 {
            t.Fatalf("expected exit code 0, got %d: stderr=%s", result.code, result.stderr)
        }
        assertContains(t, result.stdout, "name: hoverkraft-deployment", "deploymentId: \"4242\"")
    })

    t.Run("single-source falls back to unknown deployment id", func(t *testing.T) {
        result := run(t, "/hk-tools/single-source.sh", nil)
        if result.code != 0 {
            t.Fatalf("expected exit code 0, got %d: stderr=%s", result.code, result.stderr)
        }
        assertContains(t, result.stdout, "name: hoverkraft-deployment", "deploymentId: unknown")
    })

    t.Run("multi-sources propagates deployment id", func(t *testing.T) {
        result := run(t, "/hk-tools/multi-sources.sh", map[string]string{
            "ARGOCD_ENV_HOVERKRAFT_DEPLOYMENT_ID": "7777",
        })
        if result.code != 0 {
            t.Fatalf("expected exit code 0, got %d: stderr=%s", result.code, result.stderr)
        }
        assertContains(t, result.stdout, "name: hoverkraft-deployment", "deploymentId: \"7777\"")
    })

    t.Run("multi-sources defaults deployment id", func(t *testing.T) {
        result := run(t, "/hk-tools/multi-sources.sh", nil)
        if result.code != 0 {
            t.Fatalf("expected exit code 0, got %d: stderr=%s", result.code, result.stderr)
        }
        assertContains(t, result.stdout, "name: hoverkraft-deployment", "deploymentId: \"unknown\"")
    })

    t.Run("entrypoint executes single-source when ARGOCD_MULTI_SOURCES is 0", func(t *testing.T) {
        result := run(t, "/hk-tools/entrypoint.sh", map[string]string{
            "ARGOCD_ENV_ARGOCD_MULTI_SOURCES": "0",
            "ARGOCD_ENV_HOVERKRAFT_DEPLOYMENT_ID": "1234",
        })
        if result.code != 0 {
            t.Fatalf("expected exit code 0, got %d", result.code)
        }
        assertContains(t, result.stdout, "name: hoverkraft-deployment", "deploymentId: \"1234\"")
        assertContains(t, result.stderr, "hoverkraft-deployment CMP plugin", "single-source application")
    })

    t.Run("entrypoint executes multi-sources when ARGOCD_MULTI_SOURCES is 1", func(t *testing.T) {
        result := run(t, "/hk-tools/entrypoint.sh", map[string]string{
            "ARGOCD_ENV_ARGOCD_MULTI_SOURCES": "1",
            "ARGOCD_ENV_HOVERKRAFT_DEPLOYMENT_ID": "5678",
        })
        if result.code != 0 {
            t.Fatalf("expected exit code 0, got %d", result.code)
        }
        assertContains(t, result.stdout, "name: hoverkraft-deployment", "deploymentId: \"5678\"")
        assertContains(t, result.stderr, "hoverkraft-deployment CMP plugin", "multi-sources application")
    })

    t.Run("entrypoint defaults to single-source when ARGOCD_MULTI_SOURCES is unset", func(t *testing.T) {
        result := run(t, "/hk-tools/entrypoint.sh", map[string]string{
            "ARGOCD_ENV_HOVERKRAFT_DEPLOYMENT_ID": "9999",
            "ARGOCD_APP_NAME": "test-app",
        })
        if result.code != 0 {
            t.Fatalf("expected exit code 0, got %d", result.code)
        }
        assertContains(t, result.stdout, "name: hoverkraft-deployment", "deploymentId: \"9999\"")
        assertContains(t, result.stderr, "WARN: ARGOCD_MULTI_SOURCES is not set", "single-source application")
    })

    t.Run("entrypoint handles invalid ARGOCD_MULTI_SOURCES value", func(t *testing.T) {
        result := run(t, "/hk-tools/entrypoint.sh", map[string]string{
            "ARGOCD_ENV_ARGOCD_MULTI_SOURCES": "invalid",
            "ARGOCD_ENV_HOVERKRAFT_DEPLOYMENT_ID": "8888",
        })
        if result.code != 0 {
            t.Fatalf("expected exit code 0, got %d", result.code)
        }
        assertContains(t, result.stderr, "WARN: ARGOCD_MULTI_SOURCES is invalid", "WARN: defaulting to single source mode")
    })

    t.Run("entrypoint with DEBUG enabled shows environment", func(t *testing.T) {
        result := run(t, "/hk-tools/entrypoint.sh", map[string]string{
            "ARGOCD_ENV_DEBUG": "true",
            "ARGOCD_ENV_ARGOCD_MULTI_SOURCES": "0",
            "ARGOCD_ENV_HOVERKRAFT_DEPLOYMENT_ID": "1111",
        })
        if result.code != 0 {
            t.Fatalf("expected exit code 0, got %d", result.code)
        }
        assertContains(t, result.stderr, "+ DEBUG: current environment:", "ARGOCD_ENV_DEBUG=true", "ARGOCD_ENV_ARGOCD_MULTI_SOURCES=0", "ARGOCD_ENV_HOVERKRAFT_DEPLOYMENT_ID=1111")
    })

    t.Run("entrypoint display argocd app name", func(t *testing.T) {
        result := run(t, "/hk-tools/entrypoint.sh", map[string]string{
            "ARGOCD_ENV_ARGOCD_MULTI_SOURCES": "1",
            "ARGOCD_ENV_HOVERKRAFT_DEPLOYMENT_ID": "9999",
        })
        if result.code != 0 {
            t.Fatalf("expected exit code 0, got %d", result.code)
        }
        assertContains(t, result.stderr, "+ application: hk-app")
    })

    t.Run("entrypoint script is present", func(t *testing.T) {
        result := execCommand(ctx, t, container, []string{"test", "-x", "/hk-tools/entrypoint.sh"})
        if result.code != 0 {
            t.Fatalf("expected entrypoint.sh to exist and be executable")
        }
    })

    t.Run("single-source script is present", func(t *testing.T) {
        result := execCommand(ctx, t, container, []string{"test", "-x", "/hk-tools/single-source.sh"})
        if result.code != 0 {
            t.Fatalf("expected single-source.sh to exist and be executable")
        }
    })

    t.Run("multi-sources script is present", func(t *testing.T) {
        result := execCommand(ctx, t, container, []string{"test", "-x", "/hk-tools/multi-sources.sh"})
        if result.code != 0 {
            t.Fatalf("expected multi-sources.sh to exist and be executable")
        }
    })

    t.Run("kustomize template exists", func(t *testing.T) {
        result := execCommand(ctx, t, container, []string{"test", "-f", "/hk-tools/kustomize-template.yaml"})
        if result.code != 0 {
            t.Fatalf("expected kustomize-template.yaml to exist")
        }
    })

    t.Run("metadata: user is argocd", func(t *testing.T) {
        result := execCommand(ctx, t, container, []string{"id", "-un"})
        if result.code != 0 {
            t.Fatalf("expected exit code 0, got %d", result.code)
        }
        if result.stdout != "argocd" {
            t.Fatalf("expected user 'argocd', got %q", result.stdout)
        }
    })
}
