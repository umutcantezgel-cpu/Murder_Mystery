# Gegenprüfung P1R3-01: Flüster-Aufträge der Tandems in Runde 2 ohne Fassung für offene Karten

Prüfer: Gegenprüfung (Widerlegungsversuch) · Stand: Druck r3 (Arbeitsbaum) · Repository nicht verändert.

## Ergebnis

**Bestätigt, Schwere mittel.** Das Zitat steht wörtlich im Druck (20 w, 20 m, 18 w). Kein anderer gedruckter Text fängt
die Lage ab. Weder ENTSCHEIDUNGEN (E1–E22) noch MECH 12a, WELT 0.3 oder FALL-BIBEL 19.2 nehmen sie hin, und sie steht
nicht in der Liste des schon Bekannten. Bei 18 bis 20 Personen ist Serkans Flüster-Auftrag in Runde 2 planmäßig tot, und
zwar durch die eigene Kette der Bibel (ZR 9.2: Wojtek → Hana „Hanas Auslöser 3“). Damirs Flüster-Auftrag ist tot, sobald
Tandem 1 in Runde 1 aufging (FM9/YT4 im Vorrat der Runde 1, Vitrinen-Vorwurf oder freiwillig). Die Bibel verlangt selbst
Fassungen für solche Ziele (ZR 0.1, ZG-08: „Hängt ein Ziel vom Tischstand ab, hat es zwei oder drei Fassungen.“). Beide
Aufträge haben keine.

## Was geprüft wurde, wie

| Nr | Prüfpunkt | Wie | Ergebnis |
|---|---|---|---|
| 1 | Zitat Serkan R2 Ziel 1 | `druck-r3/text/w/kammerspiel-U4YRK-p20/12-zusatzheft-serkan.txt`, Seitenzählung über Seitenvorschub; Bild S. 3 (`pdftoppm -r 60`) angesehen | steht wörtlich auf **S. 3 von 3**: „Ziel 1 · Hana: Sprich leise mit Hana: „Am Tisch fragen sie nach dem Tor und nach dem Kamin. Fragt dich jemand nach dem Papier: Halten wir dicht, oder sagen wir es beide?““ |
| 2 | Serkans Auslöser 2 | dieselbe Datei | **S. 2**: „2. Sobald Hanas Geheimniskarte offen auf dem Tisch liegt.“ |
| 3 | Wojtek R1 Ziel 2 | `12-zusatzheft-wojtek.txt` (p20) | **S. 2**: „Ziel 2 · Hana: „Hana, um halb zwölf hat der Kamin den ganzen Kaminsaal vollgequalmt. Warst du das? Und was hast du da hineingesteckt?“ Stell diese Frage vor allen. Ruf dafür den Erzähler.“ |
| 4 | Hanas Auslöser 3, Sperre | `12-zusatzheft-hana.txt` (p20) | **S. 2**: „3. Sobald dich jemand vor allen fragt, was du in den Kamin gesteckt hast.“ Keine Zeile „Frühestens in Runde 2“ (Sperren nur Wojtek, Aylin: ZR 0.1 ZG-04). Ihre Karte nennt Serkans Ausrede („Um 23:56 Uhr wollte er keine Decken aus dem Auto holen.“) |
| 5 | Azra, Aylin R1 Ziel 2 an Serkan | `12-zusatzheft-azra.txt`, `12-zusatzheft-aylin.txt` (p20) | je **S. 3**: Azra „… Was wolltest du da draußen?“, Aylin „… Wohin, und warum?“ (Aylin erst ab 19; bei 18 reicht Wojteks Kette) |
| 6 | Damir R2 Ziel 2, Sibels Auslöser | `12-zusatzheft-damir.txt` **S. 3**, `12-zusatzheft-sibel.txt` **S. 2** | wörtlich wie gemeldet; FM9 und YT4 stehen im Detektivbogen „ab Runde 1“ (`01-detektivbogen.txt` S. 3). Sibels und Damirs Karten ziehen sich gegenseitig nach (je Auslöser 2) |
| 7 | Andere Besetzung / Detektiv m | `druck-r3/text/m/kammerspiel-U4YRK-p20/…serkan.txt` Z. 139 f., `…damir.txt` Z. 152 f.; `r3/p1-druck/p18/*.pdf` per `pdftotext` | gleicher Wortlaut in 20 m und 18 w; Inhalt ohne Platzhalter (`rollen/14-serkan.json`, `rollen/12-damir.json`), also in jeder Besetzung, in der die Rolle spielt (Serkan ab 16, Damir ab 14) |
| 8 | Fängt ein anderer Text das ab? | Erzählerheft p20 (Rundenaufbau S. 3, Runde 2 S. 11, Tischregeln S. 14), „So spielt ihr“, Ausweichregel, Detektivbogen „Heute bei 20 Personen“ | nein. Die einzige Ersatzregel („Fehlt dein Ziel, frag stattdessen …“) gilt nur für eine fehlende Rolle. Keine Regel für einen überholten Auftrag. In Runde 2 hat niemand Serkan oder Damir als Ziel (alle 8 Zusatzhefte, Teil 10 geprüft) |
| 9 | Bewusste Entscheidung? | ENTSCHEIDUNGEN.md E1–E22, FALL-BIBEL MECH 12a, WELT 0.3, 19.2, TESTPROTOKOLL, tests/*.md | nein. Die Flüster-Aufträge kamen mit P14-09, die frühe Öffnung von Tandem 2 mit P145R2-M05 (Hanas Auslöser „vor allen“, Wojteks Frage vor allen). Die Wechselwirkung wurde nie geprüft; ZR 0.4 nennt beides nebeneinander („In Runde 1 fragt Wojtek Hana vor allen …, in Runde 2 spricht Serkan leise mit Hana“) |
| 10 | Wirkung am Tisch real? | Ablauf Erzählerheft p20 S. 3 und S. 11: Abschnitt b 17 min, ab 18 Personen Gegenüberstellung 7 min nach der Hälfte, dann „Wechsel!“ | ja. Serkans Ziel 1 liegt in der ersten Hälfte (gut 5 min): Er soll über „Dichthalten“ flüstern, obwohl seit Runde 1 beide Karten offen liegen. Damirs Ziel 2 liegt nach „Wechsel!“ (gut 5 min): gleiches Bild, wenn Tandem 1 offen ist. Bei der Gegenüberstellung fragen beide ihr anderes Ziel (Fatma, Ahmet), das ist unberührt |

## Kette bei 18 bis 20 Personen (aus dem Druck)

1. Runde 1, nach „Wechsel!“: Wojtek ruft den Erzähler und fragt Hana vor allen, was sie in den Kamin gesteckt hat.
2. Hanas Auslöser 3 greift sofort (keine Sperre) → „Karte!“, Karte offen; ihr „Und noch etwas“ nennt Serkans Ausrede.
3. Serkans Auslöser 2 greift sofort → Karte offen. Zusätzlich fragen Azra (ab 17) und Aylin (ab 19) nach dem Warum
   (Auslöser 1).
4. Runde 2, erste Hälfte: Serkans Heft sagt „Sprich leise mit Hana: … Halten wir dicht, oder sagen wir es beide?“ – beides
   liegt offen. Toter Auftrag.

Bei 16 bis 17 Personen kann dasselbe eintreten (RK 6.12-Frage des Detektivs, Impuls I-1.3, Azra ab 17), ist aber nicht
planmäßig. Damirs Teil gilt ab 14 Personen, sobald FM9 oder YT4 in Runde 1 gezogen wurde, jemand den Vitrinen-Vorwurf
vor allen erhob oder Tandem 1 beim „Reinen Tisch“ der Runde 1 umdrehte.

## Schwere

mittel: toter Auftrag mit Leerlauf von gut fünf Minuten je Rolle, in Runde 2 hat keine andere Rolle Serkan oder Damir als
Ziel. Der Fall bleibt lösbar, nichts wird falsch oder verraten, also kein Blocker.

## Vorschlag (umsetzbar ohne weiteres Suchen)

Konvention aus SCHEMA.md §4 („Etiketten vor Varianten fett und je auf eigener Zeile“), wie bei Azra R2-2, Aylin R2-1,
Sibel R2-1. Beide Tandems drehen gegenseitig um (je Auslöser 2), „Karte des Partners offen“ heißt also „beide offen“.
Keine Platzhalter nötig: Hana (13) und Sibel (11) haben kleinere Plätze und spielen immer, wenn Serkan (ab 16) bzw. Damir
(ab 14) spielt (ZG-09, ZG-10). Alle Sätze unter 25 Wörtern, Uhrzeit in Worten (ZG-11, ZG-12).

### 1. `content/kammerspiel/schlosskeller/rollen/14-serkan.json`, `$.gespraechsauftraege[2].frage` (runde 2, nr 1, ziel hana)

Alt:
```
**Sprich leise mit Hana:** „Am Tisch fragen sie nach dem Tor und nach dem Kamin. Fragt dich jemand nach dem Papier: Halten wir dicht, oder sagen wir es beide?“
```
Neu:
```
**Hanas Karte offen:** „Hana, jetzt ist es raus. Dein Brief liegt unter der Asche in der Kamin-Nische. Lag da sonst noch etwas? Sag es allen.“\n**Hanas Karte zu:** **Sprich leise mit Hana:** „Am Tisch fragen sie nach dem Tor und nach dem Kamin. Fragt dich jemand nach dem Papier: Halten wir dicht, oder sagen wir es beide?“
```
Begründung: Serkans Wissen stützt sich nur auf Hanas offene Karte („liegt unter der Asche in der Kamin-Nische“, ZG-08).
Die Antwort steht in Hanas Heft unter „Nach dem Umdrehen“: „Den alten Arbeitshandschuh in der Nische hab ich um 23:20 Uhr
zur Seite geschoben. Er lag schon da. Wem er gehört, weiß ich nicht.“ Das ist wahr, nennt niemanden und erfüllt keinen
Pflicht-Auslöser der vier (Ollis Auslöser a–c, Fatmas a–c geprüft; ZG-15). Es lenkt zur Kamin-Nische (VP7, ab Runde 3).
(Gegenüber dem Vorschlag des Prüfers ohne „Du hast in der Kamin-Nische Ruß gewischt“: Das stammt aus Hanas gesprochenem
Satz, nicht aus Serkans Wissen oder einer offenen Karte.)

### 2. `content/kammerspiel/schlosskeller/rollen/12-damir.json`, `$.gespraechsauftraege[3].frage` (runde 2, nr 2, ziel sibel)

Alt:
```
**Sprich leise mit Sibel:** „Wenn am Tisch die Vitrine Thema wird und jemand anderes für unseren Sprung geradestehen soll: Sagen wir es dann selbst, am Ende der Runde?“
```
Neu:
```
**Sibels Karte offen:** „Sibel, unser Sprung ist jetzt raus. Sag allen, ob um neun die Münzschatulle noch in der Vitrine lag.“\n**Sibels Karte zu:** **Sprich leise mit Sibel:** „Wenn am Tisch die Vitrine Thema wird und jemand anderes für unseren Sprung geradestehen soll: Sagen wir es dann selbst, am Ende der Runde?“
```
Begründung: Die Antwort steht wörtlich in Sibels „Nach dem Umdrehen“ („Um 21:00 Uhr lag die Münzschatulle noch in der
Vitrine. Seitdem war die Scheibe lose. Man musste sie nur anheben.“), Damir kennt sie selbst (sein „Nach dem Umdrehen“).
Sie erfüllt keinen Auslöser Fatmas (NN3; FM9 mit Marker auf der Klappe; Emines Karte), drückt aber auf Fatmas
Heimlichtuerei (M5).

### 3. FALL-BIBEL mitziehen (Spezifikation = Druck)

- ZR 4.8, Zeile Runde 2 Nr 1 und ZR 2.8, Zeile Runde 2 Nr 2: Wortlaut wie oben; Spalte „Worauf du hinauswillst“ ergänzen:
  „Karte offen: Hanas Handschuh-Satz kommt vor allen; lenkt zu VP7“ bzw. „Karte offen: Schatulle um 21:00 noch da; Druck
  auf Fatma (M5)“.
- ZR 0.4 (Tandem 1 und 2) und ZR 9.2 (Zeilen „Damir → Sibel (leise)“, „Serkan → Hana (leise)“): „… sind die Karten noch zu“.

Zum Nachprüfen nach der Änderung: `dart run bin/party_druck.dart --personen 16|18|20` (Serkan) und `--personen 14`
(Damir); im Zusatzheft S. 3 müssen beide Etiketten auf eigenen Zeilen stehen. Der Test `textregeln_test.dart` zitiert
Damirs alten Satz nur als Literal und liest die Datei nicht, er bleibt grün.
