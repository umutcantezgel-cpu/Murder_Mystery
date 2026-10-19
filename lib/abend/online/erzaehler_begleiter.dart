import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mordakte_core/mordakte_core.dart' show Befragungsplan, PartyPhase, erzaehlerPaket;
import 'package:mordakte_core/runden.dart' show AbendRaum, PartyRaumFehler, Sitz;
import 'package:mordakte_netz/mordakte_netz.dart' show RelayHost, RelayParameter;

import '../../l10n/gen/app_localizations_de.dart';
import '../../l10n/lookup.dart';
import '../../netz/relay_einstellung.dart';
import '../../party/erzaehler_begleitung.dart';
import '../../party/sitzung.dart';
import '../../stil/stil.dart';
import 'ansicht.dart' show inhaltsKennung;
import 'gastgeber_lobby.dart' show OnlineCodeTafel;
import 'online_teile.dart' show OnlineWarteNotiz;

/// Namen im Raum stehen deutsch, auch ohne Lokalisierung im Baum.
final _de = LDe();

/// Der Raum des Erzähler-Begleiters (Langer Abend M3b): zwei Plätze, das
/// Reihum-Gerät ([tisch], es hält den Abend) und der Erzähler am eigenen Handy.
///
/// Die Ansicht des Erzählers hat die Form eines Erzähler-Sitzes im
/// Online-Abend (`SchlosskellerRaum`), damit sein Handy die gewohnte Gastseite
/// zeigt: die Erzähltexte des Schritts, sein pfadfreies Erzählerpaket (A-052),
/// wen der Detektiv befragt, und „Weiter“, sobald der Abschnitt fertig ist.
/// Nie Dossier, Tarnung, Spickzettel, Pfad oder Salz: Die Ansicht entsteht nur
/// aus öffentlichen Angaben, den Erzähltexten und dem Paket.
class BegleiterRaum implements AbendRaum {
  BegleiterRaum(this.raumCode, this.sitzung, {this.beiAenderung});

  /// Platz des Reihum-Geräts.
  static const tisch = 'tisch';

  @override
  final String raumCode;
  final PartySitzung sitzung;

  /// Nach Beitritt, Trennung oder Verlassen des Erzählers.
  final void Function()? beiAenderung;

  String? _erzaehler;
  String _name = '';
  bool _online = false;
  bool _zu = false;
  int _version = 0;
  late final Befragungsplan _plan = Befragungsplan(sitzung.daten.texte);
  final Map<(int, int), Map<String, Object?>> _pakete = {};

  /// Platz des Erzählers, sobald er beigetreten ist.
  String? get erzaehler => _erzaehler;

  /// Name, mit dem der Erzähler beigetreten ist (leer vor dem Beitritt).
  String get erzaehlerName => _name;

  /// Ist der Erzähler beigetreten und gerade verbunden?
  bool get erzaehlerOnline => !_zu && _erzaehler != null && _online;

  /// Schließt den Raum: kein Beitritt, keine Nachricht mehr.
  void schliessen() {
    _zu = true;
    _version++;
  }

  @override
  int get version => _version;

  @override
  int get maxSpieler => 2;

  /// Bis der Erzähler beigetreten ist, ist der Raum offen; danach kommt nur er zurück.
  @override
  bool get vorStart => !_zu && _erzaehler == null;

  @override
  bool get beendet => _zu;

  @override
  List<String> get spielerIds => [tisch, ?_erzaehler];

  void _geaendert() {
    _version++;
    beiAenderung?.call();
  }

  @override
  bool beitreten(String id, String name) {
    if (_zu) return false;
    if (id == tisch) return true;
    if (_erzaehler == null) {
      _erzaehler = id;
      _name = name.trim();
    } else if (id != _erzaehler) {
      return false;
    }
    _online = true;
    _geaendert();
    return true;
  }

  @override
  void verlassen(String id) {
    if (id != _erzaehler) return;
    _erzaehler = null;
    _name = '';
    _online = false;
    _geaendert();
  }

  @override
  void verbunden(String id, bool ja) {
    if (id != _erzaehler || _online == ja) return;
    _online = ja;
    _geaendert();
  }

  /// Abschnitte, die der Erzähler vom Handy aus beendet. Die Rollen (jede
  /// Person liest verdeckt am Gerät), die Anklage und das Ende führt das Gerät.
  static const _fuehrt = {
    PartyPhase.intro,
    PartyPhase.gespraeche,
    PartyPhase.entscheidungen,
    PartyPhase.gruppenwahl,
    PartyPhase.bonus,
    PartyPhase.resuemee,
    PartyPhase.finale,
  };

  /// Darf der Erzähler jetzt „Weiter“ drücken? Nur, wenn das Gerät selbst
  /// weiter könnte und gerade niemand verdeckt liest.
  bool get kannWeiter => !_zu && _fuehrt.contains(sitzung.phase) && sitzung.verdeckt == null && sitzung.kannWeiter;

  @override
  void nachricht(String id, Map<String, Object?> inhalt) {
    if (_zu) throw const PartyRaumFehler('invalid_phase');
    if (id != _erzaehler) throw const PartyRaumFehler('not_host');
    switch (inhalt['typ']) {
      case 'weiter':
        if (!kannWeiter) throw const PartyRaumFehler('not_ready');
        sitzung.weiter();
        _version++;
      default:
        throw const PartyRaumFehler('invalid');
    }
  }

  /// Letzte Ansicht je Platz (ohne Version): Ändert sie sich, zählt [version]
  /// hoch. Das Handy nimmt nur Ansichten mit höherer Version an; das Gerät
  /// ändert den Abend aber ohne Nachricht an den Raum.
  final Map<String, String> _letzte = {};

  @override
  Map<String, Object?> zustandFuer(String id) {
    final ansicht = _ansicht(id);
    final text = jsonEncode(ansicht);
    if (_letzte[id] != text) {
      _letzte[id] = text;
      _version++;
    }
    return {'version': _version, ...ansicht};
  }

  Map<String, Object?> _ansicht(String id) {
    final kopf = {'t': 'abend', 'protokoll': 1, 'spiel': sitzung.daten.fall, 'akte': sitzung.daten.fall, 'raum': raumCode};
    if (id == tisch) return {...kopf, 'phase': _phase, 'privat': {'spieler': id}};
    if (id != _erzaehler) throw const PartyRaumFehler('not_in_room');
    final s = sitzung;
    final runde = s.runde;
    return {
      ...kopf,
      'phase': _phase,
      'runde': runde,
      'host': tisch,
      'erzaehlerLiest': true,
      'kannWeiter': kannWeiter,
      'spieler': [
        {'id': tisch, 'name': s.detektivName.trim().isEmpty ? _de.abend_platz_detektiv : s.detektivName.trim(), 'sitz': Sitz.detektiv.name, 'online': true},
        // Reihum ist öffentlich, wer welche Figur spielt (Einrichtung).
        for (final rolle in s.besetzt) {'id': 'rolle:$rolle', 'name': s.namen[rolle] ?? '', 'rolle': rolle, 'online': true},
        {'id': id, 'name': _name, 'sitz': Sitz.erzaehler.name, 'online': _online},
      ],
      // Wen der Detektiv befragt (öffentlich: Person, Thema, Stand).
      'befragungen': [
        for (final b in s.befragungen)
          if (b.pflicht || b.frage != null) {'rolle': b.rolle, 'thema': b.thema, 'erledigt': b.erledigt},
      ],
      'privat': {
        'spieler': id,
        'vorleser': true,
        'erzaehler': [
          for (final k in s.erzaehler)
            if (s.hatText(k)) s.text(k),
        ],
        if (s.befragungsmodell && runde >= 1) 'erzaehlerPaket': _paket(s.einstellungen.rollen, runde.clamp(1, Befragungsplan.runden)),
      },
    };
  }

  /// Abschnitt in der Schreibweise des Online-Raums; vor den Rollen „lobby“,
  /// das Ende zeigt das Handy wie das Finale (das Gerät schließt den Raum dann).
  String get _phase => switch (sitzung.phase) {
        PartyPhase.titel || PartyPhase.einrichtung => 'lobby',
        PartyPhase.ende => PartyPhase.aufloesung.name,
        final p => p.name,
      };

  Map<String, Object?> _paket(int n, int runde) =>
      _pakete.putIfAbsent((n, runde), () => erzaehlerPaket(sitzung.daten.texte, _plan, n: n, runde: runde).toJson());
}

/// Erzähler-Begleiter für einen Reihum-Abend mit Erzähler am Tisch
/// ([PartySitzung.erzaehlerAmPult]): öffnet auf Wunsch („Am eigenen Handy
/// lesen“) über das Relais einen Raum nur mit dem Erzählersitz
/// ([BegleiterRaum]). Der Erzähler tritt mit Code oder QR-Code bei wie ein
/// Gast; solange er verbunden ist, zeigt das Gerät statt der Texte „… liest
/// vor“ ([liest]). Ohne Ablage: Nach dem Neuladen tritt er neu bei.
class ErzaehlerBegleiter extends ChangeNotifier implements ErzaehlerBegleitung {
  ErzaehlerBegleiter(this.sitzung, {this.relay, this.log});

  final PartySitzung sitzung;

  /// Relais (Tests: die Attrappe); sonst das der Seite.
  final RelayParameter? relay;

  /// Protokoll des Relais (Tests, Fehlersuche).
  final void Function(String)? log;

  RelayHost? _host;
  BegleiterRaum? _raum;
  Future<void>? _laeuft;
  bool _fehler = false;
  bool _entsorgt = false;
  bool _neuGeplant = false;

  /// Ist der Raum offen (Code steht fest)?
  bool get offen => _host != null;

  /// Öffnet sich der Raum gerade?
  bool get oeffnet => _laeuft != null;

  /// Ließ sich der Raum zuletzt nicht öffnen (kein Netz, Relais weg)?
  bool get fehler => _fehler;

  /// Raumcode (6 Zeichen), solange offen.
  String? get code => _host?.raumCode;

  /// Der Raum (Tests).
  @visibleForTesting
  BegleiterRaum? get raum => _raum;

  /// Das Relais des Raums (Tests).
  @visibleForTesting
  RelayHost? get host => _host;

  /// Name des Erzählers: wie beigetreten, sonst wie in der Einrichtung.
  String get erzaehlerName {
    final n = _raum?.erzaehlerName ?? '';
    return n.isNotEmpty ? n : sitzung.erzaehlerName;
  }

  @override
  bool get liest => _raum?.erzaehlerOnline ?? false;

  /// Öffnet den Raum (einmal; ein zweiter Aufruf wartet auf denselben Lauf).
  Future<void> oeffnen() {
    if (_host != null || _entsorgt) return Future.value();
    return _laeuft ??= _oeffnen().whenComplete(() {
      _laeuft = null;
      if (!_entsorgt) notifyListeners();
    });
  }

  Future<void> _oeffnen() async {
    _fehler = false;
    notifyListeners();
    RelayHost? host;
    try {
      final inhalt = await inhaltsKennung();
      host = await RelayHost.neu(
        fabrik: (code, _) => _raum = BegleiterRaum(code, sitzung, beiAenderung: _raumGeaendert),
        relay: relay ?? relayFuerSeite(),
        akte: sitzung.daten.fall,
        inhalt: inhalt,
        log: log,
      );
      host.lokaleVerbindung(BegleiterRaum.tisch, sitzung.detektivName);
      await host.starten();
      if (_entsorgt) {
        await host.schliessen();
        return;
      }
      _host = host;
      sitzung.addListener(_sitzungGeaendert);
    } catch (e) {
      debugPrint('BEGLEITER fehler $e');
      _fehler = true;
      _raum = null;
      try {
        await host?.schliessen();
      } catch (_) {}
    }
  }

  /// Das Gerät ist weiter (oder der Erzähler hat „Weiter“ gedrückt): Das Handy
  /// bekommt seine Ansicht neu. Am Ende schließt der Raum.
  void _sitzungGeaendert() {
    if (sitzung.phase == PartyPhase.ende) {
      unawaited(schliessen());
      return;
    }
    if (_neuGeplant) return;
    _neuGeplant = true;
    scheduleMicrotask(() {
      _neuGeplant = false;
      _host?.ansichtenNeu();
    });
  }

  /// Der Erzähler ist beigetreten, getrennt oder gegangen. Gemeldet wird nach
  /// dem laufenden Schritt des Relais, nicht mitten darin.
  void _raumGeaendert() => scheduleMicrotask(() {
        if (!_entsorgt) notifyListeners();
      });

  @override
  Future<void> schliessen() async {
    final host = _host;
    _host = null;
    _raum?.schliessen();
    _raum = null;
    sitzung.removeListener(_sitzungGeaendert);
    if (!_entsorgt) notifyListeners();
    if (host != null) {
      try {
        await host.schliessen();
      } catch (_) {}
    }
  }

  @override
  Future<void> zeigen(BuildContext context) {
    if (!offen && !oeffnet) unawaited(oeffnen());
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (_) => BegleiterKarte(begleiter: this),
    );
  }

  @override
  void dispose() {
    _entsorgt = true;
    if (identical(sitzung.begleitung, this)) sitzung.begleitung = null;
    unawaited(schliessen());
    super.dispose();
  }
}

/// Karte zum Erzähler-Begleiter: erst „verbinde …“, dann Code und QR-Code mit
/// einer Zeile, wie der Erzähler beitritt; sobald er liest, nur das. Bei einem
/// Fehler „noch einmal“; „Wieder am Pult lesen“ schließt den Raum.
class BegleiterKarte extends StatelessWidget {
  const BegleiterKarte({super.key, required this.begleiter});

  final ErzaehlerBegleiter begleiter;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: begleiter,
        builder: (context, _) {
          final l = L.of(context);
          final b = begleiter;
          final name = b.erzaehlerName.trim().isEmpty ? l.vorleser_erzaehler : b.erzaehlerName.trim();
          final code = b.code;
          void zurueck() => Navigator.of(context).pop();
          final zurueckKnopf = MKnopf(key: const ValueKey('begleiter-zurueck'), text: l.begleiter_zurueck, art: MKnopfArt.zweit, onPressed: zurueck);
          final beenden = MKnopf(
            key: const ValueKey('begleiter-beenden'),
            text: l.begleiter_beenden,
            art: MKnopfArt.zweit,
            icon: Icons.menu_book_rounded,
            onPressed: () {
              unawaited(b.schliessen());
              zurueck();
            },
          );
          final (Widget inhalt, List<Widget> aktionen) = switch (b) {
            _ when b.liest => (
                MGanzeWorte(l.begleiter_liest(name), key: const ValueKey('begleiter-liest'), stil: MPapierSchrift.ueberschrift.copyWith(fontSize: 20)),
                [beenden, zurueckKnopf],
              ),
            _ when code != null => (
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(l.begleiter_anleitung(name), style: MPapierSchrift.text),
                    const SizedBox(height: MMass.s12),
                    OnlineCodeTafel(key: const ValueKey('begleiter-code'), code: code, link: beitrittsLink(code), sigel: AkteStil.fuer(b.sitzung.daten.fall).sigel),
                    const SizedBox(height: MMass.s12),
                    Text(l.begleiter_hinweis, style: MPapierSchrift.leise),
                  ],
                ),
                [beenden, zurueckKnopf],
              ),
            _ when b.fehler => (
                Text(l.begleiter_fehler, key: const ValueKey('begleiter-fehler'), style: MPapierSchrift.text),
                [
                  zurueckKnopf,
                  MKnopf(key: const ValueKey('begleiter-nochmal'), text: l.begleiter_nochmal, icon: Icons.refresh_rounded, onPressed: () => unawaited(b.oeffnen())),
                ],
              ),
            _ => (OnlineWarteNotiz(text: l.online_lobby_verbinde), [zurueckKnopf]),
          };
          // Die Knöpfe stehen mit im Rollbereich: Schmal und mit großer Schrift
          // passt die Karte so immer auf den Schirm.
          return MKarteikartenDialog(
            titel: l.begleiter_titel,
            inhalt: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                inhalt,
                const SizedBox(height: 18),
                Wrap(alignment: WrapAlignment.end, spacing: 10, runSpacing: 8, children: aktionen),
              ],
            ),
          );
        },
      );
}
