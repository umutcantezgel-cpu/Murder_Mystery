// Kontaktbogen: Bildschirmfotos aller wichtigen Bildschirme für die Bildprüfung des Designs.
// Keine Behauptungen, nur Fotos. Der Abend wird über `?party=<akte>&bis=<phase>` vorgespielt.
// Aufruf: node tool/e2e/kontaktbogen.mjs [--breiten 390,320] [--nur detektei,akte,…] [--ausgabe <ordner>]
//         [--akte <id>] [--warten <ms>] [--zusatz '&at=3,4&zoom=0.8'] (Zusatz hängt an die Abend-Adressen)
// Welt-Ebenen (M7a): 20-23 zeigen die Ebenen-Vorschau `?ebene=<id>` (nur Schlosskeller).
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
const breiten = opt('breiten', '390').split(',').map(Number);
const nur = opt('nur', '')?.split(',').filter(Boolean);
const ausgabe = path.resolve(opt('ausgabe', path.join(repo, 'tool/e2e/fotos/kontaktbogen')));
const warte = Number(opt('warten', '2500'));
await fs.mkdir(ausgabe, { recursive: true });

const akte = opt('akte', 'schlosskeller');
const zusatz = opt('zusatz', '');
const party = (phase, extra = '') => `?party=${akte}${akte === 'schlosskeller' ? '&pfad=ahmet' : ''}&n=6&bis=${phase}${extra}${zusatz}#/party`;
const ansichten = [
  ['01-detektei', ''],
  ['02-akte', `?screen=akte&akte=${akte}`],
  ['03-assistent', `?screen=neu&akte=${akte}`],
  ['04-sammlung', '?screen=sammlung'],
  ['05-profil', '?screen=profile'],
  ['10-rollen', party('rollen')],
  ['11-intro', party('intro')],
  ['12-gespraeche', party('gespraeche')],
  ['13-karte', party('entscheidungen')],
  ['14-gruppenwahl', party('gruppenwahl')],
  ['15-resuemee', party('resuemee')],
  ['16-anklage', party('anklage')],
  ['17-finale', party('finale')],
  ['18-aufloesung', party('aufloesung')],
  // Welt-Ebenen des langen Abends (M7a), Ebenen-Vorschau mit allem offen
  ...(akte === 'schlosskeller'
    ? [
      ['20-ebene-erdgeschoss', '?ebene=erdgeschoss&at=25.5,10.5&zoom=0.7#/ebenen'],
      ['21-ebene-turm', '?ebene=turm&at=8.5,8.5&zoom=1.0#/ebenen'],
      ['22-ebene-aussen', '?ebene=aussen&at=21.5,9.5&zoom=0.7#/ebenen'],
      ['23-ebene-keller', '?ebene=keller&at=2.5,2.5&zoom=1.0#/ebenen'],
    ]
    : []),
];

const server = await starteServer(path.join(repo, 'build/web'));
const base = `http://127.0.0.1:${server.address().port}/`;
const browser = await starteBrowser();
const fehler = [];
try {
  for (const breite of breiten) {
    const context = await browser.newContext({ locale: 'de-DE', viewport: { width: breite, height: 844 }, deviceScaleFactor: 2 });
    await context.addInitScript(() => localStorage.setItem('flutter.mordakte.name', JSON.stringify('Testdetektiv')));
    for (const [name, route] of ansichten) {
      if (nur.length && !nur.some((n) => name.includes(n))) continue;
      const page = await context.newPage();
      page.on('pageerror', (e) => fehler.push(`${name}@${breite}: ${e.message}`));
      await page.goto(base + route, { waitUntil: 'load' });
      await page.locator('flt-glass-pane, flutter-view').first().waitFor({ state: 'attached', timeout: 30000 });
      await page.waitForTimeout(warte);
      const datei = path.join(ausgabe, `${breite}-${name}${akte === 'schlosskeller' ? '' : '-' + akte}.png`);
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
if (fehler.length) console.log(`Fehler:\n${fehler.join('\n')}`);
