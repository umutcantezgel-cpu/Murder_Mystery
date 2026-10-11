// Probe „Abend abbrechen“ im Solo-Abend „Nachtexpress“ (Handygrößen 320 und 390 px):
// Die Leiste steht in der Rollenphase und an der Würfeltafel, kein Text „Kellerwürfel“ oder
// „Handy“ ist auf dem Bildschirm, Abbrechen öffnet die Rückfrage, Ja führt zur Detektei.
// Aufruf: node tool/e2e/abbrechen.mjs. Fotos unter planung/einspiel/fotos/m6/ (öffentliche Bildschirme).
import assert from 'node:assert/strict';
import fs from 'node:fs/promises';
import path from 'node:path';
import { starteBrowser } from './browser.mjs';
import { starteServer } from './server.mjs';

const repo = path.resolve(import.meta.dirname, '../..');
const output = path.join(repo, 'planung/einspiel/fotos/m6');
await fs.mkdir(output, { recursive: true });
await fs.mkdir(path.join(import.meta.dirname, 'fotos'), { recursive: true });
const readJson = async file => JSON.parse(await fs.readFile(path.join(repo, file), 'utf8'));
const arb = await readJson('lib/l10n/app_de.arb');
// Die ui-Texte des Nachtexpress ergänzen die des Schlosskellers (wie in der App).
const ui = new Map();
for (const root of ['content/party/schlosskeller', 'content/party/nachtexpress']) {
  const index = await readJson(`${root}/texte/index.json`);
  for (const entry of index.dateien.filter(entry => entry.bereich === 'ui')) {
    for (const item of (await readJson(`${root}/texte/${entry.datei}`)).eintraege) ui.set(item.id, item.text);
  }
}
const text = key => {
  const value = ui.get(key) ?? arb[key.replace(/^ui\./, 'party_').replaceAll('.', '_')];
  assert.equal(typeof value, 'string', `Unbekannter Textschlüssel: ${key}`);
  return value;
};
// Texte, die nach der Umstellung auf neutrale Würfeltexte nirgends mehr vorkommen dürfen.
const verboten = ['Kellerwürfel', 'Handy'];
const server = await starteServer(path.join(repo, 'build/web'));
const base = `http://127.0.0.1:${server.address().port}`;
const widths = [320, 390];
const errors = [];
let browser;
let activePage;
let stage = 'Start';

// Alle sichtbaren Texte: Beschriftungen der Semantik-Knoten plus Seitentext.
const sichtbareTexte = page => page.evaluate(() => [
  ...[...document.querySelectorAll('flt-semantics')].flatMap(node => {
    const label = (node.getAttribute('aria-label') || '').trim();
    if (label) return [label];
    return node.querySelector('flt-semantics') ? [] : [(node.textContent || '').trim()];
  }),
  document.body.innerText || '',
].filter(Boolean));

async function warteBis(pruefung, label, frist = 30000) {
  const ende = Date.now() + frist;
  while (Date.now() < ende) {
    if (await pruefung()) return;
    await new Promise(resolve => setTimeout(resolve, 100));
  }
  throw new Error(`Zeitüberschreitung bei „${label}“`);
}

try {
  browser = await starteBrowser();
  for (const width of widths) {
    stage = `${width} px · App-Start`;
    const page = activePage = await browser.newPage({ locale: 'de-DE', viewport: { width, height: 844 }, deviceScaleFactor: 1 });
    page.on('pageerror', error => errors.push(`${width} px JavaScript: ${error.message}`));
    page.on('console', message => { if (message.type() === 'error') errors.push(`${width} px Konsole: ${message.text()}`); });
    await page.route('**/*', async route => {
      const u = new URL(route.request().url());
      if (!['127.0.0.1', 'localhost'].includes(u.hostname) && !['data:', 'blob:', 'about:'].includes(u.protocol)) {
        errors.push(`${width} px fremde Anfrage: ${route.request().url()}`); await route.abort();
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
      // Bei Szenenwechseln kann alte Semantik kurz parallel bestehen. Nie einen von zwei Knöpfen raten.
      await warteBis(async () => await target.count() === 1, 'Tippfläche ist eindeutig');
      await target.waitFor({ state: 'visible', timeout: 30000 });
      await target.scrollIntoViewIfNeeded();
      assert(await target.isEnabled(), 'Tippfläche ist noch gesperrt');
      const box = await target.boundingBox();
      assert(box && box.width > 0 && box.height > 0, 'Sichtbare Tippfläche fehlt');
      const x = box.x + box.width / 2, y = box.y + box.height / 2;
      assert(x >= 0 && x < width && y >= 0 && y < 844, 'Tippfläche liegt außerhalb des Handys');
      // Echter Zeiger über den Flutter-Hittest, nicht ein DOM-Klick.
      await page.mouse.click(x, y);
      await page.waitForTimeout(420);
    };
    // Der Schrittname steht im Fehlerbericht, damit ein Timeout den genauen Knopf nennt.
    const click = async key => {
      stage = `${width} px · Knopf „${text(key)}“`;
      await tap(button(key));
    };
    const offen = async key => (await button(key).count()) === 1 && (await button(key).isVisible()) && (await button(key).isEnabled());
    const photo = async name => {
      await page.screenshot({ path: path.join(output, `${name}-${width}x844.png`) });
    };
    // Prüft je Bildschirm: die Leiste genau einmal, keine verbotenen Texte.
    const pruefeBildschirm = async (titel) => {
      const leiste = button('abend_abbrechen');
      await warteBis(async () => await leiste.count() === 1 && await leiste.isVisible(), `${titel}: „${text('abend_abbrechen')}“ sichtbar`);
      const texte = await sichtbareTexte(page);
      for (const wort of verboten) {
        assert(!texte.some(t => t.includes(wort)), `${titel}: verbotener Text „${wort}“ auf dem Bildschirm`);
      }
    };

    // Akte Nachtexpress, dann Solo mit Bots (wie im Assistenten: Akte, Spielweise, Einrichtung, Start).
    stage = `${width} px · Assistent: Akte Nachtexpress`;
    await click('detektei_neuer_abend');
    const akte = page.getByRole('button', { name: /Nachtexpress/ });
    stage = `${width} px · Akte „Nachtexpress“ wählen`;
    await tap(akte);
    await click('abend_weiter');
    await click('abend_spielweise_solo');
    await click('abend_weiter');
    stage = `${width} px · Solo einrichten`;
    // Auf die kleinste Besetzung herunterzählen, solange der Knopf offen ist (kürzerer Abend).
    for (let i = 0; i < 12 && await offen('ui.einrichtung.weniger'); i++) await click('ui.einrichtung.weniger');
    await click('abend_weiter');
    await click('abend_start');

    // Rollenphase: Leiste sichtbar, keine verbotenen Texte.
    stage = `${width} px · Rollenphase`;
    await page.getByText(text('ui.solo.rollen_start'), { exact: true }).waitFor({ timeout: 30000 });
    await pruefeBildschirm(`${width} px Rollenphase`);
    await click('ui.rollen.weiter');
    await click('ui.intro.weiter');

    // Runde 1: öffentliche Gespräche bis zur Würfeltafel.
    stage = `${width} px · Runde 1 · Gespräche`;
    await button('ui.solo.gehoert').waitFor({ timeout: 30000 });
    let count = 0;
    while (await button('ui.solo.gehoert').count()) {
      assert(++count <= 70, 'Sprechblasen erreichen ihr Ende nicht');
      await click('ui.solo.gehoert');
    }
    await click('ui.runde.weiter');

    // Würfeltafel: Leiste sichtbar, keine verbotenen Texte, Foto.
    stage = `${width} px · Würfeltafel`;
    await button('ui.zug.werfen').waitFor({ timeout: 30000 });
    await pruefeBildschirm(`${width} px Würfeltafel`);
    await photo('abbrechen-wuerfel');

    // Abbrechen → Rückfrage (Titel und Erklärung) → Ja → Detektei.
    stage = `${width} px · Rückfrage`;
    await click('abend_abbrechen');
    const titel = page.getByText(text('abend_abbrechen_titel'), { exact: true });
    await titel.waitFor({ state: 'visible', timeout: 30000 });
    await page.getByText(text('abend_abbrechen_text'), { exact: true }).waitFor({ state: 'visible', timeout: 30000 });
    await page.getByRole('button', { name: text('abend_abbrechen_nein'), exact: true }).waitFor({ state: 'visible', timeout: 30000 });
    await photo('abbrechen-dialog');
    stage = `${width} px · Rückfrage bestätigen`;
    const dialog = page.getByRole('dialog');
    // Die Rückfrage liegt über der Leiste, die denselben Namen trägt. Der Knopf der Rückfrage ist der letzte.
    const ja = (await dialog.count()) > 0
      ? dialog.getByRole('button', { name: text('abend_abbrechen_ja'), exact: true })
      : page.getByRole('button', { name: text('abend_abbrechen_ja'), exact: true }).last();
    await warteBis(async () => (await ja.count()) >= 1 && await ja.last().isVisible(), 'Ja-Knopf der Rückfrage');
    const jaBox = await ja.last().boundingBox();
    assert(jaBox && jaBox.width > 0 && jaBox.height > 0, 'Ja-Knopf der Rückfrage ohne Größe');
    await page.mouse.click(jaBox.x + jaBox.width / 2, jaBox.y + jaBox.height / 2);

    // Ergebnis: Detektei sichtbar, Rückfrage weg.
    stage = `${width} px · Detektei nach Abbruch`;
    await warteBis(async () => await button('detektei_neuer_abend').count() === 1, 'Detektei mit „Neuer Abend“');
    await button('detektei_neuer_abend').waitFor({ state: 'visible', timeout: 30000 });
    assert.equal(await titel.count(), 0, 'Die Rückfrage ist nach dem Abbruch noch offen');
    assert.equal(await button('abend_abbrechen').count(), 0, 'Die Abend-Leiste ist nach dem Abbruch noch da');
    assert.equal(errors.filter(e => e.startsWith(`${width} px`)).length, 0, `Konsole oder fremde Anfragen bei ${width} px: ${errors.join(' | ')}`);
    console.log(`ABBRECHEN OK · ${width} px · Leiste in Rollenphase und Würfeltafel · Rückfrage · Ja → Detektei`);
    await page.close();
  }
  assert.equal(errors.length, 0, `Konsole oder fremde Anfragen: ${errors.join(' | ')}`);
  console.log(`ABBRECHEN GRÜN · ${widths.length}/${widths.length} Handygrößen · 0 Konsolenfehler · 0 fremde Netzaufrufe · Fotos ${path.relative(repo, output)}`);
} catch (error) {
  await activePage?.screenshot({ path: path.join(import.meta.dirname, 'fotos/abbrechen-fehler.png') }).catch(() => {});
  console.error(`ABBRECHEN ROT · ${stage} · ${String(error.message).slice(0, 1600)}`);
  process.exitCode = 1;
} finally {
  await browser?.close();
  server.close();
}
