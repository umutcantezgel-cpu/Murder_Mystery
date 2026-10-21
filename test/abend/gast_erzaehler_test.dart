// Langer Abend M3b: der Erzähler online. Ein Gast auf dem Erzähler-Sitz liest
// vor, sieht sein pfadfreies Erzählerpaket und führt weiter; die Rollen hören
// zu („… liest vor“). Sitzt der Gastgeber auf dem Erzähler-Sitz, zeigt sein
// Gerät das Pult mit Zuschauerkarte statt der Detektiv-Bildschirme. Fällt ein
// Gast-Erzähler aus, übernimmt der Gastgeber erst nach zwei Minuten.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte/abend/online/erzaehler_ablauf.dart';
import 'package:mordakte/abend/online/gastgeber_sitzung.dart';
import 'package:mordakte/l10n/gen/app_localizations_de.dart';
import 'package:mordakte/party/bildschirme/befragung.dart' show BefragungsListe;
import 'package:mordakte/party/bildschirme/intro.dart';
import 'package:mordakte_core/mordakte_core.dart';

import '../party_widgets/hilfe.dart' show akteDaten;
import 'online_hilfe.dart';

final l = LDe();

Map<String, Object?> _map(Object? wert) => (wert as Map).cast<String, Object?>();

/// Andere Geräte haben den Raum geändert: Der Gastgeber holt seine Ansicht neu
/// (der Strom liefert sie im nächsten Mikroschritt), dann zwei Bilder.
Future<void> _neu(WidgetTester tester, GastgeberSitzung s) async {
  s.dienst.verb.aktualisiere();
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

Future<void> _tippe(WidgetTester tester, Finder f) async {
  await tester.ensureVisible(f);
  await tester.pump();
  await tester.tap(f);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  final texte = akteDaten('schlosskeller').texte;

  testWidgets('Gast-Erzähler liest vor, hat sein Paket und führt weiter; die Rollen hören zu', (tester) async {
    final raum = sitzRaum(erzaehler: 'g3');
    spieleBisSitz(raum, 'intro', detektiv: 'gastgeber', leiter: 'g3');
    final dora = LiveGast(raum, spielerId: 'g3');
    final intro = texte.baustein('intro.start').substring(0, 30);
    await zeigeImThema(tester, (c) => gastSeiteLive(dora));
    expect(find.textContaining(intro), findsOneWidget, reason: 'Dora liest vor');
    expect(find.text(l.online_erzaehler_hinweis), findsOneWidget);
    await _tippe(tester, find.byKey(const ValueKey('gast-weiter')));
    expect(raum.zustandFuer('g3')['phase'], 'gespraeche');
    expect(dora.befehle.last.$1, {'typ': 'weiter'});
    expect(dora.befehle.last.$2, isNull);
    await tester.pump();
    // Das Erzählerpaket: alle Tisch-Stichpunkte der Runde, pfadfrei.
    final paket = _map(_map(raum.zustandFuer('g3')['privat'])['erzaehlerPaket']);
    final stichpunkt = ((paket['tisch'] as List).first as Map)['stichpunkte'] as List;
    expect(find.byKey(const ValueKey('erzaehlerpaket')), findsOneWidget);
    expect(find.text(stichpunkt.first as String), findsOneWidget);
    final weiter = tester.widget<FilledButton>(find.descendant(of: find.byKey(const ValueKey('gast-weiter')), matching: find.byType(FilledButton)));
    expect(weiter.onPressed, isNull, reason: 'Erst wenn die Befragungen durch sind');
    // Kein Dossierwissen beim Erzähler (das Paket kennt verbirgt und Tatwissen nicht).
    final dossier = texte.dossier('ahmet', 'ahmet', 4);
    for (final z in [...dossier.verbirgt, ...dossier.tatwissen]) {
      expect(find.textContaining(z.text), findsNothing, reason: 'Erzähler sieht nie ${z.text}');
    }
    // Ben (Rolle) hört zu.
    final ben = LiveGast(raum, spielerId: 'g1');
    await zeigeImThema(tester, (c) => gastSeiteLive(ben));
    expect(find.text(l.vorleser_liest('Dora')), findsOneWidget);
    expect(find.textContaining(texte.baustein('runde.1.start').substring(0, 30)), findsNothing);
    expect(find.byKey(const ValueKey('gast-weiter')), findsNothing);
    expect(find.byKey(const ValueKey('erzaehlerpaket')), findsNothing);
    // Die Gesprächsrunde endet; Dora führt weiter.
    befragungenImRaum(raum);
    dora.geaendert();
    await zeigeImThema(tester, (c) => gastSeiteLive(dora));
    await _tippe(tester, find.byKey(const ValueKey('gast-weiter')));
    expect(raum.zustandFuer('g3')['phase'], 'entscheidungen');
  });

  testWidgets('Gastgeber als Erzähler: Pult mit Paket und Zuschauerkarte, keine Fragen, Weiter vom Pult', (tester) async {
    final raum = sitzRaum(detektiv: 'g1', erzaehler: 'gastgeber');
    spieleBisSitz(raum, 'gespraeche', detektiv: 'g1', leiter: 'gastgeber');
    final s = GastgeberSitzung(SitzDienst(raum));
    await zeigeImThema(tester, (c) => Scaffold(body: ListenableBuilder(listenable: s, builder: (_, _) => erzaehlerErsatz(s) ?? const SizedBox())), ruhig: true);
    expect(find.byType(ErzaehlerPultOnline), findsOneWidget);
    expect(find.text(s.text('runde.1.start')), findsOneWidget, reason: 'Der Erzähler liest');
    expect(find.byType(BefragungsListe), findsNothing, reason: 'Er befragt niemanden');
    expect(find.byKey(const ValueKey('erzaehlerpaket')), findsOneWidget);
    befragungenImRaum(raum, detektiv: 'g1');
    await _neu(tester, s);
    await _tippe(tester, find.text(s.ui('ui.allgemein.weiter')));
    expect(s.phase, PartyPhase.entscheidungen);
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byKey(const ValueKey('zuschauerkarte')), findsOneWidget);
    expect(tester.takeException(), isNull);
    // In den Entscheidungen leitet der Erzähler-Gastgeber nur das Ende der Runde.
    spieleBisSitz(raum, 'anklage', detektiv: 'g1', leiter: 'gastgeber');
    await _neu(tester, s);
    expect(find.text(l.erzaehler_anklage_wartet), findsOneWidget);
    raum.nachricht('g1', {'typ': 'anklage', 'person': 'ahmet'});
    await _neu(tester, s);
    expect(find.text(l.erzaehler_angeklagt(s.figurName('ahmet'))), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    s.dispose();
  });

  testWidgets('Fällt der Gast-Erzähler aus, liest der Gastgeber erst nach zwei Minuten', (tester) async {
    final raum = sitzRaum(erzaehler: 'g3');
    spieleBisSitz(raum, 'intro', detektiv: 'gastgeber', leiter: 'g3');
    final s = GastgeberSitzung(SitzDienst(raum));
    final intro = texte.baustein('intro.start');
    await zeigeImThema(tester, (c) => Scaffold(body: ListenableBuilder(listenable: s, builder: (_, _) => IntroBildschirm(sitzung: s))));
    expect(find.text(l.vorleser_liest('Dora')), findsOneWidget);
    expect(find.text(intro), findsNothing);
    raum.verbunden('g3', false);
    await _neu(tester, s);
    expect(find.text(l.vorleser_frist('Dora')), findsOneWidget);
    expect(find.text(intro), findsNothing, reason: 'Noch liest niemand');
    expect(s.kannWeiter, isFalse);
    await tester.pump(const Duration(minutes: 2, seconds: 1));
    expect(find.text(intro), findsOneWidget, reason: 'Jetzt liest der Gastgeber');
    expect(s.kannWeiter, isTrue);
    raum.verbunden('g3', true);
    await _neu(tester, s);
    expect(find.text(l.vorleser_liest('Dora')), findsOneWidget, reason: 'Dora ist zurück');
    await tester.pumpWidget(const SizedBox.shrink());
    s.dispose();
  });

  testWidgets('Erzähler-Seiten ohne Überlauf bei 320 px und doppelter Schrift', (tester) async {
    final raum = sitzRaum(erzaehler: 'g3');
    final dora = LiveGast(raum, spielerId: 'g3');
    for (final phase in ['rollen', 'intro', 'gespraeche', 'entscheidungen']) {
      spieleBisSitz(raum, phase, detektiv: 'gastgeber', leiter: 'g3');
      await zeigeImThema(tester, (c) => gastSeiteLive(dora), groesse: const Size(320, 640), schrift: 2);
      expect(tester.takeException(), isNull, reason: phase);
    }
    final zwei = sitzRaum(detektiv: 'g1', erzaehler: 'gastgeber');
    spieleBisSitz(zwei, 'gespraeche', detektiv: 'g1', leiter: 'gastgeber');
    final s = GastgeberSitzung(SitzDienst(zwei));
    await zeigeImThema(tester, (c) => Scaffold(body: erzaehlerErsatz(s)!), groesse: const Size(320, 640), schrift: 2, ruhig: true);
    expect(tester.takeException(), isNull, reason: 'Pult');
    await tester.pumpWidget(const SizedBox.shrink());
    s.dispose();
  });
}
