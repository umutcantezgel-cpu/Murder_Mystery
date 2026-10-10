// Ein automatischer Partyabend mit Fotos an jeder Fotostelle (Probelauf F4-ORCH-01).
// Aufruf: node probe.mjs [parameter] [ausgabeOrdner]
//   parameter: URL-Parameter ohne „party=“, z. B. "pfad=ahmet&n=7&skript=best,a,richtig"
import { starteBrowser } from './browser.mjs';
import path from 'node:path';
import fs from 'node:fs';
import { starteServer } from './server.mjs';

const repo = path.resolve(import.meta.dirname, '../..');
const build = path.join(repo, 'build/web');
const param = process.argv[2] ?? 'pfad=ahmet&n=7&skript=best,a,richtig&takt=600&zeitraffer=50';
const aus = path.resolve(process.argv[3] ?? path.join(import.meta.dirname, 'fotos/probe'));
fs.mkdirSync(aus, { recursive: true });

const server = await starteServer(build);
const port = server.address().port;
const browser = await starteBrowser();
const page = await browser.newPage({ locale: 'de-DE', viewport: { width: 1280, height: 800 } });
const fremd = [];
const fehler = [];
let fertig = null;
let fotos = 0;
let kette = Promise.resolve();
page.on('request', (r) => {
  const u = new URL(r.url());
  if (!['127.0.0.1', 'localhost'].includes(u.hostname) && !['data:', 'blob:'].includes(u.protocol)) fremd.push(r.url());
});
page.on('pageerror', (e) => fehler.push(e.message));
page.on('console', (m) => {
  const t = m.text();
  if (m.type() === 'error') fehler.push(t);
  if (!t.startsWith('PARTY')) return;
  console.log(t.split('\n')[0]);
  const f = /^PARTY foto=(\S+)/.exec(t);
  if (f) {
    const n = String(++fotos).padStart(3, '0');
    kette = kette.then(() => new Promise((ok) => setTimeout(ok, 100))).then(() => page.screenshot({ path: path.join(aus, `${n}_${f[1]}.png`) })).catch((e) => fehler.push(String(e)));
  }
  if (t.startsWith('PARTY fertig')) fertig = t;
  if (t.startsWith('PARTY fehler')) fehler.push(t);
});
await page.goto(`http://127.0.0.1:${port}/?party=schlosskeller&${param}`, { waitUntil: 'load' });
const ende = Date.now() + 6 * 60 * 1000;
while (!fertig && Date.now() < ende && !fehler.some((f) => f.startsWith('PARTY fehler'))) await page.waitForTimeout(500);
await kette;
await browser.close();
server.close();
console.log(fertig ?? 'NICHT FERTIG');
console.log(`Fotos: ${fotos} in ${aus}`);
console.log(`Fremde Netzaufrufe: ${fremd.length}`);
for (const f of fremd) console.log('  ', f);
console.log(`Konsolenfehler: ${fehler.length}`);
for (const f of fehler) console.log('  ', f);
process.exitCode = fertig && fremd.length + fehler.length === 0 ? 0 : 1;
