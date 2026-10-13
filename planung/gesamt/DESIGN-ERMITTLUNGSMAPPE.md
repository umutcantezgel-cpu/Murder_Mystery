# Ermittlungsmappe: Designregeln für alle Bildschirme

Das ganze Spiel ist **ein nächtlicher Schreibtisch mit Mappen**. Jede Seite ist ein Blatt in einer Akte. Jede Aktion ist ein Gegenstand vom Detektivtisch: Messingschild, Stempel, Umschlag, Karteikarte.

Alle Bausteine importiert man über `lib/stil/stil.dart`.

## Drei Objektklassen

| Klasse | Material | Bausteine | Wofür |
|---|---|---|---|
| **Dokument** | helles Papier, Tinte | `MBlatt`, `MAktenmappe`, `MBlattKopf`, `MFeld`, `MSchreibmaschine`, `MKarteikartenDialog` | alles, was man **liest**: Erzähltext, Dossier, Funde, Auflösung, Regeln |
| **Bedienung** | Messing, Etikett, dunkler Deckel | `MKnopf` (haupt = Messingschild, zweit = Aktenetikett, leise = Tintenlink, gefahr = Stempelschild), `MSchalter`, `MHaken`, `MReiterleiste`, `MTafel` (dunkler Deckel) | alles, was man **tut** |
| **Beweis** | Foto, Karte, Kork | `MFotoabzug`, `MStempel`, `MSiegel`, `MBueroklammer`, `MKlebestreifen`, `MReissnagel`, `MKorkwand` | alles, was man **sammelt**, anpinnt oder verbindet |

## Regeln

1. **Text auf Papier ist Tinte.**
   - Auf `MBlatt` und in `MAktenmappe` stehen nur Stile aus `MPapierSchrift.*`, zum Beispiel `MPapierSchrift.text`, `.leise`, `.ueberschrift`, `.erzaehler`, `.kursiv`, `.zwischentitel`, `.maschine`, `.hand` und `.marke` (stempelrot).
   - Ein äußerer `context` liegt **über** dem Papier. Darum dort nie `context.schrift.text` oder `Keller.text`. Wer Kontextfarben im Papier braucht, nimmt einen `Builder` im Blatt; `MFarben.von` und `MSchrift.von` liefern dort Tintenfarben.
2. **Text auf dem Schreibtisch ist hell:** `context.schrift.*` bzw. `context.farben.*`. Die statischen `Keller.*`-Stile werden schrittweise ersetzt.
3. **Typografie:**

   | Schrift | Einsatz |
   |---|---|
   | Playfair Display | Titel, Namen, Überschriften |
   | Lora | Lesetext |
   | Lora kursiv | Aussagen, Zitate, Lügen |
   | Special Elite | Formularköpfe, Etiketten, Aktenzeichen |
   | Caveat | Randnotizen in Füllertinte (`MPapierSchrift.hand`) |
   | Inter | nur kleine Funktionstexte (`leise`, `marke`) |

   Keine eigenen `fontSize`-Werte außerhalb der Skala 12 · 13 · 14 · 15 · 17 · 20 · 22 · 30 · 40.
4. **Personen sind Fotos, keine Farbpunkte.**
   - `MFotoabzug(look: sitzung.figurAussehen(id), groesse: …, akzent: sitzung.figurFarbe(id))`.
   - Der Farbcode einer Figur erscheint als Registerstreifen (`MBlatt(randFarbe: …)`) oder als Band der Aktenmappe.
5. **Keine Material-Standardwidgets** in Spielbildschirmen. Ersatz:

   | Statt | Neu |
   |---|---|
   | `AlertDialog` | `MKarteikartenDialog` / `frageKarteikarte` |
   | `Switch` | `MSchalter` |
   | `Checkbox` / `CheckboxListTile` | `MHaken` |
   | Pillen | `MChip` (Etikett) |
   | `showModalBottomSheet` | Karteikarte im Dialog |

6. **Keine Versalien zur Laufzeit auf Inhalten.**
   - Kein `toUpperCase()` auf Texten, die Tests oder Bildschirmleser exakt finden müssen.
   - Stempel malen Versalien selbst; ihr Text bleibt in der Semantik in Originalschreibung.
   - Bestehende `toUpperCase()`-Marken, die Tests in Versalien suchen, bleiben.
7. **Gleiche Gestalt für alle Rollen** (K-22, E-041):
   - Das Täter-Dossier hat dieselben Blätter, Stempel, Farben und Köpfe in derselben Folge.
   - Vor dem Finale hängt nichts Sichtbares vom Täterpfad oder von der Wertung ab: keine Stempel „richtig/falsch“, kein Ausgrauen von Verdächtigen.
8. **Bewegung:**
   - Stempel schlagen auf (`MStempel(aufschlagen: true)`), Blätter liegen leicht schräg (`neigung` ±0,003–0,012).
   - Alles respektiert „Bewegung reduzieren“ (`MBewegung.ruhig`).
9. **Texte:**
   - In `lib/party` kommen sichtbare Texte nur aus `s.ui(...)` oder `s.text(...)`; der Text-Wächter prüft das.
   - Sonst kommen sie aus `lib/l10n/app_de.arb` (danach `flutter gen-l10n`).
   - Aktenzeichen wie `Nr. 03` sind erlaubt.
10. **Tests:**
    - Semantik-Namen und Knopftexte bleiben, denn die E2E-Skripte suchen sie.
    - `MKnopf` bleibt intern `FilledButton`/`OutlinedButton`/`TextButton`.
    - Ändert sich ein Widget-Typ, den ein Test sucht (`AlertDialog`, `Switch`), wird der Test **im selben Commit** auf den neuen Typ umgestellt, ohne Behauptungen zu streichen.

## Muster im Code
- Erzähltext als Berichtsblätter: `lib/party/erzaehler_ausgabe.dart`.
- Karteikasten mit Fotoabzügen, versiegelter Umschlag, Dossier als Aktenmappe: `lib/party/bildschirme/rollen.dart`.
