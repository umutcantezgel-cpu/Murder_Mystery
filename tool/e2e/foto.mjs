// Bildschirmfotos der Partymodus-Vorschau. Prüft dabei Konsolenfehler und Netzaufrufe außerhalb von localhost.
// Aufruf: node foto.mjs [buildOrdner] [ausgabeOrdner]
import { starteBrowser } from './browser.mjs';
import path from 'node:path';
import fs from 'node:fs';
import { starteServer } from './server.mjs';

const repo = path.resolve(import.meta.dirname, '../..');
const build = path.resolve(process.argv[2] ?? path.join(repo, 'build/web_party_preview'));
const aus = path.resolve(process.argv[3] ?? path.join(import.meta.dirname, 'fotos'));
fs.mkdirSync(aus, { recursive: true });

const server = await starteServer(build);
const port = server.address().port;
const browser = await starteBrowser();
const fremd = [];
const fehler = [];
const ansichten = [
  { name: 'schlosskeller_uebersicht', q: 'party=schlosskeller&zoom=0.55&at=13.5,11.5' },
  { name: 'schlosskeller_buffetsaal', q: 'party=schlosskeller&zoom=1.1&at=14.5,11.5' },
  { name: 'schlosskeller_kaminsaal', q: 'party=schlosskeller&zoom=1.1&at=3.5,12.5' },
  { name: 'schlosskeller_ostsaal', q: 'party=schlosskeller&zoom=1.1&at=23.0,12.5' },
];
for (const a of ansichten) {
  const page = await browser.newPage({ locale: 'de-DE', viewport: { width: 1280, height: 800 } });
  page.on('request', (r) => {
    const u = new URL(r.url());
    if (!['127.0.0.1', 'localhost'].includes(u.hostname) && u.protocol !== 'data:' && u.protocol !== 'blob:') fremd.push(r.url());
  });
  page.on('console', (m) => { if (m.type() === 'error') fehler.push(`${a.name}: ${m.text()}`); });
  page.on('pageerror', (e) => fehler.push(`${a.name}: ${e.message}`));
  await page.goto(`http://127.0.0.1:${port}/?${a.q}`, { waitUntil: 'load' });
  await page.waitForTimeout(6000);
  const datei = path.join(aus, `${a.name}.png`);
  await page.screenshot({ path: datei });
  console.log('Foto:', datei);
  await page.close();
}
await browser.close();
server.close();
console.log(`Fremde Netzaufrufe: ${fremd.length}`);
for (const f of fremd) console.log('  ', f);
console.log(`Konsolenfehler: ${fehler.length}`);
for (const f of fehler) console.log('  ', f);
process.exitCode = fremd.length + fehler.length > 0 ? 1 : 0;
