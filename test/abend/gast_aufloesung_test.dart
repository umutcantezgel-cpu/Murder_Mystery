// Auflösung auf der Gastansicht: Bei fester Lösung (Gewölbe) steht keine Fall-Code-Zeile,
// bei der Schlosskeller-Akte mit Fall-Code bleibt sie. Die Ansicht kommt aus einem
// Gastgerät ohne Verbindung (nur die Felder, die die Ansicht liest).
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte/abend/online/gast_ansicht.dart';
import 'package:mordakte/abend/online/gast_dienst.dart';
import 'package:mordakte/l10n/gen/app_localizations.dart';
import 'package:mordakte/l10n/gen/app_localizations_de.dart';
import 'package:mordakte/party/daten.dart';
import 'package:mordakte_netz/mordakte_netz.dart' show VerbindungsStatus;

import '../party_widgets/hilfe.dart' show partyDaten;

/// Gastgerät mit fester Ansicht und Akte; alles andere ist nicht nötig.
class _Gast implements GastDienst {
  _Gast(this.ansicht, this.daten);

  @override
  final Map<String, Object?> ansicht;

  @override
  final PartyDaten? daten;

  @override
  VerbindungsStatus get status => VerbindungsStatus.verbunden;

  @override
  String get spielerId => 'gast';

  @override
  String get raumCode => 'ABCDEF';

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Die Auflösung eines Abends, wie der Gastgeber sie schickt.
Map<String, Object?> _auflosung() => {
      'phase': 'aufloesung',
      'runde': 3,
      'aufloesung': {'pfad': 'merle', 'punkte': 7, 'ende': 'ende_teilerfolg', 'fallCode': 'ABC-DEF'},
    };

/// Die Gastseite der Phase Auflösung, in der App-Lokalisierung (Deutsch).
Future<void> zeigeAuflosung(WidgetTester tester, GastDienst dienst) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(MaterialApp(
    theme: ThemeData.dark(),
    locale: const Locale('de'),
    supportedLocales: L.supportedLocales,
    localizationsDelegates: const [
      L.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: Scaffold(body: Builder(builder: (context) {
      final seite = baueGastSeite(GastKontext(context: context, dienst: dienst, befehl: (_) async {}, belohnung: null));
      return SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: seite.kinder));
    })),
  ));
  await tester.pump();
}

void main() {
  testWidgets('Gewölbe mit fester Lösung: Auflösung ohne Fall-Code-Zeile', (tester) async {
    final daten = await tester.runAsync(() => PartyDaten.laden(rootBundle, fall: 'gewoelbe'));
    expect(daten!.kanon.festeLoesung, isTrue, reason: 'Die Gewölbe-Akte hat eine feste Lösung');
    await zeigeAuflosung(tester, _Gast(_auflosung(), daten));
    final l = LDe();
    expect(find.text(l.online_aufloesung_titel.toUpperCase()), findsOneWidget, reason: 'Die Auflösung ist sichtbar');
    expect(find.text(l.online_aufloesung_code.toUpperCase()), findsNothing, reason: 'Ohne Fall-Code keine Zeile dafür');
    expect(find.text('ABC-DEF'), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Schlosskeller mit Fall-Code: Auflösung zeigt den Code weiterhin', (tester) async {
    expect(partyDaten.kanon.festeLoesung, isFalse);
    await zeigeAuflosung(tester, _Gast(_auflosung(), partyDaten));
    final l = LDe();
    expect(find.text(l.online_aufloesung_code.toUpperCase()), findsOneWidget);
    expect(find.text('ABC-DEF'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
