// Rollbild: ein Bildschirm, bis ans Ende gerollt (für lange Seiten wie Auflösung
// oder Einrichtung). Keine Behauptungen, nur Fotos.
// Aufruf: node tool/e2e/rollbild.mjs --adresse '?party=ravensmoor&n=6&bis=aufloesung' --name aufloesung
//         [--breite 390] [--rollen 4000] [--warten 4000] [--ausgabe <ordner>] [--tippen 'Text']
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
const adresse = opt('adresse', '');
const name = opt('name', 'rollbild');
const breite = Number(opt('breite', '390'));
const rollen = Number(opt('rollen', '4000'));
const warte = Number(opt('warten', '4000'));
const tippen = opt('tippen', '');
const ausgabe = path.resolve(opt('ausgabe', path.join(repo, 'tool/e2e/fotos/rollbild')));
await fs.mkdir(ausgabe, { recursive: true });

const server = await starteServer(path.join(repo, 'build/web'));
const browser = await starteBrowser();
const fehler = [];
try {
  const context = await browser.newContext({ locale: 'de-DE', viewport: { width: breite, height: 844 }, deviceScaleFactor: 2 });
  await context.addInitScript(() => localStorage.setItem('flutter.mordakte.name', JSON.stringify('Testdetektiv')));
  const page = await context.newPage();
  page.on('pageerror', (e) => fehler.push(e.message));
  await page.goto(`http://127.0.0.1:${server.address().port}/${adresse}`, { waitUntil: 'load' });
  await page.locator('flt-glass-pane, flutter-view').first().waitFor({ state: 'attached', timeout: 30000 });
  await page.waitForTimeout(warte);
  // Optional einen Knopf über die Barrierefreiheit antippen (z. B. „Weiter“).
  if (tippen) {
    await page.evaluate(() => document.querySelector('flt-semantics-placeholder')?.click());
    await page.waitForTimeout(500);
    for (const t of tippen.split('|')) {
      await page.getByRole('button', { name: t }).first().click();
      await page.waitForTimeout(1500);
    }
  }
  await page.mouse.move(breite / 2, 420);
  for (let rest = rollen; rest > 0; rest -= 400) {
    await page.mouse.wheel(0, Math.min(400, rest));
    await page.waitForTimeout(120);
  }
  await page.waitForTimeout(1500);
  const datei = path.join(ausgabe, `${breite}-${name}.png`);
  await page.screenshot({ path: datei });
  console.log(`Foto ${datei}`);
} finally {
  await browser.close();
  server.close();
}
if (fehler.length) {
  console.error(fehler.join('\n'));
  process.exit(1);
}
