// Fotos der Sammelkarten für die Doku (M3): Sammlung, Deck, Assistent Schritt 4, Hand im Wurf,
// Erkundung mit Nebenfund und Belohnung. Ein echter Solo-Abend im Browser, ohne PartySkript.
// Voraussetzung: build/web, serviert auf 127.0.0.1:8099 (z. B. python3 -m http.server 8099 --bind 127.0.0.1 -d build/web).
// Aufruf: node tool/e2e/karten_fotos.mjs
import assert from 'node:assert/strict';
import fs from 'node:fs/promises';
import path from 'node:path';
import { starteBrowser } from './browser.mjs';

const repo = path.resolve(import.meta.dirname, '../..');
const output = path.join(repo, 'planung/einspiel/fotos/m3');
const base = 'http://127.0.0.1:8099/';
const readJson = async file => JSON.parse(await fs.readFile(path.join(repo, file), 'utf8'));
const arb = await readJson('lib/l10n/app_de.arb');
const root = 'content/party/schlosskeller';
const index = await readJson(`${root}/texte/index.json`);
const ui = new Map();
for (const entry of index.dateien.filter(entry => entry.bereich === 'ui')) {
  for (const item of (await readJson(`${root}/texte/${entry.datei}`)).eintraege) ui.set(item.id, item.text);
}
const text = key => ui.get(key) ?? arb[key.replace(/^ui\./, 'party_').replaceAll('.', '_')];
const choices = (await readJson(`${root}/entscheidungen.json`)).entscheidungen;
await fs.mkdir(output, { recursive: true });

const browser = await starteBrowser();
const pictures = [];
let stage = 'Start';
try {
  for (const [width, height] of [[390, 844], [320, 640]]) {
    const prefix = `${width}x${height}`;
    const context = await browser.newContext({ locale: 'de-DE', viewport: { width, height }, deviceScaleFactor: 1 });
    // Ein Name vermeidet den Ersteinrichtungsdialog der Detektei.
    await context.addInitScript(() => localStorage.setItem('flutter.mordakte.name', JSON.stringify('Testdetektiv')));
    const oeffne = async (route, bereit) => {
      const page = await context.newPage();
      await page.goto(base + route, { waitUntil: 'load' });
      const semantics = page.locator('flt-semantics-placeholder');
      await semantics.waitFor({ state: 'attached', timeout: 30000 });
      await semantics.evaluate(element => element.click());
      await bereit(page);
      await page.waitForTimeout(400);
      return page;
    };
    const photo = async (page, name, label) => {
      const filename = `${prefix}-${name}.png`;
      await page.screenshot({ path: path.join(output, filename) });
      pictures.push(`${filename} · ${label}`);
    };
    let page;
    const button = (p, key) => p.getByRole('button', { name: text(key), exact: true });
    const tap = async target => {
      const deadline = Date.now() + 30000;
      while (await target.count() !== 1 && Date.now() < deadline) await page.waitForTimeout(100);
      assert.equal(await target.count(), 1, 'Tippfläche ist nicht eindeutig');
      await target.waitFor({ state: 'visible', timeout: 30000 });
      await target.scrollIntoViewIfNeeded();
      const box = await target.boundingBox();
      assert(box && box.width > 0 && box.height > 0, 'Sichtbare Tippfläche fehlt');
      await page.mouse.click(box.x + box.width / 2, box.y + box.height / 2);
      await page.waitForTimeout(420);
    };
    const click = async key => tap(button(page, key));
    const offer = async keys => {
      const deadline = Date.now() + 30000;
      while (Date.now() < deadline) {
        for (const key of keys) if (await button(page, key).isVisible()) return key;
        await page.waitForTimeout(100);
      }
      throw new Error(`Kein erlaubter Bedienknopf: ${keys.join(', ')}`);
    };

    stage = `${prefix} · Sammlung`;
    page = await oeffne('#/sammlung', p => p.getByRole('button', { name: 'Spuk im Schlosskeller', exact: true }).waitFor());
    await photo(page, '01-sammlung', `${width}×${height} · Sammlung mit Startset`);
    await page.close();

    stage = `${prefix} · Deck`;
    page = await oeffne('#/sammlung/deck', p => p.getByRole('button', { name: text('karten_deck_fertig'), exact: true }).waitFor());
    await photo(page, '02-deck', `${width}×${height} · Dein Deck`);
    await page.close();

    stage = `${prefix} · Assistent Schritt 4`;
    page = await oeffne('#/abend/neu', p => p.getByRole('button', { name: text('abend_weiter'), exact: true }).waitFor());
    await click('abend_weiter');
    await click('abend_spielweise_solo');
    await click('abend_weiter');
    for (let i = 0; i < 3; i++) await click('ui.einrichtung.weniger');
    await click('abend_weiter');
    await page.getByText(text('abend_start_titel'), { exact: true }).waitFor();
    await page.getByText(text('karten_deck_abend_titel').toUpperCase(), { exact: true }).waitFor();
    await photo(page, '03-assistent-deck', `${width}×${height} · Schritt 4 mit Deckzeile`);

    stage = `${prefix} · Solo-Abend`;
    await click('abend_start');
    await click('ui.rollen.weiter');
    await click('ui.intro.weiter');
    let fotoHand = false;
    let fotoErkundung = false;
    for (let round = 1; round <= 3; round++) {
      stage = `${prefix} · Runde ${round} · Gespräche`;
      await button(page, 'ui.solo.gehoert').waitFor();
      let count = 0;
      while (await button(page, 'ui.solo.gehoert').count()) {
        assert(++count <= 70, 'Sprechblasen erreichen ihr Ende nicht');
        await click('ui.solo.gehoert');
      }
      await click('ui.runde.weiter');
      if (round === 1) {
        await click('ui.zug.werfen');
        await click('ui.zug.auftakt_weiter');
      }
      for (const decision of choices.filter(e => e.runde === round)) {
        stage = `${prefix} · Runde ${round} · ${decision.id ?? decision.frage}`;
        await page.getByText(decision.frage, { exact: true }).waitFor();
        await click('ui.karte.liste');
        await tap(page.getByRole('button', { name: decision.optionen[0].text, exact: true }));
        await click('ui.karte.ja');
        for (let attempt = 0; attempt < 8; attempt++) {
          const next = await offer(['ui.zug.werfen', 'ui.zug.umweg_knopf', 'ui.karte.gelesen']);
          if (next === 'ui.zug.werfen' && !fotoHand) {
            // Die Hand im Wurf: die Werkzeug-Karte leuchtet als „Jetzt spielbar“.
            assert(await page.getByRole('button', { name: /Jetzt spielbar/ }).count() >= 1, 'Keine spielbare Karte im Wurf');
            await photo(page, '04-hand-wurf', `${width}×${height} · Hand im Suchwurf`);
            fotoHand = true;
          }
          await click(next);
          if (next === 'ui.karte.gelesen') break;
          assert(attempt < 7, 'Zug erreicht keinen Fund');
        }
      }
      if (round === 1) {
        stage = `${prefix} · Erkundung`;
        const angebot = page.getByRole('button', { name: /^Erkunden: / });
        if (await angebot.count() > 0) {
          await tap(angebot.first());
          await click('karten_erkunden_los');
          await offer(['ui.zug.werfen']);
          await click('ui.zug.werfen');
          await page.getByText(text('karten_erkunden_fund').toUpperCase(), { exact: true }).waitFor();
          await photo(page, '05-erkundung', `${width}×${height} · Erkundung mit Nebenfund`);
          fotoErkundung = true;
          await click('ui.karte.gelesen');
        }
      }
      stage = `${prefix} · Runde ${round} · Gruppenwahl`;
      await click('ui.karte.zur_gruppenwahl');
      await page.getByText(text('ui.solo.gruppenwahl'), { exact: true }).waitFor();
      await click('ui.allgemein.weiter');
      await click('ui.allgemein.weiter');
      await click(round < 3 ? 'ui.resuemee.naechste_runde' : 'ui.resuemee.zur_anklage');
    }
    assert(fotoHand && fotoErkundung, 'Die Hand- oder Erkundungsfotos fehlen');
    stage = `${prefix} · Belohnung`;
    const firstSuspect = (await readJson(`${root}/figuren.json`)).figuren[0].name;
    await tap(page.getByRole('button', { name: new RegExp(`^${firstSuspect}(?:\\s|$)`) }));
    await click('ui.anklage.anklagen');
    await click('ui.anklage.ja');
    await click('ui.allgemein.weiter');
    await click('ui.allgemein.weiter');
    await click('ui.allgemein.weiter');
    await click('abend_belohnung_ansehen');
    await page.getByText('BELOHNUNG', { exact: true }).waitFor();
    await page.getByText(text('abend_belohnung_karten').toUpperCase(), { exact: true }).waitFor({ timeout: 30000 });
    await page.waitForTimeout(600);
    await photo(page, '06-belohnung', `${width}×${height} · Belohnung`);
    await context.close();
  }
  console.log(`KARTEN-FOTOS OK · ${pictures.length} Bilder in planung/einspiel/fotos/m3`);
  for (const line of pictures) console.log(line);
} catch (error) {
  console.error(`KARTEN-FOTOS ROT · ${stage} · ${String(error.message).slice(0, 1200)}`);
  process.exitCode = 1;
} finally {
  await browser.close();
}
