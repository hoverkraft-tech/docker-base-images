import assert from "node:assert";
import fs from "node:fs/promises";
import os from "node:os";
import path from "node:path";
import { after, before, describe, it } from "node:test";
import { GenericContainer, Wait } from "testcontainers";

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

	for (const noGitignore of [false, true]) {
		const ignoredFilesBehavior = noGitignore ? "includes" : "excludes";
		it(`${ignoredFilesBehavior} Git-ignored files according to the JSCPD configuration`, async () => {
			const workspace = "/tmp/lint";
			const source = Array.from(
				{ length: 10 },
				(_, index) => `export const value${index} = ${index};`,
			).join("\n");

			for (const ignoreGitignoredFiles of ["true", "false"]) {
				const jscpdContainer = await new GenericContainer(testedImageRef)
					.withCopyContentToContainer([
						{ content: source, target: "/tmp/jscpd-fixture/source.js" },
						{ content: source, target: "/tmp/jscpd-fixture/ignored.js" },
						{
							content: "ignored.js\n",
							target: "/tmp/jscpd-fixture/.gitignore",
						},
						{
							content: JSON.stringify({
								threshold: 0,
								noGitignore,
								format: ["javascript"],
								reporters: ["json"],
								output: `${workspace}/report`,
							}),
							target: "/tmp/jscpd-fixture/.jscpd.json",
						},
					])
					.withEnvironment({
						DEFAULT_WORKSPACE: workspace,
						LINTER_RULES_PATH: ".",
						VALIDATE_JSCPD: "true",
						VALIDATE_JAVASCRIPT_TOOLCHAIN: "",
						VALIDATE_PYTHON_TOOLCHAIN: "",
						IGNORE_GITIGNORED_FILES: ignoreGitignoredFiles,
					})
					.withEntrypoint(["/bin/sh", "-ec"])
					.withCommand([
						`cp -R /tmp/jscpd-fixture "$DEFAULT_WORKSPACE"
git init -q "$DEFAULT_WORKSPACE"
status=0
/usr/local/bin/super-linter-entrypoint > /tmp/linter.log 2>&1 || status=$?
printf '%s' "$status" > /tmp/linter-exit-code
echo "Super-Linter finished"
exec sleep infinity`,
					])
					.withWaitStrategy(Wait.forLogMessage("Super-Linter finished"))
					.withStartupTimeout(60_000)
					.start();

				try {
					const { exitCode, output } = await jscpdContainer.exec([
						"/bin/sh",
						"-c",
						'cat /tmp/linter.log; exit "$(cat /tmp/linter-exit-code)"',
					]);
					assert.strictEqual(exitCode, noGitignore ? 1 : 0, output);

					const report = await jscpdContainer.exec([
						"cat",
						`${workspace}/report/jscpd-report.json`,
					]);
					assert.strictEqual(report.exitCode, 0, report.output);
					const { total } = JSON.parse(report.output).statistics;
					assert.strictEqual(total.sources, noGitignore ? 2 : 1);
					assert.strictEqual(total.duplicatedLines > 0, noGitignore);
				} finally {
					await jscpdContainer.stop();
				}
			}
		});
	}

	it("applies local runtime defaults", async () => {
		const { exitCode, output } = await runEntrypoint([
			"-c",
			'printf "%s" "$RUN_LOCAL|$USE_FIND_ALGORITHM|$LOG_LEVEL|$LOG_FILE|$IGNORE_GITIGNORED_FILES|$KUBERNETES_KUBECONFORM_OPTIONS|$VALIDATE_JAVASCRIPT_TOOLCHAIN|$VALIDATE_PYTHON_TOOLCHAIN"',
		]);

		assert.strictEqual(exitCode, 0);
		assert.strictEqual(
			output.trim(),
			"true|true|WARN|/github/home/logs|true|-schema-location default -schema-location https://raw.githubusercontent.com/hoverkraft-tech/crds-catalog/main/{{.Group}}/{{.ResourceKind}}_{{.ResourceAPIVersion}}.json -schema-location https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/{{.Group}}/{{.ResourceKind}}_{{.ResourceAPIVersion}}.json|biome|ruff-format",
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
			[
				"-c",
				'printf "%s" "$RUN_LOCAL|$LOG_LEVEL|$IGNORE_GITIGNORED_FILES|$KUBERNETES_KUBECONFORM_OPTIONS"',
			],
			{
				RUN_LOCAL: "false",
				LOG_LEVEL: "INFO",
				IGNORE_GITIGNORED_FILES: "false",
				KUBERNETES_KUBECONFORM_OPTIONS: "-summary",
			},
		);

		assert.strictEqual(exitCode, 0);
		assert.strictEqual(output.trim(), "false|INFO|false|-summary");
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
