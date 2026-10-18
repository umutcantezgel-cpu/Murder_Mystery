import 'kanon/kanon.dart';

/// Gesprächsmodell einer Akte (A-051, Block `gespraeche` in `besetzung.json`).
/// - [legacy]: drei Pflichtgespräche je Rolle und Runde, der Detektiv springt als Partner ein (E-028).
/// - [befragung]: ein Tischgespräch je Rolle und Runde ohne den Detektiv; er führt eigene Befragungen
///   (`befragung.dart`). Gilt nur für Akten, die es ausdrücklich wählen.
enum GespraechsModell { legacy, befragung }

/// Besetzung für 4 bis 20 Rollen (Master 7.10, F-09): feste Reihenfolge,
/// Ersatzpartner für Gespräche, unbesetzte Gäste als NPC.
class Besetzung {
  final Kanon kanon;
  final List<String> reihenfolge;
  final Map<String, List<String>> ersatz;
  final int minRollen, maxRollen;

  /// Gesprächsmodell; ohne Block `gespraeche` gilt [GespraechsModell.legacy].
  final GespraechsModell modell;

  /// Tischgespräche je Rolle und Runde als Sprecher (legacy 3).
  final int tischJeRolle;

  /// Höchstlast einer Rolle je Runde (legacy [lastRolle]). Im Modell
  /// [GespraechsModell.befragung] zählt eine Befragung durch den Detektiv mit.
  final int hoechstlast;

  /// Befragungen des Detektivs je Runde, kleinste und größte Zahl (nur Modell befragung).
  final int befragungenMin, befragungenMax;

  factory Besetzung(Kanon kanon) => Besetzung._(kanon, ((kanon.besetzungJson['gespraeche'] as Map?) ?? const {}).cast<String, Object?>());

  Besetzung._(this.kanon, Map<String, Object?> gespraeche)
      : reihenfolge = [for (final r in kanon.besetzungJson['reihenfolge'] as List) r as String],
        ersatz = {
          for (final e in ((kanon.besetzungJson['ersatzpartner'] as Map?) ?? const {}).entries)
            e.key as String: [for (final r in e.value as List) r as String],
        },
        minRollen = kanon.besetzungJson['minRollen'] as int,
        maxRollen = kanon.besetzungJson['maxRollen'] as int,
        modell = gespraeche['modell'] == 'befragung' ? GespraechsModell.befragung : GespraechsModell.legacy,
        tischJeRolle = (gespraeche['tischJeRolle'] as int?) ?? 3,
        hoechstlast = (gespraeche['lastRolle'] as int?) ?? lastRolle,
        befragungenMin = ((gespraeche['befragungenJeRunde'] as List?)?.first as int?) ?? 0,
        befragungenMax = ((gespraeche['befragungenJeRunde'] as List?)?.last as int?) ?? 0;

  bool get befragungsmodell => modell == GespraechsModell.befragung;

  static const detektiv = 'detective';

  /// Besetzte Rollen bei [n] Rollen (ohne den Detektiv).
  List<String> besetzt(int n) {
    if (n < minRollen || n > maxRollen) throw RangeError.range(n, minRollen, maxRollen, 'Rollen');
    return reihenfolge.take(n).toList();
  }

  bool istBesetzt(String rolle, int n) => rolle == detektiv || besetzt(n).contains(rolle);

  /// Unbesetzte Gäste: NPC mit Karte (W1).
  List<String> npc(int n) => [for (final r in reihenfolge) if (!besetzt(n).contains(r)) r];

  /// Gesprächspartner für [wunsch] bei [n] Rollen: die Rolle selbst, sonst der
  /// erste besetzte Ersatz, der nicht [sprecher] ist, sonst der Detektiv
  /// (im Modell befragung die erste andere besetzte Rolle).
  /// Ohne Blick auf die Last; am Abend gilt [gespraechsplan].
  String partner(String wunsch, int n, {String? sprecher}) {
    if (istBesetzt(wunsch, n) && wunsch != sprecher && !(befragungsmodell && wunsch == detektiv)) return wunsch;
    for (final e in ersatz[wunsch] ?? const <String>[]) {
      if (e != sprecher && istBesetzt(e, n)) return e;
    }
    if (befragungsmodell) return besetzt(n).firstWhere((r) => r != sprecher);
    return detektiv;
  }

  /// Höchstlast je Runde im Modell legacy (V-19, E-028): Pflichtgespräche, an
  /// denen eine Person beteiligt ist, als Sprecher oder als Partner.
  static const lastRolle = 7, lastDetektiv = 6;

  /// Grenze der Tischgespräche je Runde für [person]. Im Modell befragung hält
  /// jede Rolle einen Platz für eine Befragung durch den Detektiv frei, und der
  /// Detektiv sitzt nicht am Tisch.
  int grenze(String person) => befragungsmodell
      ? (person == detektiv ? 0 : hoechstlast - 1)
      : (person == detektiv ? lastDetektiv : hoechstlast);

  int _platz(String p) => p == detektiv ? reihenfolge.length : reihenfolge.indexOf(p);

  /// Tatsächliche Partner aller Pflichtgespräche bei [n] Rollen (E-028):
  /// Kennung → Partner. Gespräche unbesetzter Rollen fallen weg.
  ///
  /// Ein besetzter Wunschpartner bleibt (im Modell befragung nur mit freier
  /// Last). Für einen fehlenden kommt der erste besetzte Ersatz mit freier Last,
  /// sonst die besetzte Person mit der kleinsten Last; neue Paare gehen vor
  /// Wiederholungen. Gleichstand entscheidet der Besetzungsplatz, der Detektiv
  /// steht zuletzt. Im Modell befragung ist der Detektiv nie Tischpartner; hat
  /// nur noch der Sprecher selbst freie Last, tauscht er mit dem zuletzt
  /// gesetzten Gespräch, das ihn nicht betrifft.
  Map<String, String> gespraechsplan(Iterable<GespraechsWunsch> wuensche, int n) {
    final personen = [...besetzt(n), if (!befragungsmodell) detektiv];
    final plan = <String, String>{};
    for (final runde in {for (final w in wuensche) w.runde}.toList()..sort()) {
      final liste = [
        for (final w in wuensche)
          if (w.runde == runde && istBesetzt(w.rolle, n)) w,
      ]..sort((a, b) => _platz(a.rolle) != _platz(b.rolle) ? _platz(a.rolle) - _platz(b.rolle) : a.nr - b.nr);
      final last = {for (final p in personen) p: 0};
      final paare = <String>{};
      String paar(String a, String b) => a.compareTo(b) < 0 ? '$a|$b' : '$b|$a';
      void setze(GespraechsWunsch w, String p) {
        plan[w.id] = p;
        last[p] = last[p]! + 1;
        paare.add(paar(w.rolle, p));
      }

      // Im Modell befragung zählt am Tisch nur die Partnerlast; der Sprecherplatz ist fest.
      for (final w in liste) {
        if (!befragungsmodell) last[w.rolle] = last[w.rolle]! + 1;
      }
      int grenzeAmTisch(String p) => befragungsmodell ? grenze(p) - tischJeRolle : grenze(p);
      final gesetzt = <GespraechsWunsch>[];
      final offen = <GespraechsWunsch>[];
      for (final w in liste) {
        final wunschOk = w.partner != w.rolle && istBesetzt(w.partner, n) && personen.contains(w.partner);
        if (wunschOk && (!befragungsmodell || last[w.partner]! < grenzeAmTisch(w.partner))) {
          setze(w, w.partner);
          gesetzt.add(w);
        } else {
          offen.add(w);
        }
      }
      for (final w in offen) {
        bool frei(String p) => p != w.rolle && last[p]! < grenzeAmTisch(p);
        bool neu(String p) => !paare.contains(paar(w.rolle, p));
        final ersatzFrei = [
          for (final e in ersatz[w.partner] ?? const <String>[])
            if (istBesetzt(e, n) && personen.contains(e) && frei(e) && neu(e)) e,
        ];
        String kleinste(Iterable<String> l) =>
            l.reduce((a, b) => last[a]! != last[b]! ? (last[a]! < last[b]! ? a : b) : (_platz(a) <= _platz(b) ? a : b));
        final freiNeu = personen.where((p) => frei(p) && neu(p));
        final freiAlt = personen.where(frei);
        if (befragungsmodell && ersatzFrei.isEmpty && freiAlt.isEmpty) {
          // Nur der Sprecher selbst hat noch Platz: Er übernimmt den Partner eines
          // früheren Gesprächs, und dessen Sprecher spricht mit ihm.
          final tausch = gesetzt.lastWhere((x) => x.rolle != w.rolle && plan[x.id] != w.rolle);
          final alt = plan[tausch.id]!;
          plan[tausch.id] = w.rolle;
          last[w.rolle] = last[w.rolle]! + 1;
          paare.add(paar(tausch.rolle, w.rolle));
          plan[w.id] = alt;
          paare.add(paar(w.rolle, alt));
          gesetzt.add(w);
          continue;
        }
        setze(
          w,
          ersatzFrei.isNotEmpty
              ? ersatzFrei.first
              : freiNeu.isNotEmpty
                  ? kleinste(freiNeu)
                  : freiAlt.isNotEmpty
                      ? kleinste(freiAlt)
                      : kleinste(personen.where((p) => p != w.rolle)),
        );
        gesetzt.add(w);
      }
    }
    return plan;
  }

  /// Personen über der Höchstlast in [plan] bei [n] Rollen (leer heißt grün).
  /// Im Modell befragung gilt am Tisch [grenze], also ein Platz unter der
  /// Höchstlast; die Befragungen zählt `Befragungsplan.verstoesse` dazu.
  List<String> lastVerstoesse(Iterable<GespraechsWunsch> wuensche, Map<String, String> plan, int n) {
    final f = <String>[];
    for (final runde in {for (final w in wuensche) w.runde}) {
      final last = <String, int>{};
      for (final w in wuensche) {
        final p = plan[w.id];
        if (w.runde != runde || p == null) continue;
        last[w.rolle] = (last[w.rolle] ?? 0) + 1;
        last[p] = (last[p] ?? 0) + 1;
      }
      for (final e in last.entries) {
        if (e.value > grenze(e.key)) f.add('$n Rollen, Runde $runde: ${e.key} hat ${e.value} Gespräche (höchstens ${grenze(e.key)})');
      }
    }
    return f;
  }
}

/// Ein Pflichtgespräch, wie es geschrieben ist: Sprecher, Runde, Nummer, Wunschpartner.
typedef GespraechsWunsch = ({String id, String rolle, int runde, int nr, String partner});
