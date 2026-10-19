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

**Prüfen (optional):** Lade `SHA256SUMS.txt` in denselben Ordner und führe `sha256sum -c SHA256SUMS.txt` aus.

---

## 3. Die Detektei

Beim Start öffnet sich die **Detektei**. Beim allerersten Start fragt sie nach deinem Namen.

- **Neuer Abend**: Der Assistent führt dich zu einem Abend (Abschnitt 4).
- **Beitreten**: Du trittst mit einem Raumcode dem Abend eines anderen Geräts bei (Abschnitt 5.3).
- **Kampagne**: Die fünf Akten in Reihenfolge. Tippe eine Akte an, dann auf **Diese Akte spielen**.
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
   - *Name des Detektivs* und *Detektiv oder Detektivin*.
   - *Rollen am Tisch* (Schlosskeller): Bei „Ein Gerät reihum“ trägst du auf Wunsch einen **Erzähler** ein. Er liest
     vor und führt weiter, ermittelt aber nicht. Bei „Jeder am eigenen Gerät“ wählst du **Dein Platz**:
     *Detektiv* (du ermittelst) oder *Erzähler* (du liest vor, ein Gast ermittelt). Die anderen Akten kennen
     keinen Erzähler-Platz; dort ermittelst du am Gastgeber-Gerät.
   - *Der Fall*: **Zufall** oder **Code eingeben**. Mit demselben fünfstelligen Fall-Code spielt ihr denselben
     Fall noch einmal.
   - *Rundendauer*: 20, 30, 45 oder 60 Minuten. Das ist die Gesprächsuhr am Tisch. Bei „Solo mit Bots“
     entfällt sie.
   - *Erzählerstimme*: Sie liest die festen Texte vor und ist anfangs aus. Gibt es auf dem Gerät keine
     deutsche Stimme, bleibt der Text auf dem Bildschirm.
4. **Start.** Eine Zusammenfassung zeigt Akte, Spielweise, Personen und Rundendauer. Darunter siehst du dein
   **Deck** für diesen Abend. Mit **Deck ändern** passt du es an. Dann tippst du auf **Abend beginnen**
   (bei „Jeder am eigenen Gerät“ auf **Raum öffnen**).

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
- Bots halten keine Karten. Dein Deck liegt als Hilfe auf dem Tisch.
- Der Abend wird nicht gespeichert. Lädst du die Seite neu oder schließt du die App, beginnst du von vorn.

### 5.2 Ein Gerät reihum

Ein Gerät geht am Tisch von Hand zu Hand. **Geheimes ist nur in der verdeckten Ansicht sichtbar.**
Diese Ansicht ist ein Schutz gegen Mitlesen, keine technische Sperre. Alle anderen schauen weg.

1. Jemand **außer der ermittelnden Person** richtet den Abend ein. Die ermittelnde Person schaut weg.
2. **Rollen lesen.** Das Gerät geht reihum.
   - Tippe auf die Zeile der Person, die gerade dran ist.
   - Die Person tippt auf **„Ich bin …, zeig her“** und liest ihr Dossier. Es hat die Teile
     *Wer ich bin*, *Was ich weiß*, *Was ich verberge*, *Mein Ziel heute Nacht*, *Meine Pflichtgespräche* und
     *Meine Rundenwahl*.
   - Mit **„Fertig, Bildschirm zudecken“** wird der Bildschirm wieder verdeckt.
   - Haben alle ihre Rolle gesehen, tippst du auf **„Alle kennen ihre Rolle“**.
   - Mit Erzähler am Tisch liegen die Erzähltexte im **Erzählerpult** zugedeckt. Das Gerät geht an den Erzähler.
     Er tippt auf **„Ich bin …, zeig her“**, liest vor und deckt mit **„Gelesen, zudecken“** wieder zu. Ab dem Finale
     lesen alle mit.
   - Bequemer ist **„Am eigenen Handy lesen“** am Pult (mit Internet): Das Gerät zeigt Code und QR-Code, der
     Erzähler tritt wie ein Gast bei (Detektei → **Beitreten**). Sein Handy zeigt die Texte und sein
     Erzählerpaket, und er tippt dort auf **Weiter**. Das Gerät am Tisch zeigt nur noch „… liest vor“. Ist sein
     Handy weg oder tippt ihr auf **„Wieder am Pult lesen“**, liegt der Text wieder im Pult.
3. **Gruppenwahl.** Jede Person wählt geheim zwischen zwei Handlungen. Die Liste zeigt nur, *wer* schon
   gewählt hat. Eine Stimmenzahl steht nie auf dem Bildschirm.
4. **Würfeln.** Das Gerät geht an den angezeigten **Würfelpaten**. Er wechselt nach jedem Wurf.
5. Alles andere sehen alle zusammen: Karte, Funde, Sprechblasen, Resümee, Finale.

Fällt jemand vor dem Start aus, stell die Personenzahl neu ein. Die fehlenden Rollen bleiben als Figuren im
Spiel. Nach dem Start lässt sich die Besetzung nicht mehr ändern. Auch dieser Abend wird nicht gespeichert.

### 5.3 Jeder am eigenen Gerät

Jede Person spielt mit dem eigenen Handy. Ein Gerät, das **Gastgeber-Gerät**, führt den Abend. Es gibt drei
Arten von Plätzen:

- **Detektiv**: ermittelt, befragt, wählt die Spuren und klagt an. Nur dieses Gerät hat Detektivkarte und Klasse.
- **Erzähler** (nur Schlosskeller): liest die Texte vor und tippt auf **Weiter**. Er sieht sein Erzählerpaket mit
  Tischgesprächen, Befragungen samt Antwort und dem Wissen ungespielter Gäste, aber nie ein Dossier.
- **Rolle**: spielt eine Figur mit eigenem Dossier.

Der Gastgeber sitzt als Detektiv oder als Erzähler am Tisch. **„Wer macht was?“** (im Assistenten, in der Lobby
und in der Leiste des Abends) zeigt für jeden Platz die Aufgabe in jedem Abschnitt.

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
     startet kein Abend.
   - die **Rollen**: Mit **Weniger Rollen** und **Mehr Rollen** legst du die Zahl fest. Sie ist mindestens so
     groß wie die Zahl der Gäste und höchstens so groß wie die Zahl, die die Akte kennt. **Bots übernehmen
     die freien Rollen.**
5. Sind alle Gäste online und bereit, steht dort **„Alle sind bereit.“** Tippe auf **Abend starten**.
6. Als Detektiv führst du den Abend wie ein Solo-Abend. Als Erzähler zeigt dein Gerät das **Erzählerpult**:
   den Text zum Vorlesen, wen der Detektiv befragt, dein Erzählerpaket und in der Ermittlung eine
   **Zuschauerkarte**. Du tippst auf **Weiter**, sobald der Abschnitt fertig ist. In der Rollenphase und bei der Gruppenwahl zeigt dir das Gerät, wer
   schon gelesen oder gewählt hat. Oben steht eine schmale Leiste mit dem Raumcode und der Zahl der Gäste.
   Das Menü dort zeigt den Tisch und bietet **Abend beenden** (für alle).

**Als Gast**

1. Detektei → **Beitreten**.
2. Gib den **Raumcode** ein. Groß- und Kleinschreibung, Leerzeichen und Bindestrich sind egal. Spielt der Gastgeber
   in der Web-Fassung, kannst du auch den **QR-Code scannen**. Er öffnet die Web-Fassung mit eingetragenem Code.
   Spielt er in der Android- oder iOS-App, enthält der QR-Code nur den Code. Tippe ihn dann bei **Beitreten** ein.
3. Gib deinen Namen ein und tippe auf **Beitreten**.
4. Tippe auf **Bereit**. Mit **Doch nicht bereit** nimmst du es zurück.
5. Nach dem Start liest du **Deine Rolle** (das Dossier). Tippe danach auf **Gelesen**. Nur du siehst es.
   Hast du den Detektiv-Platz, siehst du statt eines Dossiers deine **Detektivkarte**. Du befragst, wählst die
   Spuren auf deiner Karte und klagst an, alles am eigenen Handy. Hast du den Erzähler-Platz, liest du vor und
   tippst auf **Weiter**. Fällt dein Handy als Erzähler aus, liest nach zwei Minuten der Gastgeber.
6. Pro Runde siehst du **deine Gespräche** mit Thema, Ziel und Eröffnung. Dazu kommt **Deine Wahl in dieser
   Runde**: Tippe eine Karte an und dann auf **Wahl abgeben**. Niemand sieht, was du wählst.
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

---

## 6. Der Ablauf eines Abends

Die Abschnitte kommen in dieser Reihenfolge: **Rollen → Intro → drei Runden → Anklage → Finale →
Auflösung → Ende → Belohnung.**

**Intro.** Der Erzähler stellt Ort, Abend und Figuren vor. Im Schlosskeller enthält das Intro drei kurze
Rückblicke auf Rollen (Sibel, Olli und Hana). Frag die Personen vorher, ob das für sie in Ordnung ist.

### Eine Runde

Jede Runde hat fünf Schritte.

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

### Anklage, Finale, Auflösung

- **Anklage.** Der Detektiv klagt eine der vier Verdächtigen an. Das ist endgültig.
- **Finale.** Eine Rückblende spielt die Nacht nach. Danach liest der Erzähler den Schluss.
- **Auflösung.** Zu jeder Rolle steht, was sie wirklich getan hat.

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

- In Schlosskeller und Gewölbe ermittelt der **Detektiv** oder die **Detektivin**; den Namen trägst du in der
  Einrichtung ein. In den Noir-Akten ermittelt der **Inspektor** oder die **Inspektorin**.
- Bei der Rollenzahl zählen die Rollen ohne den Detektiv. Alle weiteren Figuren der Akte spielt das Spiel als Gäste ohne Spieler.
- Jede Akte hat **Erkundungsorte** (Schlosskeller 8, Gewölbe 7, die drei anderen je 6).
- Den Schlosskeller gibt es auch als **Druckspiel** auf Papier: Akte öffnen → **Druckmappe**
  (siehe [Druckspiel Schlosskeller](partykrimi/ANLEITUNG.md)).

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
- Mit **Abend verlassen** (Gast) gibst du deinen Platz und deine Rolle auf.

**„Keine Antwort vom Gastgeber. Versuche es noch einmal.“** Die Verbindung hakt kurz. Tippe noch einmal.

**Ein Abend am Tisch ist weg.** Solo- und Reihum-Abende werden nicht gespeichert. Nach dem Neuladen oder Schließen
beginnt ihr neu. Der Fall-Code bringt euch zum selben Fall zurück.

**Android will die APK nicht installieren.** Erlaube die Installation aus dieser Quelle. Ersetzt sie eine ältere,
debug-signierte APK, deinstalliere die alte einmal.

**Die iOS-App startet nach einer Woche nicht mehr.** Das ist die Grenze einer kostenlosen Apple-ID.
Signiere die IPA mit AltStore oder Sideloadly neu.

**Keine Stimme.** Gibt es auf dem Gerät keine deutsche Stimme, steht der Text trotzdem auf dem Bildschirm.
Mit **Noch einmal vorlesen** liest der Erzähler erneut.
