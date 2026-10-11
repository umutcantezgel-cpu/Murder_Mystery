import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../party/ablauf.dart';
import '../party/entscheidungen.dart';
import '../party/fall_code.dart';
import '../party/kanon/kanon.dart';
import '../party/texte.dart';
import '../karten/abstecher.dart';
import '../karten/karte.dart';
import '../karten/vorrat.dart';
import '../util/rng.dart';
import 'abend_raum.dart';
import 'bots.dart';
import 'partie.dart';
import 'wuerfel.dart';
import 'zugschicht.dart';

/// Protokollfehler mit festem Schlüssel, niemals mit fremden Rollen-/Nutzdaten.
class PartyRaumFehler implements Exception {
  final String code;
  const PartyRaumFehler(this.code);
  @override
  String toString() => 'PartyRaumFehler: $code';
}

class _Teilnehmer {
  final String id;
  String name;
  bool online = true;
  bool aufgegeben = false;
  bool bereit = false;
  bool gelesen = false;
  String? rolle;
  _Teilnehmer(this.id, this.name);
}

/// Autoritativer Schlosskeller-Abend, ohne Socket, Flutter oder lokale Uhr.
///
/// Die Identität kommt ausschließlich vom authentifizierten Transport, nie aus
/// einem Nachrichtenfeld. Rollen werden einmal beim Start zugeteilt und bleiben
/// beim Reconnect erhalten. [zustandFuer] baut für jedes Gerät eine neue,
/// ausdrückliche Positivliste: genau ein eigenes Dossier, nie alle Rollenkarten,
/// die richtige Option, Gruppenwahl-Qualität, Fall-Code oder Würfelsalz.
///
/// Der Gastgeber steuert den gemeinsamen Detektiv; unbesetzte Rollen sind Bots.
/// Dadurch können auch wenige verbundene Geräte einen kanongültigen Abend mit
/// mindestens vier Rollen spielen. Kapazität: größte Besetzung der Akte plus
/// Spielleitung plus vier Assistenz-Plätze (Schlosskeller: 25 Geräte).
/// Die Methodennamen entsprechen RaumSpiel; der Transportadapter bleibt separat.
///
/// Der Raum spielt jede Akte (Schlosskeller, Gewölbe, Klassiker): Rollenzahl
/// und Kennung kommen aus dem Kanon der Akte. Mehr Geräte als Rollen werden
/// Assistenz-Plätze ohne eigene Rolle (sie sehen die öffentliche Ansicht).
class SchlosskellerRaum implements AbendRaum {
  SchlosskellerRaum({
    required this.raumCode,
    required Kanon kanon,
    required Texte texte,
    required FallCode fallCode,
    required String salz,
    this.akte = 'schlosskeller',
    this.festerGastgeber = false,
    KartenKatalog? katalog,
    List<AbstecherOrt> abstecher = const [],
  }) : _katalog = katalog ?? KartenKatalog(const []), _abstecher = abstecher, _kanon = kanon, _texte = texte, _fallCode = fallCode, _salz = salz,
       wuerfelZusage = sha256.convert(utf8.encode(salz)).toString() {
    if (salz.isEmpty) throw const PartyRaumFehler('invalid_setup');
  }

  /// Kennung der Akte (Ordner unter `content/party/`).
  final String akte;

  /// Gastgebergerät als Autorität (Relais-Modus): Die Leitung wandert nie zu
  /// einem anderen Gerät, sonst bekäme ein Gast Salz und Täterpfad.
  final bool festerGastgeber;

  final KartenKatalog _katalog;
  final List<AbstecherOrt> _abstecher;

  /// Zusätzliche Plätze ohne Rolle über der größten Besetzung.
  static const assistenzPlaetze = 4;

  @override
  final String raumCode;
  final Kanon _kanon;
  final Texte _texte;
  final FallCode _fallCode;
  final String _salz;

  /// Server-Zusage vor dem ersten Zug. Eine gemeinsame Commit/Reveal-Runde
  /// aller Geräte ist noch eine zusätzliche, getrennt abzunehmende Erweiterung.
  final String wuerfelZusage;
  final Map<String, _Teilnehmer> _teilnehmer = {};
  final Map<String, bool> _stimmen = {};
  final Map<String, List<String>> _funde = {};
  RundenPartie? _partie;
  String? _host;
  String? _detektiv;
  int _version = 0;
  int _erzaehlerAb = 0;
  bool _wurfWerkzeug = false;
  bool _wurfMarke = false;
  String? _wurfKarte;

  int get _minRollen => _kanon.besetzungJson['minRollen'] as int;
  int get _maxRollen => _kanon.besetzungJson['maxRollen'] as int;

  @override
  int get version => _version;
  @override
  int get maxSpieler => _maxRollen + 1 + assistenzPlaetze;
  @override
  bool get vorStart => _partie == null;
  @override
  bool get beendet => _partie?.phase == PartyPhase.ende;
  @override
  List<String> get spielerIds => List.unmodifiable(_teilnehmer.keys);

  @override
  bool beitreten(String id, String name) {
    if (id.isEmpty || name.trim().isEmpty || name.runes.length > 40) return false;
    final alt = _teilnehmer[id];
    if (alt != null) {
      alt.name = name.trim();
      alt.online = true;
      alt.aufgegeben = false;
      _host ??= id;
      _version++;
      return true;
    }
    if (!vorStart || _teilnehmer.length >= maxSpieler) return false;
    _teilnehmer[id] = _Teilnehmer(id, name.trim());
    _host ??= id;
    _version++;
    return true;
  }

  @override
  void verlassen(String id) {
    final t = _teilnehmer[id];
    if (t == null) return;
    if (vorStart) {
      _teilnehmer.remove(id);
    } else {
      t.online = false;
      t.aufgegeben = true;
    }
    if (_host == id && !festerGastgeber) _host = _ersteOnlineId(ohne: id);
    _botStimmen();
    _version++;
  }

  @override
  void verbunden(String id, bool ja) {
    final t = _teilnehmer[id];
    if (t == null || t.online == ja) return;
    t.online = ja;
    if (ja) {
      t.aufgegeben = false;
      _host ??= id;
    }
    // Keine Neuzuteilung, kein neues Würfelsalz. Temporärer Verbindungsabbruch
    // überträgt nicht sofort die Leitung; das entscheidet die Gnadenfrist außen.
    _version++;
  }

  String? _ersteOnlineId({String? ohne}) {
    for (final t in _teilnehmer.values) {
      if (t.online && t.id != ohne) return t.id;
    }
    return null;
  }

  _Teilnehmer _person(String id) {
    final t = _teilnehmer[id];
    if (t == null || !t.online) throw const PartyRaumFehler('not_in_room');
    return t;
  }

  void _nurHost(String id) {
    if (_host != id) throw const PartyRaumFehler('not_host');
  }

  /// Feste Nachrichten, keine beliebigen Methoden oder Rollenkennungen.
  /// Eine optionale Revision verwirft veraltete Aktionen vor jeder Änderung.
  @override
  void nachricht(String id, Map<String, Object?> inhalt) {
    final t = _person(id);
    final typ = inhalt['typ'];
    if (typ is! String) throw const PartyRaumFehler('invalid');
    final erlaubt = switch (typ) {
      'bereit' => {'wert'},
      'start' => {'rollen', 'detektiv', 'vorrat'},
      'rollenGelesen' || 'weiter' || 'fundGelesen' => <String>{},
      'wahl' => {'option', 'gruendlich', 'karte'},
      'aktionFertig' => {'aktion'},
      'wurf' => <String>{},
      'wuerfelHilfe' => {'marke', 'karte'},
      'tischruf' => {'ruf', 'karte'},
      'abstecher' => {'ort', 'gruendlich', 'karte'},
      'karte' => {'id'},
      'stimme' => {'kooperativ'},
      'anklage' => {'person'},
      _ => throw const PartyRaumFehler('invalid'),
    };
    if (inhalt.keys.any((k) => k != 'typ' && k != 'revision' && !erlaubt.contains(k))) {
      throw const PartyRaumFehler('invalid');
    }
    if (inhalt.containsKey('revision') && inhalt['revision'] != _version) {
      throw const PartyRaumFehler('stale');
    }
    try {
      if (typ == 'bereit') {
        if (!vorStart) throw const PartyRaumFehler('game_running');
        t.bereit = _bool(inhalt, 'wert');
      } else if (typ == 'start') {
        _nurHost(id);
        _start(inhalt);
      } else {
        final p = _partie ?? (throw const PartyRaumFehler('not_started'));
        if (typ == 'rollenGelesen') {
          if (p.phase != PartyPhase.rollen || t.rolle == null) throw const PartyRaumFehler('invalid_phase');
          t.gelesen = true;
        } else if (typ == 'stimme') {
          if (p.phase != PartyPhase.gruppenwahl || t.rolle == null) throw const PartyRaumFehler('invalid_phase');
          if (_stimmen.containsKey(t.rolle)) throw const PartyRaumFehler('already_voted');
          _stimmen[t.rolle!] = _bool(inhalt, 'kooperativ');
          _auswerten();
        } else if (typ == 'wurf' || typ == 'wuerfelHilfe') {
          if (id != _wuerfelPate) throw const PartyRaumFehler('not_dice_player');
          if (typ == 'wuerfelHilfe') {
            // Werkzeug kommt nur aus einer Quelle in der Welt (K-07): einer
            // Werkzeug-Karte des Tischvorrats, nie aus einem freien Feld.
            final marke = _bool(inhalt, 'marke', sonst: false);
            final karte = inhalt['karte'];
            if (karte != null) {
              if (karte is! String) throw const PartyRaumFehler('invalid');
              p.vorrat.pruefe(karte, {KartenArt.werkzeug});
            }
            p.vorschau(werkzeug: karte != null, marke: marke); // Phase zuerst prüfen.
            _wurfWerkzeug = karte != null;
            _wurfKarte = karte as String?;
            _wurfMarke = marke;
          } else {
            p.wuerfeln(marke: _wurfMarke, karte: _wurfKarte);
            _wurfWerkzeug = _wurfMarke = false;
            _wurfKarte = null;
            _merkeFund();
          }
        } else if (typ == 'karte') {
          // Sofort wirkende Karten (Zeit, Marke, Erinnerung) legt die Spielleitung.
          _nurHost(id);
          p.karteSpielen(_string(inhalt, 'id'));
        } else {
          _nurHost(id);
          switch (typ) {
            case 'weiter':
              if (!_kannWeiter) throw const PartyRaumFehler('not_ready');
              final ab = p.spiel.bausteine.length;
              p.weiter();
              _erzaehlerAb = ab;
              if (p.phase == PartyPhase.gruppenwahl) {
                _stimmen.clear();
                _botStimmen();
              }
            case 'wahl':
              p.waehle(_string(inhalt, 'option'),
                  gruendlich: _bool(inhalt, 'gruendlich', sonst: false), karte: _kannString(inhalt, 'karte'));
            case 'abstecher':
              p.starteAbstecher(_string(inhalt, 'ort'),
                  gruendlich: _bool(inhalt, 'gruendlich', sonst: false), karte: _kannString(inhalt, 'karte'));
            case 'aktionFertig':
              final aktion = inhalt['aktion'];
              if (aktion is! int || !p.aktionFertig(aktion)) throw const PartyRaumFehler('stale');
              _merkeFund();
            case 'tischruf':
              final ruf = switch (inhalt['ruf']) {
                'nochmal' => Tischruf.nochmal,
                'umweg' => Tischruf.umweg,
                _ => throw const PartyRaumFehler('invalid'),
              };
              p.tischruf(ruf, karte: _kannString(inhalt, 'karte'));
              _merkeFund();
            case 'fundGelesen':
              p.fundGelesen();
            case 'anklage':
              p.anklagen(_string(inhalt, 'person'));
          }
        }
      }
    } on StateError {
      throw const PartyRaumFehler('invalid_phase');
    } on KartenFehler catch (e) {
      throw PartyRaumFehler(e.code);
    } on ArgumentError {
      throw const PartyRaumFehler('invalid');
    }
    _version++;
  }

  void _start(Map<String, Object?> inhalt) {
    if (!vorStart) throw const PartyRaumFehler('game_running');
    if (_teilnehmer.values.any((t) => !t.online || !t.bereit)) throw const PartyRaumFehler('not_ready');
    final rollen = inhalt['rollen'];
    final detektiv = inhalt['detektiv'] ?? 'm';
    final gaeste = _teilnehmer.length - 1;
    if (rollen is! int || rollen < _minRollen || rollen > _maxRollen || rollen < (gaeste < _maxRollen ? gaeste : _maxRollen) ||
        (detektiv != 'm' && detektiv != 'w')) {
      throw const PartyRaumFehler('invalid');
    }
    // Tischvorrat: höchstens 3 Karten aus den Wünschen der Spielleitung
    // (Vereinigung der Decks am Tisch), unabhängig von der Besetzung (K-06).
    final wunsch = inhalt['vorrat'];
    if (wunsch != null && (wunsch is! List || wunsch.length > 12 || wunsch.any((w) => w is! String))) {
      throw const PartyRaumFehler('invalid');
    }
    final vorrat = TischVorrat.aus([for (final w in (wunsch as List?) ?? const []) w as String], _katalog);
    final p = RundenPartie(_kanon, quelle: SalzWuerfel(_salz), vorrat: vorrat, abstecher: _abstecher);
    p.einrichten(Einstellungen(rollen: rollen, detektiv: detektiv as String, code: _fallCode));
    final zuteilung = [...p.spiel.besetzt];
    Rng(Rng.hashString('rollen:$_salz')).shuffle(zuteilung);
    var index = 0;
    for (final t in _teilnehmer.values) {
      // Überzählige Geräte bleiben Assistenz ohne Rolle.
      if (t.id != _host && index < zuteilung.length) t.rolle = zuteilung[index++];
    }
    _detektiv = _host;
    _partie = p;
  }

  static bool _bool(Map<String, Object?> j, String name, {bool? sonst}) {
    final v = j.containsKey(name) ? j[name] : sonst;
    if (v is! bool) throw const PartyRaumFehler('invalid');
    return v;
  }

  static String? _kannString(Map<String, Object?> j, String name) => j[name] == null ? null : _string(j, name);

  static String _string(Map<String, Object?> j, String name) {
    final v = j[name];
    if (v is! String || v.isEmpty || v.length > 80) throw const PartyRaumFehler('invalid');
    return v;
  }

  bool get _kannWeiter {
    final p = _partie;
    if (p == null || !p.kannWeiter) return false;
    return p.phase != PartyPhase.rollen || !_teilnehmer.values.any((t) => !t.aufgegeben && t.rolle != null && !t.gelesen);
  }

  String? get _wuerfelPate {
    final online = [for (final t in _teilnehmer.values) if (t.online) t.id];
    if (online.isEmpty) return null;
    return online[(_partie?.wuerfe.length ?? 0) % online.length];
  }

  void _botStimmen() {
    final p = _partie;
    if (p == null || p.phase != PartyPhase.gruppenwahl) return;
    final menschen = {for (final t in _teilnehmer.values) if (!t.aufgegeben && t.rolle != null) t.rolle};
    for (final rolle in p.spiel.besetzt) {
      if (!menschen.contains(rolle)) {
        _stimmen.putIfAbsent(rolle, () => botKooperativ(salz: _salz, rolle: rolle, runde: p.runde));
      }
    }
    _auswerten();
  }

  void _auswerten() {
    final p = _partie!;
    if (_stimmen.length != p.spiel.besetzt.length || p.spiel.qualitaeten.containsKey(p.runde)) return;
    p.abstimmen(
      kooperativ: _stimmen.entries.where((e) => e.key != p.spiel.pfad && e.value).length,
      taeterSabotiert: _stimmen[p.spiel.pfad] == false,
    );
  }

  void _merkeFund() {
    final z = _partie?.zug;
    if (z != null && z.phase == RundenZugPhase.fund && !z.istAuftakt) {
      _funde[z.id] = [for (final f in z.funde) f.text];
    }
  }

  List<EntscheidungsOption> _optionen(Entscheidung e) {
    final optionen = [...e.optionen];
    // Online darf auch die Reihenfolge nicht vom geheimen Fall-Code abhängen.
    Rng(Rng.hashString('optionen:$_salz:${e.id}')).shuffle(optionen);
    return optionen;
  }

  /// Nur erlaubte öffentliche Daten und das Dossier des Empfängers. Insbesondere
  /// keine generische toJson()-Abbildung von Spiel, Kanon, Dossier oder Optionen.
  @override
  Map<String, Object?> zustandFuer(String id) {
    final ich = _person(id);
    final p = _partie;
    final nachFinale = p != null && p.phase.index >= PartyPhase.finale.index;
    final zug = p?.zug;
    final e = p?.naechsteEntscheidung;
    final rolle = ich.rolle;
    final dossier = p == null || rolle == null ? null : _texte.dossier(rolle, p.spiel.pfad, p.spiel.einstellungen.rollen);
    return {
      't': 'abend', 'protokoll': 1, 'version': _version,
      'spiel': akte, 'akte': akte, 'raum': raumCode, 'host': _host,
      'phase': p?.phase.name ?? 'lobby', 'runde': p?.runde ?? 0,
      'wuerfelZusage': wuerfelZusage,
      'spieler': [for (final t in _teilnehmer.values) {
        'id': t.id, 'name': t.name, 'online': t.online, 'bereit': t.bereit,
        if (t.rolle != null) 'rolle': t.rolle,
      }],
      'kannWeiter': _kannWeiter,
      if (p != null) ...{
        'rollen': p.spiel.einstellungen.rollen,
        'restMinuten': p.restMinuten, 'marken': p.marken,
        'erzaehler': [for (final b in p.spiel.bausteine.skip(_erzaehlerAb)) _texte.baustein(b)],
        'notizbuch': {for (final f in _funde.entries) f.key: [...f.value]},
        'wuerfe': [for (final w in p.wuerfe) w.toJson()],
        'wuerfelPate': _wuerfelPate,
        // Gewählte Optionen sind am Tisch öffentlich (Karte, Notizbuch).
        'gewaehlt': Map.of(p.spiel.gewaehlt),
        'vorrat': p.vorrat.toJson(),
        'abstecher': [
          for (final a in p.abstecherOffen) {'id': a.id, 'ort': a.ort, 'name': a.name},
        ],
        'abstecherErgebnis': {for (final e in p.abstecherErgebnis.entries) e.key: e.value.kurz},
        if (e != null) 'entscheidung': {
          'id': e.id, 'frage': e.frage, 'suche': istSuche(e),
          'optionen': [for (final o in _optionen(e)) {'id': o.id, 'text': o.text, 'ziel': Map.of(o.ziel)}],
        },
        if (zug != null) 'zug': {
          'id': zug.id, 'option': zug.option, 'suche': zug.suche,
          'phase': zug.phase.name, 'aktion': zug.aktion, 'ruf': zug.ruf?.name,
          'wurf': zug.wurf?.toJson(), 'funde': [for (final f in zug.funde) f.text],
          if (zug.istAbstecher) ...{'abstecher': zug.abstecher, 'nebenfund': zug.nebenfund},
          if (zug.phase == RundenZugPhase.wurf) ...{
            'werkzeug': _wurfWerkzeug, 'marke': _wurfMarke,
            'mod': p.vorschau(werkzeug: _wurfWerkzeug, marke: _wurfMarke).mod,
            'chancen': {
              for (final v in p.vorschau(werkzeug: _wurfWerkzeug, marke: _wurfMarke).prozent.entries) v.key.name: v.value,
            },
          },
        },
        if (p.phase == PartyPhase.gespraeche) 'botGespraeche': [
          for (final g in botGespraeche(_texte, rollen: p.spiel.einstellungen.rollen, runde: p.runde, mitNpc: true))
            if (!_teilnehmer.values.any((t) => !t.aufgegeben && t.rolle == g.rolle)) {
              'id': g.id, 'rolle': g.rolle, 'partner': g.partner, 'thema': g.thema, 'text': g.text,
              'preisgaben': [for (final z in g.preisgaben) {'quelle': z.quelle, 'text': z.text}],
            },
        ],
        if (p.phase == PartyPhase.anklage) 'verdaechtige': [..._kanon.kernverdaechtige],
      },
      'privat': {
        'spieler': id, 'detektiv': id == _detektiv,
        if (dossier != null) ...{
          'rolle': rolle, 'gelesen': ich.gelesen,
          'dossier': {
            'wer': dossier.wer, 'ziel': dossier.ziel, 'besetzung': dossier.besetzung,
            'weiss': [for (final z in dossier.weiss) z.text],
            'verbirgt': [for (final z in dossier.verbirgt) z.text],
            if (dossier.tarnung != null) 'tarnung': dossier.tarnung,
            if (dossier.tatwissen.isNotEmpty) 'tatwissen': [for (final z in dossier.tatwissen) z.text],
          },
          if (p!.phase == PartyPhase.gespraeche) 'gespraeche': [
            for (final (g, partner) in dossier.gespraeche[p.runde] ?? <(Gespraech, String)>[])
              {'partner': partner, 'thema': g.thema, 'ziel': g.ziel, 'text': g.text},
          ],
          if (p.phase == PartyPhase.gruppenwahl) ...{
            'hatGestimmt': _stimmen.containsKey(rolle),
            if (dossier.wahlen[p.runde] case final w?) 'wahl': {
              'a': w.a, 'b': w.sabotage ?? w.b,
            },
          },
        },
      },
      if (nachFinale) 'aufloesung': {
        'pfad': p.spiel.pfad, 'fallCode': _fallCode.code, 'salz': _salz,
        'punkte': p.spiel.punkte, 'ende': p.spiel.ende.id,
        'seifenblasen': p.seifenblasenBilanz,
        'abstecherFunde': [...p.abstecherFunde]..sort(),
      },
    };
  }
}
