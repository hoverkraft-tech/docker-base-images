// jscpd:ignore-start
import { describe, it, before, after } from "node:test";
import assert from "node:assert";
import { GenericContainer } from "testcontainers";

describe("ci-helm image", () => {
  const testImage = process.env.TEST_IMAGE || "ci-helm:latest";
  let container;

  before(async () => {
    container = await new GenericContainer(testImage)
      .withEntrypoint(["sleep", "infinity"])
      .start();
  });

  after(async () => {
    if (container) {
      await container.stop();
    }
  });
  // jscpd:ignore-end

  it("should have helm installed", async () => {
    const { exitCode, output } = await container.exec(["helm", "version"]);
    assert.strictEqual(exitCode, 0, `helm version failed: ${output}`);
    assert.match(output, /version/i, "helm version output should contain version");
  });

  it("should have ct (chart-testing) installed", async () => {
    const { exitCode, output } = await container.exec(["ct", "version"]);
    assert.strictEqual(exitCode, 0, `ct version failed: ${output}`);
  });

  it("should have kubeconform-helm plugin installed", async () => {
    const { exitCode, output } = await container.exec([
      "helm",
      "plugin",
      "list",
    ]);
    assert.strictEqual(exitCode, 0, `helm plugin list failed: ${output}`);
    assert.match(output, /kubeconform/i, "kubeconform plugin should be installed");
  });

  it("should have helm-values-schema-json plugin installed", async () => {
    const { exitCode, output } = await container.exec([
      "helm",
      "plugin",
      "list",
    ]);
    assert.strictEqual(exitCode, 0, `helm plugin list failed: ${output}`);
    assert.match(output, /schema/i, "values-schema-json plugin should be installed");
  });

  it("should have jq installed", async () => {
    const { exitCode, output } = await container.exec(["jq", "--version"]);
    assert.strictEqual(exitCode, 0, `jq --version failed: ${output}`);
  });

  it("should have yq installed", async () => {
    const { exitCode, output } = await container.exec(["yq", "--version"]);
    assert.strictEqual(exitCode, 0, `yq --version failed: ${output}`);
  });

  it("should have helm-deps.sh script available", async () => {
    const { exitCode, output } = await container.exec([
      "test",
      "-x",
      "/usr/local/bin/helm-deps.sh",
    ]);
    assert.strictEqual(
      exitCode,
      0,
      `helm-deps.sh should be executable: ${output}`
    );
  });

  // jscpd:ignore-start
  it("should run as non-root user", async () => {
    const { exitCode, output } = await container.exec(["id", "-u"]);
    assert.strictEqual(exitCode, 0, `id -u failed: ${output}`);
    const uid = parseInt(output.trim(), 10);
    assert.notStrictEqual(uid, 0, "Container should not run as root");
  });
  // jscpd:ignore-end
});
