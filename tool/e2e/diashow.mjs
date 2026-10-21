// Diashow zur Einleitung im Browser (Langer Abend M4). Die Entwicklerroute spielt
// bis zum Intro vor (`bis=intro`, reihum ohne Begleiter: das Gerät liest vor);
// ab dort nur echte Knöpfe. Je Bild stehen die Beschriftung „Bild n von 6“ (für
// den Bildschirmleser) und nur der Erzähltext zu diesem Bild da; „Nächstes Bild“
// schaltet beide weiter, am letzten Bild bleibt „Weiter“. Einmal bei 390 px mit
// Bewegung, einmal bei 320 px mit „Bewegung reduzieren“ (der Wechsel ist ein
// Schnitt). Keine Konsolenfehler, keine fremden Anfragen.
// Fotos der Bilder (öffentlich, ohne Geheimnis) unter fotos/diashow/.
// Aufruf: node tool/e2e/diashow.mjs   (braucht build/web)
import assert from 'node:assert/strict';
import fs from 'node:fs/promises';
import path from 'node:path';
import { starteBrowser } from './browser.mjs';
import { starteServer } from './server.mjs';

const repo = path.resolve(import.meta.dirname, '../..');
const aus = path.join(import.meta.dirname, 'fotos/diashow');
await fs.mkdir(aus, { recursive: true });
const leseJson = async datei => JSON.parse(await fs.readFile(path.join(repo, datei), 'utf8'));
const arb = await leseJson('lib/l10n/app_de.arb');
const diashow = await leseJson('content/welt/schlosskeller/diashow.json');
const intro = (await leseJson('content/party/schlosskeller/texte/erzaehler-intro.json')).eintraege;
const norm = s => s.replace(/\s+/g, ' ').trim();
/** Anfang eines Bausteins bis vor den ersten Platzhalter, höchstens 30 Zeichen. */
const kopf = t => norm(t.split('{')[0]).slice(0, 30);
// Je Bild die Anfänge aller Fassungen seines Bausteins (besetzt oder npc, m oder w).
const fassungen = diashow.dias.map(d => intro
  .filter(e => e.id === d.baustein || e.id.startsWith(`${d.baustein}.`))
  .map(e => kopf(e.text))
  .filter(k => k.length >= 12));
assert(fassungen.every(f => f.length > 0), 'Jedes Bild hat einen Baustein mit Text');
const n = diashow.dias.length;
const bild = nr => arb.party_intro_bild.replace('{nr}', String(nr)).replace('{anzahl}', String(n));

const server = await starteServer(path.join(repo, 'build/web'));
const basis = `http://127.0.0.1:${server.address().port}`;
const fehler = [];
const fotos = [];
let browser;
try {
  browser = await starteBrowser();
  for (const { breite, ruhig } of [{ breite: 390, ruhig: false }, { breite: 320, ruhig: true }]) {
    const wo = `${breite} px${ruhig ? ' · Bewegung reduzieren' : ''}`;
    const page = await browser.newPage({
      locale: 'de-DE',
      viewport: { width: breite, height: 844 },
      deviceScaleFactor: 1,
      reducedMotion: ruhig ? 'reduce' : 'no-preference',
    });
    let imIntro = false;
    page.on('pageerror', e => fehler.push(`${wo}: ${e.message}`));
    page.on('console', m => {
      if (m.type() === 'error') fehler.push(`${wo}: ${m.text()}`);
      if (m.text().startsWith('PARTY foto=intro')) imIntro = true;
      if (m.text().startsWith('PARTY fehler')) fehler.push(`${wo}: ${m.text()}`);
    });
    await page.route('**/*', async route => {
      const u = new URL(route.request().url());
      if (!['127.0.0.1', 'localhost'].includes(u.hostname) && !['data:', 'blob:', 'about:'].includes(u.protocol)) {
        fehler.push(`${wo}: fremde Anfrage ${u.hostname}`);
        await route.abort();
      } else await route.continue();
    });
    await page.goto(`${basis}/?party=schlosskeller&pfad=ahmet&n=4&bis=intro&semantik=1`, { waitUntil: 'load' });
    const frist = Date.now() + 90000;
    while (!imIntro && Date.now() < frist) await page.waitForTimeout(200);
    assert(imIntro, `${wo}: Das Intro erscheint nicht`);

    /** Bildschirmtext: Semantikbaum und alle Beschriftungen (das Bild trägt nur ein aria-label). */
    const text = async () => norm(await page.evaluate(() => {
      const teile = [];
      const host = document.querySelector('flt-semantics-host');
      if (host) teile.push(host.innerText);
      for (const el of document.querySelectorAll('[aria-label]')) teile.push(el.getAttribute('aria-label'));
      return teile.join('\n');
    }));
    const warte = async (ok, was) => {
      const ende = Date.now() + 20000;
      while (Date.now() < ende) {
        if (await ok()) return;
        await page.waitForTimeout(150);
      }
      throw new Error(`${wo}: Zeitüberschreitung bei ${was}`);
    };
    /** Echter Zeiger auf die Mitte des Knopfs, sobald er still liegt (CanvasKit-Hittest statt DOM-Klick). */
    const tippe = async knopf => {
      await warte(async () => (await knopf.count()) === 1, 'einem eindeutigen Knopf');
      await knopf.scrollIntoViewIfNeeded();
      let box = await knopf.boundingBox();
      for (let stabil = 0, i = 0; stabil < 3 && i < 60; i++) {
        await page.waitForTimeout(120);
        const neu = await knopf.boundingBox();
        stabil = neu && box && Math.abs(neu.x - box.x) < 1 && Math.abs(neu.y - box.y) < 1 ? stabil + 1 : 0;
        box = neu;
      }
      assert(box && box.width > 0, `${wo}: Knopf ohne Fläche`);
      await page.mouse.click(box.x + box.width / 2, box.y + box.height / 2);
    };
    const naechstes = page.getByRole('button', { name: arb.party_intro_naechstes, exact: true });

    for (let i = 0; i < n; i++) {
      await warte(async () => (await text()).includes(bild(i + 1)), bild(i + 1));
      const t = await text();
      assert(fassungen[i].some(k => t.includes(k)), `${wo}: Der Text zu Bild ${i + 1} fehlt`);
      for (let j = 0; j < n; j++) {
        if (j !== i) assert(!fassungen[j].some(k => t.includes(k)), `${wo}: Bild ${i + 1} zeigt auch den Text zu Bild ${j + 1}`);
      }
      // Die Blende ist kurz; danach steht das Bild.
      await page.waitForTimeout(ruhig ? 400 : 1200);
      const datei = `${breite}${ruhig ? '-ruhig' : ''}-${String(i + 1).padStart(2, '0')}.png`;
      await page.screenshot({ path: path.join(aus, datei) });
      fotos.push(datei);
      if (i < n - 1) await tippe(naechstes);
    }
    assert.equal(await naechstes.count(), 0, `${wo}: Am letzten Bild gibt es kein „Nächstes Bild“ mehr`);
    console.log(`${wo}: ${n} Bilder, je Bild nur sein Text`);
    await page.close();
  }
} catch (e) {
  fehler.push(String(e?.stack ?? e));
} finally {
  await browser?.close();
  server.close();
}
console.log(`Fotos: ${fotos.length} in ${aus}`);
for (const f of fehler) console.log('FEHLER', f);
process.exitCode = fehler.length === 0 ? 0 : 1;
