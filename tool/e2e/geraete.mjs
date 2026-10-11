// Online-Abend „Jeder am eigenen Gerät“ mit drei Handys (390 × 844), echte Zeigerereignisse:
// Gastgeberin Anna in der Detektei bis zur Lobby, Gäste Ben und Cleo über den Beitrittslink.
// Rollen lesen, Runde 1 bis zur Gruppenwahl, Gäste geben ihre Stimme ab. Relais ist die lokale
// Attrappe (server/ → dart run ../tool/e2e/attrappe.dart). Keine Anfrage außerhalb von localhost.
// Aufruf: node tool/e2e/geraete.mjs. Fotos: planung/einspiel/fotos/m2/ (Fehlerbild unter tool/e2e/fotos/geraete/).
import assert from 'node:assert/strict';
import fs from 'node:fs/promises';
import path from 'node:path';
import { spawn } from 'node:child_process';
import { starteBrowser } from './browser.mjs';
import { starteServer } from './server.mjs';

const repo = path.resolve(import.meta.dirname, '../..');
const fotos = path.join(repo, 'planung/einspiel/fotos/m2');
const fehlerOrdner = path.join(import.meta.dirname, 'fotos/geraete');
await fs.mkdir(fotos, { recursive: true });
await fs.mkdir(fehlerOrdner, { recursive: true });

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

/** Alle sichtbaren Texte und Beschriftungen der Seite in Dokumentreihenfolge. */
const alleTexte = page => page.evaluate(() => [...document.querySelectorAll('flt-semantics')]
  .map(node => (node.getAttribute('aria-label') || (node.childElementCount === 0 ? node.textContent : '') || '').trim())
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

const lauf = { schritt: '', zaehler: { gehoert: 0, gewuerfelt: 0, gastWuerfe: 0, entscheidungen: 0 } };
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

/** Name der Gäste: Wer ich bin, so wie er auf dem Dossier steht. */
async function wer(h) {
  const texte = await alleTexte(h.page);
  const i = texte.indexOf(text('online_dossier_wer'));
  if (i >= 0 && texte[i + 1]) return texte[i + 1];
  const zusammen = texte.find(t => t.startsWith(text('online_dossier_wer')));
  return zusammen ? zusammen.slice(text('online_dossier_wer').length).trim() : null;
}

/** Die beiden Antwortkarten der Gruppenwahl: die Knöpfe direkt vor „Wahl abgeben“. */
async function wahlOptionen(page) {
  return page.evaluate(label => {
    const knoepfe = [...document.querySelectorAll('flt-semantics[role="button"]')];
    const i = knoepfe.findIndex(node => (node.getAttribute('aria-label') || '').trim() === label);
    if (i < 2) return [];
    return knoepfe.slice(i - 2, i).map(node => (node.getAttribute('aria-label') || '').trim());
  }, text('online_wahl_abgeben'));
}

async function fotografiere(h, dateiname, label, ordner = fotos) {
  const datei = path.join(ordner, dateiname);
  await h.page.screenshot({ path: datei });
  log(`Foto ${label}: ${path.relative(repo, datei)}`);
}

async function main() {
  const { prozess, ws } = await starteAttrappe();
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
    await tippe(p, p.getByRole('button', { name: /Spuk im Schlosskeller/ }), 'Akte Schlosskeller');
    await tippeKnopf(anna, text('detektei_akte_spielen'));
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
      stufe = `${name}: Bereit`;
      await tippeKnopf(g, text('online_bereit_knopf'));
      await warteAuf(g, () => zeigt(g.page, text('online_bereit_zurueck')), '„Doch nicht bereit“');
    }
    // Gäste am Tisch: Anna sieht beide online und bereit.
    stufe = 'Anna: Gäste bereit';
    await warteAuf(anna, async () => {
      const texte = await alleTexte(p);
      return gaeste.every(name => texte.includes(name)) && (await offen(p, text('online_abend_starten')));
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
    const dossier = {};
    for (const g of gastHandys) {
      await warteAuf(g, () => zeigt(g.page, new RegExp(`^${escapeRe(text('online_rolle_marke'))}$`, 'i')), 'Deine Rolle', 60000);
      dossier[g.name] = await warteAuf(g, () => wer(g), 'Wer ich bin');
    }
    assert.notEqual(dossier.Ben, dossier.Cleo, 'Ben und Cleo bekommen dieselbe Rolle');
    const alleBen = await alleTexte(gastHandys[0].page);
    const alleCleo = await alleTexte(gastHandys[1].page);
    assert(!alleBen.includes(dossier.Cleo), 'Ben sieht Cleos Rolle');
    assert(!alleCleo.includes(dossier.Ben), 'Cleo sieht Bens Rolle');
    log(`Dossier Ben: „${dossier.Ben.slice(0, 60)}…“ · Cleo: „${dossier.Cleo.slice(0, 60)}…“`);
    await fotografiere(gastHandys[0], 'geraete-gast-rolle-390x844.png', 'Gastseite Rolle (Ben)');

    stufe = 'Gäste: Gelesen';
    await tippeKnopf(gastHandys[0], text('online_gelesen_knopf'));
    await warteAuf(anna, () => zeigt(anna.page, /Warten auf die Gäste: 1 von 2/), 'Gastgeberin wartet: 1 von 2');
    await fotografiere(anna, 'geraete-host-wartet-390x844.png', 'Gastgeber wartet (1 von 2 gelesen)');
    await tippeKnopf(gastHandys[1], text('online_gelesen_knopf'));
    stufe = 'Anna: Rollen weiter';
    await warteAuf(anna, () => offen(p, text('ui.rollen.weiter')), 'Rollen weiter', 60000);
    await tippeKnopf(anna, text('ui.rollen.weiter'));
    await tippeKnopf(anna, text('ui.intro.weiter'));

    // 6. Runde 1: Gespräche (Bots sprechen, Gastgeberin hört zu) bis zur Ermittlung
    stufe = 'Anna: Gespräche Runde 1';
    const weiterGespraech = text('ui.solo.gehoert');
    const rundeWeiter = text('ui.runde.weiter');
    for (let i = 0; ; i++) {
      assert(i < 120, 'Die Gespräche der Runde 1 enden nicht');
      if (await offen(p, weiterGespraech)) {
        await tippeKnopf(anna, weiterGespraech);
        lauf.zaehler.gehoert++;
      } else if (await offen(p, rundeWeiter)) {
        break;
      } else await p.waitForTimeout(zeit.kurz);
    }
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
      if (g === gastHandys[0]) await fotografiere(g, 'geraete-gast-wahl-390x844.png', 'Gruppenwahl (Ben)');
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
    console.log(`GERÄTE OK · 3 Handys · Raum ${code} · Rollen ${minimum} · ${lauf.zaehler.gehoert} Sprechblasen · ${lauf.zaehler.entscheidungen} Entscheidungen · ${lauf.zaehler.gastWuerfe} Gast-Würfe · Gruppenwahl von Ben und Cleo · 0 Konsolenfehler · 0 fremde Anfragen`);
  } catch (error) {
    const aufnahmen = [];
    for (const h of handys) {
      const datei = path.join(fehlerOrdner, `fehler-${h.name.toLowerCase()}.png`);
      await h.page.screenshot({ path: datei }).then(() => aufnahmen.push(datei)).catch(() => {});
    }
    console.error(`GERÄTE ROT · ${stufe} · ${String(error.message).slice(0, 1600)}${aufnahmen.length ? ` · Fehlerbilder: ${aufnahmen.map(f => path.relative(repo, f)).join(', ')}` : ''}`);
    process.exitCode = 1;
  } finally {
    for (const h of handys) await h.context.close().catch(() => {});
    await browser?.close();
    server.close();
    prozess.kill();
  }
}

await main();
