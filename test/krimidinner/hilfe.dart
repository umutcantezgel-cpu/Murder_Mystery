// Testhilfe für den Begleiter „Spuk im Gewölbe“: echter Kanon über dart:io,
// Rahmen für Gewölbe und Hub, Textsammler und die Spoiler-Regeln.
// Tests laufen im Repo-Wurzelordner und nutzen nur pump(Duration), nie
// pumpAndSettle: Schimmer und Regen im Hub laufen endlos.
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:krimidinner_kanon/krimidinner_kanon.dart';
import 'package:mordakte/app/app.dart';
import 'package:mordakte/app/app_state.dart';
import 'package:mordakte/app/router.dart';
import 'package:mordakte/krimidinner/gewoelbe_seite.dart';
import 'package:mordakte/meta/meta_store.dart';
import 'package:mordakte_core/mordakte_core.dart' show ScenarioDef, sampleScenarioJson;
import 'package:shared_preferences/shared_preferences.dart';

const kanonPfad = 'krimidinner/spuk-im-gewoelbe/10_kanon';

KrimiKanon? _kanon;

/// Der echte Kanon aus der Repo-Wurzel (nur `K*.md`).
KrimiKanon echterKanon() => _kanon ??= KrimiKanon.ausText({
      for (final f in Directory(kanonPfad).listSync().whereType<File>()) f.uri.pathSegments.last: f.readAsStringSync(),
    });

Gewoelbe? _gewoelbe;

/// Zugriffsschicht auf den echten Kanon (für Erwartungswerte in Tests).
Gewoelbe gewoelbe() => _gewoelbe ??= Gewoelbe(echterKanon());

/// Wert eines Kanonfelds (Erwartungswerte).
String feld(String id, String name) => echterKanon().datensaetze[id]!.feld(name)!;

/// Der Begleiter in einer MaterialApp, der Kanon kommt synchron.
Widget gewoelbeApp({GewoelbeTeil? teil, int? n}) {
  final k = echterKanon();
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData.dark(useMaterial3: true),
    home: GewoelbeSeite(laden: () => SynchronousFuture(k), startTeil: teil, startRollen: n),
  );
}

/// Die ganze App, Start im alten Hub (`/hub`, nur über `?screen=hub` erreichbar).
Widget hubApp() {
  SharedPreferences.setMockInitialValues({});
  final meta = MetaStore.memory()..name = 'Test';
  final sample = ScenarioDef.fromJson(jsonDecode(sampleScenarioJson) as Map<String, dynamic>);
  return MordakteApp(app: AppState(meta: meta, scenarios: {sample.id: sample}), initialLocation: Routes.klassik);
}

bool _schriften = false;

/// Lädt die echten Schriften der App (Inter, SpecialElite), damit Textbreiten
/// wie auf dem Gerät gemessen werden und nicht mit der Testschrift.
Future<void> schriftenLaden() async {
  if (_schriften) return;
  _schriften = true;
  Future<ByteData> datei(String name) async =>
      ByteData.sublistView(Uint8List.fromList(File('assets/fonts/$name').readAsBytesSync()));
  final inter = FontLoader('Inter')
    ..addFont(datei('Inter-Regular.ttf'))
    ..addFont(datei('Inter-SemiBold.ttf'))
    ..addFont(datei('Inter-Bold.ttf'));
  final elite = FontLoader('SpecialElite')..addFont(datei('SpecialElite-Regular.ttf'));
  await inter.load();
  await elite.load();
}

/// Bildschirmgröße in logischen Pixeln setzen (wird nach dem Test zurückgesetzt).
void groesse(WidgetTester tester, Size s) {
  tester.view.physicalSize = s;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

/// Ein paar Bilder weiterlaufen lassen.
Future<void> bilder(WidgetTester tester, [int n = 3]) async {
  for (var i = 0; i < n; i++) {
    await tester.pump(const Duration(milliseconds: 120));
  }
}

/// Alle sichtbaren Texte im Baum (Text und RichText).
List<String> alleTexte(WidgetTester tester) => [
      for (final w in tester.widgetList<Text>(find.byType(Text))) w.data ?? w.textSpan?.toPlainText() ?? '',
      for (final w in tester.widgetList<RichText>(find.byType(RichText))) w.text.toPlainText(),
    ];

/// Text normalisiert (Leerraum zusammengezogen).
String normal(String s) => s.replaceAll(RegExp(r'\s+'), ' ').trim();

/// Steht [teil] (normalisiert) irgendwo in den Texten des Baums?
bool sichtbar(WidgetTester tester, String teil) {
  final t = normal(teil);
  return alleTexte(tester).any((x) => normal(x).contains(t));
}

// Spoiler-Regeln (gleich wie packages/krimidinner_kanon/test/spoiler_test.dart) ----

/// Wörter und Kennungen, die nie sichtbar sein dürfen.
final verboteneMuster = <String, RegExp>{
  'Täter': RegExp('Täter'),
  'Kernrolle': RegExp('Kernrolle'),
  'Hauptverdächtig': RegExp('Hauptverdächtig'),
  'H-Kennung': RegExp(r'\bH-\d'),
  'BS-Kennung': RegExp(r'\bBS-\d'),
  'G/E/D-Kennung': RegExp(r'\b[GED]\d-\d'),
  'Rollenkennung': RegExp(r'\bR\d\d\b'),
  'Ansage': RegExp(r'\bA-E\d'),
  'besetzt': RegExp(r'\bbesetzt\b'),
  '[NUR': RegExp(r'\[NUR'),
};

/// Ausnahmeliste öffentlicher Ansichten (Kanonlücken): leer. R17-ÖFFENTLICH nennt
/// Zofia (R20); diesen Satz lässt der Filter F7 bei N=17–19 weg.
bool ausnahmeOeffentlich(int n, String vorname) => false;

Set<String>? _verboten;

/// Werte aus L- und G-Datensätzen (L ab 20, G ab 25 Zeichen), die in keinem O-Text stehen.
Set<String> verboteneWerte() {
  if (_verboten != null) return _verboten!;
  final k = echterKanon();
  final o = normal([
    for (final d in k.datensaetze.values)
      if (d.sicht == Sicht.o) ...d.felder.values,
  ].join(' ¦ '));
  final out = <String>{};
  for (final d in k.datensaetze.values) {
    if (d.sicht == Sicht.o) continue;
    final min = d.sicht == Sicht.l ? 20 : 25;
    for (final v in d.felder.values) {
      for (final w in {normal(v), normal(ohneKennungen(v))}) {
        if (w.length >= min && !o.contains(w)) out.add(w);
      }
    }
  }
  return _verboten = out;
}

/// Bedientexte, die die Regeln nicht meinen (der Satz zur Besetzungsreihenfolge
/// enthält das Wort „besetzt“, ist aber kein Besetzungsmarker aus dem Kanon).
const erlaubteBedientexte = {GewoelbeTexte.reihenfolge};

/// Befunde der Spoiler-Regeln für öffentliche Texte bei Besetzung [n].
List<String> spoilerBefunde(Iterable<String> texte, int n) {
  final text = normal(texte.where((t) => !erlaubteBedientexte.contains(t)).join(' ¦ '));
  final befunde = <String>[
    for (final v in verboteneWerte())
      if (text.contains(v)) 'WERT: ${v.length > 70 ? v.substring(0, 70) : v}',
    for (final e in verboteneMuster.entries)
      if (e.value.hasMatch(text)) 'MUSTER ${e.key}: ${e.value.firstMatch(text)![0]}',
  ];
  final k = echterKanon();
  for (var r = n + 1; r <= 20; r++) {
    final vorname = k.datensaetze['R${r.toString().padLeft(2, '0')}-STAMM']!.feld('Name')!.split(' ').first;
    if (RegExp('\\b${RegExp.escape(vorname)}\\b').hasMatch(text) && !ausnahmeOeffentlich(n, vorname)) {
      befunde.add('NAME $vorname bei N=$n');
    }
  }
  return befunde;
}
