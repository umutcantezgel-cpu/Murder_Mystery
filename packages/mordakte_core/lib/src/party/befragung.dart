import 'dart:math';

import 'besetzung.dart';
import 'entscheidungen.dart';
import 'erzaehler.dart';
import 'kanon/kanon.dart';
import 'texte.dart';

/// Wie ein Tisch-Kettenglied den Detektiv erreicht (A-051, Semantik wie die
/// Quellenprüfung in `akte_pruefen._besetzung`).
/// - [befragung]: Der Detektiv befragt die besetzte Halterin bis zur Runde der Entscheidung.
/// - [npc]: Der Erzähler spricht das Wissen der unbesetzten Halterin zum Rundenstart (`Erzaehler.npcPlan`).
/// - [ziel]: Die unbesetzte Halterin ist Ziel einer Option bis zur Entscheidung (NPC-Karte).
/// - [fund]: Eine Option bis zur Entscheidung deckt die Beobachtung als Fakt auf.
enum Zustellweg { befragung, npc, ziel, fund }

/// Zustellung eines Tisch-Kettenglieds bei einer Besetzung.
class Zustellung {
  final String glied, halter;
  final Zustellweg weg;
  final int runde;
  const Zustellung({required this.glied, required this.halter, required this.weg, required this.runde});
}

/// Die Befragungen des Detektivs in einer Runde bei einer Besetzung.
class BefragungsRunde {
  final int runde;

  /// Feste Befragungen in Besetzungsreihenfolge: Halter von Kettengliedern,
  /// Vorgriff und Auffüllung. Deterministisch und pfadfrei.
  final List<String> pflicht;

  /// Freie Wahl: alle übrigen besetzten Rollen in Besetzungsreihenfolge.
  final List<String> frei;

  /// So viele Befragungen wählt der Detektiv aus [frei] (0 bis 2).
  final int freiWahlen;

  final Map<String, BefragungText> _texte;

  const BefragungsRunde._(this.runde, this.pflicht, this.frei, this.freiWahlen, this._texte);

  /// Befragungen der Runde insgesamt.
  int get gesamt => pflicht.length + freiWahlen;

  /// Text der Befragung von [rolle] in dieser Runde.
  BefragungText text(String rolle) => _texte[rolle] ?? (throw StateError('keine Befragung von $rolle in Runde $runde'));
}

/// Öffentliche Fassung einer Preisgabe von [rolle] (A-051): eine eigene
/// Beobachtung mit Kanal `pflichtgespraech`, die in allen Pfaden gilt, im
/// Wortlaut der dritten Person, oder die Behauptung einer eigenen Lüge, nie ihre
/// Wahrheit. Alles andere scheitert geschlossen mit [StateError].
String oeffentlicheAussage(Texte texte, String rolle, String quelle) {
  final teile = quelle.split(':');
  if (teile.length != 2) throw StateError('ungültige Bot-Quelle');
  switch (teile.first) {
    case 'beobachtung':
      final b = texte.beobachtung(teile.last);
      if (b == null || b['wer'] != rolle || b['kanal'] != 'pflichtgespraech' ||
          !texte.kanon.pfade.every((p) => Kanon.giltIn(b['pfade'], p))) {
        throw StateError('nicht öffentliche Bot-Beobachtung');
      }
      return b['text'] as String;
    case 'luege':
      final l = texte.luege(teile.last);
      if (l == null || l['person'] != rolle) throw StateError('fremde Bot-Behauptung');
      return l['behauptung'] as String;
    default:
      throw StateError('nicht öffentliche Bot-Quelle');
  }
}

/// Antwort-Stichpunkte einer Befragung in der dritten Person bzw. als Behauptung
/// (A-051). Sie entstehen nur aus den Preisgaben, nie aus der gewählten Frage.
List<String> befragungsAntwort(Texte texte, BefragungText b) => List.unmodifiable([
      for (final q in b.preisgabe) oeffentlicheAussage(texte, b.rolle, q),
    ]);

/// Spickzettel einer befragten Rolle, die ein Mensch spielt (A-051): was sie dem
/// Detektiv sagt. [sagen] sind die eigenen Beobachtungen in der Du-Form, [behaupten]
/// die Behauptungen eigener Lügen (nie ihre Wahrheit), [eigene] die Würze der
/// Befragung ohne neue Tatsache. Pfadfrei wie [befragungsAntwort]: Nicht
/// Öffentliches wirft [StateError].
class BefragungsZettel {
  final List<String> sagen, behaupten, eigene;
  const BefragungsZettel({required this.sagen, required this.behaupten, required this.eigene});

  /// Alle Zeilen ohne Behauptungen: erst die Beobachtungen, dann die eigene Würze.
  List<String> get stichpunkte => [...sagen, ...eigene];
}

BefragungsZettel befragungsZettel(Texte texte, BefragungText b) {
  final sagen = <String>[], behaupten = <String>[];
  for (final q in b.preisgabe) {
    // Dieselbe Prüfung wie die Antwort der App: nur Öffentliches.
    oeffentlicheAussage(texte, b.rolle, q);
    final id = q.substring(q.indexOf(':') + 1);
    if (q.startsWith('luege:')) {
      behaupten.add(texte.luege(id)!['behauptung'] as String);
    } else {
      final x = texte.beobachtung(id)!;
      sagen.add((x['duText'] ?? x['text']) as String);
    }
  }
  return BefragungsZettel(sagen: List.unmodifiable(sagen), behaupten: List.unmodifiable(behaupten), eigene: List.unmodifiable(b.stichpunkte));
}

/// Ein Tischgespräch einer Runde, wie alle es sehen dürfen: wer mit wem worüber.
typedef TischPaarung = ({String id, String rolle, String partner, String thema});

/// Die Tischgespräche besetzter Rollen in [runde] bei [n] Rollen mit dem Partner
/// aus dem Gesprächsplan, in Besetzungsreihenfolge. Nur Paarung und Thema, nie
/// Stichpunkte, Ziel oder Preisgabe.
List<TischPaarung> tischPaarungen(Texte t, {required int n, required int runde}) {
  final besetzt = t.besetzung.besetzt(n);
  final plan = t.gespraechsplan(n);
  int platz(String r) => besetzt.indexOf(r);
  final liste = [
    for (final g in t.sammlung.gespraeche)
      if (g.runde == runde && besetzt.contains(g.rolle)) g,
  ]..sort((a, b) => platz(a.rolle) != platz(b.rolle) ? platz(a.rolle) - platz(b.rolle) : a.nr - b.nr);
  return List.unmodifiable([
    for (final g in liste) (id: g.id, rolle: g.rolle, partner: plan[g.id] ?? g.partner, thema: g.thema),
  ]);
}

/// Verlauf der Befragungen eines Abends (A-051): welche Frage der Detektiv je
/// Befragung zuerst gestellt hat und welche erledigt sind. Prüft nur die Regeln
/// des [Befragungsplan]s; Antworten liefern [befragungsAntwort] (Rollen, die die
/// App spricht) und [befragungsZettel] (Rollen, die ein Mensch spielt).
/// Kennungen sind die der Befragungstexte (`bf_<rolle>_<runde>`).
///
/// Eine feste Befragung ist Pflicht. Eine freie wird mit der ersten Frage
/// gewählt, solange die Runde freie Wahlen übrig hat. Eine Runde ist fertig,
/// wenn alle festen erledigt, alle freien Wahlen getroffen und alle gewählten
/// erledigt sind. Welche Frage gestellt wird, ändert keine Antwort.
class BefragungsVerlauf {
  BefragungsVerlauf(this.plan, this.rollen);

  final Befragungsplan plan;
  final int rollen;
  final Map<String, int> _frage = {};
  final Set<String> _erledigt = {};

  BefragungsRunde runde(int r) => plan.fuer(rollen, r);

  /// Feste Befragungen der Runde [r] in Besetzungsreihenfolge.
  List<String> pflicht(int r) => [for (final x in runde(r).pflicht) BefragungText.kennung(x, r)];

  /// Frei wählbare Befragungen der Runde [r] in Besetzungsreihenfolge.
  List<String> frei(int r) => [for (final x in runde(r).frei) BefragungText.kennung(x, r)];

  /// Text der Befragung [id] (fester oder freier Teil des Plans).
  BefragungText text(String id) => plan.texte.sammlung.befragungen[id] ?? (throw ArgumentError('unbekannte Befragung $id'));

  /// Zuerst gestellte Frage (Index in [BefragungText.fragen]) oder null.
  int? frage(String id) => _frage[id];
  bool gefragt(String id) => _frage.containsKey(id);

  /// Ist [id] beantwortet, am Tisch oder von der App? [appSpricht] nennt die
  /// Rollen, die gerade kein Mensch spielt: Deren gestellte Befragung hat die App
  /// beantwortet, auch wenn die Person erst nach der Frage aufgegeben hat.
  bool erledigt(String id, {bool Function(String rolle)? appSpricht}) =>
      _erledigt.contains(id) || (appSpricht != null && _frage.containsKey(id) && appSpricht(text(id).rolle));

  /// Freie Wahlen, die in Runde [r] noch offen sind.
  int freiOffen(int r) => runde(r).freiWahlen - frei(r).where(_frage.containsKey).length;

  /// Darf der Detektiv in Runde [r] die Befragung [id] führen?
  bool waehlbar(int r, String id) => pflicht(r).contains(id) || (frei(r).contains(id) && (_frage.containsKey(id) || freiOffen(r) > 0));

  /// Der Detektiv stellt in Runde [r] die Frage [frage] der Befragung [id]. Nur
  /// die erste Frage zählt. Mit [sofort] antwortet die App (keine Spielerin
  /// spielt die Rolle), die Befragung ist damit erledigt.
  void befragen(int r, String id, int frage, {bool sofort = false}) {
    if (!waehlbar(r, id)) throw ArgumentError('Befragung $id ist in Runde $r nicht wählbar');
    if (frage < 0 || frage >= text(id).fragen.length) throw ArgumentError('Befragung $id hat keine Frage $frage');
    _frage.putIfAbsent(id, () => frage);
    if (sofort) _erledigt.add(id);
  }

  /// Eine gestellte Befragung ist am Tisch beantwortet.
  void erledigen(int r, String id) {
    if (!(pflicht(r).contains(id) || frei(r).contains(id))) throw ArgumentError('Befragung $id gehört nicht zu Runde $r');
    if (!_frage.containsKey(id)) throw StateError('Befragung $id ist noch nicht gestellt');
    _erledigt.add(id);
  }

  /// Ist Runde [r] durch? Erst dann darf der Abend weiter. [appSpricht] wie bei [erledigt].
  bool fertig(int r, {bool Function(String rolle)? appSpricht}) {
    bool beantwortet(String id) => erledigt(id, appSpricht: appSpricht);
    return pflicht(r).every(beantwortet) && freiOffen(r) <= 0 && frei(r).where(_frage.containsKey).every(beantwortet);
  }

  /// Alle gestellten Befragungen in der Reihenfolge der ersten Frage.
  List<String> get gestellt => List.unmodifiable(_frage.keys);
}

/// Planer der Befragungen (A-051, Modell befragung): Je Runde führt der Detektiv
/// 3 bis höchstens 5 Befragungen, feste und frei gewählte.
///
/// Eingaben sind nur die Rollenzahl n und die Begründungsketten aller Pfade,
/// nie Pfad, Salz oder Fall-Code. Je Runde:
/// 1. **Pflicht:** besetzte Halter von Tisch-Kettengliedern, die eine Entscheidung
///    dieser Runde braucht und die noch nicht befragt sind. Kernverdächtige
///    zählen, bis sie einmal befragt sind, als Bedarf der letzten Runde (I-B4).
/// 2. **Vorgriff:** Bedarf der Runden r+1 und r+2 kommt nur so weit nach vorn,
///    wie die späteren Runden ihn sonst nicht schaffen. Gesucht wird die
///    Verteilung, die möglichst vielen Runden ab r einen freien Platz lässt,
///    bei Gleichstand den früheren Runden. Vorgezogen wird der früheste Bedarf,
///    bei Gleichstand nach Besetzungsplatz.
/// 3. **Auffüllen auf 3:** Reichen feste und freie Befragungen zusammen nicht für
///    drei, kommen noch nicht befragte besetzte Kernverdächtige dazu, dann Rollen
///    in Besetzungsreihenfolge.
/// Danach wählt der Detektiv bis zu zwei weitere aus den übrigen besetzten
/// Rollen, solange die Höchstzahl reicht. Wer befragt wird, sagt alle eigenen
/// Kettenglieder, die ab dieser Runde gebraucht werden (I-B3).
class Befragungsplan {
  final Texte texte;
  late final Ermittlung ermittlung = Ermittlung(texte.kanon);
  late final Erzaehler erzaehler = Erzaehler(texte.kanon);

  Befragungsplan(this.texte);

  /// Höchstens so viele freie Wahlen je Runde.
  static const freiHoechstens = 2;
  static const runden = 3;

  Besetzung get _besetzung => texte.besetzung;
  Kanon get _kanon => texte.kanon;

  /// Tisch-Kettenglied → erste Runde, in der eine Entscheidung es braucht.
  late final Map<String, int> glieder = tischKettenglieder(_kanon);

  /// Halter eines Tisch-Kettenglieds: wer die Beobachtung gemacht hat oder lügt.
  String halter(String glied) {
    final i = glied.indexOf(':');
    final id = glied.substring(i + 1);
    return switch (glied.substring(0, i)) {
      'luege' => texte.luege(id)!['person'] as String,
      _ => texte.beobachtung(id)!['wer'] as String,
    };
  }

  /// Runden, in denen eine Entscheidung (gleich welcher Pfad) [glied] braucht.
  late final Map<String, Set<int>> bedarfsrunden = () {
    final aus = <String, Set<int>>{};
    for (final e in ermittlung.entscheidungen) {
      for (final b in e.begruendung.values) {
        for (final k in b.kette) {
          if (glieder.containsKey(k)) (aus[k] ??= {}).add(e.runde);
        }
      }
    }
    return aus;
  }();

  int _platz(String rolle) => _besetzung.reihenfolge.indexOf(rolle);

  final Map<int, List<BefragungsRunde>> _plaene = {};

  /// Die Befragungen der Runde [runde] bei [n] besetzten Rollen.
  BefragungsRunde fuer(int n, int runde) {
    if (runde < 1 || runde > runden) throw ArgumentError('ungültige Runde $runde');
    return (_plaene[n] ??= _plane(n))[runde - 1];
  }

  List<BefragungsRunde> _plane(int n) {
    final besetzt = _besetzung.besetzt(n);
    final grenze = min(_besetzung.befragungenMax, n);
    // Frist je besetzter Person: erste Runde, in der ihr Wissen gebraucht wird.
    final frist = <String, int>{};
    for (final e in glieder.entries) {
      final h = halter(e.key);
      if (besetzt.contains(h)) frist[h] = min(frist[h] ?? runden, e.value);
    }
    for (final k in _kanon.kernverdaechtige) {
      if (besetzt.contains(k)) frist.putIfAbsent(k, () => runden);
    }
    int nachFrist(String a, String b) => frist[a] != frist[b] ? frist[a]! - frist[b]! : _platz(a) - _platz(b);

    final befragt = <String>{};
    final plan = <BefragungsRunde>[];
    for (var r = 1; r <= runden; r++) {
      final offen = [for (final h in frist.keys) if (!befragt.contains(h)) h]..sort(nachFrist);
      final faellig = [for (final h in offen) if (frist[h] == r) h];
      // Was die späteren Runden nicht schaffen, rückt vor (frühester Bedarf zuerst). [frei] hält je
      // Runde ab r einen Platz frei (1) oder nicht (0).
      List<String> vorgriff(List<int> frei) {
        var ueber = <String>[];
        for (var spaeter = runden; spaeter > r; spaeter--) {
          final pool = [...ueber, for (final h in offen) if (frist[h] == spaeter) h]..sort(nachFrist);
          ueber = pool.take(max(0, pool.length - (grenze - frei[spaeter - r]))).toList();
        }
        return ueber;
      }

      // Alle Verteilungen freier Plätze: zuerst die mit den meisten, dann die mit früheren.
      final rest = runden - r + 1;
      int summe(List<int> v) => v.fold(0, (a, b) => a + b);
      int wert(List<int> v) => v.fold(0, (a, b) => a * 2 + b);
      final verteilungen = <List<int>>[
        for (var bits = 0; bits < 1 << rest; bits++) [for (var i = 0; i < rest; i++) (bits >> (rest - 1 - i)) & 1],
      ]..sort((a, b) => summe(a) != summe(b) ? summe(b) - summe(a) : wert(b) - wert(a));
      var vor = vorgriff(List.filled(rest, 0));
      for (final frei in verteilungen) {
        final v = vorgriff(frei);
        if (faellig.length + v.length <= grenze - frei.first) {
          vor = v;
          break;
        }
      }
      final pflicht = [...faellig, ...vor];
      int wahlen() => min(freiHoechstens, min(grenze - pflicht.length, besetzt.length - pflicht.length)).clamp(0, freiHoechstens);
      final kandidaten = <String>{
        for (final k in _kanon.kernverdaechtige)
          if (besetzt.contains(k) && !befragt.contains(k)) k,
        for (final x in besetzt)
          if (!befragt.contains(x)) x,
        ...besetzt,
      }..removeAll(pflicht);
      final auffuellen = kandidaten.toList();
      while (pflicht.length + wahlen() < _besetzung.befragungenMin && auffuellen.isNotEmpty) {
        pflicht.add(auffuellen.removeAt(0));
      }
      pflicht.sort((a, b) => _platz(a) - _platz(b));
      befragt.addAll(pflicht);
      final frei = [for (final x in besetzt) if (!pflicht.contains(x)) x];
      plan.add(BefragungsRunde._(r, List.unmodifiable(pflicht), List.unmodifiable(frei), wahlen(), {
        for (final x in besetzt) x: ?texte.sammlung.befragungen[BefragungText.kennung(x, r)],
      }));
    }
    return plan;
  }

  bool _sagt(String rolle, int runde, String glied) =>
      texte.sammlung.befragungen[BefragungText.kennung(rolle, runde)]?.preisgabe.contains(glied) ?? false;

  /// Entscheidungen bis einschließlich [e] in Spielreihenfolge.
  Iterable<Entscheidung> _bis(Entscheidung e) =>
      ermittlung.entscheidungen.where((y) => y.runde < e.runde || (y.runde == e.runde && y.nr <= e.nr));

  bool _alsZiel(String halter, Entscheidung e) => _bis(e).any((y) => y.optionen.any((o) => o.ziel['person'] == halter));

  bool _alsFund(String glied, Entscheidung e, String pfad) {
    if (!glied.startsWith('beobachtung:')) return false;
    final id = glied.substring('beobachtung:'.length);
    return _bis(e).any((y) => y.optionen.any((o) => o.fakten.any((f) => ermittlung.fakten[f]?.beobachtung == id && ermittlung.gibtEs(f, pfad))));
  }

  int? _alsNpc(String halter, String glied, int bisRunde) {
    if (!glied.startsWith('beobachtung:')) return null;
    final id = glied.substring('beobachtung:'.length);
    for (var r = 1; r <= bisRunde; r++) {
      if ((erzaehler.npcPlan[r]?[halter] ?? const []).contains(id)) return r;
    }
    return null;
  }

  /// Erste Entscheidung (Spielreihenfolge), die [glied] in irgendeinem Pfad braucht.
  Entscheidung _erste(String glied) => ermittlung.entscheidungen.firstWhere((e) => e.begruendung.values.any((b) => b.kette.contains(glied)));

  /// Wie jedes Tisch-Kettenglied bei [n] Rollen den Detektiv erreicht, rechtzeitig
  /// vor der ersten Entscheidung, die es braucht. Fehlt ein Glied, gibt es keinen
  /// rechtzeitigen Weg ([verstoesse] meldet es).
  Map<String, Zustellung> zustellung(int n) {
    final aus = <String, Zustellung>{};
    for (final g in glieder.keys) {
      final h = halter(g);
      final e = _erste(g);
      if (_besetzung.istBesetzt(h, n)) {
        for (var r = 1; r <= e.runde; r++) {
          if (fuer(n, r).pflicht.contains(h) && _sagt(h, r, g)) {
            aus[g] = Zustellung(glied: g, halter: h, weg: Zustellweg.befragung, runde: r);
            break;
          }
        }
        continue;
      }
      final npc = _alsNpc(h, g, e.runde);
      if (npc != null) {
        aus[g] = Zustellung(glied: g, halter: h, weg: Zustellweg.npc, runde: npc);
      } else if (_alsZiel(h, e)) {
        final y = _bis(e).firstWhere((y) => y.optionen.any((o) => o.ziel['person'] == h));
        aus[g] = Zustellung(glied: g, halter: h, weg: Zustellweg.ziel, runde: y.runde);
      } else if (_kanon.pfade.every((p) => _alsFund(g, e, p))) {
        aus[g] = Zustellung(glied: g, halter: h, weg: Zustellweg.fund, runde: e.runde);
      }
    }
    return aus;
  }

  /// Verstöße gegen I-B1 bis I-B6 für alle Besetzungen (leer heißt grün):
  /// Plangröße, Texte, Last je Rolle, rechtzeitige Zustellung je Entscheidung
  /// und Pfad, jede Kernrolle mindestens einmal befragt, vollständige
  /// Preisgaben und keine Namen unbesetzter Figuren.
  List<String> verstoesse() {
    final f = <String>[];
    if (!_besetzung.befragungsmodell) return ['Befragungsplan: die Akte hat das Modell legacy'];
    final namen = {for (final x in _kanon.figuren) x['id'] as String: x['name'] as String};

    // I-B3: Wer befragt wird, sagt alle eigenen Kettenglieder, die ab dieser Runde gebraucht werden.
    for (final x in _kanon.figuren.map((x) => x['id'] as String)) {
      for (var r = 1; r <= runden; r++) {
        final b = texte.sammlung.befragungen[BefragungText.kennung(x, r)];
        if (b == null) {
          f.add('Befragung ${BefragungText.kennung(x, r)} fehlt');
          continue;
        }
        if (b.rolle != x || b.runde != r) f.add('Befragung ${b.id}: Rolle oder Runde passt nicht');
        for (final g in glieder.keys) {
          if (halter(g) == x && bedarfsrunden[g]!.any((br) => br >= r) && !b.preisgabe.contains(g)) {
            f.add('Befragung ${b.id}: $g fehlt, eine Entscheidung ab Runde $r braucht es (I-B3)');
          }
        }
      }
    }

    for (var n = _besetzung.minRollen; n <= _besetzung.maxRollen; n++) {
      final besetzt = _besetzung.besetzt(n);
      final npc = _besetzung.npc(n);
      final grenze = min(_besetzung.befragungenMax, n);
      final plan = <String, String>{};
      try {
        plan.addAll(texte.gespraechsplan(n));
      } catch (e) {
        f.add('$n Rollen: Gesprächsplan scheitert: $e');
      }
      final jeRunde = [for (var r = 1; r <= runden; r++) fuer(n, r)];
      for (final br in jeRunde) {
        final wo = '$n Rollen, Runde ${br.runde}';
        if (br.gesamt < _besetzung.befragungenMin || br.gesamt > grenze) {
          f.add('$wo: ${br.gesamt} Befragungen statt ${_besetzung.befragungenMin} bis $grenze');
        }
        if (br.pflicht.length > grenze) f.add('$wo: ${br.pflicht.length} feste Befragungen über der Grenze $grenze');
        if ({...br.pflicht, ...br.frei}.length != besetzt.length || !besetzt.every((x) => br.pflicht.contains(x) || br.frei.contains(x))) {
          f.add('$wo: feste und freie Befragungen decken die Besetzung nicht genau');
        }
        for (final x in [...br.pflicht, ...br.frei]) {
          if (!br._texte.containsKey(x)) f.add('$wo: keine Befragung von $x');
        }
        // I-B5: Tischgespräche als Sprecherin und Partnerin plus höchstens eine Befragung.
        for (final x in besetzt) {
          final sprecher = texte.sammlung.gespraeche.where((g) => g.rolle == x && g.runde == br.runde).length;
          final partner = texte.sammlung.gespraeche.where((g) => g.runde == br.runde && besetzt.contains(g.rolle) && plan[g.id] == x).length;
          final last = sprecher + partner + 1;
          if (sprecher + partner < 1 || last > _besetzung.hoechstlast) {
            f.add('$wo: $x hat ${sprecher + partner} Tischgespräche und bis zu eine Befragung, erlaubt 1 bis ${_besetzung.hoechstlast} (I-B5)');
          }
        }
        // I-B6: Thema, Fragen und Stichpunkte nennen keine unbesetzte Figur.
        for (final x in [...br.pflicht, ...br.frei]) {
          final b = br._texte[x];
          if (b == null) continue;
          for (final u in npc) {
            final name = namen[u]!;
            final re = RegExp('(?<!\\p{L})${RegExp.escape(name)}(?!\\p{L})', unicode: true);
            for (final t in [b.thema, ...b.fragen, ...b.stichpunkte]) {
              if (re.hasMatch(t)) f.add('$wo: Befragung ${b.id} nennt die unbesetzte Figur $u ($name): $t');
            }
          }
        }
      }
      // I-B4: Jede besetzte Kernrolle wird mindestens einmal fest befragt.
      for (final k in _kanon.kernverdaechtige) {
        if (besetzt.contains(k) && !jeRunde.any((br) => br.pflicht.contains(k))) f.add('$n Rollen: Kernrolle $k wird an keinem Abendteil befragt (I-B4)');
      }
      // I-B2: Jedes Tisch-Kettenglied erreicht den Detektiv bis zu seiner Entscheidung, in jedem Pfad.
      for (final e in ermittlung.entscheidungen) {
        for (final p in _kanon.pfade) {
          for (final g in e.begruendungFuer(p)?.kette ?? const <String>[]) {
            if (!glieder.containsKey(g)) continue;
            final h = halter(g);
            final ok = besetzt.contains(h)
                ? [for (var r = 1; r <= e.runde; r++) r].any((r) => jeRunde[r - 1].pflicht.contains(h) && _sagt(h, r, g))
                : _alsNpc(h, g, e.runde) != null || _alsZiel(h, e) || _alsFund(g, e, p);
            if (!ok) f.add('$n Rollen, $p, ${e.id}: $g von $h erreicht den Detektiv nicht rechtzeitig (I-B2)');
          }
        }
      }
    }
    return f;
  }
}
