# Store-Paket

Alles, was die Stores von Mordakte brauchen und sich aus dem Code ableiten lässt.

| Ort | Inhalt |
|---|---|
| `metadata/android/de-DE/` | Play: Titel (≤ 30), Kurzbeschreibung (≤ 80), Beschreibung (≤ 4.000), Neuerungen (≤ 500) |
| `metadata/ios/de-DE/` | App Store: Name (≤ 30), Untertitel (≤ 30), Werbetext (≤ 170), Beschreibung (≤ 4.000), Schlüsselwörter (≤ 100), Neuerungen |
| `datenschutz.md` | Datenschutzhinweis für die Webseite (Angaben des Besitzers ergänzen) |
| `datenangaben.md` | Antworten für „Datensicherheit“ (Play) und „App-Datenschutz“ (Apple) |

Die Ordner folgen dem Aufbau von fastlane (`supply`, `deliver`), damit ein späterer Schritt sie
hochladen kann. `test/store/store_texte_test.dart` prüft Längen und Tonregeln und dass kein
Täter genannt wird.

## Noch offen (Besitzer)
- Konten: Google Play Console, Apple Developer Program.
- Signatur: Upload-Schlüssel für Play als Secrets der CI, Zertifikate und Profile für iOS.
- Domain für Datenschutzhinweis und später Deep Links; `datenschutz.md` dort veröffentlichen.
- Altersfreigabe (IARC, Apple-Fragebogen), Exportangabe Verschlüsselung.
- Store-Bilder: erzeugt die Bildpipeline (`tool/e2e/kontaktbogen.mjs`), Auswahl durch den Besitzer.
- Play: geschlossener Test mit 12 Personen über 14 Tage vor der Freigabe.
