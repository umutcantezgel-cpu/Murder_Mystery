// Kammerspiel P1 (ARCHITEKTUR A1/A2): allgemeiner Textprüfer für alle Zeichenketten unter
// content/kammerspiel/schlosskeller/ (FALL-BIBEL WELT 0.2, REG §6, TON-LEITFADEN, E4/E5/E11).
// (a) Rot-Proben je Regel mit eingebauten Verstößen, Grün-Proben gegen Fehlalarme, Fundort,
//     Ausnahmen und Unvollständig-Marken;
// (b) der echte Inhalt: keine Regelverstöße. Unvollständige Felder („OFFEN:“) sind hier noch
//     erlaubt; fehlt der Ordner oder ist er leer, prüft der Test die vorhandenen Dateien (null
//     Dateien = null Befunde).
import 'dart:convert';
import 'dart:io';

import 'package:mordakte_core/src/party/druck/kammer/textpruefer.dart';
import 'package:test/test.dart';

import '../kanon_hilfe.dart' show leseJson, repoWurzel;

final _ordner = '$repoWurzel/content/kammerspiel/schlosskeller';
final _regeln = leseJson('$_ordner/textregeln.json');
final _pruefer = KammerTextpruefer(_regeln);

List<KammerTextBefund> _befunde(String text, {String datei = 'probe.json'}) =>
    _pruefer.pruefeText(text, datei: datei, jsonPfad: r'$.text');

List<String> _regelnVon(String text, {String datei = 'probe.json'}) => [for (final b in _befunde(text, datei: datei)) b.regel];

/// Rot-Proben: Jede Textregel hat Texte mit eingebautem Verstoß, die der Prüfer melden muss.
/// `satzmittel` gilt je Datei und hat eine eigene Probe unten.
const _rot = <String, List<String>>{
  'satzlaenge': [
    'Ahmet hat von allen in der Clique hundertfünfzig Euro für eine angebliche Saalmiete kassiert, obwohl der Keller '
        'kostenlos war, um damit seine viel zu große Bestellung beim Essen zu bezahlen.',
  ],
  'uhrzeit': ['Um 18:40 Uhr trägt Tim die Behälter.', 'Um 4:44 Uhr schläft der Keller.', 'Um 24:00 Uhr ist Schluss.'],
  'uhrzeit-form': ['Um 00:12 Uhr wirft Ahmet den Umschlag in den Ascheneimer.', 'Um 23.58 Uhr knallt es.'],
  'sekunden': ['Um 23:58:30 Uhr scheppert es.', '30 Sek. später scheppert es.', '30 Sekunden später scheppert es.'],
  'punsch': ['Auf dem rechten Buffettisch steht warmer Apfelpunsch.'],
  'herr-schneider': [
    'Schneider forderte 2.000 € bis Mitternacht.',
    'Das ist Schneiders Klemmbrett.',
    'Hausmeister Schneider schimpft über die Bogentür.',
  ],
  'raumname': [
    'Im Ostsaal sitzen alle.',
    'Im Ost Saal sitzen alle.',
    'Im Buffet-Saal ist es hell.',
    'Im Kamin-Saal brennt Feuer.',
    'Im Turm-Gang steht die Rüstung.',
    'Can rennt zur Turmtoilette.',
    'Fatma geht zur Thekenklappe.',
    'Im Westsaal brennt der Kamin.',
    'In der Vorratskammer steht die Torte.',
    'Das Gebäck liegt am linken Büfett.',
  ],
  'raumwort': [
    'Im Gewölbegang wartet niemand.',
    'Der Saal ist leer.',
    'In der Küche brennt Licht.',
    'Kein Ausgang in Sicht.',
    'Der Übergang zur Theke ist eng.',
    'Im Zeitraum davor war es still.',
  ],
  'platzhalter': [
    'TODO: Text für Tim.',
    'Hier fehlt noch XXX.',
    'Olli sagt dann …',
    'Olli sagt dann...',
    'Weitere Aufträge usw.',
    'Siehe […] im Heft.',
    'Der Code ist ???.',
    'Für Emine gilt das analog.',
  ],
  'klammer': ['Lies {name vor.', 'Lies name} vor.', 'Sobald [Lejla | ein Gast etwas sagt.'],
  'schlagverb': [
    'Wer hat Herrn Schneider niedergeschlagen?',
    'Wer hat Herrn Schneider geschlagen?',
    'Olli schlug in Panik zu.',
    'Olli schlägt zu.',
    'Jemand hat zugeschlagen.',
    'Er wollte nicht zuschlagen.',
    'Schlagen ist nie eine Lösung.',
    'Ihr schlagt die Seite nach.',
    'Niemand wollte ihn verprügeln.',
    'Er hat zugehauen.',
  ],
  'schlag-nomen': ['Nach dem Schlag war es still.', 'Der Schlag kam von hinten.', 'Man hörte zwei Schläge.'],
  'gewalt': [
    'Herr Schneider liegt bewusstlos mit Platzwunde im Vorratsraum.',
    'Am Boden ist Blut.',
    'Er ist schwer verletzt.',
    'Er hat Schmerzen.',
    'Das war ein Überfall.',
    'Tim hat einen gequetschten Finger.',
  ],
  'alkohol': [
    'Auf der Theke steht Sekt.',
    'Es gibt Glühwein.',
    'Ihr Mantel ist weinrot.',
    'Marek bringt Bier.',
    'Olli sitzt auf einem Barhocker.',
    'Im Kühlschrank steht Eierlikör.',
    'Can ist betrunken.',
  ],
  'bargeld': ['Ahmet soll Marek die Nachzahlung bar bezahlen.', 'Sie treffen sich an der Bar.'],
  'drogen': ['Er kifft heimlich im Turmgang.'],
  'rauchen': ['Im Durchgang raucht jemand.', 'Dichter Rauch zieht durch den Durchgang.', 'Wojtek dampft eine E-Zigarette.'],
  'fachwort': [
    'Die Chafing-Dishes sind leer.',
    'Das ist die Smoking Gun.',
    'Am Tresen steht Marek.',
    'Er handelte im Affekt.',
  ],
  'herkunft': [
    'An Fatmas Kopftuch hängt ein Glassplitter.',
    'Seine Herkunft spielt eine Rolle.',
    'Marek flucht auf Polnisch.',
    'Die Nationalität steht auf dem Zettel.',
  ],
  'schatulle': [
    'Fatma hat die Münzschatulle gestohlen.',
    'Die Schatulle wurde geklaut.',
    'Fatma entwendete die Schatulle aus der Vitrine.',
    'Fatma stahl die Schatulle.',
    'Der Diebstahl der Schatulle fällt auf.',
  ],
  'anglizismus': [
    'Das Evidence Board liegt in der Tischmitte.',
    'Der Trigger für Ahmet ist Mareks Aussage.',
    'Sorry, Olli!',
    'Leg den Clue neben den Lageplan.',
    'Jetzt kommt die Ping-Pong-Vorstellung.',
    'Ein Spiel mit Pen & Paper.',
    'Fordere einen Taschen-Check.',
    'Ein Abend wie in Knives Out.',
    'Erst etwas Smalltalk.',
  ],
  'erzaehler': ['Der Spielleiter liest vor.', 'Die Spielleitung verteilt die Karten.', 'Der Game Master liest vor.'],
  'name': [
    'Leila sah Olli kommen.',
    'Leyla sah Olli kommen.',
    'Johanna fotografiert.',
    'Mark liefert das Essen.',
    'Murat liefert das Essen.',
    'Achmet sammelt das Geld ein.',
    'Dschan rennt weg.',
  ],
  'gestrichene-figur': ['Baran bringt die Box.', 'Pawel hilft beim Tragen.', 'Barans Box ist laut.'],
  'sperrliste': [
    'Der Burgwart schimpft.',
    'Herr Schneider ist benommen.',
    'Heute ist ein Geburtstag.',
    'Die Schramme ist mit Bienenwachs verdeckt.',
    'In der Speisekammer steht die Torte.',
  ],
};

/// Grün-Proben: regelkonforme Texte, darunter Sätze aus der FALL-BIBEL, die ohne Befund bleiben müssen.
const _gruen = [
  // Wortgrenzen bei „bar“ (WELT 0.2: „Bargeld“ statt „bar“, Suffix erlaubt).
  'Die Schramme ist kaum sichtbar, offenbar frisch und unmittelbar neben dem Beschlag.',
  'Ahmet hat das Geld in Bargeld eingesammelt.',
  'Zeynep läuft barfuß über den kalten Steinboden.',
  // Schlag nur als Geräusch; Nomen mit „schlag“ bleiben erlaubt.
  'Dann ist da nur ein dumpfer Schlag und Poltern.',
  'Ein dumpfer Schlag, Poltern, Metall scheppert über den Steinboden.',
  'Ahmet wirft den leeren Umschlag in den Ascheneimer.',
  'Der Beschlag der Bogentür ist aus der Wand gerissen.',
  'Herr Schneider hat einen Quittungsblock mit Durchschlägen.',
  'Zur Torte gibt es Schlagsahne.',
  // „Herr Schneider“, „Herrn Schneiders“; die Schneiderei ist kein Name.
  'Herrn Schneiders Schlüsselbund ist weg.',
  'Herr Schneider liegt bewusstlos, mit einer dicken Beule, im Vorratsraum.',
  'Fatma hat in einer Schneiderei gejobbt.',
  'Herr\u00A0Schneider und Herrn\nSchneider: geschütztes Leerzeichen und Zeilenumbruch zählen wie ein Leerzeichen.',
  // Wörtliche Rede Ollis in fremdem Heft und Aylins Quittungszettel (FALL-BIBEL ZG 3, ZR 7).
  'Um 23:52 Uhr hat Olli zu mir gesagt: ‚Ich hol dir Eis. Und dann red ich mit Schneider.‘',
  'Herr Schneider hat mir auf einen Quittungszettel geschrieben: ‚Miete: 0 Euro. Schneider‘.',
  // Wunder, verschwunden, verwundert, gewunden.
  'Serkan hat Wunderkerzen im Auto.',
  'Der Schlüsselbund ist verschwunden, Joanna ist verwundert.',
  'Die gewundene Treppe führt zur Turm-Toilette.',
  // Schatulle ausgeliehen; Stahl ohne Diebstahl; Stehlampe.
  'Fatma hat die Münzschatulle ausgeliehen und bringt sie am Montag zurück.',
  'Der Bund hängt an einem Stahlring, Serkans Weste ist stahlblau.',
  'Neben der Schatulle steht eine Stehlampe.',
  // Getränke.
  'Auf dem rechten Buffettisch steht warmer alkoholfreier Apfelpunsch.',
  'Der Tee dampft im großen Teekocher.',
  'Emine weint fast vor Lachen, und Damir schenkt Tee aus.',
  'Die Insekten im Kaminsaal schlafen.',
  // Kamin-Kontext für Qualm (TON §6).
  'Um zwanzig nach elf hab ich den Kamin angefeuert und die Klappe vergessen. Der Qualm im Kaminsaal war meine Schuld.',
  // Raumnamen genau so, Genitiv, zusammengesetzte Wörter.
  'Im Ost-Saal, im Buffetsaal, im Vorratsraum, im Durchgang und im Turmgang ist es still.',
  'Die Tür des Ost-Saals klemmt, die Vorratsraumtür auch.',
  'Marek parkt im Schlosshof, Zeynep steht im Steinbogen zum Kaminsaal.',
  'Fatma geht zur Theken-Klappe, Joanna steht im Windfang.',
  'Unter dem Schlossturm liegt der Gewölbekeller.',
  // Erlaubte Lehnwörter und Begriffe aus dem Kanon.
  'Tugba, die Party-Planerin, legt die Marker auf den Lageplan.',
  'Wojtek hat Musikboxen und ein Handy im Handyhalter mitgebracht.',
  'Joanna führt eine Checkliste für das Gruppenfoto.',
  'Fatma schreibt im letzten Semester eine Klausur.',
  // Namen in heutiger Schreibweise.
  'Lejla, Joanna und Marek sitzen am rechten Buffettisch.',
  'Markus ist heute nicht da.',
  // Uhrzeiten aus WELT 0.2.
  'Um 23:58 Uhr knallt es, um 0:00 Uhr geht das Licht an.',
  'Von 23:50 bis 23:55 Uhr sitzt der Detektiv im Ost-Saal.',
  // Auslassung in wörtlicher Rede.
  'Olli flüstert: „Lejla? Ich bin’s, Olli …“',
  'Er sagt: „Ich wollte nur …“ und schweigt.',
  // Platzhalter mit Paaren (die Syntax legt das Schema fest).
  'Sobald [Lejla | ein Gast] etwas sagt, liest du vor: {name}.',
  // Regelkonforme Ersatzsätze aus REG §7.2.
  'Zwei vor zwölf knallt es, dann ist es dunkel. Eine halbe Minute später scheppert Metall über den Steinboden. '
      'Um Mitternacht geht das Licht wieder an.',
  'Wer steckt hinter dem dumpfen Schlag im Dunkeln?',
  // Joannas Notiz (WELT 5.4, wörtlich): Zeilen sind eigene Sätze.
  'Gruppenfoto 0:00 – wer fehlt noch?\nAhmet: hinter der Theke, Ostende\nFatma: geht zur Klappe\n'
      'Olli: am Eiskübel, redet mit Herrn Schneider\nHerr Schneider: am Ostende\nMarek: Saft, hinter der Theke\n'
      'Tim: Kaffeemaschine\nLejla: rechtes Buffet\nEmine: linkes Buffet\nZeynep: im Bogen zum Kaminsaal, kommt gleich\n'
      'Can: nirgends!\nKaminsaal: noch ein paar, kommen gleich',
  // Joannas Frage an Olli (ZG 4, wörtlich): ‚…‘ beendet den Satz wie „…“.
  'Olli, auf meiner Notiz von 23:57 Uhr steht: ‚Olli: am Eiskübel, redet mit Herrn Schneider.‘ Ich hab gehört, wie er '
      'zu dir sagte: ‚Zweitausend, bis zwölf.‘ Und im Dunkeln, kurz bevor das Licht anging, war der Kopf der Tafel leer. '
      'Wo warst du wirklich?',
  // Tugbas offenes Wissen (WELT 7.3).
  'Um halb acht hat Olli am kalten Kamin den linken Arbeitshandschuh in die Nische gelegt. Der war schwarz vom alten '
      'Ruß. Den rechten hatte er in der Westentasche.',
];

void main() {
  group('Regeldaten', () {
    test('textregeln.json liest sich und nennt jede Regel genau einmal', () {
      final regeln = _pruefer.regeln;
      expect(regeln.toSet(), hasLength(regeln.length), reason: regeln.join(', '));
    });

    test('jede Regel hat Rot-Proben (satzmittel je Datei, siehe unten)', () {
      expect({..._rot.keys, KammerTextRegel.satzmittel}, _pruefer.regeln.toSet());
    });

    test('die Uhrzeiten sind genau die Liste aus WELT 0.2', () {
      final soll = [
        '18:00', '18:30', '18:35', '18:45', '18:50', '19:00', '19:30', '20:15', '21:00', '22:00', '22:30', //
        '23:00', '23:20', '23:30', '23:40', '23:45', for (var m = 50; m <= 59; m++) '23:$m', //
        '0:00', '0:01', '0:02', '0:03', '0:05', for (var m = 10; m <= 13; m++) '0:$m', //
        '0:15', '0:20', '0:30', '1:15', '2:00', '2:45', '7:00',
      ];
      expect(_regeln['uhrzeiten'], soll);
    });

    test('Schlag-Verben aus pfadwissen.dart sind alle abgedeckt (LÜ S-34)', () {
      for (final v in [
        'schlägst', 'schlägt', 'schlage', 'schlug', 'schlugen', 'zugeschlagen', 'zuschlagen', 'zuzuschlagen', //
        'niedergeschlagen', 'geschlagen', 'schlagen', 'erschlagen', 'schlugst', 'schlagend',
      ]) {
        expect(_regelnVon('Probe: $v.'), contains('schlagverb'), reason: v);
      }
    });
  });

  group('Rot-Proben', () {
    for (final e in _rot.entries) {
      test('${e.key} wird gemeldet', () {
        for (final t in e.value) {
          expect(_regelnVon(t), contains(e.key), reason: t);
        }
      });
    }

    test('satzmittel: eine Datei mit langen Sätzen wird gemeldet, eine mit kurzen nicht', () {
      const lang = 'Olli trägt mit Tim um halb sieben die schweren Warmhaltebehälter durch die geschnitzte Bogentür aus Eiche '
          'in den Keller hinunter.';
      const kurz = 'Olli trägt die Behälter.';
      final e = _pruefer.pruefe({
        'lang.json': {'a': lang, 'b': lang, 'c': kurz},
        'kurz.json': {'a': kurz, 'b': kurz, 'c': lang},
      });
      final mittel = [for (final b in e.befunde) if (b.regel == KammerTextRegel.satzmittel) b];
      expect(mittel, hasLength(1));
      expect(mittel.single.datei, 'lang.json');
      expect(mittel.single.jsonPfad, r'$');
    });

    test('bar als Wort meldet nur bargeld, Barhocker nur alkohol', () {
      expect(_regelnVon('Er zahlt bar.'), ['bargeld']);
      expect(_regelnVon('Er sitzt auf dem Barhocker.'), ['alkohol']);
    });

    test('der Ersatz steht im Befund', () {
      final b = _befunde('Leila sah Olli.').single;
      expect((b.regel, b.treffer, b.ersatz), ('name', 'Leila', 'Lejla'));
      final r = _befunde('Im Ostsaal sitzen alle.').single;
      expect((r.regel, r.treffer, r.ersatz), ('raumname', 'Ostsaal', 'Ost-Saal'));
      final z = _befunde('Um 00:12 Uhr fällt der Umschlag.').single;
      expect((z.regel, z.treffer, z.ersatz), ('uhrzeit-form', '00:12', '0:12'));
    });
  });

  group('Grün-Proben', () {
    for (final t in _gruen) {
      test('ohne Befund: ${t.split('\n').first}', () {
        expect(_befunde(t).map((b) => '$b'), isEmpty);
      });
    }
  });

  group('Satzlänge wie gedruckt: Platzhalter aufgelöst, ohne Auszeichnung', () {
    List<String> lang(String text, {Object? fall}) => [
          for (final b in _pruefer.pruefeText(text, fall: fall))
            if (b.regel == KammerTextRegel.satzlaenge) b.treffer,
        ];
    const knapp = 'hat beim Knall an der Theke gekauert und gesehen, wie Ahmet sich neben ihn duckte.';
    const zuLang = 'Der Caterer hat beim Knall und auch beim Scheppern hinten an der Theke am Ostende gekauert und dabei '
        'ganz genau gesehen, wie Ahmet sich mit dem Umschlag neben ihn duckte.';

    test('beide Zweige eines Platzhalters sind getrennte Sätze', () {
      expect(lang('{wenn:marek|Marek $knapp|Der Caterer $knapp} Dann ging das Licht an.'), isEmpty);
      expect(lang('{rolle:marek|Der Caterer} $knapp'), isEmpty);
    });

    test('ein zu langer Satz in einem Zweig wird gemeldet, mit der Wortzahl der Fassung', () {
      expect(lang('{wenn:marek|Marek $knapp|$zuLang}'), ['30']);
      expect(lang('{ab:14|$zuLang|Kurz.}'), ['30']);
      expect(lang('{detektiv:Er hört zu.|$zuLang}'), ['30']);
    });

    test('Auszeichnung trennt keinen Satz und verbindet keine zwei', () {
      expect(
        lang('**Dein Bonus-Ziel:** Du sagst selbst, was du verbirgst, bevor man es dir beweist. **Erfüllt, wenn** du deine '
            'Geheimniskarte am Ende einer Runde freiwillig umdrehst, bevor dein erster Fall eintritt.'),
        isEmpty,
      );
      expect(lang('**$zuLang**'), ['30']);
    });

    test('Doppelpunkt vor wörtlicher Rede beendet den Satz, sonst nicht', () {
      // Damirs Auftrag (FALL-BIBEL ZR, wörtlich).
      expect(
        lang('**Sprich leise mit Sibel:** „Wenn am Tisch die Vitrine Thema wird und jemand anderes für unseren Sprung '
            'geradestehen soll: Sagen wir es dann selbst, am Ende der Runde?“'),
        isEmpty,
      );
      expect(lang('Ahmet sagt im Dunkeln zu allen am Tisch: eine Zeugin, ein Zeuge, ein Streifen, eine Karte, ein Foto, '
          'ein Zettel, ein Handschuh, ein Umschlag oder ein Eiskübel.'), ['27']);
    });

    test('mit fall.json zählen nur Besetzungen, die es gibt (Ahmet spielt immer)', () {
      final fall = leseJson('$_ordner/fall.json');
      const text = '{wenn:ahmet|Ahmet $knapp|$zuLang}';
      expect(lang(text), ['30'], reason: 'ohne fall.json: beide Extreme');
      expect(lang(text, fall: fall), isEmpty);
      final e = _pruefer.pruefe({'fall.json': fall, 'probe.json': {'a': text}});
      expect([for (final b in e.befunde) if (b.datei == 'probe.json') b.regel], isNot(contains(KammerTextRegel.satzlaenge)));
      final ohne = _pruefer.pruefe({'probe.json': {'a': text}});
      expect([for (final b in ohne.befunde) b.regel], contains(KammerTextRegel.satzlaenge));
    });

    test('Wortregeln „im selben Satz“ sehen die Satzgrenzen hinter Zweigen und Auszeichnung', () {
      // Der erste Apfelpunsch steht ohne „alkoholfrei“ in seinem Satz; das „alkoholfrei“ im anderen Zweig zählt nicht.
      expect(_regelnVon('{wenn:marek|Es gibt Apfelpunsch.|Der Punsch ist alkoholfrei.}'), contains(KammerTextRegel.punsch));
      expect(_regelnVon('**Es gibt Apfelpunsch.** Er ist alkoholfrei.'), contains(KammerTextRegel.punsch));
      expect(_regelnVon('**Es gibt alkoholfreien Apfelpunsch.** Er ist warm.'), isNot(contains(KammerTextRegel.punsch)));
    });
  });

  group('Fundort, Ausnahmen, Unvollständig', () {
    test('Befund trägt Datei, JSON-Pfad, Regel und Treffer', () {
      final e = _pruefer.pruefe({
        'rollen/07-tim.json': {
          'stufe2': {
            'text': ['Alles in Ordnung.', 'Olli schlug zu.'],
          },
          'a b': 'Am Boden ist Blut.',
        },
      });
      expect([for (final b in e.befunde) '${b.datei} ${b.jsonPfad} ${b.regel} ${b.treffer}'], [
        r'rollen/07-tim.json $.stufe2.text[1] schlagverb schlug',
        r'rollen/07-tim.json $["a b"] gewalt Blut',
      ]);
      expect(e.dateien, ['rollen/07-tim.json']);
    });

    test('Texte mit „OFFEN:“ sind unvollständig, kein Regelverstoß', () {
      final e = _pruefer.pruefe({
        'x.json': {
          'a': 'OFFEN: Ollis Satz fehlt noch, TODO',
          'b': [' OFFENE FRAGE: Wer liest das vor?'],
          'c': 'Fertig.',
        },
      });
      expect(e.befunde, isEmpty);
      expect([for (final u in e.unvollstaendig) u.jsonPfad], [r'$.a', r'$.b[0]']);
    });

    test('Sekunden nur in den Dateien des Auflösungshefts (Vorgabe-Ausnahmen)', () {
      const t = 'Um 23:58:30 Uhr scheppert es.';
      expect(_regelnVon(t, datei: '90-aufloesung.json'), isEmpty);
      expect(_regelnVon(t, datei: 'teile/aufloesung.json'), isEmpty);
      expect(_regelnVon(t, datei: 'rollen/03-olli.json'), ['sekunden']);
      // Die Uhrzeit selbst wird auch im Auflösungsheft geprüft.
      expect(_regelnVon('Um 23:48:30 Uhr ist es still.', datei: '90-aufloesung.json'), ['uhrzeit']);
    });

    test('bloß „Schneider“ nur in Ollis Datei (Vorgabe-Ausnahme)', () {
      const t = 'Schneider will bis Mitternacht 2.000 €.';
      expect(_regelnVon(t, datei: 'rollen/03-olli.json'), isEmpty);
      expect(_regelnVon(t, datei: 'rollen/07-tim.json'), ['herr-schneider']);
    });

    test('Ausnahmen als Parameter: Datei-Glob, JSON-Pfad-Präfix, alle Regeln', () {
      final dateien = {
        'teile/neunzig.json': {'zeit': 'Um 23:58:30 Uhr scheppert es.'},
        'fall.json': {
          'olli': {'satz': 'Schneider will Geld.'},
          'ollie': 'Schneider will Geld.',
          'tim': 'Schneider will Geld.',
        },
        'notizen/alt.json': {'x': 'TODO Blut'},
      };
      final ohne = _pruefer.pruefe(dateien);
      expect(ohne.befunde.map((b) => '${b.datei} ${b.jsonPfad} ${b.regel}'), [
        r'fall.json $.olli.satz herr-schneider',
        r'fall.json $.ollie herr-schneider',
        r'fall.json $.tim herr-schneider',
        r'notizen/alt.json $.x gewalt',
        r'notizen/alt.json $.x platzhalter',
        r'teile/neunzig.json $.zeit sekunden',
      ]);
      final mit = _pruefer.pruefe(dateien, ausnahmen: {
        'sekunden': ['teile/*.json'],
        'herr-schneider': [r'fall.json#$.olli'],
        '*': ['notizen/**'],
      });
      expect(mit.befunde.map((b) => '${b.datei} ${b.jsonPfad} ${b.regel}'), [
        r'fall.json $.ollie herr-schneider',
        r'fall.json $.tim herr-schneider',
      ]);
    });

    test('Index-Muster im JSON-Pfad', () {
      final e = _pruefer.pruefe(
        {
          'k.json': {
            'liste': [
              {'t': 'Er zahlt bar.'},
              {'t': 'Er zahlt bar.'},
            ],
          },
        },
        ausnahmen: {
          'bargeld': [r'k.json#$.liste[*].t'],
        },
      );
      expect(e.befunde, isEmpty);
    });

    test('textregeln.json und Schemata werden nicht geprüft', () {
      expect(_pruefer.dateiGeprueft('textregeln.json'), isFalse);
      expect(_pruefer.dateiGeprueft('kammerspiel.schema.json'), isFalse);
      expect(_pruefer.dateiGeprueft('schema/rolle.schema.json'), isFalse);
      expect(_pruefer.dateiGeprueft('rollen/03-olli.json'), isTrue);
      final e = _pruefer.pruefe({'textregeln.json': _regeln});
      expect(e.befunde, isEmpty);
      expect(e.dateien, isEmpty);
    });

    test('gleiche Eingabe, gleiche Befunde in gleicher Reihenfolge (Dateien sortiert)', () {
      final a = _pruefer.pruefe({'b.json': 'Blut.', 'a.json': 'Bier.'});
      final b = _pruefer.pruefe({'a.json': 'Bier.', 'b.json': 'Blut.'});
      expect(a.befunde.map((x) => '$x'), b.befunde.map((x) => '$x'));
      expect(a.befunde.map((x) => x.datei), ['a.json', 'b.json']);
    });

    test('kammerTextStellen liefert alle Zeichenketten mit Pfad, keine Schlüssel', () {
      final s = kammerTextStellen({
        'r.json': {
          'TODO': 'x',
          'l': [1, 'y', null, {'z': 'w'}],
        },
      }).map((s) => '${s.jsonPfad}=${s.text}');
      expect(s, [r'$.TODO=x', r'$.l[1]=y', r'$.l[3].z=w']);
    });
  });

  test('(b) echter Inhalt unter content/kammerspiel/schlosskeller: keine Regelverstöße', () {
    final ordner = Directory(_ordner);
    final dateien = <String, Object?>{};
    if (ordner.existsSync()) {
      for (final f in ordner.listSync(recursive: true).whereType<File>()) {
        if (!f.path.endsWith('.json')) continue;
        final rel = f.path.substring(ordner.path.length + 1).replaceAll(r'\', '/');
        dateien[rel] = jsonDecode(f.readAsStringSync());
      }
    }
    final e = _pruefer.pruefe(dateien);
    expect(
      e.befunde.map((b) => '$b'),
      isEmpty,
      reason: '${e.befunde.length} Befunde in ${e.dateien.length} Dateien '
          '(${e.unvollstaendig.length} Felder noch unvollständig):\n${e.befunde.join('\n')}',
    );
  });
}
