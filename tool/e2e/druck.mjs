// Browserprobe der Druckmappe (Kammerspiel, B1/B3/E16): der Weg zu den PDFs im Web-Build.
// (1) Detektei bei 320 und 390 px: Vor jedem Rollen liegt „PDFs zum Ausdrucken“ oben ganz im Bild, mittig
//     und vor „Neuer Abend“ (Foto detektei-oben-<breite>). Auf einem hohen Bild, in dem beide zugleich
//     liegen, gibt es den Knopf genau zweimal; der zweite liegt unter der Mappe des Schlosskellers und
//     kommt beim Rollen ganz ins Bild (Foto detektei-<breite>), ein Tipp darauf öffnet die Druckmappe. Die
//     Mappe ist genau ein Knopf mit „Spuk im Schlosskeller“ im Namen (die Knöpfe nennen die Akte nicht).
//     (2) Neu geöffnet, ohne Rollen: Tipp auf den oberen Knopf, die Druckmappe mit ihren Standardwerten
//     (Personen nach fall.json, ohne Gästeliste; keine Fall-Wahl). Personen wählen: „Eine Person mehr“ und
//     „Eine Person weniger“ bis zur Zielzahl (Zusatzrolle allein, also mit Zusatzheft), dazu „Detektiv“
//     ankreuzen, dann „Druckmappe vorbereiten“. Die Tafel nennt Personen und Rollen, hat die acht Teile, je
//     Rolle „Senden an …“ und keine Erzählerakte (E16). (3) „Alles in einer Datei“: Zeit bis „Herunterladen:
//     …“, dann der Download: Name kammerspiel-alles.pdf, Größe, beginnt mit %PDF- und endet mit %%EOF.
//     (4) Ein Einzelheft, „Senden an“ die Rolle auf Platz 1 (Ziel: unter 20 s bis „Herunterladen: Rollenheft
//     …“), ebenso geprüft; dazu das Zusatzheft der allein spielenden Zusatzrolle. (5) Akte-Seite des
//     Schlosskellers bei 320 px: die vier Knöpfe der Fußleiste ganz im Bild, ohne Überlappung, antippbar;
//     „PDFs zum Ausdrucken“ öffnet auch von hier die Druckmappe. Alle Tipps gehen als echter Zeiger durch den
//     Flutter-Hittest.
// Geprüft wird außerdem: keine Konsolenfehler, keine Anfragen außer 127.0.0.1/localhost.
// Die Zeiten hängen am Rechner. Ein verfehltes Zeitziel meldet die Probe deshalb als Warnung
// (`ZEITZIEL VERFEHLT`); mit --zeitziel macht es sie rot. --drossel N rechnet wie ein langsameres Gerät
// (Chrome-CPU-Drosselung wie leistung.mjs: 4 = mittleres, 6 = einfaches Handy), nur auf der Seite der
// Schritte 2 bis 4. --ruhig öffnet alle Seiten mit „Bewegung reduzieren“ (der Dateiknopf zeigt beim Bauen
// ohnehin immer die ruhende Sanduhr).
// Aufruf in tool/e2e: node druck.mjs [--breite 390] [--drossel 1] [--ruhig] [--zeitziel] [--personen 13]
//   [--build build/web]
//   (--breite: Breite für die Schritte 2 bis 4; --personen: Zielzahl der Druckmappe, ungerade Rollenzahl ab
//   13, damit eine Zusatzrolle allein spielt; --build: Ordner des Web-Builds, relativ zum Repo)
// Ausgabe: fotos/druck/ (Fotos, kontaktbogen.png, die drei PDFs, bericht.json).
// Rückgabewert 0 nur, wenn alle Prüfungen bestehen; 2 bei Aufruf- oder Bauproblemen.
import assert from 'node:assert/strict';
import fs from 'node:fs/promises';
import { existsSync } from 'node:fs';
import path from 'node:path';
import { starteBrowser } from './browser.mjs';
import { starteServer } from './server.mjs';

const hier = import.meta.dirname;
const repo = path.resolve(hier, '../..');
const ausgabe = path.join(hier, 'fotos', 'druck');

const HOEHE = 844;
const BREITEN = [320, 390];
/**
 * Hohes Bild nur zum Zählen: Die Detektei liegt bis unter die Mappen ohne Rollen darin. Knöpfe außerhalb
 * des Bildes hat die Semantik oft nicht, im Handybild lassen sich beide Knöpfe also nicht zugleich zählen.
 */
const HOCH = 2400;
/** Hohes Bild für die vorbereitete Druckmappe: Tafel mit acht Teilen und bis zu 18 Heften ganz in der Semantik. */
const HOCH_MAPPE = 4000;
/**
 * Ziel für ein Einzelheft: Es steht im Browser in unter 20 s bereit. Früher galt das Ziel der Erzählerakte, die
 * die Druckmappe seit dem Kammerspiel nicht mehr anbietet (E16); das Heft je Person ist die Datei, die man am
 * Abend vorher für jeden Gast einzeln holt.
 */
const ZIEL_EINZELHEFT_S = 20;
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
/** Web-Build: Vorgabe build/web im Repo, mit --build ein anderer Ordner (etwa ein eigener Build zum Prüfen). */
const build = (() => {
  const i = args.indexOf('--build');
  return i >= 0 && args[i + 1] ? path.resolve(repo, args[i + 1]) : path.join(repo, 'build/web');
})();
const ABLAUF_BREITE = wert('breite', 390);
const DROSSEL = wert('drossel', 1);
const ZEITZIEL_STRENG = args.includes('--zeitziel');
const RUHIG = args.includes('--ruhig');
const ZIEL_PERSONEN = wert('personen', 13);
if (!BREITEN.includes(ABLAUF_BREITE) || !(DROSSEL >= 1) || !Number.isInteger(ZIEL_PERSONEN)) {
  console.error(`DRUCK · Aufruf: node druck.mjs [--breite ${BREITEN.join('|')}] [--drossel N ≥ 1] [--ruhig] [--zeitziel] [--personen N] [--build ordner]`);
  process.exit(2);
}
if (!existsSync(path.join(build, 'index.html'))) {
  console.error(`DRUCK · ${path.relative(repo, build) || build} fehlt: flutter build web --release --no-web-resources-cdn -o build/web`);
  process.exit(2);
}

// Texte aus der App (ARB), aus der Akte (ui-Texte des Schlosskellers) und aus dem Kammerspiel
// (content/kammerspiel/schlosskeller: fall.json und ui/*.json), keine Kopien.
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
const KAMMER = 'content/kammerspiel/schlosskeller';
const fall = await readJson(`${KAMMER}/fall.json`);
const kammerUi = {};
for (const teil of ['gemeinsam', ...fall.teile]) kammerUi[teil] = await readJson(`${KAMMER}/ui/${teil}.json`);
/** Beschriftung aus ui/<teil>.json ohne Auszeichnung (wie kammerKlartext); Platzhalter füllt [werte]. */
const kammer = (teil, schluessel, werte = {}) => {
  const roh = kammerUi[teil]?.[schluessel];
  assert.equal(typeof roh, 'string', `Unbekannte Beschriftung: ui/${teil}.json ${schluessel}`);
  const t = roh.replace(/\{(\w+)\}/g, (_, name) => werte[name] ?? `{${name}}`).replace(/\*\*|\*/g, '');
  assert(!/[{}]/.test(t), `ui/${teil}.json ${schluessel}: Platzhalter offen in „${t}“`);
  return t;
};
/** Dateiwort wie dateiWort in satz.dart: klein, Umlaute ausgeschrieben, sonst Bindestriche. */
const dateiWort = (s) => s.toLowerCase().replaceAll('ä', 'ae').replaceAll('ö', 'oe').replaceAll('ü', 'ue').replaceAll('ß', 'ss')
  .replace(/[^a-z0-9]+/g, '-').replace(/^-+|-+$/g, '');
const P = fall.personen;
assert(ZIEL_PERSONEN >= P.min && ZIEL_PERSONEN <= P.max && ZIEL_PERSONEN !== P.vorgabe, `--personen muss zwischen ${P.min} und ${P.max} liegen und von der Vorgabe ${P.vorgabe} abweichen`);
const ZIEL_ROLLEN = ZIEL_PERSONEN - P.ohneRolle.length;
/** Besetzt sind die Plätze 1 bis ZIEL_ROLLEN; die letzte Zusatzrolle spielt bei ungerader Zahl allein. */
const besetzt = fall.plaetze.slice(0, ZIEL_ROLLEN);
const erster = besetzt[0];
const zusatz = besetzt.filter((p) => p.art === 'zusatz').at(-1) ?? null;
const T = {
  neuerAbend: text('detektei_neuer_abend'),
  pdfs: text('detektei_druck_pdfs'),
  vorbereiten: text('detektei_druck_vorbereiten'),
  zurueck: text('common_back'),
  steckbriefe: text('detektei_akte_steckbriefe'),
  spielen: text('detektei_akte_spielen'),
  laedt: text('druck_datei_laedt'),
  fehler: text('druck_datei_fehler'),
  personenTitel: text('detektei_druck_personen'),
  personen: (n) => text('detektei_druck_personen_anzahl', { anzahl: `${n}` }),
  rollen: (n) => text('detektei_druck_personen_rollen', { rollen: `${n}` }),
  weniger: text('detektei_druck_personen_weniger'),
  mehr: text('detektei_druck_personen_mehr'),
  detektivTitel: text('detektei_druck_detektiv'),
  detektivM: text('detektei_druck_detektiv_m'),
  hinweis: (personen, rollen) => text('druck_kammer_hinweis', { personen: `${personen}`, rollen: `${rollen}` }),
  jePerson: text('druck_je_person'),
  sendenAn: (name) => text('druck_senden_an', { name }),
  rollenheftVon: (name) => text('druck_rollenheft_von', { name }),
  zusatzheftVon: (name) => text('druck_zusatzheft_von', { name }),
  spiel: kammer('gemeinsam', 'spiel.titel'),
  alles: kammer('gemeinsam', 'titel.alles'),
  allesDatei: kammer('gemeinsam', 'datei.alles'),
  teile: fall.teile.map((nr) => ({ nr, titel: kammer(nr, 'titel'), datei: kammer(nr, 'datei') })),
  // Nur zur Gegenprobe (E16): Die Druckmappe bietet keine Erzählerakte und keinen Block „Nur Erzähler“ mehr.
  akte: text('ui.druck.akte.titel'),
  nurErzaehler: text('ui.druck.paket.dateien.ordner4'),
  laden: (datei) => text('druck_datei_laden', { datei }),
};
const woertlich = (t) => t.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
const SENDEN = new RegExp(`^${woertlich(T.sendenAn(''))}`);
/**
 * Steht [s] in den Texten der Semantik: als eigener Text oder in einem zusammengefassten Label, nie als Ende
 * einer längeren Zahl („3 Personen“ zählt nicht in „13 Personen“).
 */
const steht = (texte, s) => texte.some((t) => t === s || new RegExp(`(^|[^0-9])${woertlich(s)}`).test(t));
/** Eine Überschrift der Einrichtung (MFormkopf setzt sie in Großbuchstaben): ohne Unterschied der Schreibung. */
const stehtTitel = (texte, s) => steht(texte.map((t) => t.toUpperCase()), s.toUpperCase());

await fs.rm(ausgabe, { recursive: true, force: true });
await fs.mkdir(ausgabe, { recursive: true });

const sleep = (ms) => new Promise((ok) => setTimeout(ok, ms));
const sekunden = (ms) => Math.round(ms / 100) / 10;
const fehler = [];
const fremd = [];
const bilder = [];
const bericht = { breite_ablauf: ABLAUF_BREITE, drossel: DROSSEL, ruhig: RUHIG, ziel_einzelheft_s: ZIEL_EINZELHEFT_S, detektei: [], druckmappe: {}, dateien: [], akte: {}, konsolenfehler: 0, fremd: 0 };
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

/** Wartet, bis [ziel] drei Messungen lang an derselben Stelle liegt (Flutter ordnet nach dem Laden um). */
async function ruhigeBox(ziel, label) {
  let alt = await ziel.boundingBox();
  let stabil = 0;
  const ende = Date.now() + 10000;
  while (stabil < 3 && Date.now() < ende) {
    await sleep(150);
    const neu = await ziel.boundingBox();
    stabil = neu && alt && Math.abs(neu.x - alt.x) < 1 && Math.abs(neu.y - alt.y) < 1 ? stabil + 1 : 0;
    alt = neu ?? alt;
  }
  assert(alt, `„${label}“ hat keine Lage`);
  return alt;
}

/**
 * Der obere Knopf „PDFs zum Ausdrucken“ vor jedem Rollen: der erste dieses Namens, ganz im Bild (seitlich
 * und über dem Bildrand), mittig und vor „Neuer Abend“. Rückgabe: seine Lage.
 */
async function obenImBild(page, breite) {
  const oben = knopf(page, T.pdfs).first();
  await oben.waitFor({ timeout: 30000 });
  const box = await ruhigeBox(oben, T.pdfs);
  const neu = await knopf(page, T.neuerAbend).boundingBox();
  assert(box.y >= RAND && box.y + box.height <= HOEHE - RAND, `„${T.pdfs}“ oben liegt nicht ganz im Bild (y ${Math.round(box.y)} bis ${Math.round(box.y + box.height)} bei ${HOEHE} px)`);
  assert(box.x >= 0 && box.x + box.width <= breite, `„${T.pdfs}“ oben ragt seitlich aus dem Bild`);
  assert(Math.abs(box.x + box.width / 2 - breite / 2) <= 2, `„${T.pdfs}“ oben steht nicht mittig`);
  assert(neu && box.y + box.height <= neu.y, `„${T.pdfs}“ oben liegt nicht vor „${T.neuerAbend}“`);
  return box;
}

/**
 * Der Knopf [name] unter [oberhalb] als Ziel für insBild und tippe. Er wird bei jedem Blick neu gesucht:
 * Ein gleichnamiger Knopf weiter oben kommt und geht beim Rollen in der Semantik. Ohne kurze Frist beim
 * Messen: Nach einem Radschritt rechnet Flutter oft über eine Sekunde, und ein verfehlter Blick hieße
 * weiterrollen, bis der Knopf aus dem Bild ist.
 */
function unter(page, name, oberhalb) {
  const finde = async () => {
    try {
      if (await oberhalb.count() !== 1) return null;
      const o = await oberhalb.boundingBox();
      if (!o) return null;
      for (const k of await knopf(page, name).all()) {
        const b = await k.boundingBox();
        if (b && b.y >= o.y + o.height - 1) return { k, b };
      }
    } catch { /* Beim Umordnen verschwundene Knoten: beim nächsten Blick neu. */ }
    return null;
  };
  return {
    count: async () => ((await finde()) ? 1 : 0),
    boundingBox: async () => (await finde())?.b ?? null,
    isEnabled: async () => (await finde())?.k.isEnabled() ?? false,
  };
}

/** Zählt [ziel] auf dem hohen Bild ([HOCH]) und stellt danach das Handybild wieder her. */
async function zaehleHoch(page, breite, ziel) {
  await page.setViewportSize({ width: breite, height: HOCH });
  try {
    await warteBis(async () => await ziel.count() >= 2, `„${T.pdfs}“ zweimal im hohen Bild`);
    await sleep(500);
    return await ziel.count();
  } finally {
    await page.setViewportSize({ width: breite, height: HOEHE });
    await sleep(500);
  }
}

/**
 * Führt [pruefe] auf einem hohen Bild aus ([hoehe]); Knöpfe außerhalb des Handybilds fehlen sonst oft in der
 * Semantik. Danach gilt wieder das Handybild.
 */
async function aufHohemBild(page, breite, pruefe, hoehe = HOCH_MAPPE) {
  await page.setViewportSize({ width: breite, height: hoehe });
  try {
    await sleep(800);
    return await pruefe();
  } finally {
    await page.setViewportSize({ width: breite, height: HOEHE });
    await sleep(500);
  }
}

const rund = (b) => ({ x: Math.round(b.x), y: Math.round(b.y), b: Math.round(b.width), h: Math.round(b.height) });

async function foto(page, name, label, clip) {
  const datei = `${name}.png`;
  await page.screenshot({ path: path.join(ausgabe, datei), ...(clip ? { clip } : {}) });
  bilder.push({ datei, label });
}

/**
 * Tippt auf den Dateiknopf [name], misst die Zeit bis „Herunterladen: [fertig]“ und lädt die Datei. [fertig]
 * ist der Name auf den Knöpfen der fertigen Datei; ohne Angabe [name] (bei „Senden an …“ nennen die Knöpfe
 * danach das Heft: „Herunterladen: Rollenheft …“). Rückgabe: Sekunden, Dateiname, Bytes. Die Datei liegt
 * danach unter fotos/druck/.
 */
async function datei(page, name, kuerzel, richtung, fertig = name) {
  const breite = page.viewportSize().width;
  const ziel = knopf(page, name);
  const laden = knopf(page, T.laden(fertig));
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
  await insBild(page, laden.first(), T.laden(fertig), { richtung: 1 });
  await foto(page, `${kuerzel}-bereit-${breite}`, `${breite} px · ${T.laden(fertig)}`);
  stufe = `${breite} px · „${T.laden(fertig)}“`;
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
  assert.equal(fehlerText, 0, `Nach „${T.laden(fertig)}“ steht „${T.fehler}“`);
  const eintrag = { knopf: name, sekunden: s, datei: dateiname, bytes: bytes.length, ladehinweis: hinweis };
  console.log(`DRUCK · ${breite} px · ${dateiname}: ${bytes.length} Bytes, %PDF-`);
  bericht.dateien.push(eintrag);
  return eintrag;
}

try {
  browser = await starteBrowser();
  // (1) Detektei bei 320 und 390 px.
  for (const breite of BREITEN) {
    stufe = `${breite} px · Detektei`;
    const page = await oeffne(breite);
    const akte = knopf(page, /Spuk im Schlosskeller/);
    await akte.first().waitFor({ timeout: 30000 });
    await warteBis(async () => await akte.count() === 1, 'genau eine Mappe „Spuk im Schlosskeller“');
    // Oben, vor jedem Rollen: der kurze Weg im ersten Bildschirm.
    stufe = `${breite} px · Detektei oben`;
    const oben = await obenImBild(page, breite);
    await foto(page, `detektei-oben-${breite}`, `Detektei oben, ohne Rollen · ${breite} × ${HOEHE}`);
    console.log(`DRUCK OK · ${breite} px · Detektei: „${T.pdfs}“ oben ohne Rollen ganz im Bild (y ${Math.round(oben.y)} bis ${Math.round(oben.y + oben.height)})`);
    // Genau zwei Knöpfe dieses Namens: oben und unter der Mappe.
    stufe = `${breite} px · Detektei zählen`;
    const pdfs = knopf(page, T.pdfs);
    assert.equal(await zaehleHoch(page, breite, pdfs), 2, `„${T.pdfs}“ ist nicht genau zweimal da`);
    // Unter der Mappe, nach dem Rollen ganz im Bild.
    stufe = `${breite} px · Detektei unter der Mappe`;
    const unten = unter(page, T.pdfs, akte);
    const box = await insBild(page, unten, `${T.pdfs} unter der Mappe`);
    assert.equal(await akte.count(), 1, 'Die Mappe „Spuk im Schlosskeller“ ist nicht genau ein Knopf');
    assert(box.x >= 0 && box.x + box.width <= breite, `„${T.pdfs}“ unter der Mappe ragt seitlich aus dem Bild`);
    await foto(page, `detektei-${breite}`, `Detektei · ${breite} × ${HOEHE}`);
    bericht.detektei.push({ breite, oben: rund(oben), knopf: rund(box) });
    // Antippbar: Auch der Knopf unter der Mappe führt in die Druckmappe.
    await tippe(page, unten, `${T.pdfs} unter der Mappe`);
    await knopf(page, T.vorbereiten).waitFor({ state: 'visible', timeout: 30000 });
    console.log(`DRUCK OK · ${breite} px · Detektei: „${T.pdfs}“ genau zweimal, der zweite unter der Mappe öffnet die Druckmappe, die Mappe genau einmal`);
    await page.close();
  }

  // (2) Neu geöffnet, ohne Rollen: der obere Knopf, die Druckmappe mit den Standardwerten, Personen und
  // Detektiv wählen, dann vorbereiten.
  const breite = ABLAUF_BREITE;
  stufe = `${breite} px · Detektei oben, Tipp`;
  const page = await oeffne(breite);
  if (DROSSEL > 1) {
    const cdp = await page.context().newCDPSession(page);
    await cdp.send('Emulation.setCPUThrottlingRate', { rate: DROSSEL });
    console.log(`DRUCK · CPU-Drosselung ${DROSSEL}× für die Schritte 2 bis 4`);
  }
  const knopfOben = await obenImBild(page, breite);
  assert(await knopf(page, T.pdfs).first().isEnabled(), `„${T.pdfs}“ oben ist gesperrt`);
  await page.mouse.click(knopfOben.x + knopfOben.width / 2, knopfOben.y + knopfOben.height / 2);
  await sleep(420);
  stufe = `${breite} px · Druckmappe`;
  const vorbereiten = knopf(page, T.vorbereiten);
  await vorbereiten.waitFor({ state: 'visible', timeout: 30000 });
  await warteBis(() => vorbereiten.isEnabled(), `„${T.vorbereiten}“ offen`);
  await sleep(800);
  // Ohne Gästeliste gilt die Vorgabe aus fall.json; einen Fall wählt niemand (fester Fall, B2).
  await warteBis(async () => steht(await sichtbareTexte(page), T.personen(P.vorgabe)), `„${T.personen(P.vorgabe)}“ als Vorgabe`);
  {
    const texte = await sichtbareTexte(page);
    for (const t of [T.personenTitel, T.detektivTitel]) assert(stehtTitel(texte, t), `Druckmappe: Überschrift „${t}“ fehlt`);
    const rollen = T.rollen(P.vorgabe - P.ohneRolle.length);
    assert(steht(texte, rollen), `Druckmappe: „${rollen}“ fehlt`);
  }
  await foto(page, `druckmappe-${breite}`, `${breite} px · Druckmappe (Standardwerte)`);
  // Personen wählen: über die Zielzahl hinaus und einen Schritt zurück, so arbeiten beide Knöpfe.
  stufe = `${breite} px · Druckmappe · Personen`;
  const schritte = [];
  for (let n = P.vorgabe; n !== ZIEL_PERSONEN + Math.sign(ZIEL_PERSONEN - P.vorgabe); n += Math.sign(ZIEL_PERSONEN - P.vorgabe)) schritte.push(n);
  const hin = ZIEL_PERSONEN > P.vorgabe ? T.mehr : T.weniger;
  const rueck = ZIEL_PERSONEN > P.vorgabe ? T.weniger : T.mehr;
  const ueber = ZIEL_PERSONEN + Math.sign(ZIEL_PERSONEN - P.vorgabe);
  assert(ueber >= P.min && ueber <= P.max, `--personen ${ZIEL_PERSONEN}: Ein Schritt darüber hinaus läge außerhalb von ${P.min} bis ${P.max}`);
  for (const [n, name] of [...schritte.slice(1).map((n) => [n, hin]), [ueber, hin], [ZIEL_PERSONEN, rueck]]) {
    await tippe(page, knopf(page, name), name);
    await warteBis(async () => steht(await sichtbareTexte(page), T.personen(n)), `„${T.personen(n)}“ nach „${name}“`);
  }
  {
    const texte = await sichtbareTexte(page);
    assert(steht(texte, T.rollen(ZIEL_ROLLEN)), `Druckmappe: „${T.rollen(ZIEL_ROLLEN)}“ fehlt bei ${ZIEL_PERSONEN} Personen`);
  }
  await tippe(page, knopf(page, T.detektivM), T.detektivM);
  await foto(page, `druckmappe-gewaehlt-${breite}`, `${breite} px · ${T.personen(ZIEL_PERSONEN)}, ${T.detektivM}`);
  console.log(`DRUCK OK · ${breite} px · Druckmappe: Vorgabe ${P.vorgabe}, gewählt ${ZIEL_PERSONEN} Personen (${ZIEL_ROLLEN} Rollen), ${T.detektivM}`);

  await tippe(page, vorbereiten, T.vorbereiten);
  stufe = `${breite} px · Druckmappe vorbereitet`;
  await knopf(page, T.alles).waitFor({ state: 'visible', timeout: 30000 });
  await sleep(800);
  // Gezählt wird auf dem hohen Bild: Im Handybild fehlen Knöpfe außerhalb des Bildes in der Semantik.
  const senden = await aufHohemBild(page, breite, async () => {
    await warteBis(async () => await page.getByRole('button', { name: SENDEN }).count() === ZIEL_ROLLEN, `${ZIEL_ROLLEN} × „${T.sendenAn('…')}“`);
    const texte = await sichtbareTexte(page);
    assert(steht(texte, T.spiel), `Tafel „${T.spiel}“ fehlt`);
    assert(steht(texte, T.hinweis(ZIEL_PERSONEN, ZIEL_ROLLEN)), `Hinweis „${T.hinweis(ZIEL_PERSONEN, ZIEL_ROLLEN)}“ fehlt`);
    assert(steht(texte, T.jePerson), `„${T.jePerson}“ fehlt`);
    // „Alles in einer Datei“ und die acht Teile, je genau ein Knopf mit dem Titel aus ui/*.json.
    assert.equal(await knopf(page, T.alles).count(), 1, `„${T.alles}“ ist nicht genau ein Knopf`);
    for (const teil of T.teile) assert.equal(await knopf(page, teil.titel).count(), 1, `Teil ${teil.nr} „${teil.titel}“ ist nicht genau ein Knopf`);
    // Je besetzter Rolle „Senden an …“ mit dem Namen der Rolle (ohne Gästeliste).
    for (const p of besetzt) assert.equal(await knopf(page, T.sendenAn(p.name)).count(), 1, `„${T.sendenAn(p.name)}“ fehlt`);
    // E16: keine Erzählerakte, kein Block „Nur Erzähler“.
    assert.equal(await knopf(page, T.akte).count(), 0, `Die Druckmappe bietet „${T.akte}“ an`);
    assert(!texte.some((t) => t.includes(T.nurErzaehler)), `Abschnitt „${T.nurErzaehler}“ steht noch in der Druckmappe`);
    await foto(page, `druckmappe-tafel-${breite}`, `${breite} px · Tafel „${T.spiel}“ (hohes Bild)`);
    return await page.getByRole('button', { name: SENDEN }).count();
  });
  bericht.druckmappe = { personen: ZIEL_PERSONEN, rollen: ZIEL_ROLLEN, detektiv: 'm', teile: T.teile.map((t) => t.titel), senden };
  await foto(page, `druckmappe-bereit-${breite}`, `${breite} px · ${T.vorbereiten}`);
  console.log(`DRUCK OK · ${breite} px · Druckmappe vorbereitet: ${T.teile.length} Teile, ${senden} × „${T.sendenAn('…')}“, keine Erzählerakte`);

  // (3) Alles in einer Datei.
  const allesDatei = await datei(page, T.alles, 'alles', -1);
  assert.equal(allesDatei.datei, T.allesDatei, `„${T.alles}“ heißt nicht ${T.allesDatei}`);
  // (4) Ein Einzelheft: das Rollenheft auf Platz 1, dazu das Zusatzheft der allein spielenden Zusatzrolle.
  const heftName = (p) => kammer(p.art === 'zusatz' ? '12' : '10', 'dateiEinzeln', { figur: dateiWort(p.name) });
  const heftKnopf = (p) => (p.art === 'zusatz' ? T.zusatzheftVon(p.name) : T.rollenheftVon(p.name));
  const einzelDatei = await datei(page, T.sendenAn(erster.name), `einzeln-${erster.id}`, 1, heftKnopf(erster));
  assert.equal(einzelDatei.datei, heftName(erster), `Das Heft von ${erster.name} heißt nicht ${heftName(erster)}`);
  let zusatzDatei = null;
  if (zusatz) {
    zusatzDatei = await datei(page, T.sendenAn(zusatz.name), `einzeln-${zusatz.id}`, 1, heftKnopf(zusatz));
    assert.equal(zusatzDatei.datei, heftName(zusatz), `Das Heft von ${zusatz.name} heißt nicht ${heftName(zusatz)}`);
  }
  assert(allesDatei.bytes > einzelDatei.bytes, `${T.allesDatei} (${allesDatei.bytes} Bytes) ist nicht größer als ${einzelDatei.datei} (${einzelDatei.bytes} Bytes)`);
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
  bericht.ziel_erreicht = einzelDatei.sekunden < ZIEL_EINZELHEFT_S;
  if (!bericht.ziel_erreicht) {
    const meldung = `Das Heft ${einzelDatei.datei} braucht ${einzelDatei.sekunden} s (Ziel unter ${ZIEL_EINZELHEFT_S} s, Drosselung ${DROSSEL}×${RUHIG ? ', ruhig' : ''})`;
    if (ZEITZIEL_STRENG) throw new Error(meldung);
    console.warn(`DRUCK · ZEITZIEL VERFEHLT · ${meldung}`);
  }

  // Kontaktbogen aller Fotos.
  const bogen = await browser.newPage({ locale: 'de-DE', viewport: { width: 1280, height: 960 }, deviceScaleFactor: 1 });
  const figuren = await Promise.all(bilder.map(async ({ datei: d, label }) => {
    const bild = (await fs.readFile(path.join(ausgabe, d))).toString('base64');
    return `<figure><figcaption>${label}</figcaption><img src="data:image/png;base64,${bild}"></figure>`;
  }));
  await bogen.setContent(`<html><body style="margin:0;background:#18151f;color:#f1ede4;font:15px sans-serif"><h2 style="margin:24px">Mordakte · PDFs zum Ausdrucken (Kammerspiel)</h2><main style="display:flex;flex-wrap:wrap;align-items:flex-start;gap:20px;padding:0 20px 20px">${figuren.join('')}</main><style>figure{margin:0;width:300px}figcaption{margin-bottom:8px;min-height:2.6em}img{display:block;max-width:300px}</style></body></html>`);
  await bogen.locator('img').evaluateAll((imgs) => Promise.all(imgs.map((img) => img.decode())));
  await bogen.screenshot({ path: path.join(ausgabe, 'kontaktbogen.png'), fullPage: true });
  await bogen.close();
  console.log(`DRUCK GRÜN · Detektei 2/2 · Drosselung ${DROSSEL}×${RUHIG ? ' · ruhig' : ''} · ${ZIEL_PERSONEN} Personen · Alles ${allesDatei.sekunden} s, ${allesDatei.bytes} Bytes · ${einzelDatei.datei} ${einzelDatei.sekunden} s, ${einzelDatei.bytes} Bytes${zusatzDatei ? ` · ${zusatzDatei.datei} ${zusatzDatei.sekunden} s` : ''} · keine Erzählerakte · 0 Konsolenfehler · 0 fremde Netzaufrufe`);
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
