// M5, K3, A-059: Steckbriefe & Übersicht einer Akte (/akte/:id/steckbriefe). Ein Tipp von der
// Akte-Seite, keine Einrichtung, kein Fall-Code. Personenzahl offen oder fest, Übersicht und alle
// Steckbriefe als Datei, Gästeliste Name → Figur im MetaStore, je Gast „Steckbrief senden“;
// fällt eine Figur bei kleinerer Zahl weg, steht das am Gast. Jede Datei geht an das Teilen; in der
// Android-App wartet sie auf „Herunterladen“ (Speichern-Dialog) oder „Teilen“.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte/app/app.dart';
import 'package:mordakte/app/app_state.dart';
import 'package:mordakte/app/router.dart';
import 'package:mordakte/detektei/akten.dart';
import 'package:mordakte/l10n/gen/app_localizations_de.dart';
import 'package:mordakte/meta/meta_store.dart';
import 'package:mordakte/party/daten.dart';
import 'package:mordakte/party/datei_teilen.dart';
import 'package:mordakte/party/druck_speichern_stub.dart' as app;
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _de = LDe();
const _kanal = MethodChannel('mordakte/datei');

/// Fängt den Kanal zur Android-App ab; [antwort] gibt, was das Kotlin melden würde, oder wirft.
List<MethodCall> _kotlin(Object? Function(MethodCall) antwort) {
  final aufrufe = <MethodCall>[];
  final bote = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  bote.setMockMethodCallHandler(_kanal, (c) async {
    aufrufe.add(c);
    return antwort(c);
  });
  addTearDown(() => bote.setMockMethodCallHandler(_kanal, null));
  return aufrufe;
}

/// Fängt das Teilen des Systems ab.
List<ShareParams> _zeuge() {
  final geteilt = <ShareParams>[];
  final vorher = dateiTeilenUeber;
  dateiTeilenUeber = (p) async {
    geteilt.add(p);
    return const ShareResult('ok', ShareResultStatus.success);
  };
  addTearDown(() => dateiTeilenUeber = vorher);
  return geteilt;
}

/// Echte Zeit für Bündel und PDF, Testuhr für die Bilder.
Future<void> _warte(WidgetTester tester, bool Function() fertig) async {
  for (var i = 0; i < 400 && !fertig(); i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 25)));
    await tester.pump(const Duration(milliseconds: 30));
  }
  await tester.pump(const Duration(milliseconds: 300));
}

Future<AppState> _oeffnen(WidgetTester tester, {String ort = '/akte/schlosskeller/steckbriefe', double breite = 390, double schrift = 1, MetaStore? meta}) async {
  tester.view.physicalSize = Size(breite, 844);
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = schrift;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  final state = AppState(meta: meta ?? (MetaStore.memory()..name = 'Test'), scenarios: const {});
  await tester.runAsync(() async {
    // Was die Seiten lesen, lädt hier in echter Zeit (siehe assistent_test).
    await AktenKatalog.laden();
    await AkteAuszug.laden('schlosskeller');
    await AkteAuszug.laden('blue_palm');
    await PartyDaten.laden(rootBundle, fall: 'schlosskeller');
    await rootBundle.loadString('content/party/schlosskeller/steckbriefe.json');
    await tester.pumpWidget(MordakteApp(app: state, initialLocation: ort));
  });
  await _warte(tester, () => find.text(_de.steckbrief_personen).evaluate().isNotEmpty || find.text(_de.detektei_akte_lage).evaluate().isNotEmpty);
  return state;
}

/// Tippt auf [f] und wartet, bis [fertig] gilt.
Future<void> _tippe(WidgetTester tester, Finder f, [bool Function()? fertig]) async {
  await tester.ensureVisible(f);
  await tester.pump();
  await tester.tap(f);
  await tester.pump();
  await _warte(tester, fertig ?? () => true);
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('Akte-Seite: Steckbriefe & Übersicht mit einem Tipp, nur bei Akten mit Steckbriefen', (tester) async {
    final state = await _oeffnen(tester, ort: Routes.akteVon('schlosskeller'));
    expect(find.text(_de.detektei_akte_steckbriefe), findsOneWidget);
    await _tippe(tester, find.text(_de.detektei_akte_steckbriefe), () => find.text(_de.steckbrief_personen).evaluate().isNotEmpty);
    // Der Übergang blendet die Akte-Seite aus; Knopf und Titel heißen gleich.
    await tester.pump(const Duration(seconds: 1));
    expect(find.text(_de.detektei_akte_spielen), findsNothing);
    expect(find.text(_de.steckbrief_titel), findsOneWidget);
    expect(find.text(_de.steckbrief_personen), findsOneWidget);
    // Keine Einrichtung: kein Fall-Code-Feld, keine Personennamen der Einrichtung.
    expect(find.byKey(const ValueKey('code')), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
    state.dispose();
  });

  testWidgets('Blue Palm hat keine Steckbriefe: kein Knopf auf der Akte', (tester) async {
    final state = await _oeffnen(tester, ort: Routes.akteVon('blue_palm'));
    expect(find.text(_de.detektei_akte_lage), findsOneWidget);
    expect(find.text(_de.detektei_akte_steckbriefe), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
    state.dispose();
  });

  testWidgets('Übersicht ohne und mit Personenzahl, alle Steckbriefe: jede Datei geht ans Teilen', (tester) async {
    final geteilt = _zeuge();
    final state = await _oeffnen(tester);
    await _tippe(tester, find.text('Charakterübersicht'), () => geteilt.isNotEmpty);
    expect(geteilt.single.fileNameOverrides, ['charakteruebersicht.pdf']);
    expect(geteilt.single.files!.single.mimeType, 'application/pdf');

    await _tippe(tester, find.text(_de.steckbrief_personen_fest));
    expect(state.meta.gaesteliste('schlosskeller').personen, 7);
    expect(find.text(_de.steckbrief_personen_wert('7')), findsOneWidget);
    await _tippe(tester, find.byTooltip('Eine Person weniger'));
    expect(state.meta.gaesteliste('schlosskeller').personen, 6);
    await _tippe(tester, find.text('Charakterübersicht'), () => geteilt.length > 1);
    expect(geteilt.last.fileNameOverrides, ['charakteruebersicht-6-personen.pdf']);
    await _tippe(tester, find.text('Übersicht und alle Steckbriefe'), () => geteilt.length > 2);
    expect(geteilt.last.fileNameOverrides, ['steckbriefe-6-personen.pdf']);
    await tester.pumpWidget(const SizedBox.shrink());
    state.dispose();
  });

  testWidgets('Gästeliste: Name und Figur landen im MetaStore, „Steckbrief senden“ teilt den Steckbrief, eine weggefallene Figur wird markiert', (tester) async {
    final geteilt = _zeuge();
    final state = await _oeffnen(tester);
    await _tippe(tester, find.text(_de.steckbrief_gast_neu));
    await tester.enterText(find.byType(TextField).first, 'Ayla');
    await tester.pump();
    await _tippe(tester, find.text(_de.steckbrief_gast_ohne).first);
    await _tippe(tester, find.text('Fatma').last);
    expect(state.meta.gaesteliste('schlosskeller').namenJeFigur, {'fatma': 'Ayla'});
    await _tippe(tester, find.text(_de.steckbrief_senden), () => geteilt.isNotEmpty);
    expect(geteilt.single.fileNameOverrides, ['steckbrief-fatma.pdf']);

    // Ein zweiter Gast wählt Aylin; bei vier Personen ist sie nicht dabei, Fatma schon.
    await _tippe(tester, find.text(_de.steckbrief_gast_neu));
    await tester.enterText(find.byType(TextField).last, 'Bo');
    await tester.pump();
    await _tippe(tester, find.text(_de.steckbrief_gast_ohne).first);
    await _tippe(tester, find.text('Aylin').last);
    await _tippe(tester, find.text(_de.steckbrief_personen_fest));
    for (var i = 0; i < 3; i++) {
      await _tippe(tester, find.byTooltip('Eine Person weniger'));
    }
    expect(state.meta.gaesteliste('schlosskeller').personen, 4);
    expect(find.text(_de.steckbrief_gast_nicht_dabei('4')), findsOneWidget);
    expect(state.meta.gaesteliste('schlosskeller').namenJeFigur, {'fatma': 'Ayla', 'aylin': 'Bo'});

    // Entfernen löscht den Gast aus der Liste.
    await _tippe(tester, find.byTooltip(_de.steckbrief_gast_entfernen).last);
    expect(state.meta.gaesteliste('schlosskeller').namenJeFigur, {'fatma': 'Ayla'});
    expect(find.text(_de.steckbrief_gast_nicht_dabei('4')), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
    state.dispose();
  });

  // Die Android-App (Tests laufen nie auf Android): Nach dem ersten Tipp stehen „Herunterladen“
  // (Speichern-Dialog, vorn) und „Teilen“; sie nennen die Datei, auch beim Steckbrief eines Gastes.
  for (final (breite, schrift) in [(390.0, 1.0), (320.0, 2.0)]) {
    testWidgets('Android: $breite px, Schrift $schrift: Übersicht und Steckbrief eines Gastes mit zwei Wegen; Abbruch ist kein Fehler', (tester) async {
      final vorher = app.aufAndroid;
      app.aufAndroid = true;
      addTearDown(() => app.aufAndroid = vorher);
      final kanal = _kotlin((_) => true);
      final geteilt = _zeuge();
      final meta = MetaStore.memory()
        ..name = 'Test'
        ..setzeGaesteliste('schlosskeller', const GaesteListe(personen: 5, gaeste: [Gast('Ayla', 'fatma')]));
      final state = await _oeffnen(tester, breite: breite, schrift: schrift, meta: meta);

      // Übersicht: Der erste Tipp baut nur, dann zwei Wege, Herunterladen vorn.
      final uebersichtLaden = find.bySemanticsLabel(_de.druck_datei_laden('Charakterübersicht'));
      final uebersichtTeilen = find.bySemanticsLabel(_de.druck_datei_teilen('Charakterübersicht'));
      await _tippe(tester, find.text('Charakterübersicht'), () => uebersichtLaden.evaluate().isNotEmpty);
      expect(uebersichtLaden, findsOneWidget);
      expect(uebersichtTeilen, findsOneWidget);
      expect(tester.getRect(uebersichtLaden).top, lessThanOrEqualTo(tester.getRect(uebersichtTeilen).top));
      expect(kanal, isEmpty, reason: 'Der erste Tipp baut nur');
      expect(geteilt, isEmpty);

      // Steckbrief des Gastes: Die Wege nennen ihn („Steckbrief Fatma“), nicht „Steckbrief senden“.
      final datei = _de.steckbrief_von('Fatma');
      final steckbriefLaden = find.bySemanticsLabel(_de.druck_datei_laden(datei));
      await _tippe(tester, find.text(_de.steckbrief_senden), () => steckbriefLaden.evaluate().isNotEmpty);
      expect(steckbriefLaden, findsOneWidget);
      expect(find.bySemanticsLabel(_de.druck_datei_teilen(datei)), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp('Steckbrief senden')), findsNothing);
      await _tippe(tester, steckbriefLaden);
      final a = kanal.single.arguments as Map<Object?, Object?>;
      expect(a['name'], 'steckbrief-fatma.pdf');
      expect(a['gespeichert'], _de.druck_datei_gespeichert('steckbrief-fatma.pdf'));
      expect(geteilt, isEmpty);
      await _tippe(tester, find.bySemanticsLabel(_de.druck_datei_teilen(datei)));
      expect(geteilt.single.fileNameOverrides, ['steckbrief-fatma.pdf']);
      expect(find.text(_de.druck_datei_fehler), findsNothing);

      // Abbruch im Speichern-Dialog: kein Fehler. Scheitert das Schreiben: der Satz in Handschrift.
      _kotlin((_) => false);
      await _tippe(tester, uebersichtLaden);
      expect(find.text(_de.druck_datei_fehler), findsNothing, reason: 'Abbruch ist kein Fehler');
      _kotlin((_) => throw PlatformException(code: 'schreiben'));
      await _tippe(tester, uebersichtLaden);
      expect(find.text(_de.druck_datei_fehler), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      state.dispose();
    });
  }

  for (final breite in [320.0, 390.0]) {
    testWidgets('Steckbrief-Seite: $breite px, Schrift 2.0, mit Gästen ohne Überlauf', (tester) async {
      final meta = MetaStore.memory()
        ..name = 'Test'
        ..setzeGaesteliste('schlosskeller', const GaesteListe(personen: 5, gaeste: [Gast('Ayla', 'fatma'), Gast('Bo', 'tugba'), Gast('Cem')]));
      final state = await _oeffnen(tester, breite: breite, schrift: 2, meta: meta);
      expect(find.text(_de.steckbrief_gaeste), findsOneWidget);
      expect(find.text(_de.steckbrief_gast_nicht_dabei('5')), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      state.dispose();
    });
  }
}
