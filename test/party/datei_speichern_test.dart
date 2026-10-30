// „Herunterladen“ in der Android-App (A-059): Der Kanal mordakte/datei bekommt Name, Typ,
// Bytes und den Satz nach dem Speichern aus der ARB (das Kotlin kennt keinen Oberflächentext).
// Gespeichert und abgebrochen zählen als angeboten, ein Fehler des Kanals nicht. Auf Android
// wartet die fertige Datei auf „Herunterladen“ (Speichern-Dialog) oder „Teilen“; ein Tipp ohne
// Wahl (Krimidinner) teilt weiter. iOS und der Rechner teilen wie bisher sofort.
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show MethodCall, MethodChannel, PlatformException;
import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte/l10n/gen/app_localizations_de.dart';
import 'package:mordakte/party/datei_knopf.dart';
import 'package:mordakte/party/datei_speichern.dart';
import 'package:mordakte/party/datei_teilen.dart';
import 'package:mordakte/party/druck_speichern.dart';
import 'package:mordakte/party/druck_speichern_stub.dart' as app;
import 'package:mordakte/party/party_stil.dart' show PartyKnopf;
import 'package:share_plus/share_plus.dart';

final _de = LDe();
const _kanal = MethodChannel('mordakte/datei');
final _bytes = Uint8List.fromList([0x25, 0x50, 0x44, 0x46, 0x2d, 0, 128, 255]);

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
List<ShareParams> _teilen() {
  final geteilt = <ShareParams>[];
  final vorher = dateiTeilenUeber;
  dateiTeilenUeber = (p) async {
    geteilt.add(p);
    return const ShareResult('ok', ShareResultStatus.success);
  };
  addTearDown(() => dateiTeilenUeber = vorher);
  return geteilt;
}

/// Spielt die App auf Android nach ([android]) oder auf iOS und am Rechner: Tests laufen nie auf Android.
void _aufAndroid([bool android = true]) {
  final vorher = app.aufAndroid;
  app.aufAndroid = android;
  addTearDown(() => app.aufAndroid = vorher);
}

Map<Object?, Object?> _argumente(MethodCall c) => c.arguments as Map<Object?, Object?>;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('dateiSpeichern', () {
    test('gibt Name, Typ, Bytes und den Satz nach dem Speichern an „speichern“ auf mordakte/datei', () async {
      final aufrufe = _kotlin((_) => true);
      expect(await dateiSpeichern('erzaehlerakte.pdf', _bytes, gespeichert: 'Gespeichert: erzaehlerakte.pdf'), isTrue);
      expect(await dateiSpeichern('steckbriefe.html', _bytes, typ: 'text/html', gespeichert: 'Gespeichert: steckbriefe.html'), isTrue);
      expect(aufrufe.map((c) => c.method), ['speichern', 'speichern']);
      final pdf = _argumente(aufrufe.first);
      // Genau diese Schlüssel liest MainActivity.kt.
      expect(pdf.keys.toSet(), {'name', 'typ', 'bytes', 'gespeichert'});
      expect(pdf['name'], 'erzaehlerakte.pdf');
      expect(pdf['typ'], 'application/pdf');
      expect(pdf['bytes'], isA<Uint8List>());
      expect(pdf['bytes'], _bytes);
      expect(pdf['gespeichert'], 'Gespeichert: erzaehlerakte.pdf');
      expect(_argumente(aufrufe.last)['typ'], 'text/html');
    });

    test('gespeichert und abgebrochen zählen als angeboten', () async {
      for (final antwort in [true, false]) {
        _kotlin((_) => antwort);
        expect(await dateiSpeichern('a.pdf', _bytes, gespeichert: 'Gespeichert: a.pdf'), isTrue, reason: 'Kotlin meldet $antwort');
      }
    });

    test('Schreibfehler, offener Dialog, keine Dokumenten-App oder keine Kotlin-Seite ergeben false', () async {
      for (final code in ['schreiben', 'belegt', 'kein_dialog']) {
        _kotlin((_) => throw PlatformException(code: code));
        expect(await dateiSpeichern('a.pdf', _bytes, gespeichert: 'Gespeichert: a.pdf'), isFalse, reason: code);
      }
      // Ohne Gegenstelle (MissingPluginException).
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(_kanal, null);
      expect(await dateiSpeichern('a.pdf', _bytes, gespeichert: 'Gespeichert: a.pdf'), isFalse);
    });
  });

  group('App auf Android', () {
    test('„Herunterladen“ öffnet den Speichern-Dialog mit dem Satz aus der ARB, „Teilen“ das Teilen des Systems', () async {
      _aufAndroid();
      final kanal = _kotlin((_) => true);
      final geteilt = _teilen();
      expect(zweiterTipp, isTrue);
      expect(dateiWege('druckspiel-alles.pdf'), [DateiWeg.herunterladen, DateiWeg.teilen]);

      expect(await dateiAnbieten('druckspiel-alles.pdf', _bytes, weg: DateiWeg.herunterladen), isTrue);
      expect(geteilt, isEmpty);
      final a = _argumente(kanal.single);
      expect(a['name'], 'druckspiel-alles.pdf');
      expect(a['typ'], 'application/pdf');
      expect(a['bytes'], _bytes);
      expect(a['gespeichert'], _de.druck_datei_gespeichert('druckspiel-alles.pdf'));

      expect(await dateiAnbieten('druckspiel-alles.pdf', _bytes, weg: DateiWeg.teilen), isTrue);
      expect(geteilt.single.fileNameOverrides, ['druckspiel-alles.pdf']);
      expect(kanal, hasLength(1));
    });

    test('ohne Wahl teilt die App auch auf Android (das Krimidinner baut im Tipp und bietet sofort an)', () async {
      _aufAndroid();
      final kanal = _kotlin((_) => true);
      final geteilt = _teilen();
      expect(const DateiGeraet().standardWeg, DateiWeg.teilen);
      expect(await dateiAnbieten('gewoelbe-steckbriefe-5.html', _bytes, typ: 'text/html'), isTrue);
      expect(geteilt.single.fileNameOverrides, ['gewoelbe-steckbriefe-5.html']);
      expect(geteilt.single.files!.single.mimeType, 'text/html');
      expect(kanal, isEmpty, reason: 'Der Speichern-Dialog öffnet sich nie ungefragt');
    });

    test('iOS und Rechner: kein Download, kein zweiter Tipp, die Datei geht an das Teilen', () async {
      _aufAndroid(false);
      final kanal = _kotlin((_) => true);
      final geteilt = _teilen();
      expect(zweiterTipp, isFalse);
      expect(dateiWege('a.pdf'), [DateiWeg.teilen]);
      expect(const DateiGeraet().standardWeg, DateiWeg.teilen);
      expect(await dateiAnbieten('a.pdf', _bytes), isTrue);
      // Auch wer ausdrücklich herunterladen will, bekommt hier das Teilen-Fenster.
      expect(await dateiAnbieten('b.pdf', _bytes, weg: DateiWeg.herunterladen), isTrue);
      expect(geteilt.map((p) => p.fileNameOverrides!.single), ['a.pdf', 'b.pdf']);
      expect(kanal, isEmpty);
    });
  });

  group('DateiKnopf auf Android', () {
    const text = 'Alles in einer Datei';
    final laden = find.text(_de.druck_datei_laden(text));
    final teilen = find.text(_de.druck_datei_teilen(text));

    Future<void> zeige(WidgetTester t) async {
      await t.pumpWidget(MaterialApp(
        theme: ThemeData.dark(),
        home: Scaffold(
          body: Center(child: DateiKnopf(text: text, bauen: () async => (name: 'druckspiel-alles.pdf', bytes: _bytes))),
        ),
      ));
      await t.tap(find.text(text));
      await t.pump();
      await t.pump(const Duration(milliseconds: 20));
      await t.pump();
    }

    testWidgets('der erste Tipp baut, dann stehen „Herunterladen“ und „Teilen“; jeder Knopf nimmt seinen Weg', (t) async {
      _aufAndroid();
      final kanal = _kotlin((_) => true);
      final geteilt = _teilen();
      await zeige(t);
      expect(laden, findsOneWidget);
      expect(teilen, findsOneWidget);
      expect(t.widgetList<PartyKnopf>(find.byType(PartyKnopf)).map((k) => k.text), [_de.druck_datei_laden(text), _de.druck_datei_teilen(text)],
          reason: 'Herunterladen steht vorn');
      expect(kanal, isEmpty, reason: 'Der erste Tipp baut nur');
      expect(geteilt, isEmpty);

      await t.tap(laden);
      await t.pump();
      expect(_argumente(kanal.single)['name'], 'druckspiel-alles.pdf');
      expect(_argumente(kanal.single)['gespeichert'], _de.druck_datei_gespeichert('druckspiel-alles.pdf'));
      expect(geteilt, isEmpty);

      await t.tap(teilen);
      await t.pump();
      expect(geteilt.single.fileNameOverrides, ['druckspiel-alles.pdf']);
      expect(kanal, hasLength(1));
      expect(find.text(_de.druck_datei_fehler), findsNothing);
    });

    testWidgets('scheitert der Speichern-Dialog, steht der Hinweis da und „Teilen“ bleibt', (t) async {
      _aufAndroid();
      _kotlin((_) => throw PlatformException(code: 'kein_dialog'));
      final geteilt = _teilen();
      await zeige(t);
      await t.tap(laden);
      await t.pump();
      expect(find.text(_de.druck_datei_fehler), findsOneWidget);
      expect(teilen, findsOneWidget);
      await t.tap(teilen);
      await t.pump();
      expect(geteilt.single.fileNameOverrides, ['druckspiel-alles.pdf']);
      expect(find.text(_de.druck_datei_fehler), findsNothing);
    });

    testWidgets('auf iOS und am Rechner teilt schon der erste Tipp', (t) async {
      _aufAndroid(false);
      final kanal = _kotlin((_) => true);
      final geteilt = _teilen();
      await zeige(t);
      expect(geteilt.single.fileNameOverrides, ['druckspiel-alles.pdf']);
      expect(laden, findsNothing);
      expect(teilen, findsNothing);
      expect(kanal, isEmpty);
    });
  });
}
