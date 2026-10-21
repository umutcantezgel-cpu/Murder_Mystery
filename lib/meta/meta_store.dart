import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/runden.dart' show AbendErgebnis, KartenKatalog, TischVorrat, belohnungFuer, xpFuer;
import 'package:shared_preferences/shared_preferences.dart';

import 'gaesteliste.dart';
import 'progression.dart';

export 'gaesteliste.dart';

/// Bevorzugte Ausrüstung (wird in der Lobby automatisch gesetzt).
class Loadout {
  final String cls;
  final int coat;
  final String hat;

  const Loadout({this.cls = 'forensic', this.coat = 0, this.hat = 'fedora'});

  Map<String, dynamic> toJson() => {'cls': cls, 'coat': coat, 'hat': hat};

  factory Loadout.fromJson(Map<String, dynamic> j) => Loadout(
    cls: j['cls'] as String? ?? 'forensic',
    coat: (j['coat'] as num? ?? 0).toInt(),
    hat: j['hat'] as String? ?? 'fedora',
  );
}

/// Etwas, das durch einen Rangaufstieg freigeschaltet wurde.
class Unlock {
  /// `class`, `hat`, `coat`
  final String kind;
  final String id;

  const Unlock(this.kind, this.id);
}

/// Ergebnis der Verbuchung eines Spiels (für den End-Bildschirm).
class GameResult {
  final int xpBefore;
  final int xpGained;
  final int dailyBonus;
  final int rankBefore;
  final int rankAfter;
  final bool newEnding;
  final int endingsInScenario;
  final int streak;
  final List<String> newAchievements;
  final List<Unlock> unlocks;

  const GameResult({
    required this.xpBefore,
    required this.xpGained,
    required this.dailyBonus,
    required this.rankBefore,
    required this.rankAfter,
    required this.newEnding,
    required this.endingsInScenario,
    required this.streak,
    required this.newAchievements,
    required this.unlocks,
  });

  int get xpAfter => xpBefore + xpGained + dailyBonus;
  bool get rankUp => rankAfter > rankBefore;
}

/// Besitz einer Sammelkarte: Anzahl der Exemplare und ob sie noch ungesehen ist.
class KartenBesitz {
  const KartenBesitz(this.n, {this.neu = false});

  final int n;

  /// Frisch erhalten und noch nicht in der Sammlung angesehen („NEU“).
  final bool neu;

  KartenBesitz copyWith({int? n, bool? neu}) => KartenBesitz(n ?? this.n, neu: neu ?? this.neu);
}

/// Stand einer Akte bei den Abenden dieses Geräts.
class AkteStand {
  const AkteStand({this.gespielt = 0, this.enden = const [], this.bestPunkte = 0});

  final int gespielt;

  /// Erreichte Enden (Kennungen, jede einmal).
  final List<String> enden;
  final int bestPunkte;

  AkteStand copyWith({int? gespielt, List<String>? enden, int? bestPunkte}) =>
      AkteStand(gespielt: gespielt ?? this.gespielt, enden: enden ?? this.enden, bestPunkte: bestPunkte ?? this.bestPunkte);
}

/// Was ein Abend dem Gerät bringt: Karten, Erfahrungspunkte, Rang.
class AbendBelohnung {
  const AbendBelohnung({
    required this.karten,
    required this.neu,
    required this.xp,
    this.xpVorher = 0,
    this.rangVorher = 0,
    this.rangNachher = 0,
    this.schonVerbucht = false,
  });

  /// Leere Belohnung (z. B. für einen schon verbuchten Abend ohne Zwischenspeicher).
  const AbendBelohnung.leer({this.xpVorher = 0, this.rangVorher = 0, this.rangNachher = 0, this.schonVerbucht = true})
      : karten = const [],
        neu = const [],
        xp = 0;

  /// Alle erhaltenen Karten in Reihenfolge (auch Doppelte).
  final List<String> karten;

  /// Davon erstmals im Besitz.
  final List<String> neu;
  final int xp;
  final int xpVorher;
  final int rangVorher;
  final int rangNachher;

  /// Der Abend war schon gebucht; es wurde nichts doppelt gutgeschrieben.
  final bool schonVerbucht;

  int get xpNachher => xpVorher + xp;
  bool get rangAufstieg => rangNachher > rangVorher;
}

/// Was die App während eines Spiels mitzählt (falls die Engine keine Statistik liefert).
class GameTally {
  int combos = 0;
  int revives = 0;
  bool ghostHelped = false;
}

/// Persistente Meta-Progression: Name, XP/Rang, Freischaltungen, Enden-Sammlung,
/// Fall des Tages + Serie, Erfolge, Statistik.
class MetaStore extends ChangeNotifier {
  MetaStore._(this._prefs);

  final SharedPreferences? _prefs;
  final Map<String, String> _memory = {};

  static Future<MetaStore> load() async {
    SharedPreferences? prefs;
    try {
      prefs = await SharedPreferences.getInstance();
    } catch (_) {
      prefs = null; // z. B. blockierter Speicher im Browser → nur im Speicher
    }
    final m = MetaStore._(prefs);
    m._read();
    return m;
  }

  /// Nur für Tests/Vorschau ohne Speicher.
  factory MetaStore.memory() => MetaStore._(null).._read();

  String? _name;
  int _xp = 0;
  int _streak = 0;
  int _bestStreak = 0;
  String? _lastDay;
  String? _dailyDone;
  final Map<String, Set<String>> _endings = {};
  final Set<String> _storySolved = {};
  final Set<String> _solvedScenarios = {};
  final Set<String> _achievements = {};
  final Map<String, int> _stats = {};
  Loadout _loadout = const Loadout();
  bool _loadoutChosen = false;
  String? _serverUrl;

  // Sammelkarten (v2): Besitz, Deck, Stand je Akte, zuletzt gebuchte Abende.
  final Map<String, KartenBesitz> _besitz = {};
  final List<String> _deck = [];
  final Map<String, AkteStand> _akten = {};
  final List<String> _abende = [];
  final Map<String, AbendBelohnung> _belohnungen = {};
  bool _kartenAngelegt = false;

  // Gästelisten je Akte (M5): wer welche Figur spielt, Personenzahl.
  final Map<String, GaesteListe> _gaeste = {};

  /// Wie viele gebuchte Abende sich das Gerät für die Doppelbuchungssperre merkt.
  static const abendeMerken = 50;

  // --- Lesen -----------------------------------------------------------------

  String? get name => _name;
  bool get hasName => (_name ?? '').trim().isNotEmpty;
  int get xp => _xp;
  int get rank => rankForXp(_xp);
  int get streak => _currentStreak(DateTime.now());
  int get bestStreak => _bestStreak;
  Loadout get loadout => _loadout;

  /// Hat der Spieler je selbst eine Ausrüstung gewählt? Sonst gilt die Zuteilung des Raums.
  bool get hasLoadout => _loadoutChosen;
  String? get serverUrl => _serverUrl;
  Set<String> get achievements => Set.unmodifiable(_achievements);
  Set<String> endingsFor(String scenarioId) => Set.unmodifiable(_endings[scenarioId] ?? const <String>{});
  int get totalEndings => _endings.values.fold(0, (a, s) => a + s.length);
  bool storySolved(String scenarioId) => _storySolved.contains(scenarioId);
  bool scenarioSolved(String scenarioId) => _solvedScenarios.contains(scenarioId);
  bool dailyDone(DateTime now) => _dailyDone == dayKey(now);
  int stat(String key) => _stats[key] ?? 0;

  // --- Sammelkarten -----------------------------------------------------------

  /// Besitz je Karten-Kennung (Reihenfolge: zuerst erhaltene Karte zuerst).
  Map<String, KartenBesitz> get besitz => Map.unmodifiable(_besitz);
  bool besitztKarte(String id) => _besitz.containsKey(id);
  int kartenAnzahl(String id) => _besitz[id]?.n ?? 0;

  /// Karten, die noch nicht in der Sammlung angesehen wurden.
  Set<String> get neueKarten => {for (final e in _besitz.entries) if (e.value.neu) e.key};

  /// Zuletzt erstmals erhaltene Karte (für die Detektei) oder null.
  String? get neuesteKarte => _besitz.isEmpty ? null : _besitz.keys.last;

  /// Das Deck für Abende: höchstens drei Karten-Kennungen in Reihenfolge.
  List<String> get deck => List.unmodifiable(_deck);

  /// Stand je Akte-Kennung.
  Map<String, AkteStand> get akten => Map.unmodifiable(_akten);

  /// Die zuletzt gebuchten Abend-Kennungen (älteste zuerst).
  List<String> get gebuchteAbende => List.unmodifiable(_abende);

  /// Wurde das Kartenkonto schon angelegt (Startset vergeben)?
  bool get kartenBereit => _kartenAngelegt;

  /// Gästeliste der Akte [akte] (leer, wenn es keine gibt).
  GaesteListe gaesteliste(String akte) => _gaeste[akte] ?? const GaesteListe();

  bool classUnlocked(String cls) => rank >= classUnlockRank(cls);
  bool hatUnlocked(String hat) => rank >= hatRank(hat);
  bool coatUnlocked(int coat) => rank >= coatRank(coat);

  int _currentStreak(DateTime now) {
    if (_lastDay == null) return 0;
    final today = dayKey(now);
    final yesterday = dayKey(now.subtract(const Duration(days: 1)));
    return (_lastDay == today || _lastDay == yesterday) ? _streak : 0;
  }

  // --- Schreiben ---------------------------------------------------------------

  set name(String? v) {
    _name = v?.trim();
    _put('name', _name ?? '');
    notifyListeners();
  }

  set loadout(Loadout v) {
    _loadout = v;
    _loadoutChosen = true;
    _put('loadout', jsonEncode(v.toJson()));
    notifyListeners();
  }

  set serverUrl(String? v) {
    _serverUrl = (v == null || v.trim().isEmpty) ? null : v.trim();
    _put('server', _serverUrl ?? '');
    notifyListeners();
  }

  /// Nur Entwickler-Einstieg: XP direkt setzen.
  void debugSetXp(int xp) {
    _xp = xp;
    _write();
    notifyListeners();
  }


  /// Legt die Gästeliste der Akte [akte] ab; eine leere Liste löscht sie.
  void setzeGaesteliste(String akte, GaesteListe liste) {
    if (liste == gaesteliste(akte)) return;
    if (liste.leer) {
      _gaeste.remove(akte);
    } else {
      _gaeste[akte] = liste;
    }
    _put('gaeste', jsonEncode({for (final e in _gaeste.entries) e.key: e.value.toJson()}));
    notifyListeners();
  }

  // --- Sammelkarten schreiben ----------------------------------------------------

  /// Legt das Kartenkonto an, falls es fehlt: Das Startset (alle Karten mit der
  /// Quelle `start`) gehört einmalig dazu, und die ersten passenden davon liegen
  /// im Deck. Ein vorhandenes Konto bleibt unverändert; der Aufruf ist idempotent.
  void initKarten(KartenKatalog katalog) {
    if (_kartenAngelegt) return;
    final start = [for (final k in katalog.alle) if (k.hatQuelle('start')) k];
    for (final k in start) {
      _besitz[k.id] = const KartenBesitz(1);
    }
    _deck
      ..clear()
      ..addAll([for (final k in TischVorrat.aus([for (final k in start) k.id], katalog).karten) k.id]);
    _kartenAngelegt = true;
    _schreibeKarten();
    _schreibeAbende();
    notifyListeners();
  }

  /// Legt das Deck fest. Unbekannte (nicht besessene) und doppelte Karten fallen
  /// weg, mehr als drei werden abgeschnitten. Mit [katalog] gilt zusätzlich die
  /// Regel des Tischvorrats (je Art eine Karte, höchstens vier Ladungen).
  void setzeDeck(List<String> ids, {KartenKatalog? katalog}) {
    if (!_kartenAngelegt) return;
    var gewollt = <String>[];
    for (final id in ids) {
      if (_besitz.containsKey(id) && !gewollt.contains(id)) gewollt.add(id);
    }
    if (katalog != null) {
      gewollt = [for (final k in TischVorrat.aus(gewollt, katalog).karten) k.id];
    } else if (gewollt.length > TischVorrat.maxKarten) {
      gewollt = gewollt.sublist(0, TischVorrat.maxKarten);
    }
    _deck
      ..clear()
      ..addAll(gewollt);
    _schreibeKarten();
    notifyListeners();
  }

  /// Nimmt die „NEU“-Marke von Karten, die der Spieler angesehen hat.
  void markiereGesehen(Iterable<String> ids) {
    var geaendert = false;
    for (final id in ids) {
      final b = _besitz[id];
      if (b != null && b.neu) {
        _besitz[id] = b.copyWith(neu: false);
        geaendert = true;
      }
    }
    if (!geaendert) return;
    _schreibeKarten();
    notifyListeners();
  }

  /// Verbucht einen beendeten Abend genau einmal (Schlüssel: [abendId]): Karten
  /// nach [belohnungFuer], Erfahrungspunkte nach [xpFuer] zum bestehenden
  /// Fortschritt, Stand der Akte. Ein zweiter Aufruf mit derselben Kennung
  /// schreibt nichts gut und liefert die zuerst berechnete Belohnung (oder, nach
  /// einem Neustart, eine leere mit [AbendBelohnung.schonVerbucht]).
  AbendBelohnung verbucheAbend({
    required String abendId,
    required AbendErgebnis ergebnis,
    required KartenKatalog katalog,
    int punkte = 0,
  }) {
    if (_abende.contains(abendId)) {
      final alt = _belohnungen[abendId];
      if (alt != null) {
        return AbendBelohnung(
          karten: alt.karten,
          neu: alt.neu,
          xp: alt.xp,
          xpVorher: alt.xpVorher,
          rangVorher: alt.rangVorher,
          rangNachher: alt.rangNachher,
          schonVerbucht: true,
        );
      }
      return AbendBelohnung.leer(xpVorher: _xp, rangVorher: rank, rangNachher: rank);
    }
    initKarten(katalog);
    final rangVorher = rank;
    final xpVorher = _xp;
    final karten = belohnungFuer(ergebnis, katalog, {..._besitz.keys});
    final neu = <String>[];
    for (final id in karten) {
      final b = _besitz[id];
      if (b == null) {
        _besitz[id] = const KartenBesitz(1, neu: true);
        neu.add(id);
      } else {
        _besitz[id] = b.copyWith(n: b.n + 1);
      }
    }
    final xp = xpFuer(ergebnis.ende);
    _xp += xp;

    final alt = _akten[ergebnis.akte] ?? const AkteStand();
    _akten[ergebnis.akte] = AkteStand(
      gespielt: alt.gespielt + 1,
      enden: alt.enden.contains(ergebnis.ende) ? alt.enden : [...alt.enden, ergebnis.ende],
      bestPunkte: punkte > alt.bestPunkte ? punkte : alt.bestPunkte,
    );
    _abende.add(abendId);
    while (_abende.length > abendeMerken) {
      final weg = _abende.removeAt(0);
      _belohnungen.remove(weg);
    }
    final b = AbendBelohnung(
      karten: List.unmodifiable(karten),
      neu: List.unmodifiable(neu),
      xp: xp,
      xpVorher: xpVorher,
      rangVorher: rangVorher,
      rangNachher: rank,
    );
    _belohnungen[abendId] = b;
    _write();
    _schreibeKarten();
    _schreibeAkten();
    _schreibeAbende();
    notifyListeners();
    return b;
  }

  /// Verbucht ein beendetes Spiel genau einmal.
  GameResult record({
    required EndingView ending,
    required String scenarioId,
    required String mode,
    required String playerId,
    required bool online,
    required Set<String> allScenarioIds,
    required GameTally tally,
    DateTime? now,
  }) {
    final date = now ?? DateTime.now();
    final today = dayKey(date);
    final xpBefore = _xp;
    final rankBefore = rank;

    final gained = ending.xp[playerId] ?? Tuning.xpVerdict[ending.verdict] ?? 0;
    var bonus = 0;
    if (mode == 'daily' && _dailyDone != today) {
      bonus = dailyBonusXp;
      _dailyDone = today;
    }

    // Serie: aufeinanderfolgende Tage mit mindestens einem abgeschlossenen Fall.
    if (_lastDay != today) {
      final yesterday = dayKey(date.subtract(const Duration(days: 1)));
      _streak = _lastDay == yesterday ? _streak + 1 : 1;
      _lastDay = today;
    }
    if (_streak > _bestStreak) _bestStreak = _streak;

    final set = _endings.putIfAbsent(scenarioId, () => <String>{});
    final newEnding = set.add(ending.endingId);

    final solved = const {'perfect', 'solid', 'partial'}.contains(ending.verdict);
    _inc('cases');
    if (solved) {
      _inc('solved');
      _solvedScenarios.add(scenarioId);
      if (mode == 'story') _storySolved.add(scenarioId);
    }
    if (ending.verdict == 'perfect') _inc('perfect');
    final myStats = ending.stats[playerId] ?? const <String, int>{};
    final revives = myStats['revives'] ?? tally.revives;
    final combos = myStats['combos'] ?? tally.combos;
    _inc('revives', revives);
    _inc('combos', combos);
    if (online) _inc('online');
    final myAwards = ending.awards[playerId] ?? const <String>[];
    final ghostHelped = tally.ghostHelped || myAwards.contains('geist') || (myStats['ghostHelp'] ?? 0) > 0;
    if (ghostHelped) _inc('ghost');

    _xp += gained + bonus;
    final rankAfter = rank;

    final newAch = <String>[];
    void grant(String id, bool cond) {
      if (cond && _achievements.add(id)) newAch.add(id);
    }

    grant('first_case', true);
    grant('perfect', ending.verdict == 'perfect');
    grant('all_survived', ending.team == 'all');
    grant('revive3', stat('revives') >= 3);
    grant('secret', ending.secret);
    grant('all_scenarios', allScenarioIds.isNotEmpty && _solvedScenarios.containsAll(allScenarioIds));
    grant('streak5', _streak >= 5);
    grant('ghost_helper', ghostHelped);
    grant('online', online);
    grant('combos10', stat('combos') >= 10);

    final unlocks = <Unlock>[];
    if (rankAfter > rankBefore) {
      bool fresh(int r) => r > rankBefore && r <= rankAfter;
      for (final c in detectiveClasses.values) {
        if (fresh(c.unlockRank)) unlocks.add(Unlock('class', c.id));
      }
      for (final e in hatUnlockRank.entries) {
        if (fresh(e.value)) unlocks.add(Unlock('hat', e.key));
      }
      for (var i = 0; i < coatUnlockRank.length; i++) {
        if (fresh(coatUnlockRank[i])) unlocks.add(Unlock('coat', '$i'));
      }
    }

    _write();
    notifyListeners();
    return GameResult(
      xpBefore: xpBefore,
      xpGained: gained,
      dailyBonus: bonus,
      rankBefore: rankBefore,
      rankAfter: rankAfter,
      newEnding: newEnding,
      endingsInScenario: set.length,
      streak: _streak,
      newAchievements: newAch,
      unlocks: unlocks,
    );
  }

  void _inc(String key, [int by = 1]) => _stats[key] = (_stats[key] ?? 0) + by;

  // --- Persistenz --------------------------------------------------------------

  String? _get(String k) => _prefs != null ? _prefs.getString('mordakte.$k') : _memory[k];

  void _put(String k, String v) {
    if (_prefs != null) {
      _prefs.setString('mordakte.$k', v);
    } else {
      _memory[k] = v;
    }
  }

  void _read() {
    _leseKarten();
    _leseGaeste();
    try {
      final n = _get('name');
      _name = (n == null || n.isEmpty) ? null : n;
      final s = _get('server');
      _serverUrl = (s == null || s.isEmpty) ? null : s;
      final lo = _get('loadout');
      if (lo != null && lo.isNotEmpty) {
        _loadout = Loadout.fromJson(jsonDecode(lo) as Map<String, dynamic>);
        _loadoutChosen = true;
      }
      final raw = _get('progress');
      if (raw == null || raw.isEmpty) return;
      final j = jsonDecode(raw) as Map<String, dynamic>;
      _xp = (j['xp'] as num? ?? 0).toInt();
      _streak = (j['streak'] as num? ?? 0).toInt();
      _bestStreak = (j['best'] as num? ?? 0).toInt();
      _lastDay = j['last'] as String?;
      _dailyDone = j['daily'] as String?;
      for (final e in (j['endings'] as Map? ?? const {}).entries) {
        _endings[e.key as String] = {...(e.value as List).cast<String>()};
      }
      _storySolved.addAll((j['story'] as List? ?? const []).cast<String>());
      _solvedScenarios.addAll((j['solved'] as List? ?? const []).cast<String>());
      _achievements.addAll((j['ach'] as List? ?? const []).cast<String>());
      for (final e in (j['stats'] as Map? ?? const {}).entries) {
        _stats[e.key as String] = (e.value as num).toInt();
      }
    } catch (e) {
      debugPrint('Meta: Fortschritt nicht lesbar ($e)');
    }
  }

  void _schreibeKarten() => _put(
        'karten',
        jsonEncode({
          'v': 1,
          'besitz': {for (final e in _besitz.entries) e.key: {'n': e.value.n, 'neu': e.value.neu}},
          'deck': _deck,
        }),
      );

  void _schreibeAkten() => _put(
        'akten',
        jsonEncode({
          for (final e in _akten.entries)
            e.key: {'gespielt': e.value.gespielt, 'enden': e.value.enden, 'bestPunkte': e.value.bestPunkte},
        }),
      );

  void _schreibeAbende() => _put('abende', jsonEncode(_abende));

  /// Liest Karten, Akten und Abende. Fehlt `mordakte.karten`, bleibt das Konto
  /// unangelegt, bis [initKarten] das Startset vergibt.
  void _leseKarten() {
    try {
      final raw = _get('karten');
      if (raw != null && raw.isNotEmpty) {
        final j = jsonDecode(raw) as Map<String, dynamic>;
        for (final e in (j['besitz'] as Map? ?? const {}).entries) {
          final v = e.value as Map;
          final n = (v['n'] as num? ?? 1).toInt();
          if (n > 0) _besitz[e.key as String] = KartenBesitz(n, neu: v['neu'] == true);
        }
        for (final id in (j['deck'] as List? ?? const []).cast<String>()) {
          if (_besitz.containsKey(id) && !_deck.contains(id) && _deck.length < TischVorrat.maxKarten) _deck.add(id);
        }
        _kartenAngelegt = true;
      }
    } catch (e) {
      debugPrint('Meta: Karten nicht lesbar ($e)');
    }
    try {
      final raw = _get('akten');
      if (raw != null && raw.isNotEmpty) {
        final j = jsonDecode(raw) as Map<String, dynamic>;
        for (final e in j.entries) {
          final v = e.value as Map;
          _akten[e.key] = AkteStand(
            gespielt: (v['gespielt'] as num? ?? 0).toInt(),
            enden: (v['enden'] as List? ?? const []).cast<String>(),
            bestPunkte: (v['bestPunkte'] as num? ?? 0).toInt(),
          );
        }
      }
    } catch (e) {
      debugPrint('Meta: Akten nicht lesbar ($e)');
    }
    try {
      final raw = _get('abende');
      if (raw != null && raw.isNotEmpty) {
        _abende.addAll((jsonDecode(raw) as List).cast<String>());
        while (_abende.length > abendeMerken) {
          _abende.removeAt(0);
        }
      }
    } catch (e) {
      debugPrint('Meta: Abende nicht lesbar ($e)');
    }
  }

  void _leseGaeste() {
    try {
      final raw = _get('gaeste');
      if (raw == null || raw.isEmpty) return;
      for (final e in (jsonDecode(raw) as Map).entries) {
        final liste = GaesteListe.ausJson(e.value);
        if (!liste.leer) _gaeste[e.key as String] = liste;
      }
    } catch (e) {
      debugPrint('Meta: Gästelisten nicht lesbar ($e)');
    }
  }

  void _write() {
    _put(
      'progress',
      jsonEncode({
        'xp': _xp,
        'streak': _streak,
        'best': _bestStreak,
        'last': _lastDay,
        'daily': _dailyDone,
        'endings': {for (final e in _endings.entries) e.key: e.value.toList()},
        'story': _storySolved.toList(),
        'solved': _solvedScenarios.toList(),
        'ach': _achievements.toList(),
        'stats': _stats,
      }),
    );
  }
}
