// Fixtures für Einstimmung und Erzählerakte (A-063): Die echten Inhalte schreibt
// ein anderes Team. Hier entstehen im Test erzeugte, neutrale Platzhaltertexte,
// die alle Regeln der Prüfer erfüllen: ein Setting mit Vorgeschichte, die Texte
// der Einstimmung als zusätzliche Dateien der Textsammlung und eine gültige
// Erzählerakte aus figuren.json. Kein Text hier gehört in den Kanon.
import 'package:mordakte_core/mordakte_core.dart';

import 'kanon_hilfe.dart';

/// Teile der Vorgeschichte (wie in der SPEZIFIKATION vorgeschlagen).
const fixtureTeile = ['schloss', 'schneider', 'clique', 'einladung', 'keller', 'eigenarten', 'heute'];

/// Blöcke der Vorgeschichte: neutrale Platzhalter, die vier Kernfiguren je fünfmal.
const _vorgeschichte = {
  'schloss': 'Das alte Schloss steht seit Jahrhunderten auf einem Hügel vor der Stadt. Früher wohnten hier Grafen, heute gehört es '
      'einer Stiftung. Die Stiftung pflegt die dicken Mauern, den Garten und den hohen Turm. Im Sommer kommen Schulklassen und '
      'Familien zu den Führungen. Im Winter wird es still, und der Wind singt in den alten Fenstern. Unter dem Turm liegt ein '
      'großes Gewölbe mit runden Bögen. Dort feiern manchmal Vereine ihre Feste, mit Musik und langen Tafeln. Ahmet war als Kind '
      'oft hier und kennt fast jede Ecke. Fatma findet die Mauern schön und ein bisschen unheimlich.',
  'schneider': 'Herr Schneider verwaltet das Schloss seit vielen Jahren. Er kennt jede Treppe, jede Tür und jeden knarrenden Balken. '
      'Morgens dreht er seine Runde und prüft die Fenster. Am liebsten mag er den Herbst, wenn das Laub im Garten raschelt. Er mag Ordnung, Pünktlichkeit und einen heißen Tee am Nachmittag. Wer '
      'laut wird, bekommt einen strengen Blick über die Brille. Doch hinter dem grimmigen Gesicht steckt ein gutes Herz. Olli hat '
      'ihm einmal mit schweren Stühlen geholfen. Seitdem grüßt Herr Schneider ihn mit einem kurzen Nicken. Can findet, dass Herr '
      'Schneider wie ein Burggespenst brummt, und ahmt ihn gern nach.',
  'clique': 'Die Clique kennt sich schon seit der Schulzeit. Damals saßen Ahmet, Fatma, Olli und Can oft zusammen auf der Mauer am '
      'Sportplatz. Sie teilten Pausenbrote, Witze und viele lange Sommerabende. Auf alten Fotos tragen alle bunte Mützen und '
      'grinsen frech in die Kamera. Später zogen einige zum Studium in andere Städte. '
      'Doch die Gruppe hielt Kontakt über Nachrichten und kurze Besuche. Jedes Jahr wollten sie sich einmal alle wiedersehen. '
      'Meistens klappte das nicht, weil immer jemand arbeiten musste oder krank wurde. Dieses Jahr soll es endlich anders werden, '
      'und alle haben fest zugesagt.',
  'einladung': 'Im Herbst kam die Idee für ein großes Wiedersehen. Ahmet schlug vor, im Schloss zu feiern, weil er die Stiftung von '
      'seiner Arbeit kennt. Ahmet hat den Keller organisiert. Fatma gestaltete die Einladung mit Fledermäusen und kleinen '
      'Gespenstern. Die Karten gingen an alle alten Freunde und an einige neue Gesichter. Jeder sollte etwas mitbringen, ein Lied, '
      'ein Spiel oder einen Kuchen. Can versprach, für gute Laune zu sorgen, und schickte sofort drei Witze in die Gruppe. Die '
      'Antworten kamen schnell, und bald hatten fast alle zugesagt.',
  'keller': 'Das Gewölbe unter dem Turm ist groß, kühl und voller Echos. Mehrere Säle reihen sich unter niedrigen Bögen aneinander. '
      'An den Wänden hängen alte Fahnen und verblasste Bilder. Lange Holztische warten auf Teller, Schüsseln und Becher. Olli trug '
      'am Nachmittag die schweren Bänke an ihren Platz. Fatma hängte Girlanden auf und lachte über das Echo ihrer Stimme. Herr '
      'Schneider schaute zu und brummte etwas von Brandschutz und Ordnung. Am Ende sah alles festlich und ein wenig gespenstisch '
      'aus, genau richtig für diese Nacht.',
  'eigenarten': 'Jeder in der Clique hat seine Eigenarten. Ahmet plant gern alles bis ins Kleinste und hat immer eine Liste dabei. '
      'Fatma zeichnet in jeder freien Minute kleine Figuren auf Servietten. Olli packt überall mit an, auch wenn niemand fragt. Can '
      'erzählt Witze, bis alle stöhnen und trotzdem lachen. Zusammen sind sie laut, herzlich und manchmal ein wenig chaotisch. Wer '
      'neu dazukommt, wird sofort in lange Gespräche verwickelt. So war es schon immer, und so soll es auch heute bleiben.',
  'heute': 'Heute ist ein kalter Samstag im November. Der Wind fegt über den Hügel und rüttelt an den Läden. Drinnen duftet es nach '
      'warmem Essen und frischem Tee. Die Gäste ziehen ihre Jacken aus und reiben sich die Hände. Can lacht schon an der Tür über '
      'seinen eigenen Witz. Olli trägt noch eine letzte Kiste herein und stellt sie behutsam ab. Gleich beginnt ein Abend, über den '
      'man noch lange sprechen wird. Hört gut zu, denn jetzt lernt ihr die Gäste kennen, einen nach dem anderen.',
};

const _titel = {
  'schloss': 'Das alte Schloss',
  'schneider': 'Herr Schneider',
  'clique': 'Die Clique',
  'einladung': 'Die Einladung',
  'keller': 'Das Gewölbe',
  'eigenarten': 'Eigenarten',
  'heute': 'Heute',
};

/// Zusätzliche Sätze einzelner Vorstellungen: Sie nennen eine Figur mit
/// kleinerem Besetzungsplatz über eine öffentliche Kante der Fixture-Akte.
const _bindung = {
  'leyla': 'Mit Ahmet ist sie seit Kindertagen eng verbunden.',
  'emine': 'Mit Fatma teilt sie seit vielen Jahren fast alles.',
  'zeynep': 'Auf Can passt sie auf, so gut es eben geht.',
};

/// Setting des Schlosskellers mit Einstimmung (Fixture).
Map<String, Object?> settingMitEinstimmung({List<String> teile = fixtureTeile, bool vorstellung = true}) =>
    {...leseJson('$repoWurzel/content/party/schlosskeller/setting.json'), 'vorgeschichte': teile, 'vorstellung': vorstellung};

/// Kanon des Schlosskellers mit anderem [setting] und anderen Dateien ([ersatz]).
Kanon kanonMit({Map<String, Object?>? setting, Map<String, Map<String, Object?>> ersatz = const {}}) => Kanon.lade((p) {
      if (p == 'setting.json' && setting != null) return setting;
      return ersatz[p] ?? leseJson('$repoWurzel/content/party/schlosskeller/$p');
    });

Kanon? _fixtureKanon;

/// Kanon mit Vorgeschichte und Vorstellung (einmal je Testdatei).
Kanon get einstimmungKanon => _fixtureKanon ??= kanonMit(setting: settingMitEinstimmung());

/// Die Texte der Einstimmung (Kennung → Text): alle Blöcke, Vorstellungen und Kapiteltitel.
Map<String, String> einstimmungTexte() {
  final t = <String, String>{
    for (final e in _vorgeschichte.entries) 'vorgeschichte.${e.key}': e.value,
    for (final e in _titel.entries) 'ui.einstimmung.titel.${e.key}': e.value,
    'vorstellung.start': 'Bevor der Abend richtig beginnt, lernt ihr die Gäste kennen. Wer genannt wird, steht kurz auf und winkt in die Runde.',
    'vorstellung.npc': 'Am Tisch sitzen heute noch weitere Gäste. Sie kommen später zu Wort, wenn der Abend sie braucht.',
    for (final g in ['m', 'w'])
      'vorstellung.detektiv.$g': 'Und dann bist da noch du. Du bist als Gast hier und kennst kaum jemanden am Tisch. Du hörst gut zu, '
          'merkst dir Gesichter und stellst gern Fragen. Heute wolltest du einfach feiern, Tee trinken und nette Leute kennenlernen. '
          'Doch dieser Abend verläuft anders, als du denkst.',
  };
  for (final f in kanon.figuren) {
    final id = f['id'] as String;
    final name = f['name'] as String;
    final titel = f['roleTitle'] as String;
    final alltag = f['alltag'] as String;
    final (er, ihn) = f['geschlecht'] == 'w' ? ('sie', 'sie') : ('er', 'ihn');
    final gross = '${er[0].toUpperCase()}${er.substring(1)}';
    t['vorstellung.$id'] = [
      'Das ist $name, ${titel[0].toLowerCase()}${titel.substring(1)}.',
      '$name ${alltag[0].toLowerCase()}${alltag.substring(1)}',
      ?_bindung[id],
      '$gross sitzt heute mit am Tisch und freut sich auf einen langen Abend.',
      'Wer $ihn anspricht, bekommt ein offenes Lächeln und meistens eine kleine Geschichte dazu.',
      'Heute will $er vor allem essen, lachen und alte Bekannte wiedersehen.',
    ].join(' ');
  }
  return t;
}

/// Textsammlung des Schlosskellers mit [texte] als zusätzlichen Dateien:
/// `erzaehler-vorgeschichte.json`, `erzaehler-vorstellung.json` (Bereich
/// erzaehler) und `ui-einstimmung.json` (Bereich ui).
Textsammlung sammlungMit(Map<String, String> texte) {
  Map<String, Object?> datei(String bereich, bool Function(String) passt) => {
        'settingId': kanon.settingId,
        'bereich': bereich,
        'hinweis': 'Fixture',
        'eintraege': [
          for (final e in texte.entries)
            if (passt(e.key)) {'id': e.key, 'text': e.value},
        ],
      };
  final zusatz = {
    'texte/erzaehler-vorgeschichte.json': datei('erzaehler', (k) => k.startsWith('vorgeschichte.')),
    'texte/erzaehler-vorstellung.json': datei('erzaehler', (k) => k.startsWith('vorstellung.')),
    'texte/ui-einstimmung.json': datei('ui', (k) => k.startsWith('ui.')),
  };
  return Textsammlung.lade((p) {
    if (zusatz[p] case final z?) return z;
    final j = leseJson('$repoWurzel/content/party/schlosskeller/$p');
    if (p != 'texte/index.json') return j;
    return {
      ...j,
      'dateien': [
        ...(j['dateien'] as List),
        for (final (d, b) in [('erzaehler-vorgeschichte.json', 'erzaehler'), ('erzaehler-vorstellung.json', 'erzaehler'), ('ui-einstimmung.json', 'ui')])
          {'datei': d, 'bereich': b},
      ],
    };
  });
}

/// Texte mit Einstimmung: [k] (Standard [einstimmungKanon]) und die Fixture-Texte mit [aenderung].
Texte einstimmungTexteMit({Kanon? k, Map<String, String> aenderung = const {}}) =>
    Texte(k ?? einstimmungKanon, sammlungMit({...einstimmungTexte(), ...aenderung}));

const _fuell = [
  'Im Freundeskreis gilt @er als verlässlich und hilfsbereit.',
  'An freien Tagen trifft @er sich gern mit alten Bekannten.',
  'Bei Festen sitzt @er meistens dort, wo am meisten gelacht wird.',
  'Über die Jahre hat @er viele kleine Gewohnheiten gesammelt.',
  'Wer @ihn länger kennt, hört die leisen Zwischentöne heraus.',
  'Zum Wiedersehen ist @er mit viel Neugier und etwas Lampenfieber gekommen.',
  'Lange Gespräche am Tisch mag @er lieber als laute Musik.',
  'Von früher erzählt @er gern, aber selten ganz ohne Übertreibung.',
];

String _fuelle(String er, String ihn, int n) => [for (final s in _fuell.take(n)) s.replaceAll('@er', er).replaceAll('@ihn', ihn)].join(' ');

/// Kanten des Fixture-Netzes: Loyalitäten (öffentlich, wenn ein Dossier das
/// Paar nennt, sonst heimlich), ein Ring in Besetzungsreihenfolge und Herr
/// Schneider zu jeder zweiten Figur.
List<Map<String, Object?>> _netz() {
  final reihe = [for (final f in kanon.figuren) f['id'] as String];
  final kanten = <Map<String, Object?>>[
    {'a': 'ahmet', 'b': 'leyla', 'art': 'familie', 'sichtbar': 'oeffentlich', 'text': 'Cousine und Cousin, zusammen aufgewachsen'},
    {'a': 'fatma', 'b': 'emine', 'art': 'freundschaft', 'sichtbar': 'oeffentlich', 'text': 'beste Freundinnen seit der Schule'},
    {'a': 'can', 'b': 'zeynep', 'art': 'familie', 'sichtbar': 'oeffentlich', 'text': 'Geschwister, die sich oft necken'},
    {'a': 'olli', 'b': 'kaan', 'art': 'arbeit', 'sichtbar': 'heimlich', 'text': 'helfen sich gegenseitig beim Tragen'},
    {'a': 'johanna', 'b': 'ahmet', 'art': 'gefallen', 'sichtbar': 'heimlich', 'text': 'er hat sie um etwas gebeten'},
  ];
  for (var i = 0; i < reihe.length; i++) {
    kanten.add({'a': reihe[i], 'b': reihe[(i + 1) % reihe.length], 'art': 'freundschaft', 'sichtbar': 'oeffentlich', 'text': 'kennen sich aus der Clique'});
  }
  for (var i = 0; i < reihe.length; i += 2) {
    kanten.add({'a': 'schneider', 'b': reihe[i], 'art': 'arbeit', 'sichtbar': 'oeffentlich', 'text': 'kennt das Schloss von Besuchen'});
  }
  return kanten;
}

/// Eine gültige Erzählerakte aus figuren.json (Fixture): alle Größen und Netzregeln erfüllt.
Map<String, Object?> erzaehlerakteFixture() => {
      'format': erzaehlerakteFormat,
      'settingId': kanon.settingId,
      'hinweis': 'Nur für die Person, die erzählt (A-063). Pfadgleich; nie Täter, Pfad, Tatwissen, Tarnung, Fall-Code, Hinweisqualität.',
      'einleitung': 'Diese Akte gehört nur dir als Erzähler. Sie zeigt dir, wer wen kennt und wie die Gäste sprechen. Lies sie vor dem Abend in Ruhe.',
      'schneider': {
        'hintergrund': 'Herr Schneider ist der Verwalter des Schlosses. ${_fuelle('er', 'ihn', 8)} Er mag Ordnung und einen heißen Tee am Nachmittag.',
        'stimme': ['Brummt kurz, bevor er spricht.', 'Sagt gern: Ordnung muss sein.'],
      },
      'detektiv': {
        'hintergrund': 'Der Gast mit dem Hut kennt hier kaum jemanden. ${_fuelle('er', 'ihn', 4)}',
        'stimme': ['Fragt freundlich und genau nach.', 'Wiederholt gern den letzten Satz.'],
      },
      'figuren': [
        for (final f in kanon.figuren)
          () {
            final name = f['name'] as String;
            final (er, ihn) = f['geschlecht'] == 'w' ? ('sie', 'sie') : ('er', 'ihn');
            final alltag = f['alltag'] as String;
            return {
              'figur': f['id'],
              'hintergrund': '$name ist ${f['age']} Jahre alt. $name ${alltag[0].toLowerCase()}${alltag.substring(1)} ${_fuelle(er, ihn, 8)}',
              'zuSchneider': '$name grüßt Herrn Schneider höflich und hält sich an seine Regeln.',
              'stimme': ['Spricht ruhig und freundlich.', 'Lacht gern über eigene Witze.'],
            };
          }(),
      ],
      'netz': _netz(),
    };

/// Kanten der Fixture-Akte.
List<NetzKante> get fixtureNetz => Erzaehlerakte.ausJson(erzaehlerakteFixture(), kanon).netz;
