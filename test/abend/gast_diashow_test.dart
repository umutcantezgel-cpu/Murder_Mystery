// Langer Abend M4 online: Diashow zur Einleitung und gemeinsame Rundenuhr auf
// den Geräten der Gäste. Alle sehen dasselbe Bild, nur der Vorleser-Sitz den
// Text dazu; die Uhr sehen alle, Start, Pause und plus fünf hat nur, wer leitet.
// Die Abendzeit jedes Befehls setzt der Transport (hier [LiveGast.abendzeit]).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte/l10n/gen/app_localizations_de.dart';
import 'package:mordakte/party/diashow_ansicht.dart';
import 'package:mordakte_core/runden.dart' show RundenUhr, SchlosskellerRaum;

import '../party_widgets/hilfe.dart' show diashowDaten;
import 'online_hilfe.dart';

final l = LDe();

/// Raum mit Diashow ([dias] Bilder, 0: ohne). Ohne Angabe ermittelt Anna (der
/// Gastgeber), Cleo (`g2`) erzählt und leitet, Ben (`g1`) und Dora (`g3`)
/// spielen Rollen. Der Gastgeber sitzt immer auf einem der beiden Sitze.
SchlosskellerRaum _raum({int dias = 6, String detektiv = 'gastgeber', String erzaehler = 'g2'}) =>
    sitzRaum(detektiv: detektiv, erzaehler: erzaehler, daten: diashowDaten, diaAnzahl: dias);

/// Erzähltexte, die der Raum dem Gerät [id] privat gibt.
List<String> _texte(SchlosskellerRaum raum, String id) =>
    [for (final t in ((raum.zustandFuer(id)['privat'] as Map?)?['erzaehler'] as List?) ?? const []) t as String];

LiveGast _gast(SchlosskellerRaum raum, String id) => LiveGast(raum, spielerId: id, daten: diashowDaten);

void main() {
  testWidgets('Online: alle Gäste sehen dasselbe Bild, nur der Vorleser-Sitz den Text; wer leitet, schaltet weiter', (t) async {
    final raum = _raum();
    spieleBisSitz(raum, 'intro', detektiv: 'gastgeber', leiter: 'g2');
    final cleo = _gast(raum, 'g2'), ben = _gast(raum, 'g1'), dora = _gast(raum, 'g3');
    final texte = _texte(raum, 'g2');
    expect(texte, hasLength(6), reason: 'Je Bild ein Abschnitt des Intros');
    expect(_texte(raum, 'g3'), isEmpty);
    expect(raum.zustandFuer('g3')['dia'], 0);

    await zeigeImThema(t, (_) => gastSeiteLive(cleo));
    expect(find.byKey(const ValueKey('gast-diashow')), findsOneWidget);
    expect(find.byType(DiashowAnsicht), findsOneWidget);
    expect(find.byKey(const ValueKey('gast-dia-text-0')), findsOneWidget);
    expect(find.textContaining(texte[0].substring(0, 30)), findsOneWidget);
    expect(find.textContaining(texte[1].substring(0, 30)), findsNothing, reason: 'Nur der Text zum laufenden Bild');
    await t.ensureVisible(find.byKey(const ValueKey('gast-dia-naechstes')));
    await t.tap(find.byKey(const ValueKey('gast-dia-naechstes')));
    await t.pump();
    expect(cleo.befehle.last.$1, {'typ': 'dia', 'nr': 1});
    expect(cleo.befehle.last.$2, isNull);
    await t.pump(const Duration(milliseconds: 700));
    expect(find.byKey(const ValueKey('gast-dia-text-1')), findsOneWidget);
    expect(find.textContaining(texte[1].substring(0, 30)), findsOneWidget);
    expect(find.text(l.party_intro_bild('2', '6').toUpperCase()), findsOneWidget);

    for (final g in [dora, ben]) {
      await zeigeImThema(t, (_) => gastSeiteLive(g));
      expect(find.byType(DiashowAnsicht), findsOneWidget, reason: g.spielerId);
      expect(find.text(l.party_intro_bild('2', '6').toUpperCase()), findsOneWidget, reason: '${g.spielerId}: dasselbe Bild');
      for (final x in texte) {
        expect(find.textContaining(x.substring(0, 30)), findsNothing, reason: '${g.spielerId}: kein Erzähltext');
      }
      expect(find.byKey(const ValueKey('gast-dia-naechstes')), findsNothing, reason: '${g.spielerId} leitet nicht');
    }
    // Auch über die Nachricht schaltet nur, wer leitet.
    expect(await dora.befehl({'typ': 'dia', 'nr': 2}), 'not_host');
    expect(raum.zustandFuer('g1')['dia'], 1);
    await t.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Online: alle Gäste sehen die gemeinsame Uhr; Start, Pause und plus fünf hat nur, wer leitet', (t) async {
    final raum = _raum();
    spieleBisSitz(raum, 'gespraeche', detektiv: 'gastgeber', leiter: 'g2');
    var jetzt = 5000000;
    LiveGast gast(String id) => _gast(raum, id)..abendzeit = () => jetzt;
    final cleo = gast('g2'), ben = gast('g1'), dora = gast('g3');

    await zeigeImThema(t, (_) => gastSeiteLive(cleo));
    expect(find.byKey(const ValueKey('gast-rundenuhr')), findsOneWidget);
    expect(find.text('30:00'), findsOneWidget);
    await t.ensureVisible(find.byTooltip(l.online_uhr_start));
    await t.tap(find.byTooltip(l.online_uhr_start));
    await t.pump();
    expect(cleo.befehle.last.$2, isNull);
    expect(RundenUhr.ausJson(raum.zustandFuer('g3')['uhr'])!.start, 5000000, reason: 'Die Zeit setzt der Transport');

    jetzt += 61000;
    // Die Rollen: dieselbe Restzeit aus der Abendzeit des Gastgebers, keine Knöpfe.
    for (final g in [ben, dora]) {
      await zeigeImThema(t, (_) => gastSeiteLive(g));
      expect(find.byKey(const ValueKey('gast-rundenuhr')), findsOneWidget, reason: g.spielerId);
      expect(find.text('28:59'), findsOneWidget, reason: g.spielerId);
      expect(find.byTooltip(l.online_uhr_start), findsNothing, reason: g.spielerId);
      expect(find.byTooltip(l.online_uhr_pause), findsNothing, reason: g.spielerId);
      expect(find.text(l.party_runde_stellt('Cleo')), findsOneWidget, reason: g.spielerId);
    }
    expect(await dora.befehl({'typ': 'uhr', 'aktion': 'pause'}), 'not_host');
    expect(await ben.befehl({'typ': 'uhr', 'aktion': 'plus', 'minuten': 5}), 'not_host');

    await zeigeImThema(t, (_) => gastSeiteLive(cleo));
    await t.ensureVisible(find.byTooltip(l.online_uhr_pause));
    await t.tap(find.byTooltip(l.online_uhr_pause));
    await t.pump();
    jetzt += 600000;
    await t.ensureVisible(find.byTooltip(l.party_runde_plus));
    await t.tap(find.byTooltip(l.party_runde_plus));
    await t.pump();
    expect(find.text('33:59'), findsOneWidget, reason: 'Angehalten bleibt die Restzeit, plus fünf Minuten');
    expect(find.byTooltip(l.party_runde_weiterlaufen), findsOneWidget);
    expect(find.byKey(const ValueKey('rundenuhr-angehalten')), findsOneWidget);
    await t.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Online: Der Gast-Detektiv sieht die Uhr, die der Erzähler am Gastgebergerät stellt', (t) async {
    final raum = _raum(detektiv: 'g1', erzaehler: 'gastgeber');
    spieleBisSitz(raum, 'gespraeche', detektiv: 'g1', leiter: 'gastgeber');
    raum.nachricht('gastgeber', {'typ': 'uhr', 'aktion': 'start', 'zeit': 7000000});
    final ben = _gast(raum, 'g1')..abendzeit = () => 7000000 + 90000;
    await zeigeImThema(t, (_) => gastSeiteLive(ben));
    expect(find.byKey(const ValueKey('gast-rundenuhr')), findsOneWidget);
    expect(find.text('28:30'), findsOneWidget);
    expect(find.byTooltip(l.online_uhr_pause), findsNothing);
    expect(find.text(l.party_runde_stellt('Anna')), findsOneWidget);
    expect(await ben.befehl({'typ': 'uhr', 'aktion': 'pause'}), 'not_host', reason: 'Der Erzähler leitet, nicht der Detektiv');
    await t.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Online ohne Diashow: Die Einleitung bleibt wie bisher, der Vorleser liest alle Texte', (t) async {
    final raum = _raum(dias: 0);
    spieleBisSitz(raum, 'intro', detektiv: 'gastgeber', leiter: 'g2');
    expect(raum.zustandFuer('g2').containsKey('dia'), isFalse);
    final texte = _texte(raum, 'g2');
    await zeigeImThema(t, (_) => gastSeiteLive(_gast(raum, 'g2')));
    expect(find.byKey(const ValueKey('gast-diashow')), findsNothing);
    expect(find.byType(DiashowAnsicht), findsNothing);
    for (final x in texte) {
      expect(find.textContaining(x.substring(0, 30)), findsOneWidget);
    }
    await t.pumpWidget(const SizedBox.shrink());
  });
}
