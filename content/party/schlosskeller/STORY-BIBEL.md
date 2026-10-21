# Story-Bibel · Spuk im Schlosskeller

Erzeugt aus dem Kanon (Version 1.0.0). Nicht von Hand ändern: dart run bin/party_bibel.dart

## 1. Fall

- **Titel:** Spuk im Schlosskeller
- **Untertitel:** Das Buffet hinter dicken Mauern
- **Pfade:** Ahmet (ahmet), Fatma (fatma), Olli (olli), Can (can)
- **Kernverdächtige:** Ahmet (ahmet), Fatma (fatma), Olli (olli), Can (can)
- **Personen:** 4 bis 20 (Gezählt werden Rollen ohne den Detektiv (B-13).)
- **Finale:** 02:45
- **Morgen:** 07:00
- **Rundendauer:** 30 Minuten
- **Schwellen-Regel:** wahr, wenn 5 × kooperativ ≥ 3 × Rollen; sonst neutral, wenn 5 × kooperativ ≥ 2 × Rollen; sonst falsche Fährte

**Runden**

| Nr | Uhrzeit | Name | Kern |
|---|---|---|---|
| 1 | 00:30 | Das Alibi-Geflecht | Alle vier Kernverdächtigen haben gute Gründe, nahe der Theke gewesen zu sein. |
| 2 | 01:15 | Die Indizien-Filterung | Nebendelikte werden von echter Gewalt getrennt. |
| 3 | 02:00 | Die finale Gegenüberstellung | Bei gutem Spiel stehen zwei Restverdächtige dem Schlüsselbeweis gegenüber. |

**Endenmatrix**

| Kennung | Ende | Anklage | Punkte |
|---|---|---|---|
| ende_meister | Meister-Detektiv | richtig | 7–9 |
| ende_teilerfolg | Teilerfolg | richtig | 0–6 |
| ende_justizirrtum | Justizirrtum | falsch | 4–9 |
| ende_eskalation | Totale Eskalation | falsch | 0–3 |

**Regeln**

- **W-1:** Ein wahrer Bonus-Hinweis liefert einen wahren Baustein, entlastet aber nie allein einen Kernverdächtigen.
- **S-1:** Resümees nur aus dem Wissen des Detektivs; bei nur einer Restperson kein Name.
- **D-1:** Optionen mit 0 Punkten zeigen weder Schlüsselbeweis noch Zusatzindiz.
- **G-1:** Die Option B der Täterrolle (Sabotage) zählt netto −1. Vor der Auflösung wird weder die Qualität des Hinweises noch die Stimmenzahl gezeigt (E-025).
- **K-1:** Objekte, Marker und Licht auf der Karte sind vor dem Finale in allen Pfaden gleich.
- **P-1:** Pflichtgespräche geben nur pfadneutrales Wissen preis.

## 2. Setting

- **Setting-Kennung:** spuk_im_schlosskeller
- **Schauplatz:** Ein altes, etwas abgelegenes Schloss vor der Stadt. Gefeiert wird im großen Gewölbekeller unter dem Schlossturm. Darüber liegen das Erdgeschoss und der ummauerte Schlosshof.
- **Anlass:** Ein Wiedersehen der Clique. Ahmet hat den Keller über einen Gefallen organisiert: Er gestaltet umsonst das Programm des Adventsmarkts der Schlossstiftung. Um Mitternacht gibt es Torte und Tugbas Spiel „Blinde Kuh“.
- **Datum:** ein Samstag im November; draußen kalt und windig
- **Essen:** Offenes Buffet auf langen Holztischen: warmes Essen aus Warmhaltebehältern, frisches Brot, Dips und Gebäck.
- **Getränke:**
  - schwarzer Tee aus dem großen Teekocher
  - Kaffee
  - warmer, alkoholfreier Apfelpunsch
  - Wasser
  - Säfte
- **Empfang:** Hinter den dicken Mauern gibt es keinen Handyempfang, auch nicht im Schlosshof, im Erdgeschoss oder oben im Turm. Empfang gibt es erst draußen vor dem Außentor auf den Stufen zum Parkplatz. Ein Telefon gibt es im Schloss nicht.
- **Atmosphäre:**
  - Der Wind pfeift durch die Lichtschächte.
  - Schwere Holztüren quietschen im Luftzug.
  - Elektrische Kerzen flackern auf den Tafeln; echte Kerzen brennen nur im Messingkerzenständer an der Theke.
- **Brandschutz:** Im denkmalgeschützten Keller sind offene Flammen verboten. Erlaubt ist nur der Kerzenständer an der Theke, auf Schneiders Verantwortung, und der Kamin unter Aufsicht.
- **Ton:** Grusel mit Humor: quietschende Türen, Zugluft, flackerndes Licht, verpatzte Streiche. Herr Schneider überlebt immer; der Schlag ist nur Schatten und Geräusch.
- **Weitere Intro-Teile:**
  - ausfall

**Lacher**

| Zeit | Wer | Ort | Was | Trägt |
|---|---|---|---|---|
| 21:00 | Sibel (selin) | bei der Ritterrüstung (an_der_ruestung) | Sibel hält die alte Ritterrüstung im Turmgang für einen Menschen, schreit auf und stolpert rückwärts gegen die Schauvitrine. Die Scheibe bekommt einen feinen Sprung. | Spur: Ab 21:00 ist die Vitrinenscheibe lose. |
| 20:15 | Olli (olli) | im Vorratsraum vor dem Regal mit der Torte (vorrat_mitte) | Olli sucht die Toilette, nimmt die falsche Tür hinter der Theke und steht im dunklen Vorratsraum vor der Mitternachtstorte. „Ich wollte nur aufs Klo!“ | Falsche Fährte: Olli kennt den Vorratsraum. |
| 23:30 | Hana (meryem) | an der Kamin-Nische (am_kamin) | Hana feuert den Kamin an, ohne die Kaminklappe zu öffnen. Dichter Qualm füllt den Kaminsaal, alle husten, die Lichtschacht-Klappen werden aufgerissen, das Feuer wird gelöscht. | Spur: Seit 23:30 zieht Luft vom Buffetsaal in den Kaminsaal; Gerüche wandern mit. |

## 3. Räume

| Kennung | Anzeigename | Rechteck x,y,b,l | Beschreibung |
|---|---|---|---|
| thekensaal | Buffetsaal | 11,7,8,12 | Länglicher Gewölbesaal, Knotenpunkt des Kellers. Gegenüber dem Eingang steht die Buffettheke aus dunklem Holz, dahinter die Anrichte an der Nordwand. Links und rechts an den Längswänden die Buffettische. |
| vorratsraum | Vorratsraum | 13,2,3,4 | Kleiner, kühler Raum ohne Fenster hinter der Buffettheke. Einziger Zugang ist die Tür neben der Anrichte. |
| durchgang | Durchgang | 8,8,2,2 | Kurzer, niedriger Gang zwischen West-Saal und Buffetsaal. Hier stehen die Getränkekisten. |
| west_saal | Kaminsaal | 1,8,6,12 | Gemeinschaftssaal mit zwei langen Tafeln und Wandbänken. In der Westwand die Kamin-Nische, hoch in der Nordwand zwei Lichtschächte mit Klappen, in der Nordwestecke die geschnitzte Bogentür zum Turm. |
| turmgang | Turmgang | 1,1,3,6 | Schmaler Gang im Fuß des Schlossturms. Hier stehen die alte Ritterrüstung und die Schauvitrine, neben der Hoftür hängt der Schlüsselkasten der Stiftung. Die Wendeltreppe führt hinauf zu den Toiletten; der Rest des Turms ist mit einem Vorhängeschloss abgesperrt. |
| ost_saal | Ostsaal | 20,7,6,12 | Ruhiger Gemeinschaftssaal ohne weitere Außentür. Am Eingang steht der Jackenständer, an der Ostwand die Wandtafel mit dem Ablaufplan des Abends. |
| windfang | Windfang | 14,20,2,2 | Kleiner Vorraum zwischen der Innentür des Buffetsaals und dem Außentor. |

**Türen**

| Kennung | Name | Von | Nach | Schließt | Zustand |
|---|---|---|---|---|---|
| aussentor | Außentor | windfang | draussen | schluessel_beidseitig (Schlüssel: Herrn Schneiders Schlüsselbund (bund_schneider)) | verschlossen ab 18:50 |
| windfang_tuer | Innentür | thekensaal | windfang | keine | zu (Zugluft) |
| vorrat_tuer | Vorratsraumtür | thekensaal | vorratsraum | keine | angelehnt |
| durchgang_ost | Tür zum Durchgang | thekensaal | durchgang | keine | offen |
| durchgang_west | Bogen zum Kaminsaal | durchgang | west_saal | keine | offen |
| ost_tuer | Tür zum Ostsaal | thekensaal | ost_saal | keine | offen |
| bogentuer | Bogentür zum Turm | west_saal | turmgang | keine | offen |
| hoftuer | Hoftür | turmgang | draussen | schluessel_beidseitig (Schlüssel: Herrn Schneiders Schlüsselbund (bund_schneider)) | verschlossen ab 18:50 |

**Lichtquellen**

| Kennung | Name | Art | Räume | Brennt (von–bis) |
|---|---|---|---|---|
| licht_strom | Deckenlicht und elektrische Deko-Kerzen | elektrisch | thekensaal, durchgang, west_saal, turmgang, ost_saal, windfang | 17:00–23:58:00; 00:00:00–07:00 |
| licht_vorrat | Deckenlampe im Vorratsraum | elektrisch | vorratsraum | 17:00–23:54:20; 00:00:18–07:00 |
| licht_kerzenstaender | drei rote Wachskerzen im Messingkerzenständer | kerze | – | 22:00–23:58:40 |
| licht_notausgang | grünes Notausgangsschild mit Akku | notlicht | – | 17:00–07:00 |
| licht_kamin | Kaminfeuer | feuer | – | 23:20–23:30 |
| licht_maske | nachleuchtende Farbe der Maske | nachleuchten | – | – |
| licht_stirnlampe | Tims Stirnlampe | lampe | – | 23:59:40–07:00 |
| licht_handys | Handy-Taschenlampen aus dem Handykorb | lampe | – | 23:59:30–00:00:30 |
| licht_serkan | Serkans LED-Taschenlampe | lampe | – | 23:56:00–00:01:00 |
| licht_notlaterne | Notlaterne am Haken im Vorratsraum | lampe | – |  |

**Luftzug**

- **Ab:** 23:30
- **Weg:** thekensaal → durchgang → west_saal
- **Grund:** Seit dem Qualm stehen die Lichtschacht-Klappen offen; Kaminschacht und Lichtschächte ziehen Luft aus dem Buffetsaal durch den Durchgang in den Kaminsaal.

**Orte**

| Kennung | Raum | x | y | Name |
|---|---|---|---|---|
| vor_vorratstuer | thekensaal | 14.5 | 7.5 | vor der Vorratsraumtür |
| an_anrichte | thekensaal | 13.5 | 8.5 | an der Anrichte neben der Vorratsraumtür |
| hinter_theke_west | thekensaal | 11.5 | 8.5 | hinter der Theke, Westende |
| hinter_theke_mitte | thekensaal | 15.5 | 8.5 | hinter der Theke, vor dem Teekocher |
| hinter_theke_ost | thekensaal | 17.5 | 8.5 | hinter der Theke, vor der Kaffeemaschine |
| theke_klappe | thekensaal | 11.5 | 9.5 | an der Theken-Klappe am Westende |
| theke_ostende | thekensaal | 18.5 | 9.5 | am Ostende der Theke |
| vor_theke | thekensaal | 14.5 | 10.5 | vor der Theke |
| vor_theke_west | thekensaal | 12.5 | 10.5 | vor der Theke beim Westende |
| am_eiskuebel | thekensaal | 17.5 | 10.5 | vor der Theke beim Eiskübel |
| am_linken_buffet | thekensaal | 13.5 | 13.5 | am linken Buffettisch |
| hinter_linkem_buffet | thekensaal | 11.5 | 13.5 | hinter dem linken Buffettisch |
| am_rechten_buffet | thekensaal | 16.5 | 13.5 | am rechten Buffettisch |
| hinter_rechtem_buffet | thekensaal | 18.5 | 13.5 | hinter dem rechten Buffettisch |
| saalmitte | thekensaal | 14.5 | 14.5 | Mitte des Buffetsaals |
| unter_notausgang | thekensaal | 14.5 | 18.5 | an der Innentür unter dem Notausgangsschild |
| vorrat_innen | vorratsraum | 14.5 | 5.5 | direkt hinter der Vorratsraumtür |
| vorrat_mitte | vorratsraum | 14.5 | 3.5 | im Vorratsraum vor dem Regal mit der Torte |
| bei_den_kisten | durchgang | 9.5 | 8.5 | bei den Getränkekisten |
| durchgang_mitte | durchgang | 8.5 | 9.5 | im Durchgang |
| west_bogen | west_saal | 6.5 | 9.5 | am Bogen zum Durchgang |
| am_sicherungskasten | west_saal | 6.5 | 11.5 | am Sicherungskasten |
| am_kamin | west_saal | 2.5 | 13.5 | an der Kamin-Nische |
| west_bank_nord | west_saal | 4.5 | 8.5 | auf der Wandbank unter den Lichtschächten |
| west_bank_west | west_saal | 1.5 | 10.5 | auf der Wandbank an der Westwand |
| vor_bogentuer | west_saal | 2.5 | 8.5 | vor der Bogentür |
| west_tafel_sued | west_saal | 5.5 | 15.5 | an der langen Tafel im Kaminsaal |
| west_bank_sued | west_saal | 3.5 | 18.5 | auf der Wandbank an der Südwand |
| an_der_ruestung | turmgang | 2.5 | 5.5 | bei der Ritterrüstung |
| an_der_vitrine | turmgang | 2.5 | 3.5 | an der Schauvitrine |
| wendeltreppe_fuss | turmgang | 2.5 | 1.5 | am Fuß der Wendeltreppe |
| wc | turmgang | 2.5 | 1.5 | auf der Toilette oben im Turm |
| ost_eingang | ost_saal | 20.5 | 9.5 | am Eingang des Ostsaals |
| am_jackenstaender | ost_saal | 21.5 | 8.5 | am Jackenständer |
| ost_tafel_kopf | ost_saal | 22.5 | 10.5 | am Kopf der langen Tafel |
| ost_tafel_west | ost_saal | 21.5 | 13.5 | an der langen Tafel, Westseite |
| ost_tafel_ost | ost_saal | 24.5 | 13.5 | an der langen Tafel, Ostseite |
| am_handykorb | ost_saal | 24.5 | 12.5 | beim Handykorb auf der Tafel |
| an_der_wandtafel | ost_saal | 24.5 | 10.5 | an der Wandtafel mit dem Ablaufplan |
| ost_bank | ost_saal | 25.5 | 15.5 | auf der Wandbank an der Ostwand |
| geburtstagsplatz | ost_saal | 24.5 | 16.5 | auf dem Ehrenplatz der blinden Kuh |
| im_windfang | windfang | 14.5 | 20.5 | im Windfang |
| am_aussentor | windfang | 15.5 | 21.5 | am Außentor |

## 4. Figuren

### Detektiv (Der Detektiv / Die Detektivin (Gast))

- **Farbcode:** #B8A48A (Sandbeige)
- **Startraum:** Ostsaal (ost_saal)
- **Ermittlungsort:** auf dem Ehrenplatz der blinden Kuh (geburtstagsplatz)
- **Optik:**
  - Silhouette: Mittelgroß, aufmerksame Haltung, Kopf leicht schief beim Zuhören
  - Kleidung: Heller sandbeiger Trenchcoat über Alltagskleidung, schwarze Jeans, dunkle Turnschuhe
  - Accessoires: Markante Brille, Braun karierter Detektivhut, Unangezündete Pfeife, aus der Seifenblasen steigen
  - Werkzeug: Handy in der Hand mit Taschenlampen-Lichtkegel
  - Ruhe-Animation: Bläst mit der Pfeife ein paar Seifenblasen und tippt aufs Handy
- **Look:**
  - Haut: #d9a983
  - Haar: #4a3222
  - Kopf: detektivhut
  - Statur: normal
  - Schnitt: suit
- **Tatnacht:** Ab 23:55 sitzt der Detektiv als blinde Kuh mit verbundenen Augen und Kopfhörern im Ost-Saal auf dem Ehrenplatz. Die Musik läuft laut. Durch die Musik hört er nur den Knall, Herrn Schneiders Rufe „Hab ich dich!“ und „Stehen bleiben!“ und später ein Scheppern.
- **Auftrag:** Um 0:20 bittet Herr Schneider den Detektiv: „Finde raus, wer das war. Bis zum Morgen.“
- **Nie verdächtig:** ja

### Opfer. Herr Schneider (Schlossverwalter)

- **Alter:** 61
- **Geschlecht:** m
- **Farbcode:** #2E473B (Dunkelgrün)
- **Startraum:** Buffetsaal (thekensaal)
- **Ermittlungsort:** hinter dem rechten Buffettisch (hinter_rechtem_buffet)
- **Optik:**
  - Silhouette: Breiter, leicht gebeugter Körperbau, Halbglatze, Brille, graues schütteres Haar
  - Kleidung: Dunkelgrüne Wachsjacke über grobem grauem Rollkragenpullover, derbe Arbeitsstiefel
  - Merkmal: Großer klimpernder Schlüsselbund an der rechten Gürtelschlaufe, Klemmbrett mit Quittungsblock
  - Ruhe-Animation: Tippt auf die Armbanduhr und hakt etwas auf dem Klemmbrett ab
- **Look:**
  - Haut: #e8c9b0
  - Haar: #9a9a9a
  - Kopf: none
  - Statur: broad
  - Schnitt: suit
  - Glatze: true
- **Motiv:** Seit 25 Jahren hält er das Schloss in Schuss. Den Keller hat er Ahmet umsonst überlassen. Heute ärgert er sich über die Tür, den Parkplatz, die Musik und die offene Vitrine. Um zwölf will er alles klären.
- **Status:** Nach dem Schlag kurz bewusstlos. Er wacht um 0:01:30 auf, hat eine Beule und eine Gedächtnislücke für die Sekunden vor dem Schlag. Danach sitzt er mit einem Kühlpack im Buffetsaal und ist bald wieder grantig.
- **Erinnerung:** Knall, Dunkelheit, der Weg zur Notlaterne, ein leuchtendes Gespenstergesicht. Er packt eine Kapuze und ruft „Hab ich dich!“. Danach ist alles weg.
- **Warme Seite:** Er hat den Messingkerzenständer selbst poliert, weil er Feste mag. Kleine Schäden zahlt er oft aus eigener Tasche.
- **Gedächtnislücke ab:** 23:58:14
- **Schlüsselbund:** Herrn Schneiders Schlüsselbund (bund_schneider)

### 1. Ahmet (Der Organisator)

- **Alter:** 27
- **Geschlecht:** m
- **Herkunft:** bosnisch
- **Aussprache:** Achmet
- **Alltag:** Arbeitet in einer Agentur, die Stadtfeste und Märkte plant.
- **Stufe:** 1
- **Farbcode:** #1A1A1A (Schwarz und Weiß)
- **Startraum:** Buffetsaal (thekensaal)
- **Ermittlungsort:** vor der Theke (vor_theke)
- **Optik:**
  - Silhouette: Schlank, aufrecht, sportliche Haltung, Brille, kurzer Bart
  - Kleidung: Schwarzer Strickpulli über weißem T-Shirt, dunkle Jeans, weiße Turnschuhe. Die schwarze Stoffjacke hängt ab 23:55 am Jackenständer im Ost-Saal.
  - Merkmal: Blaues Stoffarmband am Handgelenk, Handy in der Hand (ab 0:05, vorher im Handykorb)
  - Ruhe-Animation: Dreht am blauen Stoffarmband und streicht sich nervös durch den Bart
- **Look:**
  - Haut: #d9a983
  - Haar: #1a1412
  - Kopf: none
  - Statur: slim
  - Schnitt: suit
- **Motiv:** Ahmet hat den Keller umsonst bekommen. Dafür gestaltet er das Programm des Adventsmarkts. Beim Essen hat er viel zu groß bestellt. Statt das zuzugeben, hat er von allen 150 € „Miete“ eingesammelt. Um 23:51 sagt Herr Schneider an der Theke: „Um zwölf sag ich allen, was der Keller gekostet hat.“
- **Alibi:** Behauptet, hinter der Theke nach Servietten gesucht zu haben.
- **Geheimnis:** Um 23:57 schlüpft er mit dem Umschlag voller Mietgeld hinter die Theke. Er will Herrn Schneider bitten, um zwölf nichts zu sagen. Das Geld will er morgen allen zurückgeben.
- **Persönliches Ziel:** Niemand soll vor dem Morgen erfahren, dass die Miete erfunden war.
- **Nebendelikt:** Hat von allen 150 € Miete kassiert, obwohl der Keller nichts gekostet hat. (nd_mietgeld)
- **Loyalität:** Lejla (leyla): Sie sind zusammen aufgewachsen und halten zusammen.
- **Lügen:**
  - `luege_ahmet_servietten`: Ich hab hinter der Theke nur Servietten gesucht. → Er wollte Herrn Schneider mit dem Umschlag um Aufschub bitten.
  - `luege_ahmet_miete`: Die 150 € waren für die Miete. → Der Keller hat nichts gekostet; das Geld deckt seine zu große Essensbestellung.
- **Unschuldsfassung:**
  - Verhalten: Duckt sich beim Knall hinter der Theke am Ostende neben Damir und hält den Umschlag fest. Er bleibt dort, bis das Licht angeht. Später leert er den Umschlag und wirft ihn in den Ascheneimer am Kamin.
- **Täterfassung:**
  - Tat: Er kauert erst am Ostende der Theke neben Damir. Dann geht er zum Kerzenlicht an der Anrichte, um Herrn Schneider zu bitten. Herr Schneider, noch außer sich wegen Can, packt ihn am Arm und zischt: „Um zwölf erfahren's alle.“ In Panik greift Ahmet mit der Hand, in der er den Umschlag hält, den Kerzenständer und schlägt einmal zu. Heißes Wachs tropft auf den Umschlag, eine Ecke reißt ab und bleibt am Griff kleben. In Panik reißt er den Bund vom Gürtel: Wer den Schlüssel hat, kommt raus, bevor das Licht angeht. Gleich danach merkt er, dass Flucht alles schlimmer macht. Er steckt den Bund im Ost-Saal in seine eigene Jacke und kauert sich wieder neben Damir.
  - Schlüsselbeweis: Im Wachs am Griff des Kerzenständers klebt eine abgerissene Ecke seines Mietumschlags.
  - Zusatzindiz: Rote Wachstropfen auf dem leeren Umschlag im Ascheneimer am Kamin; eine Ecke fehlt.

### 2. Fatma (Die Designstudentin)

- **Alter:** 26
- **Geschlecht:** w
- **Herkunft:** kurdisch
- **Aussprache:** Fatma
- **Alltag:** Studiert Kommunikationsdesign im letzten Semester.
- **Stufe:** 1
- **Farbcode:** #6B1D2F (Beerenrot)
- **Startraum:** Buffetsaal (thekensaal)
- **Ermittlungsort:** am linken Buffettisch (am_linken_buffet)
- **Optik:**
  - Silhouette: Schlanke Statur, taubengraues Kopftuch, knielanger Wollmantel
  - Kleidung: Beerenroter Wollmantel, dunkler Rollkragen, schwarze Stoffhose, taubengraues Kopftuch
  - Merkmal: Schwere Umhängetasche aus Leder, breiter Silberring an der rechten Hand
  - Ruhe-Animation: Nestelt am Reißverschluss ihrer Tasche und lächelt Emine zu
- **Look:**
  - Haut: #e6be9e
  - Haar: #2b1d14
  - Kopf: kopftuch
  - Statur: slim
  - Schnitt: dress
  - Kopftuchfarbe: #9A8C98
- **Motiv:** Fatma schreibt ihre Abschlussarbeit über alte Münzbilder. Azra hat ihr von der Münzschatulle in der Schauvitrine erzählt. Um 23:40 hebt sie die gesprungene Scheibe an und nimmt die Schatulle mit. Sie will die Reliefs zu Hause abzeichnen und die Schatulle am Montag zurückbringen. Um 23:56 sieht Herr Schneider Glassplitter an ihrem Mantel: „Die Schatulle. Um Punkt zwölf geh ich raus und ruf die Polizei.“
- **Alibi:** Behauptet, die ganze Zeit beim Gebäck am linken Buffettisch gestanden zu haben.
- **Geheimnis:** Nachdem Herr Schneider sie um 23:56 erwischt hat, will sie ihm die Schatulle sofort zurückgeben. Um 23:57 geht sie mit der Tasche zur Theken-Klappe.
- **Persönliches Ziel:** Die Schatulle soll zurück, ohne dass es alle erfahren.
- **Nebendelikt:** Hat die Münzschatulle aus der Schauvitrine mitgenommen. (nd_schatulle)
- **Loyalität:** Emine (emine): Emine ist seit der Schulzeit ihre beste Freundin.
- **Lügen:**
  - `luege_fatma_buffet`: Ich stand die ganze Zeit beim Gebäck am linken Buffet. → Um 23:57 war sie mit der Tasche an der Theken-Klappe.
  - `luege_fatma_tasche`: In meiner Tasche sind nur Bücher. → In der Tasche liegt die Münzschatulle aus der Vitrine.
- **Unschuldsfassung:**
  - Verhalten: Beim Knall zieht sie sich mit der Tasche zum linken Buffettisch zurück und kauert dort gleich danach neben Emine.
- **Täterfassung:**
  - Tat: Beim Knall bleibt sie erschrocken vor der Theke stehen. Dann sieht sie das Kerzenlicht an der Anrichte und geht durch die Klappe hin, um die Schatulle sofort zurückzugeben. Herr Schneider packt den Gurt ihrer Tasche und zischt: „Zu spät. Die Polizei kommt so oder so.“ In Panik greift sie den Kerzenständer und schlägt einmal zu. In Panik reißt sie den Bund vom Gürtel: Wer den Schlüssel hat, kommt raus, bevor das Licht angeht. Gleich danach merkt sie, dass Flucht alles schlimmer macht. Sie steckt ihn in die Brottasche auf dem linken Buffettisch und kauert sich zu Emine.
  - Schlüsselbeweis: Frischer Messingabrieb an ihrem breiten Silberring, passend zum Kerzenständer.
  - Zusatzindiz: Rote Wachstropfen auf der Münzschatulle in ihrer Tasche.

### 3. Olli (Der Anpacker)

- **Alter:** 28
- **Geschlecht:** m
- **Herkunft:** deutsch
- **Aussprache:** Olli
- **Alltag:** Ist Lagerlogistiker und hilft bei jedem Umzug im Freundeskreis.
- **Stufe:** 1
- **Farbcode:** #1F3A52 (Marineblau und Khaki)
- **Startraum:** Ostsaal (ost_saal)
- **Ermittlungsort:** am Kopf der langen Tafel (ost_tafel_kopf)
- **Optik:**
  - Silhouette: Breit gebaut, kräftige Schultern, leicht gebeugte Haltung
  - Kleidung: Grauer Kapuzenpulli, dunkelblaue Daunenweste, Khakihose mit Seitentaschen
  - Merkmal: Holzsplitter und weißer Kalk an den Ärmeln des Pullis; der rechte Arbeitshandschuh hängt aus der Westentasche, der linke liegt seit 19:30 am Kamin
  - Ruhe-Animation: Reibt sich den Nacken, wechselt das Standbein und schaut auf seine Hände
- **Look:**
  - Haut: #f1d3bc
  - Haar: #7a5638
  - Kopf: none
  - Statur: broad
  - Schnitt: suit
- **Motiv:** Um 18:30 trägt Olli mit Wojtek die Warmhaltebehälter durch den Turm. Dabei schrammt er die geschnitzte Bogentür, ein Beschlag reißt aus. Herr Schneider verlangt 2.000 € Bargeld und schließt die Tore ab: „Keiner geht, bevor das bezahlt ist.“ Um 23:00 streiten die beiden laut.
- **Alibi:** Behauptet, die ganze Zeit am Kopf der Tafel im Ost-Saal gesessen zu haben.
- **Geheimnis:** Um 23:57 holt er am Eiskübel Eis für Wojteks eingeklemmten Finger. Herr Schneider raunzt ihn an: „Zweitausend, bis zwölf.“
- **Persönliches Ziel:** Den Türschaden selbst mit Herrn Schneider klären, ohne die Gruppe hineinzuziehen.
- **Nebendelikt:** Hat die Bogentür beschädigt und wollte die Schramme mit Möbelwachs verdecken. (nd_tuerschaden)
- **Loyalität:** Wojtek (kaan): Wojtek hat ihm beim Tragen geholfen und hält zu ihm.
- **Lügen:**
  - `luege_olli_tafel`: Ich saß die ganze Zeit am Tisch im Ost-Saal. → Um 23:57 war er am Eiskübel vor der Theke, danach kauerte er am rechten Buffettisch.
- **Unschuldsfassung:**
  - Verhalten: Beim Knall tastet er sich vom Eiskübel zum rechten Buffettisch und kauert dort gleich danach neben Azra, bis das Licht angeht. Dann bringt er Wojtek das Eis und setzt sich in den Ost-Saal an die Tafel.
- **Täterfassung:**
  - Tat: Er bleibt erst am Eiskübel stehen. Dann geht er vor der Theke entlang und durch die Klappe zum Kerzenlicht, weil er mit Herrn Schneider reden will. Herr Schneider packt ihn am Ärmel und zischt: „Zweitausend. Sonst Polizei.“ In Panik greift Olli den Kerzenständer am Fuß und schlägt einmal zu. Rote Tropfen fallen auf den Handschuh, der aus seiner Westentasche hängt. In Panik reißt er den Bund vom Gürtel: Wer den Schlüssel hat, kommt raus, bevor das Licht angeht. Gleich danach merkt er, dass Flucht alles schlimmer macht. Er wirft ihn in den Eiskübel und kauert sich zu Azra.
  - Schlüsselbeweis: Holzsplitter und weißer Kalk von seinen Ärmeln kleben im Wachs am Fuß des Kerzenständers, das inzwischen erstarrt ist.
  - Zusatzindiz: Rote Kerzenwachstropfen auf dem Arbeitshandschuh in seiner Westentasche.

### 4. Can (Der Spaßvogel)

- **Alter:** 25
- **Geschlecht:** m
- **Herkunft:** türkisch
- **Aussprache:** Dschan
- **Alltag:** Macht eine Ausbildung zum Mediengestalter und dreht lustige Kurzvideos.
- **Stufe:** 1
- **Farbcode:** #F5C400 (Signalgelb)
- **Startraum:** Kaminsaal (west_saal)
- **Ermittlungsort:** auf der Wandbank an der Westwand (west_bank_west)
- **Optik:**
  - Silhouette: Jugendlich, schlank, federnder Gang
  - Kleidung: Signalgelber weiter Kapuzenpulli, weite Jeans, bunte Turnschuhe
  - Merkmal: Auffällige gelbe Kapuze, linke Hand tief in der Bauchtasche des Pullis (dort steckt die Maske)
  - Ruhe-Animation: Zieht an den Kapuzenbändern und wippt auf den Zehenspitzen
- **Look:**
  - Haut: #d9a983
  - Haar: #1a1412
  - Kopf: none
  - Statur: slim
  - Schnitt: suit
- **Motiv:** Can hat am Nachmittag eine weiße Gespenstermaske mit Leuchtfarbe angemalt. Um 23:54 versteckt er sich damit im dunklen Vorratsraum. Um zwölf soll die blinde Kuh zur Torte kommen und sich erschrecken. Kurz vor zwölf knallt es, das Licht geht aus, und die Tür zum Vorratsraum quietscht auf. Can glaubt, die blinde Kuh wird schon gebracht, und springt mit „Buuuh!“ hervor. Er läuft Herrn Schneider in die Arme. Der packt ihn an der Kapuze und ruft: „Hab ich dich!“
- **Alibi:** Behauptet, auf der Toilette im Turm gewesen zu sein.
- **Geheimnis:** Er hat mit der Leuchtmaske im Vorratsraum gewartet. Herr Schneider hat ihn an der Kapuze gepackt.
- **Persönliches Ziel:** Der Streich soll nicht herauskommen.
- **Nebendelikt:** Hat sich mit der Leuchtmaske im Vorratsraum versteckt, um die blinde Kuh zu erschrecken. (nd_streich)
- **Loyalität:** Zeynep (zeynep): Zeynep hat für ihn Schmiere gestanden.
- **Lügen:**
  - `luege_can_toilette`: Ich war die ganze Zeit auf der Toilette im Turm. → Er war im Vorratsraum und ist erst nach dem Zusammenstoß in den Turm gerannt.
  - `luege_can_maske`: Welche Maske? Ich hab keine Maske. → Die Leuchtmaske steckt in der Bauchtasche seines Pullis.
- **Unschuldsfassung:**
  - Verhalten: Er reißt sich los und rennt durch den Durchgang, noch bevor es scheppert. Die leuchtende Maske hält er in der Hand. Im Kaminsaal rennt er zur Bogentür, stopft die Maske in die Bauchtasche seines Pullis und versteckt sich oben auf der Toilette im Turm.
- **Täterfassung:**
  - Tat: Herr Schneider hält ihn an der Kapuze fest und zischt: „Jetzt kommt die Polizei.“ In Panik greift Can mit der Hand voller Leuchtfarbe den Kerzenständer von der Anrichte und schlägt einmal zu. Herr Schneider stürzt in den Vorratsraum. Can kniet sich neben ihn und reißt in Panik den Bund vom Gürtel: Wer den Schlüssel hat, kommt raus, bevor das Licht angeht. Gleich danach merkt er, dass Flucht alles schlimmer macht. Er rennt nach dem Scheppern durch den Durchgang und den Kaminsaal, stopft an der Bogentür die Maske in die Bauchtasche, steckt den Bund in den Helm der Ritterrüstung und versteckt sich auf der Toilette im Turm.
  - Schlüsselbeweis: Ein Abdruck einer ganzen Hand in grünlich-weißer Leuchtfarbe um den Griff des Kerzenständers.
  - Zusatzindiz: Rote Wachstropfen auf der Leuchtmaske.
- **Beweisfarbe:** Gelbe Kapuzenfasern an Herrn Schneiders Hand (gelbe_fasern) müssen eindeutig Can zugeordnet werden können.

### 5. Lejla (Die Apothekerin)

- **Alter:** 25
- **Geschlecht:** w
- **Herkunft:** bosnisch
- **Aussprache:** Leila
- **Alltag:** Ist Apothekerin und hat das Buffet für heute Abend geplant.
- **Stufe:** 2
- **Farbcode:** #178582 (Türkis)
- **Startraum:** Buffetsaal (thekensaal)
- **Ermittlungsort:** hinter der Theke, vor dem Teekocher (hinter_theke_mitte)
- **Optik:**
  - Silhouette: Zierlich, Haare zu einem straffen Dutt gebunden
  - Kleidung: Türkise Latzschürze über beigem Strickpulli, dunkle Leggings
  - Merkmal: Abrechnungsblock in der Schürzentasche, Holzlöffel in der Hand
  - Ruhe-Animation: Rückt Schüsseln gerade und rührt im Warmhaltebehälter
- **Look:**
  - Haut: #e6be9e
  - Haar: #2b1d14
  - Kopf: bun
  - Statur: small
  - Schnitt: suit
- **Motiv:** Ahmets Cousine. Sie weiß, dass Ahmet mit der Rechnung fürs Essen in der Klemme steckt. Herr Schneider wollte am Nachmittag eine Genehmigung für das mitgebrachte Essen sehen.
- **Alibi:** Trug um 23:57:40 die Tortenteller in den Ost-Saal und stand beim Knall dort an der Tafel.
- **Geheimnis:** Um 23:57 sah sie, wie Ahmet mit einem dicken Umschlag hinter die Theke schlüpfte.
- **Persönliches Ziel:** Ahmet schützen, bis er selbst redet.
- **Loyalität:** Ahmet (ahmet): Sie hat Ahmet versprochen, nichts über die Rechnung zu sagen.
- **Lügen:**

### 6. Emine (Die Grundschullehrerin)

- **Alter:** 26
- **Geschlecht:** w
- **Herkunft:** türkisch
- **Aussprache:** Emine
- **Alltag:** Ist Grundschullehrerin.
- **Stufe:** 2
- **Farbcode:** #5E6E3A (Olivgrün)
- **Startraum:** Buffetsaal (thekensaal)
- **Ermittlungsort:** hinter dem linken Buffettisch (hinter_linkem_buffet)
- **Optik:**
  - Silhouette: Mittelgroß, ruhige Haltung, beiges Kopftuch
  - Kleidung: Olivgrüner Steppmantel, beiges Kopftuch, dunkle Stoffhose, schwarze Stiefel
  - Merkmal: Hält eine silberne Thermoskanne mit Tee in beiden Händen
  - Ruhe-Animation: Dreht den Deckel der Thermoskanne auf und zu und schaut zu Fatma
- **Look:**
  - Haut: #d9a983
  - Haar: #2b1d14
  - Kopf: kopftuch
  - Statur: normal
  - Schnitt: dress
  - Kopftuchfarbe: #d8c6a5
- **Motiv:** Um 23:40 sah sie im Turmgang, wie Fatma die Schatulle aus der Vitrine nahm. Sie hat geschwiegen, weil Fatma versprochen hat, die Schatulle am Montag zurückzubringen.
- **Alibi:** Kauerte beim Knall hinter dem linken Buffettisch.
- **Geheimnis:** Sie weiß, dass Fatma die Schatulle schon um 23:40 aus der Vitrine genommen hat.
- **Persönliches Ziel:** Fatma nicht verraten.
- **Loyalität:** Fatma (fatma): Fatma ist ihre beste Freundin; sie glaubt ihr.
- **Lügen:**

### 7. Tim (Der Hobby-Elektriker)

- **Alter:** 27
- **Geschlecht:** m
- **Herkunft:** deutsch
- **Aussprache:** Tim
- **Alltag:** Ist Mechatroniker und repariert gern alles selbst, manchmal zu gern.
- **Stufe:** 2
- **Farbcode:** #992222 (Karorot)
- **Startraum:** Kaminsaal (west_saal)
- **Ermittlungsort:** am Sicherungskasten (am_sicherungskasten)
- **Optik:**
  - Silhouette: Kräftig, mittelgroß, lockige Haare
  - Kleidung: Rot-schwarz kariertes Flanellhemd über dunklem Shirt, derbe Arbeitshose
  - Merkmal: Spannungsprüfer-Schraubenzieher hinter dem Ohr, kleine Stirnlampe um den Hals
  - Ruhe-Animation: Klopft prüfend gegen Kabelkanäle und schüttelt den Kopf
- **Look:**
  - Haut: #e6be9e
  - Haar: #4a3222
  - Kopf: none
  - Statur: normal
  - Schnitt: suit
- **Motiv:** Um 23:57:50 steckt er für den Tortenkaffee die Kaffeemaschine in seine alte Mehrfachsteckdose. Herr Schneider hatte ihn gerade davor gewarnt. Um 23:58:00 knallt es, die Hauptsicherung fliegt raus.
- **Alibi:** Tastete sich beim Knall sofort zum Sicherungskasten im Kaminsaal. Dabei rutschte ihm die Stirnlampe vom Hals. Im Dunkeln fand er den richtigen Schalter nicht. Um 23:59:40 fand er die Stirnlampe auf dem Boden, um 0:00:00 war das Licht wieder an.
- **Geheimnis:** Der Kurzschluss kam von seiner alten Mehrfachsteckdose. Am Sicherungskasten huschte im Dunkeln ein leuchtendes Gesicht an ihm vorbei.
- **Persönliches Ziel:** Niemand soll erfahren, dass seine Mehrfachsteckdose den Ausfall verursacht hat.
- **Nebendelikt:** Hat trotz Warnung die alte Mehrfachsteckdose benutzt und den Kurzschluss verursacht. (nd_kurzschluss)
- **Lügen:**

### 8. Joanna (Die Fotografin des Abends)

- **Alter:** 24
- **Geschlecht:** w
- **Herkunft:** polnisch
- **Aussprache:** Joanna
- **Alltag:** Studiert Medienwissenschaft und fotografiert Hochzeiten als Nebenjob.
- **Stufe:** 2
- **Farbcode:** #6A3587 (Violett)
- **Startraum:** Ostsaal (ost_saal)
- **Ermittlungsort:** beim Handykorb auf der Tafel (am_handykorb)
- **Optik:**
  - Silhouette: Schlank, aufrecht, schnelle Bewegungen
  - Kleidung: Violetter Cardigan über weißem Top, schwarze Stoffhose
  - Merkmal: Handy auf einem kleinen Handyhalter mit Aufsteckleuchte
  - Ruhe-Animation: Hebt das Handy, wischt durch Fotos und zoomt hinein
- **Look:**
  - Haut: #f1d3bc
  - Haar: #c9a86a
  - Kopf: none
  - Statur: slim
  - Schnitt: suit
- **Motiv:** Sie fotografiert den Abend für das Fotoalbum der Clique. Um 23:55 musste ihr Handy in den Handykorb. Ahmet hat sie gebeten, ein Foto zu löschen.
- **Alibi:** Stand im Ost-Saal und hielt die Hände über den Handykorb. Um 23:59:30 schaltete sie als Erste die Handylampen ein.
- **Geheimnis:** Sie hat ein Foto von 23:51: Herr Schneider und Ahmet streiten an der Theke.
- **Persönliches Ziel:** Ihr Versprechen an Ahmet halten, ohne den Detektiv anzulügen.
- **Loyalität:** Ahmet (ahmet): Ahmet hat sie gebeten, das Streitfoto zu löschen.
- **Lügen:**

### 9. Marek (Der Caterer)

- **Alter:** 28
- **Geschlecht:** m
- **Herkunft:** polnisch
- **Aussprache:** Marek
- **Alltag:** Führt mit seiner Schwester einen kleinen Catering-Betrieb.
- **Stufe:** 3
- **Farbcode:** #664229 (Lederbraun)
- **Startraum:** Buffetsaal (thekensaal)
- **Ermittlungsort:** an der Innentür unter dem Notausgangsschild (unter_notausgang)
- **Optik:**
  - Silhouette: Breitschultrig, sportlich, markante Gesichtszüge
  - Kleidung: Dunkelbraune Lederjacke, weißer Rollkragen, dunkle Jeans
  - Merkmal: Lässt den Autoschlüssel mit glänzendem Anhänger um den Zeigefinger kreisen
  - Ruhe-Animation: Zählt die Warmhaltebehälter durch und schaut auf die Uhr
- **Look:**
  - Haut: #d9a983
  - Haar: #2b1d14
  - Kopf: none
  - Statur: broad
  - Schnitt: suit
- **Motiv:** Er hat das Essen geliefert und den Lieferwagen im Schlosshof auf Herrn Schneiders reserviertem Platz abgestellt; am Telefon hatte ihm jemand gesagt, das gehe in Ordnung. Herr Schneider drohte mit Abschleppen.
- **Alibi:** Holte im Durchgang eine Kiste Saft von den Getränkekisten.
- **Geheimnis:** Im Dunkeln rannte ein leuchtendes Gespenstergesicht an ihm vorbei durch den Durchgang Richtung Kaminsaal.
- **Persönliches Ziel:** Der Lieferwagen soll nicht abgeschleppt werden.
- **Nebendelikt:** Hat auf Herrn Schneiders reserviertem Platz geparkt. (nd_parken)
- **Lügen:**

### 10. Zeynep (Die Fußballtrainerin)

- **Alter:** 23
- **Geschlecht:** w
- **Herkunft:** türkisch
- **Aussprache:** Seinep
- **Alltag:** Studiert Sport und trainiert eine Mädchen-Fußballmannschaft.
- **Stufe:** 3
- **Farbcode:** #3EB489 (Minzgrün)
- **Startraum:** Kaminsaal (west_saal)
- **Ermittlungsort:** am Bogen zum Durchgang (west_bogen)
- **Optik:**
  - Silhouette: Zierlich, sportlich, lässiger Stil
  - Kleidung: Minzgrüner weiter Pulli, weite hellgraue Hose, Kappe verkehrt herum
  - Merkmal: Weiße Kopfhörer locker um den Hals, kaut Kaugummi
  - Ruhe-Animation: Kaut Kaugummi, wippt auf den Absätzen und behält Can im Blick
- **Look:**
  - Haut: #c69270
  - Haar: #2b1d14
  - Kopf: cap
  - Statur: small
  - Schnitt: suit
- **Motiv:** Sie steht für Cans Streich Schmiere am Bogen zum Durchgang. Sie fühlt sich schuldig, weil alles aus dem Ruder lief.
- **Alibi:** Stand am Bogen zwischen Kaminsaal und Durchgang und hielt nach der blinden Kuh Ausschau.
- **Geheimnis:** Sie weiß, dass Can mit der Leuchtmaske im dunklen Vorratsraum auf die blinde Kuh gewartet hat.
- **Persönliches Ziel:** Can schützen.
- **Nebendelikt:** Hat für Cans Streich Schmiere gestanden. (nd_schmiere)
- **Loyalität:** Can (can): Sie hat für Can Schmiere gestanden und fühlt sich mitschuldig.
- **Lügen:**

### 11. Baran (Der Mann für die Musik)

- **Alter:** 26
- **Geschlecht:** m
- **Herkunft:** kurdisch
- **Aussprache:** Baran
- **Alltag:** Studiert Tontechnik und legt bei Freunden auf.
- **Stufe:** 3
- **Farbcode:** #333333 (Anthrazit mit Neongrün)
- **Startraum:** Ostsaal (ost_saal)
- **Ermittlungsort:** auf der Wandbank an der Ostwand (ost_bank)
- **Optik:**
  - Silhouette: Groß, schlank, leicht nach vorn geneigt
  - Kleidung: Anthrazitfarbener Kapuzenpulli mit neongrünen Kordeln, schwarze Jogginghose
  - Merkmal: Große Kopfhörer auf dem Kopf (in der Tatnacht trägt sie der Detektiv), tragbare Musikbox unter dem Arm
  - Ruhe-Animation: Wippt im Takt und dreht am Lautstärkerad der Box
- **Look:**
  - Haut: #a87655
  - Haar: #1a1412
  - Kopf: none
  - Statur: tall
  - Schnitt: suit
- **Motiv:** Herr Schneider verlangte ab 22:00 leise Musik und drohte, die Box einzukassieren. Um 23:55 setzte Baran der blinden Kuh seine großen Kopfhörer auf und ließ laute Musik für die Überraschung laufen.
- **Alibi:** Saß im Ost-Saal auf der Wandbank und hielt seine Box fest.
- **Geheimnis:** Die Musik in den Kopfhörern lief über seine Box weiter, als der Strom weg war. Im Ost-Saal hörte er aus Richtung Theke erst „Hab ich dich!“, dann „Stehen bleiben!“, dann das Scheppern.
- **Persönliches Ziel:** Seine Box soll nicht einkassiert werden.
- **Lügen:**

### 12. Hana (Die Kamin-Heizerin)

- **Alter:** 25
- **Geschlecht:** w
- **Herkunft:** bosnisch
- **Aussprache:** Hana
- **Alltag:** Ist Försterin und kennt Holz besser als Kaminzüge.
- **Stufe:** 3
- **Farbcode:** #2B4C7E (Jeansblau)
- **Startraum:** Kaminsaal (west_saal)
- **Ermittlungsort:** an der Kamin-Nische (am_kamin)
- **Optik:**
  - Silhouette: Mittelgroß, praktische Statur, hochgekrempelte Ärmel
  - Kleidung: Dunkelblaues Jeanshemd, feste Arbeitshose, Schnürstiefel
  - Merkmal: Rußflecken auf der linken Wange und an den Händen, Schürhaken in der Hand
  - Ruhe-Animation: Pustet sich eine Strähne aus der Stirn und wischt die Hände an einem alten Lappen ab
- **Look:**
  - Haut: #f1d3bc
  - Haar: #8a3b1e
  - Kopf: none
  - Statur: normal
  - Schnitt: suit
- **Motiv:** Um 23:30 feuert sie den Kamin an, ohne die Kaminklappe zu öffnen. Dichter Qualm füllt den Kaminsaal. Herr Schneider schimpft über den Ruß an der Wand.
- **Alibi:** Stand am Kamin und wischte Ruß von der Wand.
- **Geheimnis:** Kurz nach dem Scheppern roch sie frisch erloschenes Kerzenwachs. Der Geruch kam mit dem Luftzug aus Richtung Theke.
- **Persönliches Ziel:** Den Kamin wieder zum Ziehen bringen und sich bei Herrn Schneider für den Ruß entschuldigen.
- **Lügen:**

### 13. Serkan (Der Fahrdienst-Organisator)

- **Alter:** 29
- **Geschlecht:** m
- **Herkunft:** türkisch
- **Aussprache:** Serkan
- **Alltag:** Ist Rettungssanitäter und fährt heute alle sicher nach Hause.
- **Stufe:** 4
- **Farbcode:** #3A506B (Stahlblau)
- **Startraum:** Windfang (windfang)
- **Ermittlungsort:** im Windfang (im_windfang)
- **Optik:**
  - Silhouette: Kräftig, breite Statur, aufrechte Haltung
  - Kleidung: Stahlblaue Steppweste über grauem Sweatshirt, dunkle Kappe
  - Merkmal: Klemmbrett mit Fahrzeiten, schwere Taschenlampe
  - Ruhe-Animation: Rüttelt am Riegel des Außentors und leuchtet aufs Schloss
- **Look:**
  - Haut: #c69270
  - Haar: #2b1d14
  - Kopf: cap
  - Statur: broad
  - Schnitt: suit
- **Motiv:** Er soll die Gäste nachts nach Hause fahren. Um 23:56 wollte er Decken aus dem Auto holen und fand das Außentor verschlossen.
- **Alibi:** Stand im Windfang am Außentor und leuchtete mit der Taschenlampe aufs Schloss.
- **Geheimnis:** Von kurz vor zwölf bis nach zwölf stand er am Außentor. Es war abgeschlossen; niemand ist hinaus.
- **Persönliches Ziel:** Alle so schnell wie möglich sicher nach Hause fahren.
- **Lügen:**

### 14. Aylin (Die Kassenprüferin)

- **Alter:** 24
- **Geschlecht:** w
- **Herkunft:** kurdisch
- **Aussprache:** Ailin
- **Alltag:** Ist Steuerfachangestellte und hebt jeden Beleg auf.
- **Stufe:** 4
- **Farbcode:** #3A6EA5 (Taubenblau)
- **Startraum:** Ostsaal (ost_saal)
- **Ermittlungsort:** an der langen Tafel, Westseite (ost_tafel_west)
- **Optik:**
  - Silhouette: Sehr gerade Haltung, sachlich
  - Kleidung: Taubenblauer Strickcardigan, weiße Bluse, schwarze Stoffhose
  - Merkmal: Schwarze Ledermappe mit Belegen und Kugelschreiber, fest an die Brust gedrückt
  - Ruhe-Animation: Klickt mit dem Kugelschreiber und sieht zu Ahmet hinüber
- **Look:**
  - Haut: #d9a983
  - Haar: #1a1412
  - Kopf: none
  - Statur: slim
  - Schnitt: suit
- **Motiv:** Sie zahlte die 150 € nur unter Protest und wollte einen Beleg. Um 22:30 fragte sie Herrn Schneider direkt. Er schrieb ihr auf einen Quittungszettel: „Miete: 0 Euro.“
- **Alibi:** Saß im Ost-Saal an der Tafel und hielt ihre Mappe fest.
- **Geheimnis:** Sie hat Herrn Schneiders handschriftlichen Quittungszettel: „Miete: 0 Euro.“
- **Persönliches Ziel:** Ihr Geld zurückbekommen, ohne Ahmet vor allen bloßzustellen.
- **Lügen:**

### 15. Wojtek (Der Architekturstudent)

- **Alter:** 27
- **Geschlecht:** m
- **Herkunft:** polnisch
- **Aussprache:** Woitek
- **Alltag:** Studiert Architektur; Maßband und Bleistift hat er immer dabei.
- **Stufe:** 4
- **Farbcode:** #5C677D (Aschgrau)
- **Startraum:** Kaminsaal (west_saal)
- **Ermittlungsort:** vor der Bogentür (vor_bogentuer)
- **Optik:**
  - Silhouette: Schlank, ruhige Haltung, Brille
  - Kleidung: Aschgrauer Kapuzenpulli, schwarze Arbeitshose mit verstärkten Knien
  - Merkmal: Zimmermannsbleistift hinter dem Ohr, Maßband am Hosenbund, ein Finger mit Pflaster
  - Ruhe-Animation: Streicht mit dem Daumen über die Schramme an der Bogentür
- **Look:**
  - Haut: #e6be9e
  - Haar: #c9a86a
  - Kopf: none
  - Statur: normal
  - Schnitt: suit
- **Motiv:** Er hat mit Olli die Warmhaltebehälter durch den Turm getragen. Nach der Schramme riet er Olli, sie mit braunem Möbelwachs aus seiner Werkzeugtasche zu verdecken. Um 23:50 klemmte er sich an der Bogentür den Finger ein.
- **Alibi:** Stand an der Bogentür im Kaminsaal und tastete mit den Fingern die Schramme ab.
- **Geheimnis:** Um 23:52 sagte Olli zu ihm: „Ich hol dir Eis. Und dann red ich mit Schneider.“
- **Persönliches Ziel:** Niemand soll wissen, dass die Idee mit dem Möbelwachs von ihm kam.
- **Nebendelikt:** Hat Olli geraten, die Schramme mit Möbelwachs zu verdecken. (nd_moebelwachs)
- **Loyalität:** Olli (olli): Olli ist sein Kumpel vom Tragen und hat ihm Eis geholt.
- **Lügen:**

### 16. Azra (Die Flohmarkt-Kennerin)

- **Alter:** 26
- **Geschlecht:** w
- **Herkunft:** bosnisch
- **Aussprache:** Asra
- **Alltag:** Studiert Kunstgeschichte und stöbert jedes Wochenende auf Flohmärkten.
- **Stufe:** 4
- **Farbcode:** #7A2E5C (Pflaume)
- **Startraum:** Buffetsaal (thekensaal)
- **Ermittlungsort:** am rechten Buffettisch (am_rechten_buffet)
- **Optik:**
  - Silhouette: Groß, elegante Bewegungen, lange schwarze Haare
  - Kleidung: Pflaumenfarbenes Samtkleid, langer schwarzer Strickcardigan
  - Merkmal: Kleine Lupe an einer Silberkette um den Hals, auffällige Ringe aus Holz und Stein
  - Ruhe-Animation: Betrachtet ihre Ringe durch die Lupe und schaut zur Theke
- **Look:**
  - Haut: #c69270
  - Haar: #1a1412
  - Kopf: none
  - Statur: tall
  - Schnitt: dress
- **Motiv:** Sie kennt sich mit alten Münzen aus und hat Fatma von der Schatulle in der Schauvitrine erzählt. Herr Schneider fand es seltsam, wie lange sie vor der Vitrine stand.
- **Alibi:** Stand am rechten Buffettisch und füllte Gebäck auf einen Pappteller.
- **Geheimnis:** Um 23:45 sah sie, dass Fatmas Tasche auffällig ausgebeult war.
- **Persönliches Ziel:** Niemand soll denken, sie hätte Fatma zu etwas angestiftet.
- **Lügen:**

### 17. Damir (Der Teemeister)

- **Alter:** 25
- **Geschlecht:** m
- **Herkunft:** bosnisch
- **Aussprache:** Damir
- **Alltag:** Ist Erzieher und kocht für alle Tee, ob sie wollen oder nicht.
- **Stufe:** 5
- **Farbcode:** #E5E5E5 (Weiß mit Schwarz)
- **Startraum:** Buffetsaal (thekensaal)
- **Ermittlungsort:** hinter der Theke, Westende (hinter_theke_west)
- **Optik:**
  - Silhouette: Schlank, aufmerksam, flinke Hände
  - Kleidung: Weißes Hemd mit hochgekrempelten Ärmeln, schwarze Schürze
  - Merkmal: Hält ein schmales Teeglas auf einer Untertasse
  - Ruhe-Animation: Poliert Teegläser mit einem weißen Tuch und prüft den Teekocher
- **Look:**
  - Haut: #d9a983
  - Haar: #4a3222
  - Kopf: none
  - Statur: slim
  - Schnitt: suit
- **Motiv:** Er schenkt den ganzen Abend Tee aus. Herr Schneider warf ihm vor, das Teegeschirr des Schlosses ohne Erlaubnis zu benutzen.
- **Alibi:** Duckte sich am Ostende hinter die Theke, um nicht an heiße Kannen zu stoßen.
- **Geheimnis:** Um 23:57 sah er Ahmet, Fatma und Olli an der Theke, Herrn Schneider am Ostende. Can war nicht zu sehen.
- **Persönliches Ziel:** Sein Ärger mit Herrn Schneider über das Teegeschirr soll nicht zur Sprache kommen.
- **Lügen:**

### 18. Sibel (Die Vorsichtige)

- **Alter:** 23
- **Geschlecht:** w
- **Herkunft:** türkisch
- **Aussprache:** Sibel
- **Alltag:** Studiert Biologie und fürchtet sich vor nichts außer alten Rüstungen.
- **Stufe:** 5
- **Farbcode:** #D8A7B1 (Pastellrosa)
- **Startraum:** Kaminsaal (west_saal)
- **Ermittlungsort:** auf der Wandbank an der Südwand (west_bank_sued)
- **Optik:**
  - Silhouette: Klein, zieht oft die Schultern hoch
  - Kleidung: Pastellrosa Strickpulli, helle Jeans, weißer Fransenschal
  - Merkmal: Zieht den Fransenschal bis übers Kinn
  - Ruhe-Animation: Schaut sich um und zuckt bei lauten Geräuschen zusammen
- **Look:**
  - Haut: #e6be9e
  - Haar: #7a5638
  - Kopf: none
  - Statur: small
  - Schnitt: suit
- **Motiv:** Um 21:00 hielt sie die Ritterrüstung im Turmgang für einen Menschen, schrie auf und stieß gegen die Vitrine. Seitdem macht sie einen Bogen um den Turmgang.
- **Alibi:** Saß auf der Wandbank im Kaminsaal.
- **Geheimnis:** Im Dunkeln huschte ein leuchtendes Gesicht vom Durchgang quer durch den Kaminsaal zur Bogentür.
- **Persönliches Ziel:** Die Rüstung soll aus dem Turmgang verschwinden.
- **Lügen:**

### 19. Pawel (Der Vermittler)

- **Alter:** 30
- **Geschlecht:** m
- **Herkunft:** polnisch
- **Aussprache:** Pawel
- **Alltag:** Ist Rechtsreferendar und schlichtet seit der Schulzeit jeden Streit.
- **Stufe:** 5
- **Farbcode:** #4A3728 (Schokobraun)
- **Startraum:** Ostsaal (ost_saal)
- **Ermittlungsort:** an der langen Tafel, Ostseite (ost_tafel_ost)
- **Optik:**
  - Silhouette: Ruhig, aufrecht, gelassene Haltung
  - Kleidung: Schokobraune Steppjacke über beigem Rollkragen, Halbschuhe
  - Merkmal: Dunkelbraune Ledertasche neben sich, Teetasse in der Hand
  - Ruhe-Animation: Nimmt einen langsamen Schluck Tee und beobachtet die Gruppe
- **Look:**
  - Haut: #a87655
  - Haar: #2b1d14
  - Kopf: none
  - Statur: normal
  - Schnitt: suit
- **Motiv:** Um 23:00 versuchte er, den Streit zwischen Herrn Schneider und Olli zu schlichten. Herr Schneider wies ihn barsch ab. Im Sommer hat Pawel bei der Schlossstiftung gejobbt.
- **Alibi:** Blieb im Ost-Saal ruhig am Tisch und bat alle, keine Panik zu machen.
- **Geheimnis:** Herr Schneider muss jeden Schaden der Stiftung melden. Kleine Schäden zahlt er oft aus eigener Tasche. Darum ist er beim Geld so streng.
- **Persönliches Ziel:** Herrn Schneider in Schutz nehmen, ohne seine Geldsorgen auszuplaudern.
- **Lügen:**

### 20. Tugba (Die Party-Planerin)

- **Alter:** 27
- **Geschlecht:** w
- **Herkunft:** türkisch
- **Aussprache:** Tuuba
- **Alltag:** Ist Projektleiterin und plant sogar Spieleabende mit Ablaufplan.
- **Stufe:** 5
- **Farbcode:** #D2691E (Rostorange mit Gold)
- **Startraum:** Ostsaal (ost_saal)
- **Ermittlungsort:** an der Wandtafel mit dem Ablaufplan (an_der_wandtafel)
- **Optik:**
  - Silhouette: Organisiert, schwungvoll, geschäftsmäßig, goldfarbenes Kopftuch
  - Kleidung: Rostoranger Blazer über weißem Shirt, goldfarbenes Kopftuch, schmale Metallbrille
  - Merkmal: Notizbuch mit goldenem Einband und Fineliner
  - Ruhe-Animation: Blättert im Notizbuch, hakt Zeilen ab und schaut zur Wanduhr
- **Look:**
  - Haut: #d9a983
  - Haar: #1a1412
  - Kopf: kopftuch
  - Statur: normal
  - Schnitt: suit
  - Kopftuchfarbe: #c9a227
- **Motiv:** Sie hat den Ablaufplan des Abends geschrieben. Zu ihrem Mitternachtsspiel „Blinde Kuh“ sollte um zwölf der Detektiv mit verbundenen Augen zur Torte in den Vorratsraum geführt werden. Herr Schneider hatte nur widerwillig erlaubt, die Torte dort zu kühlen.
- **Alibi:** Stand im Ost-Saal an der Wandtafel mit dem Ablaufplan.
- **Geheimnis:** Um 23:57 hat sie notiert, wer für die Torte fehlt und wo die Leute angeblich gerade sind.
- **Persönliches Ziel:** Den Abend retten: Torte um halb eins, egal was passiert.
- **Lügen:**

### Herkunftsmatrix (TON §7, §10 Nr. 5)

Nur diese Matrix und die Prüfwerkzeuge lesen das Feld `herkunft`; im Spiel erscheint es nie. `herkunft_test` prüft, dass keine Herkunft eine Art von Verfehlung allein trägt.

| Figur | Herkunft | Kernrolle | Nebendelikt | Lügen | Verschweigt etwas | Kopftuch |
|---|---|---|---|---|---|---|
| Ahmet | bosnisch | ja | ja | 2 | ja | nein |
| Fatma | kurdisch | ja | ja | 2 | nein | ja |
| Olli | deutsch | ja | ja | 1 | nein | nein |
| Can | türkisch | ja | ja | 2 | nein | nein |
| Lejla | bosnisch | nein | nein | 0 | nein | nein |
| Emine | türkisch | nein | nein | 0 | ja | ja |
| Tim | deutsch | nein | ja | 0 | ja | nein |
| Joanna | polnisch | nein | nein | 0 | ja | nein |
| Marek | polnisch | nein | ja | 0 | ja | nein |
| Zeynep | türkisch | nein | ja | 0 | ja | nein |
| Baran | kurdisch | nein | nein | 0 | nein | nein |
| Hana | bosnisch | nein | nein | 0 | nein | nein |
| Serkan | türkisch | nein | nein | 0 | nein | nein |
| Aylin | kurdisch | nein | nein | 0 | nein | nein |
| Wojtek | polnisch | nein | ja | 0 | ja | nein |
| Azra | bosnisch | nein | nein | 0 | ja | nein |
| Damir | bosnisch | nein | nein | 0 | ja | nein |
| Sibel | türkisch | nein | nein | 0 | nein | nein |
| Pawel | polnisch | nein | nein | 0 | nein | nein |
| Tugba | türkisch | nein | nein | 0 | nein | ja |

## 5. Zeitleiste

| Zeit | Ort | Wer | Was |
|---|---|---|---|
| 18:00 | im Windfang (im_windfang) | alle | Die Gäste kommen über die fünf Sandsteinstufen und das Außentor in den Keller. Herr Schneider begrüßt alle knapp und zeigt den Weg. |
| 18:30 | bei der Ritterrüstung (an_der_ruestung) | Marek (murat), Olli (olli), Wojtek (kaan) | Marek liefert das Essen über den Schlosshof und parkt auf Herrn Schneiders reserviertem Platz. Olli und Wojtek tragen die Warmhaltebehälter durch Hoftür, Turmgang und Bogentür. |
| 18:35 | vor der Bogentür (vor_bogentuer) | Olli (olli), Wojtek (kaan) | Olli schrammt mit einem Warmhaltebehälter die geschnitzte Bogentür. Ein Beschlag reißt aus, Holzsplitter und weißer Kalk bleiben an seinen Pulli-Ärmeln. |
| 18:45 | vor der Bogentür (vor_bogentuer) | Olli (olli), Wojtek (kaan) | Wojtek gibt Olli braunes Möbelwachs aus seiner Werkzeugtasche. Olli reibt es mit seinem rechten Arbeitshandschuh in die Schramme und steckt den Handschuh in die Westentasche. |
| 18:50 | vor der Bogentür (vor_bogentuer) | Herr Schneider (schneider), Olli (olli) | Herr Schneider entdeckt den Schaden, verlangt 2.000 € Bargeld und schreibt es in seinen Quittungsblock. Er schließt Hoftür, Einfahrtstor und Außentor ab: „Keiner geht, bevor das bezahlt ist.“ |
| 19:00 | vor der Theke (vor_theke) | alle | Das Buffet ist eröffnet: warmes Essen, Brot, Dips, Gebäck. Dazu schwarzer Tee aus dem großen Teekocher, Kaffee, alkoholfreier Apfelpunsch, Wasser und Säfte. |
| 19:30 | an der Kamin-Nische (am_kamin) | Olli (olli) | Olli wärmt sich am noch kalten Kamin die Hände und vergisst dort seinen linken Arbeitshandschuh. |
| 20:15 | im Vorratsraum vor dem Regal mit der Torte (vorrat_mitte) | Olli (olli) | Lacher: Olli sucht die Toilette, nimmt die falsche Tür hinter der Theke und steht im dunklen Vorratsraum vor der Mitternachtstorte. „Ich wollte nur aufs Klo!“ |
| 21:00 | bei der Ritterrüstung (an_der_ruestung) | Sibel (selin) | Lacher: Sibel hält die Ritterrüstung für einen Menschen, schreit auf und stolpert gegen die Schauvitrine. Die Scheibe bekommt einen feinen Sprung. |
| 22:00 | an der Anrichte neben der Vorratsraumtür (an_anrichte) | Herr Schneider (schneider) | Herr Schneider zündet die drei roten Kerzen im Messingkerzenständer auf der Anrichte an. Es sind die einzigen echten Kerzen im Keller. |
| 22:00 | auf der Wandbank an der Ostwand (ost_bank) | Herr Schneider (schneider), Baran (baran) | Herr Schneider verlangt leise Musik und droht, Barans Box einzukassieren. |
| 22:30 | an der langen Tafel, Westseite (ost_tafel_west) | Aylin (aylin), Herr Schneider (schneider) | Aylin fragt Herrn Schneider nach einem Beleg für die Miete. Er schreibt ihr auf einen Quittungszettel: „Miete: 0 Euro.“ |
| 23:00 | vor der Theke (vor_theke) | Herr Schneider (schneider), Olli (olli), Pawel (hakan) | Lauter Streit zwischen Herrn Schneider und Olli um die 2.000 €. Pawel versucht zu schlichten und wird barsch abgewiesen. |
| 23:20 | an der Kamin-Nische (am_kamin) | Hana (meryem) | Hana feuert den Kamin an, ohne die Kaminklappe zu öffnen. |
| 23:30 | an der Kamin-Nische (am_kamin) | Hana (meryem), Herr Schneider (schneider) | Lacher: Dichter Qualm füllt den Kaminsaal, alle husten. Die Klappen der Lichtschächte werden aufgerissen, das Feuer wird gelöscht. Seitdem zieht Luft vom Buffetsaal in den Kaminsaal. |
| 23:40 | an der Schauvitrine (an_der_vitrine) | Fatma (fatma), Emine (emine) | Fatma hebt die gesprungene Scheibe der Vitrine an und nimmt die Münzschatulle mit. Emine sieht es. |
| 23:45 | am linken Buffettisch (am_linken_buffet) | Azra (dilara), Fatma (fatma) | Azra sieht, dass Fatmas Tasche auffällig ausgebeult ist. |
| 23:50 | vor der Bogentür (vor_bogentuer) | Wojtek (kaan) | Wojtek klemmt sich an der Bogentür den Finger ein. |
| 23:51 | vor der Theke (vor_theke) | Herr Schneider (schneider), Ahmet (ahmet), Joanna (johanna) | Herr Schneider zu Ahmet an der Theke: „Um zwölf sag ich allen, was der Keller gekostet hat.“ Joanna fotografiert den Streit. |
| 23:52 | vor der Bogentür (vor_bogentuer) | Olli (olli), Wojtek (kaan) | Olli zu Wojtek: „Ich hol dir Eis. Und dann red ich mit Schneider.“ |
| 23:53 | an der Schauvitrine (an_der_vitrine) | Herr Schneider (schneider) | Herr Schneider entdeckt auf seiner Runde die offene Vitrine und die Scherben. |
| 23:54 | im Vorratsraum vor dem Regal mit der Torte (vorrat_mitte) | Can (can), Zeynep (zeynep) | Can schleicht über den Durchgang hinter die Theke in den Vorratsraum, macht dort das Licht aus und wartet mit der Leuchtmaske auf die blinde Kuh. Zeynep steht am Bogen zum Durchgang Schmiere. |
| 23:55 | an der Wandtafel mit dem Ablaufplan (an_der_wandtafel) | Tugba (tugba), Detektiv (detective), Baran (baran) | Tugba ruft alle zu ihrem Mitternachtsspiel „Blinde Kuh“ in den Ost-Saal, die Handys kommen in den Handykorb. Der Detektiv bekommt als blinde Kuh eine Augenbinde und Barans Kopfhörer mit lauter Musik. Um zwölf soll die blinde Kuh zur Torte in den Vorratsraum geführt werden. |
| 23:55 | am Jackenständer (am_jackenstaender) | Ahmet (ahmet) | Ahmet hängt seine schwarze Jacke an den Jackenständer im Ost-Saal. |
| 23:56 | am Außentor (am_aussentor) | Serkan (serkan) | Serkan will Decken aus dem Auto holen und findet das Außentor verschlossen. |
| 23:56 | am linken Buffettisch (am_linken_buffet) | Herr Schneider (schneider), Fatma (fatma), Emine (emine) | Herr Schneider sieht Glassplitter an Fatmas Mantel: „Die Schatulle. Um Punkt zwölf geh ich raus und ruf die Polizei.“ |
| 23:57 | vor der Theke (vor_theke) | Ahmet (ahmet), Fatma (fatma), Olli (olli), Herr Schneider (schneider), Damir (enes), Lejla (leyla) | Fatma geht mit der Tasche zur Theken-Klappe, Olli holt am Eiskübel Eis, Ahmet schlüpft mit dem Umschlag hinter die Theke. Herr Schneider raunzt Olli an: „Zweitausend, bis zwölf.“ |
| 23:57:50 | hinter der Theke, vor der Kaffeemaschine (hinter_theke_ost) | Tim (tim), Herr Schneider (schneider) | Herr Schneider warnt Tim vor der alten Leiste. Tim steckt die Kaffeemaschine trotzdem in seine Mehrfachsteckdose. |
| 23:58 | hinter der Theke, vor der Kaffeemaschine (hinter_theke_ost) | alle | Knall. Die Hauptsicherung fliegt raus, überall ist es dunkel. Nur die Kerzen an der Anrichte und das grüne Notausgangsschild leuchten. |
| 23:58:13 | vor der Vorratsraumtür (vor_vorratstuer) | Herr Schneider (schneider), Can (can) | Herr Schneider will die Notlaterne holen. Can springt mit der leuchtenden Maske aus dem Vorratsraum, Herr Schneider packt ihn an der Kapuze: „Hab ich dich!“ |
| 23:58:40 | vor der Vorratsraumtür (vor_vorratstuer) | Herr Schneider (schneider) | Ein dumpfer Schlag, Poltern, Metall scheppert über den Steinboden. Die Kerzen erlöschen. Herr Schneider stürzt in den Vorratsraum. Wer zugeschlagen hat, steht in der Tatmatrix des jeweiligen Pfads. |
| 23:58:45 | direkt hinter der Vorratsraumtür (vorrat_innen) |  | Der Schlüsselbund wird vom Gürtel gezogen. Wer ihn nimmt und wo er landet, steht in der Tatmatrix des jeweiligen Pfads. |
| 00:00 | am Sicherungskasten (am_sicherungskasten) | Tim (tim) | Tim schaltet die Hauptsicherung wieder ein. |
| 00:00:20 | direkt hinter der Vorratsraumtür (vorrat_innen) | Damir (enes), Herr Schneider (schneider) | Damir findet Herrn Schneider im Vorratsraum. |
| 00:01:30 | direkt hinter der Vorratsraumtür (vorrat_innen) | Herr Schneider (schneider) | Herr Schneider kommt zu sich: Beule, Gedächtnislücke. „Mein Schlüsselbund! Der ist weg!“ |
| 00:03 | an der Innentür unter dem Notausgangsschild (unter_notausgang) | alle | Das Außentor ist zu, der Bund ist weg, hinter den Mauern gibt es keinen Empfang. Die Gruppe sitzt bis zum Morgen fest. |
| 00:05 | beim Handykorb auf der Tafel (am_handykorb) | Tugba (tugba) | Tugba gibt die Handys aus dem Korb zurück. Empfang hat keines. |
| 00:12 | an der Kamin-Nische (am_kamin) | Ahmet (ahmet) | Ahmet leert den Umschlag mit dem Mietgeld und wirft ihn in den Ascheneimer am Kamin. Hana sieht es. |
| 00:15 | am Fuß der Wendeltreppe (wendeltreppe_fuss) | Herr Schneider (schneider) | Herrn Schneider fällt der Ersatzschlüssel der Stiftung ein. Er holt ihn aus dem Schlüsselkasten im Turmgang und schließt damit die Hoftür, den Turm und die Seitentür vom Schlosshof ins Erdgeschoss auf. Das Außentor und das Einfahrtstor des Hofs öffnet der Ersatzschlüssel nicht. Hof und Garten sind hoch ummauert, die Fenster im Erdgeschoss vergittert. Die Gruppe sitzt weiter bis zum Morgen fest. |
| 00:20 | hinter dem rechten Buffettisch (hinter_rechtem_buffet) | Herr Schneider (schneider), Detektiv (detective) | Herr Schneider bittet den Detektiv: „Finde raus, wer das war. Bis zum Morgen.“ |
| 00:30 | vor der Theke (vor_theke) | alle | Runde 1: Das Alibi-Geflecht. |
| 01:15 | vor der Theke (vor_theke) | alle | Runde 2: Die Indizien-Filterung. |
| 02:00 | vor der Theke (vor_theke) | alle | Runde 3: Die finale Gegenüberstellung. |
| 02:45 | vor der Theke (vor_theke) | alle | Finale: die Anklage. |
| 07:00 | im Windfang (im_windfang) | Herr Schneider (schneider) | Herrn Schneiders Kollegin kommt mit ihrem Torschlüssel und schließt das Außentor auf. |

## 6. Gegenstände und Spuren

### Messingkerzenständer (`kerzenstaender`)

- **Lage:** vor der Vorratsraumtür (vor_vorratstuer); umgestoßen auf dem Steinboden vor der Vorratsraumtür; Tugba hat verboten, ihn anzufassen
- **Sichtbar:** ja
- **Beschreibung:** Schwerer Kerzenständer aus Messing für drei rote Wachskerzen. Herr Schneider hat ihn selbst poliert.

| Stelle | entsteht wenn | zeigt | harmlos | Rolle |
|---|---|---|---|---|
| Schaft | immer: ja | Der Schaft ist leicht verbogen, die drei roten Kerzen liegen daneben am Boden. | null | alle: umgebung |
| Griff | kerzenstaenderGegriffenVon: Ahmet (ahmet) | Am Griff klebt im erstarrten Wachs eine abgerissene Ecke braunes Umschlagpapier. Darauf steht „…keller“, in Ahmets Handschrift. | Der Griff ist mit rotem Wachs verschmiert. Das Wachs ist hart geworden und an einer Kante abgeplatzt. | Ahmet (ahmet): schluesselbeweis |
| Griff | kerzenstaenderGegriffenVon: Can (can) | Um den Griff liegt der Abdruck einer ganzen Hand in grünlich-weißer Leuchtfarbe. Es ist dieselbe Farbe wie auf der Maske. | Am Griff kleben dicke rote Wachstropfen, die vom Kerzenteller hinuntergelaufen sind. | Can (can): schluesselbeweis |
| Fuß | kerzenstaenderGegriffenVon: Olli (olli) | Im erstarrten roten Wachs am Fuß kleben feine Holzsplitter und weißer Kalk. | Am Fuß klebt rotes Wachs. Es ist zu einer dicken Nase erstarrt. | Olli (olli): schluesselbeweis |

### Fatmas breiter Silberring (`silberring_fatma`)

- **Lage:** bei Fatma (fatma)
- **Sichtbar:** nein
- **Beschreibung:** Ein breiter, glatter Silberring an Fatmas rechter Hand.

| Stelle | entsteht wenn | zeigt | harmlos | Rolle |
|---|---|---|---|---|
| Außenseite | kerzenstaenderGegriffenVon: Fatma (fatma) | In einer Kerbe des Rings steckt frischer, goldgelber Messingabrieb. | In einer Kerbe des Rings sind feine Kratzer von der Glasscheibe der Vitrine. | Fatma (fatma): schluesselbeweis |

### Ahmets schwarze Stoffjacke (`jacke_ahmet`)

- **Lage:** am Jackenständer (am_jackenstaender); Jackenständer (jackenstaender); vorderster Haken
- **Sichtbar:** ja
- **Beschreibung:** Ahmets Jacke hängt seit 23:55 am vordersten Haken des Jackenständers im Ost-Saal.

| Stelle | entsteht wenn | zeigt | harmlos | Rolle |
|---|---|---|---|---|
| Brusttasche | immer: ja | Eine Liste mit allen Namen der Gäste, hinter jedem „150 € ✓“. | null | alle: nebendelikt |
| Innentasche | bundEndetBei: jackenstaender | In der Innentasche der Jacke steckt Herrn Schneiders großer Schlüsselbund. | In der Innentasche liegt ein Kaugummipapier. | Ahmet (ahmet): fundort |

### Umschlag mit dem Mietgeld (`umschlag_mietgeld`)

- **Lage:** an der Kamin-Nische (am_kamin); Ascheneimer neben der Kamin-Nische (ascheneimer); leer im Ascheneimer neben der Kamin-Nische
- **Sichtbar:** ja
- **Beschreibung:** Ein brauner Umschlag mit Ahmets Handschrift: „Miete Schlosskeller“. Gegen 0:12 leert Ahmet ihn und wirft ihn in den Ascheneimer am Kamin.

| Stelle | entsteht wenn | zeigt | harmlos | Rolle |
|---|---|---|---|---|
| Vorderseite | immer: ja | „Miete Schlosskeller“ in Ahmets Handschrift. Der Umschlag ist leer. Darauf angesprochen gibt Ahmet zu: Er hat von allen 150 € Miete eingesammelt, obwohl der Keller umsonst war. | null | alle: nebendelikt |
| Rückseite | kerzenstaenderGegriffenVon: Ahmet (ahmet) | Auf dem Umschlag sind drei erstarrte rote Wachstropfen. Eine Ecke des Umschlags ist abgerissen. | Auf der Rückseite ist ein langer Knick, als hätte jemand den Umschlag zusammengefaltet. | Ahmet (ahmet): zusatzindiz |

### Münzschatulle aus der Schauvitrine (`muenzschatulle`)

- **Lage:** bei Fatma (fatma); in Fatmas Umhängetasche
- **Sichtbar:** nein
- **Beschreibung:** Kleine schwere Holzschatulle mit alten Schlossmünzen, Reliefs auf dem Deckel.

| Stelle | entsteht wenn | zeigt | harmlos | Rolle |
|---|---|---|---|---|
| Tasche | immer: ja | Die Schatulle aus der Vitrine liegt in Fatmas Tasche, zwischen Skizzenblock und Stiften. Darauf angesprochen gibt Fatma zu: Sie hat die Schatulle um 23:40 aus der Vitrine genommen. | null | alle: nebendelikt |
| Deckel | kerzenstaenderGegriffenVon: Fatma (fatma) | Auf dem Deckel der Münzschatulle kleben rote Wachstropfen. | Der Deckel ist blank poliert und zeigt ein Wappen mit zwei Löwen. | Fatma (fatma): zusatzindiz |

### Leuchtmaske (`leuchtmaske`)

- **Lage:** bei Can (can); in der Bauchtasche von Cans Pulli
- **Sichtbar:** nein
- **Beschreibung:** Weiße Gespenstermaske aus Kunststoff, am Nachmittag mit nachleuchtender Farbe bemalt.

| Stelle | entsteht wenn | zeigt | harmlos | Rolle |
|---|---|---|---|---|
| Bauchtasche | immer: ja | Die Maske steckt zusammengefaltet in Cans Bauchtasche. Die Farbe ist noch leicht klebrig. Darauf angesprochen gibt Can zu: Er hat im dunklen Vorratsraum gewartet, um die blinde Kuh zu erschrecken. | null | alle: nebendelikt |
| Stirn der Maske | kerzenstaenderGegriffenVon: Can (can) | Auf der Stirn der Maske kleben rote Wachstropfen. | Auf der Stirn der Maske ist grünlich-weiße Leuchtfarbe. | Can (can): zusatzindiz |

### Herrn Schneiders Schlüsselbund (`bund_schneider`)

- **Lage:** versteckt
- **Sichtbar:** nein
- **Beschreibung:** Großer Bund mit dem Schlüssel für das Außentor, die Hoftür und den Turm.

- **Versteck je Pfad:**
  - Ahmet (ahmet): am Jackenständer (am_jackenstaender); Jackenständer (jackenstaender); in der Innentasche von Ahmets Jacke
  - Fatma (fatma): hinter dem linken Buffettisch (hinter_linkem_buffet); linker Buffettisch (linkes_buffet_13); in der Brottasche auf dem linken Buffettisch
  - Olli (olli): vor der Theke beim Eiskübel (am_eiskuebel); unter dem Eis im Eiskübel
  - Can (can): bei der Ritterrüstung (an_der_ruestung); im Helm der Ritterrüstung

### Eiskübel (`eiskuebel`)

- **Lage:** vor der Theke beim Eiskübel (am_eiskuebel)
- **Sichtbar:** ja
- **Beschreibung:** Metallkübel mit Eiswürfeln am Ostende der Theke.

| Stelle | entsteht wenn | zeigt | harmlos | Rolle |
|---|---|---|---|---|
| unter dem Eis | bundEndetBei: am_eiskuebel | Im Eiskübel liegt unter den Eiswürfeln Herrn Schneiders Schlüsselbund. | Im Eiskübel sind Eiswürfel und Schmelzwasser. | Olli (olli): fundort |

### Brottasche (`brottasche`)

- **Lage:** hinter dem linken Buffettisch (hinter_linkem_buffet); linker Buffettisch (linkes_buffet_13)
- **Sichtbar:** ja
- **Beschreibung:** Leinentasche mit Fladenbrot und Baguette auf dem linken Buffettisch.

| Stelle | entsteht wenn | zeigt | harmlos | Rolle |
|---|---|---|---|---|
| unter dem Brot | bundEndetBei: linkes_buffet_13 | In der Brottasche liegt unter dem Brot Herrn Schneiders Schlüsselbund. | In der Brottasche liegen Brot und Krümel. | Fatma (fatma): fundort |

### Helm der Ritterrüstung (`ruestungshelm`)

- **Lage:** bei der Ritterrüstung (an_der_ruestung); Ritterrüstung (ruestung)
- **Sichtbar:** ja
- **Beschreibung:** Der Helm der alten Ritterrüstung im Turmgang, das Visier klemmt.

| Stelle | entsteht wenn | zeigt | harmlos | Rolle |
|---|---|---|---|---|
| im Helm | bundEndetBei: an_der_ruestung | Im Helm klemmt Herrn Schneiders Schlüsselbund. | Im Helm sind Staub und eine alte Spinnwebe. | Can (can): fundort |

### Quittungszettel „Miete: 0 Euro“ (`quittung_aylin`)

- **Lage:** bei Aylin (aylin); in Aylins Ledermappe
- **Sichtbar:** nein
- **Beschreibung:** Ein Zettel aus Herrn Schneiders Quittungsblock, um 22:30 für Aylin geschrieben und unterschrieben.

| Stelle | entsteht wenn | zeigt | harmlos | Rolle |
|---|---|---|---|---|
| Zettel | immer: ja | „Miete: 0 Euro. Schneider“. Aylin sagt: Ahmet hat trotzdem von allen 150 € eingesammelt. | null | alle: nebendelikt |

### Herrn Schneiders Klemmbrett mit Quittungsblock (`klemmbrett_schneider`)

- **Lage:** bei Herr Schneider (schneider)
- **Sichtbar:** nein
- **Beschreibung:** Klemmbrett mit Durchschlägen aller Quittungen des Abends.

| Stelle | entsteht wenn | zeigt | harmlos | Rolle |
|---|---|---|---|---|
| Durchschlag 18:50 | immer: ja | „Bogentür, Beschlag ausgerissen: 2.000 € Bargeld. Bis Mitternacht.“ | null | alle: motiv |
| Durchschlag 22:30 | immer: ja | „Miete: 0 Euro.“ | null | alle: nebendelikt |

### Schaden an der Bogentür (`bogentuer_schaden`)

- **Lage:** vor der Bogentür (vor_bogentuer); an der Bogentür
- **Sichtbar:** ja
- **Beschreibung:** Die geschnitzte Bogentür zwischen Kaminsaal und Turmgang.

| Stelle | entsteht wenn | zeigt | harmlos | Rolle |
|---|---|---|---|---|
| Türrahmen | immer: ja | Ein Beschlag ist ausgerissen, frische Holzsplitter, weißer Kalk vom Türbogen, darüber ein Rest braunes Möbelwachs. | null | alle: nebendelikt |

### Ollis linker Arbeitshandschuh (`arbeitshandschuh_olli`)

- **Lage:** an der Kamin-Nische (am_kamin); in der Kamin-Nische
- **Sichtbar:** ja
- **Beschreibung:** Ollis linker Arbeitshandschuh. Er hat ihn um 19:30 beim Wärmen am Kamin liegen lassen.

| Stelle | entsteht wenn | zeigt | harmlos | Rolle |
|---|---|---|---|---|
| Innenfläche | immer: ja | Ein linker Arbeitshandschuh, rußig vom Kamin. | null | alle: umgebung |

### Ollis rechter Arbeitshandschuh (`handschuh_weste_olli`)

- **Lage:** bei Olli (olli); hängt aus der Westentasche
- **Sichtbar:** nein
- **Beschreibung:** Der rechte Arbeitshandschuh hängt aus der Tasche von Ollis Daunenweste.

| Stelle | entsteht wenn | zeigt | harmlos | Rolle |
|---|---|---|---|---|
| Fingerkuppen | immer: ja | In Ollis Westentasche steckt sein rechter Arbeitshandschuh. An den Fingerkuppen sind braunes Möbelwachs und weißer Kalk. Darauf angesprochen gibt Olli zu: Er hat um 18:35 den Beschlag der Bogentür ausgerissen und die Schramme mit Wojteks Möbelwachs zugerieben. | null | alle: nebendelikt |
| Handrücken | kerzenstaenderGegriffenVon: Olli (olli) | Auf dem Handrücken des Handschuhs kleben frische rote Kerzenwachstropfen. | Auf dem Handrücken des Handschuhs ist Kalkstaub. | Olli (olli): zusatzindiz |

### Dose mit braunem Möbelwachs (`moebelwachs_dose`)

- **Lage:** bei Wojtek (kaan); in Wojteks Werkzeugtasche
- **Sichtbar:** nein
- **Beschreibung:** Aus Wojteks Werkzeugtasche.

| Stelle | entsteht wenn | zeigt | harmlos | Rolle |
|---|---|---|---|---|
| Deckel | immer: ja | Halb leer, am Rand Holzstaub. | null | alle: nebendelikt |

### Tims alte Mehrfachsteckdose (`mehrfachsteckdose_tim`)

- **Lage:** hinter der Theke, vor der Kaffeemaschine (hinter_theke_ost); auf dem Boden hinter der Theke beim Kaffeeautomaten
- **Sichtbar:** ja
- **Beschreibung:** Eine alte Steckdosenleiste, an der die Kaffeemaschine hängt.

| Stelle | entsteht wenn | zeigt | harmlos | Rolle |
|---|---|---|---|---|
| Stecker | immer: ja | Ein Steckplatz ist schwarz verschmort. Hier kam der Kurzschluss her. | null | alle: ausgangslage |

### Notlaterne (`notlaterne`)

- **Lage:** direkt hinter der Vorratsraumtür (vorrat_innen); am Haken neben der Tür
- **Sichtbar:** ja
- **Beschreibung:** Akkulaterne am Haken direkt hinter der Vorratsraumtür.

| Stelle | entsteht wenn | zeigt | harmlos | Rolle |
|---|---|---|---|---|
| Haken | immer: ja | Die Laterne hängt unberührt am Haken neben der Tür. | null | alle: umgebung |

### Schauvitrine im Turmgang (`vitrine`)

- **Lage:** an der Schauvitrine (an_der_vitrine); Schauvitrine (vitrine)
- **Sichtbar:** ja
- **Beschreibung:** Alte Vitrine mit Holzrahmen ohne Messing; seit 21:00 hat die Scheibe einen Sprung.

| Stelle | entsteht wenn | zeigt | harmlos | Rolle |
|---|---|---|---|---|
| Samtbett | immer: ja | Die gesprungene Scheibe ist angehoben, Scherben am Boden, das Samtbett der Münzschatulle ist leer. | null | alle: umgebung |

### Glassplitter an Fatmas Mantel (`glassplitter_mantel`)

- **Lage:** bei Fatma (fatma); am rechten Ärmel des beerenroten Mantels
- **Sichtbar:** nein
- **Beschreibung:** Winzige Glassplitter im Wollmantel.

| Stelle | entsteht wenn | zeigt | harmlos | Rolle |
|---|---|---|---|---|
| Ärmel | immer: ja | Feine Glassplitter, wie von der Vitrinenscheibe. | null | alle: nebendelikt |

### Gelbe Fasern (`gelbe_fasern`)

- **Lage:** bei Herr Schneider (schneider); an der rechten Hand
- **Sichtbar:** nein
- **Beschreibung:** Fasern zwischen Herrn Schneiders Fingern.

| Stelle | entsteht wenn | zeigt | harmlos | Rolle |
|---|---|---|---|---|
| rechte Hand | immer: ja | Knallgelbe Fasern, wie von einer Kapuze. | null | Ahmet (ahmet): falsche_faehrte; Fatma (fatma): falsche_faehrte; Olli (olli): falsche_faehrte; Can (can): ausgangslage |

### Rotes Wachs auf dem Boden (`wachs_boden`)

- **Lage:** vor der Vorratsraumtür (vor_vorratstuer); auf dem Steinboden vor der Vorratsraumtür
- **Sichtbar:** ja
- **Beschreibung:** Spritzer von rotem Kerzenwachs.

| Stelle | entsteht wenn | zeigt | harmlos | Rolle |
|---|---|---|---|---|
| Boden | immer: ja | Rote Wachsspritzer rund um die Stelle, an der der Kerzenständer liegt. | null | alle: umgebung |

### Joannas Foto von 23:51 (`foto_joanna`)

- **Lage:** bei Joanna (johanna); auf ihrem Handy
- **Sichtbar:** nein
- **Beschreibung:** Ein Foto auf Joannas Handy.

| Stelle | entsteht wenn | zeigt | harmlos | Rolle |
|---|---|---|---|---|
| Galerie | immer: ja | 23:51: Herr Schneider und Ahmet streiten an der Theke, Ahmet hält einen dicken Umschlag. | null | alle: motiv |

### Tugbas Notizbuch (`notizbuch_tugba`)

- **Lage:** bei Tugba (tugba)
- **Sichtbar:** nein
- **Beschreibung:** Goldenes Notizbuch mit dem Ablaufplan.

| Stelle | entsteht wenn | zeigt | harmlos | Rolle |
|---|---|---|---|---|
| Seite 23:57 | immer: ja | „Fehlen für die Torte: Ahmet (Theke, Servietten), Fatma (Theke), Olli (Eis), Can (?).“ Darunter: „Emine und Azra (Buffet), Damir und Tim (Kaffee), Marek (Saft), Zeynep, Hana, Wojtek, Sibel (Kaminsaal), Serkan (Auto).“ | null | alle: ueberblick |

### Handykorb (`handykorb`)

- **Lage:** beim Handykorb auf der Tafel (am_handykorb)
- **Sichtbar:** ja
- **Beschreibung:** Korb für die Handys auf der Tafel im Ost-Saal. Er steht seit 23:50 dort; ab 23:55 kommen alle Handys hinein.

| Stelle | entsteht wenn | zeigt | harmlos | Rolle |
|---|---|---|---|---|
| Korb | immer: ja | Alle Handys liegen darin. Hinter den Mauern fehlt der Empfang. | null | alle: ausgangslage |

### Mitternachtstorte (`torte`)

- **Lage:** im Vorratsraum vor dem Regal mit der Torte (vorrat_mitte)
- **Sichtbar:** ja
- **Beschreibung:** Die Torte auf dem Regal im kühlen Vorratsraum.

| Stelle | entsteht wenn | zeigt | harmlos | Rolle |
|---|---|---|---|---|
| Regal | immer: ja | Unversehrt. Wenigstens etwas. | null | alle: umgebung |

### Tims Stirnlampe (`stirnlampe_tim`)

- **Lage:** bei Tim (tim); um den Hals
- **Sichtbar:** nein
- **Beschreibung:** Kleine Stirnlampe an einem Band um den Hals. Beim Tasten nach dem Hauptschalter rutschte sie ihm vom Hals; um 23:59:40 fand er sie auf dem Boden.

| Stelle | entsteht wenn | zeigt | harmlos | Rolle |
|---|---|---|---|---|
| Lampe | immer: ja | Funktioniert. Damit hat Tim um Mitternacht den Sicherungskasten gefunden. | null | alle: ausgangslage |

### Bündel mit dem Mietgeld (`mietgeld`)

- **Lage:** bei Ahmet (ahmet); in Ahmets Hosentasche, seit 0:12
- **Sichtbar:** nein
- **Beschreibung:** Neunzehnmal 150 €, zusammen 2.850 €.

| Stelle | entsteht wenn | zeigt | harmlos | Rolle |
|---|---|---|---|---|
| Hosentasche | immer: ja | Ein dickes Bündel Scheine, 2.850 €. Ahmet hat alles davon aufbewahrt. | null | alle: nebendelikt |

**Nebendelikte**

| Kennung | Person | Text |
|---|---|---|
| nd_mietgeld | Ahmet (ahmet) | 150 € Miete von allen kassiert, obwohl der Keller nichts gekostet hat. |
| nd_schatulle | Fatma (fatma) | Münzschatulle aus der Schauvitrine mitgenommen. |
| nd_tuerschaden | Olli (olli) | Bogentür beschädigt und die Schramme mit Möbelwachs verdeckt. |
| nd_streich | Can (can) | Mit der Leuchtmaske im Vorratsraum versteckt. |
| nd_kurzschluss | Tim (tim) | Trotz Warnung die alte Mehrfachsteckdose benutzt. |
| nd_parken | Marek (murat) | Auf Herrn Schneiders reserviertem Platz geparkt. |
| nd_schmiere | Zeynep (zeynep) | Für Cans Streich Schmiere gestanden. |
| nd_moebelwachs | Wojtek (kaan) | Olli das Möbelwachs zum Verdecken der Schramme gegeben. |

## 7. Beobachtungen

| Kennung | Wer | Pfade | Kanal | Text | widerlegt | belastet | entlastet |
|---|---|---|---|---|---|---|---|
| b_lejla_ahmet_theke | Lejla (leyla) | alle | pflichtgespraech | Um 23:57 schlüpfte Ahmet mit einem dicken Umschlag hinter die Theke. | luege_ahmet_servietten | Ahmet (ahmet) | – |
| b_damir_an_der_theke | Damir (enes) | alle | pflichtgespraech | Um 23:57 standen Ahmet, Fatma und Olli an der Theke, Herr Schneider am Ostende. Can war nicht zu sehen. | luege_fatma_buffet, luege_olli_tafel | Ahmet (ahmet), Fatma (fatma), Olli (olli) | – |
| b_emine_schatulle | Emine (emine) | alle | verborgen | Um 23:40 sah sie im Turmgang, wie Fatma die Münzschatulle aus der Vitrine nahm. | luege_fatma_tasche | Fatma (fatma) | – |
| b_emine_versteck | Emine (emine) | alle | pflichtgespraech | Beim Knall duckte sie sich hinter den linken Buffettisch und blieb dort, bis das Licht anging. | – | – | – |
| b_azra_tasche | Azra (dilara) | alle | pflichtgespraech | Um 23:45 war Fatmas Tasche auffällig ausgebeult. | – | Fatma (fatma) | – |
| b_azra_versteck | Azra (dilara) | alle | pflichtgespraech | Beim Knall duckte sie sich am rechten Buffettisch und blieb dort, bis das Licht anging. | – | – | – |
| b_joanna_foto | Joanna (johanna) | alle | verborgen | Sie hat ein Foto von 23:51: Herr Schneider und Ahmet streiten an der Theke, Ahmet hält einen dicken Umschlag. | – | Ahmet (ahmet) | – |
| b_marek_gesicht | Marek (murat) | alle | pflichtgespraech | Im Dunkeln rannte ein leuchtendes Gespenstergesicht an ihm vorbei durch den Durchgang Richtung Kaminsaal. | – | Can (can) | – |
| b_selin_gesicht | Sibel (selin) | alle | pflichtgespraech | Im Dunkeln huschte ein leuchtendes Gesicht quer durch den Kaminsaal zur Bogentür. | – | Can (can) | – |
| b_tim_gesicht | Tim (tim) | alle | pflichtgespraech | Am Sicherungskasten huschte im Dunkeln ein leuchtendes Gesicht an ihm vorbei. | – | Can (can) | – |
| b_tim_kurzschluss | Tim (tim) | alle | verborgen | Der Kurzschluss kam von seiner alten Mehrfachsteckdose. | – | – | – |
| b_zeynep_vorrat | Zeynep (zeynep) | alle | verborgen | Can hat mit der Leuchtmaske im dunklen Vorratsraum auf die blinde Kuh gewartet. | luege_can_toilette, luege_can_maske | Can (can) | – |
| b_zeynep_gesicht | Zeynep (zeynep) | alle | pflichtgespraech | Ein leuchtendes Gesicht kam aus dem Durchgang an ihr vorbei in den Kaminsaal. | – | Can (can) | – |
| b_hana_wachs | Hana (meryem) | alle | pflichtgespraech | Kurz nach dem Scheppern roch sie frisch erloschenes Kerzenwachs. Der Geruch kam mit dem Luftzug aus Richtung Theke. | – | – | – |
| b_hana_umschlag | Hana (meryem) | alle | pflichtgespraech | Kurz nach zwölf warf Ahmet etwas Raschelndes in den Ascheneimer neben dem Kamin. | – | Ahmet (ahmet) | – |
| b_baran_rufe | Baran (baran) | alle | pflichtgespraech | Aus Richtung Theke hörte er erst „Hab ich dich!“, dann „Stehen bleiben!“, dann das Scheppern. | – | – | – |
| b_serkan_tor | Serkan (serkan) | alle | pflichtgespraech | Von kurz vor zwölf bis nach zwölf stand er am Außentor. Es war abgeschlossen; niemand ist hinaus. | – | – | – |
| b_wojtek_olli_satz | Wojtek (kaan) | alle | pflichtgespraech | Um 23:52 sagte Olli: „Ich hol dir Eis. Und dann red ich mit Schneider.“ | – | Olli (olli) | – |
| b_wojtek_vorbei | Wojtek (kaan) | alle | pflichtgespraech | Im Dunkeln drängte sich jemand an ihm vorbei durch die Bogentür in den Turm. | – | – | – |
| b_wojtek_tuer | Wojtek (kaan) | alle | verborgen | Er weiß: Olli hat am Abend die Bogentür beschädigt. Das Möbelwachs zum Verdecken kam von ihm. | – | Olli (olli) | – |
| b_pawel_schneider | Pawel (hakan) | alle | pflichtgespraech | Herr Schneider muss jeden Schaden der Stiftung melden. Darum ist er beim Geld so streng. | – | – | – |
| b_aylin_quittung | Aylin (aylin) | alle | pflichtgespraech | Sie hat Herrn Schneiders Quittungszettel: „Miete: 0 Euro.“ | luege_ahmet_miete | Ahmet (ahmet) | – |
| b_tugba_notiz | Tugba (tugba) | alle | pflichtgespraech | Um 23:57 hat sie notiert, wer für die Torte fehlt und wo die Leute angeblich gerade sind. | luege_olli_tafel | – | – |
| b_detektiv_gehoert | Detektiv (detective) | alle | erzaehler | Durch die Musik hast du nur einen Knall gehört, dann Herrn Schneiders Rufe „Hab ich dich!“ und „Stehen bleiben!“ und später ein Scheppern. | – | – | – |
| b_schneider_erinnerung | Herr Schneider (schneider) | alle | erzaehler | Knall, Dunkelheit, der Weg zur Notlaterne, ein leuchtendes Gespenstergesicht. Er packt eine Kapuze und ruft „Hab ich dich!“. Danach ist alles weg. | – | Can (can) | – |
| b_azra_olli_frueh | Azra (dilara) | Ahmet (ahmet), Fatma (fatma), Can (can) | verborgen | Beim Scheppern kauerte Olli neben ihr hinter dem rechten Buffettisch. Er war schon seit dem Knall da und hatte geflüstert: „Azra? Ich bin's, Olli.“ | – | – | Olli (olli) |
| b_azra_olli_spaet | Azra (dilara) | Olli (olli) | verborgen | Beim Scheppern war Olli nicht neben ihr. Er kam erst danach und flüsterte: „Azra? Ich bin's, Olli.“ | – | Olli (olli) | – |
| b_emine_fatma_frueh | Emine (emine) | Ahmet (ahmet), Olli (olli), Can (can) | verborgen | Beim Scheppern kauerte Fatma neben ihr hinter dem linken Buffettisch. Sie war schon seit dem Knall da und hatte geflüstert: „Emine? Ich bin's, Fatma.“ | – | – | Fatma (fatma) |
| b_emine_fatma_spaet | Emine (emine) | Fatma (fatma) | verborgen | Beim Scheppern war Fatma nicht neben ihr. Sie kam erst danach und flüsterte: „Emine? Ich bin's, Fatma.“ | – | Fatma (fatma) | – |
| b_damir_ahmet_blieb | Damir (enes) | Fatma (fatma), Olli (olli) | verborgen | Beim Scheppern kauerte Ahmet neben ihm am Ostende der Theke. Er war schon seit dem Knall da und hatte geflüstert: „Damir? Ich bin's, Ahmet.“ | – | – | Ahmet (ahmet) |
| b_damir_ahmet_weg | Damir (enes) | Ahmet (ahmet), Can (can) | verborgen | Beim Scheppern war Ahmet nicht neben ihm. Er war kurz davor aufgestanden und kam erst danach zurück: „Damir, ich bin's wieder.“ | – | Ahmet (ahmet) | – |
| b_ahmet_haelt | Ahmet (ahmet) | Fatma (fatma), Olli (olli) | verborgen | Im Dunkeln blieb er neben Damir und hielt den Umschlag mit dem Mietgeld fest, bis das Licht anging. | – | – | – |
| b_ahmet_jacke | Ahmet (ahmet) | Can (can) | verborgen | Kurz vor dem Scheppern stand er auf und ging im Dunkeln in den Ost-Saal. Dort steckte er den Umschlag in seine Jacke. Erst nach dem Scheppern kam er zurück zu Damir. Kurz nach zwölf holte er den Umschlag wieder aus der Jacke. | – | – | Ahmet (ahmet) |
| b_marek_vor | Marek (murat) | Ahmet (ahmet), Fatma (fatma), Olli (olli) | verborgen | Das leuchtende Gesicht rannte an ihm vorbei, bevor es an der Theke schepperte. | – | – | Can (can) |
| b_marek_nach | Marek (murat) | Can (can) | verborgen | Das leuchtende Gesicht rannte an ihm vorbei, nachdem es an der Theke gescheppert hatte. | – | Can (can) | – |

## 8. Tatmatrix je Pfad

### Pfad Ahmet

| Zeit | detective | schneider | ahmet | fatma | olli | can | leyla | emine | tim | johanna | murat | zeynep | baran | meryem | serkan | aylin | kaan | dilara | enes | selin | hakan | tugba |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 23:55 | unterwegs bei ost_tafel_ost (x 24.5, y 13.5) (geht) | unterwegs bei vor_bogentuer (x 3.2, y 8.5) (geht) | am_handykorb | am_linken_buffet | ost_tafel_kopf (sitzt) | vorrat_mitte | hinter_theke_mitte | hinter_linkem_buffet | hinter_theke_ost | am_handykorb | unter_notausgang | west_bogen | unterwegs bei ost_bank (x 25.5, y 15.5) (geht) | am_kamin | unter_notausgang | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | hinter_theke_mitte | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | an_der_wandtafel |
| 23:55:15 | geburtstagsplatz (augenbinde) | unterwegs bei west_bogen (x 7.0, y 9.5) (geht) | unterwegs bei an_der_wandtafel (x 24.5, y 11.0) (geht) | am_linken_buffet | ost_tafel_kopf (sitzt) | vorrat_mitte | hinter_theke_mitte | hinter_linkem_buffet | hinter_theke_ost | am_handykorb | unter_notausgang | west_bogen | geburtstagsplatz | am_kamin | unter_notausgang | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | hinter_theke_mitte | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | unterwegs bei ost_tafel_ost (x 24.5, y 13.5) (geht) |
| 23:55:30 | geburtstagsplatz (augenbinde) | unterwegs bei theke_klappe (x 11.2, y 9.5) (geht) | am_jackenstaender | am_linken_buffet | ost_tafel_kopf (sitzt) | vorrat_mitte | hinter_theke_mitte | hinter_linkem_buffet | hinter_theke_ost | am_handykorb | unter_notausgang | west_bogen | ost_bank (sitzt) | am_kamin | unterwegs bei unter_notausgang (x 14.5, y 18.5) (geht) | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | hinter_theke_mitte | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 23:55:45 | geburtstagsplatz (augenbinde) | unterwegs bei am_linken_buffet (x 13.5, y 12.1) (geht) | am_jackenstaender | am_linken_buffet | ost_tafel_kopf (sitzt) | vorrat_mitte | hinter_theke_mitte | hinter_linkem_buffet | hinter_theke_ost | am_handykorb | unter_notausgang | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | hinter_theke_mitte | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 23:56 | geburtstagsplatz (augenbinde) | am_linken_buffet | am_jackenstaender | am_linken_buffet | ost_tafel_kopf (sitzt) | vorrat_mitte | hinter_theke_mitte | hinter_linkem_buffet | hinter_theke_ost | am_handykorb | unter_notausgang | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | hinter_theke_mitte | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 23:56:15 | geburtstagsplatz (augenbinde) | am_linken_buffet | am_jackenstaender | am_linken_buffet | ost_tafel_kopf (sitzt) | vorrat_mitte | hinter_theke_mitte | hinter_linkem_buffet | hinter_theke_ost | am_handykorb | unter_notausgang | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | hinter_theke_mitte | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 23:56:30 | geburtstagsplatz (augenbinde) | unterwegs bei am_linken_buffet (x 13.5, y 13.5) (geht) | am_jackenstaender | am_linken_buffet | unterwegs bei ost_tafel_kopf (x 22.5, y 10.5) (geht) | vorrat_mitte | hinter_theke_mitte | hinter_linkem_buffet | hinter_theke_ost | am_handykorb | unter_notausgang | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | hinter_theke_mitte | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 23:56:45 | geburtstagsplatz (augenbinde) | unterwegs bei am_eiskuebel (x 17.7, y 10.5) (geht) | am_jackenstaender | am_linken_buffet | unterwegs bei theke_ostende (x 18.5, y 9.9) (geht) | vorrat_mitte | hinter_theke_mitte | hinter_linkem_buffet | hinter_theke_ost | am_handykorb | unter_notausgang | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | hinter_theke_mitte | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 23:57 | geburtstagsplatz (augenbinde) | theke_ostende | hinter_theke_ost | unterwegs bei am_linken_buffet (x 13.5, y 13.5) (geht) | am_eiskuebel | unterwegs bei vorrat_mitte (x 14.5, y 3.5) (geht) | hinter_theke_mitte | hinter_linkem_buffet | hinter_theke_ost | am_handykorb | unterwegs bei unter_notausgang (x 14.5, y 18.5) (geht) | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | hinter_theke_mitte | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 23:57:15 | geburtstagsplatz (augenbinde) | theke_ostende | hinter_theke_ost | theke_klappe | am_eiskuebel | vorrat_innen | hinter_theke_mitte | hinter_linkem_buffet | hinter_theke_ost | am_handykorb | unterwegs bei theke_klappe (x 11.5, y 10.0) (geht) | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | hinter_theke_mitte | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 23:57:30 | geburtstagsplatz (augenbinde) | hinter_theke_ost | hinter_theke_ost | theke_klappe | am_eiskuebel | vorrat_innen | hinter_theke_mitte | hinter_linkem_buffet | hinter_theke_ost | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | unterwegs bei hinter_theke_mitte (x 15.5, y 8.5) (geht) | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 23:57:45 | geburtstagsplatz (augenbinde) | hinter_theke_ost | hinter_theke_ost | theke_klappe | am_eiskuebel | vorrat_innen | unterwegs bei ost_eingang (x 19.7, y 9.5) (geht) | hinter_linkem_buffet | hinter_theke_ost | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | hinter_theke_ost | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 23:58 | geburtstagsplatz (augenbinde) | hinter_theke_ost | hinter_theke_ost (kauert) | theke_klappe | am_eiskuebel | vorrat_innen | ost_tafel_west | hinter_linkem_buffet (kauert) | unterwegs bei hinter_theke_ost (x 17.5, y 8.5) (geht) | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet (kauert) | hinter_theke_ost (kauert) | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 23:58:15 | geburtstagsplatz (augenbinde) | vor_vorratstuer | hinter_theke_ost (kauert) | hinter_linkem_buffet (kauert) | am_rechten_buffet (kauert) | vor_vorratstuer | ost_tafel_west | hinter_linkem_buffet (kauert) | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet (kauert) | hinter_theke_ost (kauert) | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 23:58:30 | geburtstagsplatz (augenbinde) | vor_vorratstuer | unterwegs bei hinter_theke_ost (x 17.5, y 8.5) (geht) | hinter_linkem_buffet (kauert) | am_rechten_buffet (kauert) | unterwegs bei theke_klappe (x 11.5, y 9.3) (rennt) | ost_tafel_west | hinter_linkem_buffet (kauert) | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet (kauert) | hinter_theke_ost (kauert) | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 23:58:45 | geburtstagsplatz (augenbinde) | vorrat_innen (liegt) | vorrat_innen | hinter_linkem_buffet (kauert) | am_rechten_buffet (kauert) | unterwegs bei wendeltreppe_fuss (x 2.5, y 1.5) (geht) | ost_tafel_west | hinter_linkem_buffet (kauert) | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet (kauert) | hinter_theke_ost (kauert) | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 23:59 | geburtstagsplatz (augenbinde) | vorrat_innen (liegt) | am_jackenstaender | hinter_linkem_buffet (kauert) | am_rechten_buffet (kauert) | wc | ost_tafel_west | hinter_linkem_buffet (kauert) | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet (kauert) | hinter_theke_ost (kauert) | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 23:59:15 | geburtstagsplatz (augenbinde) | vorrat_innen (liegt) | hinter_theke_ost (kauert) | hinter_linkem_buffet (kauert) | am_rechten_buffet (kauert) | wc | ost_tafel_west | hinter_linkem_buffet (kauert) | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet (kauert) | hinter_theke_ost (kauert) | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 23:59:30 | geburtstagsplatz (augenbinde) | vorrat_innen (liegt) | hinter_theke_ost (kauert) | hinter_linkem_buffet (kauert) | am_rechten_buffet (kauert) | wc | ost_tafel_west | hinter_linkem_buffet (kauert) | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet (kauert) | hinter_theke_ost (kauert) | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 23:59:45 | geburtstagsplatz (augenbinde) | vorrat_innen (liegt) | hinter_theke_ost (kauert) | hinter_linkem_buffet (kauert) | am_rechten_buffet (kauert) | wc | ost_tafel_west | hinter_linkem_buffet (kauert) | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet (kauert) | hinter_theke_ost (kauert) | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 00:00 | geburtstagsplatz (augenbinde) | vorrat_innen (liegt) | hinter_theke_ost (kauert) | hinter_linkem_buffet (kauert) | am_rechten_buffet (kauert) | wc | ost_tafel_west | hinter_linkem_buffet (kauert) | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet (kauert) | hinter_theke_ost (kauert) | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 00:00:15 | geburtstagsplatz (augenbinde) | vorrat_innen (liegt) | hinter_theke_ost | hinter_linkem_buffet | am_rechten_buffet | wc | ost_tafel_west | hinter_linkem_buffet | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | unterwegs bei vor_vorratstuer (x 14.5, y 6.5) (geht) | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 00:00:30 | geburtstagsplatz (augenbinde) | vorrat_innen (liegt) | hinter_theke_ost | hinter_linkem_buffet | unterwegs bei am_rechten_buffet (x 16.5, y 13.5) (geht) | wc | ost_tafel_west | hinter_linkem_buffet | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | vorrat_innen | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 00:00:45 | geburtstagsplatz (sitzt) | vorrat_innen (liegt) | hinter_theke_ost | hinter_linkem_buffet | unterwegs bei durchgang_mitte (x 8.7, y 9.5) (geht) | wc | ost_tafel_west | hinter_linkem_buffet | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | vorrat_innen | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 00:01 | geburtstagsplatz (sitzt) | vorrat_innen (liegt) | hinter_theke_ost | hinter_linkem_buffet | vor_bogentuer | unterwegs bei wendeltreppe_fuss (x 2.5, y 1.5) (geht) | ost_tafel_west | hinter_linkem_buffet | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | vorrat_innen | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 00:01:15 | geburtstagsplatz (sitzt) | vorrat_innen (liegt) | hinter_theke_ost | hinter_linkem_buffet | vor_bogentuer | unterwegs bei west_bank_west (x 1.5, y 10.5) (geht) | ost_tafel_west | hinter_linkem_buffet | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | vorrat_innen | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 00:01:30 | geburtstagsplatz (sitzt) | vorrat_innen (sitzt) | hinter_theke_ost | hinter_linkem_buffet | unterwegs bei vor_bogentuer (x 2.5, y 8.5) (geht) | west_bank_west | ost_tafel_west | hinter_linkem_buffet | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | vorrat_innen | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 00:01:45 | geburtstagsplatz (sitzt) | vorrat_innen (sitzt) | hinter_theke_ost | hinter_linkem_buffet | unterwegs bei theke_klappe (x 10.6, y 9.5) (geht) | west_bank_west | ost_tafel_west | hinter_linkem_buffet | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | vorrat_innen | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 00:02 | geburtstagsplatz (sitzt) | vorrat_innen (sitzt) | hinter_theke_ost | hinter_linkem_buffet | unterwegs bei am_eiskuebel (x 18.2, y 10.5) (geht) | west_bank_west | ost_tafel_west | hinter_linkem_buffet | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | vorrat_innen | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 00:02:15 | geburtstagsplatz (sitzt) | vorrat_innen (sitzt) | hinter_theke_ost | hinter_linkem_buffet | ost_tafel_kopf (sitzt) | west_bank_west | ost_tafel_west | hinter_linkem_buffet | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | vorrat_innen | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 00:02:30 | geburtstagsplatz (sitzt) | vorrat_innen (sitzt) | hinter_theke_ost | hinter_linkem_buffet | ost_tafel_kopf (sitzt) | west_bank_west | ost_tafel_west | hinter_linkem_buffet | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | unterwegs bei am_aussentor (x 15.5, y 21.5) (geht) | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | vorrat_innen | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 00:02:45 | geburtstagsplatz (sitzt) | vorrat_innen (sitzt) | hinter_theke_ost | hinter_linkem_buffet | ost_tafel_kopf (sitzt) | west_bank_west | ost_tafel_west | hinter_linkem_buffet | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | unter_notausgang | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | vorrat_innen | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 00:03 | geburtstagsplatz (sitzt) | vorrat_innen (sitzt) | hinter_theke_ost | hinter_linkem_buffet | ost_tafel_kopf (sitzt) | west_bank_west | ost_tafel_west | hinter_linkem_buffet | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | unter_notausgang | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | vorrat_innen | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 00:03:15 | geburtstagsplatz (sitzt) | vorrat_innen (sitzt) | hinter_theke_ost | hinter_linkem_buffet | ost_tafel_kopf (sitzt) | west_bank_west | ost_tafel_west | hinter_linkem_buffet | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | unter_notausgang | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | vorrat_innen | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 00:03:30 | geburtstagsplatz (sitzt) | vorrat_innen (sitzt) | hinter_theke_ost | hinter_linkem_buffet | ost_tafel_kopf (sitzt) | west_bank_west | ost_tafel_west | hinter_linkem_buffet | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | unter_notausgang | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | vorrat_innen | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 00:03:45 | geburtstagsplatz (sitzt) | vorrat_innen (sitzt) | hinter_theke_ost | hinter_linkem_buffet | ost_tafel_kopf (sitzt) | west_bank_west | ost_tafel_west | hinter_linkem_buffet | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | unter_notausgang | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | vorrat_innen | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 00:04 | geburtstagsplatz (sitzt) | vorrat_innen (sitzt) | hinter_theke_ost | hinter_linkem_buffet | ost_tafel_kopf (sitzt) | west_bank_west | ost_tafel_west | hinter_linkem_buffet | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | unter_notausgang | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | vorrat_innen | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 00:04:15 | geburtstagsplatz (sitzt) | vorrat_innen (sitzt) | hinter_theke_ost | hinter_linkem_buffet | ost_tafel_kopf (sitzt) | west_bank_west | ost_tafel_west | hinter_linkem_buffet | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | unter_notausgang | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | vorrat_innen | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 00:04:30 | geburtstagsplatz (sitzt) | vorrat_innen (sitzt) | hinter_theke_ost | hinter_linkem_buffet | ost_tafel_kopf (sitzt) | west_bank_west | ost_tafel_west | hinter_linkem_buffet | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | unter_notausgang | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | vorrat_innen | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 00:04:45 | geburtstagsplatz (sitzt) | vorrat_innen (sitzt) | hinter_theke_ost | hinter_linkem_buffet | ost_tafel_kopf (sitzt) | west_bank_west | ost_tafel_west | hinter_linkem_buffet | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | unter_notausgang | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | vorrat_innen | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 00:05 | geburtstagsplatz (sitzt) | vorrat_innen (sitzt) | hinter_theke_ost | hinter_linkem_buffet | ost_tafel_kopf (sitzt) | west_bank_west | ost_tafel_west | hinter_linkem_buffet | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | unter_notausgang | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | vorrat_innen | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |

### Pfad Fatma

| Zeit | detective | schneider | ahmet | fatma | olli | can | leyla | emine | tim | johanna | murat | zeynep | baran | meryem | serkan | aylin | kaan | dilara | enes | selin | hakan | tugba |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 23:55 | unterwegs bei ost_tafel_ost (x 24.5, y 13.5) (geht) | unterwegs bei vor_bogentuer (x 3.2, y 8.5) (geht) | am_handykorb | am_linken_buffet | ost_tafel_kopf (sitzt) | vorrat_mitte | hinter_theke_mitte | hinter_linkem_buffet | hinter_theke_ost | am_handykorb | unter_notausgang | west_bogen | unterwegs bei ost_bank (x 25.5, y 15.5) (geht) | am_kamin | unter_notausgang | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | hinter_theke_mitte | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | an_der_wandtafel |
| 23:55:15 | geburtstagsplatz (augenbinde) | unterwegs bei west_bogen (x 7.0, y 9.5) (geht) | unterwegs bei an_der_wandtafel (x 24.5, y 11.0) (geht) | am_linken_buffet | ost_tafel_kopf (sitzt) | vorrat_mitte | hinter_theke_mitte | hinter_linkem_buffet | hinter_theke_ost | am_handykorb | unter_notausgang | west_bogen | geburtstagsplatz | am_kamin | unter_notausgang | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | hinter_theke_mitte | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | unterwegs bei ost_tafel_ost (x 24.5, y 13.5) (geht) |
| 23:55:30 | geburtstagsplatz (augenbinde) | unterwegs bei theke_klappe (x 11.2, y 9.5) (geht) | am_jackenstaender | am_linken_buffet | ost_tafel_kopf (sitzt) | vorrat_mitte | hinter_theke_mitte | hinter_linkem_buffet | hinter_theke_ost | am_handykorb | unter_notausgang | west_bogen | ost_bank (sitzt) | am_kamin | unterwegs bei unter_notausgang (x 14.5, y 18.5) (geht) | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | hinter_theke_mitte | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 23:55:45 | geburtstagsplatz (augenbinde) | unterwegs bei am_linken_buffet (x 13.5, y 12.1) (geht) | am_jackenstaender | am_linken_buffet | ost_tafel_kopf (sitzt) | vorrat_mitte | hinter_theke_mitte | hinter_linkem_buffet | hinter_theke_ost | am_handykorb | unter_notausgang | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | hinter_theke_mitte | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 23:56 | geburtstagsplatz (augenbinde) | am_linken_buffet | am_jackenstaender | am_linken_buffet | ost_tafel_kopf (sitzt) | vorrat_mitte | hinter_theke_mitte | hinter_linkem_buffet | hinter_theke_ost | am_handykorb | unter_notausgang | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | hinter_theke_mitte | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 23:56:15 | geburtstagsplatz (augenbinde) | am_linken_buffet | am_jackenstaender | am_linken_buffet | ost_tafel_kopf (sitzt) | vorrat_mitte | hinter_theke_mitte | hinter_linkem_buffet | hinter_theke_ost | am_handykorb | unter_notausgang | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | hinter_theke_mitte | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 23:56:30 | geburtstagsplatz (augenbinde) | unterwegs bei am_linken_buffet (x 13.5, y 13.5) (geht) | am_jackenstaender | am_linken_buffet | unterwegs bei ost_tafel_kopf (x 22.5, y 10.5) (geht) | vorrat_mitte | hinter_theke_mitte | hinter_linkem_buffet | hinter_theke_ost | am_handykorb | unter_notausgang | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | hinter_theke_mitte | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 23:56:45 | geburtstagsplatz (augenbinde) | unterwegs bei am_eiskuebel (x 17.7, y 10.5) (geht) | am_jackenstaender | am_linken_buffet | unterwegs bei theke_ostende (x 18.5, y 9.9) (geht) | vorrat_mitte | hinter_theke_mitte | hinter_linkem_buffet | hinter_theke_ost | am_handykorb | unter_notausgang | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | hinter_theke_mitte | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 23:57 | geburtstagsplatz (augenbinde) | theke_ostende | hinter_theke_ost | unterwegs bei am_linken_buffet (x 13.5, y 13.5) (geht) | am_eiskuebel | unterwegs bei vorrat_mitte (x 14.5, y 3.5) (geht) | hinter_theke_mitte | hinter_linkem_buffet | hinter_theke_ost | am_handykorb | unterwegs bei unter_notausgang (x 14.5, y 18.5) (geht) | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | hinter_theke_mitte | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 23:57:15 | geburtstagsplatz (augenbinde) | theke_ostende | hinter_theke_ost | theke_klappe | am_eiskuebel | vorrat_innen | hinter_theke_mitte | hinter_linkem_buffet | hinter_theke_ost | am_handykorb | unterwegs bei theke_klappe (x 11.5, y 10.0) (geht) | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | hinter_theke_mitte | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 23:57:30 | geburtstagsplatz (augenbinde) | hinter_theke_ost | hinter_theke_ost | theke_klappe | am_eiskuebel | vorrat_innen | hinter_theke_mitte | hinter_linkem_buffet | hinter_theke_ost | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | unterwegs bei hinter_theke_mitte (x 15.5, y 8.5) (geht) | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 23:57:45 | geburtstagsplatz (augenbinde) | hinter_theke_ost | hinter_theke_ost | theke_klappe | am_eiskuebel | vorrat_innen | unterwegs bei ost_eingang (x 19.7, y 9.5) (geht) | hinter_linkem_buffet | hinter_theke_ost | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | hinter_theke_ost | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 23:58 | geburtstagsplatz (augenbinde) | hinter_theke_ost | hinter_theke_ost (kauert) | unterwegs bei theke_klappe (x 11.5, y 9.5) (geht) | am_eiskuebel | vorrat_innen | ost_tafel_west | hinter_linkem_buffet (kauert) | unterwegs bei hinter_theke_ost (x 17.5, y 8.5) (geht) | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet (kauert) | hinter_theke_ost (kauert) | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 23:58:15 | geburtstagsplatz (augenbinde) | vor_vorratstuer | hinter_theke_ost (kauert) | vor_theke_west | am_rechten_buffet (kauert) | vor_vorratstuer | ost_tafel_west | hinter_linkem_buffet (kauert) | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet (kauert) | hinter_theke_ost (kauert) | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 23:58:30 | geburtstagsplatz (augenbinde) | vor_vorratstuer | hinter_theke_ost (kauert) | vor_theke_west | am_rechten_buffet (kauert) | unterwegs bei theke_klappe (x 11.5, y 9.3) (rennt) | ost_tafel_west | hinter_linkem_buffet (kauert) | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet (kauert) | hinter_theke_ost (kauert) | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 23:58:45 | geburtstagsplatz (augenbinde) | vorrat_innen (liegt) | hinter_theke_ost (kauert) | vorrat_innen | am_rechten_buffet (kauert) | unterwegs bei wendeltreppe_fuss (x 2.5, y 1.5) (geht) | ost_tafel_west | hinter_linkem_buffet (kauert) | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet (kauert) | hinter_theke_ost (kauert) | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 23:59 | geburtstagsplatz (augenbinde) | vorrat_innen (liegt) | hinter_theke_ost (kauert) | hinter_linkem_buffet (kauert) | am_rechten_buffet (kauert) | wc | ost_tafel_west | hinter_linkem_buffet (kauert) | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet (kauert) | hinter_theke_ost (kauert) | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 23:59:15 | geburtstagsplatz (augenbinde) | vorrat_innen (liegt) | hinter_theke_ost (kauert) | hinter_linkem_buffet (kauert) | am_rechten_buffet (kauert) | wc | ost_tafel_west | hinter_linkem_buffet (kauert) | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet (kauert) | hinter_theke_ost (kauert) | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 23:59:30 | geburtstagsplatz (augenbinde) | vorrat_innen (liegt) | hinter_theke_ost (kauert) | hinter_linkem_buffet (kauert) | am_rechten_buffet (kauert) | wc | ost_tafel_west | hinter_linkem_buffet (kauert) | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet (kauert) | hinter_theke_ost (kauert) | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 23:59:45 | geburtstagsplatz (augenbinde) | vorrat_innen (liegt) | hinter_theke_ost (kauert) | hinter_linkem_buffet (kauert) | am_rechten_buffet (kauert) | wc | ost_tafel_west | hinter_linkem_buffet (kauert) | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet (kauert) | hinter_theke_ost (kauert) | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 00:00 | geburtstagsplatz (augenbinde) | vorrat_innen (liegt) | hinter_theke_ost (kauert) | hinter_linkem_buffet (kauert) | am_rechten_buffet (kauert) | wc | ost_tafel_west | hinter_linkem_buffet (kauert) | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet (kauert) | hinter_theke_ost (kauert) | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 00:00:15 | geburtstagsplatz (augenbinde) | vorrat_innen (liegt) | hinter_theke_ost | hinter_linkem_buffet | am_rechten_buffet | wc | ost_tafel_west | hinter_linkem_buffet | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | unterwegs bei vor_vorratstuer (x 14.5, y 6.5) (geht) | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 00:00:30 | geburtstagsplatz (augenbinde) | vorrat_innen (liegt) | hinter_theke_ost | hinter_linkem_buffet | unterwegs bei am_rechten_buffet (x 16.5, y 13.5) (geht) | wc | ost_tafel_west | hinter_linkem_buffet | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | vorrat_innen | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 00:00:45 | geburtstagsplatz (sitzt) | vorrat_innen (liegt) | hinter_theke_ost | hinter_linkem_buffet | unterwegs bei durchgang_mitte (x 8.7, y 9.5) (geht) | wc | ost_tafel_west | hinter_linkem_buffet | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | vorrat_innen | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 00:01 | geburtstagsplatz (sitzt) | vorrat_innen (liegt) | hinter_theke_ost | hinter_linkem_buffet | vor_bogentuer | unterwegs bei wendeltreppe_fuss (x 2.5, y 1.5) (geht) | ost_tafel_west | hinter_linkem_buffet | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | vorrat_innen | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 00:01:15 | geburtstagsplatz (sitzt) | vorrat_innen (liegt) | hinter_theke_ost | hinter_linkem_buffet | vor_bogentuer | unterwegs bei west_bank_west (x 1.5, y 10.5) (geht) | ost_tafel_west | hinter_linkem_buffet | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | vorrat_innen | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 00:01:30 | geburtstagsplatz (sitzt) | vorrat_innen (sitzt) | hinter_theke_ost | hinter_linkem_buffet | unterwegs bei vor_bogentuer (x 2.5, y 8.5) (geht) | west_bank_west | ost_tafel_west | hinter_linkem_buffet | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | vorrat_innen | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 00:01:45 | geburtstagsplatz (sitzt) | vorrat_innen (sitzt) | hinter_theke_ost | hinter_linkem_buffet | unterwegs bei theke_klappe (x 10.6, y 9.5) (geht) | west_bank_west | ost_tafel_west | hinter_linkem_buffet | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | vorrat_innen | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 00:02 | geburtstagsplatz (sitzt) | vorrat_innen (sitzt) | hinter_theke_ost | hinter_linkem_buffet | unterwegs bei am_eiskuebel (x 18.2, y 10.5) (geht) | west_bank_west | ost_tafel_west | hinter_linkem_buffet | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | vorrat_innen | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 00:02:15 | geburtstagsplatz (sitzt) | vorrat_innen (sitzt) | hinter_theke_ost | hinter_linkem_buffet | ost_tafel_kopf (sitzt) | west_bank_west | ost_tafel_west | hinter_linkem_buffet | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | vorrat_innen | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 00:02:30 | geburtstagsplatz (sitzt) | vorrat_innen (sitzt) | hinter_theke_ost | hinter_linkem_buffet | ost_tafel_kopf (sitzt) | west_bank_west | ost_tafel_west | hinter_linkem_buffet | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | unterwegs bei am_aussentor (x 15.5, y 21.5) (geht) | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | vorrat_innen | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 00:02:45 | geburtstagsplatz (sitzt) | vorrat_innen (sitzt) | hinter_theke_ost | hinter_linkem_buffet | ost_tafel_kopf (sitzt) | west_bank_west | ost_tafel_west | hinter_linkem_buffet | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | unter_notausgang | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | vorrat_innen | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 00:03 | geburtstagsplatz (sitzt) | vorrat_innen (sitzt) | hinter_theke_ost | hinter_linkem_buffet | ost_tafel_kopf (sitzt) | west_bank_west | ost_tafel_west | hinter_linkem_buffet | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | unter_notausgang | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | vorrat_innen | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 00:03:15 | geburtstagsplatz (sitzt) | vorrat_innen (sitzt) | hinter_theke_ost | hinter_linkem_buffet | ost_tafel_kopf (sitzt) | west_bank_west | ost_tafel_west | hinter_linkem_buffet | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | unter_notausgang | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | vorrat_innen | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 00:03:30 | geburtstagsplatz (sitzt) | vorrat_innen (sitzt) | hinter_theke_ost | hinter_linkem_buffet | ost_tafel_kopf (sitzt) | west_bank_west | ost_tafel_west | hinter_linkem_buffet | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | unter_notausgang | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | vorrat_innen | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 00:03:45 | geburtstagsplatz (sitzt) | vorrat_innen (sitzt) | hinter_theke_ost | hinter_linkem_buffet | ost_tafel_kopf (sitzt) | west_bank_west | ost_tafel_west | hinter_linkem_buffet | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | unter_notausgang | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | vorrat_innen | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 00:04 | geburtstagsplatz (sitzt) | vorrat_innen (sitzt) | hinter_theke_ost | hinter_linkem_buffet | ost_tafel_kopf (sitzt) | west_bank_west | ost_tafel_west | hinter_linkem_buffet | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | unter_notausgang | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | vorrat_innen | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 00:04:15 | geburtstagsplatz (sitzt) | vorrat_innen (sitzt) | hinter_theke_ost | hinter_linkem_buffet | ost_tafel_kopf (sitzt) | west_bank_west | ost_tafel_west | hinter_linkem_buffet | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | unter_notausgang | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | vorrat_innen | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 00:04:30 | geburtstagsplatz (sitzt) | vorrat_innen (sitzt) | hinter_theke_ost | hinter_linkem_buffet | ost_tafel_kopf (sitzt) | west_bank_west | ost_tafel_west | hinter_linkem_buffet | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | unter_notausgang | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | vorrat_innen | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 00:04:45 | geburtstagsplatz (sitzt) | vorrat_innen (sitzt) | hinter_theke_ost | hinter_linkem_buffet | ost_tafel_kopf (sitzt) | west_bank_west | ost_tafel_west | hinter_linkem_buffet | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | unter_notausgang | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | vorrat_innen | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 00:05 | geburtstagsplatz (sitzt) | vorrat_innen (sitzt) | hinter_theke_ost | hinter_linkem_buffet | ost_tafel_kopf (sitzt) | west_bank_west | ost_tafel_west | hinter_linkem_buffet | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | unter_notausgang | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | vorrat_innen | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |

### Pfad Olli

| Zeit | detective | schneider | ahmet | fatma | olli | can | leyla | emine | tim | johanna | murat | zeynep | baran | meryem | serkan | aylin | kaan | dilara | enes | selin | hakan | tugba |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 23:55 | unterwegs bei ost_tafel_ost (x 24.5, y 13.5) (geht) | unterwegs bei vor_bogentuer (x 3.2, y 8.5) (geht) | am_handykorb | am_linken_buffet | ost_tafel_kopf (sitzt) | vorrat_mitte | hinter_theke_mitte | hinter_linkem_buffet | hinter_theke_ost | am_handykorb | unter_notausgang | west_bogen | unterwegs bei ost_bank (x 25.5, y 15.5) (geht) | am_kamin | unter_notausgang | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | hinter_theke_mitte | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | an_der_wandtafel |
| 23:55:15 | geburtstagsplatz (augenbinde) | unterwegs bei west_bogen (x 7.0, y 9.5) (geht) | unterwegs bei an_der_wandtafel (x 24.5, y 11.0) (geht) | am_linken_buffet | ost_tafel_kopf (sitzt) | vorrat_mitte | hinter_theke_mitte | hinter_linkem_buffet | hinter_theke_ost | am_handykorb | unter_notausgang | west_bogen | geburtstagsplatz | am_kamin | unter_notausgang | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | hinter_theke_mitte | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | unterwegs bei ost_tafel_ost (x 24.5, y 13.5) (geht) |
| 23:55:30 | geburtstagsplatz (augenbinde) | unterwegs bei theke_klappe (x 11.2, y 9.5) (geht) | am_jackenstaender | am_linken_buffet | ost_tafel_kopf (sitzt) | vorrat_mitte | hinter_theke_mitte | hinter_linkem_buffet | hinter_theke_ost | am_handykorb | unter_notausgang | west_bogen | ost_bank (sitzt) | am_kamin | unterwegs bei unter_notausgang (x 14.5, y 18.5) (geht) | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | hinter_theke_mitte | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 23:55:45 | geburtstagsplatz (augenbinde) | unterwegs bei am_linken_buffet (x 13.5, y 12.1) (geht) | am_jackenstaender | am_linken_buffet | ost_tafel_kopf (sitzt) | vorrat_mitte | hinter_theke_mitte | hinter_linkem_buffet | hinter_theke_ost | am_handykorb | unter_notausgang | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | hinter_theke_mitte | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 23:56 | geburtstagsplatz (augenbinde) | am_linken_buffet | am_jackenstaender | am_linken_buffet | ost_tafel_kopf (sitzt) | vorrat_mitte | hinter_theke_mitte | hinter_linkem_buffet | hinter_theke_ost | am_handykorb | unter_notausgang | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | hinter_theke_mitte | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 23:56:15 | geburtstagsplatz (augenbinde) | am_linken_buffet | am_jackenstaender | am_linken_buffet | ost_tafel_kopf (sitzt) | vorrat_mitte | hinter_theke_mitte | hinter_linkem_buffet | hinter_theke_ost | am_handykorb | unter_notausgang | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | hinter_theke_mitte | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 23:56:30 | geburtstagsplatz (augenbinde) | unterwegs bei am_linken_buffet (x 13.5, y 13.5) (geht) | am_jackenstaender | am_linken_buffet | unterwegs bei ost_tafel_kopf (x 22.5, y 10.5) (geht) | vorrat_mitte | hinter_theke_mitte | hinter_linkem_buffet | hinter_theke_ost | am_handykorb | unter_notausgang | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | hinter_theke_mitte | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 23:56:45 | geburtstagsplatz (augenbinde) | unterwegs bei am_eiskuebel (x 17.7, y 10.5) (geht) | am_jackenstaender | am_linken_buffet | unterwegs bei theke_ostende (x 18.5, y 9.9) (geht) | vorrat_mitte | hinter_theke_mitte | hinter_linkem_buffet | hinter_theke_ost | am_handykorb | unter_notausgang | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | hinter_theke_mitte | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 23:57 | geburtstagsplatz (augenbinde) | theke_ostende | hinter_theke_ost | unterwegs bei am_linken_buffet (x 13.5, y 13.5) (geht) | am_eiskuebel | unterwegs bei vorrat_mitte (x 14.5, y 3.5) (geht) | hinter_theke_mitte | hinter_linkem_buffet | hinter_theke_ost | am_handykorb | unterwegs bei unter_notausgang (x 14.5, y 18.5) (geht) | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | hinter_theke_mitte | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 23:57:15 | geburtstagsplatz (augenbinde) | theke_ostende | hinter_theke_ost | theke_klappe | am_eiskuebel | vorrat_innen | hinter_theke_mitte | hinter_linkem_buffet | hinter_theke_ost | am_handykorb | unterwegs bei theke_klappe (x 11.5, y 10.0) (geht) | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | hinter_theke_mitte | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 23:57:30 | geburtstagsplatz (augenbinde) | hinter_theke_ost | hinter_theke_ost | theke_klappe | am_eiskuebel | vorrat_innen | hinter_theke_mitte | hinter_linkem_buffet | hinter_theke_ost | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | unterwegs bei hinter_theke_mitte (x 15.5, y 8.5) (geht) | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 23:57:45 | geburtstagsplatz (augenbinde) | hinter_theke_ost | hinter_theke_ost | theke_klappe | am_eiskuebel | vorrat_innen | unterwegs bei ost_eingang (x 19.7, y 9.5) (geht) | hinter_linkem_buffet | hinter_theke_ost | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | hinter_theke_ost | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 23:58 | geburtstagsplatz (augenbinde) | hinter_theke_ost | hinter_theke_ost (kauert) | theke_klappe | am_eiskuebel | vorrat_innen | ost_tafel_west | hinter_linkem_buffet (kauert) | unterwegs bei hinter_theke_ost (x 17.5, y 8.5) (geht) | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet (kauert) | hinter_theke_ost (kauert) | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 23:58:15 | geburtstagsplatz (augenbinde) | vor_vorratstuer | hinter_theke_ost (kauert) | hinter_linkem_buffet (kauert) | am_eiskuebel | vor_vorratstuer | ost_tafel_west | hinter_linkem_buffet (kauert) | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet (kauert) | hinter_theke_ost (kauert) | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 23:58:30 | geburtstagsplatz (augenbinde) | vor_vorratstuer | hinter_theke_ost (kauert) | hinter_linkem_buffet (kauert) | vor_theke_west | unterwegs bei theke_klappe (x 11.5, y 9.3) (rennt) | ost_tafel_west | hinter_linkem_buffet (kauert) | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet (kauert) | hinter_theke_ost (kauert) | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 23:58:45 | geburtstagsplatz (augenbinde) | vorrat_innen (liegt) | hinter_theke_ost (kauert) | hinter_linkem_buffet (kauert) | vorrat_innen | unterwegs bei wendeltreppe_fuss (x 2.5, y 1.5) (geht) | ost_tafel_west | hinter_linkem_buffet (kauert) | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet (kauert) | hinter_theke_ost (kauert) | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 23:59 | geburtstagsplatz (augenbinde) | vorrat_innen (liegt) | hinter_theke_ost (kauert) | hinter_linkem_buffet (kauert) | am_eiskuebel | wc | ost_tafel_west | hinter_linkem_buffet (kauert) | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet (kauert) | hinter_theke_ost (kauert) | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 23:59:15 | geburtstagsplatz (augenbinde) | vorrat_innen (liegt) | hinter_theke_ost (kauert) | hinter_linkem_buffet (kauert) | am_rechten_buffet (kauert) | wc | ost_tafel_west | hinter_linkem_buffet (kauert) | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet (kauert) | hinter_theke_ost (kauert) | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 23:59:30 | geburtstagsplatz (augenbinde) | vorrat_innen (liegt) | hinter_theke_ost (kauert) | hinter_linkem_buffet (kauert) | am_rechten_buffet (kauert) | wc | ost_tafel_west | hinter_linkem_buffet (kauert) | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet (kauert) | hinter_theke_ost (kauert) | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 23:59:45 | geburtstagsplatz (augenbinde) | vorrat_innen (liegt) | hinter_theke_ost (kauert) | hinter_linkem_buffet (kauert) | am_rechten_buffet (kauert) | wc | ost_tafel_west | hinter_linkem_buffet (kauert) | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet (kauert) | hinter_theke_ost (kauert) | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 00:00 | geburtstagsplatz (augenbinde) | vorrat_innen (liegt) | hinter_theke_ost (kauert) | hinter_linkem_buffet (kauert) | am_rechten_buffet (kauert) | wc | ost_tafel_west | hinter_linkem_buffet (kauert) | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet (kauert) | hinter_theke_ost (kauert) | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 00:00:15 | geburtstagsplatz (augenbinde) | vorrat_innen (liegt) | hinter_theke_ost | hinter_linkem_buffet | am_rechten_buffet | wc | ost_tafel_west | hinter_linkem_buffet | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | unterwegs bei vor_vorratstuer (x 14.5, y 6.5) (geht) | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 00:00:30 | geburtstagsplatz (augenbinde) | vorrat_innen (liegt) | hinter_theke_ost | hinter_linkem_buffet | unterwegs bei am_rechten_buffet (x 16.5, y 13.5) (geht) | wc | ost_tafel_west | hinter_linkem_buffet | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | vorrat_innen | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 00:00:45 | geburtstagsplatz (sitzt) | vorrat_innen (liegt) | hinter_theke_ost | hinter_linkem_buffet | unterwegs bei durchgang_mitte (x 8.7, y 9.5) (geht) | wc | ost_tafel_west | hinter_linkem_buffet | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | vorrat_innen | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 00:01 | geburtstagsplatz (sitzt) | vorrat_innen (liegt) | hinter_theke_ost | hinter_linkem_buffet | vor_bogentuer | unterwegs bei wendeltreppe_fuss (x 2.5, y 1.5) (geht) | ost_tafel_west | hinter_linkem_buffet | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | vorrat_innen | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 00:01:15 | geburtstagsplatz (sitzt) | vorrat_innen (liegt) | hinter_theke_ost | hinter_linkem_buffet | vor_bogentuer | unterwegs bei west_bank_west (x 1.5, y 10.5) (geht) | ost_tafel_west | hinter_linkem_buffet | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | vorrat_innen | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 00:01:30 | geburtstagsplatz (sitzt) | vorrat_innen (sitzt) | hinter_theke_ost | hinter_linkem_buffet | unterwegs bei vor_bogentuer (x 2.5, y 8.5) (geht) | west_bank_west | ost_tafel_west | hinter_linkem_buffet | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | vorrat_innen | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 00:01:45 | geburtstagsplatz (sitzt) | vorrat_innen (sitzt) | hinter_theke_ost | hinter_linkem_buffet | unterwegs bei theke_klappe (x 10.6, y 9.5) (geht) | west_bank_west | ost_tafel_west | hinter_linkem_buffet | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | vorrat_innen | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 00:02 | geburtstagsplatz (sitzt) | vorrat_innen (sitzt) | hinter_theke_ost | hinter_linkem_buffet | unterwegs bei am_eiskuebel (x 18.2, y 10.5) (geht) | west_bank_west | ost_tafel_west | hinter_linkem_buffet | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | vorrat_innen | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 00:02:15 | geburtstagsplatz (sitzt) | vorrat_innen (sitzt) | hinter_theke_ost | hinter_linkem_buffet | ost_tafel_kopf (sitzt) | west_bank_west | ost_tafel_west | hinter_linkem_buffet | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | vorrat_innen | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 00:02:30 | geburtstagsplatz (sitzt) | vorrat_innen (sitzt) | hinter_theke_ost | hinter_linkem_buffet | ost_tafel_kopf (sitzt) | west_bank_west | ost_tafel_west | hinter_linkem_buffet | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | unterwegs bei am_aussentor (x 15.5, y 21.5) (geht) | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | vorrat_innen | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 00:02:45 | geburtstagsplatz (sitzt) | vorrat_innen (sitzt) | hinter_theke_ost | hinter_linkem_buffet | ost_tafel_kopf (sitzt) | west_bank_west | ost_tafel_west | hinter_linkem_buffet | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | unter_notausgang | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | vorrat_innen | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 00:03 | geburtstagsplatz (sitzt) | vorrat_innen (sitzt) | hinter_theke_ost | hinter_linkem_buffet | ost_tafel_kopf (sitzt) | west_bank_west | ost_tafel_west | hinter_linkem_buffet | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | unter_notausgang | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | vorrat_innen | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 00:03:15 | geburtstagsplatz (sitzt) | vorrat_innen (sitzt) | hinter_theke_ost | hinter_linkem_buffet | ost_tafel_kopf (sitzt) | west_bank_west | ost_tafel_west | hinter_linkem_buffet | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | unter_notausgang | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | vorrat_innen | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 00:03:30 | geburtstagsplatz (sitzt) | vorrat_innen (sitzt) | hinter_theke_ost | hinter_linkem_buffet | ost_tafel_kopf (sitzt) | west_bank_west | ost_tafel_west | hinter_linkem_buffet | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | unter_notausgang | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | vorrat_innen | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 00:03:45 | geburtstagsplatz (sitzt) | vorrat_innen (sitzt) | hinter_theke_ost | hinter_linkem_buffet | ost_tafel_kopf (sitzt) | west_bank_west | ost_tafel_west | hinter_linkem_buffet | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | unter_notausgang | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | vorrat_innen | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 00:04 | geburtstagsplatz (sitzt) | vorrat_innen (sitzt) | hinter_theke_ost | hinter_linkem_buffet | ost_tafel_kopf (sitzt) | west_bank_west | ost_tafel_west | hinter_linkem_buffet | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | unter_notausgang | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | vorrat_innen | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 00:04:15 | geburtstagsplatz (sitzt) | vorrat_innen (sitzt) | hinter_theke_ost | hinter_linkem_buffet | ost_tafel_kopf (sitzt) | west_bank_west | ost_tafel_west | hinter_linkem_buffet | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | unter_notausgang | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | vorrat_innen | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 00:04:30 | geburtstagsplatz (sitzt) | vorrat_innen (sitzt) | hinter_theke_ost | hinter_linkem_buffet | ost_tafel_kopf (sitzt) | west_bank_west | ost_tafel_west | hinter_linkem_buffet | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | unter_notausgang | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | vorrat_innen | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 00:04:45 | geburtstagsplatz (sitzt) | vorrat_innen (sitzt) | hinter_theke_ost | hinter_linkem_buffet | ost_tafel_kopf (sitzt) | west_bank_west | ost_tafel_west | hinter_linkem_buffet | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | unter_notausgang | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | vorrat_innen | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 00:05 | geburtstagsplatz (sitzt) | vorrat_innen (sitzt) | hinter_theke_ost | hinter_linkem_buffet | ost_tafel_kopf (sitzt) | west_bank_west | ost_tafel_west | hinter_linkem_buffet | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | unter_notausgang | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | vorrat_innen | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |

### Pfad Can

| Zeit | detective | schneider | ahmet | fatma | olli | can | leyla | emine | tim | johanna | murat | zeynep | baran | meryem | serkan | aylin | kaan | dilara | enes | selin | hakan | tugba |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 23:55 | unterwegs bei ost_tafel_ost (x 24.5, y 13.5) (geht) | unterwegs bei vor_bogentuer (x 3.2, y 8.5) (geht) | am_handykorb | am_linken_buffet | ost_tafel_kopf (sitzt) | vorrat_mitte | hinter_theke_mitte | hinter_linkem_buffet | hinter_theke_ost | am_handykorb | unter_notausgang | west_bogen | unterwegs bei ost_bank (x 25.5, y 15.5) (geht) | am_kamin | unter_notausgang | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | hinter_theke_mitte | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | an_der_wandtafel |
| 23:55:15 | geburtstagsplatz (augenbinde) | unterwegs bei west_bogen (x 7.0, y 9.5) (geht) | unterwegs bei an_der_wandtafel (x 24.5, y 11.0) (geht) | am_linken_buffet | ost_tafel_kopf (sitzt) | vorrat_mitte | hinter_theke_mitte | hinter_linkem_buffet | hinter_theke_ost | am_handykorb | unter_notausgang | west_bogen | geburtstagsplatz | am_kamin | unter_notausgang | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | hinter_theke_mitte | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | unterwegs bei ost_tafel_ost (x 24.5, y 13.5) (geht) |
| 23:55:30 | geburtstagsplatz (augenbinde) | unterwegs bei theke_klappe (x 11.2, y 9.5) (geht) | am_jackenstaender | am_linken_buffet | ost_tafel_kopf (sitzt) | vorrat_mitte | hinter_theke_mitte | hinter_linkem_buffet | hinter_theke_ost | am_handykorb | unter_notausgang | west_bogen | ost_bank (sitzt) | am_kamin | unterwegs bei unter_notausgang (x 14.5, y 18.5) (geht) | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | hinter_theke_mitte | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 23:55:45 | geburtstagsplatz (augenbinde) | unterwegs bei am_linken_buffet (x 13.5, y 12.1) (geht) | am_jackenstaender | am_linken_buffet | ost_tafel_kopf (sitzt) | vorrat_mitte | hinter_theke_mitte | hinter_linkem_buffet | hinter_theke_ost | am_handykorb | unter_notausgang | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | hinter_theke_mitte | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 23:56 | geburtstagsplatz (augenbinde) | am_linken_buffet | am_jackenstaender | am_linken_buffet | ost_tafel_kopf (sitzt) | vorrat_mitte | hinter_theke_mitte | hinter_linkem_buffet | hinter_theke_ost | am_handykorb | unter_notausgang | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | hinter_theke_mitte | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 23:56:15 | geburtstagsplatz (augenbinde) | am_linken_buffet | am_jackenstaender | am_linken_buffet | ost_tafel_kopf (sitzt) | vorrat_mitte | hinter_theke_mitte | hinter_linkem_buffet | hinter_theke_ost | am_handykorb | unter_notausgang | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | hinter_theke_mitte | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 23:56:30 | geburtstagsplatz (augenbinde) | unterwegs bei am_linken_buffet (x 13.5, y 13.5) (geht) | am_jackenstaender | am_linken_buffet | unterwegs bei ost_tafel_kopf (x 22.5, y 10.5) (geht) | vorrat_mitte | hinter_theke_mitte | hinter_linkem_buffet | hinter_theke_ost | am_handykorb | unter_notausgang | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | hinter_theke_mitte | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 23:56:45 | geburtstagsplatz (augenbinde) | unterwegs bei am_eiskuebel (x 17.7, y 10.5) (geht) | am_jackenstaender | am_linken_buffet | unterwegs bei theke_ostende (x 18.5, y 9.9) (geht) | vorrat_mitte | hinter_theke_mitte | hinter_linkem_buffet | hinter_theke_ost | am_handykorb | unter_notausgang | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | hinter_theke_mitte | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 23:57 | geburtstagsplatz (augenbinde) | theke_ostende | hinter_theke_ost | unterwegs bei am_linken_buffet (x 13.5, y 13.5) (geht) | am_eiskuebel | unterwegs bei vorrat_mitte (x 14.5, y 3.5) (geht) | hinter_theke_mitte | hinter_linkem_buffet | hinter_theke_ost | am_handykorb | unterwegs bei unter_notausgang (x 14.5, y 18.5) (geht) | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | hinter_theke_mitte | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 23:57:15 | geburtstagsplatz (augenbinde) | theke_ostende | hinter_theke_ost | theke_klappe | am_eiskuebel | vorrat_innen | hinter_theke_mitte | hinter_linkem_buffet | hinter_theke_ost | am_handykorb | unterwegs bei theke_klappe (x 11.5, y 10.0) (geht) | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | hinter_theke_mitte | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 23:57:30 | geburtstagsplatz (augenbinde) | hinter_theke_ost | hinter_theke_ost | theke_klappe | am_eiskuebel | vorrat_innen | hinter_theke_mitte | hinter_linkem_buffet | hinter_theke_ost | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | unterwegs bei hinter_theke_mitte (x 15.5, y 8.5) (geht) | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 23:57:45 | geburtstagsplatz (augenbinde) | hinter_theke_ost | hinter_theke_ost | theke_klappe | am_eiskuebel | vorrat_innen | unterwegs bei ost_eingang (x 19.7, y 9.5) (geht) | hinter_linkem_buffet | hinter_theke_ost | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | hinter_theke_ost | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 23:58 | geburtstagsplatz (augenbinde) | hinter_theke_ost | hinter_theke_ost (kauert) | theke_klappe | am_eiskuebel | vorrat_innen | ost_tafel_west | hinter_linkem_buffet (kauert) | unterwegs bei hinter_theke_ost (x 17.5, y 8.5) (geht) | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet (kauert) | hinter_theke_ost (kauert) | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 23:58:15 | geburtstagsplatz (augenbinde) | vor_vorratstuer | hinter_theke_ost (kauert) | hinter_linkem_buffet (kauert) | am_rechten_buffet (kauert) | vor_vorratstuer | ost_tafel_west | hinter_linkem_buffet (kauert) | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet (kauert) | hinter_theke_ost (kauert) | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 23:58:30 | geburtstagsplatz (augenbinde) | vor_vorratstuer | am_jackenstaender | hinter_linkem_buffet (kauert) | am_rechten_buffet (kauert) | vor_vorratstuer | ost_tafel_west | hinter_linkem_buffet (kauert) | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet (kauert) | hinter_theke_ost (kauert) | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 23:58:45 | geburtstagsplatz (augenbinde) | vorrat_innen (liegt) | am_jackenstaender | hinter_linkem_buffet (kauert) | am_rechten_buffet (kauert) | vorrat_innen | ost_tafel_west | hinter_linkem_buffet (kauert) | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet (kauert) | hinter_theke_ost (kauert) | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 23:59 | geburtstagsplatz (augenbinde) | vorrat_innen (liegt) | am_jackenstaender | hinter_linkem_buffet (kauert) | am_rechten_buffet (kauert) | an_der_ruestung | ost_tafel_west | hinter_linkem_buffet (kauert) | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet (kauert) | hinter_theke_ost (kauert) | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 23:59:15 | geburtstagsplatz (augenbinde) | vorrat_innen (liegt) | hinter_theke_ost (kauert) | hinter_linkem_buffet (kauert) | am_rechten_buffet (kauert) | unterwegs bei wendeltreppe_fuss (x 2.5, y 1.5) (geht) | ost_tafel_west | hinter_linkem_buffet (kauert) | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet (kauert) | hinter_theke_ost (kauert) | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 23:59:30 | geburtstagsplatz (augenbinde) | vorrat_innen (liegt) | hinter_theke_ost (kauert) | hinter_linkem_buffet (kauert) | am_rechten_buffet (kauert) | wc | ost_tafel_west | hinter_linkem_buffet (kauert) | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet (kauert) | hinter_theke_ost (kauert) | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 23:59:45 | geburtstagsplatz (augenbinde) | vorrat_innen (liegt) | hinter_theke_ost (kauert) | hinter_linkem_buffet (kauert) | am_rechten_buffet (kauert) | wc | ost_tafel_west | hinter_linkem_buffet (kauert) | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet (kauert) | hinter_theke_ost (kauert) | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 00:00 | geburtstagsplatz (augenbinde) | vorrat_innen (liegt) | hinter_theke_ost (kauert) | hinter_linkem_buffet (kauert) | am_rechten_buffet (kauert) | wc | ost_tafel_west | hinter_linkem_buffet (kauert) | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet (kauert) | hinter_theke_ost (kauert) | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 00:00:15 | geburtstagsplatz (augenbinde) | vorrat_innen (liegt) | hinter_theke_ost | hinter_linkem_buffet | am_rechten_buffet | wc | ost_tafel_west | hinter_linkem_buffet | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | unterwegs bei vor_vorratstuer (x 14.5, y 6.5) (geht) | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 00:00:30 | geburtstagsplatz (augenbinde) | vorrat_innen (liegt) | hinter_theke_ost | hinter_linkem_buffet | unterwegs bei am_rechten_buffet (x 16.5, y 13.5) (geht) | wc | ost_tafel_west | hinter_linkem_buffet | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | vorrat_innen | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 00:00:45 | geburtstagsplatz (sitzt) | vorrat_innen (liegt) | hinter_theke_ost | hinter_linkem_buffet | unterwegs bei durchgang_mitte (x 8.7, y 9.5) (geht) | wc | ost_tafel_west | hinter_linkem_buffet | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | vorrat_innen | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 00:01 | geburtstagsplatz (sitzt) | vorrat_innen (liegt) | hinter_theke_ost | hinter_linkem_buffet | vor_bogentuer | unterwegs bei wendeltreppe_fuss (x 2.5, y 1.5) (geht) | ost_tafel_west | hinter_linkem_buffet | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | vorrat_innen | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 00:01:15 | geburtstagsplatz (sitzt) | vorrat_innen (liegt) | hinter_theke_ost | hinter_linkem_buffet | vor_bogentuer | unterwegs bei west_bank_west (x 1.5, y 10.5) (geht) | ost_tafel_west | hinter_linkem_buffet | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | vorrat_innen | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 00:01:30 | geburtstagsplatz (sitzt) | vorrat_innen (sitzt) | hinter_theke_ost | hinter_linkem_buffet | unterwegs bei vor_bogentuer (x 2.5, y 8.5) (geht) | west_bank_west | ost_tafel_west | hinter_linkem_buffet | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | vorrat_innen | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 00:01:45 | geburtstagsplatz (sitzt) | vorrat_innen (sitzt) | hinter_theke_ost | hinter_linkem_buffet | unterwegs bei theke_klappe (x 10.6, y 9.5) (geht) | west_bank_west | ost_tafel_west | hinter_linkem_buffet | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | vorrat_innen | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 00:02 | geburtstagsplatz (sitzt) | vorrat_innen (sitzt) | hinter_theke_ost | hinter_linkem_buffet | unterwegs bei am_eiskuebel (x 18.2, y 10.5) (geht) | west_bank_west | ost_tafel_west | hinter_linkem_buffet | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | vorrat_innen | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 00:02:15 | geburtstagsplatz (sitzt) | vorrat_innen (sitzt) | hinter_theke_ost | hinter_linkem_buffet | ost_tafel_kopf (sitzt) | west_bank_west | ost_tafel_west | hinter_linkem_buffet | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | am_aussentor | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | vorrat_innen | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 00:02:30 | geburtstagsplatz (sitzt) | vorrat_innen (sitzt) | hinter_theke_ost | hinter_linkem_buffet | ost_tafel_kopf (sitzt) | west_bank_west | ost_tafel_west | hinter_linkem_buffet | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | unterwegs bei am_aussentor (x 15.5, y 21.5) (geht) | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | vorrat_innen | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 00:02:45 | geburtstagsplatz (sitzt) | vorrat_innen (sitzt) | hinter_theke_ost | hinter_linkem_buffet | ost_tafel_kopf (sitzt) | west_bank_west | ost_tafel_west | hinter_linkem_buffet | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | unter_notausgang | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | vorrat_innen | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 00:03 | geburtstagsplatz (sitzt) | vorrat_innen (sitzt) | hinter_theke_ost | hinter_linkem_buffet | ost_tafel_kopf (sitzt) | west_bank_west | ost_tafel_west | hinter_linkem_buffet | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | unter_notausgang | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | vorrat_innen | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 00:03:15 | geburtstagsplatz (sitzt) | vorrat_innen (sitzt) | hinter_theke_ost | hinter_linkem_buffet | ost_tafel_kopf (sitzt) | west_bank_west | ost_tafel_west | hinter_linkem_buffet | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | unter_notausgang | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | vorrat_innen | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 00:03:30 | geburtstagsplatz (sitzt) | vorrat_innen (sitzt) | hinter_theke_ost | hinter_linkem_buffet | ost_tafel_kopf (sitzt) | west_bank_west | ost_tafel_west | hinter_linkem_buffet | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | unter_notausgang | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | vorrat_innen | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 00:03:45 | geburtstagsplatz (sitzt) | vorrat_innen (sitzt) | hinter_theke_ost | hinter_linkem_buffet | ost_tafel_kopf (sitzt) | west_bank_west | ost_tafel_west | hinter_linkem_buffet | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | unter_notausgang | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | vorrat_innen | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 00:04 | geburtstagsplatz (sitzt) | vorrat_innen (sitzt) | hinter_theke_ost | hinter_linkem_buffet | ost_tafel_kopf (sitzt) | west_bank_west | ost_tafel_west | hinter_linkem_buffet | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | unter_notausgang | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | vorrat_innen | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 00:04:15 | geburtstagsplatz (sitzt) | vorrat_innen (sitzt) | hinter_theke_ost | hinter_linkem_buffet | ost_tafel_kopf (sitzt) | west_bank_west | ost_tafel_west | hinter_linkem_buffet | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | unter_notausgang | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | vorrat_innen | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 00:04:30 | geburtstagsplatz (sitzt) | vorrat_innen (sitzt) | hinter_theke_ost | hinter_linkem_buffet | ost_tafel_kopf (sitzt) | west_bank_west | ost_tafel_west | hinter_linkem_buffet | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | unter_notausgang | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | vorrat_innen | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 00:04:45 | geburtstagsplatz (sitzt) | vorrat_innen (sitzt) | hinter_theke_ost | hinter_linkem_buffet | ost_tafel_kopf (sitzt) | west_bank_west | ost_tafel_west | hinter_linkem_buffet | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | unter_notausgang | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | vorrat_innen | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |
| 00:05 | geburtstagsplatz (sitzt) | vorrat_innen (sitzt) | hinter_theke_ost | hinter_linkem_buffet | ost_tafel_kopf (sitzt) | west_bank_west | ost_tafel_west | hinter_linkem_buffet | am_sicherungskasten | am_handykorb | bei_den_kisten | west_bogen | ost_bank (sitzt) | am_kamin | unter_notausgang | ost_tafel_west (sitzt) | vor_bogentuer | am_rechten_buffet | vorrat_innen | west_bank_sued (sitzt) | ost_tafel_ost (sitzt) | geburtstagsplatz |

## 9. Entscheidungen des Detektivs

- **R-ENTLASTET:** Wer beim Scheppern nachweislich woanders war und zusätzlich eine bewiesene Heimlichtuerei hat, scheidet aus. Beides muss zusammenkommen. Das Scheppern ist das laute Poltern an der Theke, gut eine halbe Minute nach dem Knall.
- **R-UEBERFUEHRT:** Ein Schlüsselbeweis überführt eine Person, wenn man auch Herrn Schneiders Schlüsselbund an ihrem Versteck findet. Alle anderen scheiden aus.

| Fakt | Art | Personen | Quelle |
|---|---|---|---|
| f_alibi_ahmet | alibi | Ahmet (ahmet) | beobachtung: b_damir_ahmet_blieb |
| f_spaet_ahmet | spaetankunft | Ahmet (ahmet) | beobachtung: b_damir_ahmet_weg |
| f_alibi_fatma | alibi | Fatma (fatma) | beobachtung: b_emine_fatma_frueh |
| f_spaet_fatma | spaetankunft | Fatma (fatma) | beobachtung: b_emine_fatma_spaet |
| f_alibi_olli | alibi | Olli (olli) | beobachtung: b_azra_olli_frueh |
| f_spaet_olli | spaetankunft | Olli (olli) | beobachtung: b_azra_olli_spaet |
| f_foto_streit | motiv | Ahmet (ahmet) | spur: spur_foto_streit |
| f_notiz_fehlende | luege | Fatma (fatma), Olli (olli) | spur: spur_notiz_fehlende |
| f_kurzschluss | ausgangslage | – | beobachtung: b_tim_kurzschluss |
| f_nd_ahmet_umschlag | nebendelikt | Ahmet (ahmet) | spur: spur_umschlag_aufschrift |
| f_z_ahmet | zusatzindiz | Ahmet (ahmet) | spur: spur_umschlag_wachs |
| f_nd_can_maske | nebendelikt | Can (can) | spur: spur_maske_da |
| f_z_can | zusatzindiz | Can (can) | spur: spur_maske_wachs |
| f_nd_fatma | nebendelikt | Fatma (fatma) | spur: spur_schatulle_da |
| f_z_fatma | zusatzindiz | Fatma (fatma) | spur: spur_schatulle_wachs |
| f_vitrine_leer | umgebung | – | spur: spur_vitrine_leer |
| f_nd_olli | nebendelikt | Olli (olli) | spur: spur_weste_moebelwachs |
| f_z_olli | zusatzindiz | Olli (olli) | spur: spur_weste_kerzenwachs |
| f_handschuh_kamin | umgebung | – | spur: spur_handschuh_russ |
| f_fundort_ahmet | fundort | Ahmet (ahmet) | spur: spur_jacke_bund |
| f_fundort_fatma | fundort | Fatma (fatma) | spur: spur_brottasche_bund |
| f_fundort_olli | fundort | Olli (olli) | spur: spur_eiskuebel_bund |
| f_fundort_can | fundort | Can (can) | spur: spur_helm_bund |
| f_staender_verbogen | umgebung | – | spur: spur_staender_verbogen |
| f_k_ahmet | schluesselbeweis | Ahmet (ahmet) | spur: spur_griff_papier |
| f_k_can | schluesselbeweis | Can (can) | spur: spur_griff_leuchtfarbe |
| f_k_olli | schluesselbeweis | Olli (olli) | spur: spur_fuss_splitter |
| f_k_fatma | schluesselbeweis | Fatma (fatma) | spur: spur_ring_messing |
| f_nd_can_zeynep | nebendelikt | Can (can) | beobachtung: b_zeynep_vorrat |
| f_nd_ahmet_quittung | nebendelikt | Ahmet (ahmet) | spur: spur_quittung |

### Runde 1.1: Wer weiß, wer im Dunkeln am Ostende der Theke war? (`e1_1`)

| Option | Text | Fakten | richtig in |
|---|---|---|---|
| e1_1_joanna | Joanna befragen | f_foto_streit |  |
| e1_1_damir | Damir befragen | f_alibi_ahmet, f_spaet_ahmet | Ahmet, Fatma, Olli, Can |

- **Begründung alle Pfade:** Damir stand um 23:57 an der Theke, wo es gescheppert hat. Wer dort im Dunkeln kauerte, weiß, wer beim Scheppern wo war. (beobachtung:b_damir_an_der_theke, beobachtung:b_detektiv_gehoert)

### Runde 1.2: Wer war im Dunkeln am linken Buffettisch? (`e1_2`)

| Option | Text | Fakten | richtig in |
|---|---|---|---|
| e1_2_emine | Emine befragen | f_alibi_fatma, f_spaet_fatma | Ahmet, Fatma, Olli, Can |
| e1_2_tugba | Tugba nach ihrem Notizbuch fragen | f_notiz_fehlende |  |

- **Begründung alle Pfade:** Emine duckte sich beim Knall hinter den linken Buffettisch, wenige Schritte von der Theke. Sie weiß, wer neben ihr kauerte. (beobachtung:b_emine_versteck, beobachtung:b_detektiv_gehoert)

### Runde 1.3: Wer war im Dunkeln am rechten Buffettisch? (`e1_3`)

| Option | Text | Fakten | richtig in |
|---|---|---|---|
| e1_3_tim | Tim zum Stromausfall befragen | f_kurzschluss |  |
| e1_3_azra | Azra befragen | f_alibi_olli, f_spaet_olli | Ahmet, Fatma, Olli, Can |

- **Begründung alle Pfade:** Azra duckte sich beim Knall am rechten Buffettisch, nahe der Theke. Sie weiß, wer neben ihr kauerte. (beobachtung:b_azra_versteck, beobachtung:b_detektiv_gehoert)

### Runde 2.1: Wessen Heimlichtuerei klärst du jetzt? (`e2_1`)

| Option | Text | Fakten | richtig in |
|---|---|---|---|
| e2_1_ascheneimer | Den Ascheneimer am Kamin durchsuchen | f_nd_ahmet_umschlag, f_z_ahmet | Ahmet, Fatma, Olli |
| e2_1_bauchtasche | Cans Bauchtasche untersuchen | f_nd_can_maske, f_z_can | Can |

- **Begründung Ahmet:** Ahmet war beim Scheppern nicht bei Damir. Hana sah ihn kurz nach zwölf etwas in den Ascheneimer werfen. (fakt:f_spaet_ahmet, beobachtung:b_hana_umschlag)
- **Begründung Fatma:** Ahmet war beim Scheppern bei Damir, hat aber wegen seines Umschlags gelogen. Was er in den Ascheneimer warf, erklärt das. (fakt:f_alibi_ahmet, beobachtung:b_lejla_ahmet_theke, beobachtung:b_hana_umschlag, luege:luege_ahmet_servietten)
- **Begründung Olli:** Ahmet war beim Scheppern bei Damir, hat aber wegen seines Umschlags gelogen. Was er in den Ascheneimer warf, erklärt das. (fakt:f_alibi_ahmet, beobachtung:b_lejla_ahmet_theke, beobachtung:b_hana_umschlag, luege:luege_ahmet_servietten)
- **Begründung Can:** Fatma und Olli haben ein Alibi für das Scheppern, Ahmet und Can nicht. Marek sah ein leuchtendes Gesicht, und Cans Hand steckt tief in der Bauchtasche seines Pullis. (fakt:f_alibi_fatma, fakt:f_alibi_olli, beobachtung:b_marek_gesicht, merkmal:can)

### Runde 2.2: Was untersuchst du als Nächstes? (`e2_2`)

| Option | Text | Fakten | richtig in |
|---|---|---|---|
| e2_2_vitrine | Die Vitrine im Turmgang untersuchen | f_vitrine_leer |  |
| e2_2_tasche | Fatmas Tasche untersuchen | f_nd_fatma, f_z_fatma | Ahmet, Fatma, Olli, Can |

- **Begründung Ahmet:** Fatma war beim Scheppern bei Emine. Ihre Tasche ist auffällig ausgebeult, und sie sagt, darin seien nur Bücher. (fakt:f_alibi_fatma, beobachtung:b_azra_tasche, luege:luege_fatma_tasche)
- **Begründung Fatma:** Fatma kam erst nach dem Scheppern zu Emine, und ihre Tasche ist auffällig ausgebeult. (fakt:f_spaet_fatma, beobachtung:b_azra_tasche)
- **Begründung Olli:** Fatma war beim Scheppern bei Emine. Ihre Tasche ist auffällig ausgebeult, und sie sagt, darin seien nur Bücher. (fakt:f_alibi_fatma, beobachtung:b_azra_tasche, luege:luege_fatma_tasche)
- **Begründung Can:** Fatma war beim Scheppern bei Emine. Ihre Tasche ist auffällig ausgebeult, und sie sagt, darin seien nur Bücher. (fakt:f_alibi_fatma, beobachtung:b_azra_tasche, luege:luege_fatma_tasche)

### Runde 2.3: Wo suchst du weiter? (`e2_3`)

| Option | Text | Fakten | richtig in |
|---|---|---|---|
| e2_3_olli | Olli und seine Weste untersuchen | f_nd_olli, f_z_olli | Ahmet, Fatma, Olli, Can |
| e2_3_kamin | Die Kamin-Nische untersuchen | f_handschuh_kamin |  |

- **Begründung Ahmet:** Olli war beim Scheppern bei Azra. Splitter und Kalk an seinen Ärmeln passen zur beschädigten Bogentür; das muss er erklären. (fakt:f_alibi_olli, merkmal:olli, karte:bogentuer_schaden)
- **Begründung Fatma:** Olli war beim Scheppern bei Azra. Splitter und Kalk an seinen Ärmeln passen zur beschädigten Bogentür; das muss er erklären. (fakt:f_alibi_olli, merkmal:olli, karte:bogentuer_schaden)
- **Begründung Olli:** Olli kam erst nach dem Scheppern zu Azra. An seinen Ärmeln hängen Splitter und Kalk. (fakt:f_spaet_olli, merkmal:olli)
- **Begründung Can:** Olli war beim Scheppern bei Azra. Splitter und Kalk an seinen Ärmeln passen zur beschädigten Bogentür; das muss er erklären. (fakt:f_alibi_olli, merkmal:olli, karte:bogentuer_schaden)

### Runde 3.1: Wo suchst du nach Herrn Schneiders Schlüsselbund? (`e3_1`)

| Option | Text | Fakten | richtig in |
|---|---|---|---|
| e3_1_turmgang | Im Turmgang bei der Rüstung suchen | f_fundort_can | Can |
| e3_1_ostsaal | Im Ost-Saal mit dem Jackenständer suchen | f_fundort_ahmet | Ahmet |
| e3_1_buffetsaal | Im Buffetsaal an Theke und Buffettischen suchen | f_fundort_fatma, f_fundort_olli | Fatma, Olli |

- **Begründung Ahmet:** Ahmet war beim Scheppern weg, und an seinem Umschlag klebt Wachs vom Tatort. Seine Jacke hängt im Ost-Saal. (fakt:f_spaet_ahmet, fakt:f_z_ahmet, karte:jacke_ahmet)
- **Begründung Fatma:** Fatma kam erst nach dem Scheppern zum linken Buffettisch, und auf ihrer Schatulle ist Wachs vom Tatort. Auf dem Weg dorthin konnte sie etwas ablegen. (fakt:f_spaet_fatma, fakt:f_z_fatma, beobachtung:b_emine_versteck, karte:brottasche)
- **Begründung Olli:** Olli kam erst nach dem Scheppern zu Azra, und an seinem Handschuh ist Wachs vom Tatort. Vorher war er am Eiskübel. (fakt:f_spaet_olli, fakt:f_z_olli, beobachtung:b_wojtek_olli_satz, karte:eiskuebel)
- **Begründung Can:** An Cans Maske klebt Wachs vom Tatort. Das leuchtende Gesicht huschte zur Bogentür, und jemand drängte sich in den Turm. (fakt:f_z_can, beobachtung:b_selin_gesicht, beobachtung:b_wojtek_vorbei, karte:ruestungshelm)

### Runde 3.2: Was untersuchst du jetzt? (`e3_2`)

| Option | Text | Fakten | richtig in |
|---|---|---|---|
| e3_2_fatma | Fatmas Hände und ihren Ring untersuchen | f_k_fatma | Fatma |
| e3_2_kerzenstaender | Den Kerzenständer untersuchen | f_staender_verbogen, f_k_ahmet, f_k_can, f_k_olli | Ahmet, Olli, Can |

- **Begründung Ahmet:** An Ahmets Umschlag ist Wachs vom Tatort, und eine Ecke fehlt. Vielleicht ist sie am Kerzenständer geblieben. (fakt:f_z_ahmet, karte:kerzenstaender)
- **Begründung Fatma:** Auf der Schatulle in Fatmas Tasche ist Wachs vom Tatort. Ihr breiter Silberring trifft beim Zupacken auf das Messing. (fakt:f_z_fatma, merkmal:fatma)
- **Begründung Olli:** An Ollis Handschuh ist Wachs vom Tatort, an seinen Ärmeln hängen Splitter und Kalk. Der Kerzenständer zeigt, ob davon etwas im Wachs klebt. (fakt:f_z_olli, merkmal:olli, karte:kerzenstaender)
- **Begründung Can:** An Cans Maske ist Wachs vom Tatort, und ihre Leuchtfarbe ist noch klebrig. Wer so den Kerzenständer packt, hinterlässt Farbe. (fakt:f_z_can, fakt:f_nd_can_maske, karte:kerzenstaender)

### Runde 3.3: Mit wem sprichst du zuletzt? (`e3_3`)

| Option | Text | Fakten | richtig in |
|---|---|---|---|
| e3_3_zeynep | Zeynep befragen | f_nd_can_zeynep | Ahmet, Fatma, Olli |
| e3_3_aylin | Aylin nach ihrem Beleg fragen | f_nd_ahmet_quittung | Can |

- **Begründung Ahmet:** Ahmets Miete ist schon geklärt, das leuchtende Gesicht nicht. Zeynep stand am Bogen zum Durchgang und sah es vorbeikommen. (fakt:f_nd_ahmet_umschlag, beobachtung:b_zeynep_gesicht, beobachtung:b_marek_gesicht)
- **Begründung Fatma:** Ahmets Miete ist schon geklärt, das leuchtende Gesicht nicht. Zeynep stand am Bogen zum Durchgang und sah es vorbeikommen. (fakt:f_nd_ahmet_umschlag, beobachtung:b_zeynep_gesicht, beobachtung:b_marek_gesicht)
- **Begründung Olli:** Ahmets Miete ist schon geklärt, das leuchtende Gesicht nicht. Zeynep stand am Bogen zum Durchgang und sah es vorbeikommen. (fakt:f_nd_ahmet_umschlag, beobachtung:b_zeynep_gesicht, beobachtung:b_marek_gesicht)
- **Begründung Can:** Ahmet kam erst nach dem Scheppern zu Damir zurück, und seine Miete ist ungeklärt. Aylin hat einen Beleg von Herrn Schneider. (fakt:f_spaet_ahmet, beobachtung:b_aylin_quittung)

## 10. Bonus-Hinweise

| Kennung | Pfad | Runde | Qualität | Text | Wirkung | widerlegt durch |
|---|---|---|---|---|---|---|
| h_ahmet_1_wahr | Ahmet | 1 | wahr | Beim Scheppern war Ahmet nicht bei Damir am Ostende der Theke. | belastet Ahmet (ahmet) |  |
| h_ahmet_1_neutral | Ahmet | 1 | neutral | Im Dunkeln huschte ein leuchtendes Gesicht am Sicherungskasten vorbei. | neutral |  |
| h_ahmet_1_falsch | Ahmet | 1 | falsch | Beim Scheppern war Olli nicht bei Azra am rechten Buffettisch. | belastet Olli (olli) | e1_3_azra |
| h_ahmet_2_wahr | Ahmet | 2 | wahr | Ahmet hat um neun vor zwölf an der Theke mit Herrn Schneider über die Miete gestritten. | belastet Ahmet (ahmet) |  |
| h_ahmet_2_neutral | Ahmet | 2 | neutral | Um Viertel vor zwölf war Fatmas Tasche auffällig ausgebeult. | neutral |  |
| h_ahmet_2_falsch | Ahmet | 2 | falsch | Olli hat um zwanzig vor zwölf die Münzschatulle aus der Vitrine genommen. | belastet Olli (olli) | e2_2_tasche |
| h_ahmet_3_wahr | Ahmet | 3 | wahr | Das leuchtende Gesicht rannte schon vor dem Scheppern durch den Durchgang. | entlastet Can (can) |  |
| h_ahmet_3_neutral | Ahmet | 3 | neutral | Um drei vor zwölf war Can nirgends an der Theke zu sehen. | neutral |  |
| h_ahmet_3_falsch | Ahmet | 3 | falsch | Can hat den Schlüsselbund im Helm der Ritterrüstung versteckt. | belastet Can (can) | e3_1_ostsaal |
| h_fatma_1_wahr | Fatma | 1 | wahr | Beim Scheppern war Fatma nicht bei Emine am linken Buffettisch. | belastet Fatma (fatma) |  |
| h_fatma_1_neutral | Fatma | 1 | neutral | Im Dunkeln huschte ein leuchtendes Gesicht am Sicherungskasten vorbei. | neutral |  |
| h_fatma_1_falsch | Fatma | 1 | falsch | Beim Scheppern war Ahmet nicht bei Damir am Ostende der Theke. | belastet Ahmet (ahmet) | e1_1_damir |
| h_fatma_2_wahr | Fatma | 2 | wahr | Fatma hat um zwanzig vor zwölf die Münzschatulle aus der Vitrine genommen. | belastet Fatma (fatma) |  |
| h_fatma_2_neutral | Fatma | 2 | neutral | Um Viertel vor zwölf war Fatmas Tasche auffällig ausgebeult. | neutral |  |
| h_fatma_2_falsch | Fatma | 2 | falsch | Ahmet hat am Abend die Bogentür beschädigt, und Herr Schneider verlangt Geld dafür. | belastet Ahmet (ahmet) | e2_3_olli |
| h_fatma_3_wahr | Fatma | 3 | wahr | Das leuchtende Gesicht rannte schon vor dem Scheppern durch den Durchgang. | entlastet Can (can) |  |
| h_fatma_3_neutral | Fatma | 3 | neutral | Um drei vor zwölf war Can nirgends an der Theke zu sehen. | neutral |  |
| h_fatma_3_falsch | Fatma | 3 | falsch | Can hat den Schlüsselbund im Helm der Ritterrüstung versteckt. | belastet Can (can) | e3_1_buffetsaal |
| h_olli_1_wahr | Olli | 1 | wahr | Beim Scheppern war Olli nicht bei Azra am rechten Buffettisch. | belastet Olli (olli) |  |
| h_olli_1_neutral | Olli | 1 | neutral | Im Dunkeln huschte ein leuchtendes Gesicht am Sicherungskasten vorbei. | neutral |  |
| h_olli_1_falsch | Olli | 1 | falsch | Beim Scheppern war Fatma nicht bei Emine am linken Buffettisch. | belastet Fatma (fatma) | e1_2_emine |
| h_olli_2_wahr | Olli | 2 | wahr | Olli hat am Abend die Bogentür beschädigt und die Schramme mit Möbelwachs verdeckt. | belastet Olli (olli) |  |
| h_olli_2_neutral | Olli | 2 | neutral | Um Viertel vor zwölf war Fatmas Tasche auffällig ausgebeult. | neutral |  |
| h_olli_2_falsch | Olli | 2 | falsch | Can hat am Abend die Bogentür beschädigt, und Herr Schneider verlangt Geld dafür. | belastet Can (can) | e2_3_olli |
| h_olli_3_wahr | Olli | 3 | wahr | Das leuchtende Gesicht rannte schon vor dem Scheppern durch den Durchgang. | entlastet Can (can) |  |
| h_olli_3_neutral | Olli | 3 | neutral | Um drei vor zwölf war Can nirgends an der Theke zu sehen. | neutral |  |
| h_olli_3_falsch | Olli | 3 | falsch | Can hat den Schlüsselbund im Helm der Ritterrüstung versteckt. | belastet Can (can) | e3_1_buffetsaal |
| h_can_1_wahr | Can | 1 | wahr | Beim Scheppern war das leuchtende Gesicht noch nicht durch den Durchgang gekommen, sondern erst danach. | belastet Can (can) |  |
| h_can_1_neutral | Can | 1 | neutral | Im Dunkeln huschte ein leuchtendes Gesicht am Sicherungskasten vorbei. | neutral |  |
| h_can_1_falsch | Can | 1 | falsch | Beim Scheppern war Fatma nicht bei Emine am linken Buffettisch. | belastet Fatma (fatma) | e1_2_emine |
| h_can_2_wahr | Can | 2 | wahr | Can hat mit einer Leuchtmaske im dunklen Vorratsraum gewartet. | belastet Can (can) |  |
| h_can_2_neutral | Can | 2 | neutral | Um Viertel vor zwölf war Fatmas Tasche auffällig ausgebeult. | neutral |  |
| h_can_2_falsch | Can | 2 | falsch | Olli hat um zwanzig vor zwölf die Münzschatulle aus der Vitrine genommen. | belastet Olli (olli) | e2_2_tasche |
| h_can_3_wahr | Can | 3 | wahr | Beim Scheppern war Ahmet nicht an der Theke, sondern drüben im Ost-Saal an seiner Jacke. | entlastet Ahmet (ahmet) |  |
| h_can_3_neutral | Can | 3 | neutral | Um drei vor zwölf war Can nirgends an der Theke zu sehen. | neutral |  |
| h_can_3_falsch | Can | 3 | falsch | Ahmet hat den Schlüsselbund in seiner Jacke im Ost-Saal versteckt. | belastet Ahmet (ahmet) | e3_1_turmgang |
