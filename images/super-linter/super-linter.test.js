import fs from "node:fs/promises";
import os from "node:os";
import path from "node:path";
import { after, before, describe, it } from "node:test";
import assert from "node:assert";
import { GenericContainer } from "testcontainers";

describe("super-linter Image", () => {
  // jscpd:ignore-start
  let container;
  const testedImageRef = process.env.TESTED_IMAGE_REF;

  if (!testedImageRef) {
    throw new Error("TESTED_IMAGE_REF environment variable is required");
  }

  before(async () => {
    container = await new GenericContainer(testedImageRef)
      .withEntrypoint(["sleep"])
      .withCommand(["infinity"])
      .start();
  });

  after(async () => {
    await container?.stop();
  });
  // jscpd:ignore-end

  async function runEntrypoint(args = [], env = {}) {
    return container.exec(["/usr/local/bin/super-linter-entrypoint", ...args], {
      env: {
        SUPER_LINTER_ENTRYPOINT: "/bin/sh",
        ...env,
      },
    });
  }

  it("wrapper script exists and is executable", async () => {
    const { exitCode } = await container.exec([
      "test",
      "-x",
      "/usr/local/bin/super-linter-entrypoint",
    ]);
    assert.strictEqual(exitCode, 0);
  });

  it("applies local runtime defaults", async () => {
    const { exitCode, output } = await runEntrypoint([
      "-c",
      'printf "%s" "$RUN_LOCAL|$USE_FIND_ALGORITHM|$LOG_LEVEL|$LOG_FILE|$IGNORE_GITIGNORED_FILES|$VALIDATE_JAVASCRIPT_TOOLCHAIN|$VALIDATE_PYTHON_TOOLCHAIN"',
    ]);

    assert.strictEqual(exitCode, 0);
    assert.strictEqual(
      output.trim(),
      "true|true|WARN|/github/home/logs|true|biome|ruff-format",
    );
  });

  it("applies conflict guards for the default toolchains", async () => {
    const { exitCode, output } = await runEntrypoint([
      "-c",
      'printf "%s" "$VALIDATE_JAVASCRIPT_ES|$VALIDATE_JSON|$VALIDATE_TYPESCRIPT_ES|$VALIDATE_BIOME_FORMAT|$VALIDATE_BIOME_LINT|$VALIDATE_PYTHON_BLACK"',
    ]);

    assert.strictEqual(exitCode, 0);
    assert.strictEqual(output.trim(), "false|false|false|||false");
  });

  it("preserves explicitly provided runtime values", async () => {
    const { exitCode, output } = await runEntrypoint(
      ["-c", 'printf "%s" "$RUN_LOCAL|$LOG_LEVEL|$IGNORE_GITIGNORED_FILES"'],
      {
        RUN_LOCAL: "false",
        LOG_LEVEL: "INFO",
        IGNORE_GITIGNORED_FILES: "false",
      },
    );

    assert.strictEqual(exitCode, 0);
    assert.strictEqual(output.trim(), "false|INFO|false");
  });

  it("disables conflicting validators for the biome toolchain", async () => {
    const { exitCode, output } = await runEntrypoint(
      [
        "-c",
        'printf "%s" "$VALIDATE_CSS|$VALIDATE_JAVASCRIPT_ES|$VALIDATE_JSON|$VALIDATE_TYPESCRIPT_ES|$VALIDATE_VUE"',
      ],
      { VALIDATE_JAVASCRIPT_TOOLCHAIN: "biome" },
    );

    assert.strictEqual(exitCode, 0);
    assert.strictEqual(output.trim(), "false|false|false|false|false");
  });

  it("disables biome validators for the eslint-prettier toolchain", async () => {
    const { exitCode, output } = await runEntrypoint(
      ["-c", 'printf "%s" "$VALIDATE_BIOME_FORMAT|$VALIDATE_BIOME_LINT"'],
      { VALIDATE_JAVASCRIPT_TOOLCHAIN: "eslint-prettier" },
    );

    assert.strictEqual(exitCode, 0);
    assert.strictEqual(output.trim(), "false|false");
  });

  it("disables the conflicting formatter for the selected python toolchain", async () => {
    const blackResult = await runEntrypoint(
      ["-c", 'printf "%s" "$VALIDATE_PYTHON_RUFF_FORMAT"'],
      { VALIDATE_PYTHON_TOOLCHAIN: "black" },
    );
    assert.strictEqual(blackResult.exitCode, 0);
    assert.strictEqual(blackResult.output.trim(), "false");

    const ruffResult = await runEntrypoint(
      ["-c", 'printf "%s" "$VALIDATE_PYTHON_BLACK"'],
      { VALIDATE_PYTHON_TOOLCHAIN: "ruff-format" },
    );
    assert.strictEqual(ruffResult.exitCode, 0);
    assert.strictEqual(ruffResult.output.trim(), "false");
  });

  it("fails fast on unsupported toolchain names", async () => {
    const { exitCode, output } = await runEntrypoint([], {
      SUPER_LINTER_ENTRYPOINT: "/bin/true",
      VALIDATE_JAVASCRIPT_TOOLCHAIN: "unknown",
    });

    assert.strictEqual(exitCode, 1);
    assert.match(output, /Unsupported VALIDATE_JAVASCRIPT_TOOLCHAIN: unknown/);
  });

  it("applies uid and gid to child builds via ONBUILD", async () => {
    const buildContext = await fs.mkdtemp(
      path.join(os.tmpdir(), "super-linter-onbuild-"),
    );

    try {
      await fs.writeFile(
        path.join(buildContext, "Dockerfile"),
        `FROM ${testedImageRef}\n`,
      );

      const childImage = await GenericContainer.fromDockerfile(buildContext)
        .withBuildArgs({ UID: "2345", GID: "3456" })
        .build();

      const childContainer = await childImage
        .withEntrypoint(["sleep"])
        .withCommand(["infinity"])
        .start();

      try {
        const userId = await childContainer.exec(["id", "-u"]);
        assert.strictEqual(userId.exitCode, 0);
        assert.strictEqual(userId.output.trim(), "2345");

        const groupId = await childContainer.exec(["id", "-g"]);
        assert.strictEqual(groupId.exitCode, 0);
        assert.strictEqual(groupId.output.trim(), "3456");

        const owner = await childContainer.exec([
          "stat",
          "-c",
          "%u:%g",
          "/github/home",
        ]);
        assert.strictEqual(owner.exitCode, 0);
        assert.strictEqual(owner.output.trim(), "2345:3456");
      } finally {
        await childContainer.stop();
      }
    } finally {
      await fs.rm(buildContext, { recursive: true, force: true });
    }
  });
});
