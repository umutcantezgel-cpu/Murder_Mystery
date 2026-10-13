// Probe „Abend abbrechen“ im Solo-Abend „Nachtexpress“ (Handygrößen 320 und 390 px):
// Die Leiste steht in der Rollenphase, an der Würfeltafel und nach dem Probewurf. Auf diesen
// Bildschirmen steht kein „Kellerwürfel“, „Handy“ oder „Seifenblasen“, und die Würfeltafel zeigt
// ihren neutralen Titel und die Stufen. Abbrechen öffnet die Rückfrage (Titel und Erklärung).
// Die Browser-Zurück-Taste fragt ebenfalls nach; „Weiterspielen“ lässt den Abend, wie er war; Ja führt
// zur Detektei. Ein Befund im Browser-Verlauf (zusätzlicher Eintrag nach „Weiterspielen“) macht die Probe
// rot; er ist ein Produktbefund, kein Testfehler. Aufruf: node tool/e2e/abbrechen.mjs. Fotos unter planung/einspiel/fotos/m6/ (öffentliche Bildschirme).
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
// Texte, die nach der Umstellung auf neutrale Würfeltexte auf keinem dieser Bildschirme vorkommen dürfen.
// „Seifenblasen“ war der alte Name der Marke („Seifenblasen-Marke +1“), jetzt heißt sie „Marke“.
const verboten = ['Kellerwürfel', 'Handy', 'Seifenblasen'];
// Die neutralen Würfeltexte: Titel der Tafel und die drei Stufen.
const wuerfelTexte = ['ui.zug.wuerfel', 'ui.zug.erfolg', 'ui.zug.teilerfolg', 'ui.zug.pech'].map(key => text(key));
const server = await starteServer(path.join(repo, 'build/web'));
const base = `http://127.0.0.1:${server.address().port}`;
const widths = [320, 390];
const errors = [];
// Produktbefunde des Browser-Verlaufs: Sie laufen am Ende als Fehler, damit die Probe nicht grün wird.
const befunde = [];
// Adresse des laufenden Abends (Routes.abend in lib/app/router.dart).
const abendAdresse = '#/abend';
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
      // Flutter ordnet das Layout nach dem Laden und nach dem Scrollen noch um (die Detektei rückt
      // beim Start um rund 77 px). Erst tippen, wenn die Lage drei Messungen lang gleich bleibt;
      // sonst trifft der Zeiger eine Stelle, an der der Knopf nicht mehr steht.
      let box = await target.boundingBox();
      let stabil = 0;
      const ende = Date.now() + 10000;
      while (stabil < 3 && Date.now() < ende) {
        await page.waitForTimeout(150);
        const neu = await target.boundingBox();
        stabil = neu && box && Math.abs(neu.x - box.x) < 1 && Math.abs(neu.y - box.y) < 1 ? stabil + 1 : 0;
        box = neu;
      }
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
    // Die Rückfrage liegt über der Leiste, die denselben Namen trägt; ihr Knopf ist der letzte.
    const tippeRueckfrage = async name => {
      const knopf = page.getByRole('button', { name, exact: true }).last();
      await warteBis(async () => await knopf.count() === 1 && await knopf.isVisible(), `Rückfrage-Knopf „${name}“`);
      const box = await knopf.boundingBox();
      assert(box && box.width > 0 && box.height > 0, `Rückfrage-Knopf „${name}“ ohne Größe`);
      await page.mouse.click(box.x + box.width / 2, box.y + box.height / 2);
      await page.waitForTimeout(420);
    };
    const photo = async name => {
      await page.screenshot({ path: path.join(output, `${name}-${width}x844.png`) });
    };
    // Die Leiste genau einmal, keine verbotenen Texte auf dem Bildschirm.
    const pruefeTexte = async titel => {
      const texte = await sichtbareTexte(page);
      for (const wort of verboten) {
        assert(!texte.some(t => t.includes(wort)), `${titel}: verbotener Text „${wort}“ auf dem Bildschirm`);
      }
    };
    const pruefeBildschirm = async titel => {
      const leiste = button('abend_abbrechen');
      await warteBis(async () => await leiste.count() === 1 && await leiste.isVisible(), `${titel}: „${text('abend_abbrechen')}“ sichtbar`);
      await pruefeTexte(titel);
    };
    // Das Würfelergebnis steht als Rechnung „2W6: …“ auf dem Bildschirm.
    const wurfErgebnis = async () => (await sichtbareTexte(page)).some(t => t.includes('2W6:'));

    // Akte Nachtexpress, dann Solo mit Bots (wie im Assistenten: Akte, Spielweise, Einrichtung, Start).
    stage = `${width} px · Assistent öffnen`;
    await click('detektei_neuer_abend');
    // Getippt wird erst, wenn der Assistent beim Schritt „Akte“ steht (sein Titel ist sichtbar).
    await page.getByText(text('abend_akte_titel'), { exact: true }).waitFor({ state: 'visible', timeout: 30000 });
    // Die Karte „Nachtexpress“ gibt es auch in der Detektei: Die Tippfläche muss eindeutig sein,
    // sonst wartet tap() und meldet die Zeitüberschreitung, statt die falsche Karte zu treffen.
    stage = `${width} px · Akte „Nachtexpress“ wählen`;
    await tap(page.getByRole('button', { name: /Nachtexpress/ }));
    await click('abend_weiter');
    await click('abend_spielweise_solo');
    await click('abend_weiter');
    stage = `${width} px · Solo einrichten`;
    // Auf die kleinste Besetzung herunterzählen, solange der Knopf offen ist (kürzerer Abend).
    const offen = async key => (await button(key).count()) === 1 && (await button(key).isVisible()) && (await button(key).isEnabled());
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

    // Würfeltafel: Leiste, keine verbotenen Texte, die neutralen Würfeltexte stehen auf der Tafel; Foto.
    stage = `${width} px · Würfeltafel`;
    await button('ui.zug.werfen').waitFor({ timeout: 30000 });
    await pruefeBildschirm(`${width} px Würfeltafel`);
    for (const wort of wuerfelTexte) {
      assert(await page.getByText(wort, { exact: true }).count() >= 1, `${width} px Würfeltafel: neutraler Text „${wort}“ fehlt`);
    }
    await photo('abbrechen-wuerfel');

    // Probewurf: das Ergebnis steht auf dem Bildschirm, Leiste und Texte bleiben neutral.
    stage = `${width} px · Probewurf`;
    await click('ui.zug.werfen');
    await warteBis(wurfErgebnis, `${width} px Probewurf-Ergebnis`);
    await pruefeBildschirm(`${width} px nach Probewurf`);

    // Browser-Zurück (der Verlauf des Browsers, nicht der Knopf der App): die Route fragt nach, bevor der
    // Abend endet. Playwrights goBack() wirkt hier nicht (es bleibt bei einem Schritt im selben Dokument);
    // history.back() ist derselbe Schritt wie der Browser-Zurück-Knopf.
    stage = `${width} px · Browser-Zurück`;
    // Die Karteikarte benennt ihre Route mit dem Titel (Semantik-Label für Bildschirmleser), der
    // Titel steht dann nicht noch einmal als Text im Baum.
    const titel = page.getByLabel(text('abend_abbrechen_titel'), { exact: true }).or(page.getByText(text('abend_abbrechen_titel'), { exact: true }));
    const verlauf = () => page.evaluate(() => ({ len: history.length, hash: location.hash }));
    const vorZurueck = await verlauf();
    await page.evaluate(() => history.back());
    await titel.first().waitFor({ state: 'visible', timeout: 30000 });
    await page.getByText(text('abend_abbrechen_text'), { exact: true }).waitFor({ state: 'visible', timeout: 30000 });
    await page.getByRole('button', { name: text('abend_abbrechen_nein'), exact: true }).waitFor({ state: 'visible', timeout: 30000 });
    await photo('abbrechen-dialog');

    // „Weiterspielen“ in der offenen Rückfrage: der Abend und der Probewurf bleiben, die Adresse ist wieder
    // die des Abends, und der Verlauf wächst nicht. [vorher] ist die Verlaufslänge vor dem Auslöser.
    const weiterspielen = async (quelle, vorher) => {
      stage = `${width} px · ${quelle}: Weiterspielen`;
      await tippeRueckfrage(text('abend_abbrechen_nein'));
      await warteBis(async () => await titel.count() === 0, `Rückfrage (${quelle}) nach „Weiterspielen“ geschlossen`);
      await pruefeBildschirm(`${width} px nach ${quelle}`);
      assert(await wurfErgebnis(), `${width} px (${quelle}): der Probewurf ist nach „Weiterspielen“ weg`);
      const nachher = await verlauf();
      if (nachher.hash !== abendAdresse) befunde.push(`${width} px (${quelle}): nach „Weiterspielen“ steht die Adresse „${nachher.hash}“ statt „${abendAdresse}“`);
      if (nachher.len !== vorher.len) befunde.push(`${width} px (${quelle}): „Weiterspielen“ legt einen zusätzlichen Verlaufseintrag an (${vorher.len} → ${nachher.len})`);
    };
    await weiterspielen('Browser-Zurück', vorZurueck);

    // Abbrechen über die Leiste → Weiterspielen: auch dieser Weg darf den Verlauf nicht verlängern.
    stage = `${width} px · Leiste: Abbrechen`;
    const vorLeiste = await verlauf();
    await click('abend_abbrechen');
    await titel.first().waitFor({ state: 'visible', timeout: 30000 });
    await weiterspielen('Leiste', vorLeiste);

    // Abbrechen → Ja → Detektei.
    stage = `${width} px · Rückfrage bestätigen`;
    await click('abend_abbrechen');
    await titel.first().waitFor({ state: 'visible', timeout: 30000 });
    await tippeRueckfrage(text('abend_abbrechen_ja'));

    // Ergebnis: Detektei sichtbar, Rückfrage weg.
    stage = `${width} px · Detektei nach Abbruch`;
    await warteBis(async () => await button('detektei_neuer_abend').count() === 1, 'Detektei mit „Neuer Abend“');
    await button('detektei_neuer_abend').waitFor({ state: 'visible', timeout: 30000 });
    assert.equal(await titel.count(), 0, 'Die Rückfrage ist nach dem Abbruch noch offen');
    assert.equal(await button('abend_abbrechen').count(), 0, 'Die Abend-Leiste ist nach dem Abbruch noch da');
    assert.equal(errors.filter(e => e.startsWith(`${width} px`)).length, 0, `Konsole oder fremde Anfragen bei ${width} px: ${errors.join(' | ')}`);
    console.log(`ABBRECHEN OK · ${width} px · Leiste in Rollenphase, Würfeltafel und nach Probewurf · Weiterspielen · Browser-Zurück · Ja → Detektei`);
    await page.close();
  }
  assert.equal(errors.length, 0, `Konsole oder fremde Anfragen: ${errors.join(' | ')}`);
  stage = 'Browser-Verlauf nach „Weiterspielen“';
  assert.equal(befunde.length, 0, `Produktbefund (lib/app/router.dart onExit, lib/abend/abend_seite.dart abendVerlassen): ${befunde.join(' | ')}`);
  console.log(`ABBRECHEN GRÜN · ${widths.length}/${widths.length} Handygrößen · 0 Konsolenfehler · 0 fremde Netzaufrufe · Fotos ${path.relative(repo, output)}`);
} catch (error) {
  await activePage?.screenshot({ path: path.join(import.meta.dirname, 'fotos/abbrechen-fehler.png') }).catch(() => {});
  console.error(`ABBRECHEN ROT · ${stage} · ${String(error.message).slice(0, 1600)}`);
  process.exitCode = 1;
} finally {
  await browser?.close();
  server.close();
}
