// Persönliche Ziele der Einfluss-Schicht (Finale §3.9): zwei Sterne je Figur als kleine
// Bedingungssprache, ausgewertet gegen das Protokoll der Nacht. Vor der Anklage ist jeder Stern
// „offen“, „erreicht“ (steht schon fest) oder „verloren“ (nicht mehr zu schaffen). Kein Atom kennt
// die Lösung des Falls.
//
//   B := {"alle":[B..]} | {"eine":[B..]} | {"nicht":B} | {"mind":[W,int]} | {"hoechstens":[W,int]}
//      | {"gleich":[W, W|wert]}
//   W := "angeklagt" | "bekannt:<faktId>" | "gestanden:<fig|ich>" | "zuege:<art>" | "zieleAuf:<art>:<fig|ich>"
//      | "ertappt:<fig|ich>" | "geruecht:<fig|ich>" | "zusammenhalt" | "spuk" | "rest"
//      | "auspackRunde:<fig|ich>" | "jedeRunde:<art>"
//
// Werte: `angeklagt` ist eine Figur; alle übrigen Atome sind ganze Zahlen (Wahrheitswerte als 0 und 1,
// `auspackRunde` ist [nieRunde], wer nie auspackt). `zuege` und `zieleAuf` zählen die eigenen Züge,
// `geruecht` die Runden mit Gerücht, `ertappt` die Male. Ein Wert in `gleich` ist eine Zahl, true/false,
// eine Figur oder `ich`.
import 'einfluss.dart';

/// `auspackRunde` für eine Figur, die nie auspackt (nach der letzten Runde).
const nieRunde = 4;

/// Live-Stand eines Sterns.
enum ZielStand { offen, erreicht, verloren }

/// Eine Bedingung der Zielsprache; [toJson] gibt die Datenform zurück.
sealed class ZielBedingung {
  const ZielBedingung();
  Object toJson();
}

class AlleBedingung extends ZielBedingung {
  final List<ZielBedingung> teile;
  const AlleBedingung(this.teile);
  @override
  Object toJson() => {'alle': [for (final t in teile) t.toJson()]};
}

class EineBedingung extends ZielBedingung {
  final List<ZielBedingung> teile;
  const EineBedingung(this.teile);
  @override
  Object toJson() => {'eine': [for (final t in teile) t.toJson()]};
}

class NichtBedingung extends ZielBedingung {
  final ZielBedingung teil;
  const NichtBedingung(this.teil);
  @override
  Object toJson() => {'nicht': teil.toJson()};
}

/// `mind` (≥) oder `hoechstens` (≤) gegen eine Zahl.
class GrenzBedingung extends ZielBedingung {
  final ZielWert wert;
  final int grenze;
  final bool mindestens;
  const GrenzBedingung(this.wert, this.grenze, {required this.mindestens});
  @override
  Object toJson() => {mindestens ? 'mind' : 'hoechstens': [wert.text, grenze]};
}

class GleichBedingung extends ZielBedingung {
  final ZielWert links;

  /// Rechts: ein Atom, eine Zahl oder eine Figur (`ich` erlaubt).
  final ZielWert? rechtsWert;
  final int? rechtsZahl;
  final String? rechtsFigur;
  const GleichBedingung(this.links, {this.rechtsWert, this.rechtsZahl, this.rechtsFigur});
  @override
  Object toJson() => {'gleich': [links.text, rechtsWert?.text ?? rechtsZahl ?? rechtsFigur]};
}

/// Arten der Atome.
enum WertArt { angeklagt, bekannt, gestanden, zuege, zieleAuf, ertappt, geruecht, zusammenhalt, spuk, rest, auspackRunde, jedeRunde }

/// Ein Atom der Zielsprache mit seinen Argumenten.
class ZielWert {
  final WertArt art;

  /// Text wie in den Daten (`zieleAuf:decken:ahmet`).
  final String text;
  final String? fakt, figur;
  final ZugArt? zug;
  const ZielWert(this.art, this.text, {this.fakt, this.figur, this.zug});

  /// Figur oder Zahl? (`angeklagt` ist die einzige Figur.)
  bool get istFigur => art == WertArt.angeklagt;
}

/// Ein Stern einer Figur: Nummer (1, 2), Kennung und Bedingung.
class EinflussZiel {
  final String figur, id;
  final int nr;
  final ZielBedingung bedingung;
  const EinflussZiel(this.figur, this.nr, this.id, this.bedingung);

  /// Text-Schlüssel des Sterns.
  String get schluessel => 'einfluss.ziel.$figur.$nr';
}

/// Liest eine Bedingung; unbekannte Atome, Figuren, Fakten oder Formen werfen [FormatException].
ZielBedingung zielBedingung(Object? j, EinflussRegeln r) {
  if (j is! Map || j.length != 1) throw FormatException('Bedingung: genau ein Schlüssel erwartet: $j');
  final e = j.entries.single;
  final v = e.value;
  List<Object?> paar() {
    if (v is! List || v.length != 2) throw FormatException('${e.key}: genau zwei Einträge');
    return v;
  }

  switch (e.key) {
    case 'alle' || 'eine':
      if (v is! List || v.isEmpty) throw FormatException('${e.key}: nicht leere Liste');
      final teile = [for (final x in v) zielBedingung(x, r)];
      return e.key == 'alle' ? AlleBedingung(teile) : EineBedingung(teile);
    case 'nicht':
      return NichtBedingung(zielBedingung(v, r));
    case 'mind' || 'hoechstens':
      final p = paar();
      final w = zielWert(p[0], r);
      if (w.istFigur) throw FormatException('${e.key}: ${w.text} ist keine Zahl');
      if (p[1] is! int) throw FormatException('${e.key}: Grenze ist eine ganze Zahl');
      return GrenzBedingung(w, p[1] as int, mindestens: e.key == 'mind');
    case 'gleich':
      final p = paar();
      final links = zielWert(p[0], r);
      final rechts = p[1];
      if (rechts is bool || rechts is int) {
        if (links.istFigur) throw const FormatException('gleich: angeklagt vergleicht nur mit Figuren');
        return GleichBedingung(links, rechtsZahl: rechts is bool ? (rechts ? 1 : 0) : rechts as int);
      }
      if (rechts is String && _istAtom(rechts)) {
        final w = zielWert(rechts, r);
        if (w.istFigur != links.istFigur) throw const FormatException('gleich: Figur und Zahl gemischt');
        return GleichBedingung(links, rechtsWert: w);
      }
      if (rechts is String && (rechts == 'ich' || r.figuren.contains(rechts))) {
        if (!links.istFigur) throw const FormatException('gleich: eine Zahl vergleicht nicht mit einer Figur');
        return GleichBedingung(links, rechtsFigur: rechts);
      }
      throw FormatException('gleich: unbekannter Wert $rechts');
    default:
      throw FormatException('unbekannte Verknüpfung ${e.key}');
  }
}

const _einfacheAtome = {'angeklagt', 'zusammenhalt', 'spuk', 'rest'};

bool _istAtom(String s) => _einfacheAtome.contains(s) || s.contains(':');

/// Liest ein Atom ([ZielWert]); Fehler als [FormatException].
ZielWert zielWert(Object? j, EinflussRegeln r) {
  if (j is! String) throw FormatException('Atom erwartet: $j');
  final t = j.split(':');
  String figur(String f) => f == 'ich' || r.figuren.contains(f) ? f : throw FormatException('$j: unbekannte Figur $f');
  ZugArt art(String a) => ZugArt.lesen(a) ?? (throw FormatException('$j: unbekannte Zugart $a'));
  void laenge(int n) {
    if (t.length != n) throw FormatException('$j: falsche Form');
  }

  switch (t.first) {
    case 'angeklagt':
      laenge(1);
      return ZielWert(WertArt.angeklagt, j);
    case 'zusammenhalt' || 'spuk' || 'rest':
      laenge(1);
      return ZielWert(WertArt.values.byName(t.first), j);
    case 'bekannt':
      laenge(2);
      if (!r.faktIds.contains(t[1])) throw FormatException('$j: unbekannter Fakt');
      return ZielWert(WertArt.bekannt, j, fakt: t[1]);
    case 'gestanden' || 'ertappt' || 'geruecht' || 'auspackRunde':
      laenge(2);
      return ZielWert(WertArt.values.byName(t.first), j, figur: figur(t[1]));
    case 'zuege' || 'jedeRunde':
      laenge(2);
      return ZielWert(WertArt.values.byName(t.first), j, zug: art(t[1]));
    case 'zieleAuf':
      laenge(3);
      final a = art(t[1]);
      if (r.arten[a]?.ziel == null || r.arten[a]!.ziel == ZielRegel.keins) throw FormatException('$j: ${a.name} hat kein Ziel');
      return ZielWert(WertArt.zieleAuf, j, zug: a, figur: figur(t[2]));
    default:
      throw FormatException('unbekanntes Atom $j');
  }
}

/// Spanne möglicher Endwerte eines Zahl-Atoms ([hoch] null: nach oben offen).
class _Spanne {
  final int tief;
  final int? hoch;
  const _Spanne(this.tief, this.hoch);
  const _Spanne.genau(int w) : this(w, w);
  bool get fest => hoch == tief;
}

/// Auswertung gegen ein Protokoll für die Figur [ich].
class _Auswertung {
  _Auswertung(this.p, this.r, this.ich);
  final NachtProtokoll p;
  final EinflussRegeln r;
  final String ich;

  int get _offen => p.fertig ? 0 : 3 - p.rundenFertig;
  String _fig(String f) => f == 'ich' ? ich : f;
  Iterable<EinflussZug> _eigene() sync* {
    for (final runde in p.zuege.keys) {
      yield p.zug(runde, ich)!;
    }
  }

  /// Figur von `angeklagt`; `null`, solange die Anklage aussteht.
  String? person(ZielWert w) => p.angeklagt;

  _Spanne zahl(ZielWert w) {
    final offen = _offen;
    switch (w.art) {
      case WertArt.angeklagt:
        throw StateError('angeklagt ist keine Zahl');
      case WertArt.bekannt:
        if (p.sichtbar.contains(w.fakt)) return const _Spanne.genau(1);
        return p.fertig ? const _Spanne.genau(0) : const _Spanne(0, 1);
      case WertArt.gestanden:
        final f = _fig(w.figur!);
        if (p.auspackRunde(f) != null) return const _Spanne.genau(1);
        return offen > 0 && p.besetzt.contains(f) ? const _Spanne(0, 1) : const _Spanne.genau(0);
      case WertArt.auspackRunde:
        final f = _fig(w.figur!);
        final a = p.auspackRunde(f);
        if (a != null) return _Spanne.genau(a);
        return offen > 0 && p.besetzt.contains(f) ? _Spanne(p.rundenFertig + 1, nieRunde) : const _Spanne.genau(nieRunde);
      case WertArt.zuege:
        final c = _eigene().where((z) => z.art == w.zug).length;
        final schon = w.zug == ZugArt.auspacken && p.auspackRunde(ich) != null;
        final noch = (r.arten[w.zug]?.einmal ?? false) ? (schon || offen == 0 ? 0 : 1) : offen;
        return _Spanne(c, c + noch);
      case WertArt.zieleAuf:
        final f = _fig(w.figur!);
        final c = _eigene().where((z) => z.art == w.zug && z.ziel == f).length;
        final moeglich = p.besetzt.contains(f) && (f != ich || r.arten[w.zug]!.ziel == ZielRegel.jede);
        return _Spanne(c, c + (moeglich ? offen : 0));
      case WertArt.ertappt:
        final c = p.ertappt[_fig(w.figur!)] ?? 0;
        return p.fertig ? _Spanne.genau(c) : _Spanne(c, null);
      case WertArt.geruecht:
        final f = _fig(w.figur!);
        final c = [for (final runde in p.zuege.keys) if (p.geruechte(runde).any((g) => g.figur == f)) runde].length;
        return _Spanne(c, c + offen);
      case WertArt.zusammenhalt || WertArt.spuk:
        // Leisten steigen nur: höchstens um den größten Zuwachs je offene Runde, nie über den Deckel.
        final zus = w.art == WertArt.zusammenhalt;
        final stand = zus ? p.zusammenhalt : p.spuk;
        if (offen == 0) return _Spanne.genau(stand);
        final h = stand + offen * (zus ? r.zahlen.zusammenhaltSchwellen : r.zahlen.spukSchwellen).first.zuwachs;
        return _Spanne(stand, h > r.zahlen.leisteHoechstens ? r.zahlen.leisteHoechstens : h);
      case WertArt.rest:
        final rest = p.rest;
        return rest != null && (p.fertig || p.rundenFertig >= 3) ? _Spanne.genau(rest) : const _Spanne(0, null);
      case WertArt.jedeRunde:
        final alle = _eigene().every((z) => z.art == w.zug);
        if (!alle) return const _Spanne.genau(0);
        return offen == 0 ? const _Spanne.genau(1) : const _Spanne(0, 1);
    }
  }

  /// Dreiwertig: true (steht fest), false (unmöglich) oder null (offen).
  bool? wert(ZielBedingung b) {
    switch (b) {
      case AlleBedingung(:final teile):
        var offen = false;
        for (final t in teile) {
          final x = wert(t);
          if (x == false) return false;
          if (x == null) offen = true;
        }
        return offen ? null : true;
      case EineBedingung(:final teile):
        var offen = false;
        for (final t in teile) {
          final x = wert(t);
          if (x == true) return true;
          if (x == null) offen = true;
        }
        return offen ? null : false;
      case NichtBedingung(:final teil):
        final x = wert(teil);
        return x == null ? null : !x;
      case GrenzBedingung(:final wert, :final grenze, :final mindestens):
        final s = zahl(wert);
        if (mindestens) {
          if (s.tief >= grenze) return true;
          if (s.hoch != null && s.hoch! < grenze) return false;
        } else {
          if (s.hoch != null && s.hoch! <= grenze) return true;
          if (s.tief > grenze) return false;
        }
        return null;
      case GleichBedingung(:final links, :final rechtsWert, :final rechtsZahl, :final rechtsFigur):
        if (links.istFigur) {
          final a = person(links);
          final b = rechtsFigur != null ? _fig(rechtsFigur) : person(rechtsWert!);
          if (a == null || b == null) return null;
          return a == b;
        }
        final a = zahl(links);
        final b = rechtsZahl != null ? _Spanne.genau(rechtsZahl) : zahl(rechtsWert!);
        if (a.fest && b.fest) return a.tief == b.tief;
        final getrennt = (a.hoch != null && a.hoch! < b.tief) || (b.hoch != null && b.hoch! < a.tief);
        return getrennt ? false : null;
    }
  }
}

/// Die Ziele aller Figuren einer Akte (aus [EinflussRegeln.ziele]).
class EinflussZiele {
  EinflussZiele._(this.regeln, this.je);
  final EinflussRegeln regeln;
  final Map<String, List<EinflussZiel>> je;

  /// Liest alle Sterne; eine fehlerhafte Bedingung wirft [FormatException] mit Figur und Nummer.
  factory EinflussZiele.aus(EinflussRegeln r) {
    final je = <String, List<EinflussZiel>>{};
    for (final e in r.ziele.entries) {
      je[e.key] = [
        for (final (i, z) in e.value.indexed)
          () {
            try {
              return EinflussZiel(e.key, i + 1, z.id, zielBedingung(z.bedingung, r));
            } on FormatException catch (f) {
              throw FormatException('ziele.${e.key}[${i + 1}]: ${f.message}');
            }
          }(),
      ];
    }
    return EinflussZiele._(r, Map.unmodifiable(je));
  }

  /// Sterne einer Figur (leer ohne Eintrag).
  List<EinflussZiel> von(String figur) => je[figur] ?? const [];

  /// Live-Stand eines Sterns gegen [p] (§3.9).
  ZielStand stand(EinflussZiel z, NachtProtokoll p) => zielStandAus(z, p, regeln);

  /// Erreichte Sterne einer Figur, sobald das Protokoll fertig ist (sonst die schon sicheren).
  int sterne(String figur, NachtProtokoll p) => von(figur).where((z) => stand(z, p) == ZielStand.erreicht).length;

  /// Erreichte Sterne aller besetzten Rollen (für die Auszeichnungen).
  Map<String, int> alleSterne(NachtProtokoll p) => {for (final f in p.besetzt) f: sterne(f, p)};
}

/// Live-Stand eines Sterns gegen [p] (§3.9): nach der Anklage nur erreicht oder verloren.
ZielStand zielStandAus(EinflussZiel z, NachtProtokoll p, EinflussRegeln r) => switch (_Auswertung(p, r, z.figur).wert(z.bedingung)) {
      true => ZielStand.erreicht,
      false => ZielStand.verloren,
      null => p.fertig ? ZielStand.verloren : ZielStand.offen,
    };

/// Gestalt einer Bedingung ohne Fakten und Figuren (§3.9: gleiche Form der Kernfiguren). `ich` bleibt,
/// `alle` und `eine` werden zur Menge ihrer Teilgestalten.
String zielForm(ZielBedingung b) {
  String atom(ZielWert w) => switch (w.art) {
        WertArt.bekannt => 'bekannt:_',
        WertArt.gestanden || WertArt.ertappt || WertArt.geruecht || WertArt.auspackRunde => '${w.art.name}:${w.figur == 'ich' ? 'ich' : '_'}',
        WertArt.zieleAuf => 'zieleAuf:${w.zug!.name}:${w.figur == 'ich' ? 'ich' : '_'}',
        _ => w.text,
      };
  return switch (b) {
    AlleBedingung(:final teile) => 'alle{${({for (final t in teile) zielForm(t)}.toList()..sort()).join(',')}}',
    EineBedingung(:final teile) => 'eine{${({for (final t in teile) zielForm(t)}.toList()..sort()).join(',')}}',
    NichtBedingung(:final teil) => 'nicht(${zielForm(teil)})',
    GrenzBedingung(:final wert, :final grenze, :final mindestens) => '${mindestens ? 'mind' : 'hoechstens'}(${atom(wert)},$grenze)',
    GleichBedingung(:final links, :final rechtsWert, :final rechtsZahl, :final rechtsFigur) =>
      'gleich(${atom(links)},${rechtsWert != null ? atom(rechtsWert) : rechtsZahl ?? (rechtsFigur == 'ich' ? 'ich' : '_')})',
  };
}

/// Alle Atome einer Bedingung.
Iterable<ZielWert> zielAtome(ZielBedingung b) sync* {
  switch (b) {
    case AlleBedingung(:final teile) || EineBedingung(:final teile):
      for (final t in teile) {
        yield* zielAtome(t);
      }
    case NichtBedingung(:final teil):
      yield* zielAtome(teil);
    case GrenzBedingung(:final wert):
      yield wert;
    case GleichBedingung(:final links, :final rechtsWert):
      yield links;
      if (rechtsWert != null) yield rechtsWert;
  }
}

/// Probe für den Prüfer (§3.9): Gibt es einen fertigen Abend, an dem der Stern erreicht ist, und einen,
/// an dem er verfehlt ist? Gesucht wird über erdachte Protokolle bei voller Besetzung: eigene
/// Zugfolgen (gleich in allen Runden oder ein Zug in einer Runde) und, nur für die Atome des Sterns,
/// Anklage, sichtbare Fakten, Leisten, Rest, Ertappt, Gerüchte und Auspacken anderer.
({bool erreichbar, bool verfehlbar}) zielProbe(EinflussZiel z, EinflussRegeln r) {
  final ich = z.figur;
  final atome = zielAtome(z.bedingung).toList();
  final arten = {for (final a in atome) a.art};
  final besetzt = r.figuren;
  final genannt = <String>{ich, for (final a in atome) if (a.figur case final f? when f != 'ich') f};
  final dritte = besetzt.firstWhere((f) => !genannt.contains(f));
  final ziele = [...genannt, dritte];

  // Eigene Züge: ohne Ziel, und je Zielart auf jede genannte Figur.
  final zuege = <EinflussZug>[
    EinflussZug.abgewartet(ich),
    for (final a in [ZugArt.helfen, ZugArt.ablenken, ZugArt.auspacken]) EinflussZug(ich, a),
    for (final a in [ZugArt.zeigen, ZugArt.decken, ZugArt.lauschen])
      for (final f in ziele)
        if (f != ich || r.arten[a]!.ziel == ZielRegel.jede) EinflussZug(ich, a, ziel: f),
  ];
  final folgen = <List<EinflussZug>>[
    for (final m in zuege)
      if (m.art == ZugArt.auspacken) ...[
        for (var runde = 1; runde <= 3; runde++) [for (var i = 1; i <= 3; i++) i == runde ? m : EinflussZug.abgewartet(ich)],
      ] else ...[
        [m, m, m],
        for (var runde = 1; runde <= 3; runde++) [for (var i = 1; i <= 3; i++) i == runde ? m : EinflussZug.abgewartet(ich)],
      ],
  ];

  List<T> wenn<T>(bool b, List<T> ja, T sonst) => b ? ja : [sonst];
  final fakten = <String>{for (final a in atome) ?a.fakt}.toList();
  final sichtbarAuswahl = <Set<String>>[
    if (!arten.contains(WertArt.bekannt)) <String>{}
    else
      for (var maske = 0; maske < (1 << (fakten.length > 4 ? 4 : fakten.length)); maske++)
        {for (var i = 0; i < fakten.length && i < 4; i++) if (maske & (1 << i) != 0) fakten[i]},
  ];
  final leisten = [0, 2, 3, 4, 6];
  final betroffen = {for (final a in atome) if (a.figur case final f?) f == 'ich' ? ich : f};

  var erreichbar = false, verfehlbar = false;
  for (final eigen in folgen) {
    for (final angeklagt in wenn(arten.contains(WertArt.angeklagt), r.kern, r.kern.first)) {
      for (final sichtbar in sichtbarAuswahl) {
        for (final zh in wenn(arten.contains(WertArt.zusammenhalt), leisten, 0)) {
          for (final sp in wenn(arten.contains(WertArt.spuk), leisten, 0)) {
            for (final rest in wenn(arten.contains(WertArt.rest), [0, 9, 10, 30], 0)) {
              for (final fremd in wenn(arten.any((a) => {WertArt.ertappt, WertArt.geruecht, WertArt.gestanden, WertArt.auspackRunde}.contains(a)), [0, 1, 2, 3], 0)) {
                // fremd: 0 nichts; 1 Gerücht über die Betroffenen in Runde 1; 2 Betroffene ertappt; 3 Betroffene packen in Runde 2 aus.
                final runden = <int, Map<String, EinflussZug>>{};
                for (var runde = 1; runde <= 3; runde++) {
                  final m = <String, EinflussZug>{ich: eigen[runde - 1]};
                  if (fremd == 1 && runde == 1) {
                    for (final f in betroffen) {
                      final zeiger = besetzt.firstWhere((x) => x != f && x != ich);
                      m[zeiger] = EinflussZug(zeiger, ZugArt.zeigen, ziel: f);
                    }
                  }
                  if (fremd == 3 && runde == 2) {
                    for (final f in betroffen) {
                      if (f != ich && r.auspacken.containsKey(f)) m[f] = EinflussZug(f, ZugArt.auspacken);
                    }
                  }
                  runden[runde] = m;
                }
                final p = NachtProtokoll(
                  besetzt: besetzt,
                  zuege: runden,
                  ertappt: fremd == 2 ? {for (final f in betroffen) f: 1} : const {},
                  zusammenhalt: zh,
                  spuk: sp,
                  sichtbar: sichtbar,
                  angeklagt: angeklagt,
                  rest: rest,
                );
                final w = _Auswertung(p, r, ich).wert(z.bedingung);
                if (w == true) erreichbar = true;
                if (w == false) verfehlbar = true;
                if (erreichbar && verfehlbar) return (erreichbar: true, verfehlbar: true);
              }
            }
          }
        }
      }
    }
  }
  return (erreichbar: erreichbar, verfehlbar: verfehlbar);
}
