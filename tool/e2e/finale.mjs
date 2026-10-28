// Browserprobe des Finales (Schlosskeller): ein Abend mit Einstimmung und „Dein Moment“ über die
// Entwicklerroute (`?party=schlosskeller&einstimmung=1&einfluss=1`, PartySkript) bei 390 × 844 px.
// Das Skript geht Vorgeschichte und Vorstellung Schritt für Schritt durch, zieht je Runde für jede
// Rolle verdeckt den Zug eines Bots, lässt zu Beginn jeder Ermittlung die Folgen lesen, ermittelt
// ohne Gruppenwahl, nutzt vor der Anklage eine offene Nachfrage und läuft bis zum Schlussbild.
// Fotografiert werden Vorgeschichte, Vorstellung, die Gespräche mit der Moment-Liste, der verdeckte
// Moment, die Folgen, jede endgültige Wahl (Abzeichen des Tischwerts: Endung `_abzeichen`), die
// Zwischenresümees mit den Leisten, die Nachfrage, die Auflösung mit Sternen und Auszeichnungen und
// das Schlussbild. Ist ein Bildschirm länger als das Handy, scrollt die Probe ihn mit dem Mausrad
// weiter und fotografiert jede neue Ansicht (`_2`, `_3`, …), nie die Karte darunter. Reicht die
// Fotopause nicht bis zum Ende des Bildschirms, springt sie zum Schluss ans Ende (`_<n>_ende`).
// Geprüft wird: `PARTY fertig` mit Pfad und Personenzahl, die Phasenfolge ohne Gruppenwahl, die
// Fotostellen je Abschnitt und in ihrer Folge (Moment vor den Folgen, Folgen vor der Ermittlung),
// mindestens ein Abzeichen, zu jeder fotografierten Stelle ein Foto, die Auflösung bis zu ihrem Ende
// (Sterne, Tipps, Endwert) im Bild, keine Konsolenfehler, kein `PARTY fehler`, keine Anfragen außer
// 127.0.0.1/localhost.
// Aufruf in tool/e2e: node finale.mjs [--pfad ahmet] [--n 5]
// Ausgabe: fotos/finale/ (Fotos, kontaktbogen.png, bericht.json).
// Rückgabewert 0 nur, wenn alle Prüfungen bestehen; 2 bei Aufruf- oder Bauproblemen.

import fs from 'node:fs';
import path from 'node:path';
import zlib from 'node:zlib';
import { starteBrowser } from './browser.mjs';
import { fotoGruppe, kollabiere, PHASEN } from './e2e.mjs';
import { PFADE } from './laeufe.mjs';
import { starteServer } from './server.mjs';

const hier = import.meta.dirname;
const repo = path.resolve(hier, '../..');
const build = path.join(repo, 'build/web');
const ausgabe = path.join(hier, 'fotos', 'finale');

/** Handy hochkant, wie man den Abend am Tisch spielt. */
const ANSICHT = { width: 390, height: 844 };

/**
 * Takt und Zeitraffer wie die Fotoläufe von e2e.mjs, nur etwas schneller. An jeder fotografierten Stelle
 * wartet das Skript 18 s: Zeit für das Foto und das Scrollen langer Bildschirme. Nach jedem Mausradschritt
 * braucht der Renderer rund 1,5 s für die neue Ansicht, und die Auflösung mit „Dein Moment“ ist gut zehn
 * Ansichten lang. Gleiches Salz wie der Widget-Test test/party_widgets/einfluss_skript_test.dart: derselbe
 * Abend (mit Abzeichen und Nachfrage).
 */
const PARAMETER = { takt: 300, zeitraffer: 120, fotopause: 18_000, zeitlimitMin: 20, salz: 'einfluss-skript' };

/** Anfänge der Fotostellen, die fotografiert werden (dort wartet das Skript die Fotopause). */
const FOTOS = ['vorgeschichte', 'vorstellung', 'gespraeche_r1', 'moment_r1', 'folgen_r1', 'endgueltig_', 'resuemee_', 'nachfrage', 'aufloesung', 'ende'];

/** Hier scrollt die Probe nicht: Über der Karte würde das Mausrad zoomen. */
const NICHT_SCROLLEN = ['endgueltig_'];

/** Diese Bildschirme müssen bis zu ihrem Ende im Bild sein (Sterne, Tipps und Endwert stehen ganz unten). */
const BIS_ZUM_ENDE = ['aufloesung_r3'];

/** Ein Mausradschritt: 85 % der Höhe; unter der Knopfleiste überlappen sich die Ansichten um eine Zeile oder zwei. */
const SCHRITT = Math.round(ANSICHT.height * 0.85);

/** Höchstens so viele Ansichten je Bildschirm, der Sprung ans Ende nicht mitgezählt. */
const TEILE = 16;

/**
 * Breite des rechten Rands, den der Vergleich zweier Ansichten auslässt: Dort blendet der Rollbalken nach dem
 * Scrollen langsam aus; mit ihm sah das Ende eines Bildschirms wie eine neue Ansicht aus (doppelte Fotos).
 */
const ROLLBALKEN = 16;

/** Mit „Dein Moment“ entfällt die Gruppenwahl (Finale §3). */
const PHASEN_FINALE = PHASEN.filter((p) => p !== 'gruppenwahl');

/** Abschnitt einer Fotostelle: die Stellen des Finales, sonst wie in e2e.mjs. */
function gruppe(name) {
  if (name === 'vorgeschichte' || name === 'vorstellung') return 'intro';
  if (/^moment_r\d+$/.test(name)) return 'gespraeche';
  if (/^folgen_r\d+$/.test(name)) return 'entscheidungen';
  if (name === 'nachfrage') return 'anklage';
  return fotoGruppe(name);
}

const sleep = (ms) => new Promise((ok) => setTimeout(ok, ms));
const kurz = (text) => String(text).replace(/\s+/g, ' ').trim().slice(0, 300);

/** Pixel eines Bildschirmfotos (PNG mit 8 Bit je Kanal, RGB oder RGBA, ohne Zeilensprung). */
function pixel(png) {
  const idat = [];
  let breite = 0;
  let hoehe = 0;
  let bpp = 0;
  for (let pos = 8; pos < png.length;) {
    const laenge = png.readUInt32BE(pos);
    const typ = png.toString('ascii', pos + 4, pos + 8);
    const daten = png.subarray(pos + 8, pos + 8 + laenge);
    if (typ === 'IHDR') {
      breite = daten.readUInt32BE(0);
      hoehe = daten.readUInt32BE(4);
      if (daten[8] !== 8 || ![2, 6].includes(daten[9]) || daten[12] !== 0) throw new Error(`PNG-Format ${daten[8]}/${daten[9]}/${daten[12]} nicht unterstützt`);
      bpp = daten[9] === 6 ? 4 : 3;
    } else if (typ === 'IDAT') idat.push(daten);
    else if (typ === 'IEND') break;
    pos += 12 + laenge;
  }
  // Zeilenfilter rückgängig machen (PNG: None, Sub, Up, Average, Paeth).
  const roh = zlib.inflateSync(Buffer.concat(idat));
  const zeile = breite * bpp;
  const aus = Buffer.alloc(zeile * hoehe);
  for (let y = 0; y < hoehe; y++) {
    const filter = roh[y * (zeile + 1)];
    const ein = y * (zeile + 1) + 1;
    const o = y * zeile;
    for (let x = 0; x < zeile; x++) {
      const a = x >= bpp ? aus[o + x - bpp] : 0;
      const b = y > 0 ? aus[o - zeile + x] : 0;
      const c = x >= bpp && y > 0 ? aus[o - zeile + x - bpp] : 0;
      let v = roh[ein + x];
      if (filter === 1) v += a;
      else if (filter === 2) v += b;
      else if (filter === 3) v += (a + b) >> 1;
      else if (filter === 4) {
        const p = a + b - c;
        const pa = Math.abs(p - a);
        const pb = Math.abs(p - b);
        const pc = Math.abs(p - c);
        v += pa <= pb && pa <= pc ? a : pb <= pc ? b : c;
      }
      aus[o + x] = v & 0xff;
    }
  }
  return { breite, hoehe, bpp, daten: aus };
}

/** Zeigen zwei Bildschirmfotos dieselbe Ansicht? Verglichen ohne den Rollbalken am rechten Rand. */
function gleicheAnsicht(a, b) {
  const p = pixel(a);
  const q = pixel(b);
  if (p.breite !== q.breite || p.hoehe !== q.hoehe || p.bpp !== q.bpp) return false;
  const zeile = p.breite * p.bpp;
  const bis = Math.max(0, p.breite - ROLLBALKEN) * p.bpp;
  for (let y = 0; y < p.hoehe; y++) {
    if (p.daten.compare(q.daten, y * zeile, y * zeile + bis, y * zeile, y * zeile + bis) !== 0) return false;
  }
  return true;
}

function erlaubt(url) {
  try {
    const u = new URL(url);
    return ['127.0.0.1', 'localhost'].includes(u.hostname) || ['data:', 'blob:', 'about:'].includes(u.protocol);
  } catch {
    return false;
  }
}

function parseArgs(argv) {
  const o = { pfad: 'ahmet', n: 5 };
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i];
    if (a === '--pfad') o.pfad = argv[++i];
    else if (a === '--n') o.n = Number(argv[++i]);
    else throw new Error(`Unbekannte Option: ${a}`);
  }
  if (!PFADE.includes(o.pfad)) throw new Error(`--pfad muss einer von ${PFADE.join(', ')} sein`);
  if (!Number.isInteger(o.n) || o.n < 4 || o.n > 20) throw new Error('--n muss zwischen 4 und 20 liegen');
  return o;
}

function adresse(o, port) {
  const p = PARAMETER;
  return `http://127.0.0.1:${port}/?party=schlosskeller&pfad=${o.pfad}&n=${o.n}&skript=best,a,richtig&einstimmung=1&einfluss=1` +
    `&takt=${p.takt}&zeitraffer=${p.zeitraffer}&fotos=1&fotopause=${p.fotopause}&fotonur=${FOTOS.join(',')}` +
    `&salz=${encodeURIComponent(p.salz)}`;
}

/** Prüfungen nach dem Lauf; liefert die Fehlermeldungen (leer heißt bestanden). */
function pruefe(o, b) {
  const f = [];
  if (b.abbruch) f.push(b.abbruch);
  for (const x of b.parteiFehler) f.push(`PARTY fehler: ${x}`);
  if (!b.fertig) f.push('kein „PARTY fertig“ (Ende nicht erreicht)');
  else {
    if (b.fertig.pfad !== o.pfad) f.push(`pfad: erwartet ${o.pfad}, ist ${b.fertig.pfad}`);
    if (Number(b.fertig.rollen) !== o.n) f.push(`rollen: erwartet ${o.n}, ist ${b.fertig.rollen}`);
  }
  const phasen = kollabiere(b.phasen).filter((p) => p !== 'titel');
  if (phasen.join(' > ') !== PHASEN_FINALE.join(' > ')) f.push(`Phasenfolge weicht ab: ${phasen.join(' > ')}`);
  const gruppen = kollabiere(b.fotostellen.map(gruppe));
  if (gruppen.join(' > ') !== ['titel', ...PHASEN_FINALE].join(' > ')) f.push(`Fotostellen weichen ab: ${gruppen.join(' > ')}`);
  const s = b.fotostellen;
  const einmal = (name) => {
    const n = s.filter((x) => x === name).length;
    if (n !== 1) f.push(`Fotostelle ${name} ${n}-mal statt einmal`);
    return s.indexOf(name);
  };
  const vor = (a, c) => {
    const i = einmal(a);
    const j = einmal(c);
    if (i >= 0 && j >= 0 && i > j) f.push(`${a} nicht vor ${c}`);
  };
  vor('dossier_taeter', 'vorgeschichte');
  vor('vorgeschichte', 'vorstellung');
  vor('vorstellung', 'intro');
  for (const r of [1, 2, 3]) {
    vor(`gespraeche_r${r}`, `moment_r${r}`);
    vor(`moment_r${r}`, `folgen_r${r}`);
    vor(`folgen_r${r}`, `entscheidungen_fertig_r${r}`);
    vor(`entscheidungen_fertig_r${r}`, `resuemee_r${r}`);
  }
  const auftakt = s.findIndex((x) => x.startsWith('aktion_auftakt'));
  if (auftakt >= 0 && s.indexOf('folgen_r1') > auftakt) f.push('Die Folgen von Runde 1 kommen erst nach dem Auftakt');
  if (s.some((x) => /^(wahl_verdeckt|wahl_taeter|gruppenwahl)_/.test(x))) f.push('Gruppenwahl trotz „Dein Moment“');
  if (!s.some((x) => /^endgueltig_.+_abzeichen$/.test(x))) f.push('Keine endgültige Wahl mit Abzeichen');
  if (s.includes('nachfrage')) vor('nachfrage', 'anklage');
  vor('aufloesung_r3', 'ende');
  for (const name of s.filter((x) => FOTOS.some((p) => x.startsWith(p)))) {
    if (!b.fotos.some((x) => x.name === name)) f.push(`kein Foto von ${name}`);
  }
  for (const name of BIS_ZUM_ENDE.filter((x) => s.includes(x))) {
    if (!b.bisZumEnde.includes(name)) f.push(`${name} nicht bis zum Ende des Bildschirms fotografiert`);
  }
  for (const x of b.konsole) f.push(`Konsole: ${x}`);
  for (const x of b.technik) f.push(`Technik: ${x}`);
  const fremd = [...new Set(b.fremd)];
  if (fremd.length) f.push(`fremde Anfragen (${fremd.length}): ${fremd.slice(0, 3).join(', ')}`);
  return [...new Set(f)];
}

/** Kontaktbogen aller Fotos, vier Handys je Zeile, beschriftet mit der Fotostelle. */
async function kontaktbogen(browser, fotos) {
  const seite = await browser.newPage({ viewport: { width: 1660, height: 960 }, locale: 'de-DE' });
  try {
    const bilder = fotos.map(({ datei, name, teil }) => {
      const data = fs.readFileSync(path.join(ausgabe, datei)).toString('base64');
      return `<figure><figcaption>${name}${teil > 1 ? ` (${teil})` : ''}</figcaption><img src="data:image/png;base64,${data}"></figure>`;
    });
    await seite.setContent(`<html><body style="margin:0;background:#18151f;color:#f1ede4;font:15px sans-serif"><h2 style="margin:24px">Mordakte · Finale: Einstimmung und „Dein Moment“ bei 390 px</h2><main style="display:grid;grid-template-columns:repeat(4,390px);gap:18px;padding:0 12px 20px">${bilder.join('')}</main><style>figure{margin:0}figcaption{margin-bottom:8px}img{display:block;width:390px}</style></body></html>`);
    await seite.locator('img').evaluateAll((imgs) => Promise.all(imgs.map((i) => i.decode())));
    await seite.screenshot({ path: path.join(ausgabe, 'kontaktbogen.png'), fullPage: true });
  } finally {
    await seite.close();
  }
}

async function main() {
  const o = parseArgs(process.argv.slice(2));
  if (!fs.existsSync(path.join(build, 'index.html'))) {
    throw new Error('Web-Build fehlt (build/web). Bauen mit: flutter build web --release --no-web-resources-cdn -o build/web');
  }
  fs.rmSync(ausgabe, { recursive: true, force: true });
  fs.mkdirSync(ausgabe, { recursive: true });
  const beginn = Date.now();
  const b = { fertig: null, phasen: [], fotostellen: [], fotos: [], bisZumEnde: [], konsole: [], parteiFehler: [], technik: [], fremd: [], abbruch: null };
  const server = await starteServer(build);
  const port = server.address().port;
  let browser = null;
  try {
    browser = await starteBrowser();
    console.log(`FINALE: ${o.pfad} n=${o.n}, Einstimmung und „Dein Moment“, ${ANSICHT.width} px; Server 127.0.0.1:${port}`);
    const kontext = await browser.newContext({ locale: 'de-DE', viewport: ANSICHT, deviceScaleFactor: 1 });
    const seite = await kontext.newPage();
    let beenden;
    const beendet = new Promise((ok) => { beenden = ok; });
    const zeitlimit = setTimeout(() => {
      b.abbruch = `Zeitlimit von ${PARAMETER.zeitlimitMin} min überschritten`;
      beenden();
    }, PARAMETER.zeitlimitMin * 60_000);
    // Jede PARTY-Zeile zählt: Kam eine neue, zeigt der Bildschirm nicht mehr die Fotostelle.
    let zeilen = 0;
    let kette = Promise.resolve();

    /**
     * Foto der Stelle; lange Bildschirme mit dem Mausrad weiter, solange sich das Bild ändert. Nicht jeder
     * Bildschirmwechsel meldet eine Zeile (der verdeckte Moment schließt still): Gescrollt wird deshalb nur
     * innerhalb der Fotopause, und ein Foto zählt nur, wenn es vor ihrem Ende fertig ist. Reicht die Zeit
     * nicht bis zum Ende des Bildschirms, springt das Mausrad zum Schluss ganz nach unten (`_schluss`).
     */
    const fotografiere = async (nr, name, stand, gemeldet) => {
      const schluss = gemeldet + PARAMETER.fotopause;
      // Steht die Fotostelle noch mindestens [ms] lang?
      const noch = (ms) => zeilen === stand && Date.now() < schluss - ms;
      await sleep(250);
      const basis = `${String(nr).padStart(3, '0')}_${name}`;
      let bild = await seite.screenshot({ path: path.join(ausgabe, `${basis}.png`), timeout: 20_000 });
      b.fotos.push({ datei: `${basis}.png`, name, teil: 1 });
      if (NICHT_SCROLLEN.some((p) => name.startsWith(p))) return;
      // Das Mausrad dreht am linken Rand: Dort liegt kein Knopf, über dem ein Tooltip ins Foto käme (die Karten
      // beginnen bei 20 px, die Folgen-Tafel scrollt ab 16 px).
      await seite.mouse.move(18, ANSICHT.height / 2);
      /** Mausrad um [delta]; eine neue Ansicht wird als [datei] gesichert. Ergebnis: `neu`, `ende` oder `vorbei`. */
      const ansicht = async (delta, datei, teil) => {
        await seite.mouse.wheel(0, delta);
        // Das Foto wartet ohnehin auf das nächste Bild; die Pause lässt Flutter das Mausrad zuerst verarbeiten.
        await sleep(150);
        const neu = await seite.screenshot({ timeout: 20_000 });
        // Inzwischen ging das Skript weiter (oder geht gleich): Das Foto zeigt vielleicht schon den nächsten Bildschirm.
        if (!noch(200)) return 'vorbei';
        if (gleicheAnsicht(neu, bild)) return 'ende';
        fs.writeFileSync(path.join(ausgabe, datei), neu);
        b.fotos.push({ datei, name, teil });
        bild = neu;
        return 'neu';
      };
      let teil = 2;
      // Weiter, solange noch Zeit für einen Schritt und den Sprung ans Ende bleibt (je rund 1,5 s).
      for (; teil <= TEILE && noch(3500); teil++) {
        const ergebnis = await ansicht(SCHRITT, `${basis}_${teil}.png`, teil);
        if (ergebnis === 'ende') b.bisZumEnde.push(name);
        if (ergebnis !== 'neu') return;
      }
      // Die Fotopause reicht nicht bis zum Ende des Bildschirms: ein Sprung ganz nach unten.
      if (!noch(1800)) return;
      if ((await ansicht(1_000_000, `${basis}_schluss.png`, teil)) !== 'vorbei') b.bisZumEnde.push(name);
    };

    seite.on('request', (r) => { if (!erlaubt(r.url())) b.fremd.push(r.url()); });
    seite.on('pageerror', (e) => { b.konsole.push(`pageerror: ${kurz(e.message)}`); });
    seite.on('crash', () => {
      b.abbruch = 'Seite abgestürzt';
      beenden();
    });
    seite.on('console', (m) => {
      const text = m.text();
      if (m.type() === 'error') b.konsole.push(kurz(text));
      if (!text.startsWith('PARTY ')) return;
      zeilen++;
      const zeile = text.split('\n')[0];
      let t;
      if ((t = /^PARTY phase=(\w+)/.exec(zeile))) {
        b.phasen.push(t[1]);
      } else if ((t = /^PARTY foto=(\S+)/.exec(zeile))) {
        const name = t[1];
        b.fotostellen.push(name);
        if (FOTOS.some((p) => name.startsWith(p))) {
          const nr = b.fotostellen.length;
          const stand = zeilen;
          const gemeldet = Date.now();
          kette = kette.then(() => fotografiere(nr, name, stand, gemeldet)).catch((e) => { b.technik.push(`Foto ${name}: ${kurz(e.message)}`); });
        }
      } else if ((t = /^PARTY fertig pfad=(\S+) ende=(\S+) punkte=(\S+) rollen=(\S+)/.exec(zeile))) {
        b.fertig = { pfad: t[1], ende: t[2], punkte: t[3], rollen: t[4], zeile };
        beenden();
      } else if (zeile.startsWith('PARTY fehler')) {
        b.parteiFehler.push(kurz(text));
        beenden();
      }
    });
    try {
      await seite.goto(adresse(o, port), { waitUntil: 'load' });
      await beendet;
    } catch (e) {
      b.abbruch ??= `Lauffehler: ${kurz(e.message)}`;
    } finally {
      clearTimeout(zeitlimit);
      await Promise.race([kette, sleep(30_000)]);
      await kontext.close().catch(() => {});
    }
    if (b.fotos.length) await kontaktbogen(browser, b.fotos).catch((e) => b.technik.push(`Kontaktbogen: ${kurz(e.message)}`));
  } finally {
    await browser?.close();
    server.close();
  }

  const fehler = pruefe(o, b);
  const dauer = Math.round((Date.now() - beginn) / 100) / 10;
  const abzeichen = b.fotostellen.filter((x) => x.endsWith('_abzeichen'));
  const bericht = {
    erzeugt: new Date().toISOString(), ok: fehler.length === 0, fehler, pfad: o.pfad, n: o.n, parameter: PARAMETER, dauer_s: dauer,
    fertig: b.fertig?.zeile ?? null, ende: b.fertig?.ende ?? null, punkte: b.fertig?.punkte ?? null,
    nachfrage: b.fotostellen.includes('nachfrage'), abzeichen, phasen: kollabiere(b.phasen), fotostellen: b.fotostellen,
    fotos: b.fotos.map((x) => x.datei), bis_zum_ende: b.bisZumEnde, fremd: [...new Set(b.fremd)], konsole: b.konsole,
  };
  fs.writeFileSync(path.join(ausgabe, 'bericht.json'), `${JSON.stringify(bericht, null, 2)}\n`);
  if (fehler.length) {
    console.error(`FINALE ROT · ${dauer} s · ${fehler.slice(0, 8).join(' | ')}${fehler.length > 8 ? ` (+${fehler.length - 8})` : ''}`);
    process.exitCode = 1;
    return;
  }
  console.log(`FINALE GRÜN · ${o.pfad} n=${o.n} · ${b.fertig.ende}, ${b.fertig.punkte} Punkte · Einstimmung · 3 Momente mit Folgen · ` +
    `${abzeichen.length} Abzeichen · Nachfrage ${bericht.nachfrage ? 'genutzt' : 'keine offen'} · ${b.fotos.length} Fotos unter ` +
    `${path.relative(repo, ausgabe)} · ${dauer} s · 0 Konsolenfehler · 0 fremde Netzaufrufe`);
}

main().catch((e) => {
  console.error(e.message);
  process.exitCode = 2;
});
