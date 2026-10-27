import 'package:mordakte_core/runden.dart' show BefragungsLage, EinflussFund, ZielStand, ZugArt, tippKeiner;

/// Lesemodell der Einfluss-Schicht „Dein Moment“ (Finale §3.12, §3.14) aus den
/// Ansichten des Raums: öffentlich `einfluss`, privat `moment` und
/// `einflussTafel`, ab dem Finale `aufloesung.einfluss`. An einem Gerät baut die
/// Sitzung dieselben Ansichten aus ihrer Partie (`EinflussRaum`), online liest
/// das Gerät sie aus seiner Ansicht. So zeigen Tisch, Gastgeber und Gäste
/// dieselben Bausteine aus derselben Datenform; nichts hier kennt den Pfad.

Map<String, Object?> _map(Object? v) => v is Map ? v.cast<String, Object?>() : const {};
List<Object?> _liste(Object? v) => v is List ? v : const [];
List<Map<String, Object?>> _maps(Object? v) => [for (final x in _liste(v)) if (x is Map) x.cast<String, Object?>()];
List<String> _texte(Object? v) => [for (final x in _liste(v)) if (x is String) x];
String? _text(Object? v) => v is String && v.isNotEmpty ? v : null;
int _zahl(Object? v, [int sonst = 0]) => v is int ? v : sonst;
Map<String, int> _zahlen(Object? v) => {for (final e in _map(v).entries) if (e.value is int) e.key: e.value as int};

/// Ein Zug, wie ihn eine Ansicht zeigt (eigener Zug, Protokoll, Tafel).
class ZugSicht {
  const ZugSicht({required this.art, this.ziel, this.tipp, this.rolle, this.runde = 0, this.bot = false});

  final ZugArt art;
  final String? ziel, tipp, rolle;
  final int runde;

  /// Diese Rolle zog als Bot (nur Tafel und Protokoll).
  final bool bot;

  static ZugSicht? ausJson(Object? j) {
    final m = _map(j);
    final art = ZugArt.lesen(m['art']);
    if (art == null) return null;
    return ZugSicht(art: art, ziel: _text(m['ziel']), tipp: _text(m['tipp']), rolle: _text(m['rolle']), runde: _zahl(m['runde']), bot: m['bot'] == true);
  }
}

/// Eine private Nachricht (§3.12): Text-Schlüssel mit Platzhaltern `@figur`, `@zug`, `@ziel`.
class NachrichtSicht {
  const NachrichtSicht({required this.runde, required this.schluessel, this.figur, this.zug, this.ziel});

  final int runde;
  final String schluessel;
  final String? figur, zug, ziel;

  /// Ein Lauschergebnis?
  bool get gelauscht => schluessel.startsWith('einfluss.privat.gelauscht');

  static NachrichtSicht? ausJson(Object? j) {
    final m = _map(j);
    final k = _text(m['schluessel']);
    if (k == null) return null;
    return NachrichtSicht(runde: _zahl(m['runde']), schluessel: k, figur: _text(m['figur']), zug: _text(m['zug']), ziel: _text(m['ziel']));
  }
}

/// Ein Stern (persönliches Ziel) mit Live-Stand.
class SternSicht {
  const SternSicht({required this.nr, required this.schluessel, required this.stand});

  final int nr;
  final String schluessel;
  final ZielStand stand;
}

ZielStand _stand(Object? v) => ZielStand.values.where((z) => z.name == v).firstOrNull ?? ZielStand.offen;

/// Privat `moment` einer Rolle: in den Gesprächen (`offen`) der eigene Zug, die
/// erlaubten Arten, Ziele je Art und in der Tipp-Runde die Tipps; immer die
/// eigenen bisherigen Züge, die zwei Sterne und die privaten Nachrichten.
class MomentSicht {
  const MomentSicht({
    required this.runde,
    required this.offen,
    this.zug,
    this.arten = const [],
    this.ziele = const {},
    this.tipps = const [],
    this.zuege = const [],
    this.sterne = const [],
    this.nachrichten = const [],
  });

  final int runde;

  /// Kann die Rolle jetzt ziehen (Gespräche der laufenden Runde)?
  final bool offen;

  /// Eigener Zug dieser Runde, solange er sich noch ändern lässt.
  final ZugSicht? zug;

  /// Erlaubte Arten (ohne schon gespielte Einmal-Züge).
  final List<ZugArt> arten;
  final Map<ZugArt, List<String>> ziele;

  /// Tipps „Wer war's?“ (nur in der Tipp-Runde): Kernfiguren und [tippKeiner].
  final List<String> tipps;

  /// Eigene Züge der ausgewerteten Runden.
  final List<ZugSicht> zuege;
  final List<SternSicht> sterne;

  /// Private Nachrichten aller ausgewerteten Runden, Lauschergebnisse eingeschlossen.
  final List<NachrichtSicht> nachrichten;

  factory MomentSicht.ausJson(Object? j) {
    final m = _map(j);
    return MomentSicht(
      runde: _zahl(m['runde']),
      offen: m['offen'] == true,
      zug: ZugSicht.ausJson(m['zug']),
      arten: [for (final a in _liste(m['arten'])) ?ZugArt.lesen(a)],
      ziele: {
        for (final e in _map(m['ziele']).entries) ?ZugArt.lesen(e.key): _texte(e.value),
      },
      tipps: _texte(m['tipps']),
      zuege: [for (final z in _maps(m['zuege'])) ?ZugSicht.ausJson(z)],
      sterne: [
        for (final s in _maps(m['sterne']))
          if (_text(s['schluessel']) case final k?) SternSicht(nr: _zahl(s['nr']), schluessel: k, stand: _stand(s['stand'])),
      ],
      nachrichten: [
        for (final n in [..._maps(m['nachrichten']), ..._maps(m['gelauscht'])]) ?NachrichtSicht.ausJson(n),
      ]..sort((a, b) => a.runde.compareTo(b.runde)),
    );
  }

  /// Was die Rolle aus der Runde davor erfahren hat (hält zu dir, Lauschergebnis, Wirkung, Ertappt).
  List<NachrichtSicht> get vorrunde => [for (final n in nachrichten) if (n.runde == runde - 1) n];

  /// Der Zug der Runde davor, wenn er so jetzt wieder erlaubt ist („Wie letzte Runde“).
  ZugSicht? get wieLetzteRunde {
    final z = zuege.where((z) => z.runde == runde - 1).firstOrNull;
    if (z == null || z.art == ZugArt.abgewartet || !arten.contains(z.art)) return null;
    final ziel = z.ziel;
    if (ziel != null && !(ziele[z.art] ?? const <String>[]).contains(ziel)) return null;
    return ZugSicht(art: z.art, ziel: ziel);
  }
}

/// Folgen einer ausgewerteten Runde, öffentlich (§3.12).
class FolgenSicht {
  const FolgenSicht({
    required this.runde,
    this.geruechte = const [],
    this.gestanden = const [],
    this.ablenker = const [],
    this.zuwachsZusammenhalt = 0,
    this.zuwachsSpuk = 0,
    this.ereignisse = const [],
    this.minuten = 0,
    this.tisch = const {},
    this.blasen = const [],
  });

  final int runde;

  /// Gerüchte als Bausteine (`einfluss.geruecht.<leise|laut>@<figur>`).
  final List<String> geruechte;

  /// Ausgepackt: Figur mit Fakt und/oder Randnotiz.
  final List<({String figur, String? fakt, String? notiz})> gestanden;
  final List<String> ablenker;
  final int zuwachsZusammenhalt, zuwachsSpuk;
  final List<String> ereignisse;
  final int minuten;
  final Map<String, int> tisch;

  /// Reaktionsblasen der Bots (Text-Schlüssel `einfluss.bot.<figur>.<anlass>`).
  final List<String> blasen;

  static FolgenSicht ausJson(Map<String, Object?> m) {
    final zuwachs = _map(m['zuwachs']);
    return FolgenSicht(
      runde: _zahl(m['runde']),
      geruechte: _texte(m['geruechte']),
      gestanden: [
        for (final g in _maps(m['gestanden']))
          if (_text(g['figur']) case final f?) (figur: f, fakt: _text(g['fakt']), notiz: _text(g['notiz'])),
      ],
      ablenker: _texte(m['ablenker']),
      zuwachsZusammenhalt: _zahl(zuwachs['zusammenhalt']),
      zuwachsSpuk: _zahl(zuwachs['spuk']),
      ereignisse: _texte(m['ereignisse']),
      minuten: _zahl(m['minuten']),
      tisch: _zahlen(m['tisch']),
      blasen: _texte(m['blasen']),
    );
  }
}

/// Öffentlich `einfluss`, für alle Geräte gleich: wer schon gezogen hat (nie
/// was), letzter Aufruf, Leisten, Ereignisse, Folgen, Tischwerte, Kennzeichen
/// der Funde, gezeigte Randnotizen und Nachfragen.
class EinflussLage {
  const EinflussLage({
    required this.runde,
    this.gezogen,
    this.aufruf,
    this.zusammenhalt = 0,
    this.spuk = 0,
    this.ereignisse = const [],
    this.folgen = const [],
    this.tisch = const {},
    this.funde = const {},
    this.randnotizen = const [],
    this.kerzenschein = false,
    this.nachfragenOffen = 0,
    this.nachfrageOptionen = const [],
    this.nachgefragt = const [],
  });

  final int runde;

  /// In den Gesprächen: Rollen, die schon gezogen haben; sonst `null`.
  final List<String>? gezogen;

  /// Abendzeit (ms) des letzten Aufrufs in den laufenden Gesprächen.
  final int? aufruf;
  final int zusammenhalt, spuk;
  final List<String> ereignisse;
  final List<FolgenSicht> folgen;

  /// Tischwerte der laufenden Runde (nach den Folgen).
  final Map<String, int> tisch;
  final Map<String, EinflussFund> funde;
  final List<String> randnotizen;
  final bool kerzenschein;
  final int nachfragenOffen;
  final List<String> nachfrageOptionen;
  final List<({String option, String notiz})> nachgefragt;

  factory EinflussLage.ausJson(Object? j) {
    final m = _map(j);
    final leisten = _map(m['leisten']);
    final nachfragen = _map(m['nachfragen']);
    final funde = <String, EinflussFund>{};
    for (final e in _map(m['funde']).entries) {
      try {
        funde[e.key] = EinflussFund.ausJson(_map(e.value));
      } on FormatException {
        // Eine unlesbare Kennzeichnung bleibt weg; der Fund selbst steht im Notizbuch.
      }
    }
    return EinflussLage(
      runde: _zahl(m['runde']),
      gezogen: m['gezogen'] is List ? _texte(m['gezogen']) : null,
      aufruf: m['aufruf'] is int ? m['aufruf'] as int : null,
      zusammenhalt: _zahl(leisten['zusammenhalt']),
      spuk: _zahl(leisten['spuk']),
      ereignisse: _texte(m['ereignisse']),
      folgen: [for (final f in _maps(m['folgen'])) FolgenSicht.ausJson(f)],
      tisch: _zahlen(m['tisch']),
      funde: funde,
      randnotizen: _texte(m['randnotizen']),
      kerzenschein: m['kerzenschein'] == true,
      nachfragenOffen: _zahl(nachfragen['offen']),
      nachfrageOptionen: _texte(nachfragen['optionen']),
      nachgefragt: [
        for (final n in _maps(m['nachgefragt']))
          if ((_text(n['option']), _text(n['notiz'])) case (final o?, final t?)) (option: o, notiz: t),
      ],
    );
  }

  /// Folgen der Runde [r], sonst `null`.
  FolgenSicht? folgenVon(int r) => folgen.where((f) => f.runde == r).firstOrNull;
}

/// Privat `einflussTafel` des Erzählers: wer in der laufenden Runde was spielte.
class TafelSicht {
  const TafelSicht({required this.runde, required this.ausgewertet, required this.zuege});

  final int runde;
  final bool ausgewertet;
  final List<ZugSicht> zuege;

  static TafelSicht? ausJson(Object? j) {
    if (j is! Map) return null;
    final m = _map(j);
    return TafelSicht(
      runde: _zahl(m['runde']),
      ausgewertet: m['ausgewertet'] == true,
      zuege: [for (final z in _maps(m['zuege'])) ?ZugSicht.ausJson(z)],
    );
  }
}

/// `aufloesung.einfluss` ab dem Finale: Protokoll der Nacht, Sterne, Tipps,
/// Auszeichnungen, Leisten, Tischbonus, Endwert und Morgen.
class AufloesungSicht {
  const AufloesungSicht({
    required this.protokoll,
    required this.sterne,
    required this.ziele,
    required this.tipps,
    required this.stern,
    required this.spuernasen,
    required this.schlossgeist,
    required this.treueSeele,
    required this.zusammenhalt,
    required this.spuk,
    required this.tischbonus,
    required this.endwert,
    required this.morgen,
  });

  /// Züge je Runde (Runde → Züge in Besetzungsreihenfolge).
  final Map<int, List<ZugSicht>> protokoll;
  final Map<String, int> sterne;

  /// Stand je Stern und Rolle (Nummer → Stand).
  final Map<String, Map<int, ZielStand>> ziele;
  final Map<String, String> tipps;
  final String? stern, schlossgeist, treueSeele;
  final List<String> spuernasen;
  final int zusammenhalt, spuk, tischbonus, endwert;
  final String morgen;

  static AufloesungSicht? ausJson(Object? j) {
    if (j is! Map) return null;
    final m = _map(j);
    final a = _map(m['auszeichnungen']);
    final leisten = _map(m['leisten']);
    return AufloesungSicht(
      protokoll: {
        for (final r in _maps(m['protokoll'])) _zahl(r['runde']): [for (final z in _maps(r['zuege'])) ?ZugSicht.ausJson({...z, 'runde': r['runde']})],
      },
      sterne: _zahlen(m['sterne']),
      ziele: {
        for (final e in _map(m['ziele']).entries) e.key: {for (final z in _maps(e.value)) _zahl(z['nr']): _stand(z['stand'])},
      },
      tipps: {for (final e in _map(m['tipps']).entries) if (e.value is String) e.key: e.value as String},
      stern: _text(a['stern']),
      spuernasen: _texte(a['spuernasen']),
      schlossgeist: _text(a['schlossgeist']),
      treueSeele: _text(a['treueSeele']),
      zusammenhalt: _zahl(leisten['zusammenhalt']),
      spuk: _zahl(leisten['spuk']),
      tischbonus: _zahl(m['tischbonus']),
      endwert: _zahl(m['endwert']),
      morgen: _text(m['morgen']) ?? '',
    );
  }

  /// Rollen des Protokolls in der Reihenfolge der ersten Runde.
  List<String> get rollen => [for (final z in protokoll.values.firstOrNull ?? const <ZugSicht>[]) ?z.rolle];

  /// Hat [rolle] mit „Keine Ahnung“ getippt?
  bool keineAhnung(String rolle) => tipps[rolle] == tippKeiner;
}

/// Wie eine Befragung mit Tischwert lief (§3.4), als Kennung für `einfluss.befragung.<lage>`.
String befragungsSchluessel(BefragungsLage l) => 'einfluss.befragung.${l.name}';

/// Text-Schlüssel des Abzeichens zum Tischwert [t] (§3.3), `null` bei 0.
String? abzeichenSchluessel(int t) => t == 0 ? null : 'einfluss.abzeichen.${t > 0 ? 'plus' : 'minus'}${t.abs().clamp(1, 2)}';
