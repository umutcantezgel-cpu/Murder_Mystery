// Online-Abend „Jeder am eigenen Gerät“ mit drei Handys (390 × 844), echte Zeigerereignisse:
// Gastgeberin Anna in der Detektei bis zur Lobby, Gäste Ben und Cleo über den Beitrittslink.
// Rollen lesen, in Runde 1 befragt Anna als Detektiv drei bis fünf Rollen (Modell befragung:
// Ben und Cleo sehen die Frage auf dem eigenen Gerät, Anna nie ihre Antwort), dann bis zur
// Gruppenwahl, Gäste geben ihre Stimme ab. Relais ist die lokale
// Attrappe (server/ → dart run ../tool/e2e/attrappe.dart). Keine Anfrage außerhalb von localhost.
// Aufruf: node tool/e2e/geraete.mjs. Eine schon laufende Attrappe nimmt MORDAKTE_RELAIS=ws://127.0.0.1:4455.
// Fotos ohne geheime Texte: planung/einspiel/fotos/m2/ (390 px). Rollen- und Wahlfotos (Dossiers) und Fehlerbilder
// bleiben lokal unter tool/e2e/fotos/geraete/ (gitignoriert).
import assert from 'node:assert/strict';
import fs from 'node:fs/promises';
import path from 'node:path';
import { spawn } from 'node:child_process';
import { befragungenFuehren } from './befragung.mjs';
import { starteBrowser } from './browser.mjs';
import { starteServer } from './server.mjs';

const repo = path.resolve(import.meta.dirname, '../..');
const fotos = path.join(repo, 'planung/einspiel/fotos/m2');
const fehlerOrdner = path.join(import.meta.dirname, 'fotos/geraete');
// Rollen- und Wahlfotos zeigen geheime Dossiers und bleiben lokal (tool/e2e/fotos ist ignoriert).
const geheimOrdner = path.join(fehlerOrdner, 'geheim');
await fs.mkdir(fotos, { recursive: true });
await fs.mkdir(fehlerOrdner, { recursive: true });
await fs.mkdir(geheimOrdner, { recursive: true });

const readJson = async file => JSON.parse(await fs.readFile(path.join(repo, file), 'utf8'));
const arb = await readJson('lib/l10n/app_de.arb');
const root = 'content/party/schlosskeller';
const index = await readJson(`${root}/texte/index.json`);
const ui = new Map();
for (const entry of index.dateien.filter(entry => entry.bereich === 'ui')) {
  for (const item of (await readJson(`${root}/texte/${entry.datei}`)).eintraege) ui.set(item.id, item.text);
}
const text = key => {
  const value = ui.get(key) ?? arb[key.replace(/^ui\./, 'party_').replaceAll('.', '_')];
  assert.equal(typeof value, 'string', `Unbekannter Textschlüssel: ${key}`);
  return value;
};
const choices = (await readJson(`${root}/entscheidungen.json`)).entscheidungen;
const besetzung = await readJson(`${root}/besetzung.json`);
const dossiere = [];
for (const eintrag of index.dateien.filter(e => e.bereich === 'dossier')) {
  dossiere.push(...(await readJson(`${root}/texte/${eintrag.datei}`)).eintraege);
}
// Befragungen des Detektivs (A-051): Kennung → Rolle, Fragen und eigene Stichpunkte der Rolle.
const befragungen = new Map();
for (const eintrag of index.dateien.filter(e => e.bereich === 'befragung')) {
  for (const b of (await readJson(`${root}/texte/${eintrag.datei}`)).eintraege) befragungen.set(b.id, b);
}
const escapeRe = s => s.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');

const WIDTH = 390;
const HEIGHT = 844;
const ANNA = 'Anna';
const gaeste = ['Ben', 'Cleo'];
const zeit = { kurz: 150, tap: 420 };

// ---------------------------------------------------------------- Attrappe und Server

function starteAttrappe() {
  const prozess = spawn(process.env.MORDAKTE_DART ?? 'dart', ['run', '../tool/e2e/attrappe.dart', '0'], {
    cwd: path.join(repo, 'server'),
    env: process.env,
  });
  let puffer = '';
  return new Promise((ok, fail) => {
    const frist = setTimeout(() => fail(new Error('Attrappe ist nach 180 s nicht bereit')), 180000);
    const lies = data => {
      puffer += data;
      const treffer = puffer.match(/Attrappe läuft: ws:\/\/127\.0\.0\.1:(\d+)/);
      if (treffer) {
        clearTimeout(frist);
        ok({ prozess, ws: `ws://127.0.0.1:${treffer[1]}` });
      }
    };
    prozess.stdout.on('data', lies);
    prozess.stderr.on('data', data => { puffer += data; });
    prozess.on('exit', code => { clearTimeout(frist); fail(new Error(`Attrappe beendet sich (Code ${code}): ${puffer.slice(-600)}`)); });
  });
}

// ---------------------------------------------------------------- Bedienung

const knopf = (page, name) => page.getByRole('button', { name, exact: true });

async function offen(page, name) {
  const b = knopf(page, name);
  return (await b.count()) === 1 && (await b.isVisible()) && (await b.isEnabled());
}

async function tippe(page, ziel, label) {
  const frist = Date.now() + 30000;
  while ((await ziel.count()) !== 1 && Date.now() < frist) await page.waitForTimeout(100);
  assert.equal(await ziel.count(), 1, `Tippfläche ist nicht eindeutig: ${label}`);
  await ziel.waitFor({ state: 'visible', timeout: 30000 });
  await ziel.scrollIntoViewIfNeeded();
  const frist2 = Date.now() + 30000;
  while (!(await ziel.isEnabled()) && Date.now() < frist2) await page.waitForTimeout(100);
  assert(await ziel.isEnabled(), `Tippfläche bleibt gesperrt: ${label}`);
  const box = await ziel.boundingBox();
  assert(box && box.width > 0 && box.height > 0, `Tippfläche ohne Größe: ${label}`);
  const x = box.x + box.width / 2;
  const y = box.y + box.height / 2;
  assert(x >= 0 && x < WIDTH && y >= 0 && y < HEIGHT, `Tippfläche liegt außerhalb des Handys: ${label}`);
  // Echter Zeiger über den Flutter-Hittest, nicht ein DOM-Klick.
  await page.mouse.click(x, y);
  await page.waitForTimeout(zeit.tap);
}

const tippeKnopf = (h, name) => tippe(h.page, knopf(h.page, name), `${h.name}: ${name}`);

async function warteAuf(h, pruefung, label, frist = 30000) {
  const ende = Date.now() + frist;
  while (Date.now() < ende) {
    const ergebnis = await pruefung();
    if (ergebnis) return ergebnis;
    await h.page.waitForTimeout(zeit.kurz);
  }
  throw new Error(`${h.name}: Zeitüberschreitung bei „${label}“`);
}

/** Ein Name steht als eigene Zeile in den Texten (Zeilen einer Liste dürfen mehr Text enthalten). */
const nennt = (texte, name) => texte.some(t => t.split(/\n|,|·/).map(s => s.trim()).includes(name));

/** Alle sichtbaren Texte und Beschriftungen der Seite in Dokumentreihenfolge. */
// Flutter-Web legt Text als flt-Semantik-Knoten mit <span> ab (Kinder ohne Semantik) und Knöpfe
// oft ohne aria-label; daher: aria-label, sonst der Text eines Blattknotens (ohne Semantik-Kinder).
const alleTexte = page => page.evaluate(() => [...document.querySelectorAll('flt-semantics')]
  .flatMap(node => {
    const label = (node.getAttribute('aria-label') || '').trim();
    if (label) return [label];
    return node.querySelector('flt-semantics') ? [] : [(node.textContent || '').trim()];
  })
  .filter(Boolean));

const zeigt = (page, muster) => page.getByText(muster).count().then(n => n > 0);

// ---------------------------------------------------------------- Handys

async function oeffneHandy(browser, name, url, log) {
  const context = await browser.newContext({ viewport: { width: WIDTH, height: HEIGHT }, deviceScaleFactor: 1, locale: 'de-DE' });
  const page = await context.newPage();
  const h = { name, context, page, konsole: [], javascript: [], fremd: [], sockets: [] };
  page.on('pageerror', error => h.javascript.push(error.message));
  page.on('console', message => { if (message.type() === 'error') h.konsole.push(message.text()); });
  page.on('websocket', socket => h.sockets.push(socket.url()));
  await context.route('**/*', async route => {
    const u = new URL(route.request().url());
    if (!['127.0.0.1', 'localhost'].includes(u.hostname) && !['data:', 'blob:', 'about:'].includes(u.protocol)) {
      h.fremd.push(route.request().url());
      await route.abort();
    } else await route.continue();
  });
  await page.goto(url, { waitUntil: 'load' });
  const platzhalter = page.locator('flt-semantics-placeholder');
  await platzhalter.waitFor({ state: 'attached', timeout: 60000 });
  await platzhalter.evaluate(element => element.click());
  log(`${name}: Seite geladen`);
  return h;
}

// ---------------------------------------------------------------- Ablauf

const lauf = { schritt: '', zaehler: { befragt: 0, gastFragen: 0, gewuerfelt: 0, gastWuerfe: 0, entscheidungen: 0 } };
const log = text => console.log(`· ${text}`);

async function gastTippt(gastListe, name) {
  for (const g of gastListe) {
    if (await offen(g.page, name)) {
      await tippe(g.page, knopf(g.page, name), `${g.name}: ${name}`);
      return g.name;
    }
  }
  return null;
}

const norm = s => s.replace(/\s+/g, ' ').trim();
const zeilen = liste => (liste ?? []).map(z => (typeof z === 'string' ? z : z?.text)).filter(t => typeof t === 'string');

/** Die privaten Zeilen eines Dossiers (Wer ich bin, Ziel, Was ich weiß, Was ich verberge), ab 20 Zeichen. */
const privat = e => [e.wer, e.ziel, ...zeilen(e.weiss), ...zeilen(e.verbirgt)]
  .filter(t => typeof t === 'string').map(norm).filter(t => t.length >= 20);

/** Das Dossier, dessen „Wer ich bin“-Zeile auf dieser Seite steht; `null`, solange nichts gezeichnet ist. */
const eigenesDossier = texte => {
  const alles = norm(texte.join('\n'));
  return dossiere.find(e => typeof e.wer === 'string' && alles.includes(norm(e.wer))) ?? null;
};

/** Die beiden Antwortkarten der Gruppenwahl: die Knöpfe direkt vor „Wahl abgeben“. */
async function wahlOptionen(page) {
  return page.evaluate(label => {
    const beschriftung = node => (node.getAttribute('aria-label') || node.textContent || '').trim();
    const knoepfe = [...document.querySelectorAll('flt-semantics[role="button"]')];
    const i = knoepfe.findIndex(node => beschriftung(node) === label);
    if (i < 2) return [];
    return knoepfe.slice(i - 2, i).map(beschriftung);
  }, text('online_wahl_abgeben'));
}

async function fotografiere(h, dateiname, label, ordner = fotos) {
  const datei = path.join(ordner, dateiname);
  await h.page.screenshot({ path: datei });
  log(`Foto ${label}: ${path.relative(repo, datei)}`);
}

async function main() {
  // MORDAKTE_RELAIS=ws://127.0.0.1:4455 nimmt eine schon laufende Attrappe; sonst startet dieser Lauf eine eigene.
  const vorhanden = process.env.MORDAKTE_RELAIS?.trim();
  const { prozess, ws } = vorhanden ? { prozess: null, ws: vorhanden } : await starteAttrappe();
  assert(/^ws:\/\/127\.0\.0\.1:\d+$/.test(ws), `Relais muss lokal sein: ${ws}`);
  log(`Attrappe: ${ws}`);
  const server = await starteServer(path.join(repo, 'build/web'));
  const base = `http://127.0.0.1:${server.address().port}`;
  const relay = encodeURIComponent(ws);
  const handys = [];
  const alle = () => handys;
  let browser;
  let anna;
  let stufe = 'Start';
  try {
    browser = await starteBrowser();

    // 1. Gastgeberin Anna: Detektei → Akte → Spielweise → Raum öffnen
    stufe = 'Anna: Detektei und Akte';
    anna = await oeffneHandy(browser, 'Anna', `${base}/?semantik=1&name=${ANNA}&relay=${relay}`, log);
    handys.push(anna);
    const p = anna.page;
    await warteAuf(anna, () => knopf(p, text('detektei_neuer_abend')).isVisible().catch(() => false), 'Detektei');
    stufe = 'Anna: Neuer Abend';
    await tippeKnopf(anna, text('detektei_neuer_abend'));
    stufe = 'Anna: Akte Schlosskeller';
    await warteAuf(anna, () => offen(p, text('abend_weiter')), 'Akte-Schritt des Abends');
    await tippe(p, p.getByRole('button', { name: /Spuk im Schlosskeller/ }), 'Akte Schlosskeller');
    await tippeKnopf(anna, text('abend_weiter'));
    stufe = 'Anna: Spielweise „Jeder am eigenen Gerät“';
    await tippe(p, p.getByRole('button', { name: new RegExp(`^${escapeRe(text('abend_spielweise_eigene'))}`) }), 'Spielweise');
    await tippeKnopf(anna, text('abend_weiter'));
    stufe = 'Anna: Einstellungen';
    await tippeKnopf(anna, text('abend_weiter'));
    stufe = 'Anna: Raum öffnen';
    await tippeKnopf(anna, text('online_raum_oeffnen'));

    // 2. Lobby: Raumcode lesen
    stufe = 'Anna: Lobby und Raumcode';
    const code = await warteAuf(anna, async () => {
      const texte = await alleTexte(p);
      const treffer = texte.map(t => t.match(/Raumcode ([A-Z0-9]{3}-[A-Z0-9]{3})/)).find(Boolean);
      return treffer?.[1] ?? null;
    }, 'Raumcode in der Lobby', 60000);
    log(`Raumcode ${code}`);
    assert(await zeigt(p, text('online_lobby_titel')), 'Die Lobby ist nicht sichtbar');

    // 3. Gäste treten über den Beitrittslink bei und sagen Bereit
    const gastHandys = [];
    for (const name of gaeste) {
      stufe = `${name}: Beitritt`;
      const link = `${base}/?semantik=1&name=${name}&relay=${relay}#/beitreten?raum=${code.replace('-', '')}`;
      const g = await oeffneHandy(browser, name, link, log);
      handys.push(g);
      gastHandys.push(g);
      await warteAuf(g, () => zeigt(g.page, text('online_beitreten_titel')), 'Beitreten-Seite');
      await tippeKnopf(g, text('online_beitreten_los'));
      await warteAuf(g, () => zeigt(g.page, text('online_gast_lobby_titel')), 'Warten auf den Start', 60000);
      if (name === 'Ben') await fotografiere(g, 'geraete-gast-lobby-390x844.png', 'Gast-Lobby (Ben)');
      stufe = `${name}: Bereit`;
      await tippeKnopf(g, text('online_bereit_knopf'));
      await warteAuf(g, () => zeigt(g.page, text('online_bereit_zurueck')), '„Doch nicht bereit“');
    }
    // Gäste am Tisch: Anna sieht beide online und bereit.
    stufe = 'Anna: Gäste bereit';
    await warteAuf(anna, async () => {
      const texte = await alleTexte(p);
      return gaeste.every(name => nennt(texte, name)) && (await offen(p, text('online_abend_starten')));
    }, '„Abend starten“ freigeschaltet', 60000);

    // 4. Rollen auf das Minimum, Lobbyfoto, Start
    stufe = 'Anna: Rollen auf das Minimum';
    let minimum = 0;
    for (let i = 0; i < 20; i++) {
      if (!(await offen(p, text('online_rollen_weniger')))) break;
      await tippeKnopf(anna, text('online_rollen_weniger'));
    }
    const rollenText = (await alleTexte(p)).find(t => /^\d+ Rollen$/.test(t));
    minimum = Number(rollenText?.split(' ')[0]);
    const erwartet = Math.max(besetzung.minRollen, Math.min(gaeste.length, besetzung.maxRollen));
    assert.equal(minimum, erwartet, `Rollen auf dem Minimum: ${rollenText}`);
    log(`Rollen: ${minimum} (Minimum aus Gästen und Besetzung)`);
    await fotografiere(anna, 'geraete-host-lobby-390x844.png', 'Gastgeber-Lobby');
    stufe = 'Anna: Abend starten';
    await tippeKnopf(anna, text('online_abend_starten'));

    // 5. Rollen: jede Person liest auf dem eigenen Gerät
    stufe = 'Gäste: Deine Rolle';
    const rollen = {};
    for (const g of gastHandys) {
      await warteAuf(g, () => zeigt(g.page, new RegExp(`^${escapeRe(text('online_rolle_marke'))}$`, 'i')), 'Deine Rolle', 60000);
      rollen[g.name] = await warteAuf(g, async () => {
        const texte = await alleTexte(g.page);
        const eintrag = eigenesDossier(texte);
        return eintrag ? { texte, eintrag } : null;
      }, 'Eigenes Dossier mit „Wer ich bin“', 60000);
    }
    assert.notEqual(rollen.Ben.eintrag.rolle, rollen.Cleo.eintrag.rolle, 'Ben und Cleo bekommen dieselbe Rolle');
    // Jedes Gerät zeigt nur die eigene Rolle: keine private Zeile des anderen Gastes auf dem Bildschirm,
    // gemeinsame Sätze ausgenommen. Die Gastgeberin sieht gar keine Dossierzeile.
    const priv = Object.fromEntries(gastHandys.map(g => [g.name, privat(rollen[g.name].eintrag)]));
    for (const g of gastHandys) {
      const sicht = norm((await alleTexte(g.page)).join('\n'));
      const eigene = new Set(priv[g.name]);
      const eigeneVerborgen = zeilen(rollen[g.name].eintrag.verbirgt).map(norm);
      assert(eigeneVerborgen.some(z => sicht.includes(z)), `${g.name}: die eigenen Zeilen „Was ich verberge“ fehlen auf dem Gerät`);
      for (const fremder of gastHandys.filter(x => x !== g)) {
        for (const zeile of priv[fremder.name]) {
          if (eigene.has(zeile)) continue;
          assert(!sicht.includes(zeile), `${g.name} sieht eine private Zeile von ${fremder.name}: „${zeile.slice(0, 60)}…“`);
        }
      }
      log(`${g.name}: eigene Rolle ${rollen[g.name].eintrag.rolle}, keine private Zeile von ${gaeste.filter(x => x !== g.name).join(', ')} (${priv[gaeste.find(x => x !== g.name)].length} Zeilen geprüft)`);
    }
    const hostSicht = norm((await alleTexte(p)).join('\n'));
    for (const g of gastHandys) {
      for (const zeile of priv[g.name]) assert(!hostSicht.includes(zeile), `Die Gastgeberin sieht eine private Zeile von ${g.name}: „${zeile.slice(0, 60)}…“`);
    }
    log(`Gastgeberin: keine Dossierzeile auf dem Gerät`);
    await fotografiere(gastHandys[0], 'geraete-gast-rolle-ben-390x844.png', 'Rolle Ben (geheim, nur lokal)', geheimOrdner);
    await fotografiere(gastHandys[1], 'geraete-gast-rolle-cleo-390x844.png', 'Rolle Cleo (geheim, nur lokal)', geheimOrdner);

    stufe = 'Gäste: Gelesen';
    await tippeKnopf(gastHandys[0], text('online_gelesen_knopf'));
    await warteAuf(anna, () => zeigt(anna.page, /Warten auf die Gäste: 1 von 2/), 'Gastgeberin wartet: 1 von 2');
    await fotografiere(anna, 'geraete-host-wartet-390x844.png', 'Gastgeber wartet (1 von 2 gelesen)');
    await tippeKnopf(gastHandys[1], text('online_gelesen_knopf'));
    stufe = 'Anna: Rollen weiter';
    await warteAuf(anna, () => offen(p, text('ui.rollen.weiter')), 'Rollen weiter', 60000);
    await tippeKnopf(anna, text('ui.rollen.weiter'));
    await tippeKnopf(anna, text('ui.intro.weiter'));

    // 6. Runde 1: Befragungen (Modell befragung, A-051). Anna ist der Detektiv und stellt je Karte die
    // erste Frage. Rollen der App antworten nur ihr; Ben und Cleo sehen die Frage auf dem eigenen Gerät,
    // antworten am Tisch, und Anna tippt „Beantwortet“. „Weiter“ wird erst danach frei.
    stufe = 'Anna: Befragungen Runde 1';
    const rundeWeiter = text('ui.runde.weiter');
    assert(!(await offen(p, rundeWeiter)), 'Weiter ist vor den Befragungen frei');
    const gastVon = Object.fromEntries(gastHandys.map(g => [rollen[g.name].eintrag.rolle, g]));
    const befragung = await befragungenFuehren(p, {
      tippe: (ziel, label) => tippe(p, ziel, `Anna: ${label}`),
      fertig: () => offen(p, rundeWeiter),
      nachFrage: async id => {
        const b = befragungen.get(id);
        assert(b, `Unbekannte Befragung ${id}`);
        const g = gastVon[b.rolle];
        if (!g) return;
        stufe = `${g.name}: Frage des Detektivs`;
        const frage = text('party_befragung_fragt').replace('{frage}', b.fragen[0]);
        await warteAuf(g, () => zeigt(g.page, frage), `„${frage}“ auf dem Gerät`);
        if (lauf.zaehler.gastFragen++ === 0) {
          await fotografiere(g, `geraete-gast-befragt-${g.name.toLowerCase()}-390x844.png`, `Befragt: ${g.name} (geheim, nur lokal)`, geheimOrdner);
        }
        // Was die befragte Person sagt, steht nie auf Annas Gerät.
        const sicht = norm((await alleTexte(p)).join('\n'));
        for (const z of b.stichpunkte ?? []) assert(!sicht.includes(norm(z)), `Anna sieht den Spickzettel von ${g.name}: „${z}“`);
        stufe = 'Anna: Befragungen Runde 1';
      },
    });
    assert(befragung.fragen >= 3 && befragung.fragen <= 5, `Runde 1: ${befragung.fragen} Befragungen statt drei bis fünf`);
    assert.equal(befragung.beantwortet, lauf.zaehler.gastFragen, 'Jede Frage an Ben oder Cleo wird am Tisch beantwortet');
    lauf.zaehler.befragt = befragung.fragen;
    log(`Befragungen: ${befragung.fragen} (davon ${lauf.zaehler.gastFragen} an Gäste, ${befragung.gewaehlt} frei gewählt)`);
    // Annas Karten zeigen die Antworten der App-Rollen: nur für den Detektiv, daher nur lokal.
    await fotografiere(anna, 'geraete-host-befragungen-390x844.png', 'Gastgeberin nach den Befragungen (nur lokal)', geheimOrdner);
    stufe = 'Anna: Runde 1 weiter';
    await tippeKnopf(anna, rundeWeiter);

    // 7. Ermittlung der Runde 1: Würfe (Würfelpate am Gast-Gerät), Karten, bis zur Gruppenwahl
    stufe = 'Runde 1: Ermittlung';
    const runde1 = choices.filter(e => e.runde === 1);
    let naechste = 0;
    for (let i = 0; ; i++) {
      assert(i < 500, 'Runde 1 kommt nicht zur Gruppenwahl');
      if (await offen(p, text('ui.karte.zur_gruppenwahl'))) break;
      if (naechste < runde1.length) {
        const d = runde1[naechste];
        const frageSichtbar = await p.getByText(d.frage, { exact: true }).count();
        if (frageSichtbar > 0 && (await offen(p, text('ui.karte.liste')))) {
          stufe = `Runde 1: Entscheidung ${naechste + 1}`;
          await tippeKnopf(anna, text('ui.karte.liste'));
          await tippe(p, p.getByRole('button', { name: d.optionen[0].text, exact: true }), `Option: ${d.optionen[0].text}`);
          await tippeKnopf(anna, text('ui.karte.ja'));
          naechste++;
          lauf.zaehler.entscheidungen++;
          continue;
        }
      }
      // Würfel: der Würfelpate am Gast-Gerät würfelt selbst, sonst die Spielleitung.
      const gast = await gastTippt(gastHandys, text('online_wuerfeln_knopf'));
      if (gast) { lauf.zaehler.gastWuerfe++; log(`${gast} würfelt für die Gruppe`); continue; }
      if (await offen(p, text('ui.zug.werfen'))) { await tippeKnopf(anna, text('ui.zug.werfen')); lauf.zaehler.gewuerfelt++; continue; }
      if (await offen(p, text('ui.zug.auftakt_weiter'))) { await tippeKnopf(anna, text('ui.zug.auftakt_weiter')); continue; }
      if (await offen(p, text('ui.karte.gelesen'))) { await tippeKnopf(anna, text('ui.karte.gelesen')); continue; }
      await p.waitForTimeout(zeit.kurz);
    }
    assert.equal(naechste, runde1.length, 'Nicht alle Entscheidungen der Runde 1 gespielt');

    // 8. Gruppenwahl: die Gäste stimmen auf ihren Geräten ab
    stufe = 'Anna: Gruppenwahl';
    await tippeKnopf(anna, text('ui.karte.zur_gruppenwahl'));
    for (const g of gastHandys) {
      stufe = `${g.name}: Gruppenwahl`;
      await warteAuf(g, () => zeigt(g.page, text('online_wahl_titel')), 'Gruppenwahl auf dem Gerät', 60000);
      const optionen = await warteAuf(g, async () => {
        const liste = await wahlOptionen(g.page);
        return liste.length === 2 ? liste : null;
      }, 'Zwei Wahlkarten');
      log(`${g.name} wählt: „${optionen[0].slice(0, 50)}“`);
      await tippe(g.page, g.page.getByRole('button', { name: optionen[0], exact: true }), `${g.name}: Wahlkarte`);
      if (g === gastHandys[0]) await fotografiere(g, 'geraete-gast-wahl-ben-390x844.png', 'Gruppenwahl Ben (geheim, nur lokal)', geheimOrdner);
      await tippeKnopf(g, text('online_wahl_abgeben'));
      await warteAuf(g, () => zeigt(g.page, text('online_wahl_abgegeben')), 'Stimme abgegeben');
    }
    stufe = 'Anna: alle gestimmt';
    await warteAuf(anna, async () => {
      const texte = await alleTexte(p);
      return texte.includes(text('ui.gruppenwahl.alle')) || texte.some(t => t === '2 von 2 Gästen haben abgestimmt' || t.startsWith('2 von 2 Gästen'));
    }, 'Alle Gäste haben abgestimmt', 60000);
    log('Gruppenwahl: beide Gäste haben abgestimmt');

    // 9. Auswertung: keine Konsolenfehler, keine fremden Anfragen, nur lokale Sockets
    stufe = 'Auswertung';
    for (const h of alle()) {
      assert.equal(h.javascript.length, 0, `${h.name}: JavaScript-Fehler ${h.javascript.join(' | ')}`);
      assert.equal(h.konsole.length, 0, `${h.name}: Konsolenfehler ${h.konsole.join(' | ')}`);
      assert.equal(h.fremd.length, 0, `${h.name}: fremde Anfragen ${h.fremd.join(' | ')}`);
      for (const socket of h.sockets) assert(socket.startsWith('ws://127.0.0.1:'), `${h.name}: fremder Socket ${socket}`);
    }
    console.log(`GERÄTE OK · 3 Handys · Raum ${code} · Rollen ${minimum} · ${lauf.zaehler.befragt} Befragungen (${lauf.zaehler.gastFragen} an Gäste) · ${lauf.zaehler.entscheidungen} Entscheidungen · ${lauf.zaehler.gastWuerfe} Gast-Würfe · Gruppenwahl von Ben und Cleo · 0 Konsolenfehler · 0 fremde Anfragen`);
  } catch (error) {
    const aufnahmen = [];
    for (const h of handys) {
      const datei = path.join(fehlerOrdner, `fehler-${h.name.toLowerCase()}.png`);
      await h.page.screenshot({ path: datei }).then(() => aufnahmen.push(datei)).catch(() => {});
    }
    console.error(`GERÄTE ROT · ${stufe} · ${String(error.message).slice(0, 1600)}${aufnahmen.length ? ` · Fehlerbilder: ${aufnahmen.map(f => path.relative(repo, f)).join(', ')}` : ''}`);
    // Diagnose: was die Semantik-Auswertung auf jedem Gerät sieht (Anfang der Liste).
    for (const h of handys) {
      const texte = await alleTexte(h.page).catch(() => []);
      console.error(`  ${h.name} · ${texte.length} Semantik-Texte: ${texte.slice(0, 30).map(t => JSON.stringify(t.slice(0, 80))).join(', ')}`);
    }
    process.exitCode = 1;
  } finally {
    for (const h of handys) await h.context.close().catch(() => {});
    await browser?.close();
    server.close();
    prozess?.kill();
  }
}

await main();
