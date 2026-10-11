# Gelockerte Kanon-Schemas für Akten

Diese Schemas leitet `tool/schema_akte.py` aus `content/party/schema/` ab. Sie gelten für jede Akte unter
`content/party/<akte>/`, auch für den Schlosskeller, und werden mit dem eigenen Prüfer `SchemaPruefer`
(`packages/mordakte_core/lib/src/party/kanon/schema.dart`) von `packages/mordakte_core/bin/akte_pruefen.dart` angewendet.

Datei von Hand ändern gilt nicht: `python3 tool/schema_akte.py` schreibt alles neu, `--pruefen` prüft die Ableitung.

Gelockert: feste Pfadlisten (ahmet, fatma, olli, can), Pflichtschlüssel je Pfad, feste Anzahlen (Pfade, Besetzung,
Figuren, Gruppenwahl, Bonus-Hinweise), `setting.lacher` und die Opfer-Felder `schluesselbund` und `gedaechtnisLueckeAb`
(jetzt optional), die Kopfbedeckungen (alle des Zeichners) und `herkunft` (freie Zeichenkette). Neu und optional: `fall.simulation`, `fall.pruefprofil`, `fall.zug`,
`setting.darstellung`, Spurbedingung `{"pfade": [...]}` und die Marke `generiert` in jeder Datei.
Alles andere bleibt so streng wie im Schlosskeller.
