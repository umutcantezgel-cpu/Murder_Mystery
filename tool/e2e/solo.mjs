// Echter Solo-Abend von der Detektei bis zum Ende, ohne Entwicklerroute oder PartySkript.
// Nur öffentliche Sprechblasen fotografieren, keine Dossiers oder Auflösung.
// Aufruf: node tool/e2e/solo.mjs [--nur320]
import assert from 'node:assert/strict';
import fs from 'node:fs/promises';
import path from 'node:path';
import { starteBrowser } from './browser.mjs';
import { starteServer } from './server.mjs';

const repo = path.resolve(import.meta.dirname, '../..');
const output = path.join(import.meta.dirname, 'fotos/solo');
await fs.mkdir(output, { recursive: true });
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
  assert.equal(typeof value, 'string', `Unbekannter öffentlicher Textschlüssel: ${key}`);
  return value;
};
const choices = (await readJson(`${root}/entscheidungen.json`)).entscheidungen;
const firstSuspect = (await readJson(`${root}/figuren.json`)).figuren[0].name;
const server = await starteServer(path.join(repo, 'build/web'));
const base = `http://127.0.0.1:${server.address().port}`;
const widths = process.argv.includes('--nur320') ? [320] : [320, 390];
const pictures = [];
const errors = [];
let browser;
let activePage;
let stage = 'Start';
try {
  browser = await starteBrowser();
  for (const width of widths) {
    stage = `${width} px · App-Start`;
    const page = activePage = await browser.newPage({ locale: 'de-DE', viewport: { width, height: 844 }, deviceScaleFactor: 1 });
    page.on('pageerror', () => errors.push('JavaScript'));
    page.on('console', message => { if (message.type() === 'error') errors.push('Konsole'); });
    await page.route('**/*', async route => {
      const u = new URL(route.request().url());
      if (!['127.0.0.1', 'localhost'].includes(u.hostname) && !['data:', 'blob:', 'about:'].includes(u.protocol)) {
        errors.push('Fremde Anfrage'); await route.abort();
      } else await route.continue();
    });
    // Ein Name vermeidet den Ersteinrichtungsdialog der Detektei, der sonst den Start verdeckt.
    await page.addInitScript(() => localStorage.setItem('flutter.mordakte.name', JSON.stringify('Testdetektiv')));
    await page.goto(base, { waitUntil: 'load' });
    const semantics = page.locator('flt-semantics-placeholder');
    await semantics.waitFor({ state: 'attached', timeout: 30000 });
    await semantics.evaluate(element => element.click());
    const button = key => page.getByRole('button', { name: text(key), exact: true });
    const tap = async target => {
      // Bei einem schweren Szenenwechsel kann die ausgehende Semantik länger
      // als die nominalen 350 ms bestehen. Nie einen von zwei Knöpfen raten.
      const deadline = Date.now() + 30000;
      while (await target.count() !== 1 && Date.now() < deadline) await page.waitForTimeout(100);
      assert.equal(await target.count(), 1, 'Tippfläche ist nicht eindeutig');
      await target.waitFor({ state: 'visible', timeout: 30000 });
      await target.scrollIntoViewIfNeeded();
      assert(await target.isEnabled(), 'Tippfläche ist noch gesperrt');
      // Flutter ordnet das Layout nach dem Laden noch um (die Detektei rückt beim Start um rund 77 px).
      // Erst tippen, wenn die Lage drei Messungen lang gleich bleibt; sonst trifft der Zeiger eine alte Stelle.
      let box = await target.boundingBox();
      let stabil = 0;
      const stabilEnde = Date.now() + 10000;
      while (stabil < 3 && Date.now() < stabilEnde) {
        await page.waitForTimeout(150);
        const neu = await target.boundingBox();
        stabil = neu && box && Math.abs(neu.x - box.x) < 1 && Math.abs(neu.y - box.y) < 1 ? stabil + 1 : 0;
        box = neu;
      }
      assert(box && box.width > 0 && box.height > 0, 'Sichtbare Tippfläche fehlt');
      const x = box.x + box.width / 2, y = box.y + box.height / 2;
      assert(x >= 0 && x < width && y >= 0 && y < 844, 'Tippfläche liegt außerhalb des Handys');
      // CanvasKit legt einen Scroll-Semantikknoten über die Knöpfe. Ein echter
      // Pointer geht durch den Flutter-Hittest, statt einen DOM-Klick auszulösen.
      await page.mouse.click(x, y);
      // Der echte AnimatedSwitcher bleibt aktiv; ausgehende Semantik ausblenden lassen.
      await page.waitForTimeout(420);
    };
    const click = async key => tap(button(key));
    const photo = async (name, label) => {
      const filename = `${name}-${width}.png`;
      await page.screenshot({ path: path.join(output, filename) });
      pictures.push({ filename, label: `${width} px · ${label}` });
    };
    const offer = async keys => {
      const deadline = Date.now() + 30000;
      while (Date.now() < deadline) {
        for (const key of keys) if (await button(key).isVisible()) return key;
        await page.waitForTimeout(100);
      }
      throw new Error('Kein erlaubter nächster Bedienknopf');
    };
    // Die Detektei führt über den Assistenten: Akte (vorgewählt), Spielweise, Einstellungen, Start.
    stage = `${width} px · Assistent: Akte und Spielweise`;
    await click('detektei_neuer_abend');
    await click('abend_weiter');
    await click('abend_spielweise_solo');
    await click('abend_weiter');
    stage = `${width} px · Solo einrichten`;
    for (let i = 0; i < 3; i++) await click('ui.einrichtung.weniger');
    assert.equal(await page.getByText(text('ui.solo.rollen_anzahl').replace('{anzahl}', '4'), { exact: true }).count(), 1);
    assert.equal(await button('ui.einrichtung.spiel_druck').count(), 0);
    await photo('einrichtung', 'Solo mit vier Bot-Rollen');
    await click('abend_weiter');
    await click('abend_start');
    stage = `${width} px · Bot-Karten bleiben zu`;
    await page.getByText(text('ui.solo.rollen_start'), { exact: true }).waitFor();
    assert.equal(await page.getByText(text('ui.rollen.verbirgt_titel'), { exact: true }).count(), 0);
    await click('ui.rollen.weiter');
    await click('ui.intro.weiter');
    let conversations = 0;
    let decisions = 0;
    let rolls = 0;
    for (let round = 1; round <= 3; round++) {
      stage = `${width} px · Runde ${round} · öffentliche Sprechblasen`;
      await button('ui.solo.gehoert').waitFor();
      assert.equal(await button('ui.runde.weiter').count(), 0);
      let count = 0;
      while (await button('ui.solo.gehoert').count()) {
        assert(++count <= 70, 'Sprechblasen erreichen ihr Ende nicht');
        await click('ui.solo.gehoert');
        conversations++;
        if (round === 1 && count === 1) await photo('sprechblase', 'Nur öffentliche Bot-Aussagen');
        assert.equal(await page.getByText(text('ui.rollen.verbirgt_titel'), { exact: true }).count(), 0);
      }
      assert(count >= 12, 'Pflichtgespräche fehlen');
      await click('ui.runde.weiter');
      if (round === 1) {
        stage = `${width} px · Auftaktwurf`;
        await click('ui.zug.werfen'); rolls++;
        await click('ui.zug.auftakt_weiter');
      }
      for (const decision of choices.filter(e => e.runde === round)) {
        stage = `${width} px · Runde ${round} · Kartenentscheidung ${++decisions}`;
        await page.getByText(decision.frage, { exact: true }).waitFor();
        await click('ui.karte.liste');
        await tap(page.getByRole('button', { name: decision.optionen[0].text, exact: true }));
        await click('ui.karte.ja');
        if (decisions === 1) {
          await page.getByText(text('ui.zug.weg'), { exact: true }).waitFor();
          assert.equal(await button('ui.karte.liste').count(), 0);
          await photo('laufweg', 'Echte Kartenaktion auch im Solo-Abend');
        }
        for (let attempt = 0; attempt < 8; attempt++) {
          const next = await offer(['ui.zug.werfen', 'ui.zug.umweg_knopf', 'ui.karte.gelesen']);
          if (next === 'ui.zug.werfen') rolls++;
          await click(next);
          if (next === 'ui.karte.gelesen') break;
          assert(attempt < 7, 'Zug erreicht keinen Fund');
        }
      }
      stage = `${width} px · Runde ${round} · geheime Bot-Wahl`;
      await click('ui.karte.zur_gruppenwahl');
      await page.getByText(text('ui.solo.gruppenwahl'), { exact: true }).waitFor();
      await click('ui.allgemein.weiter'); // Gruppenwahl → Bonus
      await click('ui.allgemein.weiter'); // Bonus → Resümee
      await click(round < 3 ? 'ui.resuemee.naechste_runde' : 'ui.resuemee.zur_anklage');
    }
    stage = `${width} px · Anklage und Ende`;
    // Die Anklagekarte fasst Name, Figurentitel und Hinweis in einem Knopf zusammen.
    await tap(page.getByRole('button', { name: new RegExp(`^${firstSuspect}(?:\\s|$)`) }));
    await click('ui.anklage.anklagen');
    await click('ui.anklage.ja');
    await click('ui.allgemein.weiter'); // Anklage → Finale
    await click('ui.allgemein.weiter'); // Finale → Auflösung
    await click('ui.allgemein.weiter'); // Auflösung → Ende
    // Im Abend führt das Ende über die Belohnung (Karten, Erfahrung, Rang), nicht ins Hauptmenü.
    stage = `${width} px · Belohnung`;
    await click('abend_belohnung_ansehen');
    await page.getByText('BELOHNUNG', { exact: true }).waitFor();
    await button('abend_belohnung_detektei').waitFor();
    assert.equal(decisions, 9);
    assert(rolls >= 3, 'Würfel wurden umgangen');
    assert.equal(errors.length, 0, 'Konsole oder fremde Netzaufrufe');
    console.log(`SOLO OK · ${width} px · ${conversations} Sprechblasen · 9 echte Kartenentscheidungen · ${rolls} sichtbare Würfe · 3 Bot-Wahlen · Ende erreicht`);
    await page.close();
  }
  const sheet = await browser.newPage({ viewport: { width: 1220, height: 960 }, locale: 'de-DE' });
  const images = await Promise.all(pictures.map(async ({ filename, label }) => {
    const data = (await fs.readFile(path.join(output, filename))).toString('base64');
    return `<figure><figcaption>${label}</figcaption><img src="data:image/png;base64,${data}"></figure>`;
  }));
  await sheet.setContent(`<html><body style="margin:0;background:#18151f;color:#f1ede4;font:16px sans-serif"><h2 style="margin:24px">Mordakte · Solo mit Bots</h2><main style="display:grid;grid-template-columns:repeat(3,390px);gap:18px;padding:0 12px 20px">${images.join('')}</main><style>figure{margin:0}figcaption{margin-bottom:12px}img{display:block;max-height:844px;max-width:390px}</style></body></html>`);
  await sheet.locator('img').evaluateAll(images => Promise.all(images.map(image => image.decode())));
  await sheet.screenshot({ path: path.join(output, 'kontaktbogen.png'), fullPage: true });
  await sheet.close();
  console.log(`SOLO GRÜN · ${widths.length}/${widths.length} vollständige Handy-Abende · kein PartySkript · 0 Konsolenfehler · 0 fremde Netzaufrufe`);
} catch (error) {
  await activePage?.screenshot({ path: path.join(output, 'fehler.png') }).catch(() => {});
  console.error(`SOLO ROT · ${stage} · ${String(error.message).slice(0, 1600)}`);
  process.exitCode = 1;
} finally {
  await browser?.close(); server.close();
}
