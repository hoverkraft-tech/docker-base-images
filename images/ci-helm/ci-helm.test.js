import { after, before, describe, it } from "node:test";
import assert from "node:assert";
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
