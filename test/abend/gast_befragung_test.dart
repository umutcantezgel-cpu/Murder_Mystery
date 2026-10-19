// Gastgeräte im Modell befragung (A-051): Ein Gast sieht nie, was eine andere
// Rolle dem Detektiv antwortet, weder Antworten der App noch fremde Spickzettel.
// Die befragte Person sieht ihren Spickzettel und die Frage des Detektivs;
// öffentlich sind nur Paarungen und Themen.
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte/abend/online/gast_befragung.dart';
import 'package:mordakte/l10n/gen/app_localizations_de.dart';
import 'package:mordakte/party/bildschirme/spickzettel.dart' show SpickKarte;
import 'package:mordakte_core/mordakte_core.dart';

import '../party_widgets/hilfe.dart' show partyDaten;
import 'online_hilfe.dart';

Map<String, Object?> _map(Object? wert) => (wert as Map).cast<String, Object?>();

/// Alle Texte einer Ansicht, wie sie über das Netz geht.
String _alles(Map<String, Object?> ansicht) => jsonEncode(ansicht);

/// Ein Text, wie er in der JSON-Ansicht steht (mit Anführungszeichen, damit nur ganze Einträge zählen).
String _eintrag(String text) => jsonEncode(text);

void main() {
  final texte = partyDaten.texte;
  final l = LDe();

  /// Was Rolle [rolle] in Runde [r] dem Detektiv sagt: die Antwort der App und der Spickzettel.
  Set<String> antworten(String rolle, int r) {
    final b = texte.sammlung.befragungen[BefragungText.kennung(rolle, r)]!;
    final z = befragungsZettel(texte, b);
    return {...befragungsAntwort(texte, b), ...z.sagen, ...z.behaupten, ...z.eigene};
  }

  test('Kein Gast sieht eine Antwort einer anderen Rolle; jeder sieht nur den eigenen Spickzettel', () {
    final raum = testRaum();
    starte(raum);
    final besetzt = texte.besetzung.besetzt(4);
    final rollen = {for (final g in ['g1', 'g2']) g: _map(raum.zustandFuer(g)['privat'])['rolle'] as String};
    var gepruft = 0;
    for (var r = 1; r <= 3; r++) {
      spieleBisPhase(raum, 'gespraeche');
      expect(raum.zustandFuer('gastgeber')['runde'], r);
      void pruefe(String wann) {
        for (final MapEntry(key: gast, value: eigene) in rollen.entries) {
          final v = raum.zustandFuer(gast);
          final privat = _map(v['privat']);
          final sicht = _alles(v);
          expect(privat.containsKey('befragungen'), isFalse, reason: '$wann: Nur der Detektiv hat Befragungskarten');
          expect(sicht.contains('"antwort"'), isFalse, reason: '$wann: $gast bekommt keine Antwort der App');
          final mein = antworten(eigene, r);
          for (final x in besetzt.where((x) => x != eigene)) {
            for (final a in antworten(x, r).where((a) => !mein.contains(a))) {
              expect(sicht.contains(_eintrag(a)), isFalse, reason: '$wann: $gast ($eigene) sieht, was $x sagt: $a');
              gepruft++;
            }
          }
          // Der eigene Spickzettel: Stichpunkte in der Du-Form, Behauptungen eigener Lügen.
          final b = texte.sammlung.befragungen[BefragungText.kennung(eigene, r)]!;
          final z = befragungsZettel(texte, b);
          final zettel = _map(privat['befragung']);
          // Als Karten (R17, E-044): je Preisgabe eine, Behauptungen markiert, zuletzt die Würze.
          expect(zettel['karten'], [for (final k in z.karten) {'zeilen': k.zeilen, 'behaupte': k.behaupten}], reason: '$wann: $gast');
          expect(zettel['fragen'], b.fragen, reason: '$wann: $gast');
          // Öffentlich nur, wen der Detektiv befragt und wer am Tisch mit wem worüber spricht.
          for (final e in (v['befragungen'] as List).map(_map)) {
            expect(e.keys.toSet(), {'rolle', 'thema', 'erledigt'}, reason: wann);
          }
          for (final e in (v['tisch'] as List).map(_map)) {
            expect(e.keys.toSet(), {'rolle', 'partner', 'thema'}, reason: wann);
          }
        }
      }

      pruefe('Runde $r vor den Fragen');
      befragungenImRaum(raum);
      pruefe('Runde $r nach den Fragen');
      raum.nachricht('gastgeber', {'typ': 'weiter'});
    }
    expect(gepruft, greaterThan(50), reason: 'Es wurden fremde Antworten geprüft');
  });

  testWidgets('Die befragte Person sieht die Frage und ihren Spickzettel zuoberst, nichts von anderen', (tester) async {
    final raum = testRaum();
    starte(raum);
    spieleBisPhase(raum, 'gespraeche');
    final eigene = _map(raum.zustandFuer('g1')['privat'])['rolle'] as String;
    final karten = [for (final k in _map(raum.zustandFuer('gastgeber')['privat'])['befragungen'] as List) _map(k)];
    final meine = karten.firstWhere((k) => k['rolle'] == eigene);
    // Der Detektiv stellt Ben die zweite Frage und befragt eine Rolle der App.
    raum.nachricht('gastgeber', {'typ': 'befragen', 'id': meine['id'], 'frage': 1});
    final bots = [for (final k in karten) if (k['mensch'] != true) k]..sort((a, b) => (b['pflicht'] == true ? 1 : 0) - (a['pflicht'] == true ? 1 : 0));
    final frei = _map(raum.zustandFuer('gastgeber')['privat'])['befragungenFrei'] as int;
    if (bots.first['pflicht'] == true || frei > 0) raum.nachricht('gastgeber', {'typ': 'befragen', 'id': bots.first['id'], 'frage': 0});

    await zeigeImThema(tester, (c) => gastSeite(c, raum.zustandFuer('g1')), groesse: const Size(390, 5000));
    expect(find.byType(GastBefragung), findsOneWidget);
    final b = texte.sammlung.befragungen[meine['id']]!;
    final z = befragungsZettel(texte, b);
    expect(find.text(l.party_befragung_fragt(b.fragen[1])), findsOneWidget);
    for (final p in z.stichpunkte) {
      expect(find.text(p), findsWidgets, reason: p);
    }
    for (final p in z.behaupten) {
      expect(find.text(l.party_befragung_behaupte(p)), findsOneWidget, reason: p);
    }
    // Je Karte ein Block (R17): so viele Karten wie im Zettel, jede mit ihren Zeilen.
    final bloecke = find.byType(SpickKarte);
    expect(bloecke, findsNWidgets(z.karten.length));
    for (final (i, k) in z.kartenZeilen(l.party_befragung_behaupte).indexed) {
      for (final zeile in k) {
        expect(find.descendant(of: bloecke.at(i), matching: find.text(zeile)), findsOneWidget, reason: zeile);
      }
    }
    // Fragt der Detektiv, steht die eigene Befragung über dem Tischgespräch.
    final oben = tester.getTopLeft(find.text(l.party_befragung_dich.toUpperCase())).dy;
    expect(oben, lessThan(tester.getTopLeft(find.text(l.party_befragung_tisch_eigen.toUpperCase())).dy));
    // Öffentlich: wen der Detektiv befragt, und die Paarungen am Tisch.
    expect(find.text(l.party_befragung_oeffentlich.toUpperCase()), findsOneWidget);
    expect(find.text(l.party_befragung_tisch_titel.toUpperCase()), findsOneWidget);
    final mein = antworten(eigene, 1);
    for (final x in texte.besetzung.besetzt(4).where((x) => x != eigene)) {
      for (final a in antworten(x, 1).where((a) => !mein.contains(a))) {
        expect(find.text(a), findsNothing, reason: '$x: $a');
      }
    }
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
