// Finale Schlosskeller (A-063) online: die Erzählerakte gehört nur dem
// Erzähler-Sitz. Der Gast auf dem Erzähler-Sitz öffnet sie aus der Akte seines
// Geräts (nie über den Raum); Rolle, Detektiv und Assistenz sehen keinen Knopf,
// in der Lobby und ab dem Finale niemand. Ist der Gastgeber Erzähler, liegt sie
// in Menü und Pult seiner Sitzung; als Detektiv nicht.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte/abend/online/gast_erzaehler.dart' show gastErzaehlerakteErlaubt, gastMitMoment;
import 'package:mordakte/abend/online/gastgeber_sitzung.dart';
import 'package:mordakte/l10n/gen/app_localizations_de.dart';
import 'package:mordakte/party/erzaehlerakte_ansicht.dart';
import 'package:mordakte_core/runden.dart' show SchlosskellerRaum, Sitz;

import '../party_widgets/einfluss_hilfe.dart' show einflussDaten;
import '../party_widgets/erzaehl_hilfe.dart';
import '../party_widgets/hilfe.dart' show partyDaten, rahmen;
import 'online_hilfe.dart';

final l = LDe();

/// Raum mit 23 Geräten (zwanzig Rollen und Greta ohne Figur): Anna ermittelt, Cleo (`g2`) erzählt.
SchlosskellerRaum _raum({String detektiv = 'gastgeber', String erzaehler = 'g2'}) =>
    sitzRaum(detektiv: detektiv, erzaehler: erzaehler, daten: erzaehlDaten, ohneFigur: true);

const _knopf = ValueKey('erzaehlerakte-knopf');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Nur der Erzähler-Sitz hat den Knopf; die Akte kommt vom Gerät und zeigt die besetzten Figuren zuerst', (t) async {
    final raum = _raum();
    spieleBisSitz(raum, 'rollen', detektiv: 'gastgeber', leiter: 'g2');
    final cleo = LiveGast(raum, spielerId: 'g2', daten: erzaehlDaten);
    final rolle = LiveGast(raum, spielerId: 'g1', daten: erzaehlDaten);
    final greta = LiveGast(raum, spielerId: 'g22', daten: erzaehlDaten);
    expect([gastErzaehlerakteErlaubt(cleo), gastErzaehlerakteErlaubt(rolle), gastErzaehlerakteErlaubt(greta)], [true, false, false]);
    expect(raum.zustandFuer('g2').toString().contains('hintergrund'), isFalse, reason: 'Der Raum überträgt die Akte nie');
    for (final g in [rolle, greta]) {
      await zeigeImThema(t, (_) => gastSeiteLive(g));
      expect(find.byKey(_knopf), findsNothing, reason: g.spielerId);
      expect(find.text(l.erzaehlerakte_pdf), findsNothing, reason: g.spielerId);
    }
    await zeigeImThema(t, (_) => gastSeiteLive(cleo));
    expect(find.text(l.erzaehlerakte_pdf), findsNothing, reason: 'Erst in der offenen Akte');
    await t.ensureVisible(find.byKey(_knopf));
    await t.tap(find.byKey(_knopf));
    await t.pumpAndSettle();
    expect(find.byType(ErzaehlerakteSeite), findsOneWidget);
    final seite = t.widget<ErzaehlerakteSeite>(find.byType(ErzaehlerakteSeite));
    expect(seite.besetzt, raum.partieFuerGastgeber!.spiel.besetzt);
    expect(seite.spieler!('ahmet'), isNotEmpty, reason: 'Wer die Figur spielt, steht in der Akte');
    expect(seite.einfluss, isFalse, reason: 'Ohne „Dein Moment“ die Ziele des Kanons');
    // „Als PDF“ mit der Rollenzahl des Raums, wie die Akte sie zeigt.
    expect(seite.rollen, raum.partieFuerGastgeber!.spiel.besetzt.length);
    expect(find.text(l.erzaehlerakte_pdf), findsOneWidget);
    expect(find.text(l.erzaehlerakte_reiter_netz), findsOneWidget);
    await t.tap(find.byKey(const ValueKey('erzaehlerakte-schliessen')));
    await t.pumpAndSettle();
    expect(find.byType(ErzaehlerakteSeite), findsNothing);
    await t.pumpWidget(const SizedBox.shrink());
  });

  test('Mit „Dein Moment“ im Raum zeigt die Erzählerakte des Gastes die Sterne, sonst die Ziele des Kanons', () {
    final mit = sitzRaum(erzaehler: 'g2', daten: einflussDaten, einfluss: einflussDaten.einfluss);
    spieleBisSitz(mit, 'rollen', detektiv: 'gastgeber', leiter: 'g2');
    expect(gastMitMoment(LiveGast(mit, spielerId: 'g2', daten: einflussDaten)), isTrue);
    final ohne = sitzRaum(erzaehler: 'g2', daten: einflussDaten);
    spieleBisSitz(ohne, 'rollen', detektiv: 'gastgeber', leiter: 'g2');
    expect(gastMitMoment(LiveGast(ohne, spielerId: 'g2', daten: einflussDaten)), isFalse);
  });

  testWidgets('Ab dem Finale ist sie weg und schließt sich selbst; in der Lobby gibt es sie noch nicht', (t) async {
    final lobby = lobbyRaum(daten: erzaehlDaten);
    lobby.nachricht('gastgeber', {'typ': 'sitz', 'spieler': 'g2', 'sitz': 'erzaehler'});
    expect(gastErzaehlerakteErlaubt(LiveGast(lobby, spielerId: 'g2', daten: erzaehlDaten)), isFalse, reason: 'Vor dem Start');
    final raum = _raum();
    spieleBisSitz(raum, 'anklage', detektiv: 'gastgeber', leiter: 'g2');
    final cleo = LiveGast(raum, spielerId: 'g2', daten: erzaehlDaten);
    await zeigeImThema(t, (_) => gastSeiteLive(cleo));
    await t.ensureVisible(find.byKey(_knopf));
    await t.tap(find.byKey(_knopf));
    await t.pumpAndSettle();
    expect(find.byType(ErzaehlerakteSeite), findsOneWidget);
    spieleBisSitz(raum, 'finale', detektiv: 'gastgeber', leiter: 'g2');
    cleo.geaendert();
    await t.pumpAndSettle();
    expect(find.byType(ErzaehlerakteSeite), findsNothing, reason: 'Nie ab dem Finale');
    expect(find.byKey(_knopf), findsNothing);
    expect(gastErzaehlerakteErlaubt(cleo), isFalse);
    // Eine Akte ohne Erzählerakte bietet sie nie an.
    expect(gastErzaehlerakteErlaubt(LiveGast(_raum(), spielerId: 'g2', daten: partyDaten)), isFalse);
    await t.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Gastgebergerät: als Erzähler in der Sitzung und am Pult, als Detektiv nie', (t) async {
    final raum = _raum(detektiv: 'g1', erzaehler: 'gastgeber');
    spieleBisSitz(raum, 'gespraeche', detektiv: 'g1', leiter: 'gastgeber');
    final s = GastgeberSitzung(SitzDienst(raum, daten: erzaehlDaten));
    addTearDown(s.dispose);
    expect([s.sitz, s.istDetektiv, s.erzaehlerakteSichtbar], [Sitz.erzaehler, false, true]);
    await t.pumpWidget(rahmen(ErzaehlerakteKnopf(sitzung: s)));
    expect(find.byKey(_knopf), findsOneWidget);
    spieleBisSitz(raum, 'finale', detektiv: 'g1', leiter: 'gastgeber');
    expect(s.erzaehlerakteSichtbar, isFalse);
    final detektiv = _raum();
    spieleBisSitz(detektiv, 'gespraeche', detektiv: 'gastgeber', leiter: 'g2');
    final d = GastgeberSitzung(SitzDienst(detektiv, daten: erzaehlDaten));
    addTearDown(d.dispose);
    expect([d.istDetektiv, d.erzaehlerakteSichtbar], [true, false]);
    await t.pumpWidget(rahmen(ErzaehlerakteKnopf(sitzung: d)));
    expect(find.byKey(_knopf), findsNothing);
    await t.pumpWidget(const SizedBox.shrink());
  });
}
