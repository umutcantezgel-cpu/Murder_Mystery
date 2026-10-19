import '../../party/ablauf.dart';
import '../../party/befragung.dart';
import '../../party/texte.dart';
import '../schlosskeller_raum.dart' show PartyRaumFehler;
import 'raum_modul.dart';

/// Befragungen des Detektivs im Online-Abend (A-051, Modell befragung).
///
/// Nachrichten, nur vom Gerät des Detektivs und nur in den Gesprächen:
/// - `befragen {id, frage}`: Der Detektiv stellt eine Frage der Befragung `id`
///   aus dem Plan der Runde. Eine freie Befragung ist damit gewählt. Spricht die
///   App die Rolle, ist sie sofort erledigt, und nur der Detektiv bekommt die
///   Antwort; spielt ein Mensch die Rolle, antwortet er am Tisch.
/// - `erledigt {id}`: Die gestellte Befragung ist am Tisch beantwortet.
///
/// Gibt eine Person nach der Frage auf, spricht ab da die App ihre Rolle: Die
/// gestellte Befragung gilt als beantwortet, der Detektiv bekommt die Antwort.
/// Kommt das Gerät zurück, antwortet wieder der Mensch am Tisch.
///
/// „Weiter“ geht erst, wenn die Runde durch ist ([BefragungsVerlauf.fertig]).
/// Öffentlich sind nur Paarungen und Themen (`tisch`, `befragungen`), nie eine
/// Antwort oder ein Stichpunkt. Privat bekommt der Detektiv seine Karten
/// (Fragen, Stand, Antwort der App-Rollen), die befragte Rolle ihren Spickzettel.
/// Antwort und Spickzettel kommen als Karten zu höchstens drei Zeilen (R17,
/// E-044), damit jedes Gerät sie getrennt zeigt: `antwort` je Preisgabe eine
/// Liste, `karten` je Karte `{zeilen, behaupte}`.
class BefragungModul extends RaumModul {
  BefragungsVerlauf? _verlauf;

  @override
  Map<String, Set<String>> get nachrichten => const {
        'befragen': {'id', 'frage'},
        'erledigt': {'id'},
      };

  @override
  void beimStart(RaumKontext k) {
    final p = k.partie!;
    _verlauf = BefragungsVerlauf(Befragungsplan(k.texte), p.spiel.einstellungen.rollen);
  }

  bool _gespraeche(RaumKontext k) => k.phase == PartyPhase.gespraeche && _verlauf != null;

  /// Rollen, die gerade kein Mensch spielt: Für sie spricht die App.
  bool Function(String rolle) _appSpricht(RaumKontext k) => (rolle) => !k.menschSpielt(rolle);

  /// Beantwortet am Tisch oder von der App, weil kein Mensch die Rolle (mehr) spielt.
  bool _erledigt(RaumKontext k, String b) => _verlauf!.erledigt(b, appSpricht: _appSpricht(k));

  @override
  void nachricht(RaumKontext k, String id, String typ, Map<String, Object?> inhalt) {
    k.nurDetektiv(id);
    final v = _verlauf;
    if (v == null || k.phase != PartyPhase.gespraeche) throw const PartyRaumFehler('invalid_phase');
    final b = inhalt['id'];
    final r = k.runde;
    if (b is! String || !(v.pflicht(r).contains(b) || v.frei(r).contains(b))) throw const PartyRaumFehler('invalid');
    switch (typ) {
      case 'befragen':
        final frage = inhalt['frage'];
        if (frage is! int) throw const PartyRaumFehler('invalid');
        v.befragen(r, b, frage, sofort: !k.menschSpielt(v.text(b).rolle));
      case 'erledigt':
        if (!v.gefragt(b)) throw const PartyRaumFehler('invalid_phase');
        v.erledigen(r, b);
    }
  }

  @override
  bool darfWeiter(RaumKontext k) => !_gespraeche(k) || _verlauf!.fertig(k.runde, appSpricht: _appSpricht(k));

  @override
  Map<String, Object?> oeffentlich(RaumKontext k, String id) {
    if (!_gespraeche(k)) return const {};
    final v = _verlauf!;
    final r = k.runde;
    return {
      // Wen der Detektiv befragt: die festen und die schon gewählten freien Befragungen.
      'befragungen': [
        for (final b in [...v.pflicht(r), ...v.frei(r).where(v.gefragt)])
          {'rolle': v.text(b).rolle, 'thema': v.text(b).thema, 'erledigt': _erledigt(k, b)},
      ],
      'tisch': [
        for (final t in tischPaarungen(k.texte, n: v.rollen, runde: r)) {'rolle': t.rolle, 'partner': t.partner, 'thema': t.thema},
      ],
    };
  }

  @override
  Map<String, Object?> privat(RaumKontext k, String id) {
    if (!_gespraeche(k)) return const {};
    final v = _verlauf!;
    final r = k.runde;
    if (id == k.detektiv) {
      final pflicht = v.pflicht(r);
      return {
        'befragungen': [
          for (final b in [...pflicht, ...v.frei(r)])
            {
              'id': b,
              'rolle': v.text(b).rolle,
              'thema': v.text(b).thema,
              'fragen': [...v.text(b).fragen],
              'pflicht': pflicht.contains(b),
              'mensch': k.menschSpielt(v.text(b).rolle),
              'frage': v.frage(b),
              'erledigt': _erledigt(k, b),
              // Die Antwort der App kommt erst nach der Frage, und nur für Rollen ohne Menschen.
              if (v.gefragt(b) && !k.menschSpielt(v.text(b).rolle)) 'antwort': befragungsKarten(k.texte, v.text(b)),
            },
        ],
        'befragungenFrei': v.freiOffen(r),
      };
    }
    final rolle = k.rolleVon(id);
    if (rolle == null) return const {};
    final b = BefragungText.kennung(rolle, r);
    final text = v.text(b);
    final zettel = befragungsZettel(k.texte, text);
    final p = k.partie!;
    final plan = k.texte.gespraechsplan(v.rollen);
    final besetzt = p.spiel.besetzt;
    return {
      'befragung': {
        'id': b,
        'thema': text.thema,
        'fragen': [...text.fragen],
        'karten': [
          for (final z in zettel.karten) {'zeilen': z.zeilen, 'behaupte': z.behaupten},
        ],
        'pflicht': v.pflicht(r).contains(b),
        // Eine freie Befragung entfällt, wenn alle freien Wahlen schon getroffen sind.
        'entfaellt': !v.waehlbar(r, b),
        'frage': v.frage(b),
        'erledigt': _erledigt(k, b),
      },
      'angesprochen': [
        for (final g in k.texte.sammlung.gespraeche)
          if (g.runde == r && besetzt.contains(g.rolle) && plan[g.id] == rolle) {'sprecher': g.rolle, 'thema': g.thema},
      ],
    };
  }
}
