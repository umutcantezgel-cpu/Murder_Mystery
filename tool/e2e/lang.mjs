// Browserprobe des langen Abends (M7b, `?party=schlosskeller&fassung=lang`) gegen den Web-Build.
// Derselbe Abend (Pfad, Fall-Code, Personenzahl, Skript und Salz, also dieselben Würfel) läuft einmal
// kurz und einmal lang über die Entwicklerroute (PartySkript), nacheinander bei 390 × 844 px (zwei
// Seiten zugleich bremsen sich auf vier Kernen mehr aus, als sie sparen). Kurz mit „Bewegung
// reduzieren“ (Kartenaktionen als Kurzblende, schnell; auch das darf am Abend nichts ändern), lang
// mit Bewegung und Fotos:
// Vorspiel Station für Station, Diashow, je Runde der Streifzug mit Treffpunkten, Erkundung und
// Rückweg vor jeder Entscheidung, Auflösung, Morgen, Schlussbild.
// Geprüft wird je Lauf, was e2e.mjs prüft (Pfad, Ende, Personenzahl, Phasenfolge, Fotostellen je
// Abschnitt, Streifzug-Fotostellen je Runde, Konsole, nur lokale Anfragen), dazu:
//   - `PARTY fertig` lang gleich kurz: Pfad, Ende, Punkte, Personenzahl, Zahl der Würfe,
//     Nachtminuten und die Kennung des Abends (Würfe, Wahlen, Fakten, Marken, Qualitäten, Abstecher)
//   - Fotofolge lang: `vorspiel` nach den Dossiers und vor der Diashow (`intro`), je Runde
//     `streifzug_r<n>`, `treffpunkt_r<n>` und `erkundung_r<n>` genau einmal in ihrer Runde, `morgen`
//     nach der Auflösung und vor dem Schlussbild (`ende`); kurz keine davon
//   - lang liegt zu jeder dieser Fotostellen ein Foto vor
// Fotografiert werden die Stellen des langen Abends (`fotonur=`; dort wartet das Skript die
// Fotopause); die übrigen meldet das Skript nur. `--alle-fotos` fotografiert jede Fotostelle (dauert
// gut drei Minuten länger).
// Aufruf in tool/e2e: node lang.mjs [--pfad ahmet] [--n 4] [--ende ende_meister] [--alle-fotos]
// Ausgabe: fotos/lang/ (Fotos des langen Laufs, bericht.json).
// Rückgabewert 0 nur, wenn beide Läufe bestehen und lang wie kurz endet; 2 bei Aufrufproblemen.

import fs from 'node:fs';
import path from 'node:path';
import { starteBrowser } from './browser.mjs';
import { fuehreLauf, ladeDaten, STREIFZUG_FOTOS } from './e2e.mjs';
import { ENDEN, PFADE } from './laeufe.mjs';
import { starteServer } from './server.mjs';

const hier = import.meta.dirname;
const repo = path.resolve(hier, '../..');
const build = path.join(repo, 'build/web');
const ausgabe = path.join(hier, 'fotos', 'lang');

/** Handy hochkant, wie man den Abend am Tisch spielt. */
const ANSICHT = { width: 390, height: 844 };

/**
 * Kurz ohne Fotos und ruhig (Takt und Zeitraffer der schnellen e2e-Läufe). Lang mit Fotos: An jeder Fotostelle
 * wartet das Skript die Fotopause (2 s wie in e2e.mjs: so zeigt das Foto noch die Karte der Stelle);
 * Wege gehen sichtbar und werden nach 1,5 s abgekürzt.
 */
const KURZ = { takt: 40, zeitraffer: 240, zeitlimitMin: 6 };
const LANG = { takt: 80, zeitraffer: 240, fotopause: 2000, zeitlimitMin: 12 };

/** Anfänge der Fotostellen des langen Abends. */
const LANG_FOTOS = ['vorspiel', ...STREIFZUG_FOTOS, 'morgen'];

/** Die Fotostellen des langen Abends, die es kurz nicht gibt. */
const NUR_LANG = ['vorspiel', 'morgen', ...[1, 2, 3].flatMap((r) => STREIFZUG_FOTOS.map((a) => `${a}_r${r}`))];

function parseArgs(argv) {
  const o = { pfad: 'ahmet', n: 4, ende: 'ende_meister', alleFotos: false };
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i];
    if (a === '--pfad') o.pfad = argv[++i];
    else if (a === '--n') o.n = Number(argv[++i]);
    else if (a === '--ende') o.ende = argv[++i];
    else if (a === '--alle-fotos') o.alleFotos = true;
    else throw new Error(`Unbekannte Option: ${a}`);
  }
  if (!PFADE.includes(o.pfad)) throw new Error(`--pfad muss einer von ${PFADE.join(', ')} sein`);
  if (!Number.isInteger(o.n) || o.n < 4 || o.n > 20) throw new Error('--n muss zwischen 4 und 20 liegen');
  if (!Object.hasOwn(ENDEN, o.ende)) throw new Error(`--ende muss einer von ${Object.keys(ENDEN).join(', ')} sein`);
  return o;
}

/** Fotofolge und Fotos des langen Laufs; kurz keine der Fotostellen des langen Abends. */
function pruefeFolge(kurz, lang) {
  const f = [];
  for (const name of NUR_LANG) {
    if (kurz.fotostellen.includes(name)) f.push(`kurz: Fotostelle ${name}`);
  }
  const s = lang.fotostellen;
  const einmal = (name) => {
    const n = s.filter((x) => x === name).length;
    if (n !== 1) f.push(`lang: ${name} ${n}-mal statt einmal`);
    return s.indexOf(name);
  };
  const vor = (a, b) => {
    const i = einmal(a);
    const j = s.indexOf(b);
    if (i < 0 || j < 0 || i > j) f.push(`lang: ${a} nicht vor ${b}`);
  };
  vor('dossier_taeter', 'vorspiel');
  vor('vorspiel', 'intro');
  vor('intro', 'gespraeche_r1');
  for (const r of [1, 2, 3]) {
    vor(`gespraeche_r${r}`, `streifzug_r${r}`);
    vor(`streifzug_r${r}`, `treffpunkt_r${r}`);
    vor(`erkundung_r${r}`, `entscheidungen_fertig_r${r}`);
  }
  vor('aufloesung_r3', 'morgen');
  vor('morgen', 'ende');
  for (const name of NUR_LANG) {
    if (s.includes(name) && !lang.fotos.some((x) => x.endsWith(`_${name}.png`))) f.push(`lang: kein Foto von ${name}`);
  }
  return f;
}

async function main() {
  const o = parseArgs(process.argv.slice(2));
  if (!fs.existsSync(path.join(build, 'index.html'))) {
    throw new Error('Web-Build fehlt (build/web). Bauen mit: flutter build web --release --no-web-resources-cdn -o build/web');
  }
  fs.rmSync(ausgabe, { recursive: true, force: true });
  fs.mkdirSync(ausgabe, { recursive: true });
  const basis = {
    pfad: o.pfad, ende: o.ende, n: o.n, skript: ENDEN[o.ende], semantik: false, ansicht: ANSICHT,
    // Dasselbe Salz in beiden Läufen: dieselben Würfel, also derselbe Abend.
    salz: `lang-probe:${o.pfad}:${o.n}:${o.ende}`,
  };
  const kurzLauf = { ...basis, fotos: false, lang: false, ruhig: true, parameter: KURZ };
  const langLauf = { ...basis, fotos: true, lang: true, parameter: LANG, ...(o.alleFotos ? {} : { fotoNur: LANG_FOTOS }) };
  const daten = ladeDaten();
  const server = await starteServer(build);
  const port = server.address().port;
  let browser = null;
  let kurz;
  let lang;
  try {
    browser = await starteBrowser();
    console.log(`LANG: ${o.pfad} ${o.ende} n=${o.n}, erst kurz, dann lang; Server 127.0.0.1:${port}`);
    kurz = await fuehreLauf(browser, kurzLauf, daten, port, ausgabe);
    console.log(`kurz: ${kurz.ok ? 'OK' : 'FEHLER'} · ${kurz.dauer_s} s`);
    lang = await fuehreLauf(browser, langLauf, daten, port, ausgabe);
  } finally {
    await browser?.close();
    server.close();
  }

  const fehler = [
    ...kurz.fehler.map((x) => `kurz: ${x}`),
    ...lang.fehler.map((x) => `lang: ${x}`),
  ];
  if (kurz.ok && lang.ok) {
    if (!/ wuerfe=\d+ nacht=-?\d+ abend=[0-9a-f]{8}$/.test(kurz.fertig ?? '')) fehler.push(`kurz: PARTY fertig ohne Würfe und Kennung: ${kurz.fertig}`);
    if (lang.fertig !== kurz.fertig) fehler.push(`PARTY fertig: lang „${lang.fertig}“, kurz „${kurz.fertig}“`);
  }
  fehler.push(...pruefeFolge(kurz, lang));
  const bericht = { erzeugt: new Date().toISOString(), ok: fehler.length === 0, fehler, kurz, lang };
  fs.writeFileSync(path.join(ausgabe, 'bericht.json'), `${JSON.stringify(bericht, null, 2)}\n`);
  for (const r of [kurz, lang]) {
    console.log(`${r.lang ? 'lang' : 'kurz'}: ${r.ok ? 'OK' : 'FEHLER'} · ${r.fertig ?? 'kein PARTY fertig'} · ${r.fotostellen.length} Fotostellen · ${r.fotos.length} Fotos · ${r.dauer_s} s`);
  }
  if (fehler.length) {
    console.error(`LANG ROT · ${fehler.slice(0, 8).join(' | ')}${fehler.length > 8 ? ` (+${fehler.length - 8})` : ''}`);
    process.exitCode = 1;
    return;
  }
  const stellen = NUR_LANG.filter((x) => lang.fotostellen.includes(x)).length;
  console.log(`LANG GRÜN · ${o.pfad} n=${o.n}: lang endet wie kurz (${lang.ende_ist}, ${lang.punkte} Punkte, gleiche Würfe und Kennung) · ` +
    `${stellen} Fotostellen des langen Abends · ${lang.fotos.length} Fotos unter ${path.relative(repo, lang.ordner)}`);
}

main().catch((e) => {
  console.error(e.message);
  process.exitCode = 2;
});
