import 'besetzung.dart';
import 'erzaehler.dart';
import 'kanon/kanon.dart';
import 'spuren.dart';

/// Ein Punkt in einem Dossier: eigener Text oder Verweis auf eine Kanon-Tatsache.
class TextPunkt {
  final String? text;
  final String? ref;
  const TextPunkt({this.text, this.ref});
  factory TextPunkt.fromJson(Map j) => TextPunkt(text: j['text'] as String?, ref: j['ref'] as String?);
}

List<TextPunkt> _punkte(Object? l) => [for (final p in (l as List? ?? const [])) TextPunkt.fromJson(p as Map)];

class DossierRoh {
  final String rolle, wer, ziel, besetzung;
  final List<TextPunkt> weiss, verbirgt;
  DossierRoh(Map j)
      : rolle = j['rolle'] as String,
        wer = j['wer'] as String,
        ziel = j['ziel'] as String,
        besetzung = j['besetzung'] as String,
        weiss = _punkte(j['weiss']),
        verbirgt = _punkte(j['verbirgt']);
}

class TaeterRoh {
  final String rolle, tarnung, ziel;
  final List<TextPunkt> tatwissen, verbirgt;
  TaeterRoh(Map j)
      : rolle = j['rolle'] as String,
        tarnung = j['tarnung'] as String,
        ziel = j['ziel'] as String,
        tatwissen = _punkte(j['tatwissen']),
        verbirgt = _punkte(j['verbirgt']);
}

List<String> _texte(Object? l) => [for (final x in (l as List? ?? const [])) x as String];

class Gespraech {
  final String id, rolle, partner, thema, ziel;

  /// Eröffnungssatz (Modell legacy); im Modell befragung leer.
  final String text;
  final int runde, nr;
  final List<String> preisgabe;

  /// Stichpunkte statt Eröffnungssatz (Modell befragung, Kartenformat R17):
  /// höchstens drei kurze Zeilen in der Ich- und Du-Form; sonst leer.
  final List<String> stichpunkte;
  Gespraech(Map j)
      : id = j['id'] as String,
        rolle = j['rolle'] as String,
        runde = j['runde'] as int,
        nr = j['nr'] as int,
        partner = j['partner'] as String,
        thema = j['thema'] as String,
        ziel = j['ziel'] as String,
        text = (j['text'] as String?) ?? '',
        preisgabe = _texte(j['preisgabe']),
        stichpunkte = _texte(j['stichpunkte']);
}

/// Befragung einer Rolle durch den Detektiv in einer Runde (A-051, Modell
/// befragung). Der Detektiv sieht [thema] und [fragen], nie die Antwort. Was
/// die Rolle sagt, steht nur als Verweis in [preisgabe] (eigene Beobachtungen
/// mit Kanal `pflichtgespraech`, Behauptungen eigener Lügen) und hängt nie von
/// der gewählten Frage ab. [stichpunkte] sind eigene Würze der befragten Rolle
/// für ihre Spielerin, ohne neue Tatsache.
class BefragungText {
  final String id, rolle, thema;
  final int runde;
  final List<String> fragen, stichpunkte, preisgabe;
  BefragungText(Map j)
      : id = j['id'] as String,
        rolle = j['rolle'] as String,
        runde = j['runde'] as int,
        thema = j['thema'] as String,
        fragen = _texte(j['fragen']),
        stichpunkte = _texte(j['stichpunkte']),
        preisgabe = _texte(j['preisgabe']);

  /// Kennung der Befragung von [rolle] in [runde].
  static String kennung(String rolle, int runde) => 'bf_${rolle}_$runde';
}

/// Kurzfassung einer Befragungs-Preisgabe (E-044, Kartenformat R17): eine
/// Karte mit ein bis drei Stichpunkten zu je höchstens acht Wörtern statt des
/// Kanon-Wortlauts. [antwort] zeigt die App dem Detektiv (Beobachtung in der
/// dritten Person, Lüge nur als Behauptung in der Ich-Form), [du] steht auf dem
/// Spickzettel der befragten Rolle; ohne [du] gilt [antwort]. Die Langfassung
/// bleibt in Beobachtung und Lüge, die Kurzfassung ändert keine Tatsache.
class Kurzfassung {
  final String quelle;
  final List<String> antwort;
  final List<String>? du;
  Kurzfassung(Map j)
      : quelle = j['quelle'] as String,
        antwort = _texte(j['antwort']),
        du = j['du'] == null ? null : _texte(j['du']);

  /// Zeilen für den Spickzettel der Rolle.
  List<String> get zettel => du ?? antwort;
}

class WahlText {
  final String id, a, b;
  final String? sabotage;
  WahlText(Map j)
      : id = j['id'] as String,
        a = j['a'] as String,
        b = j['b'] as String,
        sabotage = j['sabotage'] as String?;
  const WahlText._(this.id, this.a, this.b, this.sabotage);

  /// Dieselbe Wahl ohne Sabotage: So sieht sie eine Kernrolle, die in diesem Pfad unschuldig ist.
  WahlText get ohneSabotage => WahlText._(id, a, b, null);
}

/// Die Textsammlung (E-026): alle Dateien aus `texte/index.json`, je Bereich
/// zusammengeführt. Jede Kennung kommt genau einmal vor.
class Textsammlung {
  final Map<String, Map<String, Object?>> dateien;
  final Map<String, String> bausteine = {};
  final Map<String, String> herkunft = {};
  final Map<String, DossierRoh> dossiers = {};
  final Map<String, TaeterRoh> taeter = {};
  final List<Gespraech> gespraeche = [];
  final Map<String, BefragungText> befragungen = {};

  /// Kurzfassungen der Befragungs-Preisgaben nach Verweis (`beobachtung:<id>`, `luege:<id>`).
  final Map<String, Kurzfassung> kurzfassungen = {};
  final Map<String, WahlText> wahlen = {};
  final List<String> doppelt = [];

  Textsammlung._(this.dateien) {
    // Bei doppelter Kennung gilt der erste Eintrag; die Doppelung wird gemeldet.
    bool merke(String id, String datei) {
      if (herkunft.containsKey(id)) {
        doppelt.add('$id in ${herkunft[id]} und $datei');
        return false;
      }
      herkunft[id] = datei;
      return true;
    }

    for (final d in dateien.entries) {
      for (final e in (d.value['eintraege'] as List? ?? const [])) {
        final m = e as Map;
        switch (d.value['bereich']) {
          case 'erzaehler' || 'detektiv' || 'ui':
            if (merke(m['id'] as String, d.key)) bausteine[m['id'] as String] = m['text'] as String;
          case 'dossier':
            if (merke('dossier.${m['rolle']}', d.key)) dossiers[m['rolle'] as String] = DossierRoh(m);
          case 'taeter':
            if (merke('taeter.${m['rolle']}', d.key)) taeter[m['rolle'] as String] = TaeterRoh(m);
          case 'gespraech':
            if (merke(m['id'] as String, d.key)) gespraeche.add(Gespraech(m));
          case 'befragung':
            if (merke(m['id'] as String, d.key)) befragungen[m['id'] as String] = BefragungText(m);
          case 'kurzfassung':
            if (merke('kurz.${m['quelle']}', d.key)) kurzfassungen[m['quelle'] as String] = Kurzfassung(m);
          case 'wahl':
            if (merke(m['id'] as String, d.key)) wahlen[m['id'] as String] = WahlText(m);
        }
      }
    }
  }

  /// Lädt `texte/index.json` und alle dort genannten Dateien.
  factory Textsammlung.lade(KanonLeser lies) {
    final index = lies('texte/index.json');
    return Textsammlung._({
      'texte/index.json': index,
      for (final d in index['dateien'] as List) 'texte/${(d as Map)['datei']}': lies('texte/${d['datei']}'),
    });
  }

  Map<String, Object?> get index => dateien['texte/index.json']!;

  /// Übernimmt fehlende Oberflächentexte (`ui.*`) aus [basis], der
  /// eingefrorenen Basis `content/party/basis-ui` (A-061). Neue Akten liefern nur, was bei
  /// ihnen anders heißt (z. B. ohne Geburtstagskind).
  void ergaenzeUi(Textsammlung basis) {
    for (final e in basis.bausteine.entries) {
      if (e.key.startsWith('ui.') && !bausteine.containsKey(e.key)) {
        bausteine[e.key] = e.value;
        herkunft[e.key] = 'basis:${basis.herkunft[e.key]}';
      }
    }
  }
}

/// Ein aufgelöster Dossierpunkt.
class DossierZeile {
  final String art;
  final String text;
  final String? behauptung;
  const DossierZeile(this.art, this.text, {this.behauptung});
}

/// Ein für Rolle, Pfad und Besetzung zusammengesetztes Dossier (Master 7.11).
class Dossier {
  final String rolle;
  final bool taeter;
  final String wer, ziel, besetzung;
  final String? tarnung;
  final List<DossierZeile> weiss, verbirgt, tatwissen;
  final Map<int, List<(Gespraech, String)>> gespraeche;

  /// Wer die Rolle am Tisch anspricht: je Runde Gespräch und Sprecher.
  final Map<int, List<(Gespraech, String)>> alsPartner;

  /// Je Runde die eigene Befragung durch den Detektiv (nur Modell befragung, sonst null).
  final Map<int, BefragungText?> befragungen;
  final Map<int, WahlText?> wahlen;
  const Dossier({
    required this.rolle,
    required this.taeter,
    required this.wer,
    required this.ziel,
    required this.besetzung,
    required this.tarnung,
    required this.weiss,
    required this.verbirgt,
    required this.tatwissen,
    required this.gespraeche,
    required this.alsPartner,
    required this.befragungen,
    required this.wahlen,
  });
}

/// Setzt Texte und Kanon zusammen: Verweise werden je Pfad aufgelöst, das
/// Dossier einer Kernrolle ist im eigenen Pfad die Täterfassung.
class Texte {
  final Kanon kanon;
  final Textsammlung sammlung;
  final SpurRechner spuren;
  final Besetzung besetzung;
  late final Map<String, Map<String, Object?>> _beob = {for (final b in kanon.beobachtungen) b['id'] as String: b};
  late final Map<String, Map<String, Object?>> _zeit = {for (final z in kanon.zeitleiste) z['id'] as String: z};
  late final Map<String, Map<String, Object?>> _luegen = {
    for (final f in kanon.figuren)
      for (final l in (f['luegen'] as List? ?? const [])) (l as Map)['id'] as String: {...l.cast<String, Object?>(), 'person': f['id']},
  };
  late final Map<String, Map<String, Object?>> _nebendelikte = {
    for (final n in (kanon.gegenstaendeJson['nebendelikte'] as List? ?? const [])) (n as Map)['id'] as String: n.cast<String, Object?>(),
  };
  late final Map<String, Map<String, Object?>> _spuren = {
    for (final g in kanon.gegenstaende)
      for (final s in (g['spuren'] as List? ?? const [])) (s as Map)['id'] as String: s.cast<String, Object?>(),
  };

  Texte(this.kanon, this.sammlung, {SpurRechner? spuren})
      : spuren = spuren ?? SpurRechner(kanon),
        besetzung = Besetzung(kanon);

  /// Gibt es die Quelle des Verweises?
  bool bekannt(String ref) {
    final (art, id) = _teile(ref);
    return switch (art) {
      'beobachtung' => _beob.containsKey(id),
      'luege' => _luegen.containsKey(id),
      'nebendelikt' => _nebendelikte.containsKey(id),
      'zeitleiste' => _zeit.containsKey(id),
      'spur' => _spuren.containsKey(id),
      _ => false,
    };
  }

  Map<String, Object?>? beobachtung(String id) => _beob[id];
  Map<String, Object?>? luege(String id) => _luegen[id];

  /// Kurzfassung einer Befragungs-Preisgabe (E-044), sonst null.
  Kurzfassung? kurzfassung(String quelle) => sammlung.kurzfassungen[quelle];

  late final Map<String, String> _hinweise = {
    for (final h in kanon.bonusJson['hinweise'] as List) (h as Map)['id'] as String: h['text'] as String,
  };

  /// Wortlaut eines Bausteins (Erzähler, Oberfläche, Hinweis). Hinweise
  /// (`hinweis.<id>`) stehen in `bonus.json`, alles andere in der Textsammlung.
  /// Unbekannte Kennungen sind ein Fehler: Die App erzeugt keinen Text (F-11).
  String baustein(String kennung) {
    if (kennung.startsWith('hinweis.')) {
      return _hinweise[kennung.substring('hinweis.'.length)] ?? (throw ArgumentError('unbekannter Hinweis $kennung'));
    }
    return sammlung.bausteine[kennung] ?? (throw ArgumentError('unbekannter Baustein $kennung'));
  }

  (String, String) _teile(String ref) {
    final i = ref.indexOf(':');
    return (ref.substring(0, i), ref.substring(i + 1));
  }

  /// Text eines Verweises in [pfad]; null, wenn es die Tatsache dort nicht gibt.
  DossierZeile? aufloesen(String ref, String pfad) {
    final (art, id) = _teile(ref);
    switch (art) {
      case 'beobachtung':
        final b = _beob[id]!;
        // Im Dossier spricht die Beobachtung die eigene Rolle mit „du“ an (E-032).
        return Kanon.giltIn(b['pfade'], pfad) ? DossierZeile(art, (b['duText'] ?? b['text']) as String) : null;
      case 'luege':
        final l = _luegen[id]!;
        // Auch die Wahrheit einer Lüge spricht die Rolle mit „du“ an (E-036).
        return DossierZeile(art, (l['duWahrheit'] ?? l['wahrheit']) as String, behauptung: l['behauptung'] as String);
      case 'nebendelikt':
        final n = _nebendelikte[id]!;
        return DossierZeile(art, (n['duText'] ?? n['text']) as String);
      case 'zeitleiste':
        final z = _zeit[id]!;
        return Kanon.giltIn(z['pfade'], pfad) ? DossierZeile(art, z['text'] as String) : null;
      case 'spur':
        final s = _spuren[id]!;
        if (spuren.entsteht(s['entstehtWenn'] as Map, pfad)) return DossierZeile(art, s['zeigt'] as String);
        final h = s['harmlos'] as String?;
        return h == null ? null : DossierZeile(art, h);
    }
    return null;
  }

  List<DossierZeile> _liste(List<TextPunkt> punkte, String pfad) => [
        for (final p in punkte)
          if (p.text != null) DossierZeile('text', p.text!) else ?aufloesen(p.ref!, pfad),
      ];

  late final List<GespraechsWunsch> _wuensche = [
    for (final g in sammlung.gespraeche) (id: g.id, rolle: g.rolle, runde: g.runde, nr: g.nr, partner: g.partner),
  ];
  final Map<int, Map<String, String>> _plaene = {};

  /// Tatsächliche Partner aller Pflichtgespräche bei [rollen] Rollen (E-028).
  Map<String, String> gespraechsplan(int rollen) => _plaene[rollen] ??= besetzung.gespraechsplan(_wuensche, rollen);

  /// Höchstlast verletzt bei irgendeiner Besetzung von 4 bis 20 (leer heißt grün).
  List<String> lastVerstoesse() => [
        for (var n = besetzung.minRollen; n <= besetzung.maxRollen; n++) ...besetzung.lastVerstoesse(_wuensche, gespraechsplan(n), n),
      ];

  /// Dossier von [rolle] in [pfad] bei [rollen] besetzten Rollen.
  Dossier dossier(String rolle, String pfad, int rollen) {
    final roh = sammlung.dossiers[rolle] ?? (throw StateError('kein Dossier für $rolle'));
    final t = rolle == pfad ? sammlung.taeter[rolle] : null;
    if (rolle == pfad && t == null) throw StateError('keine Täterfassung für $rolle');
    final gespraeche = <int, List<(Gespraech, String)>>{};
    final plan = gespraechsplan(rollen);
    for (final g in sammlung.gespraeche.where((g) => g.rolle == rolle)) {
      (gespraeche[g.runde] ??= []).add((g, plan[g.id] ?? besetzung.partner(g.partner, rollen, sprecher: rolle)));
    }
    for (final l in gespraeche.values) {
      l.sort((a, b) => a.$1.nr.compareTo(b.$1.nr));
    }
    final alsPartner = <int, List<(Gespraech, String)>>{};
    for (final g in sammlung.gespraeche) {
      if (plan[g.id] == rolle) (alsPartner[g.runde] ??= []).add((g, g.rolle));
    }
    int platz(String r) => besetzung.reihenfolge.indexOf(r);
    for (final l in alsPartner.values) {
      l.sort((a, b) => platz(a.$2) != platz(b.$2) ? platz(a.$2) - platz(b.$2) : a.$1.nr - b.$1.nr);
    }
    return Dossier(
      rolle: rolle,
      taeter: t != null,
      wer: roh.wer,
      ziel: t?.ziel ?? roh.ziel,
      besetzung: roh.besetzung,
      tarnung: t?.tarnung,
      weiss: _liste(roh.weiss, pfad),
      verbirgt: _liste(t?.verbirgt ?? roh.verbirgt, pfad),
      tatwissen: t == null ? const [] : _liste(t.tatwissen, pfad),
      gespraeche: gespraeche,
      alsPartner: alsPartner,
      befragungen: {for (var r = 1; r <= 3; r++) r: sammlung.befragungen[BefragungText.kennung(rolle, r)]},
      // Die Sabotage sieht nur, wer in diesem Pfad die Tat begangen hat.
      wahlen: {for (var r = 1; r <= 3; r++) r: t != null ? sammlung.wahlen['gw_${rolle}_$r'] : sammlung.wahlen['gw_${rolle}_$r']?.ohneSabotage},
    );
  }
}

/// Querverweise und Regeln der Textsammlung (F-10, F-11). Leer heißt grün.
/// Prüft nur, was da ist; Vollständigkeit prüft [textLuecken].
List<String> textVerweise(Kanon kanon, Textsammlung t) {
  final f = <String>[...t.doppelt];
  final texte = Texte(kanon, t);
  final figuren = {for (final x in kanon.figuren) x['id'] as String};
  final kern = kanon.kernverdaechtige.toSet();
  final namen = {for (final x in kanon.figuren) x['id'] as String: x['name'] as String};
  final katalog = Erzaehler(kanon).katalog().toSet();
  final wahlIds = {for (final w in kanon.gruppenwahlJson['wahlen'] as List) (w as Map)['id'] as String};

  for (final d in t.index['dateien'] as List) {
    final m = d as Map;
    final j = t.dateien['texte/${m['datei']}']!;
    if (j['bereich'] != m['bereich']) f.add('texte/${m['datei']}: Bereich ${j['bereich']}, Index sagt ${m['bereich']}');
  }
  for (final d in t.dateien.entries) {
    if (d.key == 'texte/index.json') continue;
    final bereich = d.value['bereich'];
    for (final e in (d.value['eintraege'] as List? ?? const [])) {
      final id = (e as Map)['id'] as String?;
      if (bereich == 'erzaehler' && !katalog.contains(id)) f.add('${d.key}: $id gehört nicht zum Erzähler-Katalog');
      if (bereich == 'detektiv' && !(id!.startsWith('detektiv.') || id.startsWith('ermittlungsbogen.'))) f.add('${d.key}: $id ist kein Detektiv-Schlüssel');
      if (bereich == 'ui' && !id!.startsWith('ui.')) f.add('${d.key}: $id ist kein Oberflächen-Schlüssel');
    }
  }

  void punkte(String wo, String rolle, List<TextPunkt> l) {
    for (final p in l) {
      if (p.ref == null) continue;
      if (!texte.bekannt(p.ref!)) {
        f.add('$wo: unbekannter Verweis ${p.ref}');
        continue;
      }
      if (p.ref!.startsWith('beobachtung:') && texte.beobachtung(p.ref!.substring(12))!['wer'] != rolle) {
        f.add('$wo: ${p.ref} ist nicht die Beobachtung von $rolle');
      }
      if (p.ref!.startsWith('luege:') && texte.luege(p.ref!.substring(6))!['person'] != rolle) f.add('$wo: ${p.ref} ist nicht die Lüge von $rolle');
    }
  }

  for (final d in t.dossiers.values) {
    if (!figuren.contains(d.rolle)) f.add('Dossier ${d.rolle}: unbekannte Rolle');
    punkte('Dossier ${d.rolle}.weiss', d.rolle, d.weiss);
    punkte('Dossier ${d.rolle}.verbirgt', d.rolle, d.verbirgt);
  }
  for (final x in t.taeter.values) {
    if (!kern.contains(x.rolle)) f.add('Täterfassung ${x.rolle}: keine Kernrolle');
    punkte('Täterfassung ${x.rolle}.tatwissen', x.rolle, x.tatwissen);
    punkte('Täterfassung ${x.rolle}.verbirgt', x.rolle, x.verbirgt);
  }
  // P-1: am Tisch und in Befragungen nur Pflichtgespräch-Beobachtungen der Rolle und behauptete Fassungen ihrer Lügen.
  void preisgaben(String wo, String rolle, List<String> l) {
    for (final p in l) {
      if (!texte.bekannt(p)) {
        f.add('$wo: unbekannter Verweis $p');
      } else if (p.startsWith('beobachtung:')) {
        final b = texte.beobachtung(p.substring(12))!;
        if (b['kanal'] != 'pflichtgespraech') f.add('$wo: $p ist nicht für den Tisch (Kanal ${b['kanal']})');
        if (b['wer'] != rolle) f.add('$wo: $p gehört nicht zu $rolle');
      } else if (p.startsWith('luege:')) {
        if (texte.luege(p.substring(6))!['person'] != rolle) f.add('$wo: $p ist nicht die Lüge von $rolle');
      } else {
        f.add('$wo: $p ist am Tisch nicht erlaubt (nur Beobachtungen und Lügen)');
      }
    }
  }

  // Kartenformat R17: höchstens [hoechstens] Stichpunkte zu je höchstens acht Wörtern.
  void karte(String wo, List<String> l, {required int mindestens, required int hoechstens}) {
    if (l.length < mindestens || l.length > hoechstens) f.add('$wo: ${l.length} Stichpunkte statt $mindestens bis $hoechstens (R17)');
    for (final x in l) {
      if (stichpunktWoerter(x) > 8) f.add('$wo: Stichpunkt mit ${stichpunktWoerter(x)} Wörtern statt höchstens 8 (R17): $x');
    }
  }

  final besetzung = texte.besetzung;
  final glieder = besetzung.befragungsmodell ? tischKettenglieder(kanon) : const <String, int>{};
  for (final g in t.gespraeche) {
    final wo = 'Gespräch ${g.id}';
    if (g.id != 'g_${g.rolle}_${g.runde}_${g.nr}') f.add('$wo: Kennung passt nicht zu Rolle, Runde, Nummer');
    if (!figuren.contains(g.rolle)) f.add('$wo: unbekannte Rolle');
    if (g.partner == g.rolle) f.add('$wo: Partner ist die Rolle selbst');
    if (!figuren.contains(g.partner) && g.partner != Besetzung.detektiv) f.add('$wo: unbekannter Partner ${g.partner}');
    // P-2: Ein Partner, der ersetzt werden kann, steht nicht im Text; die App nennt ihn auf der Karte.
    final name = namen[g.partner];
    if (name != null && !kern.contains(g.partner) && RegExp('(^|[^\\p{L}])$name(\$|[^\\p{L}])', unicode: true).hasMatch('${g.thema} ${g.ziel} ${g.text} ${g.stichpunkte.join(' ')}')) {
      f.add('$wo: nennt den Partner $name, der ersetzt werden kann (P-2)');
    }
    preisgaben(wo, g.rolle, g.preisgabe);
    if (besetzung.befragungsmodell) {
      // Modell befragung (A-051): Stichpunkte statt Prosa, der Detektiv sitzt nicht am Tisch,
      // Kettenglieder erfährt er nur in seinen Befragungen.
      if (g.partner == Besetzung.detektiv) f.add('$wo: der Detektiv ist kein Tischpartner (Modell befragung)');
      if (g.nr < 1 || g.nr > besetzung.tischJeRolle) f.add('$wo: Nummer ${g.nr}, das Modell kennt ${besetzung.tischJeRolle} Tischgespräch je Runde');
      if (g.text.isNotEmpty) f.add('$wo: Prosa statt Stichpunkte (Modell befragung)');
      karte(wo, g.stichpunkte, mindestens: 2, hoechstens: 3);
      for (final p in g.preisgabe) {
        if (glieder.containsKey(p)) f.add('$wo: $p ist ein Kettenglied und gehört in die Befragung');
      }
    } else if (g.text.isEmpty) {
      f.add('$wo: Eröffnungssatz fehlt (Modell legacy)');
    }
  }
  for (final b in t.befragungen.values) {
    final wo = 'Befragung ${b.id}';
    if (!besetzung.befragungsmodell) f.add('$wo: Befragungen gibt es nur im Modell befragung');
    if (b.id != BefragungText.kennung(b.rolle, b.runde)) f.add('$wo: Kennung passt nicht zu Rolle und Runde');
    if (!figuren.contains(b.rolle)) f.add('$wo: unbekannte Rolle');
    if (b.runde < 1 || b.runde > 3) f.add('$wo: Runde ${b.runde}');
    if (b.fragen.length < 2 || b.fragen.length > 3) f.add('$wo: ${b.fragen.length} Fragen statt 2 bis 3');
    for (final q in b.fragen) {
      if (!q.trimRight().endsWith('?')) f.add('$wo: Frage ohne Fragezeichen: $q');
      if (stichpunktWoerter(q) > 12) f.add('$wo: Frage mit ${stichpunktWoerter(q)} Wörtern statt höchstens 12: $q');
    }
    karte(wo, b.stichpunkte, mindestens: 0, hoechstens: 2);
    preisgaben(wo, b.rolle, b.preisgabe);
  }
  // Kurzfassungen (E-044): nur für öffentliche Preisgaben einer Befragung, je eine Karte nach R17.
  final preisgegeben = {for (final b in t.befragungen.values) ...b.preisgabe};
  for (final k in t.kurzfassungen.values) {
    final wo = 'Kurzfassung ${k.quelle}';
    if (!besetzung.befragungsmodell) f.add('$wo: Kurzfassungen gibt es nur im Modell befragung');
    if (!texte.bekannt(k.quelle)) {
      f.add('$wo: unbekannter Verweis');
      continue;
    }
    if (!preisgegeben.contains(k.quelle)) f.add('$wo: keine Befragung gibt das preis');
    if (k.quelle.startsWith('beobachtung:')) {
      final b = texte.beobachtung(k.quelle.substring(12))!;
      if (b['kanal'] != 'pflichtgespraech' || b['pfade'] != 'alle') f.add('$wo: nicht öffentlich (Kanal ${b['kanal']}, Pfade ${b['pfade']})');
    } else if (k.quelle.startsWith('luege:')) {
      if (k.du != null) f.add('$wo: eine Lüge hat nur die Behauptung, kein du');
    } else {
      f.add('$wo: nur Beobachtungen und Lügen');
    }
    karte('$wo, antwort', k.antwort, mindestens: 1, hoechstens: 3);
    if (k.du != null) karte('$wo, du', k.du!, mindestens: 1, hoechstens: 3);
  }
  for (final w in t.wahlen.values) {
    if (!wahlIds.contains(w.id)) f.add('Wahl ${w.id}: keine Gruppenwahl mit dieser Kennung');
    final rolle = w.id.substring(3, w.id.lastIndexOf('_'));
    if (w.sabotage != null && !kern.contains(rolle)) f.add('Wahl ${w.id}: Sabotage nur bei Kernrollen');
  }
  return f;
}

/// Was der Textsammlung zur Vollständigkeit noch fehlt (Tor F3).
List<String> textLuecken(Kanon kanon, Textsammlung t) {
  final f = <String>[];
  final besetzung = Besetzung(kanon);
  for (final k in Erzaehler(kanon).katalog()) {
    if (!t.bausteine.containsKey(k)) f.add('Erzähler-Baustein $k fehlt');
  }
  for (final x in kanon.figuren) {
    final r = x['id'] as String;
    if (!t.dossiers.containsKey(r)) f.add('Dossier $r fehlt');
    for (var runde = 1; runde <= 3; runde++) {
      final n = t.gespraeche.where((g) => g.rolle == r && g.runde == runde).length;
      if (besetzung.befragungsmodell) {
        if (n != besetzung.tischJeRolle) f.add('Rolle $r, Runde $runde: $n statt ${besetzung.tischJeRolle} Tischgespräche');
        final b = t.befragungen[BefragungText.kennung(r, runde)];
        if (b == null) f.add('Befragung ${BefragungText.kennung(r, runde)} fehlt');
        for (final q in b?.preisgabe ?? const <String>[]) {
          if (!t.kurzfassungen.containsKey(q)) f.add('Kurzfassung $q fehlt (${b!.id})');
        }
      } else if (n != 3) {
        f.add('Rolle $r, Runde $runde: $n statt 3 Pflichtgespräche');
      }
      final w = t.wahlen['gw_${r}_$runde'];
      if (w == null) f.add('Wahltext gw_${r}_$runde fehlt');
      // Sabotieren kann nur, wer in einem Pfad Täter ist (Akten mit fester Lösung: eine Rolle).
      if (kanon.kernverdaechtige.contains(r) && kanon.pfade.contains(r) && w?.sabotage == null) f.add('Sabotage-Text gw_${r}_$runde fehlt');
    }
  }
  for (final p in kanon.pfade) {
    if (!t.taeter.containsKey(p)) f.add('Täterfassung $p fehlt');
  }
  for (final g in ['m', 'w']) {
    if (!t.bausteine.keys.any((k) => k.startsWith('detektiv.$g.'))) f.add('Detektiv-Bogen $g fehlt');
  }
  return f;
}

final _wortRe = RegExp(r'[\p{L}\p{N}]+(?:-[\p{L}\p{N}]+)*', unicode: true);

/// Wörter einer Stichpunktzeile oder Frage (wie der Textprüfer: Bindestrich verbindet).
int stichpunktWoerter(String s) => _wortRe.allMatches(s).length;

/// Tisch-Kettenglieder (A-051): Verweise der Begründungsketten, die nur am Tisch
/// gesagt werden – Lügen und Beobachtungen mit Kanal `pflichtgespraech` –, je mit
/// der ersten Runde, in der eine Entscheidung sie braucht. Die Ketten aller Pfade
/// zählen, damit nichts den Pfad verrät (S-1).
Map<String, int> tischKettenglieder(Kanon kanon) {
  final beob = {for (final b in kanon.beobachtungen) b['id'] as String: b};
  final aus = <String, int>{};
  for (final e in kanon.entscheidungenJson['entscheidungen'] as List) {
    final runde = (e as Map)['runde'] as int;
    for (final b in (e['begruendung'] as Map).values) {
      for (final k in (b as Map)['kette'] as List) {
        final ref = k as String;
        final tisch = ref.startsWith('luege:') ||
            (ref.startsWith('beobachtung:') && beob[ref.substring('beobachtung:'.length)]?['kanal'] == 'pflichtgespraech');
        if (tisch && (aus[ref] == null || runde < aus[ref]!)) aus[ref] = runde;
      }
    }
  }
  return aus;
}
