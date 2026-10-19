// Online-Abend mit Sitzen (Langer Abend M3b), drei Handys (390 × 844), echte Zeigerereignisse:
// Gastgeberin Anna wählt in der Einrichtung „Dein Platz: Erzähler“. In der Lobby teilt sie zu:
// Ben bekommt den Detektiv-Sitz, Cleo eine feste Figur. Danach die Privatsphäre-Matrix je Abschnitt:
// - Erzähltext (Auftakt, Rundenstart, Wissen ungespielter Gäste) steht vor dem Finale nur bei Anna;
//   Ben und Cleo sehen „Anna liest vor.“
// - Das Wissen ungespielter Gäste hat Ben als Notiz im Notizbuch (E-044), Cleo nie.
// - Dossierzeilen nur bei Cleo; Anna und Ben sehen nie, was Cleo verbirgt; Ben nie Cleos Spickzettel.
// - Ben befragt am eigenen Gerät, Cleo sieht die Frage, Anna führt vom Pult weiter.
// - Ben wählt die erste Spur, Anna sieht die Zuschauerkarte und keine Wahl.
// Relais ist die lokale Attrappe (server/ → dart run ../tool/e2e/attrappe.dart). Nur localhost.
// Aufruf: node tool/e2e/erzaehler.mjs. Eine laufende Attrappe nimmt MORDAKTE_RELAIS=ws://127.0.0.1:4455.
// Fotos ohne geheime Texte und Fehlerbilder: tool/e2e/fotos/erzaehler/ (gitignoriert).
import assert from 'node:assert/strict';
import fs from 'node:fs/promises';
import path from 'node:path';
import { spawn } from 'node:child_process';
import { befragungenFuehren } from './befragung.mjs';
import { starteBrowser } from './browser.mjs';
import { starteServer } from './server.mjs';

const repo = path.resolve(import.meta.dirname, '../..');
const ordner = path.join(import.meta.dirname, 'fotos/erzaehler');
await fs.mkdir(ordner, { recursive: true });

const readJson = async file => JSON.parse(await fs.readFile(path.join(repo, file), 'utf8'));
const arb = await readJson('lib/l10n/app_de.arb');
const root = 'content/party/schlosskeller';
const index = await readJson(`${root}/texte/index.json`);
const eintraege = async bereich => {
  const out = [];
  for (const e of index.dateien.filter(e => e.bereich === bereich)) out.push(...(await readJson(`${root}/texte/${e.datei}`)).eintraege);
  return out;
};
const ui = new Map((await eintraege('ui')).map(e => [e.id, e.text]));
const text = (key, werte = {}) => {
  let value = ui.get(key) ?? arb[key.replace(/^ui\./, 'party_').replaceAll('.', '_')];
  assert.equal(typeof value, 'string', `Unbekannter Textschlüssel: ${key}`);
  for (const [k, v] of Object.entries(werte)) value = value.replaceAll(`{${k}}`, v);
  return value;
};
const erzaehlung = new Map((await eintraege('erzaehler')).map(e => [e.id, e.text]));
const dossiere = await eintraege('dossier');
const taeter = new Map((await eintraege('taeter')).map(t => [t.rolle, t]));
const befragungen = new Map((await eintraege('befragung')).map(b => [b.id, b]));
const choices = (await readJson(`${root}/entscheidungen.json`)).entscheidungen;
const figuren = await readJson(`${root}/figuren.json`);
const escapeRe = s => s.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');

const WIDTH = 390;
const HEIGHT = 844;
const zeit = { kurz: 150, tap: 420 };
/** Cleos Figur: eine der vier Kernrollen, fest zugeteilt. */
const CLEO_FIGUR = 'fatma';

/** Name einer Figur aus dem Kanon. */
function figurName(id) {
  let name = null;
  const suche = x => {
    if (name || !x || typeof x !== 'object') return;
    if (x.id === id && typeof x.name === 'string') { name = x.name; return; }
    for (const v of Object.values(x)) suche(v);
  };
  suche(figuren);
  assert(name, `Figur ${id} ohne Namen`);
  return name;
}

// ---------------------------------------------------------------- Attrappe

function starteAttrappe() {
  const prozess = spawn(process.env.MORDAKTE_DART ?? 'dart', ['run', '../tool/e2e/attrappe.dart', '0'], { cwd: path.join(repo, 'server'), env: process.env });
  let puffer = '';
  return new Promise((ok, fail) => {
    const frist = setTimeout(() => fail(new Error('Attrappe ist nach 180 s nicht bereit')), 180000);
    prozess.stdout.on('data', data => {
      puffer += data;
      const treffer = puffer.match(/Attrappe läuft: ws:\/\/127\.0\.0\.1:(\d+)/);
      if (treffer) { clearTimeout(frist); ok({ prozess, ws: `ws://127.0.0.1:${treffer[1]}` }); }
    });
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

async function tippe(page, ziel, label, warten = 30000) {
  const frist = Date.now() + warten;
  while ((await ziel.count()) !== 1 && Date.now() < frist) await page.waitForTimeout(100);
  assert.equal(await ziel.count(), 1, `Tippfläche ist nicht eindeutig: ${label}`);
  await ziel.waitFor({ state: 'visible', timeout: warten });
  await inSicht(page, ziel);
  const frist2 = Date.now() + warten;
  while (!(await ziel.isEnabled({ timeout: warten })) && Date.now() < frist2) await page.waitForTimeout(100);
  assert(await ziel.isEnabled(), `Tippfläche bleibt gesperrt: ${label}`);
  // Das Rollen in die Sicht läuft über die Semantik und braucht einige Bilder:
  // erst tippen, wenn die Lage drei Messungen lang gleich bleibt (wie solo.mjs).
  let box = await ziel.boundingBox();
  let stabil = 0;
  const stabilEnde = Date.now() + 10000;
  while (stabil < 3 && Date.now() < stabilEnde) {
    await page.waitForTimeout(150);
    const neu = await ziel.boundingBox();
    stabil = neu && box && Math.abs(neu.x - box.x) < 1 && Math.abs(neu.y - box.y) < 1 ? stabil + 1 : 0;
    box = neu;
  }
  assert(box && box.width > 0 && box.height > 0, `Tippfläche ohne Größe: ${label}`);
  const x = box.x + box.width / 2;
  const y = box.y + box.height / 2;
  assert(x >= 0 && x < WIDTH && y >= 0 && y < HEIGHT, `Tippfläche liegt außerhalb des Handys: ${label}`);
  // Echter Zeiger über den Flutter-Hittest, nicht ein DOM-Klick.
  await page.mouse.click(x, y);
  await page.waitForTimeout(zeit.tap);
}

/**
 * Rollt die Flutter-Ansicht mit dem Mausrad, bis die Mitte von [ziel] frei im Bild
 * liegt (nicht unter der Knopfleiste unten). Ein DOM-Rollen der Semantik bewegt die
 * Zeichenfläche nicht mit; der Zeiger träfe dann eine alte Stelle.
 */
async function inSicht(page, ziel) {
  const { width, height } = page.viewportSize();
  let letzte = null;
  for (let i = 0; i < 40; i++) {
    // Verschwindet die Fläche (neue Ansicht), entscheidet der Aufrufer neu.
    const box = await ziel.boundingBox({ timeout: 3000 }).catch(() => null);
    if (!box) return;
    const y = box.y + box.height / 2;
    if (y >= 70 && y <= height - 110) return;
    // Steht der Knopf fest (Leiste unten), ändert das Rollen nichts an seiner Lage.
    if (letzte !== null && Math.abs(letzte - y) < 1 && y >= 0 && y < height) return;
    letzte = y;
    await page.mouse.move(width / 2, height / 2);
    await page.mouse.wheel(0, y < 70 ? -250 : 250);
    await page.waitForTimeout(220);
  }
}

const tippeKnopf = (h, name) => tippe(h.page, knopf(h.page, name), `${h.name}: ${name}`);

/** Rollt, bis [ziel] genau einmal in der Semantik steht (unten liegende Karten baut Flutter erst beim Rollen). */
async function rolleBis(h, ziel, label, schritte = 16) {
  const { width, height } = h.page.viewportSize();
  await h.page.mouse.move(width / 2, height / 2);
  for (let i = 0; i < schritte && (await ziel.count()) !== 1; i++) {
    await h.page.mouse.wheel(0, 350);
    await h.page.waitForTimeout(220);
  }
  assert.equal(await ziel.count(), 1, `${h.name}: „${label}“ nicht gefunden`);
}

async function warteAuf(h, pruefung, label, frist = 30000) {
  const ende = Date.now() + frist;
  while (Date.now() < ende) {
    const ergebnis = await pruefung();
    if (ergebnis) return ergebnis;
    await h.page.waitForTimeout(zeit.kurz);
  }
  throw new Error(`${h.name}: Zeitüberschreitung bei „${label}“`);
}

/** Alle sichtbaren Texte und Beschriftungen der Seite (aria-label, sonst Text eines Blattknotens). */
const alleTexte = page => page.evaluate(() => [...document.querySelectorAll('flt-semantics')]
  .flatMap(node => {
    const label = (node.getAttribute('aria-label') || '').trim();
    if (label) return [label];
    return node.querySelector('flt-semantics') ? [] : [(node.textContent || '').trim()];
  })
  .filter(Boolean));

/** Alle Texte der ganzen Seite: von oben nach unten gerollt, danach wieder oben. */
async function ganzeSeite(h, schritte = 24) {
  const p = h.page;
  const { width, height } = p.viewportSize();
  await p.mouse.move(width / 2, height / 2);
  for (let i = 0; i < 4; i++) await p.mouse.wheel(0, -4000);
  await p.waitForTimeout(250);
  const gesehen = new Set(await alleTexte(p));
  let gleich = 0;
  for (let i = 0; i < schritte && gleich < 3; i++) {
    await p.mouse.wheel(0, 420);
    await p.waitForTimeout(220);
    const vorher = gesehen.size;
    for (const t of await alleTexte(p)) gesehen.add(t);
    gleich = gesehen.size === vorher ? gleich + 1 : 0;
  }
  for (let i = 0; i < 4; i++) await p.mouse.wheel(0, -4000);
  await p.waitForTimeout(250);
  return [...gesehen];
}

/** Steht [muster] im Bild: als Text oder in einer Beschriftung (Titel einer Karte stehen nur im aria-label)? */
const zeigt = async (page, muster) => (await page.getByText(muster).count()) > 0
  || (typeof muster === 'string' && (await alleTexte(page)).some(t => t.includes(muster)));
const norm = s => s.replace(/\s+/g, ' ').trim();
const kopf = t => norm(t).slice(0, 40);
const enthaelt = (texte, satz) => norm(texte.join('\n')).includes(kopf(satz));
const zeilen = liste => (liste ?? []).map(z => (typeof z === 'string' ? z : z?.text)).filter(t => typeof t === 'string');

/** Geheime Zeilen eines Dossiers: was die Figur verbirgt, ihre Tarngeschichte und ihr Tatwissen (ab 20 Zeichen). */
const geheim = e => [e.tarnung, ...zeilen(e.verbirgt), ...zeilen(e.tatwissen)].filter(t => typeof t === 'string').map(norm).filter(t => t.length >= 20);
/** Alle privaten Zeilen eines Dossiers (dazu Wer ich bin, Ziel, Was ich weiß). */
const privat = e => [e.wer, e.ziel, ...zeilen(e.weiss), ...geheim(e)].filter(t => typeof t === 'string').map(norm).filter(t => t.length >= 20);

function sieht(h, texte, satz, label) {
  assert(enthaelt(texte, satz), `${h.name} sieht ${label} nicht: „${kopf(satz)}…“`);
}
function siehtNie(h, texte, satz, label) {
  assert(!enthaelt(texte, satz), `${h.name} sieht ${label}: „${kopf(satz)}…“`);
}

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

async function fotografiere(h, name) {
  const datei = path.join(ordner, `${name}.png`);
  await h.page.screenshot({ path: datei });
  log(`Foto: ${path.relative(repo, datei)}`);
}

const log = text => console.log(`· ${text}`);
const zaehler = { pruefungen: 0, befragt: 0, cleoGefragt: 0, npc: 0, wuerfe: 0 };
const geprueft = (n = 1) => { zaehler.pruefungen += n; };

/** Tippt [name] bei [h], wenn der Knopf noch da ist; verschwindet er dazwischen (neue Ansicht), zählt es nicht. */
async function tippeWennDa(h, name) {
  if (!(await offen(h.page, name))) return false;
  try {
    await tippe(h.page, knopf(h.page, name), `${h.name}: ${name}`, 5000);
    return true;
  } catch (error) {
    log(`${h.name}: „${name}“ nicht getippt (${String(error.message).split('\n')[0].slice(0, 120)})`);
    return false;
  }
}

/** Würfeln (der Würfelpate an einem Gast-Gerät), Auftakt und Funde bis zur Frage [frage] bei Ben. */
async function zugBisFrage(ben, gaeste, frage, label) {
  const ende = Date.now() + 240000;
  for (let i = 0; i < 400 && Date.now() < ende; i++) {
    // Die Frage steht als Kopf des Blatts in Großbuchstaben bei Ben (aus „ß“ wird „SS“).
    if (frage && (await alleTexte(ben.page)).some(t => norm(t).toUpperCase() === norm(frage).toUpperCase())) return;
    let getan = false;
    for (const g of gaeste) {
      if (await tippeWennDa(g, text('online_wuerfeln_knopf'))) {
        log(`${g.name} würfelt`);
        zaehler.wuerfe++;
        getan = true;
      }
    }
    if (getan) continue;
    for (const name of [text('ui.zug.auftakt_weiter'), text('ui.karte.gelesen'), text('ui.zug.umweg_knopf')]) {
      if (await tippeWennDa(ben, name)) {
        log(`Ben: ${name}`);
        getan = true;
        break;
      }
    }
    if (!getan && !frage && (await zeigt(ben.page, text('ui.karte.fertig')))) return;
    if (!getan) await ben.page.waitForTimeout(zeit.kurz);
  }
  throw new Error(`Ben: ${label} kommt nicht`);
}

async function main() {
  const vorhanden = process.env.MORDAKTE_RELAIS?.trim();
  const { prozess, ws } = vorhanden ? { prozess: null, ws: vorhanden } : await starteAttrappe();
  assert(/^ws:\/\/127\.0\.0\.1:\d+$/.test(ws), `Relais muss lokal sein: ${ws}`);
  log(`Attrappe: ${ws}`);
  const server = await starteServer(path.join(repo, 'build/web'));
  const base = `http://127.0.0.1:${server.address().port}`;
  const relay = encodeURIComponent(ws);
  const handys = [];
  let browser;
  let stufe = 'Start';
  try {
    browser = await starteBrowser();

    // 1. Anna: Detektei → Akte → Spielweise → Einstellungen mit „Dein Platz: Erzähler“ → Raum öffnen
    stufe = 'Anna: Einrichtung';
    const anna = await oeffneHandy(browser, 'Anna', `${base}/?semantik=1&name=Anna&relay=${relay}`, log);
    handys.push(anna);
    const p = anna.page;
    await warteAuf(anna, () => knopf(p, text('detektei_neuer_abend')).isVisible().catch(() => false), 'Detektei');
    await tippeKnopf(anna, text('detektei_neuer_abend'));
    await warteAuf(anna, () => offen(p, text('abend_weiter')), 'Akte-Schritt');
    await tippe(p, p.getByRole('button', { name: /Spuk im Schlosskeller/ }), 'Akte Schlosskeller');
    await tippeKnopf(anna, text('abend_weiter'));
    await tippe(p, p.getByRole('button', { name: new RegExp(`^${escapeRe(text('abend_spielweise_eigene'))}`) }), 'Spielweise');
    await tippeKnopf(anna, text('abend_weiter'));
    stufe = 'Anna: Dein Platz Erzähler';
    await warteAuf(anna, () => offen(p, text('abend_weiter')), 'Einstellungen');
    const erzaehlerPlatz = knopf(p, text('abend_platz_erzaehler'));
    await rolleBis(anna, erzaehlerPlatz, 'Dein Platz: Erzähler');
    await tippe(p, erzaehlerPlatz, 'Anna: Dein Platz Erzähler');
    await warteAuf(anna, () => zeigt(p, text('abend_platz_hinweis_erzaehler')), 'Hinweis zum Erzähler-Platz');
    geprueft();
    await tippeKnopf(anna, text('abend_weiter'));
    await tippeKnopf(anna, text('online_raum_oeffnen'));

    // 2. Lobby: Raumcode, Gäste treten bei
    stufe = 'Anna: Lobby';
    const code = await warteAuf(anna, async () => {
      const treffer = (await alleTexte(p)).map(t => t.match(/Raumcode ([A-Z0-9]{3}-[A-Z0-9]{3})/)).find(Boolean);
      return treffer?.[1] ?? null;
    }, 'Raumcode', 60000);
    log(`Raumcode ${code}`);
    const gaeste = {};
    for (const name of ['Ben', 'Cleo']) {
      stufe = `${name}: Beitritt`;
      const g = await oeffneHandy(browser, name, `${base}/?semantik=1&name=${name}&relay=${relay}#/beitreten?raum=${code.replace('-', '')}`, log);
      handys.push(g);
      gaeste[name] = g;
      await warteAuf(g, () => zeigt(g.page, text('online_beitreten_titel')), 'Beitreten-Seite');
      await tippeKnopf(g, text('online_beitreten_los'));
      await warteAuf(g, () => zeigt(g.page, text('online_gast_lobby_titel')), 'Warten auf den Start', 60000);
      await tippeKnopf(g, text('online_bereit_knopf'));
    }
    const { Ben: ben, Cleo: cleo } = gaeste;

    // 3. Zuteilung: Ohne Detektiv startet nichts. Ben bekommt den Detektiv-Sitz, Cleo eine feste Figur.
    stufe = 'Anna: ohne Detektiv kein Start';
    await warteAuf(anna, async () => (await alleTexte(p)).some(t => t.includes('Ben')) && (await alleTexte(p)).some(t => t.includes('Cleo')), 'Ben und Cleo am Tisch', 60000);
    assert(!(await offen(p, text('online_abend_starten'))), '„Abend starten“ ist ohne Detektiv frei');
    await rolleBis(anna, p.getByText(text('online_lobby_detektiv_fehlt')), 'Hinweis „Wähle zuerst, wer ermittelt“');
    geprueft(2);
    const platzVon = name => p.getByRole('button', { name: new RegExp(`^${name}\\b`) });
    stufe = 'Anna: Ben ermittelt';
    await rolleBis(anna, platzVon('Ben'), 'Platz von Ben');
    await tippe(p, platzVon('Ben'), 'Anna: Platz von Ben');
    await warteAuf(anna, () => zeigt(p, text('online_lobby_wahl_titel', { name: 'Ben' })), 'Karte „Platz und Figur: Ben“');
    await tippe(p, knopf(p, text('abend_platz_detektiv')), 'Anna: Ben auf den Detektiv-Sitz');
    stufe = 'Ben: Dein Platz Detektiv';
    await warteAuf(ben, () => zeigt(ben.page, text('online_gast_detektiv_text')), '„Du ermittelst heute“', 30000);
    geprueft();
    // Ein neuer Sitz nimmt das Bereit zurück.
    await warteAuf(ben, () => offen(ben.page, text('online_bereit_knopf')), 'Bereit nach dem Sitzwechsel');
    await tippeKnopf(ben, text('online_bereit_knopf'));
    stufe = `Anna: Cleo spielt ${CLEO_FIGUR}`;
    const fatma = figurName(CLEO_FIGUR);
    await rolleBis(anna, platzVon('Cleo'), 'Platz von Cleo');
    await tippe(p, platzVon('Cleo'), 'Anna: Platz von Cleo');
    await warteAuf(anna, () => zeigt(p, text('online_lobby_wahl_titel', { name: 'Cleo' })), 'Karte „Platz und Figur: Cleo“');
    const figurKachel = p.getByRole('button', { name: new RegExp(`^${escapeRe(fatma)}(,|$)`) });
    await rolleBis(anna, figurKachel, `Figur ${fatma}`);
    await tippe(p, figurKachel, `Anna: Cleo spielt ${fatma}`);
    stufe = 'Cleo: Deine Figur';
    await warteAuf(cleo, () => zeigt(cleo.page, fatma), `Cleo sieht ihre Figur ${fatma}`, 30000);
    await warteAuf(cleo, () => offen(cleo.page, text('online_bereit_knopf')), 'Bereit nach der Zuteilung');
    await tippeKnopf(cleo, text('online_bereit_knopf'));
    geprueft();
    stufe = 'Anna: Abend starten';
    await warteAuf(anna, () => offen(p, text('online_abend_starten')), '„Abend starten“ frei', 60000);
    await fotografiere(anna, 'host-lobby-zuteilung-390x844');
    await tippeKnopf(anna, text('online_abend_starten'));

    // 4. Rollen: Cleo liest ihr Dossier (die zugeteilte Figur), Ben die Detektivkarte, Anna keins.
    stufe = 'Rollen';
    const dossier = await warteAuf(cleo, async () => {
      const texte = await alleTexte(cleo.page);
      const alles = norm(texte.join('\n'));
      const e = dossiere.find(d => typeof d.wer === 'string' && alles.includes(norm(d.wer)));
      if (!e) return null;
      const istTaeter = texte.some(t => t === text('online_dossier_tarnung')) && taeter.has(e.rolle);
      return istTaeter ? { ...e, ...taeter.get(e.rolle) } : e;
    }, 'Cleos Dossier', 60000);
    assert.equal(dossier.rolle, CLEO_FIGUR, `Cleo spielt ${dossier.rolle} statt der zugeteilten ${CLEO_FIGUR}`);
    log(`Cleo: Dossier ${dossier.rolle}${dossier.tarnung ? ' (Täterfassung)' : ''}`);
    await warteAuf(ben, () => zeigt(ben.page, text('detektiv_karte_titel')), 'Bens Detektivkarte', 60000);
    const cleoGeheim = geheim(dossier);
    const cleoPrivat = privat(dossier);
    const sichtAnna = await ganzeSeite(anna);
    const sichtBen = await ganzeSeite(ben);
    for (const z of cleoPrivat) {
      siehtNie(anna, sichtAnna, z, 'eine Dossierzeile von Cleo');
      siehtNie(ben, sichtBen, z, 'eine Dossierzeile von Cleo');
    }
    assert(sichtBen.some(t => t === text('online_sitz_rollen')), 'Ben: Hinweis „Alle lesen ihre Rolle“ fehlt');
    geprueft(cleoPrivat.length * 2 + 3);
    log(`Rollen: Cleo ${dossier.rolle}, Anna und Ben ohne Cleos Dossier (${cleoPrivat.length} Zeilen)`);
    await tippeKnopf(cleo, text('online_gelesen_knopf'));
    stufe = 'Anna: Rollen weiter';
    await warteAuf(anna, () => offen(p, text('ui.rollen.weiter')), 'Rollen weiter', 60000);
    await tippeKnopf(anna, text('ui.rollen.weiter'));

    // 5. Auftakt: nur Anna liest; Ben und Cleo sehen „Anna liest vor.“
    stufe = 'Auftakt';
    const intro = erzaehlung.get('intro.start');
    await warteAuf(anna, () => zeigt(p, kopf(intro)), 'Auftakt bei Anna', 60000);
    for (const g of [ben, cleo]) {
      await warteAuf(g, () => zeigt(g.page, text('vorleser_liest', { name: 'Anna' })), `„Anna liest vor.“ bei ${g.name}`, 60000);
      siehtNie(g, await ganzeSeite(g), intro, 'den Auftakt');
    }
    geprueft(3);
    await fotografiere(ben, 'gast-detektiv-auftakt-390x844');
    await tippeKnopf(anna, text('ui.intro.weiter'));

    // 6. Runde 1: Anna am Pult (Rundenstart, Paket), Ben befragt, Cleo sieht die Frage.
    stufe = 'Runde 1: Pult';
    const start = erzaehlung.get('runde.1.start');
    await warteAuf(anna, () => zeigt(p, kopf(start)), 'Rundenstart am Pult', 60000);
    await warteAuf(anna, () => zeigt(p, text('erzaehler_paket_titel').toUpperCase()), 'Erzählerpaket am Pult', 30000);
    await warteAuf(ben, () => zeigt(ben.page, text('ui.befragung.titel').toUpperCase()), 'Bens Befragungen', 60000);
    {
      const a = await ganzeSeite(anna);
      sieht(anna, a, start, 'den Rundenstart');
      for (const z of cleoGeheim) siehtNie(anna, a, z, 'was Cleo verbirgt');
      const npc = [...erzaehlung.entries()].filter(([id, t]) => /^npc\..+\.1$/.test(id) && enthaelt(a, t)).map(([, t]) => t);
      zaehler.npc = npc.length;
      const b = await ganzeSeite(ben);
      const c = await ganzeSeite(cleo);
      for (const [h, s] of [[ben, b], [cleo, c]]) siehtNie(h, s, start, 'den Rundenstart');
      // Das Wissen ungespielter Gäste: am Pult als Erzähltext, bei Ben als Notiz, bei Cleo nie.
      for (const t of npc) {
        sieht(ben, b, t, 'die Notiz zu einem ungespielten Gast');
        siehtNie(cleo, c, t, 'Erzählerwissen');
      }
      for (const z of cleoPrivat) siehtNie(ben, b, z, 'eine Dossierzeile von Cleo');
      geprueft(1 + cleoGeheim.length + 2 + npc.length * 2 + cleoPrivat.length);
      log(`Runde 1: Rundenstart nur am Pult, ${npc.length} Notizen zu ungespielten Gästen nur bei Anna und Ben`);
    }
    await fotografiere(anna, 'host-erzaehler-pult-390x844');
    stufe = 'Runde 1: Ben befragt';
    const pultWeiter = text('ui.allgemein.weiter');
    assert(!(await offen(p, pultWeiter)), 'Weiter am Pult ist vor den Befragungen frei');
    const befragung = await befragungenFuehren(ben.page, {
      tippe: (ziel, label) => tippe(ben.page, ziel, `Ben: ${label}`),
      fertig: () => offen(p, pultWeiter),
      nachFrage: async id => {
        const b = befragungen.get(id);
        assert(b, `Unbekannte Befragung ${id}`);
        // Die Karte zeigt die Frage gleich als gestellt; kein zweiter Tipp.
        await warteAuf(ben, async () => (await ben.page.locator(`flt-semantics[flt-semantics-identifier="befragung-frage-${id}-0"]`).count()) === 0, `Frage an ${b.rolle} gestellt`);
        if (b.rolle !== CLEO_FIGUR) return;
        stufe = 'Cleo: Frage des Detektivs';
        const frage = text('party_befragung_fragt', { frage: b.fragen[0] });
        await warteAuf(cleo, () => zeigt(cleo.page, frage), `„${frage}“ bei Cleo`);
        zaehler.cleoGefragt++;
        // Was Cleo antwortet, sagt sie am Tisch: nie auf Bens Gerät.
        const sicht = await alleTexte(ben.page);
        for (const z of b.stichpunkte ?? []) siehtNie(ben, sicht, z, 'Cleos Spickzettel');
        geprueft(1 + (b.stichpunkte ?? []).length);
        stufe = 'Runde 1: Ben befragt';
      },
    });
    assert(befragung.fragen >= 3 && befragung.fragen <= 5, `Runde 1: ${befragung.fragen} Befragungen statt drei bis fünf`);
    zaehler.befragt = befragung.fragen;
    log(`Ben befragt ${befragung.fragen} (davon Cleo ${zaehler.cleoGefragt}, ${befragung.gewaehlt} frei gewählt)`);
    stufe = 'Anna: Weiter am Pult';
    await tippeKnopf(anna, pultWeiter);

    // 7. Ermittlung: Ben wählt die erste Spur; Anna sieht die Zuschauerkarte und wählt nichts.
    stufe = 'Ermittlung';
    const e1 = choices.filter(e => e.runde === 1)[0];
    await warteAuf(anna, () => zeigt(p, text('erzaehler_zuschauer_titel').toUpperCase()).then(ja => ja || zeigt(p, text('erzaehler_zuschauer_titel'))), 'Zuschauerkarte am Pult', 60000);
    await zugBisFrage(ben, [ben, cleo], e1.frage, 'die erste Frage');
    const option = e1.optionen[0];
    const optionKnopf = ben.page.getByRole('button', { name: new RegExp(`^${escapeRe(option.text)}`) });
    await rolleBis(ben, optionKnopf, `Option „${option.text}“`);
    // Die Frage ist öffentlich, die Wahl nicht: Nur Ben hat Knöpfe dafür.
    for (const h of [anna, cleo]) {
      assert.equal(await h.page.getByRole('button', { name: new RegExp(`^${escapeRe(option.text)}`) }).count(), 0, `${h.name} kann eine Spur wählen`);
    }
    await tippe(ben.page, optionKnopf, `Ben: ${option.text}`);
    await tippeKnopf(ben, text('ui.karte.ja'));
    await fotografiere(anna, 'host-zuschauerkarte-390x844');
    // Der Weg läuft auf Bens Karte; danach Wurf und Fund, bis die Runde ihre nächste Frage stellt.
    const e2 = choices.filter(e => e.runde === 1)[1];
    await zugBisFrage(ben, [ben, cleo], e2?.frage, 'die zweite Frage');
    geprueft(3);
    log(`Ermittlung: Ben wählt „${option.text.slice(0, 40)}“, ${zaehler.wuerfe} Würfe am Gast-Gerät`);

    // 8. Auswertung: keine Konsolenfehler, keine fremden Anfragen, nur lokale Sockets
    stufe = 'Auswertung';
    for (const h of handys) {
      assert.equal(h.javascript.length, 0, `${h.name}: JavaScript-Fehler ${h.javascript.join(' | ')}`);
      assert.equal(h.konsole.length, 0, `${h.name}: Konsolenfehler ${h.konsole.join(' | ')}`);
      assert.equal(h.fremd.length, 0, `${h.name}: fremde Anfragen ${h.fremd.join(' | ')}`);
      for (const socket of h.sockets) assert(socket.startsWith('ws://127.0.0.1:'), `${h.name}: fremder Socket ${socket}`);
    }
    console.log(`ERZÄHLER OK · 3 Handys · Raum ${code} · Anna erzählt, Ben ermittelt, Cleo spielt ${dossier.rolle} · ${zaehler.befragt} Befragungen (Cleo ${zaehler.cleoGefragt}) · ${zaehler.npc} Notizen ungespielter Gäste · ${zaehler.pruefungen} Privatsphäre-Prüfungen · 0 Konsolenfehler · 0 fremde Anfragen`);
  } catch (error) {
    const aufnahmen = [];
    for (const h of handys) {
      const datei = path.join(ordner, `fehler-${h.name.toLowerCase()}.png`);
      await h.page.screenshot({ path: datei }).then(() => aufnahmen.push(datei)).catch(() => {});
    }
    console.error(`ERZÄHLER ROT · ${stufe} · ${String(error.message).slice(0, 1600)}${aufnahmen.length ? ` · Fehlerbilder: ${aufnahmen.map(f => path.relative(repo, f)).join(', ')}` : ''}`);
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
