import { after, before, describe, it } from "node:test";
import assert from "node:assert";
import { fileURLToPath } from "node:url";
import { GenericContainer } from "testcontainers";

describe("CI Helm Image", () => {
	let container;
	const testedImageRef = process.env.TESTED_IMAGE_REF;

	if (!testedImageRef) {
		throw new Error("TESTED_IMAGE_REF environment variable is required");
	}

	before(async () => {
		container = await new GenericContainer(testedImageRef)
			.withCommand(["sleep", "infinity"])
			.withCopyDirectoriesToContainer([
				{
					source: fileURLToPath(new URL("./tests", import.meta.url)),
					target: "/tmp/ci-helm-tests",
				},
			])
			.start();
	});

	after(async () => {
		await container?.stop();
	});

	it("helm is installed", async () => {
		const { exitCode, output } = await container.exec(["helm", "version"]);
		assert.strictEqual(exitCode, 0);
		assert.match(output, /version/);
	});

	it("ct (chart-testing) is installed", async () => {
		const { exitCode } = await container.exec(["ct", "version"]);
		assert.strictEqual(exitCode, 0);
	});

	it("kubeconform-helm plugin is installed", async () => {
		const { exitCode, output } = await container.exec([
			"helm",
			"plugin",
			"list",
		]);
		assert.strictEqual(exitCode, 0);
		assert.match(output, /kubeconform/);
	});

	for (const { name, args, expectedExitCode, expectedSummary } of [
		{
			name: "kubeconform validates a rendered chart using a local schema",
			args: [],
			expectedExitCode: 0,
			expectedSummary: /Valid: 1, Invalid: 0, Errors: 0, Skipped: 0/,
		},
		{
			name: "kubeconform rejects rendered values that violate the schema",
			args: ["--values", "/tmp/ci-helm-tests/invalid-values.yaml"],
			expectedExitCode: 1,
			expectedSummary: /Valid: 0, Invalid: 1, Errors: 0, Skipped: 0/,
		},
	]) {
		it(name, async () => {
			const { exitCode, output } = await container.exec([
				"helm",
				"kubeconform",
				"/tmp/ci-helm-tests/chart",
				"--schema-location",
				"/tmp/ci-helm-tests/configmap-schema.json",
				"--summary",
				...args,
			]);
			assert.strictEqual(exitCode, expectedExitCode, output);
			assert.match(output, expectedSummary);
		});
	}

	it("helm-values-schema-json plugin is installed", async () => {
		const { exitCode, output } = await container.exec([
			"helm",
			"plugin",
			"list",
		]);
		assert.strictEqual(exitCode, 0);
		assert.match(output, /schema/);
	});

	it("jq is installed", async () => {
		const { exitCode } = await container.exec(["jq", "--version"]);
		assert.strictEqual(exitCode, 0);
	});

	it("yq is installed", async () => {
		const { exitCode } = await container.exec(["yq", "--version"]);
		assert.strictEqual(exitCode, 0);
	});

	it("helm-deps.sh script exists and is executable", async () => {
		const { exitCode } = await container.exec([
			"test",
			"-x",
			"/usr/local/bin/helm-deps.sh",
		]);
		assert.strictEqual(exitCode, 0);
	});

	it("metadata: user is helm:helm", async () => {
		const { exitCode, output } = await container.exec(["id", "-un"]);
		assert.strictEqual(exitCode, 0);
		assert.strictEqual(output.trim(), "helm");
	});

	it("metadata: workdir is /home/helm", async () => {
		const { exitCode, output } = await container.exec(["pwd"]);
		assert.strictEqual(exitCode, 0);
		assert.strictEqual(output.trim(), "/home/helm");
	});
});
