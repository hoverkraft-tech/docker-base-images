package tests

import (
	"io"
	"testing"
)

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
