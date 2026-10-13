# Datenangaben für die Stores

Antworten für die Formulare der Stores, abgeleitet aus dem Code (Stand Oktober 2026). Ändert
sich der Code, ändern sich diese Antworten mit.

## Google Play · Datensicherheit
- **Erhebt die App Nutzerdaten?** Nein.
- **Werden Daten an Dritte weitergegeben?** Nein.
- **Hinweis zum Online-Abend:** Spielnachrichten laufen Ende-zu-Ende verschlüsselt über einen
  Weiterleitungsdienst; weder der Dienst noch der Entwickler kann sie lesen. Nach den Regeln
  von Google gelten Ende-zu-Ende verschlüsselte Daten, die der Entwickler nicht lesen kann, nicht
  als erhoben.
- **Verschlüsselung bei der Übertragung:** Ja (TLS zum Weiterleitungsdienst, zusätzlich Ende-zu-Ende).
- **Kann man das Löschen der Daten beantragen?** Entfällt (keine Daten beim Entwickler).
- **Werbe-ID:** wird nicht verwendet.
- **Zielgruppe:** ab 12 Jahren empfohlen (Krimi-Inhalte ohne Gewaltdarstellung); Einstufung über
  den IARC-Fragebogen durch den Besitzer.

## Apple App Store · App-Datenschutz
- **Datenerfassung:** „Keine Daten erfasst“ (Data Not Collected).
- **Tracking:** nein; kein App Tracking Transparency nötig.
- **Exportangabe Verschlüsselung (`ITSAppUsesNonExemptEncryption`):** offen, Entscheidung des
  Besitzers (siehe `planung/gesamt/STATUS.md`).

## Berechtigungen
- Android: Internet (Online-Abend) und Vibration (Rückmeldung beim Tippen). Keine Kamera, kein
  Mikrofon, kein Standort, keine Kontakte.
- iOS: nur beim Sichern einer geteilten Karte in „Fotos“ fragt iOS nach (`NSPhotoLibraryAddUsageDescription`, nur Hinzufügen, kein Lesen der Mediathek); sonst keine Berechtigungsabfragen.
