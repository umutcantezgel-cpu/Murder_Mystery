# Architektur der Umsetzung „Kammerspiel“ (verbindlich für alle Bau-Phasen)

Stand 2026-11-02. Ergänzt ENTSCHEIDUNGEN.md (B1–B3, E1–E17). Grundlage: `bibel/FALL-BIBEL.md` (Spezifikation, Rang vor
den Teilentwürfen) und `verstehen/generator.md` §13 (Vorschlag; gilt, wo hier nichts anderes steht).

## A1 Inhalt
- Ordner **`content/kammerspiel/schlosskeller/`** (nicht unter `content/party/…`): So bleiben Inhaltskennung
  (`tool/inhalt_kennung.py`, online-Verträglichkeit), Kanon-Prüfsummen (`tool/kanon_neu.sh`, `kanon_pruefsummen.txt`),
  `texte/index.json`, `spoiler_test.dart` und alle bestehenden Dateien unter `content/` unberührt (E1).
- Eigenes Schema, beschrieben in `content/kammerspiel/schlosskeller/SCHEMA.md`. Jede Rolle hat eine eigene Datei
  (`rollen/NN-<figur>.json`), damit Schreiber parallel arbeiten können.
- Alle Spielertexte und alle Beschriftungen des Kammerspiel-Drucks stehen im Inhalt (auch Überschriften, Dateinamen,
  Hinweise: `ui.json`). Im Dart-Code steht kein Spielertext (`story_text_ausserhalb_test.dart`).
- `pubspec.yaml` bekommt je Asset-Ordner eine Zeile (Asset-Ordner sind nicht rekursiv).
- Platzhalter für Namen von Rollen, die vielleicht unbesetzt sind (WELT 0.2 „[Name | Ersatz]“), haben eine feste, im
  Schema beschriebene Syntax; der Generator löst sie je Besetzung auf. Unaufgelöste Platzhalter im PDF sind ein Fehler.

## A2 Code
- Neue Dart-Dateien unter **`packages/mordakte_core/lib/src/party/druck/kammer/`**, Export über
  `packages/mordakte_core/lib/party_druck.dart`. Der Kern lädt den Inhalt ohne `dart:io`
  (`KammerInhalt.ausJson(Map<String, Object?>)`), CLI und App lesen die Dateien selbst (Datei bzw. `rootBundle`).
- Teile und Dateinamen nach FALL-BIBEL Kap. 18 (MECH 10.1/10.3): `00-erzaehlerheft.pdf`, `01-detektivbogen.pdf`,
  `02-tisch.pdf`, `10-rollenhefte.pdf`, `11-fassungen.pdf`, `12-zusatzrollen.pdf`, `20-karten.pdf`,
  `90-aufloesung-versiegelt.pdf`, alles in einer Datei `kammerspiel-alles.pdf`; je Person `10-rollenheft-<figur>.pdf`
  bzw. `12-zusatzheft-<figur>.pdf`.
- Personen 6–20 = Rollen + Detektiv + Erzähler (E6). Besetzung, Tandems, Solo-Zusatzrolle, Abwesenheitsblatt (E7)
  rechnet `KammerBesetzung`.
- Stil **`DruckStil`** (schlicht, schwarzweiß, `satz_stil.dart`). Überlauf ist ein Fehler (Ausnahme mit Teil und
  Seite), nie stilles Abschneiden. Lageplan Blatt A + B quer (MECH 10.2).
- Gleiche Eingaben ⇒ gleiche Bytes (`festeBytes` aus `satz_fest.dart`).

## A3 Altes Druckspiel
- Bleibt mit allen Dateien und Tests unverändert erreichbar (E1, A-2), in der CLI mit **`--druckspiel-alt`** (alle
  alten Optionen gelten dort weiter). Der Standardmodus der CLI für `schlosskeller` ist das Kammerspiel
  (`--personen 6..20`, Vorgabe 10; `--detektiv w|m`; `--alles`; `--aus`; `--probe` = Sätze für 6, 10 und 20 Personen).
  `--paket`, `--steckbriefe`, `--erzaehlerakte` bleiben unverändert.
- Die App-Druckmappe bietet nur das Kammerspiel an (B1), ohne „Nur Erzähler“/Erzählerakte (E16). „Zum Drucken“ im
  Abend-Assistenten führt zur Druckmappe (E17). Der Kernpfad `Spiel(druck: true)` bleibt mit seinen Tests.

## A4 Verbote (für jeden Agenten)
- Keine bestehende Datei unter `content/` ändern; `tool/kanon_fest.txt`, `tool/kanon_pruefsummen.txt`,
  `*_soll*.g.dart`, Goldens unter `packages/mordakte_core/test/runden/` nie anfassen. Andere Akten bytegleich.
- Tests nie löschen, überspringen oder abschwächen. Ersetztes bleibt bis zur Abnahme erreichbar.
- Kein `git commit`, kein `git push`, kein `git stash`, kein `git checkout -- …` fremder Dateien (der Hauptlauf
  committet). Keine Modellnamen in Code, Doku oder Inhalt.
- Parallel arbeiten andere Agenten im selben Repo an anderen Dateien. Nur die eigenen Dateien ändern. Bricht ein Test
  wegen einer fremden Datei, nicht dort reparieren, sondern melden.

## A5 Werkzeug
- `cd /home/user/Murder_Mystery && source tool/flutter_env.sh` (gepinnte Flutter/Dart-Kette).
- Kern: `cd packages/mordakte_core && dart analyze && dart test test/party/kammer/` (eigene Tests unter
  `test/party/kammer/`). PDFs prüfen mit `pdfinfo`/`pdftotext -layout` (poppler-utils) wie `test/party/druck_hilfe.dart`;
  Seiten als Bild mit `pdftoppm -r 60 -png` (zum Ansehen mit dem Read-Werkzeug).
- Vor Abgabe: `dart analyze` ohne neue Befunde; die eigenen Tests grün; `bash tool/kanon_tor.sh --pruefen` grün.
