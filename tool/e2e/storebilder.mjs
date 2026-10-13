// Store-Bilder (M8): die wichtigsten Bildschirme in den Formaten der Stores.
// Keine Behauptungen, nur Fotos. Abende werden über `?party=<akte>&bis=<phase>` vorgespielt.
// Aufruf: node tool/e2e/storebilder.mjs [--ausgabe <ordner>] [--warten <ms>]
// Formate: iPhone 6,7" (1290 × 2796), Android-Telefon 9:16 (1080 × 1920).
// Voraussetzung: build/web (flutter build web --release --no-web-resources-cdn).
import fs from 'node:fs/promises';
import path from 'node:path';
import { starteBrowser } from './browser.mjs';
import { starteServer } from './server.mjs';

const repo = path.resolve(import.meta.dirname, '../..');
const args = process.argv.slice(2);
const opt = (name, std) => {
  const i = args.indexOf(`--${name}`);
  return i >= 0 && i + 1 < args.length ? args[i + 1] : std;
};
const ausgabe = path.resolve(opt('ausgabe', path.join(repo, 'tool/e2e/fotos/store')));
const warte = Number(opt('warten', '7000'));
await fs.mkdir(ausgabe, { recursive: true });

const formate = [
  { name: 'ios-6.7', breite: 430, hoehe: 932, faktor: 3 },
  { name: 'android', breite: 360, hoehe: 640, faktor: 3 },
];
const abend = (akte, phase, extra = '') => `?party=${akte}&n=6&bis=${phase}${extra}#/party`;
const ansichten = [
  ['1-detektei', ''],
  ['2-akte', '?screen=akte&akte=ravensmoor'],
  ['3-karte', abend('ravensmoor', 'entscheidungen')],
  ['4-gespraech', abend('ravensmoor', 'entscheidungen', '&gespraech=zofe,1')],
  ['5-anklage', abend('nachtexpress', 'anklage')],
  // Kein Ende und keine Auflösung: Sie zeigen den Täter.
  ['6-rollen', abend('schlosskeller', 'rollen')],
];

const server = await starteServer(path.join(repo, 'build/web'));
const base = `http://127.0.0.1:${server.address().port}/`;
const browser = await starteBrowser();
const fehler = [];
try {
  for (const f of formate) {
    const context = await browser.newContext({ locale: 'de-DE', viewport: { width: f.breite, height: f.hoehe }, deviceScaleFactor: f.faktor });
    await context.addInitScript(() => localStorage.setItem('flutter.mordakte.name', JSON.stringify('Ermittlerin')));
    for (const [name, route] of ansichten) {
      const page = await context.newPage();
      page.on('pageerror', (e) => fehler.push(`${name}@${f.name}: ${e.message}`));
      await page.goto(base + route, { waitUntil: 'load' });
      await page.locator('flt-glass-pane, flutter-view').first().waitFor({ state: 'attached', timeout: 30000 });
      await page.waitForTimeout(warte);
      const datei = path.join(ausgabe, `${f.name}-${name}.png`);
      await page.screenshot({ path: datei });
      console.log(`Foto ${datei}`);
      await page.close();
    }
    await context.close();
  }
} finally {
  await browser.close();
  server.close();
}
if (fehler.length) {
  console.error(fehler.join('\n'));
  process.exit(1);
}
