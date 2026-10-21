// E2E-Läufe des Partymodus gegen die gebaute Web-Fassung (F4-BAUMEISTER-07).
// Aufruf in tool/e2e: node e2e.mjs [--nur feld=wert,...] [--parallel 1|2] [--negativtest]
//   --nur          nur passende Läufe; Felder: pfad, ende, n, skript, fotos (0|1), semantik (0|1)
//   --parallel     gleichzeitige Seiten, höchstens 2 (Vorgabe 2)
//   --negativtest  prüft eine Kopie des ersten gewählten Laufs, deren Ende-Erwartung
//                  vertauscht ist; die Kopie muss als Fehler gemeldet werden
// Ausgabe: tool/e2e/fotos/e2e/ (Fotos je Lauf, bericht.json, bericht.md).
// Rückgabewert 0 nur, wenn alle Läufe bestanden (bei --negativtest: der Fehler ist erkannt).

import { starteBrowser } from './browser.mjs';
import fs from 'node:fs';
import path from 'node:path';
import { starteServer } from './server.mjs';
import { alleLaeufe, PFADE } from './laeufe.mjs';

const hier = import.meta.dirname;
const repo = path.resolve(hier, '../..');
const build = path.join(repo, 'build/web');
const texteOrdner = path.join(repo, 'content/party/schlosskeller/texte');
const ausgabe = path.join(hier, 'fotos', 'e2e');

/** Takt, Zeitraffer und Zeitlimit je Lauftyp. */
const MIT_FOTOS = { takt: 400, zeitraffer: 60, zeitlimitMin: 8 };
const OHNE_FOTOS = { takt: 40, zeitraffer: 240, zeitlimitMin: 3 };
/**
 * Semantik-Läufe (fotos=0) mit größerem Takt: Bei takt=40 zeichnet der Browser den neuen
 * Bildschirm noch nicht, wenn die Fotostelle gemeldet wird (gemessen: die Fotostelle
 * gespraeche_r2 zeigte noch den Bildschirm der Vorrunde). Bei 400 ms ist er gezeichnet.
 */
const SEMANTIK = { takt: 400, zeitraffer: 240, zeitlimitMin: 3 };

/** Parameter eines Laufs. */
function parameter(lauf) {
  if (lauf.semantik) return SEMANTIK;
  return lauf.fotos ? MIT_FOTOS : OHNE_FOTOS;
}

const RUNDE = ['gespraeche', 'entscheidungen', 'gruppenwahl', 'bonus', 'resuemee'];
/** Phasen ab der Einrichtung in Reihenfolge. Der Titel meldet keine Phase, nur eine Fotostelle. */
const PHASEN = ['einrichtung', 'rollen', 'intro', ...RUNDE, ...RUNDE, ...RUNDE, 'anklage', 'finale', 'aufloesung', 'ende'];

/** Rundenuhr im Bild je Runde (fall.json, Feld uhrzeit). */
const UHRZEIT = { 1: '00:30', 2: '01:15', 3: '02:00' };

/** Vertauschte Ende-Erwartung für den Negativtest. */
const TAUSCH = {
  ende_meister: 'ende_teilerfolg',
  ende_teilerfolg: 'ende_meister',
  ende_justizirrtum: 'ende_eskalation',
  ende_eskalation: 'ende_justizirrtum',
};

const FILTER_FELDER = ['pfad', 'ende', 'n', 'skript', 'fotos', 'semantik'];

/** Fotostellen, die fest einem Abschnitt gehören (Namen wie in skript.dart). */
const FESTE_FOTOS = {
  titel: 'titel',
  einrichtung: 'einrichtung',
  rollen: 'rollen',
  dossier: 'rollen',
  dossier_taeter: 'rollen',
  intro: 'intro',
  // Langer Abend (M7b): Vorspiel vor der Diashow, Morgen vor dem Schlussbild.
  vorspiel: 'intro',
  morgen: 'ende',
  anklage: 'anklage',
  finale: 'finale',
  ende: 'ende',
};

const sleep = (ms) => new Promise((ok) => setTimeout(ok, ms));
const norm = (text) => String(text).normalize('NFC').replace(/\s+/g, ' ').trim();
const kurz = (text) => norm(text).slice(0, 300);
const lesJson = (datei) => JSON.parse(fs.readFileSync(datei, 'utf8'));
const kollabiere = (liste) => liste.filter((x, i) => i === 0 || x !== liste[i - 1]);
const gleich = (a, b) => a.length === b.length && a.every((x, i) => x === b[i]);
const zahl = (x) => (x == null ? null : Number.isFinite(Number(x)) ? Number(x) : x);

/** Abschnitt, zu dem eine Fotostelle gehört. */
function fotoGruppe(name) {
  if (Object.hasOwn(FESTE_FOTOS, name)) return FESTE_FOTOS[name];
  if (/^gespraeche_r\d+$/.test(name)) return 'gespraeche';
  if (/^(fund|endgueltig|ziel|aktion|wurf|pech|auftakt)_/.test(name) || /^entscheidungen_fertig_r\d+$/.test(name)) return 'entscheidungen';
  if (/^(wahl_verdeckt|wahl_taeter|gruppenwahl)_r\d+$/.test(name)) return 'gruppenwahl';
  if (/^bonus_r\d+$/.test(name)) return 'bonus';
  if (/^resuemee_r\d+$/.test(name)) return 'resuemee';
  if (/^rueckblende_\d+$/.test(name)) return 'finale';
  if (/^aufloesung(_r\d+)?$/.test(name)) return 'aufloesung';
  return `unbekannt:${name}`;
}

/** Nur 127.0.0.1, localhost sowie data:, blob: und about: sind erlaubt. */
function erlaubt(url) {
  try {
    const u = new URL(url);
    return ['127.0.0.1', 'localhost'].includes(u.hostname) || ['data:', 'blob:', 'about:'].includes(u.protocol);
  } catch {
    return false;
  }
}

function adresse(lauf, port) {
  const p = parameter(lauf);
  const semantik = lauf.semantik ? '&semantik=1' : '';
  return `http://127.0.0.1:${port}/?party=schlosskeller&pfad=${lauf.pfad}&n=${lauf.n}&skript=${lauf.skript}` +
    `&takt=${p.takt}&zeitraffer=${p.zeitraffer}&fotos=${lauf.fotos ? 1 : 0}${lauf.fotos ? '&fotopause=2000' : ''}${semantik}`;
}

/** Erzählertexte der Runden, die Täterfassungen (je Pfad, die ersten 40 Zeichen des Feldes tarnung)
 * und die heimliche Wahl B der Täterrolle je Runde (die ersten 40 Zeichen von `sabotage`). */
function ladeDaten() {
  const runden = lesJson(path.join(texteOrdner, 'erzaehler-runden.json')).eintraege;
  const runde = {};
  for (const r of [1, 2, 3]) {
    const e = runden.find((x) => x.id === `runde.${r}.start`);
    if (!e) throw new Error(`Erzählertext runde.${r}.start fehlt in erzaehler-runden.json`);
    runde[r] = norm(e.text);
  }
  const tarnung = {};
  for (const p of PFADE) {
    const e = lesJson(path.join(texteOrdner, `taeter-${p}.json`)).eintraege.find((x) => x.rolle === p);
    if (!e) throw new Error(`Täterfassung für ${p} fehlt in taeter-${p}.json`);
    tarnung[p] = norm(e.tarnung).slice(0, 40);
  }
  const wahlen = lesJson(path.join(texteOrdner, 'wahlen-kern.json')).eintraege;
  const sabotage = {};
  for (const p of PFADE) {
    for (const r of [1, 2, 3]) {
      const w = wahlen.find((x) => x.id === `gw_${p}_${r}`);
      if (!w || !w.sabotage) throw new Error(`Sabotage-Text gw_${p}_${r} fehlt in wahlen-kern.json`);
      sabotage[`${p}_${r}`] = norm(w.sabotage).slice(0, 40);
    }
  }
  return { runde, tarnung, sabotage };
}

/** Läuft im Browser vor dem Spiel: merkt sich bei jeder Fotostelle den Bildschirmtext (nur semantik=1). */
function textHaken(aktiv) {
  if (!aktiv) return;
  window.__e2eTexte = [];
  const lies = () => {
    const teile = [];
    const host = document.querySelector('flt-semantics-host');
    if (host) teile.push(host.innerText);
    for (const el of document.querySelectorAll('[aria-label]')) teile.push(el.getAttribute('aria-label'));
    return teile.join('\n');
  };
  const original = console.log;
  console.log = function (...args) {
    try {
      if (typeof args[0] === 'string' && args[0].startsWith('PARTY foto=')) {
        window.__e2eTexte.push({ name: args[0].slice('PARTY foto='.length).split('\n')[0].trim(), text: lies() });
      }
    } catch {
      // Die Messung darf das Spiel nicht stören.
    }
    return original.apply(this, args);
  };
}

/** Semantik-Prüfung an den Fotostellen (nur semantik=1). */
function pruefeSemantik(lauf, texte, daten) {
  const f = [];
  for (const r of [1, 2, 3]) {
    const name = `gespraeche_r${r}`;
    const e = texte.find((x) => x.name === name);
    if (!e) {
      f.push(`Semantik: kein Bildschirmtext an ${name}`);
      continue;
    }
    const t = norm(e.text);
    if (!t.includes(UHRZEIT[r])) f.push(`Semantik: Uhrzeit ${UHRZEIT[r]} fehlt an ${name}`);
    if (!t.includes(daten.runde[r])) f.push(`Semantik: Erzählertext der Runde ${r} fehlt an ${name}`);
  }
  // Die Täteransicht (E-039, E-041): Das Dossier zeigt die Tarnung, die heimliche Wahl
  // zeigt in jeder Runde den Sabotage-Text. Ein leerer Text gilt hier als Fehler.
  const taeter = texte.find((x) => x.name === 'dossier_taeter');
  if (!taeter) f.push('Semantik: keine Fotostelle „dossier_taeter“');
  else if (!norm(taeter.text).includes(daten.tarnung[lauf.pfad])) f.push('Semantik: Täterfassung fehlt an dossier_taeter');
  for (const r of [1, 2, 3]) {
    const w = texte.find((x) => x.name === `wahl_taeter_r${r}`);
    if (!w) f.push(`Semantik: keine Fotostelle „wahl_taeter_r${r}“`);
    else if (!norm(w.text).includes(daten.sabotage[`${lauf.pfad}_${r}`])) f.push(`Semantik: heimliche Wahl fehlt an wahl_taeter_r${r}`);
  }
  const finale = texte.findIndex((x) => x.name === 'finale');
  if (finale < 0) f.push('Semantik: keine Fotostelle „finale“');
  for (const e of finale < 0 ? texte : texte.slice(0, finale)) {
    if (e.name === 'dossier' || e.name === 'dossier_taeter' || e.name.startsWith('wahl_verdeckt_') || e.name.startsWith('wahl_taeter_')) continue;
    // Leerer Text: Der Bildschirm ist an dieser Stelle noch nicht gezeichnet (nur bei „titel“,
    // der vor dem ersten Bild gemeldet wird). Eine Leerprüfung verrät dann nichts.
    const t = norm(e.text);
    if (!t) continue;
    if (t.includes('Nur für dich')) f.push(`Semantik: „Nur für dich“ an ${e.name}`);
    if (t.includes(daten.tarnung[lauf.pfad])) f.push(`Semantik: Täterfassung an ${e.name}`);
  }
  return f;
}

/** Alle Prüfungen eines Laufs; liefert die Fehlermeldungen (leer heißt bestanden). */
function pruefe(lauf, b, daten) {
  const f = [];
  if (b.abbruch) f.push(b.abbruch);
  for (const x of b.parteiFehler) f.push(`PARTY fehler: ${x}`);
  if (b.fertig) {
    if (b.fertig.pfad !== lauf.pfad) f.push(`pfad: erwartet ${lauf.pfad}, ist ${b.fertig.pfad}`);
    if (b.fertig.ende !== lauf.ende) f.push(`ende: erwartet ${lauf.ende}, ist ${b.fertig.ende}`);
    if (Number(b.fertig.rollen) !== lauf.n) f.push(`rollen: erwartet ${lauf.n}, ist ${b.fertig.rollen}`);
  } else if (!b.abbruch && b.parteiFehler.length === 0) {
    f.push('kein „PARTY fertig“');
  }
  const phasen = kollabiere(b.phasen);
  const ohneTitel = phasen[0] === 'titel' ? phasen.slice(1) : phasen;
  if (!gleich(ohneTitel, PHASEN)) f.push(`Phasenfolge weicht ab: ${ohneTitel.join(' > ')}`);
  const gruppen = kollabiere(b.fotostellen.map(fotoGruppe));
  if (!gleich(gruppen, ['titel', ...PHASEN])) f.push(`Fotostellen weichen ab: ${gruppen.join(' > ')}`);
  for (const x of b.konsole) f.push(`Konsole: ${x}`);
  for (const x of b.technik) f.push(`Technik: ${x}`);
  const fremd = [...new Set(b.fremd)];
  if (fremd.length) f.push(`fremde Anfragen (${fremd.length}): ${fremd.slice(0, 3).join(', ')}`);
  if (lauf.semantik) f.push(...pruefeSemantik(lauf, b.fotoTexte ?? [], daten));
  return f;
}

async function warteBis(versprechen, ms) {
  let timer;
  await Promise.race([versprechen.catch(() => {}), new Promise((ok) => { timer = setTimeout(ok, ms); })]);
  clearTimeout(timer);
}

/** Ein Lauf in einem eigenen Browser-Kontext (Ansicht 1280×800). */
async function fuehreLauf(browser, lauf, daten, port) {
  const beginn = Date.now();
  const p = parameter(lauf);
  const ordner = path.join(ausgabe, `${lauf.pfad}_${lauf.ende}_n${lauf.n}${lauf.negativtest ? '_negativtest' : ''}`);
  const b = {
    fertig: null,
    phasen: [],
    fotostellen: [],
    fotos: [],
    fotoTexte: null,
    konsole: [],
    parteiFehler: [],
    technik: [],
    fremd: [],
    abbruch: null,
  };
  if (lauf.fotos) {
    fs.rmSync(ordner, { recursive: true, force: true });
    fs.mkdirSync(ordner, { recursive: true });
  }

  const kontext = await browser.newContext({ locale: 'de-DE', viewport: { width: 1280, height: 800 } });
  let beenden;
  const beendet = new Promise((ok) => { beenden = ok; });
  const zeitlimit = setTimeout(() => {
    b.abbruch = `Zeitlimit von ${p.zeitlimitMin} min überschritten`;
    beenden();
  }, p.zeitlimitMin * 60_000);
  let seite = null;
  let fotoKette = Promise.resolve();

  try {
    await kontext.addInitScript(textHaken, lauf.semantik);
    seite = await kontext.newPage();

    // Fotos nacheinander: 200 ms nach der Meldung, nie zwei gleichzeitig.
    const fotoStellen = (name) => {
      b.fotostellen.push(name);
      if (!lauf.fotos) return;
      const datei = path.join(ordner, `${String(b.fotostellen.length).padStart(3, '0')}_${name}.png`);
      fotoKette = fotoKette
        .then(() => sleep(200))
        .then(() => seite.screenshot({ path: datei, timeout: 20_000 }))
        .then(() => { b.fotos.push(path.relative(ausgabe, datei)); })
        .catch((e) => { b.technik.push(`Foto ${name}: ${kurz(e.message)}`); });
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
      const zeile = text.split('\n')[0];
      let t;
      if ((t = /^PARTY phase=(\w+)/.exec(zeile))) {
        b.phasen.push(t[1]);
      } else if ((t = /^PARTY foto=(\S+)/.exec(zeile))) {
        fotoStellen(t[1]);
      } else if ((t = /^PARTY fertig pfad=(\S+) ende=(\S+) punkte=(\S+) rollen=(\S+)/.exec(zeile))) {
        b.fertig = { pfad: t[1], ende: t[2], punkte: t[3], rollen: t[4] };
        beenden();
      } else if (zeile.startsWith('PARTY fehler')) {
        b.parteiFehler.push(kurz(text));
        beenden();
      }
    });

    await seite.goto(adresse(lauf, port), { waitUntil: 'load' });
    await beendet;
  } catch (e) {
    b.abbruch ??= `Lauffehler: ${kurz(e.message)}`;
  } finally {
    clearTimeout(zeitlimit);
    await warteBis(fotoKette, 30_000);
    if (seite && lauf.semantik) {
      b.fotoTexte = await seite.evaluate(() => window.__e2eTexte ?? []).catch(() => []);
    }
    await kontext.close().catch(() => {});
  }

  const fehler = pruefe(lauf, b, daten);
  const ok = lauf.negativtest ? fehler.some((x) => x.startsWith('ende: erwartet')) : fehler.length === 0;
  return {
    pfad: lauf.pfad,
    ende: lauf.ende,
    n: lauf.n,
    skript: lauf.skript,
    semantik: lauf.semantik,
    negativtest: lauf.negativtest === true,
    ok,
    ende_ist: b.fertig?.ende ?? null,
    punkte: zahl(b.fertig?.punkte),
    dauer_s: Math.round((Date.now() - beginn) / 100) / 10,
    fehler,
    fremd: [...new Set(b.fremd)],
    fotos: b.fotos,
    fotostellen: b.fotostellen,
    phasen: kollabiere(b.phasen),
    ...(lauf.semantik ? { bildschirmtexte: b.fotoTexte ?? [] } : {}),
  };
}

/** `pfad=ahmet,n=4` oder `skript=best,a,richtig,n=7`: Teile ohne `feld=` gehören zum vorigen Wert. */
function parseFilter(text) {
  if (!text) throw new Error('--nur braucht einen Filter, z. B. pfad=ahmet,n=4');
  const f = {};
  let feld = null;
  for (const teil of text.split(',')) {
    const i = teil.indexOf('=');
    const kopf = i < 0 ? '' : teil.slice(0, i).trim();
    if (FILTER_FELDER.includes(kopf)) {
      feld = kopf;
      f[feld] = teil.slice(i + 1);
    } else if (feld) {
      f[feld] += `,${teil}`;
    } else {
      throw new Error(`Filter ungültig: ${teil} (Felder: ${FILTER_FELDER.join(', ')})`);
    }
  }
  for (const k of Object.keys(f)) f[k] = f[k].trim();
  return f;
}

function parseArgs(argv) {
  const o = { nur: null, parallel: 2, negativtest: false };
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i];
    if (a === '--nur') o.nur = parseFilter(argv[++i]);
    else if (a.startsWith('--nur=')) o.nur = parseFilter(a.slice('--nur='.length));
    else if (a === '--parallel') o.parallel = Number(argv[++i]);
    else if (a === '--negativtest') o.negativtest = true;
    else throw new Error(`Unbekannte Option: ${a}`);
  }
  if (![1, 2].includes(o.parallel)) throw new Error('--parallel muss 1 oder 2 sein');
  return o;
}

function passt(lauf, filter) {
  return Object.entries(filter).every(([feld, wert]) => {
    if (feld === 'fotos') return (lauf.fotos ? '1' : '0') === wert;
    if (feld === 'semantik') return (lauf.semantik ? '1' : '0') === wert;
    return String(lauf[feld]) === wert;
  });
}

function zeile(i, gesamt, r) {
  const ergebnis = r.negativtest ? (r.ok ? 'Fehler erkannt' : 'NICHT erkannt') : (r.ok ? 'OK' : 'FEHLER');
  const art = `${r.semantik ? ' semantik' : ''}${r.negativtest ? ' negativtest' : ''}`;
  const meldung = (!r.ok || r.negativtest) && r.fehler.length ? ` | ${r.fehler[0]}${r.fehler.length > 1 ? ` (+${r.fehler.length - 1})` : ''}` : '';
  return `${String(i + 1).padStart(2, '0')}/${gesamt} ${r.pfad} ${r.ende} n=${r.n}${art}: ${ergebnis} (${r.dauer_s} s)${meldung}`;
}

function markdown(b) {
  const z = [];
  z.push('# Bericht E2E Partymodus (F4-BAUMEISTER-07)', '');
  z.push(`Erzeugt: ${b.erzeugt}`);
  z.push(`Filter: ${b.filter ?? 'alle Läufe'}; gleichzeitige Seiten: ${b.parallel}; Modus: ${b.negativtest ? 'Negativtest (Ende-Erwartung vertauscht)' : 'regulär'}`);
  z.push(`Parameter: mit Fotos takt=${MIT_FOTOS.takt}, zeitraffer=${MIT_FOTOS.zeitraffer}, Zeitlimit ${MIT_FOTOS.zeitlimitMin} min; ` +
    `ohne Fotos takt=${OHNE_FOTOS.takt}, zeitraffer=${OHNE_FOTOS.zeitraffer}, Zeitlimit ${OHNE_FOTOS.zeitlimitMin} min; ` +
    `Semantik-Läufe takt=${SEMANTIK.takt}, zeitraffer=${SEMANTIK.zeitraffer}, Zeitlimit ${SEMANTIK.zeitlimitMin} min`, '');
  z.push(`Summe: ${b.summe.bestanden}/${b.summe.gesamt} ${b.negativtest ? 'Fehler erkannt' : 'bestanden'}`, '');
  z.push('| # | Pfad | Ende (erwartet) | n | Ergebnis | Ende (ist) | Punkte | Dauer (s) | Fotos | Semantik |');
  z.push('|---|---|---|---|---|---|---|---|---|---|');
  b.laeufe.forEach((r, i) => {
    const ergebnis = r.negativtest ? (r.ok ? 'Fehler erkannt' : 'NICHT erkannt') : (r.ok ? 'bestanden' : 'FEHLER');
    z.push(`| ${i + 1} | ${r.pfad} | ${r.ende} | ${r.n} | ${ergebnis} | ${r.ende_ist ?? '–'} | ${r.punkte ?? '–'} | ${r.dauer_s} | ${r.fotos.length} | ${r.semantik ? 'ja' : '–'} |`);
  });
  z.push('', '## Fehler je Lauf', '');
  const mitFehler = b.laeufe.filter((r) => !r.ok || (r.negativtest && r.fehler.length));
  if (mitFehler.length === 0) z.push('keine');
  for (const r of mitFehler) {
    z.push(`- **${r.pfad} / ${r.ende} / n=${r.n}${r.negativtest ? ' (Negativtest)' : ''}**: ${r.fehler.join('; ')}`);
    if (r.fremd.length) z.push(`  - fremde Anfragen: ${r.fremd.join(', ')}`);
  }
  if (b.negativtest) {
    const r = b.laeufe[0];
    const meldung = r.fehler.find((x) => x.startsWith('ende: erwartet')) ?? 'keine Ende-Meldung';
    z.push('', '## Negativtest', '');
    z.push(`Kopie des Laufs ${r.pfad} / n=${r.n} mit vertauschter Ende-Erwartung (erwartet: ${r.ende}). ` +
      `Ergebnis: ${r.ok ? 'Fehler erkannt' : 'NICHT erkannt'}. Meldung: ${meldung}.`);
  }
  return `${z.join('\n')}\n`;
}

async function main() {
  const optionen = parseArgs(process.argv.slice(2));
  if (!fs.existsSync(path.join(build, 'index.html'))) {
    throw new Error('Web-Build fehlt (build/web). Bauen mit: flutter build web --release --no-web-resources-cdn -o build/web');
  }
  let laeufe = alleLaeufe().filter((l) => !optionen.nur || passt(l, optionen.nur));
  if (laeufe.length === 0) throw new Error('Kein Lauf passt zum Filter.');
  if (optionen.negativtest) {
    const kopie = structuredClone(laeufe[0]);
    laeufe = [{ ...kopie, ende: TAUSCH[kopie.ende], negativtest: true }];
  }
  const daten = ladeDaten();
  fs.mkdirSync(ausgabe, { recursive: true });

  const server = await starteServer(build);
  const port = server.address().port;
  const ergebnisse = [];
  let browser = null;
  try {
    browser = await starteBrowser();
    console.log(`E2E: ${laeufe.length} Läufe, ${optionen.parallel} gleichzeitige Seite(n), Server 127.0.0.1:${port}`);
    let naechster = 0;
    const arbeiter = async () => {
      while (naechster < laeufe.length) {
        const i = naechster++;
        const r = await fuehreLauf(browser, laeufe[i], daten, port);
        ergebnisse[i] = r;
        console.log(zeile(i, laeufe.length, r));
      }
    };
    await Promise.all(Array.from({ length: Math.min(optionen.parallel, laeufe.length) }, arbeiter));
  } finally {
    await browser?.close();
    server.close();
  }

  const bestanden = ergebnisse.filter((r) => r.ok).length;
  const bericht = {
    erzeugt: new Date().toISOString(),
    filter: optionen.nur ? Object.entries(optionen.nur).map(([k, v]) => `${k}=${v}`).join(',') : null,
    parallel: optionen.parallel,
    negativtest: optionen.negativtest,
    summe: { bestanden, gesamt: ergebnisse.length },
    laeufe: ergebnisse,
  };
  fs.writeFileSync(path.join(ausgabe, 'bericht.json'), `${JSON.stringify(bericht, null, 2)}\n`);
  fs.writeFileSync(path.join(ausgabe, 'bericht.md'), markdown(bericht));
  console.log(`Summe: ${bestanden}/${ergebnisse.length} ${optionen.negativtest ? 'Fehler erkannt' : 'bestanden'}`);
  console.log(`Bericht: ${path.join(ausgabe, 'bericht.md')}`);
  process.exitCode = bestanden === ergebnisse.length ? 0 : 1;
}

main().catch((e) => {
  console.error(e.message);
  process.exitCode = 2;
});
