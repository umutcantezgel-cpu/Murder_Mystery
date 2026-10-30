// Browserprobe der Druckmappe (PDF-Paket): der Weg zu den PDFs und die Erzählerakte im Web-Build.
// (1) Detektei bei 320 und 390 px: unter der Mappe des Schlosskellers der Knopf „PDFs zum Ausdrucken“,
//     ganz im Bild und genau einmal; die Mappe ist genau ein Knopf mit „Spuk im Schlosskeller“ im Namen
//     (der neue Knopf nennt die Akte nicht). (2) Tipp darauf: die Druckmappe mit ihren Standardwerten,
//     dann „Druckmappe vorbereiten“. (3) Tipp auf „Erzählerakte“: Zeit bis „Herunterladen: Erzählerakte“
//     (Ziel des PDF-Pakets: unter 20 s), dann der Download: Name, Größe, beginnt mit %PDF- und endet mit %%EOF.
//     (4) Zum Vergleich „Alles in einer Datei“ ebenso. (5) Akte-Seite des Schlosskellers bei 320 px: die
//     vier Knöpfe der Fußleiste ganz im Bild, ohne Überlappung, antippbar; „PDFs zum Ausdrucken“ öffnet
//     auch von hier die Druckmappe. Alle Tipps gehen als echter Zeiger durch den Flutter-Hittest.
// Geprüft wird außerdem: keine Konsolenfehler, keine Anfragen außer 127.0.0.1/localhost.
// Die Zeiten hängen am Rechner. Ein verfehltes Zeitziel meldet die Probe deshalb als Warnung
// (`ZEITZIEL VERFEHLT`); mit --zeitziel macht es sie rot. --drossel N rechnet wie ein langsameres Gerät
// (Chrome-CPU-Drosselung wie leistung.mjs: 4 = mittleres, 6 = einfaches Handy), nur auf der Seite der
// Schritte 2 bis 4. --ruhig öffnet alle Seiten mit „Bewegung reduzieren“ (der Dateiknopf zeigt beim Bauen
// ohnehin immer die ruhende Sanduhr, seit der Ladekreisel die Erzählerakte im Browser auf über 20 s brachte).
// Aufruf in tool/e2e: node druck.mjs [--breite 390] [--drossel 1] [--ruhig] [--zeitziel]
//   (--breite: Breite für die Schritte 2 bis 4)
// Ausgabe: fotos/druck/ (Fotos, kontaktbogen.png, die beiden PDFs, bericht.json).
// Rückgabewert 0 nur, wenn alle Prüfungen bestehen; 2 bei Aufruf- oder Bauproblemen.
import assert from 'node:assert/strict';
import fs from 'node:fs/promises';
import { existsSync } from 'node:fs';
import path from 'node:path';
import { starteBrowser } from './browser.mjs';
import { starteServer } from './server.mjs';

const hier = import.meta.dirname;
const repo = path.resolve(hier, '../..');
const build = path.join(repo, 'build/web');
const ausgabe = path.join(hier, 'fotos', 'druck');

const HOEHE = 844;
const BREITEN = [320, 390];
/** Ziel des Plans: Die Erzählerakte steht im Browser in unter 20 s bereit (sonst Porträts mit 240 px). */
const ZIEL_ERZAEHLERAKTE_S = 20;
/** Spätestens dann gilt eine Datei als gescheitert. */
const FRIST_DATEI_S = 180;
/** Ein Mausradschritt beim Suchen eines Knopfs unterhalb oder oberhalb des Bildes. */
const RAD = 300;
/**
 * Abstand zum Rand der rollenden Fläche: Die Semantik schneidet Knöpfe am Rand ab, ein halb
 * sichtbarer Knopf endet also genau dort. Mit diesem Abstand zählt er nicht als ganz im Bild.
 */
const RAND = 4;
/** Hier dreht die Probe das Mausrad: im linken Rand der rollenden Fläche, neben den Knöpfen. */
const RAD_X = 8;

const args = process.argv.slice(2);
const wert = (name, std) => {
  const i = args.indexOf(`--${name}`);
  return i >= 0 ? Number(args[i + 1]) : std;
};
const ABLAUF_BREITE = wert('breite', 390);
const DROSSEL = wert('drossel', 1);
const ZEITZIEL_STRENG = args.includes('--zeitziel');
const RUHIG = args.includes('--ruhig');
if (!BREITEN.includes(ABLAUF_BREITE) || !(DROSSEL >= 1)) {
  console.error(`DRUCK · Aufruf: node druck.mjs [--breite ${BREITEN.join('|')}] [--drossel N ≥ 1] [--ruhig] [--zeitziel]`);
  process.exit(2);
}
if (!existsSync(path.join(build, 'index.html'))) {
  console.error('DRUCK · build/web fehlt: flutter build web --release --no-web-resources-cdn -o build/web');
  process.exit(2);
}
await fs.rm(ausgabe, { recursive: true, force: true });
await fs.mkdir(ausgabe, { recursive: true });

// Texte aus der App (ARB) und aus der Akte (ui-Texte des Schlosskellers), keine Kopien.
const readJson = async (datei) => JSON.parse(await fs.readFile(path.join(repo, datei), 'utf8'));
const arb = await readJson('lib/l10n/app_de.arb');
const ui = new Map();
{
  const wurzel = 'content/party/schlosskeller/texte';
  const index = await readJson(`${wurzel}/index.json`);
  for (const eintrag of index.dateien.filter((e) => e.bereich === 'ui')) {
    for (const item of (await readJson(`${wurzel}/${eintrag.datei}`)).eintraege) ui.set(item.id, item.text);
  }
}
const text = (key, werte = {}) => {
  const roh = key.startsWith('ui.') ? ui.get(key) : arb[key];
  assert.equal(typeof roh, 'string', `Unbekannter Textschlüssel: ${key}`);
  return roh.replace(/\{(\w+)\}/g, (_, name) => werte[name] ?? `{${name}}`);
};
const T = {
  neuerAbend: text('detektei_neuer_abend'),
  pdfs: text('detektei_druck_pdfs'),
  vorbereiten: text('detektei_druck_vorbereiten'),
  zurueck: text('common_back'),
  steckbriefe: text('detektei_akte_steckbriefe'),
  spielen: text('detektei_akte_spielen'),
  laedt: text('druck_datei_laedt'),
  fehler: text('druck_datei_fehler'),
  akte: text('ui.druck.akte.titel'),
  alles: text('ui.druck.datei.alles'),
  nurErzaehler: text('ui.druck.paket.dateien.ordner4'),
  laden: (datei) => text('druck_datei_laden', { datei }),
};
const woertlich = (t) => t.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
const SENDEN = new RegExp(`^${woertlich(text('druck_senden_an', { name: '' }))}`);
/** Der Fall-Code im Hinweis der Druckfassung („… Fall-Code {code}. …“). */
const CODE = (() => {
  const [vor, nach] = text('ui.druck.app.hinweis').split('{code}');
  return new RegExp(`${woertlich(vor.slice(-10))}(\\S+?)${woertlich(nach.slice(0, 1))}`);
})();

const sleep = (ms) => new Promise((ok) => setTimeout(ok, ms));
const sekunden = (ms) => Math.round(ms / 100) / 10;
const fehler = [];
const fremd = [];
const bilder = [];
const bericht = { breite_ablauf: ABLAUF_BREITE, drossel: DROSSEL, ruhig: RUHIG, ziel_erzaehlerakte_s: ZIEL_ERZAEHLERAKTE_S, detektei: [], druckmappe: {}, dateien: [], akte: {}, konsolenfehler: 0, fremd: 0 };
const server = await starteServer(build);
const base = `http://127.0.0.1:${server.address().port}`;
let browser;
let aktiv;
let stufe = 'Start';

/** Alle Texte der Semantik (Beschriftungen und Text der Blätter). */
const sichtbareTexte = (page) => page.evaluate(() => [...document.querySelectorAll('flt-semantics')].flatMap((node) => {
  const label = (node.getAttribute('aria-label') || '').trim();
  if (label) return [label];
  return node.querySelector('flt-semantics') ? [] : [(node.textContent || '').trim()];
}).filter(Boolean));

async function warteBis(pruefung, label, frist = 30000) {
  const ende = Date.now() + frist;
  while (Date.now() < ende) {
    if (await pruefung()) return;
    await sleep(100);
  }
  throw new Error(`Zeitüberschreitung bei „${label}“`);
}

/** Eine Handyseite mit Fehler- und Netzwächter, gestartet bis zur Detektei. */
async function oeffne(breite) {
  const page = aktiv = await browser.newPage({ locale: 'de-DE', viewport: { width: breite, height: HOEHE }, deviceScaleFactor: 1, acceptDownloads: true, reducedMotion: RUHIG ? 'reduce' : 'no-preference' });
  page.on('pageerror', (e) => fehler.push(`${breite} px JavaScript: ${e.message}`));
  page.on('console', (m) => { if (m.type() === 'error') fehler.push(`${breite} px Konsole: ${m.text()}`); });
  await page.route('**/*', async (route) => {
    const u = new URL(route.request().url());
    if (!['127.0.0.1', 'localhost'].includes(u.hostname) && !['data:', 'blob:', 'about:'].includes(u.protocol)) {
      fremd.push(`${breite} px: ${route.request().url()}`);
      await route.abort();
    } else await route.continue();
  });
  // Ein Name vermeidet den Ersteinrichtungsdialog, den die Detektei sonst zeigt.
  await page.addInitScript(() => localStorage.setItem('flutter.mordakte.name', JSON.stringify('Testdetektiv')));
  await page.goto(base, { waitUntil: 'load' });
  const semantik = page.locator('flt-semantics-placeholder');
  await semantik.waitFor({ state: 'attached', timeout: 30000 });
  await semantik.evaluate((element) => element.click());
  await page.getByRole('button', { name: T.neuerAbend, exact: true }).waitFor({ timeout: 30000 });
  return page;
}

const knopf = (page, name) => page.getByRole('button', { name, exact: typeof name === 'string' });

/** Oberkante der Fußleiste (MRahmen): über ihr liegt der rollende Inhalt; ohne Fuß das Bildende. */
async function fussOben(page) {
  let oben = HOEHE;
  for (const name of [T.zurueck, T.vorbereiten]) {
    const k = knopf(page, name);
    if (await k.count() !== 1) continue;
    const box = await k.boundingBox();
    if (box) oben = Math.min(oben, box.y - 12);
  }
  return oben;
}

/**
 * Rollt mit dem Mausrad, bis [ziel] eindeutig und ganz zwischen Bildoberkante und Fußleiste liegt.
 * Knöpfe außerhalb des Bildes hat die Semantik oft noch nicht; dann rollt die Probe in [richtung].
 */
async function insBild(page, ziel, label, { richtung = 1, schritte = 40 } = {}) {
  // Gerollt wird am linken Rand (wie finale.mjs): Dort liegt kein Knopf, der Fotos mit Hover färbt.
  const rad = async (dy) => {
    await page.mouse.move(RAD_X, Math.min(300, (await fussOben(page)) / 2));
    await page.mouse.wheel(0, dy);
    await sleep(300);
  };
  for (let i = 0; i <= schritte; i++) {
    const n = await ziel.count();
    if (n === 1) {
      const box = await ziel.boundingBox();
      // Ein Knopf der Fußleiste selbst liegt immer im Bild, unter dem rollenden Inhalt.
      const fuss = await fussOben(page);
      const unten = box && box.y >= fuss - 1 ? HOEHE : fuss;
      if (box && box.width > 0 && box.y >= RAND && box.y + box.height <= unten - RAND) {
        // Flutter ordnet nach dem Rollen noch um: erst weiter, wenn die Lage drei Messungen lang gleich bleibt.
        let stabil = 0;
        let alt = box;
        const ende = Date.now() + 10000;
        while (stabil < 3 && Date.now() < ende) {
          await sleep(150);
          const neu = await ziel.boundingBox();
          stabil = neu && Math.abs(neu.x - alt.x) < 1 && Math.abs(neu.y - alt.y) < 1 ? stabil + 1 : 0;
          alt = neu ?? alt;
        }
        if (alt.y >= RAND && alt.y + alt.height <= unten - RAND) return alt;
        continue;
      }
      // Oben angeschnitten oder darüber: hoch rollen, sonst hinunter.
      if (box) { await rad(box.y < RAND ? -RAD : RAD); continue; }
    }
    if (n > 1) { await sleep(200); continue; }
    await rad(richtung * RAD);
  }
  throw new Error(`„${label}“ kommt nicht eindeutig ins Bild`);
}

/** Echter Zeiger auf die Mitte von [ziel], nachdem es ins Bild gerollt ist. */
async function tippe(page, ziel, label, optionen) {
  stufe = `${page.viewportSize().width} px · Tipp auf „${label}“`;
  const box = await insBild(page, ziel, label, optionen);
  assert(await ziel.isEnabled(), `„${label}“ ist gesperrt`);
  await page.mouse.click(box.x + box.width / 2, box.y + box.height / 2);
  await sleep(420);
}

async function foto(page, name, label, clip) {
  const datei = `${name}.png`;
  await page.screenshot({ path: path.join(ausgabe, datei), ...(clip ? { clip } : {}) });
  bilder.push({ datei, label });
}

/**
 * Tippt auf den Dateiknopf [name], misst die Zeit bis „Herunterladen: [name]“ und lädt die Datei.
 * Rückgabe: Sekunden, Dateiname, Bytes. Die Datei liegt danach unter fotos/druck/.
 */
async function datei(page, name, kuerzel, richtung) {
  const breite = page.viewportSize().width;
  const ziel = knopf(page, name);
  const laden = knopf(page, T.laden(name));
  await insBild(page, ziel, name, { richtung });
  stufe = `${breite} px · „${name}“ erstellen`;
  const box = await ziel.boundingBox();
  const start = performance.now();
  await page.mouse.click(box.x + box.width / 2, box.y + box.height / 2);
  // Der Ladehinweis des Dateiknopfs, solange die Datei entsteht. Kein Foto in dieser Zeit: Es
  // erzwingt zusätzliche Bilder und verlängerte die gemessene Zeit um rund 3 s.
  let hinweis = false;
  try {
    await page.getByText(T.laedt, { exact: true }).waitFor({ state: 'visible', timeout: 3000 });
    hinweis = true;
  } catch { /* Sehr schnelle Dateien zeigen den Hinweis kaum. */ }
  let ende = null;
  const frist = Date.now() + FRIST_DATEI_S * 1000;
  while (Date.now() < frist) {
    if (await laden.count() >= 1) { ende = performance.now(); break; }
    if (await page.getByText(T.fehler, { exact: true }).count()) throw new Error(`„${name}“: ${T.fehler}`);
    await sleep(100);
  }
  assert(ende !== null, `„${name}“ ist nach ${FRIST_DATEI_S} s nicht fertig`);
  const s = sekunden(ende - start);
  console.log(`DRUCK · ${breite} px · „${name}“ bereit nach ${s} s (Ladehinweis ${hinweis ? 'gesehen' : 'nicht gesehen'})`);
  await insBild(page, laden.first(), T.laden(name), { richtung: 1 });
  await foto(page, `${kuerzel}-bereit-${breite}`, `${breite} px · ${T.laden(name)}`);
  stufe = `${breite} px · „${T.laden(name)}“`;
  const boxLaden = await laden.first().boundingBox();
  const [download] = await Promise.all([
    page.waitForEvent('download', { timeout: 30000 }),
    page.mouse.click(boxLaden.x + boxLaden.width / 2, boxLaden.y + boxLaden.height / 2),
  ]);
  const dateiname = download.suggestedFilename();
  const ziel2 = path.join(ausgabe, dateiname);
  await download.saveAs(ziel2);
  const bytes = await fs.readFile(ziel2);
  assert.equal(bytes.subarray(0, 5).toString('latin1'), '%PDF-', `${dateiname} beginnt nicht mit %PDF-`);
  assert(bytes.subarray(-1024).toString('latin1').includes('%%EOF'), `${dateiname} endet ohne %%EOF`);
  assert.match(dateiname, /\.pdf$/, `${dateiname} ist keine PDF-Datei`);
  await sleep(600);
  const fehlerText = await page.getByText(T.fehler, { exact: true }).count();
  assert.equal(fehlerText, 0, `Nach „${T.laden(name)}“ steht „${T.fehler}“`);
  const eintrag = { knopf: name, sekunden: s, datei: dateiname, bytes: bytes.length, ladehinweis: hinweis };
  console.log(`DRUCK · ${breite} px · ${dateiname}: ${bytes.length} Bytes, %PDF-`);
  bericht.dateien.push(eintrag);
  return eintrag;
}

try {
  browser = await starteBrowser();
  let ablauf;
  // (1) Detektei bei 320 und 390 px.
  for (const breite of BREITEN) {
    stufe = `${breite} px · Detektei`;
    const page = await oeffne(breite);
    const akte = knopf(page, /Spuk im Schlosskeller/);
    await akte.first().waitFor({ timeout: 30000 });
    await warteBis(async () => await akte.count() === 1, 'genau eine Mappe „Spuk im Schlosskeller“');
    const pdfs = knopf(page, T.pdfs);
    const box = await insBild(page, pdfs, T.pdfs);
    assert.equal(await pdfs.count(), 1, `„${T.pdfs}“ ist nicht genau einmal da`);
    assert.equal(await akte.count(), 1, 'Die Mappe „Spuk im Schlosskeller“ ist nicht genau ein Knopf');
    assert(box.x >= 0 && box.x + box.width <= breite, `„${T.pdfs}“ ragt seitlich aus dem Bild`);
    const mappe = await akte.boundingBox();
    // Der Knopf steht unter der Mappe, nicht in ihr.
    assert(mappe && box.y >= mappe.y + mappe.height - 1, `„${T.pdfs}“ liegt nicht unter der Mappe`);
    await foto(page, `detektei-${breite}`, `Detektei · ${breite} × ${HOEHE}`);
    bericht.detektei.push({ breite, knopf: { x: Math.round(box.x), y: Math.round(box.y), b: Math.round(box.width), h: Math.round(box.height) } });
    console.log(`DRUCK OK · ${breite} px · Detektei: „${T.pdfs}“ unter der Mappe, die Mappe genau einmal`);
    if (breite === ABLAUF_BREITE) ablauf = page;
    else await page.close();
  }

  // (2) Druckmappe mit den Standardwerten, dann vorbereiten.
  const page = aktiv = ablauf;
  const breite = ABLAUF_BREITE;
  if (DROSSEL > 1) {
    const cdp = await page.context().newCDPSession(page);
    await cdp.send('Emulation.setCPUThrottlingRate', { rate: DROSSEL });
    console.log(`DRUCK · CPU-Drosselung ${DROSSEL}× für die Schritte 2 bis 4`);
  }
  await tippe(page, knopf(page, T.pdfs), T.pdfs);
  stufe = `${breite} px · Druckmappe`;
  const vorbereiten = knopf(page, T.vorbereiten);
  await vorbereiten.waitFor({ state: 'visible', timeout: 30000 });
  await warteBis(() => vorbereiten.isEnabled(), `„${T.vorbereiten}“ offen`);
  await sleep(800);
  await foto(page, `druckmappe-${breite}`, `${breite} px · Druckmappe (Standardwerte)`);
  await tippe(page, vorbereiten, T.vorbereiten);
  stufe = `${breite} px · Druckmappe vorbereitet`;
  await knopf(page, T.alles).waitFor({ state: 'visible', timeout: 30000 });
  await sleep(800);
  const texte = await sichtbareTexte(page);
  const code = texte.join('\n').match(CODE)?.[1] ?? null;
  const personen = await page.getByRole('button', { name: SENDEN }).count();
  assert(personen >= 1, 'Keine Rollenhefte je Person');
  assert(texte.some((t) => t.includes(T.nurErzaehler)), `Abschnitt „${T.nurErzaehler}“ fehlt`);
  bericht.druckmappe = { fall_code: code, rollenhefte: personen };
  await foto(page, `druckmappe-bereit-${breite}`, `${breite} px · ${T.vorbereiten}`);
  console.log(`DRUCK OK · ${breite} px · Druckmappe vorbereitet: ${personen} Rollenhefte, Fall-Code ${code ?? '–'}`);

  // (3) Erzählerakte, (4) zum Vergleich alles in einer Datei (steht oben: zurückrollen).
  const akteDatei = await datei(page, T.akte, 'erzaehlerakte', 1);
  assert.equal(akteDatei.datei, 'erzaehlerakte.pdf', 'Die Erzählerakte heißt nicht erzaehlerakte.pdf');
  const allesDatei = await datei(page, T.alles, 'alles', -1);
  assert.notEqual(allesDatei.datei, akteDatei.datei, 'Alles in einer Datei und die Erzählerakte tragen denselben Namen');
  await page.close();

  // (5) Akte-Seite des Schlosskellers bei 320 px: die Fußleiste.
  stufe = '320 px · Akte-Seite';
  const schmal = await oeffne(320);
  await tippe(schmal, knopf(schmal, /Spuk im Schlosskeller/), 'Spuk im Schlosskeller');
  await knopf(schmal, T.spielen).waitFor({ state: 'visible', timeout: 30000 });
  await sleep(800);
  const fuss = [];
  for (const name of [T.zurueck, T.steckbriefe, T.pdfs, T.spielen]) {
    const k = knopf(schmal, name);
    assert.equal(await k.count(), 1, `Fußknopf „${name}“ ist nicht genau einmal da`);
    assert(await k.isVisible(), `Fußknopf „${name}“ ist nicht sichtbar`);
    assert(await k.isEnabled(), `Fußknopf „${name}“ ist gesperrt`);
    const b = await k.boundingBox();
    assert(b && b.x >= 0 && b.y >= 0 && b.x + b.width <= 320 && b.y + b.height <= HOEHE, `Fußknopf „${name}“ ragt aus dem Bild`);
    fuss.push({ name, ...b });
  }
  for (let i = 0; i < fuss.length; i++) {
    for (let j = i + 1; j < fuss.length; j++) {
      const a = fuss[i], b = fuss[j];
      const ueber = a.x < b.x + b.width - 0.5 && b.x < a.x + a.width - 0.5 && a.y < b.y + b.height - 0.5 && b.y < a.y + a.height - 0.5;
      assert(!ueber, `Fußknöpfe „${a.name}“ und „${b.name}“ überlappen`);
    }
  }
  const oben = Math.max(0, Math.min(...fuss.map((b) => b.y)) - 14);
  await foto(schmal, 'akte-320', `Akte Schlosskeller · 320 × ${HOEHE}`);
  await foto(schmal, 'akte-fuss-320', 'Akte Schlosskeller · Fußleiste bei 320 px', { x: 0, y: oben, width: 320, height: HOEHE - oben });
  bericht.akte = { fuss: fuss.map((b) => ({ name: b.name, x: Math.round(b.x), y: Math.round(b.y), b: Math.round(b.width), h: Math.round(b.height) })), zeilen: new Set(fuss.map((b) => Math.round(b.y))).size };
  // Antippbar: „PDFs zum Ausdrucken“ führt auch von der Akte in die Druckmappe.
  await tippe(schmal, knopf(schmal, T.pdfs), T.pdfs);
  await knopf(schmal, T.vorbereiten).waitFor({ state: 'visible', timeout: 30000 });
  console.log(`DRUCK OK · 320 px · Akte: vier Fußknöpfe ganz im Bild (${bericht.akte.zeilen} Zeilen), „${T.pdfs}“ öffnet die Druckmappe`);
  await schmal.close();

  bericht.konsolenfehler = fehler.length;
  bericht.fremd = fremd.length;
  assert.equal(fehler.length, 0, `Konsolenfehler: ${fehler.join(' | ')}`);
  assert.equal(fremd.length, 0, `Fremde Anfragen: ${fremd.join(' | ')}`);
  stufe = 'Zeitziel';
  bericht.ziel_erreicht = akteDatei.sekunden < ZIEL_ERZAEHLERAKTE_S;
  if (!bericht.ziel_erreicht) {
    const meldung = `Die Erzählerakte braucht ${akteDatei.sekunden} s (Ziel unter ${ZIEL_ERZAEHLERAKTE_S} s, Drosselung ${DROSSEL}×${RUHIG ? ', ruhig' : ''})`;
    if (ZEITZIEL_STRENG) throw new Error(meldung);
    console.warn(`DRUCK · ZEITZIEL VERFEHLT · ${meldung}`);
  }

  // Kontaktbogen aller Fotos.
  const bogen = await browser.newPage({ locale: 'de-DE', viewport: { width: 1280, height: 960 }, deviceScaleFactor: 1 });
  const figuren = await Promise.all(bilder.map(async ({ datei: d, label }) => {
    const bild = (await fs.readFile(path.join(ausgabe, d))).toString('base64');
    return `<figure><figcaption>${label}</figcaption><img src="data:image/png;base64,${bild}"></figure>`;
  }));
  await bogen.setContent(`<html><body style="margin:0;background:#18151f;color:#f1ede4;font:15px sans-serif"><h2 style="margin:24px">Mordakte · PDFs zum Ausdrucken</h2><main style="display:flex;flex-wrap:wrap;align-items:flex-start;gap:20px;padding:0 20px 20px">${figuren.join('')}</main><style>figure{margin:0;width:300px}figcaption{margin-bottom:8px;min-height:2.6em}img{display:block;max-width:300px}</style></body></html>`);
  await bogen.locator('img').evaluateAll((imgs) => Promise.all(imgs.map((img) => img.decode())));
  await bogen.screenshot({ path: path.join(ausgabe, 'kontaktbogen.png'), fullPage: true });
  await bogen.close();
  console.log(`DRUCK GRÜN · Detektei 2/2 · Drosselung ${DROSSEL}×${RUHIG ? ' · ruhig' : ''} · Erzählerakte ${akteDatei.sekunden} s, ${akteDatei.bytes} Bytes · Alles ${allesDatei.sekunden} s, ${allesDatei.bytes} Bytes · 0 Konsolenfehler · 0 fremde Netzaufrufe`);
} catch (error) {
  await aktiv?.screenshot({ path: path.join(ausgabe, 'fehler.png') }).catch(() => {});
  bericht.fehler = `${stufe} · ${String(error.message).slice(0, 1600)}`;
  bericht.konsolenfehler = fehler.length;
  bericht.fremd = fremd.length;
  console.error(`DRUCK ROT · ${bericht.fehler}`);
  process.exitCode = 1;
} finally {
  bericht.fotos = bilder.map((b) => b.datei);
  await fs.writeFile(path.join(ausgabe, 'bericht.json'), `${JSON.stringify(bericht, null, 2)}\n`);
  await browser?.close();
  server.close();
}
