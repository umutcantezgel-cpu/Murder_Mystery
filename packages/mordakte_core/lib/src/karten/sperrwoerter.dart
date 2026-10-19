/// Sperrwörter für pfadgleiche Zusatztexte (Abstecher, Gerüchte): Sie nennen
/// weder Beweise noch Verdächtige noch Geheimnisse. Gemeinsame Quelle für
/// `bin/karten_pruefen.dart` und den Gerüchte-Prüfer.
library;

/// Wörter, die in pfadgleichen Zusatztexten nie vorkommen (Beweise,
/// Schlüsselbund, Kerzenständer, Alibis, Geheimnisse).
const spoilerWoerter = [
  'beweis', 'indiz', 'spur', 'alibi', 'täter', 'mörder', 'verdächtig', 'geheimnis', 'tatort', 'mordwaffe',
  'schlüssel', 'kerze', 'kerzenständer', 'wachs', 'kurzschluss', 'stromausfall', 'blackout', 'opfer', 'schneider',
];

/// Gegenstandsnamen, die zu allgemein sind, um sie in Zusatztexten zu sperren.
const allgemeineWoerter = {'breiter', 'linker', 'rechter', 'braunem', 'schwarze', 'schaden', 'bündel', 'turmgang', 'alte'};

final _buchstaben = RegExp(r'[\p{L}]+', unicode: true);

/// Trifft [wort] am Anfang eines Wortes (ohne Groß- und Kleinschreibung).
RegExp wortAnfang(String wort) => RegExp('(?<!\\p{L})${RegExp.escape(wort)}', unicode: true, caseSensitive: false);

/// Wörter ab sechs Buchstaben aus [name] (klein), ohne [allgemeineWoerter].
Iterable<String> kennwoerter(String name, {int mindestens = 6}) sync* {
  for (final m in _buchstaben.allMatches(name)) {
    final w = m.group(0)!.toLowerCase();
    if (w.length >= mindestens && !allgemeineWoerter.contains(w)) yield w;
  }
}

/// Teile eines Namens für den Vergleich mit ganzen Wörtern: jedes Wort ab
/// [mindestens] Buchstaben (klein, ohne [allgemeineWoerter] und [ohne]) und
/// jeder vordere und hintere Teil davon ab [mindestens] Buchstaben, der
/// mindestens drei Buchstaben übrig lässt. So stecken in „Brottasche“ brot und
/// tasche, in „Silberring“ silber und ring. Ohne Wörterbuch fallen auch
/// Bruchstücke an (brott, asche); darum nur mit ganzen Wörtern vergleichen
/// ([wortformen]), nie mit Wortanfängen.
Iterable<String> teilwoerter(String name, {int mindestens = 4, Set<String> ohne = const {}}) sync* {
  for (final m in _buchstaben.allMatches(name)) {
    final w = m.group(0)!.toLowerCase();
    if (w.length < mindestens || allgemeineWoerter.contains(w) || ohne.contains(w)) continue;
    yield w;
    for (var i = mindestens; i <= w.length - 3; i++) {
      yield w.substring(0, i);
    }
    for (var i = 3; i <= w.length - mindestens; i++) {
      yield w.substring(i);
    }
  }
}

/// Endungen, die [wortformen] abstreift: Mehrzahl und Fälle der Hauptwörter.
const _endungen = ['en', 'es', 'e', 'n', 's'];

/// [wort] klein, dazu ohne Endung (Laternen → laterne, Handys → handy); jede
/// Form behält mindestens drei Buchstaben.
List<String> wortformen(String wort) {
  final w = wort.toLowerCase();
  return [
    w,
    for (final e in _endungen)
      if (w.length - e.length >= 3 && w.endsWith(e)) w.substring(0, w.length - e.length),
  ];
}

/// Sperrregeln einer Akte: die [spoilerWoerter], Gegenstandsnamen
/// ([gegenstaende], `gegenstaende.json`) und die Namen und Kennungen aller
/// Figuren außer dem Detektiv ([figuren], `figuren.json`).
List<RegExp> sperrregeln(Map<String, Object?> figuren, Map<String, Object?> gegenstaende) {
  final woerter = <String>{...spoilerWoerter};
  for (final g in gegenstaende['gegenstaende'] as List) {
    woerter.addAll(kennwoerter((g as Map)['name'] as String));
  }
  final regeln = [for (final w in woerter) wortAnfang(w)];
  final namen = <String>{
    for (final x in [...(figuren['figuren'] as List), figuren['detektiv'] as Map, figuren['opfer'] as Map])
      if ((x as Map)['id'] != 'detective') (x['name'] as String? ?? x['id'] as String).toLowerCase(),
    for (final x in figuren['figuren'] as List) (x as Map)['id'] as String,
  };
  return [
    ...regeln,
    for (final n in namen) RegExp('(?<!\\p{L})${RegExp.escape(n)}(?!\\p{L})', unicode: true, caseSensitive: false),
  ];
}
