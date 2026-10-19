// Befragungen des Detektivs im Browser (Modell befragung, A-051). Die Karten tragen
// Semantik-Kennungen (`flt-semantics-identifier`): `befragung-<id>` je Karte,
// `befragung-frage-<id>-<nr>` je Frage, `befragung-waehlen-<id>` je freier Wahl und
// am Tisch `befragung-beantwortet-<id>`. Getippt wird mit echtem Zeiger über die
// Tippfunktion des Aufrufers, nie per DOM-Klick.

/** Alle Semantik-Knoten, deren Kennung mit [praefix] beginnt. */
export const kennung = (page, praefix) => page.locator(`flt-semantics[flt-semantics-identifier^="${praefix}"]`);

/** Die erste Frage einer noch offenen Karte. */
const ersteFrage = page => page.locator('flt-semantics[flt-semantics-identifier^="befragung-frage-"][flt-semantics-identifier$="-0"]');

/**
 * Führt die Befragungen einer Runde, bis [fertig] wahr ist: erst die erste Frage
 * jeder offenen Karte (feste zuerst, sie stehen oben), dann klappt es die oberste
 * freie Befragung auf, solange freie Wahlen offen sind; zuletzt tippt es
 * „Beantwortet“ für Menschen am Tisch. [nachFrage] bekommt die Kennung der
 * Befragung nach jeder Frage. Steht nichts im Bild, rollt es weiter nach unten.
 * Gibt die Zahl der Fragen, Wahlen und Antworten zurück.
 */
export async function befragungenFuehren(page, { tippe, fertig, nachFrage, frist = 180000 }) {
  const zaehler = { fragen: 0, gewaehlt: 0, beantwortet: 0 };
  const ende = Date.now() + frist;
  while (Date.now() < ende) {
    if (await fertig()) return zaehler;
    const frage = ersteFrage(page);
    if (await frage.count()) {
      const id = (await frage.first().getAttribute('flt-semantics-identifier')).replace(/^befragung-frage-/, '').replace(/-0$/, '');
      await tippe(frage.first(), `Frage an ${id}`);
      zaehler.fragen++;
      await nachFrage?.(id);
      continue;
    }
    const wahl = kennung(page, 'befragung-waehlen-');
    if (await wahl.count()) {
      await tippe(wahl.first(), 'freie Befragung');
      zaehler.gewaehlt++;
      continue;
    }
    const beantwortet = kennung(page, 'befragung-beantwortet-');
    if (await beantwortet.count()) {
      await tippe(beantwortet.first(), 'Beantwortet');
      zaehler.beantwortet++;
      continue;
    }
    // Karten unterhalb des Bildschirms hat die Semantik noch nicht: weiter nach unten rollen.
    const { width, height } = page.viewportSize();
    await page.mouse.move(width / 2, height / 2);
    await page.mouse.wheel(0, 400);
    await page.waitForTimeout(250);
  }
  throw new Error(`Die Befragungen der Runde enden nicht (${zaehler.fragen} Fragen, ${zaehler.gewaehlt} Wahlen, ${zaehler.beantwortet} Antworten)`);
}
