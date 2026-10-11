// Echter App-Start ohne Entwicklerroute: die Detektei als Start des einen Spiels,
// die Akte als Knopf, keine alten Menütexte mehr, mobile Bildschirmfotos.
// Aufruf: node tool/e2e/start.mjs. Ausgabe unter tool/e2e/fotos/start/.
import assert from 'node:assert/strict';
import fs from 'node:fs/promises';
import path from 'node:path';
import { starteBrowser } from './browser.mjs';
import { starteServer } from './server.mjs';

const repo = path.resolve(import.meta.dirname, '../..');
const output = path.join(import.meta.dirname, 'fotos/start');
await fs.mkdir(output, { recursive: true });
const server = await starteServer(path.join(repo, 'build/web'));
const base = `http://127.0.0.1:${server.address().port}`;
// Texte des alten Menüs; sie dürfen im Start nirgends mehr stehen.
const altesMenue = ['Andere Abende & Fälle', 'Spuk im Gewölbe', 'Klassische Fälle'];
let browser;
const errors = [];
const pictures = [];
try {
  browser = await starteBrowser();
  for (const width of [320, 390]) {
    const page = await browser.newPage({ locale: 'de-DE', viewport: { width, height: 844 }, deviceScaleFactor: 1 });
    page.on('pageerror', () => errors.push(`JavaScript-Fehler bei ${width} px`));
    page.on('console', (message) => { if (message.type() === 'error') errors.push(`Konsolenfehler bei ${width} px`); });
    await page.route('**/*', async (route) => {
      const url = new URL(route.request().url());
      if (!['127.0.0.1', 'localhost'].includes(url.hostname) && !['data:', 'blob:', 'about:'].includes(url.protocol)) {
        errors.push('Unerwarteter externer Netzaufruf');
        await route.abort();
      } else await route.continue();
    });
    // Ein Name vermeidet den Ersteinrichtungsdialog, den die Detektei sonst zeigt.
    await page.addInitScript(() => localStorage.setItem('flutter.mordakte.name', JSON.stringify('Testdetektiv')));
    await page.goto(base, { waitUntil: 'load' });
    const semantics = page.locator('flt-semantics-placeholder');
    await semantics.waitFor({ state: 'attached', timeout: 30000 });
    await semantics.evaluate((element) => element.click());
    await page.getByRole('button', { name: 'Neuer Abend', exact: true }).waitFor({ timeout: 30000 });
    const akte = page.getByRole('button', { name: /Spuk im Schlosskeller/ });
    await akte.waitFor({ timeout: 30000 });
    assert.equal(await akte.count(), 1, 'Die Akte ist genau einmal als Knopf da');
    for (const text of altesMenue) {
      assert.equal(await page.getByRole('button', { name: text }).count(), 0, `Altes Menü sichtbar: ${text}`);
      const gefunden = await page.evaluate((t) => [...document.querySelectorAll('flt-semantics')]
        .some((node) => (node.getAttribute('aria-label') ?? '').includes(t) || (node.textContent ?? '').includes(t)), text);
      assert.equal(gefunden, false, `Altes Menü im Start: ${text}`);
    }
    const filename = `detektei-start-${width}.png`;
    await page.screenshot({ path: path.join(output, filename) });
    pictures.push({ filename, label: `Detektei · ${width} × 844` });
    console.log(`START OK · ${width} px · Detektei mit Akte „Spuk im Schlosskeller“, ohne alte Menütexte`);
    await page.close();
  }
  assert.equal(errors.length, 0, errors.join('; '));
  const sheet = await browser.newPage({ locale: 'de-DE', viewport: { width: 800, height: 960 }, deviceScaleFactor: 1 });
  const images = await Promise.all(pictures.map(async ({ filename, label }) => {
    const image = (await fs.readFile(path.join(output, filename))).toString('base64');
    return `<figure><figcaption>${label}</figcaption><img src="data:image/png;base64,${image}"></figure>`;
  }));
  await sheet.setContent(`<html><body style="margin:0;background:#18151f;color:#f1ede4;font:16px sans-serif"><h2 style="margin:24px">Mordakte · Die Detektei als Start</h2><main style="display:flex;align-items:flex-start;gap:20px;padding:0 20px">${images.join('')}</main><style>figure{margin:0}figcaption{margin-bottom:12px}img{display:block;max-height:844px;max-width:390px}</style></body></html>`);
  await sheet.locator('img').evaluateAll((images) => Promise.all(images.map((image) => image.decode())));
  await sheet.screenshot({ path: path.join(output, 'kontaktbogen.png'), fullPage: true });
  await sheet.close();
  console.log('START GRÜN · 2/2 Handygrößen · 0 Konsolenfehler · 0 fremde Netzaufrufe');
} catch (error) {
  console.error(`START ROT · ${error.message}`);
  process.exitCode = 1;
} finally {
  await browser?.close();
  server.close();
}
