// Gespräche mit Wahl (M6): Randgespräche mit unbesetzten Zeugen, Ereignisketten
// über Flags und Epiloge. Regeln R1–R12: planung/gesamt/ERZAEHLREGELN.md.
//
// Reines Dart. Bewusst ohne Zugriff auf Würfel, Nachtminuten, Wertung und
// Täterpfad: Ein Gespräch kann das Rätsel weder lösen noch verzerren.

/// Gesprächshaltung des Detektivs (R7).
enum Haltung { freundlich, draengen, bluffen, vorlegen }

/// Erzähltiefe des Abends (R11): aus = wie bisher, kurz = eine Wahl je
/// Gespräch, voll = Dialogbäume und Ereignisketten.
enum Erzaehltiefe { aus, kurz, voll }

/// Was ein Gespräch über den Abend wissen darf (R1): keine Pfad-, Fall- oder
/// Wertungsdaten, nur Runde, Tiefe, eigene Flags und ob die Gruppe schon
/// einen Fund in der Hand hat (für *vorlegen*, R8).
class ErzaehlUmwelt {
  const ErzaehlUmwelt({required this.runde, this.flags = const {}, this.hatFund = false, this.tiefe = Erzaehltiefe.voll});

  final int runde;
  final Set<String> flags;
  final bool hatFund;
  final Erzaehltiefe tiefe;
}

/// Bedingung eines Übergangs: Mindestvertrauen, Mindestdruck, ein Flag.
class Bedingung {
  const Bedingung({this.vertrauenAb, this.druckAb, this.flag});

  final int? vertrauenAb;
  final int? druckAb;
  final String? flag;

  bool gilt(int vertrauen, int druck, Set<String> flags) =>
      (vertrauenAb == null || vertrauen >= vertrauenAb!) && (druckAb == null || druck >= druckAb!) && (flag == null || flags.contains(flag));

  bool get leer => vertrauenAb == null && druckAb == null && flag == null;

  factory Bedingung.ausJson(Map<String, Object?>? j) => j == null
      ? const Bedingung()
      : Bedingung(vertrauenAb: j['vertrauenAb'] as int?, druckAb: j['druckAb'] as int?, flag: j['flag'] as String?);
}

/// Ein Ziel einer Wahl: der erste Eintrag, dessen Bedingung gilt.
class Ziel {
  const Ziel(this.knoten, [this.wenn = const Bedingung()]);

  final String knoten;
  final Bedingung wenn;
}

/// Eine Antwortmöglichkeit des Detektivs.
class Wahl {
  const Wahl({
    required this.haltung,
    required this.text,
    required this.ziele,
    this.vertrauen = 0,
    this.druck = 0,
    this.brauchtFlag,
  });

  final Haltung haltung;

  /// Was der Detektiv sagt.
  final String text;
  final int vertrauen;
  final int druck;

  /// Nur anbieten, wenn dieses Flag gesetzt ist (Ereigniskette).
  final String? brauchtFlag;
  final List<Ziel> ziele;

  factory Wahl.ausJson(Map<String, Object?> j) {
    final ziel = j['ziel'];
    return Wahl(
      haltung: Haltung.values.byName(j['haltung'] as String),
      text: j['text'] as String,
      vertrauen: j['vertrauen'] as int? ?? 0,
      druck: j['druck'] as int? ?? 0,
      brauchtFlag: j['brauchtFlag'] as String?,
      ziele: ziel is String
          ? [Ziel(ziel)]
          : [
              for (final z in (ziel as List? ?? const []))
                Ziel((z as Map)['knoten'] as String, Bedingung.ausJson((z['wenn'] as Map?)?.cast<String, Object?>())),
            ],
    );
  }
}

/// Ein Knoten: eine Zeile der Figur, danach Wahlen (leer heißt: Ende).
class Knoten {
  const Knoten({required this.id, required this.text, this.wahlen = const [], this.setzt = const [], this.preisgabe = const [], this.geste});

  final String id;
  final String text;
  final List<Wahl> wahlen;

  /// Flags, die beim Erreichen gesetzt werden (R9).
  final List<String> setzt;

  /// Kanonstellen, die diese Zeile wiedergibt (`beobachtung:<id>`,
  /// `luege:<id>`); nur zur Prüfung (R2).
  final List<String> preisgabe;

  /// Optionale Geste der Figur (`nicken`, `abwehr`, `nachdenken` …).
  final String? geste;

  bool get ende => wahlen.isEmpty;

  factory Knoten.ausJson(String id, Map<String, Object?> j) => Knoten(
        id: id,
        text: j['text'] as String,
        wahlen: [for (final w in (j['wahlen'] as List? ?? const [])) Wahl.ausJson((w as Map).cast<String, Object?>())],
        setzt: [for (final f in (j['setzt'] as List? ?? const [])) f as String],
        preisgabe: [for (final p in (j['preisgabe'] as List? ?? const [])) p as String],
        geste: j['geste'] as String?,
      );
}

/// Ein Randgespräch mit einer Figur.
class Randgespraech {
  const Randgespraech({
    required this.id,
    required this.figur,
    required this.start,
    required this.knoten,
    this.abRunde = 1,
    this.brauchtFlags = const [],
    this.ohneFlags = const [],
  });

  final String id;
  final String figur;

  /// Ab dieser Runde ansprechbar.
  final int abRunde;

  /// Nur wenn alle diese Flags gesetzt sind (Ereigniskette).
  final List<String> brauchtFlags;

  /// Nicht mehr, sobald eines dieser Flags gesetzt ist.
  final List<String> ohneFlags;
  final String start;
  final Map<String, Knoten> knoten;

  bool verfuegbar(ErzaehlUmwelt u) =>
      u.tiefe != Erzaehltiefe.aus &&
      u.runde >= abRunde &&
      brauchtFlags.every(u.flags.contains) &&
      !ohneFlags.any(u.flags.contains) &&
      // Ereignisketten nur in voller Tiefe.
      (brauchtFlags.isEmpty || u.tiefe == Erzaehltiefe.voll);

  factory Randgespraech.ausJson(Map<String, Object?> j) {
    final k = (j['knoten'] as Map).cast<String, Object?>();
    return Randgespraech(
      id: j['id'] as String,
      figur: j['figur'] as String,
      abRunde: j['abRunde'] as int? ?? 1,
      brauchtFlags: [for (final f in (j['brauchtFlags'] as List? ?? const [])) f as String],
      ohneFlags: [for (final f in (j['ohneFlags'] as List? ?? const [])) f as String],
      start: j['start'] as String,
      knoten: {for (final e in k.entries) e.key: Knoten.ausJson(e.key, (e.value as Map).cast<String, Object?>())},
    );
  }
}

/// Ein Satz im Nachspiel nach dem Finale (R10): hängt nur von Flags und vom
/// Ergebnis der Anklage ab.
class Epilog {
  const Epilog({required this.id, required this.text, this.figur, this.flags = const [], this.ergebnis});

  final String id;
  final String? figur;
  final List<String> flags;

  /// `richtig`, `falsch` oder `null` (beides).
  final String? ergebnis;
  final String text;

  bool passt(Set<String> gesetzt, bool richtig) =>
      flags.every(gesetzt.contains) && (ergebnis == null || (ergebnis == 'richtig') == richtig);

  factory Epilog.ausJson(Map<String, Object?> j) => Epilog(
        id: j['id'] as String,
        text: j['text'] as String,
        figur: j['figur'] as String?,
        flags: [for (final f in (j['flags'] as List? ?? const [])) f as String],
        ergebnis: j['ergebnis'] as String?,
      );
}

/// Alle Gespräche und Epiloge einer Akte (`content/erzaehlung/<akte>/gespraeche.json`).
class Erzaehlung {
  const Erzaehlung({required this.akte, required this.gespraeche, required this.epiloge});

  final String akte;
  final List<Randgespraech> gespraeche;
  final List<Epilog> epiloge;

  factory Erzaehlung.ausJson(Map<String, Object?> j) {
    if (j['format'] != 'erzaehlung/1') throw FormatException('Unbekanntes Format: ${j['format']}');
    return Erzaehlung(
      akte: j['akte'] as String,
      gespraeche: [for (final g in (j['gespraeche'] as List? ?? const [])) Randgespraech.ausJson((g as Map).cast<String, Object?>())],
      epiloge: [for (final e in (j['epiloge'] as List? ?? const [])) Epilog.ausJson((e as Map).cast<String, Object?>())],
    );
  }

  /// Das nächste offene Gespräch mit [figur] (oder `null`): in der Reihenfolge
  /// der Datei, ohne bereits geführte.
  Randgespraech? offenFuer(String figur, ErzaehlUmwelt u, {Set<String> gefuehrt = const {}}) {
    for (final g in gespraeche) {
      if (g.figur == figur && !gefuehrt.contains(g.id) && g.verfuegbar(u)) return g;
    }
    return null;
  }

  /// Nachspiel in der Reihenfolge der Datei, je Figur höchstens ein Satz.
  List<Epilog> nachspiel(Set<String> flags, {required bool richtig}) {
    final figuren = <String>{};
    return [
      for (final e in epiloge)
        if (e.passt(flags, richtig) && (e.figur == null || figuren.add(e.figur!))) e,
    ];
  }
}

/// Ein laufendes Gespräch: Knoten, Vertrauen, Druck und neue Flags.
/// Deterministisch (R6): gleiche Wahlen, gleicher Verlauf.
class GespraechsLauf {
  GespraechsLauf(this.gespraech, this.umwelt) : _knoten = gespraech.start {
    _betreten(gespraech.knoten[_knoten]!);
  }

  final Randgespraech gespraech;
  final ErzaehlUmwelt umwelt;
  String _knoten;
  int vertrauen = 0;
  int druck = 0;
  int _schritte = 0;

  /// Flags, die dieses Gespräch gesetzt hat.
  final Set<String> neueFlags = {};

  /// Bisheriger Verlauf: Zeilen der Figur und die gewählten Sätze.
  final List<({String? detektiv, String figur, String? geste})> verlauf = [];

  Knoten get knoten => gespraech.knoten[_knoten]!;

  Set<String> get _flags => {...umwelt.flags, ...neueFlags};

  /// Wahlen, die jetzt angeboten werden. In kurzer Tiefe nur beim ersten Schritt.
  List<Wahl> get wahlen {
    if (umwelt.tiefe == Erzaehltiefe.kurz && _schritte >= 1) return const [];
    return [
      for (final w in knoten.wahlen)
        if ((w.brauchtFlag == null || _flags.contains(w.brauchtFlag)) && (w.haltung != Haltung.vorlegen || umwelt.hatFund)) w,
    ];
  }

  bool get fertig => wahlen.isEmpty;

  void waehle(Wahl w) {
    if (!wahlen.contains(w)) throw ArgumentError('Wahl gerade nicht möglich');
    vertrauen += w.vertrauen;
    druck += w.druck;
    _schritte++;
    final f = _flags;
    final ziel = w.ziele.firstWhere((z) => z.wenn.gilt(vertrauen, druck, f), orElse: () => w.ziele.last);
    _knoten = ziel.knoten;
    final k = gespraech.knoten[_knoten]!;
    verlauf.last = (detektiv: w.text, figur: verlauf.last.figur, geste: verlauf.last.geste);
    _betreten(k);
  }

  void _betreten(Knoten k) {
    neueFlags.addAll(k.setzt);
    verlauf.add((detektiv: null, figur: k.text, geste: k.geste));
  }
}
