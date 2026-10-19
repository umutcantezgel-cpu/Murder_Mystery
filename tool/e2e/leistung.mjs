// Leistungsmessung im Browser: Ladezeit, Bildintervalle
// (Median, 99. Perzentil), Rechenlast (Anteil der Hauptthread-Arbeit an der Wanduhr) und JS-Speicher
// einer gebauten Web-Fassung, je Geräteklasse über CPU-Drosselung genähert:
//   hoch = 1× · mittel = 4× · einfach = 6× (Chrome DevTools Emulation.setCPUThrottlingRate).
// Je Ansicht zwei Phasen: „ruhig“ (keine Eingabe) und „bewegt“ (Pfeiltaste gehalten).
// Nur localhost; fremde Netzaufrufe und Konsolenfehler werden gezählt.
//
// Aufruf: node tool/e2e/leistung.mjs <buildOrdner> <ausgabe.json>
//           [--ansichten name=query;name=query | ebenen] [--klassen hoch,mittel,einfach] [--sekunden 8]
// `--ansichten ebenen` misst die Welt-Ebenen des langen Abends (M7a) in der Übersicht gegen den Keller
// heute (Partykarte) und den Keller in derselben Ebenen-Vorschau.
import { createRequire } from 'node:module';
import http from 'node:http';
import fs from 'node:fs';
import path from 'node:path';

// Playwright wie tool/browser/geraete.js aus der globalen Installation (keine neue Abhängigkeit).
const { chromium } = createRequire(import.meta.url)('/opt/node22/lib/node_modules/playwright');

const args = process.argv.slice(2);
if (args.length < 2) {
  console.error('Aufruf: node tool/e2e/leistung.mjs <buildOrdner> <ausgabe.json> [--ansichten …] [--klassen …] [--sekunden N]');
  process.exit(2);
}
const build = path.resolve(args[0]);
const ausgabe = path.resolve(args[1]);
const opt = (name, std) => {
  const i = args.indexOf(`--${name}`);
  return i >= 0 && i + 1 < args.length ? args[i + 1] : std;
};
const sekunden = Number(opt('sekunden', '8'));
const warten = Number(opt('warten', '2000')); // Einschwingen nach dem ersten Bild (ms)
const drossel = { hoch: 1, mittel: 4, einfach: 6 };
const klassen = opt('klassen', 'hoch,mittel,einfach').split(',');
const ebenen = [
  'keller_heute=party=schlosskeller&zoom=0.55&at=13.5,11.5',
  'ebene_keller=ebene=keller&zoom=0.55&at=13.5,11.5',
  'ebene_erdgeschoss=ebene=erdgeschoss&zoom=0.55&at=25.5,10.5',
  'ebene_turm=ebene=turm&zoom=0.55&at=8.5,8.5',
  'ebene_aussen=ebene=aussen&zoom=0.55&at=21.5,9.5',
].join(';');
const ansichtenWahl = opt('ansichten',
  'buffetsaal=party=schlosskeller&zoom=1.1&at=14.5,11.5;uebersicht=party=schlosskeller&zoom=0.55&at=13.5,11.5');
const ansichten = (ansichtenWahl === 'ebenen' ? ebenen : ansichtenWahl)
  .split(';').map((a) => { const i = a.indexOf('='); return { name: a.slice(0, i), q: a.slice(i + 1) }; });

const typen = {
  '.html': 'text/html', '.js': 'application/javascript', '.mjs': 'application/javascript', '.json': 'application/json',
  '.wasm': 'application/wasm', '.css': 'text/css', '.png': 'image/png', '.ttf': 'font/ttf', '.otf': 'font/otf',
  '.wav': 'audio/wav', '.bin': 'application/octet-stream', '.frag': 'application/octet-stream',
};
const server = http.createServer((req, res) => {
  const url = new URL(req.url, 'http://localhost');
  let datei = path.join(build, decodeURIComponent(url.pathname));
  if (!datei.startsWith(build)) { res.writeHead(403); res.end(); return; }
  if (fs.existsSync(datei) && fs.statSync(datei).isDirectory()) datei = path.join(datei, 'index.html');
  if (!fs.existsSync(datei)) { res.writeHead(404); res.end(); return; }
  res.writeHead(200, { 'Content-Type': typen[path.extname(datei)] ?? 'application/octet-stream' });
  fs.createReadStream(datei).pipe(res);
});
await new Promise((ok) => server.listen(0, '127.0.0.1', ok));
const port = server.address().port;

const browser = await chromium.launch({
  executablePath: '/opt/pw-browsers/chromium-1194/chrome-linux/chrome',
  args: ['--use-gl=swiftshader', '--enable-unsafe-swiftshader', '--ignore-gpu-blocklist'],
});
const fremd = [];
const fehler = [];
const ergebnisse = [];

/** Perzentil p (0..1) einer Zahlenliste. */
const perz = (werte, p) => {
  if (werte.length === 0) return null;
  const s = [...werte].sort((a, b) => a - b);
  return s[Math.min(s.length - 1, Math.floor(p * (s.length - 1)))];
};

/** Misst über [ms] Millisekunden: rAF-Intervalle im Seitenkontext und Hauptthread-Arbeit per CDP. */
async function phase(page, cdp, ms) {
  await page.evaluate(() => {
    window.__fk = [];
    let letzte = performance.now();
    const schleife = (t) => { window.__fk.push(t - letzte); letzte = t; if (window.__fkAn) requestAnimationFrame(schleife); };
    window.__fkAn = true;
    requestAnimationFrame(schleife);
  });
  const m0 = await cdp.send('Performance.getMetrics');
  const t0 = Date.now();
  await page.waitForTimeout(ms);
  const m1 = await cdp.send('Performance.getMetrics');
  const t1 = Date.now();
  const intervalle = await page.evaluate(() => { window.__fkAn = false; return window.__fk.slice(1); });
  const wert = (m, n) => m.metrics.find((x) => x.name === n)?.value ?? 0;
  const arbeit = (wert(m1, 'TaskDuration') - wert(m0, 'TaskDuration')) * 1000; // ms
  const skript = (wert(m1, 'ScriptDuration') - wert(m0, 'ScriptDuration')) * 1000; // ms
  return {
    bilder: intervalle.length,
    bilderProSekunde: Math.round((intervalle.length / ((t1 - t0) / 1000)) * 10) / 10,
    intervallMedianMs: Math.round(perz(intervalle, 0.5) * 10) / 10,
    intervallP99Ms: Math.round(perz(intervalle, 0.99) * 10) / 10,
    rechenlast: Math.round((arbeit / (t1 - t0)) * 1000) / 1000,
    skriptlast: Math.round((skript / (t1 - t0)) * 1000) / 1000,
    jsHeapMB: Math.round(wert(m1, 'JSHeapUsedSize') / 1e5) / 10,
  };
}

for (const klasse of klassen) {
  for (const a of ansichten) {
    const page = await browser.newPage({ viewport: { width: 1280, height: 720 } });
    page.on('request', (r) => {
      const u = new URL(r.url());
      if (!['127.0.0.1', 'localhost'].includes(u.hostname) && !['data:', 'blob:'].includes(u.protocol)) fremd.push(r.url());
    });
    const meldungen = [];
    page.on('console', (m) => {
      if (m.type() === 'error') fehler.push(`${klasse}/${a.name}: ${m.text()}`);
      else if (m.text().startsWith('WELT')) meldungen.push(m.text());
    });
    page.on('pageerror', (e) => fehler.push(`${klasse}/${a.name}: ${e.message}`));
    const cdp = await page.context().newCDPSession(page);
    await cdp.send('Performance.enable');
    await cdp.send('Emulation.setCPUThrottlingRate', { rate: drossel[klasse] });
    const start = Date.now();
    await page.goto(`http://127.0.0.1:${port}/?${a.q}`, { waitUntil: 'load' });
    // Bereit, sobald die Flutter-Ansicht steht und zwei Bilder gezeichnet wurden
    await page.waitForSelector('flutter-view, flt-glass-pane', { timeout: 120000 });
    await page.evaluate(() => new Promise((ok) => requestAnimationFrame(() => requestAnimationFrame(ok))));
    const ladezeitMs = Date.now() - start;
    await page.waitForTimeout(warten); // Einschwingen
    await page.mouse.click(640, 360);
    const ruhig = await phase(page, cdp, sekunden * 1000);
    await page.keyboard.down('ArrowRight');
    const bewegt = await phase(page, cdp, sekunden * 1000);
    await page.keyboard.up('ArrowRight');
    const foto = ausgabe.replace(/\.json$/, `_${klasse}_${a.name}.png`);
    await page.screenshot({ path: foto });
    ergebnisse.push({ klasse, drossel: drossel[klasse], ansicht: a.name, ladezeitMs, ruhig, bewegt, meldungen, foto: path.basename(foto) });
    console.log(`MESSUNG ${klasse} ${a.name} · Laden ${ladezeitMs} ms · ruhig ${ruhig.bilderProSekunde} B/s (p99 ${ruhig.intervallP99Ms} ms, Last ${ruhig.rechenlast}) · bewegt ${bewegt.bilderProSekunde} B/s (p99 ${bewegt.intervallP99Ms} ms, Last ${bewegt.rechenlast}) · Heap ${bewegt.jsHeapMB} MB${meldungen.length ? ' · ' + meldungen.join(' | ') : ''}`);
    await page.close();
  }
}
await browser.close();
server.close();
fs.mkdirSync(path.dirname(ausgabe), { recursive: true });
fs.writeFileSync(ausgabe, JSON.stringify({ build: path.basename(build), sekunden, ergebnisse, fremdeNetzaufrufe: fremd, konsolenfehler: fehler }, null, 2));
console.log(`Fremde Netzaufrufe: ${fremd.length} · Konsolenfehler: ${fehler.length} · ${ausgabe}`);
process.exitCode = fremd.length > 0 ? 1 : 0;
