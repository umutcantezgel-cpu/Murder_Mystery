/// Teil 10 (Rollenhefte der besetzten Rollen 1–10) und Teil 12 (Zusatzhefte
/// der besetzten Rollen 11–18), dazu das Heft einer Rolle für die Einzeldatei
/// (MECH 10.1, 10.3, 10.4; RK 1.1, ZG 0.6, ZR 0.7).
///
/// Drei Gestalten mit fester Seitenzahl und Abschnitten in Bibel-Reihenfolge:
/// - Verdächtige 1–4 (RK 1.1, MECH 10.4), vier Seiten: Titel, Dein Auftritt,
///   Wer du bist, Was alle wissen, So spielt ihr (die Tischregeln in Kurzform;
///   RK 1.1 nennt ihnen keine Seite, auf Seite 1 stehen sie beim gemeinsamen
///   Wissen) · Deine Marker, Stufe 1 mit Ausweichsätzen, Wenn der Erzähler
///   fragt, Stufe 2 · Gesprächsaufträge, Was du über andere sagen darfst · Was
///   du bei dir trägst, Aktionskarte, Bonus-Ziel, versiegelte Fassung, Notizen,
///   unten der Besetzungshinweis.
/// - Zeugen 5–10 (ZG 0.6), vier Seiten: Titel, Auftritt, Wer du bist, Marker,
///   Was alle wissen · Was du weißt, Stufe 1 (bei Joanna mit ihrer Notiz),
///   Wenn der Erzähler fragt · Stufe 2, Was du dann zugibst, Nach dem Umdrehen,
///   Nachbohr-Ziele · Was du bei dir trägst, Aktionskarte, Bonus-Ziel, Wenn du
///   angeklagt wirst, So spielt ihr, Notizen, Besetzungshinweis.
/// - Zusatzrollen 11–18 (ZR 0.7), drei Seiten: wie die Zeugen, auf Seite 1 der
///   Kasten „Dein Tandem“ (spielt die Rolle allein, in der Ersatzfassung ihrer
///   Platzhalter, ZR 1.12) · Was du weißt, Stufe 1, Wenn der Erzähler fragt ·
///   Stufe 2 bis Gesprächsaufträge, Aktionskarte, Was du bei dir trägst,
///   Bonus-Ziel, Wenn du angeklagt wirst, beim kleineren Platz eines Tandems,
///   das heute allein spielt, der Solo-Abschnitt, So spielt ihr, unten der
///   Besetzungshinweis.
///
/// Seitenplan (für alle heute besetzten Hefte einer Gestalt gemeinsam berechnet,
/// einmal je Kontext, auch für die Einzeldatei): Jede Seite ist eine feste
/// Seite; ein Abschnitt besteht aus Blöcken (Absatz, Listenpunkt,
/// Tabellenzeile, Kasten), die nie geteilt werden.
/// 1. Der Seitenplan der Bibel, wenn alle Seiten in mindestens 9 pt passen und
///    seine kleinste Seitenschrift höchstens 0,5 pt unter der von 2. liegt.
/// 2. Sonst Umbrüche an denselben Abschnittsgrenzen in allen Heften der
///    Gestalt: größte Schrift, dann so nah am Bibel-Plan wie möglich. Die
///    Reihenfolge der Abschnitte bleibt immer die der Bibel.
/// 3. Nur Zeugen und Zusatzrollen, wenn auch das in 9 pt nicht reicht: Umbruch
///    zwischen Blöcken (nie nach einer Überschrift), je Heft eigener Umbruch,
///    eine Schrift für alle.
/// Passt es auch so nicht, wirft es [KammerUeberlauf] mit Teil, Seite und Rolle.
/// Die vier Verdächtigen (E9) brechen nie nach 3. um: gleiche Abschnitte auf
/// gleichen Seiten, gleiche Schriftgröße je Seite. Die letzte Seite der
/// Rollenhefte 1–10 behält Platz für mindestens drei Notizlinien.
///
/// Schrift: Grundschrift je Seite von 10,5 pt abwärts, nie unter 9 pt (ZG 0.6);
/// Rand 10 mm (Text hält den Druckrand von 5 mm) und knapper Zeilenabstand,
/// damit die Bibel-Längen in die festen Seitenzahlen passen. Jeder sichtbare
/// Text kommt aus dem Inhalt: Rollendateien, `gemeinsam.json`,
/// `ui/gemeinsam.json` (Heft-Überschriften `heft.*`) und `ui/10.json` bzw.
/// `ui/12.json`.
library;

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../satz_stil.dart';
import 'inhalt.dart';
import 'kontext.dart';
import 'satz.dart';

/// Setzt Teil 10: die Rollenhefte der besetzten Plätze 1–10 in Platzreihenfolge.
void kammerRollenhefte(pw.Document doc, KammerKontext k) {
  for (final p in k.besetzung.hauptrollen) {
    kammerRollenheft(doc, k, p);
  }
}

/// Setzt Teil 12: die Zusatzhefte der besetzten Plätze 11–18; ohne Zusatzrollen
/// (6 bis 12 Personen) eine Hinweisseite (MECH 10.1, `ui/12.json` → `hinweisseite`).
void kammerZusatzhefte(pw.Document doc, KammerKontext k) {
  final rollen = k.besetzung.zusatzrollen;
  if (rollen.isEmpty) {
    kammerTeilSetzen(doc, k, '12', (s) {
      s.seite(wo: 'hinweisseite', [
        k.satz.ueberschrift(k.teilTitel('12')),
        pw.SizedBox(height: 6),
        k.satz.absatz(k.ui('12', 'hinweisseite'), groesse: 12),
      ]);
    });
    return;
  }
  for (final p in rollen) {
    kammerZusatzheft(doc, k, p);
  }
}

/// Das Rollenheft von [p] (Platz 1–10, heute besetzt) mit eigener
/// Seitenzählung, vier Seiten.
void kammerRollenheft(pw.Document doc, KammerKontext k, KammerPlatz p) {
  if (p.art == KammerArt.zusatz) throw ArgumentError.value(p.id, 'p', 'Zusatzrolle: kammerZusatzheft');
  _heftSetzen(doc, k, p);
}

/// Das Zusatzheft von [p] (Platz 11–18, heute besetzt) mit eigener
/// Seitenzählung, drei Seiten.
void kammerZusatzheft(pw.Document doc, KammerKontext k, KammerPlatz p) {
  if (p.art != KammerArt.zusatz) throw ArgumentError.value(p.id, 'p', 'Hauptrolle: kammerRollenheft');
  _heftSetzen(doc, k, p);
}

// ---------------------------------------------------------------- Maße

/// Seitenrand der Hefte (10 mm; Text hält den Druckrand von 5 mm).
const _rand = pw.EdgeInsets.all(10 * PdfPageFormat.mm);

/// Satzbreite der Hefte.
final double _breite = KammerSatz.a4Hoch.width - _rand.horizontal;

/// Grundschriften von groß nach klein; die kleinste ist die Mindestgröße (ZG 0.6).
const List<double> _raster = [10.5, 10.25, 10.0, 9.75, 9.5, 9.25, KammerSatz.kleinsteGroesse];

/// Zusätzlicher Zeilenabstand in Teilen der Schriftgröße.
const double _zeilenabstand = 0.02;

/// Abstand der Notizlinien.
const double _notizAbstand = 22;

/// So viele Notizlinien hat die letzte Seite eines Rollenhefts mindestens.
const int _notizMindestens = 3;

/// Innenabstand der Tabellenzellen.
const _zelle = pw.EdgeInsets.fromLTRB(3, 1.2, 3, 1.6);

const _linie = pw.BorderSide(color: DruckStil.linie, width: 0.5);

// ---------------------------------------------------------------- Gestalt

/// Gestalt eines Hefts mit ihrer festen Seitenzahl (MECH 10.1).
enum _Gestalt {
  verdaechtig(4),
  zeuge(4),
  zusatz(3);

  const _Gestalt(this.seiten);
  final int seiten;

  static _Gestalt von(KammerPlatz p) => switch (p.art) {
        KammerArt.verdaechtig => verdaechtig,
        KammerArt.zeuge => zeuge,
        KammerArt.zusatz => zusatz,
      };
}

/// Ein Baustein, der nie über zwei Seiten geteilt wird.
class _Block {
  const _Block(this.w, {this.klebt = false, this.zeile = false});
  final pw.Widget w;

  /// Gehört zum nächsten Block (Überschrift, Tabellenkopf): kein Umbruch danach.
  final bool klebt;

  /// Tabellenzeile ohne obere Linie; oben auf einer Seite bekommt sie eine.
  final bool zeile;
}

/// Ein Abschnitt: [name] (für den Seitenplan), [abstand] davor in Teilen der
/// Grundschrift (entfällt oben auf einer Seite), Blöcke je Grundschrift.
class _Abschnitt {
  const _Abschnitt(this.name, this.bauen, {this.abstand = 0.7});
  final String name;
  final List<_Block> Function(double g) bauen;
  final double abstand;
}

/// Alle Blöcke eines Hefts in einer Grundschrift, mit Abschnitt und Abstand.
class _Fluss {
  final bloecke = <_Block>[];

  /// Erster Block seines Abschnitts?
  final erster = <bool>[];

  /// Abstand vor dem Block (pt), wenn er nicht oben auf der Seite steht.
  final abstand = <double>[];

  /// Je Abschnitt der Index seines ersten Blocks (leerer Abschnitt: der nächste).
  final start = <int>[];
}

/// Eine gesetzte Heftseite: Grundschrift und Blöcke [von] bis vor [bis].
typedef _Seite = ({double g, int von, int bis});

/// Ein Heft in einer Grundschrift; jeder Block wird erst gemessen, wenn ein
/// Seitenplan seine Höhe braucht.
class _Mass {
  _Mass(this.fluss, this._messen, this.unten)
      : n = fluss.bloecke.length,
        _hoehen = List<double?>.filled(fluss.bloecke.length, null);

  final _Fluss fluss;
  final int n;
  final double Function(pw.Widget w) _messen;
  final List<double?> _hoehen;

  /// Höhe des Besetzungshinweises unten auf der letzten Seite.
  final double unten;

  /// Höhe von Block [i] (ohne den Abstand davor).
  double h(int i) => _hoehen[i] ??= _messen(fluss.bloecke[i].w);

  /// Abstand vor Block [i], wenn er nicht oben auf der Seite steht.
  double abstand(int i) => fluss.erster[i] ? fluss.abstand[i] : 0;

  /// Höhe der Blöcke [von] bis vor [bis] auf einer Seite.
  double hoehe(int von, int bis) {
    var s = 0.0;
    for (var i = von; i < bis; i++) {
      s += h(i) + (i > von ? abstand(i) : 0);
    }
    return s;
  }
}

// ---------------------------------------------------------------- Seitenplan

/// Seitenplan je Gestalt, einmal je Kontext: Rollen-ID → Seiten.
final _plaene = Expando<Map<_Gestalt, Map<String, List<_Seite>>>>('kammerHeftPlaene');

void _heftSetzen(pw.Document doc, KammerKontext k, KammerPlatz p) {
  if (!k.besetzung.istBesetzt(p.id)) throw ArgumentError.value(p.id, 'p', 'heute nicht besetzt');
  final h = _Heft(k, p);
  kammerTeilSetzen(doc, k, h.teil, (s) {
    final plaene = _plaene[k] ??= {};
    final plan = plaene[h.gestalt] ??= _Planer(s, k, h.gestalt).planen();
    h.setzen(s, plan[p.id]!);
  }, bereich: p.name);
}

/// Höhe für den Inhalt einer Heftseite (ohne Kopf und Fuß).
double _platz(KammerSeiten s) =>
    KammerSatz.a4Hoch.height - _rand.vertical - s.satz.hoehe(s.kopf(), _breite) - s.satz.hoehe(s.fuss(), _breite);

/// Berechnet den Seitenplan aller heute besetzten Hefte einer Gestalt.
class _Planer {
  _Planer(this.s, this.k, this.ge)
      : hefte = [for (final p in k.besetzung.besetzt) if (_Gestalt.von(p) == ge) _Heft(k, p)],
        platz = _platz(s);

  final KammerSeiten s;
  final KammerKontext k;
  final _Gestalt ge;
  final List<_Heft> hefte;
  final double platz;
  final _masse = <(int, double), _Mass>{};

  int get n => ge.seiten;
  _Mass mass(int i, double g) => _masse[(i, g)] ??= hefte[i].messen(g);

  /// Abschnittsindizes, an denen nach der Bibel eine Seite beginnt.
  List<int> get bibel => hefte.first.bibelStarts;
  int get abschnitte => hefte.first.abschnitte.length;

  bool passt(_Mass m, int von, int bis, bool letzte) => von < bis && m.hoehe(von, bis) + (letzte ? m.unten : 0) <= platz + 0.01;

  int von(_Mass m, List<int> schnitte, int seite) => m.fluss.start[schnitte[seite]];
  int bis(_Mass m, List<int> schnitte, int seite) => seite + 1 < n ? m.fluss.start[schnitte[seite + 1]] : m.n;

  /// Passt Seite [seite] bei Abschnittsschnitten [schnitte] in allen Heften in [g]?
  bool allePassen(List<int> schnitte, int seite, double g) {
    for (var i = 0; i < hefte.length; i++) {
      final m = mass(i, g);
      if (!passt(m, von(m, schnitte, seite), bis(m, schnitte, seite), seite == n - 1)) return false;
    }
    return true;
  }

  /// Größte Grundschrift je Seite bei festen Schnitten, oder null.
  List<double>? groessen(List<int> schnitte) {
    for (var seite = 0; seite < n; seite++) {
      if (!allePassen(schnitte, seite, _raster.last)) return null;
    }
    final aus = <double>[];
    for (var seite = 0; seite < n; seite++) {
      final g = _groesste((g) => allePassen(schnitte, seite, g));
      if (g == null) return null;
      aus.add(g);
    }
    return aus;
  }

  /// Passen alle Seiten aller Hefte bei Schnitten [c] in [g]?
  bool machbar(List<int> c, double g) {
    for (var seite = 0; seite < n; seite++) {
      if (!allePassen(c, seite, g)) return false;
    }
    return true;
  }

  Map<String, List<_Seite>> ausSchnitten(List<int> schnitte, List<double> gs) => {
        for (var i = 0; i < hefte.length; i++)
          hefte[i].p.id: [
            for (var seite = 0; seite < n; seite++)
              (g: gs[seite], von: von(mass(i, gs[seite]), schnitte, seite), bis: bis(mass(i, gs[seite]), schnitte, seite)),
          ],
      };

  /// So viel größer muss die kleinste Seitenschrift mit gemeinsamen Umbrüchen
  /// sein, damit sie den Bibel-Plan ersetzen (Lesbarkeit gegen Seitenplan).
  static const _vorsprung = 0.5;

  Map<String, List<_Seite>> planen() {
    // 1. Der Seitenplan der Bibel und 2. gemeinsame Umbrüche an
    //    Abschnittsgrenzen: größte Schrift, dann so nah am Bibel-Plan wie
    //    möglich (bei Gleichstand der erste in fester Reihenfolge). Der
    //    Bibel-Plan gilt, solange er in der kleinsten Seite höchstens
    //    [_vorsprung] kleiner setzt.
    final b = groessen(bibel);
    final kombis = _kombinationen(abschnitte, n);
    final g0 = _groesste((g) => kombis.any((c) => machbar(c, g)));
    if (b != null && (g0 == null || b.reduce((x, y) => x < y ? x : y) + _vorsprung >= g0)) return ausSchnitten(bibel, b);
    if (g0 != null) {
      List<int>? beste;
      var abweichung = 0;
      for (final c in kombis.where((c) => machbar(c, g0))) {
        var d = 0;
        for (var i = 1; i < n; i++) {
          d += (c[i] - bibel[i]).abs();
        }
        if (beste == null || d < abweichung) (beste, abweichung) = (c, d);
      }
      return ausSchnitten(beste!, groessen(beste)!);
    }

    // 3. Zeugen und Zusatzrollen: Umbruch zwischen Blöcken, eine Schrift für alle.
    if (ge != _Gestalt.verdaechtig) {
      final g1 = _groesste((g) => [for (var i = 0; i < hefte.length; i++) i].every((i) => fluss(mass(i, g), g) != null));
      if (g1 != null) return {for (var i = 0; i < hefte.length; i++) hefte[i].p.id: fluss(mass(i, g1), g1)!};
    }
    _ueberlauf();
  }

  /// Umbruch zwischen Blöcken für ein Heft in [g]: genau [n] Seiten, die alle
  /// passen; Umbrüche lieber an Bibel-Seitenanfängen, dann an
  /// Abschnittsgrenzen, sonst zwischen Blöcken, nie nach einer Überschrift.
  List<_Seite>? fluss(_Mass m, double g) {
    const nie = 1 << 30;
    final b = m.n;
    final bibelStart = {for (final a in bibel.skip(1)) m.fluss.start[a]};
    final kosten = List.generate(n + 1, (_) => List.filled(b + 1, nie));
    final vorher = List.generate(n + 1, (_) => List.filled(b + 1, -1));
    kosten[0][0] = 0;
    for (var seite = 1; seite <= n; seite++) {
      for (var e = 1; e <= b; e++) {
        final letzte = seite == n;
        if (letzte && e != b) continue;
        var hoehe = letzte ? m.unten : 0.0;
        for (var a = e - 1; a >= 0; a--) {
          // Block a kommt oben auf die Seite; der bisher oberste bekommt seinen Abstand.
          hoehe += m.h(a) + (a + 1 < e ? m.abstand(a + 1) : 0);
          if (hoehe > platz + 0.01) break;
          if (kosten[seite - 1][a] >= nie) continue;
          if (a > 0 && m.fluss.bloecke[a - 1].klebt) continue;
          final c = kosten[seite - 1][a] + (a == 0 ? 0 : bibelStart.contains(a) ? 0 : m.fluss.erster[a] ? 1 : 3);
          if (c < kosten[seite][e]) {
            kosten[seite][e] = c;
            vorher[seite][e] = a;
          }
        }
      }
    }
    if (kosten[n][b] >= nie) return null;
    final seiten = <_Seite>[];
    var e = b;
    for (var seite = n; seite >= 1; seite--) {
      final a = vorher[seite][e];
      seiten.insert(0, (g: g, von: a, bis: e));
      e = a;
    }
    return seiten;
  }

  /// Nichts passt in 9 pt: Überlauf an der ersten Seite des Bibel-Plans, die
  /// in einem Heft nicht passt.
  Never _ueberlauf() {
    const g = KammerSatz.kleinsteGroesse;
    for (var seite = 0; seite < n; seite++) {
      for (var i = 0; i < hefte.length; i++) {
        final m = mass(i, g);
        final a = von(m, bibel, seite), e = bis(m, bibel, seite);
        final h = m.hoehe(a, e) + (seite == n - 1 ? m.unten : 0);
        if (h > platz) {
          final teil = hefte[i].teil;
          final wo = [k.teilTitel(teil), hefte[i].p.name].join(' / ');
          throw KammerUeberlauf.werfen(teil, seite + 1, wo, 'passt auf $n Seiten auch in ${g}pt nicht, diese Seite ${h.toStringAsFixed(1)} pt hoch, Platz ${platz.toStringAsFixed(1)} pt');
        }
      }
    }
    final wo = [k.teilTitel(hefte.first.teil), for (final h in hefte) h.p.name].join(' / ');
    throw KammerUeberlauf.werfen(hefte.first.teil, n, wo, 'kein Seitenplan in ${g}pt');
  }
}

/// Größte Grundschrift aus [_raster], für die [passt] gilt; null, wenn es auch
/// in der kleinsten nicht passt. Was in einer Größe passt, passt auch kleiner;
/// darum genügt eine Halbierungssuche (wenige Messungen).
double? _groesste(bool Function(double g) passt) {
  var a = 0, b = _raster.length - 1;
  if (!passt(_raster[b])) return null;
  while (a < b) {
    final m = (a + b) ~/ 2;
    if (passt(_raster[m])) {
      b = m;
    } else {
      a = m + 1;
    }
  }
  return _raster[b];
}

/// Alle Schnitte [0, c1, …, c(n−1)] mit 0 < c1 < … < c(n−1) < [abschnitte],
/// in fester Reihenfolge.
List<List<int>> _kombinationen(int abschnitte, int n) {
  final aus = <List<int>>[];
  void weiter(List<int> bisher) {
    if (bisher.length == n) {
      aus.add(List.unmodifiable(bisher));
      return;
    }
    for (var c = bisher.last + 1; c < abschnitte; c++) {
      weiter([...bisher, c]);
    }
  }

  weiter([0]);
  return aus;
}

// ---------------------------------------------------------------- Heft

/// Ein Heft (Rolle [p]) mit seinen Abschnitten.
class _Heft {
  _Heft(this.k, this.p)
      : r = k.rolle(p),
        gestalt = _Gestalt.von(p);

  final KammerKontext k;
  final KammerPlatz p;
  final KammerRolle r;
  final _Gestalt gestalt;

  /// Teil 10 (Rollenheft) oder 12 (Zusatzheft).
  String get teil => gestalt == _Gestalt.zusatz ? '12' : '10';
  KammerSatz get x => k.satz;
  DruckStil get stil => k.stil;

  /// Beschriftung aus `ui/10.json` bzw. `ui/12.json`.
  String u(String schluessel, [Map<String, String> werte = const {}]) => k.ui(teil, schluessel, werte);

  /// Beschriftung aus `ui/gemeinsam.json`.
  String gm(String schluessel, [Map<String, String> werte = const {}]) => k.uiGemeinsam(schluessel, werte);

  /// Spielt diese Rolle ihr Tandem heute allein (ZR 0.2)?
  bool get solo => k.besetzung.solo == p;

  // -------------------------------------------------------------- Abschnitte

  /// Die Abschnitte in Bibel-Reihenfolge (RK 1.1, ZG 0.6, ZR 0.7).
  late final List<_Abschnitt> abschnitte = switch (gestalt) {
    _Gestalt.verdaechtig => [
        _Abschnitt('titel', titel, abstand: 0),
        _Abschnitt('auftritt', auftritt, abstand: 0.5),
        _Abschnitt('werDuBist', werDuBist),
        _Abschnitt('wasAlleWissen', wasAlleWissen),
        _Abschnitt('soSpieltIhr', soSpieltIhr),
        _Abschnitt('marker', marker),
        _Abschnitt('stufe1', stufe1Verdaechtig),
        _Abschnitt('ausweichsaetze', ausweichsaetze, abstand: 0.45),
        _Abschnitt('erzaehler', erzaehler),
        _Abschnitt('stufe2', stufe2Verdaechtig),
        ..._auftraege(),
        _Abschnitt('freigabe', freigabe),
        _Abschnitt('traegst', traegst),
        _Abschnitt('aktionskarte', aktionskarte),
        _Abschnitt('bonusZiel', bonusZiel),
        _Abschnitt('fassung', fassung),
      ],
    _Gestalt.zeuge => [
        _Abschnitt('titel', titel, abstand: 0),
        _Abschnitt('auftritt', auftritt, abstand: 0.5),
        _Abschnitt('werDuBist', werDuBist),
        _Abschnitt('marker', marker),
        _Abschnitt('wasAlleWissen', wasAlleWissen),
        _Abschnitt('wasDuWeisst', wasDuWeisst),
        ..._stufe1(),
        _Abschnitt('erzaehler', erzaehler),
        _Abschnitt('stufe2', stufe2),
        _Abschnitt('zugibst', zugibst, abstand: 0.6),
        _Abschnitt('nachDemUmdrehen', nachDemUmdrehen, abstand: 0.6),
        ..._auftraege(),
        _Abschnitt('traegst', traegst),
        _Abschnitt('aktionskarte', aktionskarte),
        _Abschnitt('bonusZiel', bonusZiel),
        _Abschnitt('angeklagt', angeklagt),
        _Abschnitt('soSpieltIhr', soSpieltIhr),
      ],
    _Gestalt.zusatz => [
        _Abschnitt('titel', titel, abstand: 0),
        _Abschnitt('auftritt', auftritt, abstand: 0.5),
        _Abschnitt('werDuBist', werDuBist),
        _Abschnitt('tandem', tandem, abstand: 0.7),
        _Abschnitt('marker', marker),
        _Abschnitt('wasAlleWissen', wasAlleWissen),
        _Abschnitt('wasDuWeisst', wasDuWeisst),
        ..._stufe1(),
        _Abschnitt('erzaehler', erzaehler),
        _Abschnitt('stufe2', stufe2),
        _Abschnitt('zugibst', zugibst, abstand: 0.6),
        _Abschnitt('nachDemUmdrehen', nachDemUmdrehen, abstand: 0.6),
        ..._auftraege(),
        _Abschnitt('aktionskarte', aktionskarte),
        _Abschnitt('traegst', traegst),
        _Abschnitt('bonusZiel', bonusZiel),
        _Abschnitt('angeklagt', angeklagt),
        _Abschnitt('solo', soloAbschnitt, abstand: 0.7),
        _Abschnitt('soSpieltIhr', soSpieltIhr),
      ],
  };

  /// Seitenanfänge nach der Bibel (RK 1.1, ZG 0.6, ZR 0.7) als Abschnittsindizes.
  List<int> get bibelStarts => [
        for (final name in switch (gestalt) {
          _Gestalt.verdaechtig => const ['titel', 'marker', 'auftraege1', 'traegst'],
          _Gestalt.zeuge => const ['titel', 'wasDuWeisst', 'stufe2', 'traegst'],
          _Gestalt.zusatz => const ['titel', 'wasDuWeisst', 'stufe2'],
        })
          abschnitte.indexWhere((a) => a.name == name),
      ];

  List<_Abschnitt> _stufe1() => [
        _Abschnitt('stufe1', stufe1),
        _Abschnitt('notiz', notiz, abstand: 0.5),
        _Abschnitt('behaeltst', behaeltst, abstand: 0.45),
        _Abschnitt('verboten', verboten, abstand: 0.45),
      ];

  List<_Abschnitt> _auftraege() => [
        for (final runde in k.fall.runden) _Abschnitt('auftraege${runde.nr}', (g) => auftraege(g, runde), abstand: runde.nr == 1 ? 0.7 : 0.45),
      ];

  /// Alle Blöcke in Grundschrift [g]. Ein Abschnitt, dessen letzter Block
  /// „klebt“, klebt nicht über seine Grenze hinaus.
  _Fluss fluss(double g) {
    final f = _Fluss();
    for (final a in abschnitte) {
      f.start.add(f.bloecke.length);
      final bloecke = a.bauen(g);
      for (var i = 0; i < bloecke.length; i++) {
        final b = bloecke[i];
        f.bloecke.add(i == bloecke.length - 1 && b.klebt ? _Block(b.w, zeile: b.zeile) : b);
        f.erster.add(i == 0);
        f.abstand.add(a.abstand * g);
      }
    }
    return f;
  }

  /// Die Blöcke in Grundschrift [g], zum Messen.
  _Mass messen(double g) => _Mass(fluss(g), (w) => x.hoehe(w, _breite), x.hoehe(pw.Column(children: unten()), _breite) + notizPlatz(g));

  /// Mindestplatz für die Notizen auf der letzten Seite der Rollenhefte 1–10
  /// (RK 1.1, ZG 0.6): Marke und [_notizMindestens] Linien; Zusatzhefte haben keine.
  double notizPlatz(double g) =>
      gestalt == _Gestalt.zusatz ? 0 : g + x.hoehe(notizMarke(), _breite) + 2 + _notizMindestens * _notizAbstand + 1;

  pw.Widget notizMarke() => x.marke(gm('notizen'), groesse: KammerSatz.kleinsteGroesse);

  /// Besetzungshinweis unten auf der letzten Seite (RK 1.1, ZG G-13, ZR 0.7).
  List<pw.Widget> unten() => [
        pw.SizedBox(height: 8),
        text(gm('besetzungshinweis', {'name': p.name}), KammerSatz.kleinsteGroesse, leise: true),
      ];

  /// Stelle für Fehlermeldungen.
  String wo(int seite, int seiten) =>
      '${p.name}, ${k.klartext(gm('fuss.seite', {'seite': '$seite', 'seiten': '$seiten'}))}';

  /// Setzt die Seiten nach Plan. Auf der letzten Seite der Rollenhefte füllen
  /// Notizlinien den freien Platz; ganz unten steht der Besetzungshinweis.
  void setzen(KammerSeiten s, List<_Seite> seiten) {
    final platz = _platz(s);
    for (var i = 0; i < seiten.length; i++) {
      final seite = seiten[i];
      final f = fluss(seite.g);
      final kinder = <pw.Widget>[
        for (var j = seite.von; j < seite.bis; j++) ...[
          if (j > seite.von && f.erster[j] && f.abstand[j] > 0) pw.SizedBox(height: f.abstand[j]),
          if (j == seite.von && f.bloecke[j].zeile)
            pw.Container(decoration: const pw.BoxDecoration(border: pw.Border(top: _linie)), child: f.bloecke[j].w)
          else
            f.bloecke[j].w,
        ],
      ];
      var fuss = <pw.Widget>[];
      if (i == seiten.length - 1) {
        fuss = unten();
        if (gestalt != _Gestalt.zusatz) {
          final marke = notizMarke();
          final frei = platz - x.hoehe(pw.Column(children: [...kinder, ...fuss]), _breite) - x.hoehe(marke, _breite) - seite.g - 2;
          final zeilen = (frei / _notizAbstand).floor();
          if (zeilen > 0) {
            fuss = [pw.SizedBox(height: seite.g), marke, pw.SizedBox(height: 2), x.notizlinien(zeilen, abstand: _notizAbstand), ...fuss];
          }
        }
      }
      final hoehe = x.hoehe(pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [...kinder, ...fuss]), _breite);
      s.pruefeHoehe(hoehe, platz, wo: wo(i + 1, seiten.length));
      s.vollSeite(
        rand: _rand,
        (c) => pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.stretch, children: [
          s.kopf(),
          pw.Expanded(child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [...kinder, pw.Spacer(), ...fuss])),
          s.fuss(c),
        ]),
      );
    }
  }

  // -------------------------------------------------------------- Bausteine

  /// Abschnittsüberschrift mit feiner Linie darunter.
  pw.Widget h1(String t, double g) => pw.Padding(
        padding: pw.EdgeInsets.only(bottom: g * 0.25),
        child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.stretch, children: [
          x.fett(t, groesse: g + 2),
          pw.SizedBox(height: 1.5),
          pw.Container(height: 0.5, color: DruckStil.linie),
        ]),
      );

  /// Unterüberschrift (Teil eines Abschnitts).
  pw.Widget h2(String t, double g) => pw.Padding(
        padding: pw.EdgeInsets.only(bottom: g * 0.25),
        child: x.fett(t, groesse: g + 1),
      );

  /// Etikett in Grundschrift, fett.
  pw.Widget etikett(String t, double g) => pw.Padding(
        padding: pw.EdgeInsets.only(bottom: g * 0.15),
        child: x.fett(t, groesse: g),
      );

  /// Absatz mit Auszeichnung (`**fett**`, `*kursiv*` grau, Zeilen, Absätze) in
  /// Größe [g], mit knappem Zeilenabstand. Leer aufgelöst: nichts.
  pw.Widget text(String t, double g, {bool leise = false}) =>
      x.absatz(t, groesse: g, leise: leise, abstand: g * 0.35, zeilenabstand: _zeilenabstand);

  /// Fließtext mit fettem Etikett davor.
  pw.Widget mitEtikett(String etikett, String t, double g) => text('**${k.klartext(etikett)}:** ${k.text(t)}', g);

  /// Listenpunkte (Strich, Zahl, Buchstabe oder ohne), je einer ein Block.
  /// Einträge, die leer aufgelöst werden, fallen weg; die Nummern rücken nach.
  List<_Block> liste(Iterable<String> eintraege, double g, {KammerNummer nummer = KammerNummer.strich, bool leise = false}) {
    final texte = k.texte(eintraege);
    final einzug = nummer.einzug(g);
    return [
      for (var i = 0; i < texte.length; i++)
        _Block(pw.Padding(
          padding: pw.EdgeInsets.only(top: i == 0 ? 0 : g * 0.1),
          child: pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            if (einzug > 0) pw.SizedBox(width: einzug, child: pw.Text(nummer.zeichen(i), style: stil.text(g).copyWith(lineSpacing: g * _zeilenabstand))),
            pw.Expanded(child: text(texte[i], g, leise: leise)),
          ]),
        )),
    ];
  }

  /// Eine Liste als ein Widget (in Tabellenzellen und Kästen).
  pw.Widget listeWidget(Iterable<String> eintraege, double g, {KammerNummer nummer = KammerNummer.strich}) =>
      pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [for (final b in liste(eintraege, g, nummer: nummer)) b.w]);

  /// Text zum Vorlesen (Auftritt, Taschenkontrolle): Balken links.
  pw.Widget vortrag(String t, double g) => pw.Container(
        padding: const pw.EdgeInsets.fromLTRB(9, 1, 0, 2),
        decoration: const pw.BoxDecoration(border: pw.Border(left: pw.BorderSide(color: DruckStil.tinte, width: 2))),
        child: text(t, g),
      );

  /// Kasten mit Rahmen, grau hinterlegt oder weiß.
  pw.Widget kasten(List<pw.Widget> inhalt, {bool grau = false}) =>
      x.kasten(inhalt, grau: grau, rahmen: 0.6, innen: const pw.EdgeInsets.fromLTRB(7, 4, 7, 5));

  /// Tabelle als Blöcke, je Zeile einer (die Zeilen einer Seite schließen
  /// lückenlos aneinander). Zellen: Text oder Widget. Zeilen, deren erster Text
  /// leer aufgelöst wird, fallen weg. [kopf] klebt an der ersten Zeile.
  List<_Block> tabelle(List<List<Object?>> zeilen, double g, {List<String>? kopf, required List<double> spalten}) {
    pw.Widget zelle(Object? inhalt, {bool fett = false}) => pw.Padding(
          padding: _zelle,
          child: switch (inhalt) {
            null => pw.SizedBox(),
            final pw.Widget w => w,
            final String s => text(fett ? '**${k.text(s)}**' : s, g),
            _ => text('$inhalt', g),
          },
        );
    pw.Widget reihe(List<pw.Widget> zellen, {required bool oben, bool grau = false}) => x.tabellenzeile(zellen, spalten, oben: oben, grau: grau);
    final sichtbar = [
      for (final z in zeilen)
        if (z.isEmpty || z.first is! String || !k.leer(z.first! as String)) z,
    ];
    return [
      if (kopf != null) _Block(reihe([for (final t in kopf) zelle(t, fett: true)], oben: true, grau: true), klebt: true),
      for (var i = 0; i < sichtbar.length; i++)
        _Block(
          reihe([for (var j = 0; j < spalten.length; j++) zelle(j < sichtbar[i].length ? sichtbar[i][j] : null)], oben: kopf == null && i == 0),
          zeile: kopf != null || i > 0,
        ),
    ];
  }

  // -------------------------------------------------------------- Seite 1

  List<_Block> titel(double g) => [
        _Block(x.titel(u('kopf', {'name': p.name, 'platz': '${p.platz}', if (p.tandem case final t?) 'tandem': '$t'}), groesse: 17)),
      ];

  List<_Block> auftritt(double g) => [_Block(h1(gm('heft.deinAuftritt'), g), klebt: true), _Block(vortrag(r.auftritt, g))];

  List<_Block> werDuBist(double g) => [
        _Block(h1(gm('heft.werDuBist'), g), klebt: true),
        _Block(text(r.werDuBist, g)),
        if (r.haltung case final h?) _Block(pw.Padding(padding: pw.EdgeInsets.only(top: g * 0.35), child: text(h, g, leise: true))),
      ];

  /// Kasten „Dein Tandem“ (ZR x.4). Spielt die Rolle allein, steht er in der
  /// Ersatzfassung seiner Platzhalter (ZR 1.12); der Solo-Abschnitt folgt am Ende.
  List<_Block> tandem(double g) => [
        if (r.tandemKasten case final t?) _Block(kasten([mitEtikett(u('deinTandem'), t, g)])),
      ];

  List<_Block> marker(double g) => [_Block(h1(gm('heft.deineMarker'), g), klebt: true), _Block(text(r.marker.zeile, g))];

  List<_Block> wasAlleWissen(double g) =>
      [_Block(h1(gm('ueberschrift.wasAlleWissen'), g), klebt: true), ...liste(k.inhalt.gemeinsam.wasAlleWissen, g)];

  // -------------------------------------------------------------- Wissen und Stufe 1

  /// „Was du weißt“ (ZG x.4, ZR x.5): Zeit und Wissen; ist eine Zeile nicht
  /// gleich frei, steht dahinter grau, ab wann (ZG 0.6: „erst nach dem
  /// Umdrehen“, „frühestens in Runde 3“ oder der eigene Zusatz).
  List<_Block> wasDuWeisst(double g) {
    final w = r.wasDuWeisst;
    if (w == null) return const [];
    String? frei(KammerWissenZeile z) =>
        z.zusatz ??
        switch (z.frei) {
          KammerFrei.offen => null,
          KammerFrei.karte => gm('heft.frei.karte'),
          KammerFrei.runde3 => gm('heft.frei.runde3'),
        };
    return [
      _Block(h1(gm('heft.wasDuWeisst'), g), klebt: true),
      ...tabelle(
        [
          for (final z in w.zeilen)
            [
              z.zeit,
              switch (frei(z)) {
                final f? => '${k.text(z.text)} *(${k.klartext(f)})*',
                null => z.text,
              },
            ],
        ],
        g,
        spalten: [1.1, 7.9],
      ),
    ];
  }

  /// Stufe 1 der Zeugen und Zusatzrollen (ZG G-03, ZR ZG-03), erster Teil:
  /// Überschrift, eine Einleitung (`regie`, bei Tugba ZR 8.6) ohne eigene
  /// Überschrift, „Das sagst du jedem“. Leere Listen bekommen keine Überschrift.
  List<_Block> stufe1(double g) {
    final s1 = r.stufe1;
    final sagst = liste(s1.sagstDuJedem, g);
    return [
      _Block(h1(gm('heft.stufe1'), g), klebt: true),
      if (s1.regie case final regie?) _Block(pw.Padding(padding: pw.EdgeInsets.only(bottom: g * 0.3), child: text(regie, g)), klebt: sagst.isNotEmpty),
      if (sagst.isNotEmpty) ...[_Block(etikett(gm('heft.sagstDuJedem'), g), klebt: true), ...sagst],
    ];
  }

  /// Joannas Notiz von 23:57 (ZG 4.5) im Kasten, zweispaltig, darunter der Hinweis.
  List<_Block> notiz(double g) {
    final n = r.notiz;
    if (n == null) return const [];
    final zeilen = k.texte(n.zeilen);
    final links = (zeilen.length + 1) ~/ 2;
    return [
      _Block(kasten([
        etikett(u('notiz'), g),
        pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Expanded(child: listeWidget(zeilen.take(links), g, nummer: KammerNummer.keine)),
          pw.SizedBox(width: 10),
          pw.Expanded(child: listeWidget(zeilen.skip(links), g, nummer: KammerNummer.keine)),
        ]),
        pw.SizedBox(height: g * 0.3),
        text(n.hinweis, g, leise: true),
      ])),
    ];
  }

  /// „Das behältst du für dich“: Tarnsätze auf bestimmte Fragen.
  List<_Block> behaeltst(double g) {
    final a = r.stufe1.ausweichsaetze;
    if (a.isEmpty) return const [];
    return [
      _Block(etikett(gm('heft.behaeltstDuFuerDich'), g), klebt: true),
      ...tabelle([for (final z in a) [z.frage, z.antwort]], g, kopf: [gm('heft.wennJemandFragt'), gm('heft.sagstDu')], spalten: [2, 3]),
    ];
  }

  /// „Verboten“ (Sätze, die gelogen wären) in einer Zeile wie in der Bibel
  /// (ZG x.5: „Verboten: „…“ · „…““), dazu ein Markersatz, falls es einen gibt.
  List<_Block> verboten(double g) {
    final s1 = r.stufe1;
    final v = k.texte(s1.verboten);
    return [
      if (v.isNotEmpty) _Block(pw.Padding(padding: pw.EdgeInsets.only(top: g * 0.15), child: mitEtikett(gm('heft.verboten'), v.join(' · '), g))),
      if (s1.markersatz case final m?) _Block(pw.Padding(padding: pw.EdgeInsets.only(top: g * 0.4), child: text(m, g))),
    ];
  }

  /// Stufe 1 der Verdächtigen (RK 1.1, 1.3), erster Teil: „Das sagst du“ mit
  /// den zwei Kernsätzen und der Regiesatz.
  List<_Block> stufe1Verdaechtig(double g) {
    final s1 = r.stufe1;
    return [
      _Block(h1(u('stufe1'), g), klebt: true),
      _Block(etikett(u('kernsaetze'), g), klebt: true),
      ...liste(s1.kernsaetze, g),
      if (s1.regie case final regie?) _Block(pw.Padding(padding: pw.EdgeInsets.only(top: g * 0.3), child: mitEtikett(u('regie'), regie, g))),
    ];
  }

  /// Die sieben Ausweichsätze der Verdächtigen und der Markersatz (RK 1.3).
  List<_Block> ausweichsaetze(double g) {
    final s1 = r.stufe1;
    return [
      ...tabelle([for (final a in s1.ausweichsaetze) [a.frage, a.antwort]], g, kopf: [gm('heft.wennJemandFragt'), gm('heft.sagstDu')], spalten: [2, 3.4]),
      if (s1.markersatz case final m?) _Block(pw.Padding(padding: pw.EdgeInsets.only(top: g * 0.4), child: text(m, g))),
    ];
  }

  /// „Wenn der Erzähler fragt“ (RK 1.8, ZG 0.4, ZR 0.5): Impuls und Antwort.
  List<_Block> erzaehler(double g) {
    final impulse = {for (final i in k.inhalt.erzaehlerheft.impulse) i.id: i};
    return [
      _Block(h1(gm('heft.wennDerErzaehlerFragt'), g), klebt: true),
      ...tabelle(
        [
          for (final a in r.wennDerErzaehlerFragt)
            [u('impuls', {'id': a.impuls, 'titel': k.text(impulse[a.impuls]!.titel)}), a.antwort],
        ],
        g,
        spalten: [1.9, 5],
      ),
    ];
  }

  // -------------------------------------------------------------- Stufe 2

  /// Stufe 2 der Verdächtigen (RK 1.1, MECH 4.2): Was du verbirgst, die drei
  /// Sobald-Fälle (a)–(c), Was du dann sagst, Marker, Ab dann.
  List<_Block> stufe2Verdaechtig(double g) {
    final s2 = r.stufe2;
    pw.Widget oben(pw.Widget w, [double abstand = 0.4]) => pw.Padding(padding: pw.EdgeInsets.only(top: g * abstand), child: w);
    return [
      _Block(h1(u('stufe2'), g), klebt: true),
      if (s2.wasDuVerbirgst case final v?) _Block(mitEtikett(u('wasDuVerbirgst'), v, g)),
      _Block(oben(text(u('ausloeser.kopf'), g)), klebt: true),
      ...liste(s2.ausloeser, g, nummer: KammerNummer.buchstabe),
      _Block(oben(text(u('ausloeser.fuss'), g), 0.2)),
      for (final (schluessel, t) in [('wasDuDannSagst', s2.wasDuDannSagst), ('marker', s2.marker), ('abDann', s2.abDann)])
        if (t != null) _Block(oben(mitEtikett(u(schluessel), t, g))),
    ];
  }

  /// Stufe 2 der Zeugen und Zusatzrollen: Rundensperre und Sobald-Sätze (ZG
  /// G-04, ZR ZG-04). Ein einzelner Satz (Tugba) steht ohne Nummer.
  List<_Block> stufe2(double g) {
    final s2 = r.stufe2;
    final sperre = r.geheimniskarte.sperre;
    final ausloeser = k.texte(s2.ausloeser);
    return [
      _Block(h1(gm('heft.stufe2'), g), klebt: true),
      if (sperre > 1)
        _Block(pw.Padding(padding: pw.EdgeInsets.only(bottom: g * 0.25), child: text('**${k.klartext(gm('heft.rundensperre', {'runde': '$sperre'}))}**', g)), klebt: true),
      if (s2.wasDuVerbirgst case final v?) _Block(pw.Padding(padding: pw.EdgeInsets.only(bottom: g * 0.25), child: text(v, g)), klebt: true),
      ...liste(ausloeser, g, nummer: ausloeser.length > 1 ? KammerNummer.zahl : KammerNummer.keine),
      for (final t in [s2.wasDuDannSagst, s2.marker, s2.abDann])
        if (t != null) _Block(pw.Padding(padding: pw.EdgeInsets.only(top: g * 0.3), child: text(t, g))),
    ];
  }

  /// „Was du dann zugibst“: die Innenseite der eigenen Geheimniskarte (ZG 0.6,
  /// ZR 0.7) mit dem Domino-Hinweis.
  List<_Block> zugibst(double g) {
    final gk = r.geheimniskarte;
    return [
      _Block(h2(gm('heft.wasDuDannZugibst'), g), klebt: true),
      _Block(kasten(grau: true, [
        text(gk.wasIchZugebe, g),
        pw.SizedBox(height: g * 0.35),
        mitEtikett(gm('karte.undNochEtwas'), gk.undNochEtwas, g),
      ])),
    ];
  }

  List<_Block> nachDemUmdrehen(double g) {
    final s2 = r.stufe2;
    final saetze = liste(s2.nachDemUmdrehen, g);
    final einleitung = s2.nachDemUmdrehenEinleitung;
    if (einleitung == null && saetze.isEmpty) return const [];
    return [
      _Block(h2(gm('heft.nachDemUmdrehen'), g), klebt: true),
      if (einleitung != null) _Block(pw.Padding(padding: pw.EdgeInsets.only(bottom: g * 0.2), child: text(einleitung, g)), klebt: saetze.isNotEmpty),
      ...saetze,
    ];
  }

  // -------------------------------------------------------------- Gesprächsaufträge

  /// Gesprächsaufträge bzw. Nachbohr-Ziele von Runde [runde] (RK 1.2, ZG 0.2,
  /// ZR ZG-09). Fehlt die Zielrolle heute, steht nur das Ausweichziel da, ohne
  /// ihren Namen. Zusatzhefte tragen unter der Überschrift die Ausweichregel.
  List<_Block> auftraege(double g, KammerRunde runde) {
    final b = k.besetzung;
    final auftraege = r.gespraechsauftraege.where((a) => a.runde == runde.nr).toList();
    pw.Widget ziel(KammerAuftrag a, bool erstes) {
      final nr = k.klartext(gm('heft.ziel', {'nr': '${a.nr}'}));
      final List<pw.Widget> inhalt;
      if (b.istBesetzt(a.ziel)) {
        inhalt = [
          text('**$nr · ${k.inhalt.platzVon(a.ziel).name}:** ${k.text(a.frage)}', g),
          if (a.nachschlag case final n?) pw.Padding(padding: pw.EdgeInsets.only(top: g * 0.2), child: mitEtikett(gm('heft.nachschlag'), n, g)),
        ];
      } else {
        final ausweich = k.text(a.ausweich ??
            (gestalt == _Gestalt.zusatz ? u('ausweichRegel') : throw StateError('${p.name}: Ziel ${a.ziel} fehlt heute, kein Ausweichziel')));
        // Beginnt das Ausweichziel mit dem Namen einer besetzten Rolle („Can: „…““),
        // steht der Name wie bei jedem Ziel im Kopf („Ziel 2 · Can:“), nicht doppelt mit Doppelpunkt.
        final vorne = RegExp(r'^([^\s:*„“]+): ').firstMatch(ausweich);
        final name = vorne?.group(1);
        inhalt = [
          if (vorne != null && name != null && b.besetzt.any((q) => q.name == name))
            text('**$nr · $name:** ${ausweich.substring(vorne.end)}', g)
          else
            text('**$nr:** $ausweich', g),
        ];
      }
      return pw.Padding(
        padding: pw.EdgeInsets.only(top: erstes ? 0 : g * 0.45),
        child: pw.Container(
          padding: const pw.EdgeInsets.only(left: 6),
          decoration: const pw.BoxDecoration(border: pw.Border(left: _linie)),
          child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: inhalt),
        ),
      );
    }

    final ueberschrift = gestalt == _Gestalt.zeuge ? gm('heft.nachbohrZiele') : u('gespraechsauftraege');
    return [
      if (runde.nr == 1) ...[
        _Block(h1(ueberschrift, g), klebt: true),
        if (gestalt == _Gestalt.zusatz)
          _Block(pw.Padding(padding: pw.EdgeInsets.only(bottom: g * 0.3), child: text(u('ausweichRegel'), g, leise: true)), klebt: true),
      ],
      _Block(etikett(gm('runde.titel', {'runde': '${runde.nr}', 'name': k.text(runde.name)}), g), klebt: true),
      for (var i = 0; i < auftraege.length; i++) _Block(ziel(auftraege[i], i == 0)),
    ];
  }

  /// „Was du über andere sagen darfst“ (RK 1.4, 8.1), nur die Verdächtigen.
  List<_Block> freigabe(double g) {
    final f = r.freigabe;
    if (f == null) return const [];
    return [
      _Block(h1(u('freigabe'), g), klebt: true),
      _Block(pw.Padding(padding: pw.EdgeInsets.only(bottom: g * 0.4), child: text(u('freigabe.kopf'), g)), klebt: true),
      ...tabelle(
        [
          [listeWidget(f.sofort, g), listeWidget(f.nachDemMarker, g), listeWidget(f.nachDerKarte, g)],
        ],
        g,
        kopf: [u('freigabe.sofort'), u('freigabe.marker'), u('freigabe.karte')],
        spalten: [1, 1, 1],
      ),
    ];
  }

  // -------------------------------------------------------------- Letzte Seite

  List<_Block> traegst(double g) => [
        _Block(h1(gm('heft.wasDuBeiDirTraegst'), g), klebt: true),
        _Block(vortrag(r.wasDuBeiDirTraegst.text, g)),
        if (r.wasDuBeiDirTraegst.hinweis case final h?) _Block(pw.Padding(padding: pw.EdgeInsets.only(top: g * 0.3), child: text(h, g, leise: true))),
      ];

  /// „Deine Aktionskarte“: Abbildung der Karte (MECH 4.3: Kopf, Name, ab
  /// Runde, Wirkung, Grenzen, Fuß) und daneben der Tipp, der nur im Heft steht.
  List<_Block> aktionskarte(double g) {
    final a = r.aktionskarte;
    final karte = pw.Container(
      padding: const pw.EdgeInsets.fromLTRB(9, 6, 9, 7),
      decoration: pw.BoxDecoration(border: pw.Border.all(color: DruckStil.tinte, width: 0.9)),
      child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        x.marke(u('aktion.kopf', {'name': p.name}), groesse: KammerSatz.kleinsteGroesse),
        pw.SizedBox(height: g * 0.3),
        pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
          pw.Flexible(child: text('**${k.klartext(a.name)}**', g + 2)),
          pw.SizedBox(width: g * 0.8),
          text(gm('ab.runde', {'runde': '${a.abRunde}'}), g, leise: true),
        ]),
        pw.SizedBox(height: g * 0.3),
        mitEtikett(u('aktion.wirkung'), a.wirkung, g),
        pw.SizedBox(height: g * 0.3),
        mitEtikett(u('aktion.grenzen'), a.grenzen, g),
        pw.SizedBox(height: g * 0.4),
        text(u('aktion.fuss'), g, leise: true),
      ]),
    );
    return [
      _Block(h1(gm('heft.deineAktionskarte'), g), klebt: true),
      _Block(pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Expanded(flex: 3, child: karte),
        pw.SizedBox(width: 12),
        pw.Expanded(
          flex: 2,
          child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            etikett(gm('heft.tipp'), g),
            text(a.tipp, g),
          ]),
        ),
      ])),
    ];
  }

  /// „Dein Bonus-Ziel“ (MECH 7.3) im Kasten. Beginnt der Text selbst mit der
  /// Überschrift („**Dein Bonus-Ziel:** …“, RK 1.6), steht sie nicht doppelt da.
  List<_Block> bonusZiel(double g) {
    final ueberschrift = gm('heft.deinBonusZiel');
    final doppelt = k.klartext(r.bonusZiel.text).trimLeft().startsWith(k.klartext(ueberschrift));
    return [
      if (!doppelt) _Block(h1(ueberschrift, g), klebt: true),
      _Block(kasten([
        text(r.bonusZiel.text, g),
        if (r.bonusZiel.hinweis case final h?) ...[pw.SizedBox(height: g * 0.3), text(h, g, leise: true)],
      ])),
    ];
  }

  /// „Deine versiegelte Fassung“ (RK 1.1), nur die Verdächtigen.
  List<_Block> fassung(double g) => [
        if (r.fassung case final f?) ...[
          _Block(h1(u('fassung'), g), klebt: true),
          _Block(text(u('fassung.text', {'code': f.code}), g)),
        ],
      ];

  /// „Wenn du angeklagt wirst: ‚Ich war es nicht.‘“ (ZG G-06, ZR ZG-07).
  List<_Block> angeklagt(double g) => [_Block(h1(gm('heft.angeklagt'), g))];

  /// Solo-Abschnitt (ZR x.12): nur beim kleineren Platz eines Tandems, der heute allein spielt.
  List<_Block> soloAbschnitt(double g) => [
        if (r.solo case final t? when solo) _Block(kasten([text(t, g)])),
      ];

  /// „So spielt ihr“: die Tischregeln in Kurzform (MECH 1.4).
  List<_Block> soSpieltIhr(double g) => [
        _Block(h1(gm('ueberschrift.soSpieltIhr'), g), klebt: true),
        _Block(kasten(grau: true, [text(k.inhalt.gemeinsam.soSpieltIhr, g)])),
      ];
}
