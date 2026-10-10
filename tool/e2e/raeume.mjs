// Fotos aller Räume auf der Party-Karte (Sichtprüfung F-13: jede Figur im
// gedimmten Bild erkennbar). Aufruf: node raeume.mjs [ausgabeOrdner] [zusatzParameter]
import { starteBrowser } from './browser.mjs';
import path from 'node:path';
import fs from 'node:fs';
import { starteServer } from './server.mjs';

const repo = path.resolve(import.meta.dirname, '../..');
const aus = path.resolve(process.argv[2] ?? path.join(import.meta.dirname, 'fotos/raeume'));
const zusatz = process.argv[3] ?? 'pfad=ahmet&n=20';
fs.mkdirSync(aus, { recursive: true });

// Stellen des Detektivs: Mitte jedes Raums laut raeume.json (begehbare Kachel).
const stellen = [
  ['buffetsaal', '14.5,13.5'],
  ['buffetsaal_theke', '14.5,10.5'],
  ['vorratsraum', '14.5,4.5'],
  ['durchgang', '8.5,9.5'],
  ['kaminsaal', '5.5,13.5'],
  ['turmgang', '2.5,4.5'],
  ['ostsaal', '21.5,12.5'],
  ['windfang', '14.5,20.5'],
];

const server = await starteServer(path.join(repo, 'build/web'));
const port = server.address().port;
const browser = await starteBrowser();
const fremd = [];
const fehler = [];
for (const [name, at] of stellen) {
  const page = await browser.newPage({ locale: 'de-DE', viewport: { width: 1280, height: 800 } });
  page.on('request', (r) => {
    const u = new URL(r.url());
    if (!['127.0.0.1', 'localhost'].includes(u.hostname) && !['data:', 'blob:'].includes(u.protocol)) fremd.push(r.url());
  });
  page.on('console', (m) => { if (m.type() === 'error') fehler.push(`${name}: ${m.text()}`); });
  page.on('pageerror', (e) => fehler.push(`${name}: ${e.message}`));
  let bereit = false;
  page.on('console', (m) => { if (m.text().startsWith('PARTY foto=entscheidungen')) bereit = true; });
  await page.goto(`http://127.0.0.1:${port}/?party=schlosskeller&${zusatz}&bis=entscheidungen&at=${at}&zoom=1.05`, { waitUntil: 'load' });
  const ende = Date.now() + 60000;
  while (!bereit && Date.now() < ende) await page.waitForTimeout(300);
  await page.waitForTimeout(3500);
  const datei = path.join(aus, `${name}.png`);
  await page.screenshot({ path: datei });
  console.log('Foto:', datei);
  await page.close();
}
await browser.close();
server.close();
console.log(`Fremde Netzaufrufe: ${fremd.length}`);
console.log(`Konsolenfehler: ${fehler.length}`);
for (const f of fehler) console.log('  ', f);
process.exitCode = fremd.length + fehler.length > 0 ? 1 : 0;
