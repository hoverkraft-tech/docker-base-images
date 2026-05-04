import { after, before, describe, it } from "node:test";
import assert from "node:assert";
import { GenericContainer } from "testcontainers";

describe("Testcontainers Node Runner Image", () => {
  let container;
  const testedImageRef = process.env.TESTED_IMAGE_REF;

  if (!testedImageRef) {
    throw new Error("TESTED_IMAGE_REF environment variable is required");
  }

  before(async () => {
    const builder = new GenericContainer(testedImageRef);
    builder.withEntrypoint(["sleep"]);
    builder.withCommand(["infinity"]);
    container = await builder.start();
  });

  after(async () => {
    if (!container) {
      return;
    }
    await container.stop();
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

  it("metadata: workdir is /workspace/image", async () => {
    const { exitCode, output } = await container.exec(["pwd"]);
    assert.strictEqual(exitCode, 0);
    assert.strictEqual(output.trim(), "/workspace/image");
  });
});
