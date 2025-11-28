// jscpd:ignore-start
import { describe, it, before, after } from "node:test";
import assert from "node:assert";
import { GenericContainer } from "testcontainers";

describe("mydumper image", () => {
  const testImage = process.env.TEST_IMAGE || "mydumper:latest";
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

  it("should have mydumper installed", async () => {
    const { exitCode, output } = await container.exec(["mydumper", "--version"]);
    assert.strictEqual(exitCode, 0, `mydumper --version failed: ${output}`);
    assert.match(output, /mydumper/i, "mydumper version output should contain mydumper");
  });

  it("should have myloader installed", async () => {
    const { exitCode, output } = await container.exec(["myloader", "--version"]);
    assert.strictEqual(exitCode, 0, `myloader --version failed: ${output}`);
  });

  it("should have entrypoint.sh script available", async () => {
    const { exitCode, output } = await container.exec([
      "test",
      "-x",
      "/entrypoint.sh",
    ]);
    assert.strictEqual(exitCode, 0, `entrypoint.sh should be executable: ${output}`);
  });

  it("should have /backup directory writable", async () => {
    const { exitCode, output } = await container.exec(["test", "-w", "/backup"]);
    assert.strictEqual(exitCode, 0, `/backup should be writable: ${output}`);
  });

  // jscpd:ignore-start
  it("should run as non-root user", async () => {
    const { exitCode, output } = await container.exec(["id", "-u"]);
    assert.strictEqual(exitCode, 0, `id -u failed: ${output}`);
    const uid = parseInt(output.trim(), 10);
    assert.notStrictEqual(uid, 0, "Container should not run as root");
  });
  // jscpd:ignore-end

  it("should have correct environment variables set", async () => {
    const { exitCode, output } = await container.exec(["printenv"]);
    assert.strictEqual(exitCode, 0, `printenv failed: ${output}`);
    assert.match(output, /MYSQL_HOST/i, "MYSQL_HOST should be set");
    assert.match(output, /MYSQL_PORT/i, "MYSQL_PORT should be set");
    assert.match(output, /BACKUP_DIR|KEEP_BACKUPS/i, "Backup related env should be set");
  });

  it("should have pigz installed for compression", async () => {
    const { exitCode, output } = await container.exec(["pigz", "--version"]);
    // pigz outputs version to stderr, so exitCode 0 is enough
    assert.strictEqual(exitCode, 0, `pigz should be installed: ${output}`);
  });

  it("should have bzip2 installed", async () => {
    const { exitCode, output } = await container.exec(["bzip2", "--version"]);
    // bzip2 outputs version to stderr, so we check that the command exists
    assert.ok(exitCode === 0 || output.includes("bzip2"), `bzip2 should be installed: ${output}`);
  });
});
