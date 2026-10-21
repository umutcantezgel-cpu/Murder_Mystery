// Nachschliff M3: Die Altakten (Gewölbe, Ravensmoor, Nachtexpress, Blue Palm)
// laufen online unverändert (Besitzerentscheidung 1). Der Sitz des Ermittlers
// trägt das Wort der Akte (Noir „Inspektor“, Gewölbe „Geburtstagskind“), die
// Statustexte der Gäste sagen wie vor M3 „Spielleitung“ statt „Detektiv“, und
// nur der Schlosskeller spricht vom Detektiv.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte/l10n/gen/app_localizations_de.dart';
import 'package:mordakte/party/daten.dart';
import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/runden.dart';

import '../party_widgets/hilfe.dart' show akteDaten;
import 'online_hilfe.dart';

final l = LDe();

Map<String, Object?> _map(Object? wert) => (wert as Map).cast<String, Object?>();
List<Map<String, Object?>> _liste(Object? wert) => [for (final v in wert as List) _map(v)];

/// Gestarteter Raum der Akte [daten]: Anna (Gastgeberin, Detektiv-Sitz), Ben, Cleo, Dora.
SchlosskellerRaum _raum(PartyDaten daten) {
  final raum = SchlosskellerRaum(
    raumCode: 'ABCDEF',
    kanon: daten.kanon,
    texte: daten.texte,
    fallCode: FallCode.fuerPfad(daten.kanon.pfade.first, daten.kanon.pfade),
    salz: 'salz-test',
    akte: daten.fall,
    festerGastgeber: true,
  );
  for (final (id, name) in [('gastgeber', 'Anna'), ('g1', 'Ben'), ('g2', 'Cleo'), ('g3', 'Dora')]) {
    raum.beitreten(id, name);
    raum.nachricht(id, {'typ': 'bereit', 'wert': true});
  }
  raum.nachricht('gastgeber', {'typ': 'start', 'rollen': 4, 'detektiv': 'w', 'vorrat': const <String>[]});
  return raum;
}

/// Bis zur ersten offenen Frage der Entscheidungen (die Gäste lesen und stimmen nicht ab, wo es nicht nötig ist).
void _bisZurFrage(SchlosskellerRaum raum) {
  for (var i = 0; i < 50; i++) {
    final s = raum.zustandFuer('gastgeber');
    if (s['phase'] == 'entscheidungen' && s['entscheidung'] is Map && s['zug'] == null) return;
    if (s['phase'] == 'rollen') {
      for (final t in _liste(s['spieler'])) {
        if (t['rolle'] != null) raum.nachricht(t['id'] as String, {'typ': 'rollenGelesen'});
      }
    }
    if (s['phase'] == 'gespraeche') befragungenImRaum(raum);
    if (s['zug'] case final Map zug) {
      // Der Auftakt der Runde (Fund) und Würfe vor der ersten Frage.
      switch (zug['phase']) {
        case 'aktion':
          raum.nachricht('gastgeber', {'typ': 'aktionFertig', 'aktion': zug['aktion']});
        case 'wurf':
          raum.nachricht(s['wuerfelPate'] as String, {'typ': 'wurf'});
        case 'tischruf':
          raum.nachricht('gastgeber', {'typ': 'tischruf', 'ruf': 'umweg'});
        case 'fund':
          raum.nachricht('gastgeber', {'typ': 'fundGelesen'});
      }
      continue;
    }
    raum.nachricht('gastgeber', {'typ': 'weiter'});
  }
  fail('Keine offene Frage erreicht');
}

void main() {
  for (final akte in ['schlosskeller', 'gewoelbe', 'ravensmoor', 'nachtexpress', 'blue_palm']) {
    testWidgets('$akte: Wort für den Ermittler am Tisch und Statustexte der Gäste', (tester) async {
      final daten = akteDaten(akte);
      final neu = daten.mitErzaehlerSitz;
      expect(neu, akte == 'schlosskeller');
      final wort = daten.texte.baustein('ui.allgemein.detektiv');
      final raum = _raum(daten);
      final ben = LiveGast(raum, spielerId: 'g1', daten: daten);
      _bisZurFrage(raum);
      await zeigeImThema(tester, (c) => gastSeiteLive(ben), groesse: const Size(390, 3000));
      // Am Tisch trägt der Platz des Gastgebers das Wort der Akte.
      expect(find.text(wort), findsWidgets, reason: 'Etikett des Detektiv-Sitzes');
      if (wort != l.abend_platz_detektiv) expect(find.text(l.abend_platz_detektiv), findsNothing);
      // Entscheidungen: wer wählt.
      expect(find.text(neu ? l.online_ermittlung_wartet : l.online_ermittlung_wartet_leitung), findsOneWidget);
      expect(find.text(neu ? l.online_ermittlung_wartet_leitung : l.online_ermittlung_wartet), findsNothing);
      // Der Weg läuft.
      final e = _map(raum.zustandFuer('gastgeber')['entscheidung']);
      raum.nachricht('gastgeber', {'typ': 'wahl', 'option': _liste(e['optionen']).first['id']});
      ben.geaendert();
      await tester.pump();
      expect(find.text(neu ? l.online_zug_aktion : l.online_zug_aktion_leitung), findsOneWidget);
      if (!neu) {
        // Wie vor M3 nennt kein Statustext einer Altakte den Detektiv.
        expect(find.textContaining('Der Detektiv'), findsNothing);
      }
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
}
