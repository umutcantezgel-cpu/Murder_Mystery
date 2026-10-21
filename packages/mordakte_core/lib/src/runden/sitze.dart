/// Sitze am Online-Abend (Langer Abend M3): wer ermittelt, wer vorliest, wer
/// welche Figur spielt.
///
/// Der [Sitzplan] ist rein: kein Raum, kein Transport, keine Uhr. Er hält, was
/// die Lobby festlegt (Sitz-Nachrichten, Rollenzahl, Zuteilung, Wünsche), und
/// verteilt beim Start die Rollen. Die Rechte daraus prüft der Raum.
library;

/// Was ein Gerät am Abend tut.
enum Sitz {
  /// Führt die Ermittlung: Optionen, Abstecher, Tischruf, Funde, Befragungen, Anklage.
  detektiv,

  /// Liest vor und führt durch den Abend („Weiter“); entscheidet nichts,
  /// spielt keine Figur, würfelt und stimmt nicht.
  erzaehler,

  /// Spielt eine Figur mit eigenem Dossier.
  rolle,

  /// Platz ohne Figur: sieht nur die öffentliche Ansicht.
  assistenz;

  /// Sitz aus seinem Namen (`detektiv`, `erzaehler`, …), sonst `null`.
  static Sitz? lesen(Object? name) {
    for (final s in values) {
      if (s.name == name) return s;
    }
    return null;
  }

  /// Ein Sitz, den die Nachricht `sitz` vergibt (Detektiv oder Erzähler).
  bool get vergeben => this == detektiv || this == erzaehler;
}

/// Sitze, Rollenzahl und Figurenwahl der Lobby.
///
/// - Es gibt höchstens einen Detektiv- und einen Erzähler-Sitz; ein Gerät hat
///   höchstens einen davon. Wer einen Sitz hat, spielt keine Figur.
/// - Die Klasse ([klasse]) reist mit dem Detektiv-Sitz: Wandert der Sitz zu
///   einem anderen Gerät, gilt sie nicht mehr.
/// - Zugeteilt wird nur als Permutation über die besetzten Figuren: Hält ein
///   anderes Gerät die Figur schon, tauschen beide.
/// - Wünsche sind nur Hinweise für die Zuteilung; der Start beachtet sie nicht.
///
/// Jede Änderung meldet die betroffenen Geräte, damit der Raum deren `bereit`
/// aufhebt (sie sollen ihren neuen Platz erst sehen).
class Sitzplan {
  String? _detektiv;
  String? _erzaehler;
  String? _klasse;
  int? _rollen;
  final Map<String, String> _zuteilung = {};
  final Map<String, String> _wunsch = {};

  /// Gerät auf dem Detektiv-Sitz.
  String? get detektiv => _detektiv;

  /// Gerät auf dem Erzähler-Sitz (optional).
  String? get erzaehler => _erzaehler;

  /// Klasse des Detektiv-Sitzes (Kennung wie `forensic`), sonst `null`.
  String? get klasse => _klasse;

  /// Rollenzahl aus der Lobby (`besetzung`), sonst `null`.
  int? get rollen => _rollen;

  /// Gerät → zugeteilte Figur (vor dem Start).
  Map<String, String> get zuteilung => Map.unmodifiable(_zuteilung);

  /// Gerät → gewünschte Figur (Hinweis).
  Map<String, String> get wuensche => Map.unmodifiable(_wunsch);

  /// Vergebener Sitz von [id] (Detektiv oder Erzähler), sonst `null`.
  Sitz? sitzVon(String id) => id == _detektiv ? Sitz.detektiv : (id == _erzaehler ? Sitz.erzaehler : null);

  /// Hat [id] den Detektiv- oder den Erzähler-Sitz?
  bool sitzt(String id) => sitzVon(id) != null;

  /// Setzt [id] auf [sitz] oder nimmt ihm seinen Sitz (`null`). Ein bisheriger
  /// Inhaber verliert den Sitz, eine Zuteilung von [id] fällt weg. [klasse]
  /// gilt nur für den Detektiv-Sitz: mit [klasseSetzen] wird sie übernommen
  /// (auch `null`), sonst bleibt sie, solange der Sitz beim selben Gerät bleibt.
  /// Ergibt die betroffenen Geräte.
  Set<String> setze(String id, Sitz? sitz, {String? klasse, bool klasseSetzen = false}) {
    if (sitz != null && !sitz.vergeben) throw ArgumentError.value(sitz, 'sitz');
    if (klasseSetzen && klasse != null && sitz != Sitz.detektiv) throw ArgumentError.value(klasse, 'klasse');
    final betroffen = <String>{id};
    switch (sitz) {
      case Sitz.detektiv:
        if (_detektiv != id) {
          if (_detektiv case final alt?) betroffen.add(alt);
          _klasse = null;
        }
        if (_erzaehler == id) _erzaehler = null;
        _detektiv = id;
        if (klasseSetzen) _klasse = klasse;
      case Sitz.erzaehler:
        if (_erzaehler case final alt? when alt != id) betroffen.add(alt);
        if (_detektiv == id) {
          _detektiv = null;
          _klasse = null;
        }
        _erzaehler = id;
      default:
        if (_detektiv == id) {
          _detektiv = null;
          _klasse = null;
        }
        if (_erzaehler == id) _erzaehler = null;
    }
    if (sitz != null) _zuteilung.remove(id);
    return betroffen;
  }

  /// Setzt die Rollenzahl. Zuteilungen außerhalb von [besetzt] (den ersten
  /// Figuren der Besetzungsreihenfolge) fallen weg; ergibt deren Geräte.
  Set<String> setzeRollen(int n, List<String> besetzt) {
    _rollen = n;
    final weg = {for (final e in _zuteilung.entries) if (!besetzt.contains(e.value)) e.key};
    _zuteilung.removeWhere((id, _) => weg.contains(id));
    return weg;
  }

  /// Teilt [id] die Figur [figur] zu (`null`: Zufall beim Start). Nur Figuren
  /// aus [besetzt] und nie einem Gerät mit Sitz. Hält ein anderes Gerät die
  /// Figur, bekommt es die bisherige Figur von [id] (Tausch). Ergibt die
  /// betroffenen Geräte (leer, wenn sich nichts ändert).
  Set<String> zuteilen(String id, String? figur, List<String> besetzt) {
    if (sitzt(id)) throw ArgumentError.value(id, 'id', 'hat einen Sitz');
    if (figur != null && !besetzt.contains(figur)) throw ArgumentError.value(figur, 'figur');
    final alt = _zuteilung[id];
    if (alt == figur) return const {};
    final betroffen = <String>{id};
    if (figur == null) {
      _zuteilung.remove(id);
      return betroffen;
    }
    for (final e in _zuteilung.entries.toList()) {
      if (e.key != id && e.value == figur) {
        betroffen.add(e.key);
        if (alt == null) {
          _zuteilung.remove(e.key);
        } else {
          _zuteilung[e.key] = alt;
        }
      }
    }
    _zuteilung[id] = figur;
    return betroffen;
  }

  /// Merkt den Wunsch von [id] (`null` hebt ihn auf).
  void wuenscht(String id, String? figur) {
    if (figur == null) {
      _wunsch.remove(id);
    } else {
      _wunsch[id] = figur;
    }
  }

  /// [id] verlässt die Lobby: Sitz, Klasse, Zuteilung und Wunsch fallen weg.
  void entferne(String id) {
    setze(id, null);
    _zuteilung.remove(id);
    _wunsch.remove(id);
  }

  /// Kann der Abend mit Gastgeber [host] beginnen? Es braucht einen Detektiv,
  /// und der Gastgeber sitzt auf dem Detektiv- oder dem Erzähler-Sitz (der
  /// Gastgeber hält Salz und Pfad; eine Figur spielt er nie).
  bool startklar(String? host) => _detektiv != null && host != null && sitzt(host);

  /// Rollen zum Start: zuerst die Zuteilung (soweit in [gemischt]), den Rest
  /// in der Reihenfolge von [gemischt] an die übrigen Geräte ohne Sitz, in der
  /// Reihenfolge von [geraete] (Beitritt). Überzählige Geräte bleiben ohne
  /// Figur (Assistenz), übrige Figuren spielt die App.
  Map<String, String> verteile(Iterable<String> geraete, List<String> gemischt) {
    final ergebnis = <String, String>{};
    for (final id in geraete) {
      final f = _zuteilung[id];
      if (f != null && !sitzt(id) && gemischt.contains(f)) ergebnis[id] = f;
    }
    final vergeben = ergebnis.values.toSet();
    final rest = [for (final f in gemischt) if (!vergeben.contains(f)) f];
    var i = 0;
    for (final id in geraete) {
      if (sitzt(id) || ergebnis.containsKey(id)) continue;
      if (i < rest.length) ergebnis[id] = rest[i++];
    }
    return ergebnis;
  }
}
