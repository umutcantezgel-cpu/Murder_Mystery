// Einstimmung (Finale Schlosskeller, A-063, SPEZIFIKATION §1): Vorgeschichte und
// Vorstellung zwischen Rollen und Intro. Ein Unterzustand der Einleitung
// (`PartyPhase.intro`, wie der Rundgang), keine eigene Phase; die Texte gehen nie
// in `spiel.bausteine`. Pfadfrei: Die Schritte hängen nur an Rollenzahl und
// Detektiv. Nur Akten mit `setting.vorgeschichte` haben eine Einstimmung. Reines
// Dart ohne dart:io.
import '../karten/sperrwoerter.dart';
import '../welt/vorspiel_morgen.dart' show VorspielMorgen, urteilsWoerter;
import 'besetzung.dart';
import 'erzaehlerakte.dart' show NetzKante, namensMuster;
import 'kanon/kanon.dart';
import 'pfadwissen.dart';
import 'steckbriefe.dart';
import 'texte.dart';
import 'textpruefer.dart';
import 'zeit.dart';

/// Größen (SPEZIFIKATION §1): Teile der Vorgeschichte, Wörter je Teil und
/// gesamt, Wörter je Vorstellung (Figur und Detektiv), höchstens für
/// `vorstellung.start` und `vorstellung.npc`, Wörter eines Kapiteltitels.
const vorgeschichteTeileMin = 6,
    vorgeschichteTeileMax = 8,
    vorgeschichteWorteMin = 70,
    vorgeschichteWorteMax = 120,
    vorgeschichteGesamtMin = 600,
    vorgeschichteGesamtMax = 750,
    vorstellungWorteMin = 40,
    vorstellungWorteMax = 70,
    vorstellungKurzWorte = 35,
    einstimmungTitelWorte = 4;

/// Teil der Einstimmung.
enum EinstimmungTeil { vorgeschichte, vorstellung }

/// Ein Schritt der Einstimmung: ein Baustein, den der Vorleser wortgleich liest.
class EinstimmungSchritt {
  const EinstimmungSchritt({required this.teil, required this.kennung, this.figur, required this.nr, required this.von});

  final EinstimmungTeil teil;

  /// Baustein im Bereich `erzaehler` (`vorgeschichte.<teil>`, `vorstellung.*`).
  final String kennung;

  /// Vorgestellte Figur, beim Detektiv [Besetzung.detektiv]; sonst `null`.
  final String? figur;

  /// Nummer im Teil (ab 1) und Zahl der Schritte des Teils („Vorgeschichte · 3 von 7“).
  final int nr, von;

  /// Kapiteltitel (nicht vorgelesen), nur in der Vorgeschichte.
  String? get titel => teil == EinstimmungTeil.vorgeschichte ? Einstimmung.titelKennung(kennung.substring('vorgeschichte.'.length)) : null;

  Map<String, Object?> toJson() => {'teil': teil.name, 'kennung': kennung, 'figur': ?figur, 'nr': nr, 'von': von};

  @override
  bool operator ==(Object other) =>
      other is EinstimmungSchritt && other.teil == teil && other.kennung == kennung && other.figur == figur && other.nr == nr && other.von == von;

  @override
  int get hashCode => Object.hash(teil, kennung, figur, nr, von);

  @override
  String toString() => 'EinstimmungSchritt(${teil.name} $nr/$von $kennung${figur == null ? '' : ' $figur'})';
}

/// Die Einstimmung einer Akte: Teile der Vorgeschichte aus `setting.vorgeschichte`,
/// danach (mit `setting.vorstellung`) die Vorstellung der besetzten Figuren.
class Einstimmung {
  Einstimmung._(this.kanon, this.teile, this.vorstellung) : besetzung = Besetzung(kanon);

  /// Einstimmung von [kanon]; `null`, wenn die Akte keine Vorgeschichte hat.
  static Einstimmung? aus(Kanon kanon) => switch (kanon.vorgeschichte) {
        final teile? => Einstimmung._(kanon, List.unmodifiable(teile), kanon.vorstellung),
        null => null,
      };

  final Kanon kanon;
  final Besetzung besetzung;

  /// Teile der Vorgeschichte in Lesereihenfolge.
  final List<String> teile;

  /// Folgt die Vorstellungsrunde?
  final bool vorstellung;

  static const start = 'vorstellung.start', npc = 'vorstellung.npc';
  static String teilKennung(String teil) => 'vorgeschichte.$teil';
  static String figurKennung(String figur) => 'vorstellung.$figur';
  static String detektivKennung(String g) => 'vorstellung.detektiv.$g';
  static String titelKennung(String teil) => 'ui.einstimmung.titel.$teil';

  /// Schritte eines Abends mit [rollen] Rollen und Detektiv [detektiv] (`m`
  /// oder `w`): alle Blöcke der Vorgeschichte, dann `vorstellung.start`, die
  /// besetzten Figuren in Besetzungsreihenfolge, `vorstellung.npc` für
  /// unbesetzte Gäste (nur wenn es welche gibt) und der Detektiv.
  List<EinstimmungSchritt> schritte({required int rollen, required String detektiv}) {
    if (detektiv != 'm' && detektiv != 'w') throw ArgumentError.value(detektiv, 'detektiv', 'm oder w');
    final besetzt = besetzung.besetzt(rollen);
    final vor = [
      for (final (i, t) in teile.indexed) EinstimmungSchritt(teil: EinstimmungTeil.vorgeschichte, kennung: teilKennung(t), nr: i + 1, von: teile.length),
    ];
    if (!vorstellung) return vor;
    final reihe = <(String, String?)>[
      (start, null),
      for (final f in besetzt) (figurKennung(f), f),
      if (besetzung.npc(rollen).isNotEmpty) (npc, null),
      (detektivKennung(detektiv), Besetzung.detektiv),
    ];
    return [
      ...vor,
      for (final (i, (k, f)) in reihe.indexed) EinstimmungSchritt(teil: EinstimmungTeil.vorstellung, kennung: k, figur: f, nr: i + 1, von: reihe.length),
    ];
  }

  /// Alle Bausteine, die eine Einstimmung je liest (Erzähler-Katalog).
  List<String> katalog() => [
        for (final t in teile) teilKennung(t),
        if (vorstellung) ...[
          start,
          for (final f in besetzung.reihenfolge) figurKennung(f),
          npc,
          detektivKennung('m'),
          detektivKennung('w'),
        ],
      ];

  /// Kapiteltitel der Vorgeschichte (Oberfläche, nicht vorgelesen).
  List<String> titel() => [for (final t in teile) titelKennung(t)];
}

/// Gemeinsame Zustandsmaschine der Einstimmung (App, Raum, Replay): Schritt für
/// Schritt durch [schritte], ein Teil lässt sich überspringen.
class EinstimmungLauf {
  EinstimmungLauf(Iterable<EinstimmungSchritt> schritte, {int schritt = 0})
      : schritte = List.unmodifiable(schritte),
        _schritt = 0 {
    _schritt = schritt.clamp(0, this.schritte.length);
  }

  final List<EinstimmungSchritt> schritte;
  int _schritt;

  /// Nummer des laufenden Schritts (ab 0); nach dem letzten gleich der Zahl der Schritte.
  int get schritt => _schritt;

  bool get fertig => _schritt >= schritte.length;

  /// Laufender Schritt; `null`, wenn die Einstimmung fertig ist.
  EinstimmungSchritt? get aktuell => fertig ? null : schritte[_schritt];

  /// Weiter vom Schritt [von] zum nächsten. Nur, wenn [von] der laufende
  /// Schritt ist: Ein doppelter Tipp überspringt nichts (sonst `false`).
  bool weiter(int von) {
    if (fertig || von != _schritt) return false;
    _schritt++;
    return true;
  }

  /// Überspringt den Rest des laufenden Teils: aus der Vorgeschichte zur
  /// Vorstellung, aus der Vorstellung ans Ende. `false`, wenn schon fertig.
  bool ueberspringen() {
    final teil = aktuell?.teil;
    if (teil == null) return false;
    while (!fertig && schritte[_schritt].teil == teil) {
      _schritt++;
    }
    return true;
  }
}

final _ziffer = RegExp(r'\p{N}', unicode: true);
final _wortRe = RegExp(r'[\p{L}]+(?:-[\p{L}]+)*', unicode: true);

/// Ein Wort, das mit [anfang] beginnt (ohne Groß- und Kleinschreibung), ganz.
RegExp _anfang(String anfang) => RegExp('(?<!\\p{L})${RegExp.escape(anfang)}\\p{L}*', unicode: true, caseSensitive: false);

/// Was die Vorgeschichte nie berührt (öffentliche Keller-Fassung, SPEZIFIKATION
/// §1): Wortteile irgendwo im Wort und Wortanfänge.
const _vorgeschichteTeile = ['geld', 'miet', 'münz', 'schatull', 'türschad', 'steckdos'];
const _vorgeschichteAnfaenge = ['gefallen', 'streich'];

/// Prüft die Einstimmung [e] mit den Texten [texte] (SPEZIFIKATION §1). Leer heißt grün.
/// - Größen: [vorgeschichteTeileMin]–[vorgeschichteTeileMax] Teile zu je
///   [vorgeschichteWorteMin]–[vorgeschichteWorteMax] Wörtern, gesamt
///   [vorgeschichteGesamtMin]–[vorgeschichteGesamtMax]; Vorstellung je Figur und
///   Detektiv [vorstellungWorteMin]–[vorstellungWorteMax], Start und Sammelblock
///   höchstens [vorstellungKurzWorte]; Kapiteltitel höchstens [einstimmungTitelWorte].
/// - Namen: Die Vorgeschichte nennt nur Figuren, die immer besetzt sind, und
///   Herrn Schneider, nie den Detektiv; jede der immer besetzten mindestens
///   einmal, die meistgenannte höchstens doppelt so oft wie die seltenste.
///   `vorstellung.start` nennt nur immer besetzte Figuren. `vorstellung.<f>`
///   nennt f und sonst nur Figuren mit kleinerem Besetzungsplatz, mit denen f
///   eine öffentliche Kante im Netz [netz] (Erzählerakte) hat; die Vorstellung
///   einer Kernfigur nennt keine andere Kernfigur („Änderungen“ 14).
///   Sammelblock und Detektiv nennen keine Figur. Herr Schneider ist immer erlaubt.
/// - Fünf-Wort-Regel: keine Folge aus den geheimen Feldern ([geheimeFelder]),
///   aus Dossiers, Täterfassungen, Finale und Auflösung ([steckbriefGeschuetzt])
///   oder aus Pfadwissen ([pfadwissenVerboten]), ausgenommen Folgen, die auch in
///   öffentlichen Texten stehen (Alltag und „Wer du bist“ der Figuren). Dazu
///   keine Folge aus der Zeitleiste ab 18:00, aus `intro.*` oder dem Vorspiel ([vorspiel]).
/// - Wörter: kein Spoilerwort ([spoilerWoerter] außer dem Namen des Opfers),
///   kein Kennwort eines Gegenstands, kein Urteilswort ([urteilsWoerter]), kein
///   Geburtstag, keine Ziffern; die Vorgeschichte ohne Geld, Miete, Gefallen,
///   Streich, Münzen, Schatulle, Türschaden, Steckdose.
/// - [ton]: Tonregeln wie alle Vorlesetexte, dazu der Mittelwert der Satzlängen je Teil.
List<String> pruefeEinstimmung(Einstimmung e, Texte texte, {List<NetzKante> netz = const [], Textpruefer? ton, VorspielMorgen? vorspiel}) {
  final f = <String>[];
  final kanon = texte.kanon;
  final b = e.besetzung;
  final platz = {for (final (i, r) in b.reihenfolge.indexed) r: i + 1};
  final immer = b.besetzt(b.minRollen);
  final kern = kanon.kernverdaechtige.toSet();
  final namen = {
    for (final x in kanon.figuren)
      x['id'] as String: [namensMuster(x['name'] as String), if (x['vollerName'] is String) namensMuster(x['vollerName'] as String)],
  };
  int nennungen(String figur, String text) => namen[figur]!.fold(0, (n, re) => n + re.allMatches(text).length);
  List<String> genannt(String text) => [for (final id in namen.keys) if (nennungen(id, text) > 0) id];
  String name(String figur) => kanon.figur(figur)!['name'] as String;

  // Texte der Einstimmung (Ort → Text), vorgelesen; Titel nur auf dem Bildschirm.
  final vorgeschichte = <String, String>{};
  final vorstellungen = <String, String>{};
  String? text(String k) {
    final t = texte.sammlung.bausteine[k];
    if (t == null || t.trim().isEmpty) {
      f.add('$k fehlt');
      return null;
    }
    return t;
  }

  void worte(String k, String t, {int min = 1, required int max}) {
    final n = stichpunktWoerter(t);
    if (n < min || n > max) f.add('$k: $n Wörter statt ${min <= 1 ? 'höchstens $max' : '$min bis $max'}');
  }

  // Größen
  if (e.teile.length < vorgeschichteTeileMin || e.teile.length > vorgeschichteTeileMax) {
    f.add('Vorgeschichte: ${e.teile.length} Teile statt $vorgeschichteTeileMin bis $vorgeschichteTeileMax');
  }
  var gesamt = 0;
  for (final t in e.teile) {
    final k = Einstimmung.teilKennung(t);
    final x = text(k);
    if (x != null) {
      vorgeschichte[k] = x;
      worte(k, x, min: vorgeschichteWorteMin, max: vorgeschichteWorteMax);
      gesamt += stichpunktWoerter(x);
    }
  }
  if (gesamt < vorgeschichteGesamtMin || gesamt > vorgeschichteGesamtMax) {
    f.add('Vorgeschichte: $gesamt Wörter statt $vorgeschichteGesamtMin bis $vorgeschichteGesamtMax');
  }
  final titel = <String, String>{};
  for (final k in e.titel()) {
    final x = texte.sammlung.bausteine[k];
    if (x == null || x.trim().isEmpty) {
      f.add('Kapiteltitel $k fehlt');
      continue;
    }
    titel[k] = x;
    worte(k, x, max: einstimmungTitelWorte);
  }
  if (e.vorstellung) {
    for (final k in e.katalog().where((k) => k.startsWith('vorstellung.'))) {
      final x = text(k);
      if (x == null) continue;
      vorstellungen[k] = x;
      if (k == Einstimmung.start || k == Einstimmung.npc) {
        worte(k, x, max: vorstellungKurzWorte);
      } else {
        worte(k, x, min: vorstellungWorteMin, max: vorstellungWorteMax);
      }
    }
  }

  // Namen
  final zaehler = {for (final id in immer) id: 0};
  for (final MapEntry(key: k, value: x) in vorgeschichte.entries) {
    for (final g in genannt(x)) {
      if (!zaehler.containsKey(g)) f.add('$k: nennt ${name(g)}, die Figur ist nicht immer besetzt');
    }
    for (final id in immer) {
      zaehler[id] = zaehler[id]! + nennungen(id, x);
    }
    final d = _anfang('detektiv').firstMatch(x);
    if (d != null) f.add('$k: nennt den Detektiv („${d.group(0)}“)');
  }
  if (vorgeschichte.isNotEmpty) {
    for (final MapEntry(key: id, value: n) in zaehler.entries) {
      if (n == 0) f.add('Vorgeschichte: nennt ${name(id)} nie');
    }
    final werte = zaehler.values.toList()..sort();
    if (werte.first > 0 && werte.last > 2 * werte.first) {
      f.add('Vorgeschichte: unausgewogen (${[for (final MapEntry(key: id, value: n) in zaehler.entries) '${name(id)} $n'].join(', ')}); '
          'die meistgenannte höchstens doppelt so oft wie die seltenste');
    }
  }
  for (final MapEntry(key: k, value: x) in vorstellungen.entries) {
    final teile = k.split('.');
    if (k == Einstimmung.start) {
      for (final g in genannt(x)) {
        if (!immer.contains(g)) f.add('$k: nennt ${name(g)}, die Figur ist nicht immer besetzt');
      }
    } else if (k == Einstimmung.npc || teile[1] == 'detektiv') {
      for (final g in genannt(x)) {
        f.add('$k: nennt ${name(g)}');
      }
    } else {
      final figur = teile[1];
      if (nennungen(figur, x) == 0) f.add('$k: nennt ${name(figur)} nicht');
      for (final g in genannt(x)) {
        if (g == figur) continue;
        if (kern.contains(figur) && kern.contains(g)) {
          f.add('$k: nennt ${name(g)}, die Vorstellung einer Kernfigur nennt keine andere Kernfigur');
        } else if (platz[g]! > platz[figur]!) {
          f.add('$k: nennt ${name(g)} (Platz ${platz[g]}), die vielleicht noch nicht vorgestellt ist');
        } else if (!netz.any((n) => n.verbindet(figur, g) && n.oeffentlich)) {
          f.add('$k: nennt ${name(g)}, das Paar $figur–$g ist keine öffentliche Kante');
        }
      }
    }
  }

  // Fünf-Wort-Regel
  final erlaubt = <String>{
    for (final x in kanon.figuren)
      if (x['alltag'] is String) ...fuenfWortFolgen(x['alltag'] as String),
    for (final d in texte.sammlung.dossiers.values) ...fuenfWortFolgen(d.wer),
  };
  final quelle = <String, String>{};
  void merke(String wo, String t, {bool ausnahme = false}) {
    for (final folge in fuenfWortFolgen(t)) {
      if (ausnahme && erlaubt.contains(folge)) continue;
      quelle.putIfAbsent(folge, () => wo);
    }
  }

  for (final x in {...geheimeFelder(kanon), ...steckbriefGeschuetzt(texte)}.entries) {
    merke(x.key, x.value, ausnahme: true);
  }
  for (final x in pfadwissenVerboten(kanon).entries) {
    if (!erlaubt.contains(x.key)) quelle.putIfAbsent(x.key, () => x.value);
  }
  final abend = Uhrzeit.parse('18:00');
  for (final z in kanon.zeitleiste) {
    if (z['zeit'] is String && Uhrzeit.istGueltig(z['zeit'] as String) && Uhrzeit.parse(z['zeit'] as String) >= abend) {
      merke('Zeitleiste ${z['id']}', z['text'] as String);
    }
  }
  for (final x in texte.sammlung.bausteine.entries) {
    if (x.key.startsWith('intro.')) merke(x.key, x.value);
  }
  for (final s in vorspiel?.vorspiel.stationen ?? const []) {
    for (final (id, t) in s.texte) {
      merke('Vorspiel $id', t.titel);
      merke('Vorspiel $id', t.vorlesen);
      for (final p in t.punkte) {
        merke('Vorspiel $id', p);
      }
    }
  }

  // Wörter
  final opfer = ((kanon.figurenJson['opfer'] as Map)['name'] as String).split(' ').last.toLowerCase();
  final personen = [opfer, for (final x in kanon.figuren) (x['name'] as String).toLowerCase()];
  final sperren = <RegExp>[
    for (final s in spoilerWoerter)
      if (!s.startsWith(opfer)) _anfang(s),
    for (final g in kanon.gegenstaende)
      for (final k in kennwoerter(g['name'] as String))
        if (!personen.any(k.startsWith)) _anfang(k),
  ];

  final alle = {...vorgeschichte, ...vorstellungen, ...titel};
  for (final MapEntry(key: k, value: x) in alle.entries) {
    for (final folge in fuenfWortFolgen(x)) {
      if (quelle[folge] case final q?) f.add('$k: „$folge“ stammt aus $q');
    }
    for (final re in sperren) {
      if (re.firstMatch(x) case final m?) f.add('$k: „${m.group(0)}“ gehört nicht in die Einstimmung');
    }
    for (final m in _wortRe.allMatches(x)) {
      final w = m.group(0)!.toLowerCase();
      if (urteilsWoerter.any(w.startsWith)) f.add('$k: Urteilswort „${m.group(0)}“');
      if (vorgeschichte.containsKey(k) && (_vorgeschichteTeile.any(w.contains) || _vorgeschichteAnfaenge.any(w.startsWith))) {
        f.add('$k: „${m.group(0)}“ gehört nicht in die Vorgeschichte (öffentliche Keller-Fassung)');
      }
    }
    if (x.toLowerCase().contains('geburtstag')) f.add('$k: Geburtstag (A-061)');
    if (_ziffer.firstMatch(x) case final m?) f.add('$k: Ziffern („${m.group(0)}“) verraten Zeiten oder Mengen');
  }

  // Ton
  if (ton != null) {
    for (final MapEntry(key: k, value: x) in alle.entries) {
      for (final t in ton.pruefe(TextQuelle(ort: k, text: x, vorlesen: !titel.containsKey(k)))) {
        f.add('${t.ort}: ${t.regel}: ${t.auszug}');
      }
    }
    for (final (bereich, l) in [('Vorgeschichte', vorgeschichte), ('Vorstellung', vorstellungen)]) {
      for (final t in ton.pruefeMittel(bereich, [for (final x in l.entries) TextQuelle(ort: x.key, text: x.value, vorlesen: true)])) {
        f.add('${t.ort}: ${t.regel}: ${t.auszug}');
      }
    }
  }
  return f;
}
