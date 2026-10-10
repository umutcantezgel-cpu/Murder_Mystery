import assert from 'node:assert/strict';
import test from 'node:test';
import { browserOptionen } from './browser.mjs';

test('Standard verwendet das installierte Playwright-Chromium, keinen Maschinenpfad', () => {
  assert.deepEqual(browserOptionen({}), { headless: true });
});

test('Expliziter lokaler Browserpfad wird unverändert weitergereicht', () => {
  assert.deepEqual(browserOptionen({ MORDAKTE_CHROMIUM: ' /local/chromium ' }), {
    headless: true, executablePath: '/local/chromium',
  });
});

test('Leere Konfiguration fällt auf Playwright zurück', () => {
  assert.deepEqual(browserOptionen({ MORDAKTE_CHROMIUM: ' ' }), { headless: true });
});

test('Native Bibliotheken werden nur an den Browser weitergereicht', () => {
  const env = { MORDAKTE_BROWSER_LIBRARY_PATH: '/local/libs', PATH: '/bin' };
  assert.deepEqual(browserOptionen(env), {
    headless: true, env: { ...env, LD_LIBRARY_PATH: '/local/libs' },
  });
  assert.equal(env.LD_LIBRARY_PATH, undefined);
});
