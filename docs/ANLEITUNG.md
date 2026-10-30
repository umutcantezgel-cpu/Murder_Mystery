# Mordakte · Anleitung

Diese Anleitung gilt für das ganze Spiel. Sie ersetzt die früheren Anleitungen für Schlosskeller,
Gewölbe und die klassischen Fälle. Die Druckfassung des Schlosskellers hat eine eigene Seite:
[Druckspiel Schlosskeller](partykrimi/ANLEITUNG.md). Entwicklerthemen stehen in der
[README](../README.md).

**Inhalt**

1. [Was Mordakte ist](#1-was-mordakte-ist)
2. [Installieren](#2-installieren)
3. [Die Detektei](#3-die-detektei)
4. [Einen Abend vorbereiten](#4-einen-abend-vorbereiten)
5. [Die drei Spielweisen](#5-die-drei-spielweisen)
6. [Der Ablauf eines Abends](#6-der-ablauf-eines-abends)
7. [Enden und Belohnung](#7-enden-und-belohnung)
8. [Karten, Deck und Erkunden](#8-karten-deck-und-erkunden)
9. [Die fünf Akten](#9-die-fünf-akten)
10. [Wenn etwas hakt](#10-wenn-etwas-hakt)

---

## 1. Was Mordakte ist

Mordakte ist ein Krimi-Abend für den Tisch und für unterwegs. Es gibt **eine Kampagne aus fünf Akten**.
Jede Akte ist ein eigener Fall mit eigenen Figuren. Alle Akten laufen nach **denselben Regeln**.

- Eine Person ermittelt als Detektiv. Alle anderen spielen Gäste mit Rollen und Geheimnissen.
- Ein Abend hat **drei Runden**. Danach folgen Anklage, Finale, Auflösung und Ende.
- Jeder Fall ist **immer lösbar**. Der Würfel ändert nie einen Fakt und nie die Punkte.
- Am Ende gibt es **Karten und Erfahrungspunkte**. Die Karten bleiben dauerhaft auf deinem Gerät.

---

## 2. Installieren

Alle Dateien stehen auf der Seite der
[Releases](https://github.com/umutcantezgel-cpu/Murder_Mystery/releases). Diese Links zeigen immer auf das
neueste freigegebene Release:

| Gerät | Datei | Link |
| --- | --- | --- |
| Android | `mordakte.apk` | [Download](https://github.com/umutcantezgel-cpu/Murder_Mystery/releases/latest/download/mordakte.apk) |
| iPhone und iPad | `mordakte-ios-unsigned.ipa` | [Download](https://github.com/umutcantezgel-cpu/Murder_Mystery/releases/latest/download/mordakte-ios-unsigned.ipa) |
| Webserver | `mordakte-web.zip` | [Download](https://github.com/umutcantezgel-cpu/Murder_Mystery/releases/latest/download/mordakte-web.zip) |
| Erzählerakte (Druckspiel) | `erzaehlerakte.pdf` | [Download](https://github.com/umutcantezgel-cpu/Murder_Mystery/releases/latest/download/erzaehlerakte.pdf) |
| Erzählerakte („Dein Moment“) | `erzaehlerakte-dein-moment.pdf` | [Download](https://github.com/umutcantezgel-cpu/Murder_Mystery/releases/latest/download/erzaehlerakte-dein-moment.pdf) |
| Prüfsummen | `SHA256SUMS.txt` | [Download](https://github.com/umutcantezgel-cpu/Murder_Mystery/releases/latest/download/SHA256SUMS.txt) |

**Android**

1. Lade `mordakte.apk` auf das Handy und öffne die Datei.
2. Erlaube die Installation aus dieser Quelle, wenn Android danach fragt.
3. Spätere Versionen installierst du einfach über die alte. Alle Test-APKs tragen dasselbe Zertifikat.
4. Hattest du vorher eine ältere APK mit Debug-Signatur? Dann deinstalliere sie **einmal**. Dabei gehen
   lokale Karten und Fortschritte verloren.

**iPhone und iPad**

Die IPA ist **unsigniert**. Du brauchst AltStore oder Sideloadly und eine kostenlose Apple-ID.

1. Öffne die IPA mit AltStore oder Sideloadly auf deinem Computer.
2. Signiere sie mit deiner Apple-ID und installiere sie auf dem Gerät.
3. Mit einer kostenlosen Apple-ID läuft die App nur sieben Tage. Danach musst du sie **neu signieren**.

**Web**

Die Web-Fassung läuft im Browser. Entpacke `mordakte-web.zip` auf einem statischen Webhost, im
Wurzelverzeichnis. Wo das Spiel im Web erreichbar ist, hängt davon ab, wo es veröffentlicht wurde. Frag
deinen Gastgeber nach der Adresse.

**Erzählerakte (PDF, Schlosskeller)**

Die beiden PDFs sind die Erzählerakte zum Ausdrucken (Abschnitt 5.4). Sie sind **nur für die Person, die erzählt**,
und nennen nie den Täter. Sie gelten für jede Personenzahl: Alle Figuren stehen in der Reihenfolge der Besetzung,
ohne Marken für einen bestimmten Abend. `erzaehlerakte.pdf` nennt die Ziele wie im Druckspiel,
`erzaehlerakte-dein-moment.pdf` die zwei Sterne je Figur für einen Abend mit „Dein Moment“. Alle anderen PDFs
(Rollenhefte, Erzählerheft, Auflösung) erstellt die App: Detektei → **PDFs zum Ausdrucken** (Abschnitt 3).

**Prüfen (optional):** Lade `SHA256SUMS.txt` in denselben Ordner und führe `sha256sum -c SHA256SUMS.txt` aus.

---

## 3. Die Detektei

Beim Start öffnet sich die **Detektei**. Beim allerersten Start fragt sie nach deinem Namen.

- **Neuer Abend**: Der Assistent führt dich zu einem Abend (Abschnitt 4).
- **Beitreten**: Du trittst mit einem Raumcode dem Abend eines anderen Geräts bei (Abschnitt 5.3).
- **Kampagne**: Die fünf Akten in Reihenfolge. Tippe eine Akte an, dann auf **Diese Akte spielen**.
- **PDFs zum Ausdrucken**: Der Knopf steht unter der Mappe jeder Akte mit Druckfassung (bisher nur der
  Schlosskeller) und unten auf der Seite der Akte. Er öffnet die **Druckmappe**. Dort stellst du Personen, Detektiv
  oder Detektivin und den Fall ein und tippst auf **Druckmappe vorbereiten**. Danach gibt es **Alles in einer
  Datei**, einen Knopf je Datei, **Rollenhefte einzeln senden** und unter **Nur Erzähler** die **Erzählerakte** für
  die Person, die erzählt. Dabei entsteht kein Abend. Jede Datei entsteht erst beim Tipp und geht dann an das
  Teilen des Telefons; im Browser tippst du ein zweites Mal auf **Herunterladen** (Details:
  [Druckspiel Schlosskeller](partykrimi/ANLEITUNG.md)).
- **Sammlung**: Deine Karten. Dazu gehört das **Deck** (Abschnitt 8).
- **Profil**: Name, Rang, Erfahrung und deine Dienstakte.

Hast du noch einen Platz in einem Online-Abend, erscheint oben ein Banner **„Zurück in Raum …“** oder
**„Zurück zum Abend …“**. Das ist der Weg zurück nach einem Abbruch (Abschnitt 10).

---

## 4. Einen Abend vorbereiten

Tippe auf **Neuer Abend**. Der Assistent hat vier Schritte.

1. **Akte.** Wähle, welchen Fall ihr spielt. Kommst du von der Seite einer Akte, steht sie schon fest.
2. **Spielweise.** Wähle zuerst, *wie* ihr spielt:
   **Solo mit Bots**, **Ein Gerät reihum** oder **Jeder am eigenen Gerät**.
3. **Einstellungen.** Die Abschnitte hängen von der Spielweise ab:
   - *Personen am Tisch*: nur bei „Ein Gerät reihum“. Du stellst die Zahl der Rollen mit dem Regler ein.
     Jede Rolle hat ein Feld für den Namen. Ohne Namen heißt jede Person wie ihre Figur.
   - *Name des Detektivs* und *Detektiv oder Detektivin*. Führt die Gästeliste der Akte (Akte → **Steckbriefe &
     Übersicht**) einen Detektiv, steht sein Name schon im Feld, reihum wie online.
   - *Rollen am Tisch* (Schlosskeller): Bei „Ein Gerät reihum“ trägst du auf Wunsch einen **Erzähler** ein. Er liest
     vor und führt weiter, ermittelt aber nicht. Bei „Jeder am eigenen Gerät“ wählst du **Dein Platz**:
     *Detektiv* (du ermittelst) oder *Erzähler* (du liest vor, ein Gast ermittelt). Die anderen Akten kennen
     keinen Erzähler-Platz; dort ermittelst du am Gastgeber-Gerät.
   - *Der Fall*: **Zufall** oder **Code eingeben**. Mit demselben fünfstelligen Fall-Code spielt ihr denselben
     Fall noch einmal.
   - *Wie spielt ihr?* (Schlosskeller, nur bei „Ein Gerät reihum“): **Am Bildschirm** oder **Zum Drucken**. Beim
     Druckspiel kommt die Druckfassung als PDF, der Bildschirm führt trotzdem durch den Abend
     ([Druckspiel Schlosskeller](partykrimi/ANLEITUNG.md)). Darunter steht: „Nur die PDFs, ohne Abend? Die gibt es
     bei der Akte unter PDFs zum Ausdrucken.“ Das ist nur ein Hinweis; deine Einstellungen bleiben (Abschnitt 3).
   - *Länge des Abends* (Schlosskeller): **Kurzer Abend** oder **Langer Abend**. Der lange Abend ist ein
     Streifzug durch Schloss, Hof und Garten, mit Vorspiel am Anfang und Morgen am Ende.
   - *Einstimmung* (Schlosskeller): der Schalter **Vorgeschichte und Vorstellung**. Er ist anfangs an. Dann
     liest der Erzähler vor dem Auftakt eine kurze Vorgeschichte und stellt jede Figur vor (Abschnitt 6). Darunter
     steht, wie lange das dauert: etwa 7 Minuten bis 8 Rollen, 9 Minuten bis 14 Rollen, 11 Minuten bei mehr. Beim
     Druckspiel (**Zum Drucken**) ist der Schalter anfangs aus.
   - *Dein Moment* (Schlosskeller): der Schalter **Heimliche Züge in jeder Runde**. Er ist anfangs an. Dann zieht
     jede Rolle in jeder Runde geheim einen Zug (Abschnitt 6). Ist er aus, spielt ihr die Gruppenwahl wie bisher.
     Beim Druckspiel gibt es den Schalter nicht: Papier spielt immer mit Gruppenwahl.
   - *Rundendauer*: 20, 30, 45 oder 60 Minuten. Im Schlosskeller sind es beim kurzen Abend 10, 15 oder 20 Minuten,
     beim langen 20, 25, 30 oder 40. Das ist die Gesprächsuhr am Tisch. Bei „Solo mit Bots“ entfällt sie.
   - *Zeitschätzung* (Schlosskeller, nicht solo): Unter der Rundendauer steht **Ganzer Abend: ca. … Min.**,
     neben jeder Länge des Abends ebenso. Ist die Einstimmung an, rechnet die Schätzung sie mit. Beispiel: kurzer
     Abend mit 15 Minuten und 12 Rollen, ohne Einstimmung ca. 100 Minuten, mit Einstimmung ca. 110.
   - *Erzählerstimme*: Sie liest die festen Texte vor und ist anfangs aus. Gibt es auf dem Gerät keine
     deutsche Stimme, bleibt der Text auf dem Bildschirm.
4. **Start.** Eine Zusammenfassung zeigt Akte, Spielweise, Personen und Rundendauer, im Schlosskeller auch Länge,
   Einstimmung und „Dein Moment“. Darunter siehst du dein **Deck** für diesen Abend. Mit **Deck ändern** passt du
   es an. Dann tippst du auf **Abend beginnen** (bei „Jeder am eigenen Gerät“ auf **Raum öffnen**).

Bei einem Abend am eigenen Gerät legst du die Zahl der Rollen erst in der Lobby fest.

---

## 5. Die drei Spielweisen

### 5.1 Solo mit Bots

Du ermittelst allein. Bots spielen alle Gäste.

- Die Dossiers der Bot-Rollen bleiben **verschlossen**. Du hörst in jeder Runde ihre öffentlichen Aussagen
  als Sprechblasen. Behauptungen können falsch sein. Die Sprechblasen bleiben im **Notizbuch**.
- Die Bots wählen in der Gruppenwahl verdeckt. Sie arbeiten mit einer Wahrscheinlichkeit von 70 Prozent mit
  dir zusammen. Nur die Täterrolle kann mit ihrer Wahl sabotieren. Stimmen und Qualität der Hinweise bleiben
  geheim.
- Mit **„Dein Moment“** (Schlosskeller) gibt es keine Gruppenwahl. Die Bots ziehen ihren Moment selbst, jede
  Figur auf ihre Art: Pawel hilft fast immer, Can lenkt gern ab. Zu den Folgen raunen bis zu drei von ihnen einen
  kurzen Satz.
- Die **Einstimmung** liest die App: Der Text steht auf dem Bildschirm, mit Erzählerstimme liest sie ihn vor. Auf
  der Karte jeder vorgestellten Figur steht **„Die App spielt …“**. Eine Erzählerakte gibt es solo nicht.
- Bots halten keine Karten. Dein Deck liegt als Hilfe auf dem Tisch.
- Das Gerät legt den Abend nach jedem Schritt ab. Lädst du die Seite neu oder schließt du die App, steht in der
  Detektei **Abend fortsetzen**.

### 5.2 Ein Gerät reihum

Ein Gerät geht am Tisch von Hand zu Hand. **Geheimes ist nur in der verdeckten Ansicht sichtbar.**
Diese Ansicht ist ein Schutz gegen Mitlesen, keine technische Sperre. Alle anderen schauen weg.

1. Jemand **außer der ermittelnden Person** richtet den Abend ein. Die ermittelnde Person schaut weg.
2. **Rollen lesen.** Das Gerät geht reihum.
   - Tippe auf die Zeile der Person, die gerade dran ist.
   - Die Person tippt auf **„Ich bin …, zeig her“** und liest ihr Dossier. Es hat die Teile
     *Wer ich bin*, *Was ich weiß*, *Was ich verberge*, *Mein Ziel heute Nacht*, *Meine Pflichtgespräche* und
     *Meine Rundenwahl*. Mit „Dein Moment“ stehen statt der Rundenwahl **Deine Ziele** (zwei Sterne) und eine
     kurze Erklärung zu „Dein Moment“.
   - Mit **„Fertig, Bildschirm zudecken“** wird der Bildschirm wieder verdeckt.
   - Mit Erzähler am Tisch (Schlosskeller) steht in der Liste auch die **Erzählerakte**. Das Gerät geht an den
     Erzähler, er tippt auf **„Ich bin …, zeig her“** und liest sie allein (Abschnitt 5.4).
   - Haben alle ihre Rolle gesehen, tippst du auf **„Alle kennen ihre Rolle“**.
   - Mit Erzähler am Tisch liegen die Erzähltexte im **Erzählerpult** zugedeckt. Das Gerät geht an den Erzähler.
     Er tippt auf **„Ich bin …, zeig her“**, liest vor und deckt mit **„Gelesen, zudecken“** wieder zu. Ab dem Finale
     lesen alle mit. Am offenen Pult liegt auch der Knopf **Erzählerakte**.
   - Bequemer ist **„Am eigenen Handy lesen“** am Pult (mit Internet): Das Gerät zeigt Code und QR-Code, der
     Erzähler tritt wie ein Gast bei (Detektei → **Beitreten**). Sein Handy zeigt die Texte und sein
     Erzählerpaket, und er tippt dort auf **Weiter**. Das Gerät am Tisch zeigt nur noch „… liest vor“, mit dem
     Namen, mit dem das Handy beitrat. Den Platz hält dieses eine Handy: Ein anderes kommt mit dem Code nicht
     mehr hinein. Ist sein Handy weg oder tippt ihr auf **„Wieder am Pult lesen“**, liegt der Text wieder im
     Pult; **„Am eigenen Handy lesen“** zeigt dann einen neuen Code.
3. **Gruppenwahl.** Jede Person wählt geheim zwischen zwei Handlungen. Die Liste zeigt nur, *wer* schon
   gewählt hat. Eine Stimmenzahl steht nie auf dem Bildschirm.
   **Mit „Dein Moment“** gibt es keine Gruppenwahl. Stattdessen zieht jede Person in den Gesprächen geheim ihren
   Zug. Die Liste **Dein Moment** zeigt je Person nur *offen* oder *fertig*. Tippe auf die Zeile der Person und gib
   ihr das Gerät. Sie tippt auf **„Ich bin …, zeig her“**, wählt ihren Zug und tippt auf **„Das ist mein Zug“**.
   Erst wenn alle gezogen haben, geht es weiter.
4. **Würfeln.** Das Gerät geht an den angezeigten **Würfelpaten**. Er wechselt nach jedem Wurf.
5. Alles andere sehen alle zusammen: Karte, Funde, Sprechblasen, Resümee, Finale.

Mit „Dein Moment“ sieht nur der Erzähler, wer was gezogen hat: am offenen Pult oder am Erzähler-Handy, als Tafel
**Züge dieser Runde**. Sie ist nie zum Vorlesen da. Geht das Gerät an eine Person, schließt sich das Pult.

Fällt jemand vor dem Start aus, stell die Personenzahl neu ein. Die fehlenden Rollen bleiben als Figuren im
Spiel. Nach dem Start lässt sich die Besetzung nicht mehr ändern. Auch dieser Abend liegt nach jedem Schritt auf
dem Gerät und lässt sich mit **Abend fortsetzen** wieder aufnehmen.

### 5.3 Jeder am eigenen Gerät

Jede Person spielt mit dem eigenen Handy. Ein Gerät, das **Gastgeber-Gerät**, führt den Abend. Es gibt drei
Arten von Plätzen:

- **Detektiv**: ermittelt, befragt, wählt die Spuren und klagt an. Nur dieses Gerät hat Detektivkarte und Klasse.
- **Erzähler** (nur Schlosskeller): liest die Texte vor und tippt auf **Weiter**. Er sieht sein Erzählerpaket mit
  Tischgesprächen, Befragungen samt Antwort und dem Wissen ungespielter Gäste, aber nie ein Dossier. Dazu hat er
  die **Erzählerakte** (Abschnitt 5.4) und mit „Dein Moment“ die Tafel **Züge dieser Runde**.
- **Rolle**: spielt eine Figur mit eigenem Dossier.

Der Gastgeber sitzt als Detektiv oder als Erzähler am Tisch. **„Wer macht was?“** (im Assistenten, in der Lobby
und in der Leiste des Abends) zeigt für jeden Platz die Aufgabe in jedem Abschnitt; in den Akten ohne
Erzähler-Platz fehlt der Erzähler dort.

**Was du dafür brauchst:** Internet auf allen Geräten, dieselbe App-Version und eine gemeinsame Akte.
Du brauchst **keinen eigenen Server**. Der Abend läuft über ein Relais (Abschnitt „Technik“ unten).

**Als Gastgeber**

1. Detektei → **Neuer Abend** → Akte wählen → **Jeder am eigenen Gerät**.
2. Stelle Detektiv, Fall, Rundendauer und Erzählerstimme ein. Prüfe dein Deck.
3. Tippe auf **Raum öffnen**. Dein Gerät verbindet sich jetzt mit dem Relais.
4. In der **Lobby** siehst du:
   - den **Raumcode** mit sechs Zeichen (zum Beispiel `ABC-DEF`) und einen **QR-Code**,
   - **Code kopieren**, in der Web-Fassung auch **Link kopieren**,
   - die Liste **Am Tisch** mit dem Zustand jedes Gastes (*Bereit*, *Nicht bereit*, *Getrennt*). Tippe auf einen
     Platz, um ihm den **Detektiv-** oder **Erzähler-Platz** zu geben oder ihm eine **Figur** zuzuteilen (sonst
     lost der Start). Gäste können sich eine Figur wünschen; der Wunsch steht unter ihrem Namen. Ohne Detektiv
     startet kein Abend, und du brauchst selbst einen Platz. Gibst du einem Gast den Detektiv-Platz, liest du vor,
     solange der Erzähler-Platz frei ist. In Akten ohne Erzähler-Platz ermittelst immer du.
   - die **Rollen**: Mit **Weniger Rollen** und **Mehr Rollen** legst du die Zahl fest. Sie ist mindestens so
     groß wie die Zahl der Gäste und höchstens so groß wie die Zahl, die die Akte kennt. **Bots übernehmen
     die freien Rollen.** Die Zahl liegt im Raum; mit ihr startet der Abend, und alle sehen sie.
   - die **Gästeliste** dieses Geräts (Akte → **Steckbriefe & Übersicht**): Ihre Personenzahl ist die erste
     Rollenzahl. Tritt ein Gast mit einem Namen der Liste bei, bekommt er seine Figur; führt die Liste ihn als
     Detektiv und ist der Platz frei, bekommt er den Detektiv-Platz. Das geschieht je Gast einmal, danach gilt,
     was du änderst. **Figuren aus der Gästeliste** teilt erneut zu. Fällt eine Figur der Liste bei der
     eingestellten Rollenzahl weg, nennt ein Hinweis sie und ihren Gast.
5. Sind alle Gäste online und bereit, steht dort **„Alle sind bereit.“** Tippe auf **Abend starten**.
6. Als Detektiv führst du den Abend wie ein Solo-Abend. Als Erzähler zeigt dein Gerät das **Erzählerpult**:
   den Text zum Vorlesen, wen der Detektiv befragt, dein Erzählerpaket und in der Ermittlung eine
   **Zuschauerkarte**. Du tippst auf **Weiter**, sobald der Abschnitt fertig ist. Führt ein Gast als Erzähler
   weiter, steht das neben **Weiter**. In der Rollenphase und bei der Gruppenwahl zeigt dir das Gerät, wer
   schon gelesen oder gewählt hat. Mit „Dein Moment“ zeigt es in den Gesprächen, wer seinen Zug noch nicht
   gezogen hat. Weiter geht es erst, wenn alle gezogen haben. Wer leitet, kann vorher den **Letzten Aufruf**
   geben: Nach 60 Sekunden geht es weiter, und wer dann noch nicht gezogen hat, wartet diese Runde ab.
   Oben steht eine schmale Leiste mit dem Raumcode und der Zahl der Gäste.
   Das Menü dort zeigt den Tisch und bietet **Abend beenden** (für alle).
7. **Fällt der Gast-Detektiv aus**, steht unter der Leiste, dass er getrennt ist. Kommt er nicht zurück, tippe auf
   **Detektiv-Sitz weitergeben** und wähle, wer weiter ermittelt: du selbst (**Ich ermittle selbst**) oder ein
   verbundener Gast ohne Figur (bei mehr Gästen als Rollen). Wer eine Figur spielt, behält sie und übernimmt nie
   den Sitz. Die beiden tauschen die Plätze: Kommt der alte Detektiv zurück, liest er vor, wenn du selbst
   übernommen hast, sonst schaut er ohne Figur zu. Die Klasse bleibt beim Sitz. Wessen Platz wechselt, liest es
   als Meldung auf dem eigenen Gerät.

**Als Gast**

1. Detektei → **Beitreten**.
2. Gib den **Raumcode** ein. Groß- und Kleinschreibung, Leerzeichen und Bindestrich sind egal. Spielt der Gastgeber
   in der Web-Fassung, kannst du auch den **QR-Code scannen**. Er öffnet die Web-Fassung mit eingetragenem Code.
   Spielt er in der Android- oder iOS-App, enthält der QR-Code nur den Code. Tippe ihn dann bei **Beitreten** ein.
3. Gib deinen Namen ein und tippe auf **Beitreten**.
4. Tippe auf **Bereit**. Mit **Doch nicht bereit** nimmst du es zurück.
5. Nach dem Start liest du **Deine Rolle** (das Dossier). Tippe danach auf **Gelesen**. Nur du siehst es.
   Hast du den Detektiv-Platz, siehst du statt eines Dossiers deine **Detektivkarte**. Du befragst, wählst die
   Spuren auf deiner Karte und klagst an, alles am eigenen Handy. Später öffnet **Detektivkarte** unten auf der
   Seite sie wieder. Hast du den Erzähler-Platz, liest du vor und tippst auf **Weiter**. Fällt dein Handy als
   Erzähler aus, liest nach zwei Minuten der Gastgeber.
6. Pro Runde siehst du **deine Gespräche** mit Thema, Ziel und Eröffnung. Dazu kommt **Deine Wahl in dieser
   Runde**: Tippe eine Karte an und dann auf **Wahl abgeben**. Niemand sieht, was du wählst.
   Mit „Dein Moment“ pulsiert stattdessen der Knopf **Dein Moment**. Wähle deinen Zug und tippe auf **„Das ist
   mein Zug“**. Bis zu den Folgen kannst du ihn ändern. Dort stehen auch deine zwei Sterne und was du aus der
   Runde davor erfahren hast.
7. Du verfolgst die Ermittlung auf deinem Gerät: Würfel, Würfelprotokoll, Funde, Resümee, Anklage, Auflösung.
   Wenn du Würfelpate bist, tippst du auf **Würfeln**.
8. Am Ende tippst du auf **Belohnung ansehen**.

**Überzählige Geräte.** Gibt es mehr Gäste als Rollen, werden die übrigen Geräte **Assistenz**. Sie haben keine
eigene Rolle und keine Stimme. Sie verfolgen den öffentlichen Verlauf mit.

**Technik, kurz**

- Das Relais ist ein **Supabase-Realtime-Projekt**. Es gilt der **kostenlose Plan** mit seinen Grenzen. Er ist
  für Abende im Freundeskreis gedacht, nicht für große Veranstaltungen.
- Das Relais leitet nur Pakete weiter. Das **Gastgeber-Gerät entscheidet**. Der Verlauf liegt auf dem Gastgeber-Gerät.
- Die privaten Ansichten und alle Befehle laufen **Ende-zu-Ende-verschlüsselt** (X25519 und ChaCha20-Poly1305).
  Das Relais sieht nur verschlüsselte Pakete. Offen sind nur Raumcode, Akte, freie Plätze und öffentliche Schlüssel.
- Der Raumcode ist an den Schlüssel des Gastgebers gebunden. So kann sich niemand im Relais als Gastgeber ausgeben.
- **Das Gastgeber-Gerät muss im Vordergrund bleiben.** Lass den Bildschirm an. Geht die App in den Hintergrund,
  sehen die Gäste **„Gastgeber getrennt – Abend pausiert“**. Der Abend geht weiter, sobald du zurück bist.
- **Alle Geräte brauchen dieselbe App-Version.** Seit „Dein Moment“ gilt eine neue Fassung des Online-Protokolls.
  Ältere Apps kommen nicht in den Raum („Diese App-Version passt nicht zum Raum“).

### 5.4 Einstimmung und Erzählerakte (Schlosskeller)

**Wer die Einstimmung liest.** Vorgeschichte und Vorstellung liest, wer auch sonst vorliest.

- *Solo:* die App. Der Text steht auf dem Bildschirm; mit Erzählerstimme liest sie ihn vor.
- *Reihum mit Erzähler:* der Erzähler, aus dem Erzählerpult oder am eigenen Handy. Das Pult bleibt über die ganze
  Einstimmung offen. Das Gerät am Tisch zeigt allen die Karte der vorgestellten Figur.
- *Reihum ohne Erzähler:* jemand am Tisch liest den Text vom Bildschirm vor, oder die Erzählerstimme.
- *Jeder am eigenen Gerät:* der Erzähler-Sitz. Ist er frei oder getrennt, liest, wer sonst vorliest (Abschnitt
  5.3). Nur das Gerät, das vorliest, zeigt den Text. Alle anderen sehen das Kapitel und die Karte der Figur.
  Wer gerade vorgestellt wird, liest auf dem eigenen Gerät **„Du bist dran“**. **Weiter** und **… überspringen**
  tippt nur, wer leitet; auf dem Gastgeber-Gerät steht sonst, wer durch die Einstimmung führt.

**Die Erzählerakte** ist das Heft des Erzählers: Hintergründe aller Figuren und ihr Beziehungsnetz. Sie zeigt
alles außer dem Täter und ist in jedem Fall gleich.

- Reiter **Figuren**: erst die Figuren am Tisch, dann die ohne Spieler, dazu Herr Schneider und der Detektiv. Je
  Figur stehen Hintergrund, Bindungen, das Verhältnis zu Herrn Schneider, Motiv, Geheimnis, Nebendelikt,
  Loyalität, Ziele und Tipps für die Stimme. Mit „Dein Moment“ sind die Ziele die zwei Sterne, sonst das Ziel aus
  dem Dossier.
- Reiter **Netz**: ein Ring mit Herrn Schneider in der Mitte. Durchgezogene Linien kennt der ganze Tisch,
  gestrichelte nur du. Tippe auf eine Figur, dann treten ihre Bindungen hervor.

Wo sie liegt:

- *Reihum mit Erzähler:* in der Rollenphase als eigener Eintrag und am offenen Erzählerpult (Knopf
  **Erzählerakte**), beide verdeckt wie ein Dossier.
- *Erzähler-Handy* (reihum mit **„Am eigenen Handy lesen“**): Knopf **Erzählerakte** am Handy.
- *Jeder am eigenen Gerät:* Knopf **Erzählerakte** auf dem Erzähler-Sitz, beim Gast wie beim Gastgeber. Die Akte
  kommt aus dem eigenen Gerät und wird nie übertragen.
- **Nie** solo, nie für den Detektiv, eine Rolle oder die Assistenz. Ab dem Finale schließt sie sich.

**Als PDF.** In der offenen Erzählerakte steht unten neben **Schließen** der Knopf **Als PDF** (nur dort, nicht am
Eintrag, nicht am Pult). Er liefert `erzaehlerakte.pdf` in der Fassung, die du gerade siehst: mit „Dein Moment“ die
zwei Sterne je Figur, sonst die Ziele aus dem Dossier. Dazu kommt die Personenzahl des Abends; die Figuren am Tisch
stehen zuerst. Ein Fall-Code steht nicht darin. In der App öffnet sich das Teilen des Telefons, im Browser tippst du
ein zweites Mal auf **Herunterladen: Erzählerakte**. Schließt sich die Akte (Finale, Sitz gewechselt), entsteht
keine Datei mehr.

Gedruckt gibt es sie außerdem in der Druckmappe (Detektei → **PDFs zum Ausdrucken**, Abschnitt 3; Ziele wie im
Druckspiel) und am Release für jede Personenzahl (Abschnitt 2). Mehr dazu in
[Druckspiel Schlosskeller](partykrimi/ANLEITUNG.md).

---

## 6. Der Ablauf eines Abends

Die Abschnitte kommen in dieser Reihenfolge: **Rollen → Einstimmung → Vorspiel → Intro → drei Runden →
Anklage → Finale → Auflösung → Ende → Belohnung.** Die Einstimmung gibt es nur im Schlosskeller mit dem Schalter
„Vorgeschichte und Vorstellung“, das Vorspiel nur im langen Abend.

**Einstimmung.** Sie kommt nach dem Rollenlesen, vor allem anderen.

- **Vorgeschichte:** sieben kurze Teile, zusammen etwa fünf Minuten. Sie erzählen vom Schloss, von Herrn Schneider,
  wie die Clique entstand und wie es zu diesem Abend kam. Alles spielt *vor* dem Abend und verrät nichts über den
  Fall. Oben steht der Kapitelzähler, etwa „Vorgeschichte · 3 von 7“, mit einem Titel. Der Titel wird nicht
  vorgelesen.
- **Vorstellung:** Danach stellt der Erzähler jede Figur am Tisch vor, in der Reihenfolge der Rollen. Wer genannt
  wird, steht kurz auf; das sagt der Vorlesetext selbst. Die Karte auf dem Bildschirm zeigt Porträt, Name, Rolle,
  einen typischen Satz und **„gespielt von …“** (reihum nur mit eingetragenem Namen). Dann kommt ein Satz für alle
  Gäste ohne Spieler, zuletzt der Detektiv.
- **Vorgeschichte überspringen** und **Vorstellung überspringen** springen ans Ende des laufenden Teils. Danach
  geht es mit **Weiter** zum Intro, im langen Abend mit **Weiter zum Vorspiel**.

**Vorspiel** (nur langer Abend). Um 18 Uhr kommt die Clique an, mit einem Rundgang durch das Schloss.

**Intro.** Der Erzähler stellt Ort, Abend und Figuren vor. Im Schlosskeller enthält das Intro drei kurze
Rückblicke auf Rollen (Sibel, Olli und Hana). Frag die Personen vorher, ob das für sie in Ordnung ist.

### Eine Runde

Jede Runde hat fünf Schritte. Mit „Dein Moment“ läuft sie etwas anders (nächster Abschnitt).

1. **Rundenstart und Gespräche.** Der Erzähler spricht den Start. Die Gesprächsuhr am Tisch zeigt die gewählte
   Rundendauer. Sie ist nur eine Hilfe und schaltet nichts weiter. Jede Person führt ihre
   **Pflichtgespräche**. Wer mit wem spricht, steht im Dossier und auf dem Bildschirm.
   Die Gespräche führt ihr selbst, am Tisch oder in einem Sprach- oder Videochat eurer Wahl. Die App hat
   keinen eigenen Chat. Bei „Solo mit Bots“ hörst du die Gespräche als Sprechblasen.
2. **Ermittlung auf der Karte.** Der Detektiv trifft pro Runde **drei Entscheidungen**, insgesamt neun.
3. **Gruppenwahl.** Jede Rolle wählt geheim. Der Detektiv wählt nicht mit.
4. **Bonus-Hinweis.** Die Runde flüstert dem Detektiv etwas zu. Ob der Hinweis stimmt, sagt niemand.
5. **Zwischenresümee.** Es zeigt das Gruppenergebnis, den Stand der Verdächtigen und die Lage.

### Eine Entscheidung treffen

- Wähle ein Ziel auf der Karte (Person, Gegenstand oder Ort) oder **Aus einer Liste wählen**.
- Steuern: Joystick, Pfeiltasten oder WASD. Handeln: Knopf unten rechts oder Leertaste.
- Dein Tipp ist erst ein Vorschlag. **Die Entscheidung gilt erst mit „Ja, so machen wir es“.** Danach gibt es
  keinen zweiten Versuch.
- Danach **läuft die Figur sichtbar zum Ziel** und führt die Handlung aus. **Szene abkürzen** verkürzt nur die
  Darstellung, nie die Regeln.
- **Befragungen sind würfelfrei.** Beim Suchen würfelst du den **Würfel**. Vorher zeigt die App die
  **Chancen**: Lupe (Erfolg), Glühbirne (Teilerfolg), Gespenst (Pech). Bei „reihum“ geht das Gerät dafür an den
  Würfelpaten.
- **Gründlich suchen** gibt +2 auf den Wurf und kostet 2 Nachtminuten mehr. Eine **Marke** gibt
  +1. Insgesamt gilt höchstens +2; eine Werkzeugkarte verbraucht am Deckel keine Ladung.
- **Erfolg** gewinnt 7 Nachtminuten. **Pech** bringt eine Marke. Danach entscheidet der Tisch offen:
  **Nochmal** oder **Umweg**, je 3 Nachtminuten. Beides bleibt bei derselben Quelle. Der dritte Anlauf gelingt
  mindestens teilweise (**Pech-Garantie**).
- Jede Runde hat **45 Nachtminuten**. Das ist Spielzeit und unabhängig von der Gesprächsuhr.
- Danach erscheint der Fund unter **Was du findest**. Das **Notizbuch** hält alle Funde und das Würfelprotokoll.

Der Würfel steuert nur, *wie schnell* du an einen Fund kommst und wie viel Nachtzeit das kostet. Er ändert nie
einen Fakt, nie die Punkte und nie, ob der Fall lösbar ist.

### Erkunden (Abstecher)

Zwischen den Entscheidungen kannst du **freiwillig erkunden**. Das ist ein kurzer Blick in eine Ecke der Akte.

- Es kostet Nachtminuten (7, bei Pech 3 mehr) und geht nur, wenn danach noch genug Zeit für die offenen
  Entscheidungen bleibt.
- Es bringt Stimmung und einen **Nebenfund**, aber **nie einen Hinweis zum Fall**. Es ist auf allen
  Täter-Pfaden gleich.
- Bei Erfolg oder Teilerfolg findest du die **Karte** dieses Ortes. Du bekommst sie in der Belohnung am Abendende
  (Abschnitt 7).
- Mit einer **Abstecher-Karte** kostet der Gang keine Nachtminuten.

### Eine Runde mit „Dein Moment“ (Schlosskeller)

Mit „Dein Moment“ gibt es **keine Gruppenwahl**. Stattdessen zieht jede besetzte Rolle in jeder Runde geheim
einen Zug, Mensch wie Bot. Detektiv, Erzähler und Assistenz ziehen nicht. Der Fall-Code legt Täter und Wahrheit
fest. Die Züge ändern Würfel, Zeit, Gerüchte und Stimmung, nie die Wahrheit. Jeder Fall bleibt lösbar.

Die Runde läuft so:

1. **Gespräche und Dein Moment.** Während der Gespräche zieht jede Rolle ihren Zug (Abschnitt 5). Im langen
   Abend muss der Moment vor der ersten Entscheidung der Runde stehen.
2. **Die Folgen.** Zu Beginn der Ermittlung liest der Erzähler vor, was der Moment bewirkt hat: wer ausgepackt
   und wer abgelenkt hat, welche Gerüchte umgehen, wie sich die Leisten bewegen und welche Ereignisse kommen.
   Solo raunen dazu bis zu drei Bots. **Zur Ermittlung** legt das Blatt weg.
3. **Ermittlung** mit drei Entscheidungen, jetzt mit Tischwerten (unten).
4. **Flüstern** statt Bonus-Hinweis (unten).
5. **Zwischenresümee** mit den Leisten, den Ereignissen der Runde und unter **Jetzt sichtbar** den Funden, die
   bis jetzt gewartet haben. Ein Gruppenergebnis gibt es nicht.

**Die sechs Züge.** Jede Kachel zeigt ihre Wirkung in drei Stichpunkten.

| Zug | Ziel | Wirkung | Wer es erfährt |
| --- | --- | --- | --- |
| **Zeigen** | eine andere Figur | +1 Tischstimme auf jede Option dieser Runde, bei der die Figur vorkommt; der Spuk wächst | alle hören ein Gerücht über die Figur, ohne Quelle |
| **Decken** | eine Figur oder du selbst | −1 Tischstimme auf jede Option, bei der die Figur vorkommt | die Figur liest nur „Jemand hält zu dir“; gelingt dort eine Suche, kannst du auffliegen |
| **Helfen** | – | +3 Nachtminuten, zusammen höchstens +9 je Runde; der Zusammenhalt wächst | niemand bis zur Auflösung |
| **Auspacken** | – | dein Geheimnis kommt zu den Funden; der Zusammenhalt wächst doppelt; nur einmal am Abend | alle, mit deinem Namen |
| **Ablenken** | – | −4 Nachtminuten, zusammen höchstens −8 je Runde; der Spuk wächst doppelt, der Zusammenhalt sinkt | alle, mit deinem Namen und einem Auftritt |
| **Lauschen** | eine andere Figur | du erfährst Zug und Ziel dieser Figur in dieser Runde | nur du |

- Wer bis zu den Folgen nicht zieht, **wartet ab**. Das hat keine Wirkung, und niemand sieht es.
- Die Kachel **Wie letzte Runde** wiederholt deinen letzten Zug. Nach dem Auspacken ist die Kachel ausgegraut.
- Was du privat erfahren hast (Lauschen, „Jemand hält zu dir“, ob dein Zug etwas bewegt hat), steht in der
  nächsten Runde oben in deinem Moment. Aus Runde 3 zeigt es erst das Protokoll der Nacht.
- In Runde 3 gibst du dazu einen **geheimen Tipp** ab: „Wer war's?“, eine der vier Verdächtigen oder **Keine
  Ahnung**. Er bleibt bis zur Auflösung verdeckt und ändert die Anklage nicht.
- Beim Auspacken legen die vier Verdächtigen ihr Nebendelikt offen. Es zählt für die Regeln wie ein Fund und steht
  mit ihrem Namen im Notizbuch. Die anderen Figuren verraten eine Beobachtung.
- **Deine Ziele:** Jede Figur hat zwei geheime Ziele, die **Sterne**. Sie stehen im Dossier und in deinem Moment,
  mit Stand *offen*, *erreicht* oder *verloren*. Gewertet wird nach der Anklage.

**Tischwerte.** Zu jeder Option gehören feste Figuren, in allen Fällen gleich. Aus Zeigen und Decken auf diese
Figuren entsteht ein **Tischwert** von −2 bis +2: Zeigen zählt +1, Decken −1. Je Stufe braucht es bei bis zu
5 Rollen eine Stimme, bis 10 Rollen zwei, bis 15 drei, bis 20 vier. Figuren ohne Spieler zählen nicht. Vor der
Wahl steht der Wert als Abzeichen an der Option: **Rückendeckung +1**, **Volle Rückendeckung +2**,
**Störung −1** oder **Starke Störung −2**. Du siehst es in der Liste (**Aus einer Liste wählen**), in der
Rückfrage und bei den Gästen, nicht an den Zielen auf der Karte.

**Würfel mit Tisch.** Beim Suchen kommt der Tischwert zum Wurf dazu. Die Chancen zeigen ihn als Zeile **Tisch**.
Zusammen gilt dann −2 bis +3 statt höchstens +2. Ohne Tischwert bleibt alles wie oben.

- **Erfolg:** Fund und 7 Nachtminuten wie immer, dazu ein **Zusatzfund**: eine **Randnotiz** im Notizbuch. Das
  ist eine kleine Beobachtung, die in jedem Fall gleich gilt. Sie zählt nicht für die Regeln und ändert nie, wer
  noch verdächtig ist. Hat jemand eine Figur dieser Option gedeckt, fliegt ein Decker auf: **Ertappt!** Sein Name
  ist dann öffentlich.
- **Teilerfolg:** nur der Fund.
- **Pech:** eine Marke wie immer, dazu **Die Spur verwischt**. Verloren ist sie nicht. Der Tisch ruft, je
  3 Nachtminuten:
  - **Nochmal:** dieselbe Stelle, derselbe Tischwert. Zusatzfund und Ertappt bleiben möglich.
  - **Umweg:** +1 auf den nächsten Anlauf, und eine Störung zählt dann nicht. Dafür gibt es keinen Zusatzfund und
    kein Ertappt, und die Fakten kommen erst im Zwischenresümee.
- Die Pech-Garantie bleibt. Kein Fund geht verloren, er kommt höchstens später.

**Befragung mit Tisch.** Befragungen bleiben würfelfrei. Mit Rückendeckung ist die Person **redselig**: Es gibt
eine Randnotiz dazu. Bei Störung −1 **zögert** sie (3 Nachtminuten mehr). Bei −2 **mauert** sie: 3 Nachtminuten
mehr, und die Fakten kommen erst im Zwischenresümee.

**Nachtminuten.** Jede Runde beginnt mit 45 Nachtminuten. Dazu kommen bis zu 5 übrige Minuten der Runde davor,
Helfen und Ereignisse; Ablenken und Ereignisse ziehen ab. Es bleiben immer mindestens 42 Minuten.

**Leisten und Ereignisse.** Zwei Leisten von 0 bis 6 zeigen die Stimmung am Tisch: **Zusammenhalt** und **Spuk**.
Sie wachsen bei den Folgen, je Runde um höchstens 2.

- *Zusammenhalt:* Helfen zählt 1, Auspacken 2, Ablenken −1. Er wächst um 1, wenn die Summe ein Fünftel der Rollen
  erreicht, um 2 ab zwei Fünfteln.
- *Spuk:* Zeigen zählt 1, Ablenken 2. Er wächst um 1 ab einem Viertel der Rollen, um 2 ab der Hälfte.
- Gerechnet wird mit mindestens 5 Rollen. Beispiel bei 10 Rollen: Zwei Helfer bringen Zusammenhalt +1, vier +2.

Erreicht eine Leiste eine Stufe, kommt ihr Ereignis, jedes höchstens einmal am Abend:

| Leiste | Stufe | Ereignis | Wirkung |
| --- | --- | --- | --- |
| Zusammenhalt | 2 | **Tee für alle** | +5 Nachtminuten in dieser Runde |
| Zusammenhalt | 4 | **Goldener Schein** | bei der nächsten Suche zählt keine Störung |
| Zusammenhalt | 6 | **Schneider erinnert sich** | eine Nachfrage mehr vor der Anklage |
| Spuk | 2 | **Flackerlicht** | −3 Nachtminuten in dieser Runde |
| Spuk | 4 | **Die Fledermaus** | in dieser Runde zählt jede Störung doppelt, höchstens −2 |
| Spuk | 6 | **Geplatzter Kragen** | −5 Nachtminuten, der Morgen wird chaotisch |

**Flüstern.** Wuchs der Zusammenhalt in dieser Runde um 2, flüstert die Runde dem Detektiv einen wahren Hinweis zu.
Bei +1 kommt ein neutraler Hinweis, sonst „Diesmal flüstert dir niemand etwas zu.“ Falsche Hinweise gibt es mit
„Dein Moment“ nicht. Täuschen können nur die Spieler selbst.

**Nachfragen.** Nach Runde 3, vor der Anklage, werden übrige Nachtminuten zu Nachfragen: je volle 25 Minuten eine,
höchstens zwei, dazu eine durch „Schneider erinnert sich“. Jede Nachfrage zeigt zu einer eurer Entscheidungen eine
Randnotiz, die noch fehlt, etwa nach einem Umweg.

### Anklage, Finale, Auflösung

- **Anklage.** Der Detektiv klagt eine der vier Verdächtigen an. Das ist endgültig.
- **Finale.** Eine Rückblende spielt die Nacht nach. Danach liest der Erzähler den Schluss. Mit „Dein Moment“
  liest er vorher einen Satz zum Tischbonus, wenn es einen gibt (Abschnitt 7).
- **Auflösung.** Zu jeder Rolle steht, was sie wirklich getan hat. Mit „Dein Moment“ kommt mehr dazu
  (Abschnitt 7).

---

## 7. Enden und Belohnung

Die Anklage und die **Punkte** (richtige Entscheidungen, von 9) bestimmen das Ende. Alle Akten nutzen
dieselbe Matrix. Nur die Namen der Enden sind je Akte eigen.

| Anklage | Punkte | Ende | Erfahrung |
| --- | --- | --- | --- |
| richtig | 7 bis 9 | **Meister** | 300 |
| richtig | 0 bis 6 | **Teilerfolg** | 200 |
| falsch | 4 bis 9 | **Justizirrtum** | 120 |
| falsch | 0 bis 3 | **Eskalation** | 80 |

### Ende mit „Dein Moment“ (Schlosskeller)

- **Endwert.** In der Tabelle oben zählt statt der Punkte der **Endwert**: Punkte plus **Tischbonus**, zwischen
  0 und 9. Der Tischbonus ist +1, wenn der Zusammenhalt am Ende mindestens 4 ist, und −1 bei einem Spuk von
  mindestens 4. Beides zusammen gibt 0. Richtig oder falsch entscheidet allein die Anklage. Die Auflösung zeigt die
  Punkte trotzdem ohne Bonus.
- **Geklärt-Regel.** Hat Auspacken schon vor einer Entscheidung alle Fakten gezeigt, die ihre richtige Option
  bringen würde, zählt die Entscheidung als richtig, auch wenn ihr die andere gewählt habt. Das hebt Punkte nur an.
- **Auflösung.** Zum Text je Rolle kommt eine Zeile, wie die Nacht für die Figur ausging, je nachdem ob sie
  mindestens einen Stern erreicht hat. Dann folgen:
  - das **Protokoll der Nacht**: alle Züge aller Runden als Zeichen, mit Ziel. Die Züge der App sind markiert.
    Es wird nicht vorgelesen.
  - die **Sterne der Nacht** je Figur und die **Geheimen Tipps**,
  - Punkte, Tischbonus und Endwert,
  - die **Auszeichnungen**, vom Erzähler vorgelesen:
    - **Stern des Abends:** die meisten Wertungspunkte. Je Stern 3, als Spürnase 2, je gelungene Suche dort, wo du
      mit Zeigen Rückendeckung gegeben hast, 1 (höchstens 2), fürs Auspacken 1. Bei Gleichstand gewinnt, wer
      seltener ertappt wurde, dann die frühere Rolle.
    - **Spürnase:** wer richtig getippt hat. Die Täterrolle zählt nicht, sie kennt ihre Tat.
    - **Schlossgeist:** wer den meisten Spuk gemacht hat (Zeigen 1, Ablenken 2).
    - **Treue Seele:** wer am häufigsten andere gedeckt hat.
  - zum Schluss der **Morgen**: warm bei Zusammenhalt ab 4 und Spuk unter 4, chaotisch bei Spuk ab 4 und
    Zusammenhalt unter 4 oder nach „Geplatzter Kragen“, sonst gemischt.
- **Erfahrung.** Gäste mit Figur am eigenen Gerät bekommen zum Ende dazu: 15 je erreichtem Stern, 25 für den Stern
  des Abends und 10 als Spürnase. Für den Detektiv und an einem Gerät zählt das Ende nach dem Endwert.

Nach dem Ende kommt die **Belohnung**. Tippe die Karten an, um sie umzudrehen. Du bekommst:

- immer eine Karte **deiner Rolle** oder, als Detektiv, **deiner Detektivklasse**,
- bei einer richtigen Anklage die **Täterkarte**,
- beim **Meister**-Ende eine **legendäre Karte** der Akte,
- die Karten der **Abstecher**, die du gefunden hast,
- solo und reihum außerdem eine Karte einer **Figur, die an deinem Tisch saß** (so ist jede Figur auch ohne
  eigene Geräte sammelbar),
- **Erfahrungspunkte** für den Rang.

Hast du eine Karte schon, wird sie ein weiteres Exemplar. Jeder Abend wird nur **einmal** verbucht.
Jedes Gerät rechnet seine Belohnung selbst aus, in jeder Spielweise nach derselben Regel. Gäste bekommen die
Karten ihrer eigenen Rolle.

---

## 8. Karten, Deck und Erkunden

**Sammlung.** Es gibt Karten für **jede Figur jeder Akte** und für **fünf Detektivklassen**
(Forensikerin, Profiler, Ex-Polizist, Journalistin, Sanitäter). Sie bleiben **dauerhaft auf dem Gerät**.
Ungefundene Karten zeigt die Sammlung als Silhouette. Es gibt drei Seltenheiten: gewöhnlich, selten, legendär.
Ein Startset liegt schon beim ersten Öffnen bereit.

**Deck.** Dein Deck hat höchstens **drei Plätze**, je Kartenart eine Karte. Beim Start eines Abends bildet es den
**Tischvorrat**:

- höchstens **3 Karten**,
- höchstens **eine Karte je Art**,
- zusammen höchstens **4 Ladungen**.

Das gilt unabhängig von der Zahl der Spieler. Acht Spieler bringen nicht mehr Hilfe als einer. Bei „Jeder am
eigenen Gerät“ gilt das Deck des Gastgebers. Bots halten keine Karten.

**Wirkung.** Karten sind reiner Komfort. **Keine Karte ändert Option, Fakten, Punkte, Ende oder die Zahl der
Verdächtigen.** Es gibt diese Arten:

| Art | Wirkung |
| --- | --- |
| Werkzeug | +1 auf den nächsten Suchwurf (die Obergrenze +2 bleibt) |
| Marke | eine Marke dazu (+1 auf einen Wurf) |
| Zeit | Nachtminuten dazu, einmal je Runde und Karte |
| Gründlich | gründlich suchen ohne die 2 Nachtminuten |
| Nochmal / Umweg | nach Pech ohne Nachtminuten |
| Abstecher | ein Abstecher ohne Nachtminuten |
| Erinnerung | wiederholt öffentliche Sprechblasen |
| Aussehen | nur Kosmetik |

Du setzt eine Karte in deiner **Kartenhand** ein, im passenden Moment: beim Würfeln, nach Pech oder beim
Erkunden. Zeit-, Marken- und Erinnerungskarten spielst du zwischen den Zügen. Jede Karte hat eine oder zwei
**Ladungen**.

**Woher Karten kommen.** Von der Belohnung am Ende (Abschnitt 7) und von **Funden beim Erkunden**. Auf jeder
Kartenseite steht unter **So bekommst du sie**, wie du sie erspielst.

**Deck bauen.** Detektei → **Sammlung** → **Deck bearbeiten**, oder im Assistenten bei **Deck ändern**.
Tippe eine Karte an, um sie ins Deck zu legen. Eine Karte gleicher Art ersetzt die bisherige.

---

## 9. Die fünf Akten

| Akte | Ton | Rollen | Täter |
| --- | --- | --- | --- |
| **Spuk im Schlosskeller** · Das Buffet hinter dicken Mauern | Spuk | 4 bis 20 | vier Pfade (Ahmet, Fatma, Olli, Can); der Fall-Code bestimmt den Pfad |
| **Spuk im Gewölbe** · Ein Geburtstag auf Burg Schartenfels | Spuk | 4 bis 20 | feste Lösung (ein Pfad) |
| **Ravensmoor** · Ein Gewitter. Ein Herrenhaus. Ein Toter, der zu viele Geheimnisse kannte. | Noir | 4 bis 8 | vier Pfade |
| **Nachtexpress 1931** · Ein Toter im Schlafwagen. Ein Zug, den niemand verlassen kann. | Noir | 4 bis 8 | vier Pfade |
| **Blue Palm Motel** · Neonlicht, Hurrikan-Warnung und ein Toter in Zimmer 7 | Noir | 4 bis 8 | vier Pfade |

- Im Schlosskeller ermittelt der **Detektiv** oder die **Detektivin**; den Namen trägst du in der Einrichtung ein.
  Im Gewölbe heißt die ermittelnde Person weiter **Geburtstagskind**. In den Noir-Akten ermittelt der
  **Inspektor** oder die **Inspektorin**. So heißt auch der Platz in Lobby, Tisch und „Wer macht was?“.
- Bei der Rollenzahl zählen die Rollen ohne den Detektiv. Alle weiteren Figuren der Akte spielt das Spiel als Gäste ohne Spieler.
- Jede Akte hat **Erkundungsorte** (Schlosskeller 8, Gewölbe 7, die drei anderen je 6).
- Den Schlosskeller gibt es auch als **Druckspiel** auf Papier: **PDFs zum Ausdrucken** unter seiner Mappe in der
  Detektei oder auf der Seite der Akte öffnet die **Druckmappe** (Abschnitt 3,
  siehe [Druckspiel Schlosskeller](partykrimi/ANLEITUNG.md)).

---

## 10. Wenn etwas hakt

**Das Relais ist nicht erreichbar.** Das meldet der Gastgeber in der Lobby, ein Gast beim Beitreten.

1. Prüfe die Internetverbindung auf deinem Gerät. Tippe auf **Nochmal versuchen**.
2. Bleibt es dabei, kann das kostenlose Supabase-Projekt **pausiert** sein. Es pausiert nach sieben Tagen ohne Nutzung.
   Der Besitzer des Projekts muss es im Supabase-Dashboard **wieder aktivieren**.

**„Es gibt keinen Raum mit diesem Code, oder der Gastgeber ist nicht online.“** Prüfe den Code. Der Gastgeber muss
die Lobby geöffnet haben und online sein.

**„Der Raum ist voll.“ / „Der Abend hat schon begonnen.“** Nach dem Start kommen nur Geräte wieder herein,
die schon im Abend waren.

**„Diese App-Version passt nicht zum Raum.“ / „Die Fassungen der Akten passen nicht zusammen.“**
Aktualisiere die App **auf beiden Geräten** auf dieselbe Version.

**Der Gastgeber ging in den Hintergrund (Gäste sehen „Abend pausiert“).** Bring die App des Gastgebers wieder in den Vordergrund.
Der Abend setzt sich fort. Lass den Bildschirm des Gastgebers während des Abends an.

**Ein Gast ist getrennt, oder eine App wurde geschlossen.**

- *Gast:* Öffne die App. Auf der Detektei steht **„Zurück in Raum …“**. Tippe darauf. Dein Platz und deine Rolle sind noch da.
  Mit **Vergessen** gibst du den Platz auf.
- *Gastgeber:* Auf der Detektei steht **„Zurück zum Abend …“**. Der Abend liegt auf deinem Gerät. Tippe darauf,
  dann geht es weiter. Mit **Verwerfen** löschst du ihn.
- Ist ein Gast länger als zwei Minuten weg, stimmt ein Bot für seine Rolle. Er kann trotzdem zurückkehren.
- Ist der Gast auf dem Detektiv-Platz weg, vertritt ihn nach zwei Minuten der Gastgeber. Mit **Detektiv-Sitz
  weitergeben** geht es sofort weiter, mit dem Gastgeber oder einem Gast ohne Figur (Abschnitt 5.3).
- Mit **Abend verlassen** (Gast) gibst du deinen Platz und deine Rolle auf.

**„Keine Antwort vom Gastgeber. Versuche es noch einmal.“** Die Verbindung hakt kurz. Tippe noch einmal.

**Ein Abend am Tisch ist weg.** Solo- und Reihum-Abende liegen nach jedem Schritt auf dem Gerät. Nach dem Neuladen
oder Schließen steht in der Detektei **Abend fortsetzen**. Ist der Stand weg, bringt euch der Fall-Code zum selben
Fall zurück. Ein Stand aus der App-Version vor „Dein Moment“ läuft ohne diese Züge weiter.

**Android will die APK nicht installieren.** Erlaube die Installation aus dieser Quelle. Ersetzt sie eine ältere,
debug-signierte APK, deinstalliere die alte einmal.

**Die iOS-App startet nach einer Woche nicht mehr.** Das ist die Grenze einer kostenlosen Apple-ID.
Signiere die IPA mit AltStore oder Sideloadly neu.

**Keine Stimme.** Gibt es auf dem Gerät keine deutsche Stimme, steht der Text trotzdem auf dem Bildschirm.
Mit **Noch einmal vorlesen** liest der Erzähler erneut.
