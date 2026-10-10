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
		const workspace =
			env.DEFAULT_WORKSPACE ??
			(await container.exec(["mktemp", "-d"])).output.trim();
		const result = await container.exec(
			["/usr/local/bin/super-linter-entrypoint", ...args],
			{
				env: {
					SUPER_LINTER_ENTRYPOINT: "/bin/sh",
					DEFAULT_WORKSPACE: workspace,
					GITHUB_WORKSPACE: workspace,
					...env,
				},
			},
		);
		return { ...result, workspace };
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

	it("runs as root for GitHub Docker actions", async () => {
		const { exitCode, output } = await container.exec(["id", "-u"]);
		assert.strictEqual(exitCode, 0);
		assert.strictEqual(output.trim(), "0");
	});

	it("applies local runtime defaults", async () => {
		const { exitCode, output } = await runEntrypoint([
			"-c",
			'printf "%s" "$RUN_LOCAL|$USE_FIND_ALGORITHM|$LOG_LEVEL|$IGNORE_GITIGNORED_FILES|$KUBERNETES_KUBECONFORM_OPTIONS|$VALIDATE_JAVASCRIPT_TOOLCHAIN|$VALIDATE_PYTHON_TOOLCHAIN"',
		]);

		assert.strictEqual(exitCode, 0);
		assert.strictEqual(
			output.trim(),
			"true|true|WARN|true|-schema-location default -schema-location https://raw.githubusercontent.com/hoverkraft-tech/crds-catalog/main/{{.Group}}/{{.ResourceKind}}_{{.ResourceAPIVersion}}.json -schema-location https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/{{.Group}}/{{.ResourceKind}}_{{.ResourceAPIVersion}}.json|biome|ruff-format",
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

	it("selects CI mode in GitHub Actions", async () => {
		const { exitCode, output } = await runEntrypoint(
			["-c", 'printf "%s" "$RUN_LOCAL"'],
			{ GITHUB_ACTIONS: "true" },
		);
		assert.strictEqual(exitCode, 0);
		assert.strictEqual(output.trim(), "false");
	});

	it("applies the same linting policy locally and in GitHub Actions", async () => {
		const args = [
			"-c",
			'printf "%s" "$VALIDATE_JAVASCRIPT_TOOLCHAIN|$VALIDATE_PYTHON_TOOLCHAIN|$VALIDATE_JAVASCRIPT_ES|$VALIDATE_PYTHON_BLACK|$KUBERNETES_KUBECONFORM_OPTIONS|$IGNORE_GITIGNORED_FILES|$LOG_LEVEL"',
		];
		const local = await runEntrypoint(args);
		const ci = await runEntrypoint(args, { GITHUB_ACTIONS: "true" });
		assert.strictEqual(local.exitCode, 0);
		assert.strictEqual(ci.exitCode, 0);
		assert.strictEqual(ci.output, local.output);
	});

	it("supports explicit local execution inside GitHub Actions", async () => {
		const { exitCode, output } = await runEntrypoint(
			["-c", 'printf "%s" "$RUN_LOCAL|$USE_FIND_ALGORITHM"'],
			{ GITHUB_ACTIONS: "true", RUN_LOCAL: "true" },
		);
		assert.strictEqual(exitCode, 0);
		assert.strictEqual(output.trim(), "true|true");
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

	it("preserves validator overrides and empty toolchain selectors", async () => {
		const { exitCode, output } = await runEntrypoint(
			[
				"-c",
				'printf "%s" "$VALIDATE_JAVASCRIPT_ES|$VALIDATE_PYTHON_BLACK|$VALIDATE_BIOME_LINT"',
			],
			{
				VALIDATE_JAVASCRIPT_ES: "true",
				VALIDATE_PYTHON_TOOLCHAIN: "",
				VALIDATE_JAVASCRIPT_TOOLCHAIN: "",
			},
		);
		assert.strictEqual(exitCode, 0);
		assert.strictEqual(output.trim(), "true||");
	});

	it("keeps commitlint enabled without restricting the other validators", async () => {
		const { exitCode, output } = await runEntrypoint(
			[
				"-c",
				'if printenv VALIDATE_GIT_COMMITLINT; then exit 1; fi; printf "%s" "$VALIDATE_JAVASCRIPT_ES"',
			],
			{ VALIDATE_GIT_COMMITLINT: "true" },
		);
		assert.strictEqual(exitCode, 0);
		assert.strictEqual(output.trim(), "false");
	});

	for (const [message, expectedExitCode] of [
		["feat: add a shared linter", 0],
		["invalid commit message", 1],
	]) {
		it(`validates '${message}' without writing in the workspace`, async () => {
			const { exitCode, workspace } = await runEntrypoint(
				[
					"-c",
					'printf "%s\\n" "$COMMIT_MESSAGE" | commitlint --cwd "$DEFAULT_WORKSPACE"',
				],
				{ COMMIT_MESSAGE: message },
			);
			assert.strictEqual(exitCode, expectedExitCode);
			const files = await container.exec(["ls", "-A", workspace]);
			assert.strictEqual(files.output, "");
		});
	}

	for (const [filename, contents] of [
		[
			"commitlint.config.cjs",
			'module.exports = { rules: { "type-enum": [2, "always", ["custom"]] } };',
		],
		[
			"commitlint.config.mjs",
			'export default { rules: { "type-enum": [2, "always", ["custom"]] } };',
		],
		[".commitlintrc.yaml", "rules:\n  type-enum: [2, always, [custom]]\n"],
		[
			"package.json",
			'{"commitlint":{"rules":{"type-enum":[2,"always",["custom"]]}}}',
		],
		[
			"package.yaml",
			"commitlint:\n  rules:\n    type-enum: [2, always, [custom]]\n",
		],
	]) {
		it(`uses project rules from ${filename}`, async () => {
			const workspace = (await container.exec(["mktemp", "-d"])).output.trim();
			await container.exec([
				"sh",
				"-c",
				'printf "%s" "$1" > "$2"',
				"sh",
				contents,
				`${workspace}/${filename}`,
			]);
			const { exitCode, output } = await runEntrypoint(
				[
					"-c",
					'printf "custom: project rules\\n" | commitlint --cwd "$DEFAULT_WORKSPACE"',
				],
				{ DEFAULT_WORKSPACE: workspace },
			);
			assert.strictEqual(exitCode, 0, output);
			const config = await container.exec(["cat", `${workspace}/${filename}`]);
			assert.strictEqual(config.output, contents);
		});
	}

	it("uses commitlint rules inherited from a parent directory", async () => {
		const { exitCode, output } = await runEntrypoint([
			"-c",
			'mkdir "$DEFAULT_WORKSPACE/child"; printf \'{"rules":{"type-enum":[2,"always",["custom"]]}}\' > "$DEFAULT_WORKSPACE/.commitlintrc.json"; printf "custom: inherited rules\\n" | commitlint --cwd "$DEFAULT_WORKSPACE/child"',
		]);
		assert.strictEqual(exitCode, 0, output);
	});

	it("honors existing global commitlint configuration", async () => {
		const configHome = (await container.exec(["mktemp", "-d"])).output.trim();
		await container.exec([
			"sh",
			"-c",
			'mkdir "$1/commitlint"; printf \'export default { rules: { "type-enum": [2, "always", ["custom"]] } };\' > "$1/commitlint/config.mjs"',
			"sh",
			configHome,
		]);
		const { exitCode, output } = await runEntrypoint(
			[
				"-c",
				'printf "custom: global rules\\n" | commitlint --cwd "$DEFAULT_WORKSPACE"',
			],
			{ XDG_CONFIG_HOME: configHome },
		);
		assert.strictEqual(exitCode, 0, output);
	});

	it("installs fallback rules in the runtime home directory", async () => {
		const home = (await container.exec(["mktemp", "-d"])).output.trim();
		const { exitCode, output } = await runEntrypoint(
			[
				"-c",
				'printf "feat: runtime home\\n" | commitlint --cwd "$DEFAULT_WORKSPACE"',
			],
			{ HOME: home },
		);
		assert.strictEqual(exitCode, 0, output);
	});

	it("skips configuration when commitlint is disabled", async () => {
		const home = (await container.exec(["mktemp", "-d"])).output.trim();
		const { exitCode } = await runEntrypoint(
			[
				"-c",
				'test -z "$(ls -A "$HOME")" && test "$VALIDATE_GIT_COMMITLINT" = false',
			],
			{ HOME: home, VALIDATE_GIT_COMMITLINT: "false" },
		);
		assert.strictEqual(exitCode, 0);
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

	for (const [name, env] of [
		["Python toolchain", { VALIDATE_PYTHON_TOOLCHAIN: "unknown" }],
		["execution mode", { RUN_LOCAL: "unknown" }],
	]) {
		it(`rejects an unsupported ${name}`, async () => {
			const { exitCode } = await runEntrypoint(["-c", "exit 0"], env);
			assert.strictEqual(exitCode, 1);
		});
	}

	async function runFixture(image, name) {
		const script = await fs.readFile(
			path.join(import.meta.dirname, "tests", name),
			"utf8",
		);
		let output = "";
		try {
			const fixture = await image
				.withEntrypoint(["sh"])
				.withCommand(["-c", script])
				.withLogConsumer((stream) =>
					stream.on("data", (chunk) => {
						output += chunk;
					}),
				)
				.withWaitStrategy(Wait.forOneShotStartup())
				.withStartupTimeout(120_000)
				.start();
			await fixture.stop();
		} catch (cause) {
			throw new Error(`Fixture ${name} failed:\n${output}`, { cause });
		}
	}

	it("uses Git changes in CI and includes untracked files locally", async () => {
		await runFixture(new GenericContainer(testedImageRef), "file-selection.sh");
	});

	it("supports toolchain selection and native validator allowlists", async () => {
		await runFixture(new GenericContainer(testedImageRef), "toolchains.sh");
	});

	it("validates commit history with the bundled rules", async () => {
		await runFixture(new GenericContainer(testedImageRef), "commitlint.sh");
	});

	it("accepts self-repository references while reporting other workflow errors", async () => {
		await runFixture(
			new GenericContainer(testedImageRef),
			"self-repository.sh",
		);
	});

	it("preserves local ownership when fixing files in a child image", async () => {
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
			await runFixture(childImage, "autofix.sh");
		} finally {
			await fs.rm(buildContext, { recursive: true, force: true });
		}
	});
});
