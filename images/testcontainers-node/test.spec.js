import { describe, it } from "node:test";
import assert from "node:assert";
import { GenericContainer } from "testcontainers";

describe("Testcontainers Node Runner Image", () => {
  let container;
  const imageName = process.env.IMAGE_NAME || "testcontainers-node:latest";

  it("setup container", async () => {
    container = await new GenericContainer(imageName)
      .withCommand(["sleep", "infinity"])
      .start();
  });

  it("node is installed", async () => {
    const { exitCode, output } = await container.exec(["node", "--version"]);
    assert.strictEqual(exitCode, 0);
    assert.match(output, /^v\d+\./);
  });

  it("testcontainers library can be imported", async () => {
    const { exitCode, output } = await container.exec([
      "node",
      "--input-type=module",
      "-e",
      "import('testcontainers').then(() => console.log('ok'))",
    ]);
    assert.strictEqual(exitCode, 0);
    assert.match(output, /ok/);
  });

  it("metadata: user is tester", async () => {
    const { exitCode, output } = await container.exec(["id", "-un"]);
    assert.strictEqual(exitCode, 0);
    assert.strictEqual(output.trim(), "tester");
  });

  it("metadata: workdir is /workspace", async () => {
    const { exitCode, output } = await container.exec(["pwd"]);
    assert.strictEqual(exitCode, 0);
    assert.strictEqual(output.trim(), "/workspace");
  });

  it("cleanup container", async () => {
    if (container) {
      await container.stop();
    }
  });
});
