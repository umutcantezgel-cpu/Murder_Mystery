// Handy-Bedienprobe: echte Tasten statt PartySkript. Der Einstieg stellt nur
// den Anfang der ersten Ermittlungsrunde bereit; Weg, Pose und Wurf laufen live.
// Aufruf: node tool/e2e/runden.mjs. Keine externen Anfragen oder Zusatzpakete.
import assert from 'node:assert/strict';
import fs from 'node:fs/promises';
import path from 'node:path';
import { starteBrowser } from './browser.mjs';
import { starteServer } from './server.mjs';

const repo = path.resolve(import.meta.dirname, '../..');
const output = path.join(import.meta.dirname, 'fotos/runden');
await fs.mkdir(output, { recursive: true });
const choices = JSON.parse(await fs.readFile(path.join(repo, 'content/party/schlosskeller/entscheidungen.json'), 'utf8'));
const first = choices.entscheidungen[0].optionen[0].text;
const server = await starteServer(path.join(repo, 'build/web'));
const base = `http://127.0.0.1:${server.address().port}`;
const pictures = [];
const errors = [];
let browser;
let activePage;
let stage = 'Start';
try {
  browser = await starteBrowser();
  for (const width of [320, 390]) {
    stage = `${width} px · Laden`;
    const page = activePage = await browser.newPage({ locale: 'de-DE', viewport: { width, height: 844 }, deviceScaleFactor: 1 });
    page.on('pageerror', () => errors.push('JavaScript'));
    page.on('console', message => { if (message.type() === 'error') errors.push('Konsole'); });
    await page.route('**/*', async route => {
      const u = new URL(route.request().url());
      if (!['127.0.0.1', 'localhost'].includes(u.hostname) && !['data:', 'blob:', 'about:'].includes(u.protocol)) {
        errors.push('Fremde Anfrage');
        await route.abort();
      } else await route.continue();
    });
    await page.goto(`${base}/?party=schlosskeller&n=4&pfad=ahmet&bis=entscheidungen`, { waitUntil: 'load' });
    const semantics = page.locator('flt-semantics-placeholder');
    await semantics.waitFor({ state: 'attached', timeout: 30000 });
    await semantics.evaluate(element => element.click());
    const button = name => page.getByRole('button', { name, exact: true });
    const photo = async (name, label) => {
      const filename = `${name}-${width}.png`;
      await page.screenshot({ path: path.join(output, filename) });
      pictures.push({ filename, label: `${width} px · ${label}` });
    };
    stage = `${width} px · Chancen vor dem Auftaktwurf`;
    await button('Würfeln').waitFor({ timeout: 25000 });
    for (const percent of ['28 %', '30 %', '42 %']) assert.equal(await page.getByText(percent, { exact: true }).count(), 1);
    assert.equal(await button('Weiter zur Gruppenwahl').count(), 0);
    await photo('chancen', 'Chancen vor dem Wurf');
    await button('Würfeln').click();
    await button('Zur ersten Entscheidung').waitFor();
    await button('Zur ersten Entscheidung').click();
    stage = `${width} px · Endgültige Wahl über die Liste`;
    await button('Aus einer Liste wählen').click();
    await button(first).click();
    await button('Ja, so machen wir es').click();
    stage = `${width} px · Sichtbarer Laufweg`;
    await page.getByText('Unterwegs zum gewählten Ziel', { exact: true }).waitFor();
    await page.waitForTimeout(450);
    assert.equal(await button('Weiter zur Gruppenwahl').count(), 0);
    assert.equal(await button('Aus einer Liste wählen').count(), 0);
    await photo('laufweg', 'Figur geht zum gewählten Ziel');
    stage = `${width} px · Gesprächspose`;
    await page.getByText('Das Gespräch führen', { exact: true }).waitFor({ timeout: 20000 });
    await page.waitForTimeout(120);
    await photo('pose', 'Gespräch am Ziel');
    stage = `${width} px · Befragungsfund ohne Wurf`;
    await button('Verstanden').waitFor({ timeout: 15000 });
    assert.equal(await button('Würfeln').count(), 0);
    await button('Verstanden').click();
    await button('Aus einer Liste wählen').waitFor();
    assert.equal(errors.length, 0, 'Konsolen- oder Netzwerkfehler');
    console.log(`RUNDEN OK · ${width} px · Chancen · echter Wurf · Listenwahl · echter Laufweg · Gesprächspose · würfelfreier Fund`);
    await page.close();
  }
  const sheet = await browser.newPage({ locale: 'de-DE', viewport: { width: 1220, height: 960 }, deviceScaleFactor: 1 });
  const images = await Promise.all(pictures.map(async ({ filename, label }) => {
    const data = (await fs.readFile(path.join(output, filename))).toString('base64');
    return `<figure><figcaption>${label}</figcaption><img src="data:image/png;base64,${data}"></figure>`;
  }));
  await sheet.setContent(`<html><body style="margin:0;background:#18151f;color:#f1ede4;font:16px sans-serif"><h2 style="margin:24px">Mordakte · Kartenaktion und Kellerwürfel</h2><main style="display:grid;grid-template-columns:repeat(3,390px);gap:18px;padding:0 12px 20px">${images.join('')}</main><style>figure{margin:0}figcaption{margin-bottom:12px}img{display:block;max-height:844px;max-width:390px}</style></body></html>`);
  await sheet.locator('img').evaluateAll(images => Promise.all(images.map(image => image.decode())));
  await sheet.screenshot({ path: path.join(output, 'kontaktbogen.png'), fullPage: true });
  await sheet.close();
  console.log('RUNDEN GRÜN · 2/2 Handygrößen · 0 Konsolenfehler · 0 fremde Netzaufrufe');
} catch (error) {
  // Diese Probe besucht nur öffentliche lokale Spielansichten, keine Anmeldung
  // oder privaten Rollenkarten. Nie Netzwerkpakete oder Browser-Speicher ausgeben.
  await activePage?.screenshot({ path: path.join(output, 'fehler.png') }).catch(() => {});
  console.error(`RUNDEN ROT · ${stage} · ${String(error.message).slice(0, 600)}`);
  process.exitCode = 1;
} finally {
  await browser?.close();
  server.close();
}
