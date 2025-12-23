import { describe, it } from 'node:test';
import assert from 'node:assert';
import { GenericContainer } from 'testcontainers';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import fs from 'node:fs';

const __dirname = path.dirname(fileURLToPath(import.meta.url));

describe('ArgoCD CMP HK Deployment Image', () => {
  let container;
  const imageName = process.env.IMAGE_NAME || 'argocd-cmp-hk-deployment:latest';
  
  const workdir = process.cwd();
  const hostTestsDir = process.env.HOST_TESTS_DIR || path.join(__dirname, 'tests');

  // Helper function to run commands with environment
  async function runScript(script, env = {}) {
    // Prepare tests directory
    const prepCmd = ['bash', '-c', 'rm -rf /tmp/tests && cp -r /mnt/tests-ro /tmp/tests && chown -R argocd:argocd /tmp/tests'];
    const prepResult = await container.exec(prepCmd);
    if (prepResult.exitCode !== 0) {
      throw new Error(`Failed to prepare tests directory: ${prepResult.output}`);
    }

    // Build environment variable array
    const envVars = Object.entries(env).map(([key, value]) => `${key}=${value}`);
    
    // Execute the script - note: testcontainers for Node.js handles env differently
    // We'll need to use a shell wrapper to set env vars
    const envString = envVars.length > 0 ? envVars.join(' ') + ' ' : '';
    const cmd = ['bash', '-c', `cd /tmp/tests && ${envString}${script}`];
    
    return await container.exec(cmd);
  }

  function assertContains(output, ...expected) {
    for (const value of expected) {
      assert.ok(output.includes(value), `Expected output to contain "${value}", got: ${output}`);
    }
  }

  it('setup container', async () => {
    // Verify tests directory exists
    assert.ok(fs.existsSync(hostTestsDir), `Tests directory is required but missing: ${hostTestsDir}`);

    container = await new GenericContainer(imageName)
      .withCommand(['sleep', 'infinity'])
      .withEnvironment({
        ARGOCD_APP_NAME: 'hk-app',
        ARGOCD_APP_NAMESPACE: 'hk-ns',
        KUBE_VERSION: '1.33.0',
      })
      .withBindMounts([
        {
          source: hostTestsDir,
          target: '/mnt/tests-ro',
        },
      ])
      .start();
  });

  it('single-source renders helm output with provided deployment id', async () => {
    const result = await runScript('/hk-tools/single-source.sh', {
      ARGOCD_ENV_HOVERKRAFT_DEPLOYMENT_ID: '4242',
    });
    assert.strictEqual(result.exitCode, 0);
    assertContains(result.output, 'name: hoverkraft-deployment', 'deploymentId: "4242"');
  });

  it('single-source falls back to unknown deployment id', async () => {
    const result = await runScript('/hk-tools/single-source.sh', {});
    assert.strictEqual(result.exitCode, 0);
    assertContains(result.output, 'name: hoverkraft-deployment', 'deploymentId: unknown');
  });

  it('multi-sources propagates deployment id', async () => {
    const result = await runScript('/hk-tools/multi-sources.sh', {
      ARGOCD_ENV_HOVERKRAFT_DEPLOYMENT_ID: '7777',
    });
    assert.strictEqual(result.exitCode, 0);
    assertContains(result.output, 'name: hoverkraft-deployment', 'deploymentId: "7777"');
  });

  it('multi-sources defaults deployment id', async () => {
    const result = await runScript('/hk-tools/multi-sources.sh', {});
    assert.strictEqual(result.exitCode, 0);
    assertContains(result.output, 'name: hoverkraft-deployment', 'deploymentId: "unknown"');
  });

  it('entrypoint executes single-source when ARGOCD_MULTI_SOURCES is 0', async () => {
    const result = await runScript('/hk-tools/entrypoint.sh', {
      ARGOCD_ENV_ARGOCD_MULTI_SOURCES: '0',
      ARGOCD_ENV_HOVERKRAFT_DEPLOYMENT_ID: '1234',
    });
    assert.strictEqual(result.exitCode, 0);
    assertContains(result.output, 'name: hoverkraft-deployment', 'deploymentId: "1234"');
    assertContains(result.output, 'hoverkraft-deployment CMP plugin', 'single-source application');
  });

  it('entrypoint executes multi-sources when ARGOCD_MULTI_SOURCES is 1', async () => {
    const result = await runScript('/hk-tools/entrypoint.sh', {
      ARGOCD_ENV_ARGOCD_MULTI_SOURCES: '1',
      ARGOCD_ENV_HOVERKRAFT_DEPLOYMENT_ID: '5678',
    });
    assert.strictEqual(result.exitCode, 0);
    assertContains(result.output, 'name: hoverkraft-deployment', 'deploymentId: "5678"');
    assertContains(result.output, 'hoverkraft-deployment CMP plugin', 'multi-sources application');
  });

  it('entrypoint defaults to single-source when ARGOCD_MULTI_SOURCES is unset', async () => {
    const result = await runScript('/hk-tools/entrypoint.sh', {
      ARGOCD_ENV_HOVERKRAFT_DEPLOYMENT_ID: '9999',
      ARGOCD_APP_NAME: 'test-app',
    });
    assert.strictEqual(result.exitCode, 0);
    assertContains(result.output, 'name: hoverkraft-deployment', 'deploymentId: "9999"');
    assertContains(result.output, 'WARN: ARGOCD_MULTI_SOURCES is not set', 'single-source application');
  });

  it('entrypoint handles invalid ARGOCD_MULTI_SOURCES value', async () => {
    const result = await runScript('/hk-tools/entrypoint.sh', {
      ARGOCD_ENV_ARGOCD_MULTI_SOURCES: 'invalid',
      ARGOCD_ENV_HOVERKRAFT_DEPLOYMENT_ID: '8888',
    });
    assert.strictEqual(result.exitCode, 0);
    assertContains(result.output, 'WARN: ARGOCD_MULTI_SOURCES is invalid', 'WARN: defaulting to single source mode');
  });

  it('entrypoint with DEBUG enabled shows environment', async () => {
    const result = await runScript('/hk-tools/entrypoint.sh', {
      ARGOCD_ENV_DEBUG: 'true',
      ARGOCD_ENV_ARGOCD_MULTI_SOURCES: '0',
      ARGOCD_ENV_HOVERKRAFT_DEPLOYMENT_ID: '1111',
    });
    assert.strictEqual(result.exitCode, 0);
    assertContains(
      result.output,
      '+ DEBUG: current environment:',
      'ARGOCD_ENV_DEBUG=true',
      'ARGOCD_ENV_ARGOCD_MULTI_SOURCES=0',
      'ARGOCD_ENV_HOVERKRAFT_DEPLOYMENT_ID=1111'
    );
  });

  it('entrypoint display argocd app name', async () => {
    const result = await runScript('/hk-tools/entrypoint.sh', {
      ARGOCD_ENV_ARGOCD_MULTI_SOURCES: '1',
      ARGOCD_ENV_HOVERKRAFT_DEPLOYMENT_ID: '9999',
    });
    assert.strictEqual(result.exitCode, 0);
    assertContains(result.output, '+ application: hk-app');
  });

  it('entrypoint script is present', async () => {
    const { exitCode } = await container.exec(['test', '-x', '/hk-tools/entrypoint.sh']);
    assert.strictEqual(exitCode, 0);
  });

  it('single-source script is present', async () => {
    const { exitCode } = await container.exec(['test', '-x', '/hk-tools/single-source.sh']);
    assert.strictEqual(exitCode, 0);
  });

  it('multi-sources script is present', async () => {
    const { exitCode } = await container.exec(['test', '-x', '/hk-tools/multi-sources.sh']);
    assert.strictEqual(exitCode, 0);
  });

  it('kustomize template exists', async () => {
    const { exitCode } = await container.exec(['test', '-f', '/hk-tools/kustomize-template.yaml']);
    assert.strictEqual(exitCode, 0);
  });

  it('metadata: user is argocd', async () => {
    const { exitCode, output } = await container.exec(['id', '-un']);
    assert.strictEqual(exitCode, 0);
    assert.strictEqual(output.trim(), 'argocd');
  });

  it('cleanup container', async () => {
    if (container) {
      await container.stop();
    }
  });
});
