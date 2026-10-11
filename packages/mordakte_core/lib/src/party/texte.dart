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

class Gespraech {
  final String id, rolle, partner, thema, ziel, text;
  final int runde, nr;
  final List<String> preisgabe;
  Gespraech(Map j)
      : id = j['id'] as String,
        rolle = j['rolle'] as String,
        runde = j['runde'] as int,
        nr = j['nr'] as int,
        partner = j['partner'] as String,
        thema = j['thema'] as String,
        ziel = j['ziel'] as String,
        text = j['text'] as String,
        preisgabe = [for (final p in j['preisgabe'] as List) p as String];
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
  /// unveränderten Schlosskeller-Sammlung. Neue Akten liefern nur, was bei
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
  for (final g in t.gespraeche) {
    if (g.id != 'g_${g.rolle}_${g.runde}_${g.nr}') f.add('Gespräch ${g.id}: Kennung passt nicht zu Rolle, Runde, Nummer');
    if (!figuren.contains(g.rolle)) f.add('Gespräch ${g.id}: unbekannte Rolle');
    if (g.partner == g.rolle) f.add('Gespräch ${g.id}: Partner ist die Rolle selbst');
    if (!figuren.contains(g.partner) && g.partner != Besetzung.detektiv) f.add('Gespräch ${g.id}: unbekannter Partner ${g.partner}');
    // P-2: Ein Partner, der ersetzt werden kann, steht nicht im Text; die App nennt ihn auf der Karte.
    final name = namen[g.partner];
    if (name != null && !kern.contains(g.partner) && RegExp('(^|[^\\p{L}])$name(\$|[^\\p{L}])', unicode: true).hasMatch('${g.thema} ${g.ziel} ${g.text}')) {
      f.add('Gespräch ${g.id}: nennt den Partner $name, der ersetzt werden kann (P-2)');
    }
    // P-1: am Tisch nur Pflichtgespräch-Beobachtungen der Rolle und behauptete Fassungen ihrer Lügen.
    for (final p in g.preisgabe) {
      if (!texte.bekannt(p)) {
        f.add('Gespräch ${g.id}: unbekannter Verweis $p');
      } else if (p.startsWith('beobachtung:')) {
        final b = texte.beobachtung(p.substring(12))!;
        if (b['kanal'] != 'pflichtgespraech') f.add('Gespräch ${g.id}: $p ist nicht für den Tisch (Kanal ${b['kanal']})');
        if (b['wer'] != g.rolle) f.add('Gespräch ${g.id}: $p gehört nicht zu ${g.rolle}');
      } else if (p.startsWith('luege:')) {
        if (texte.luege(p.substring(6))!['person'] != g.rolle) f.add('Gespräch ${g.id}: $p ist nicht die Lüge von ${g.rolle}');
      } else {
        f.add('Gespräch ${g.id}: $p ist am Tisch nicht erlaubt (nur Beobachtungen und Lügen)');
      }
    }
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
  for (final k in Erzaehler(kanon).katalog()) {
    if (!t.bausteine.containsKey(k)) f.add('Erzähler-Baustein $k fehlt');
  }
  for (final x in kanon.figuren) {
    final r = x['id'] as String;
    if (!t.dossiers.containsKey(r)) f.add('Dossier $r fehlt');
    for (var runde = 1; runde <= 3; runde++) {
      final n = t.gespraeche.where((g) => g.rolle == r && g.runde == runde).length;
      if (n != 3) f.add('Rolle $r, Runde $runde: $n statt 3 Pflichtgespräche');
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
