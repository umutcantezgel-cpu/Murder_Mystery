// Druckspiel des Partymodus als PDF-Satz (F5, Master 7.14) und Steckbriefe (K3, M5).
// Aufruf (im Paketordner):
//   dart run bin/party_druck.dart [--fall schlosskeller] [--code XXXXX | --pfad <ahmet|fatma|olli|can>] [--n 12] [--detektiv w] [--dauer 30] [--alles] [--aus ordner]
//   dart run bin/party_druck.dart --steckbriefe [--fall schlosskeller] [--n 12] [--detektiv w] [--aus ordner]
//   dart run bin/party_druck.dart --paket [--n 12] [--code XXXXX] [--dein-moment] [--aus ordner] [--portraets ordner]
//   dart run bin/party_druck.dart --erzaehlerakte [--fall schlosskeller] [--personen 8] [--dein-moment] [--aus ordner] [--portraets ordner]
// Ohne Code und Pfad entsteht ein Zufallsfall. Der Pfad ist nur für Testläufe
// des Erzählers gedacht; im Ordnernamen steht nur der Code. --alles setzt die acht
// Teile in eine Datei. --steckbriefe braucht keinen Fall-Code: Übersicht, alle
// Steckbriefe in einer Datei und je Figur ein Steckbrief (ohne --n alle Figuren).
// --paket setzt das festliche Druckpaket für den Abend am Bildschirm (nur Akten mit
// Steckbriefen): vier Ordner nach Empfängern und ZIP-Archive in build/paket/. Die
// Porträts kommen aus build/druck/portraets/ (flutter test tool/bild/druck_portraets_test.dart).
// Hat die Akte eine Erzählerakte (erzaehlerakte.json, A-063), liegt sie im Paket in
// Ordner 4. --erzaehlerakte setzt nur sie, ohne Fall-Code: Sie ist in allen Pfaden
// gleich und hängt nur an der Personenzahl (erst die besetzten Figuren). Je Figur steht
// ihr persönliches Ziel: Das Druckspiel läuft immer ohne „Dein Moment“ (Finale §3.1).
// Mit --dein-moment (nur Akten mit der Fähigkeit einfluss) stehen dort die zwei Sterne
// je Figur, für einen Abend am Bildschirm mit der Schicht.
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/party_druck.dart';
import 'package:mordakte_core/runden.dart' show EinflussRegeln, EinflussZielQuelle;

Future<void> main(List<String> args) async {
  String? wert(String name) {
    final i = args.indexOf('--$name');
    return i >= 0 && i + 1 < args.length ? args[i + 1] : null;
  }

  // Repo-Wurzel: der erste Ordner aufwärts mit content/party; am Dateisystemende ein Fehler.
  var d = Directory.current.absolute;
  while (!Directory('${d.path}/content/party').existsSync()) {
    if (d.parent.path == d.path) {
      stderr.writeln('Kein Mordakte-Repo gefunden: Rufe das Werkzeug im Repo auf (etwa in packages/mordakte_core).');
      exitCode = 2;
      return;
    }
    d = d.parent;
  }
  final wurzel = d.path;
  final fall = wert('fall') ?? 'schlosskeller';
  if (!Directory('$wurzel/content/party/$fall').existsSync()) {
    stderr.writeln('Akte $fall gibt es nicht (content/party/$fall).');
    exitCode = 2;
    return;
  }
  Map<String, Object?> lies(String ordner, String p) => jsonDecode(File('$wurzel/content/party/$ordner/$p').readAsStringSync()) as Map<String, Object?>;
  final kanon = Kanon.lade((p) => lies(fall, p));
  final sammlung = Textsammlung.lade((p) => lies(fall, p));
  // Wie die App: Andere Akten ergänzen Oberflächentexte aus der eingefrorenen Basis (A-061).
  if (fall != 'schlosskeller') sammlung.ergaenzeUi(Textsammlung.lade((p) => lies('basis-ui', p)));
  final texte = Texte(kanon, sammlung);
  final stil = DruckStil(
    regular: File('$wurzel/assets/fonts/Inter-Regular.ttf').readAsBytesSync(),
    fett: File('$wurzel/assets/fonts/Inter-Bold.ttf').readAsBytesSync(),
    schreibmaschine: File('$wurzel/assets/fonts/SpecialElite-Regular.ttf').readAsBytesSync(),
  );
  final n = wert('n');
  final detektiv = wert('detektiv') ?? 'w';

  void schreibe(Directory aus, List<DruckDatei> dateien) {
    aus.createSync(recursive: true);
    for (final f in dateien) {
      File('${aus.path}/${f.name}').writeAsBytesSync(f.bytes);
      stdout.writeln('${f.name.padRight(40)} ${(f.bytes.length / 1024).toStringAsFixed(0).padLeft(6)} KB');
    }
  }

  // Sterne von „Dein Moment“ in der Erzählerakte nur auf Wunsch; das Druckspiel bleibt ohne Schicht.
  final deinMoment = args.contains('--dein-moment');
  if (deinMoment && !faehigkeiten(wurzel, fall).contains('einfluss')) {
    stderr.writeln('Akte $fall kennt „Dein Moment“ nicht (Fähigkeit einfluss fehlt); --dein-moment geht nicht.');
    exitCode = 2;
    return;
  }

  if (args.contains('--erzaehlerakte')) {
    await erzaehlerakte(wurzel, fall, kanon, texte, wert, deinMoment: deinMoment);
    return;
  }

  if (args.contains('--paket')) {
    await paket(wurzel, fall, kanon, texte, stil, wert, deinMoment: deinMoment);
    return;
  }

  if (args.contains('--steckbriefe')) {
    final datei = File('$wurzel/content/party/$fall/steckbriefe.json');
    if (!datei.existsSync()) {
      stderr.writeln('Akte $fall hat keine Steckbriefe (steckbriefe.json fehlt).');
      exitCode = 2;
      return;
    }
    final rollen = n == null ? null : int.parse(n);
    final k = SteckbriefKontext(kanon, texte, stil,
        steckbriefe: Steckbriefe.ausJson(jsonDecode(datei.readAsStringSync()) as Map<String, Object?>), detektiv: detektiv);
    final aus = Directory(wert('aus') ?? '$wurzel/build/druck/$fall-steckbriefe${rollen == null ? '' : '-n$rollen'}');
    schreibe(aus, await steckbriefDateien(k, rollen: rollen));
    stdout.writeln('Steckbriefe ${rollen == null ? 'aller Figuren' : 'für $rollen Personen'} in ${aus.path}');
    return;
  }

  final code = switch ((wert('code'), wert('pfad'))) {
    (final String c, _) => FallCode.lesen(c) ?? (throw ArgumentError('ungültiger Fall-Code $c')),
    (_, final String p) => FallCode.fuerPfad(p, kanon.pfade),
    _ => FallCode.zufall(Rng(DateTime.now().microsecondsSinceEpoch & 0x7fffffff)),
  };
  final rollen = int.parse(n ?? '12');
  final aus = Directory(wert('aus') ?? '$wurzel/build/druck/${fall == 'schlosskeller' ? '' : '$fall-'}${code.code}-n$rollen');
  final dauer = wert('dauer');
  final satz = DruckSatz.aus(kanon, texte, code, rollen: rollen, detektiv: detektiv, rundendauerMinuten: dauer == null ? null : int.parse(dauer));
  // Dia-Nummern im Erzählerheft aus der Diashow der Akte (M4), sonst ein Dia je Baustein.
  final dia = File('$wurzel/content/welt/$fall/diashow.json');
  final diashow = dia.existsSync() ? Diashow.ausJson(jsonDecode(dia.readAsStringSync()) as Map<String, Object?>) : null;
  final k = DruckKontext(kanon, texte, satz, stil, diashow: diashow);
  schreibe(aus, args.contains('--alles') ? [await druckAlles(k)] : await druckDateien(k));
  stdout.writeln('Druckspiel ${code.code} für $rollen Rollen und den Detektiv in ${aus.path}');
}

/// Das Druckpaket für den Veranstalter (`--paket`): Ordner, Dateien und ZIP-Archive.
Future<void> paket(String wurzel, String fall, Kanon kanon, Texte texte, DruckStil stil, String? Function(String) wert, {bool deinMoment = false}) async {
  final datei = File('$wurzel/content/party/$fall/steckbriefe.json');
  if (!datei.existsSync()) {
    stderr.writeln('Akte $fall hat keine Steckbriefe (steckbriefe.json fehlt); ein Paket gibt es nur für den Schlosskeller.');
    exitCode = 2;
    return;
  }
  final besetzung = Besetzung(kanon);
  final n = int.parse(wert('n') ?? '12');
  if (n < besetzung.minRollen || n > besetzung.maxRollen) {
    stderr.writeln('--n muss zwischen ${besetzung.minRollen} und ${besetzung.maxRollen} liegen.');
    exitCode = 2;
    return;
  }
  final c = wert('code');
  final code = c == null ? FallCode.zufall(Rng(DateTime.now().microsecondsSinceEpoch & 0x7fffffff)) : (FallCode.lesen(c) ?? (throw ArgumentError('ungültiger Fall-Code $c')));
  final fest = festStil(wurzel);
  final ordner = portraetOrdner(wurzel, wert);
  final portraets = portraetsAus(ordner);
  final dia = File('$wurzel/content/welt/$fall/diashow.json');
  final diashow = dia.existsSync() ? Diashow.ausJson(jsonDecode(dia.readAsStringSync()) as Map<String, Object?>) : null;
  final satz = DruckSatz.aus(kanon, texte, code, rollen: n, detektiv: 'w');
  final k = PaketKontext(
    DruckKontext(kanon, texte, satz, stil, diashow: diashow),
    steckbriefe: Steckbriefe.ausJson(jsonDecode(datei.readAsStringSync()) as Map<String, Object?>),
    stil: fest,
    portraets: portraets,
    erzaehlerakte: erzaehlerakteAus(wurzel, fall, kanon, texte, deinMoment: deinMoment),
  );
  final fehlen = k.fehlendePortraets();
  if (fehlen.isNotEmpty) {
    stderr
      ..writeln('Achtung: Porträts fehlen (${fehlen.join(', ')}) in ${ordner.path}.')
      ..writeln('Erzeugen im Repo-Wurzelordner mit: flutter test tool/bild/druck_portraets_test.dart')
      ..writeln('Bis dahin stehen in den Heften Schattenrisse statt Porträts.');
  }
  final name = '$fall-n$n-${code.code}';
  final basis = Directory(wert('aus') ?? '$wurzel/build/paket');
  final ziel = Directory('${basis.path}/$name');
  if (ziel.existsSync()) ziel.deleteSync(recursive: true);
  final dateien = await paketDateien(k);
  final alle = <String, Uint8List>{};
  for (final o in paketOrdner) {
    final inhalt = {for (final p in dateien.where((p) => p.ordner == o)) p.datei.name: p.datei.bytes};
    Directory('${ziel.path}/$o').createSync(recursive: true);
    for (final e in inhalt.entries) {
      File('${ziel.path}/$o/${e.key}').writeAsBytesSync(e.value);
      alle['$name/$o/${e.key}'] = e.value;
      stdout.writeln('${'$o/${e.key}'.padRight(64)}${(e.value.length / 1024).toStringAsFixed(0).padLeft(6)} KB');
    }
    File('${ziel.path}/$o.zip').writeAsBytesSync(zipArchiv({for (final e in inhalt.entries) '$o/${e.key}': e.value}));
  }
  File('${basis.path}/$name.zip').writeAsBytesSync(zipArchiv(alle));
  stdout
    ..writeln('Druckpaket für $n Personen, Fall-Code ${code.code}: ${ziel.path}')
    ..writeln('Archiv: ${basis.path}/$name.zip (je Ordner eine ZIP im Paketordner)');
}

/// Nur die Erzählerakte (`--erzaehlerakte`): ohne Fall-Code, für `--personen` Personen.
Future<void> erzaehlerakte(String wurzel, String fall, Kanon kanon, Texte texte, String? Function(String) wert, {bool deinMoment = false}) async {
  final akte = erzaehlerakteAus(wurzel, fall, kanon, texte, deinMoment: deinMoment);
  if (akte == null) {
    stderr.writeln('Akte $fall hat keine Erzählerakte (content/party/$fall/erzaehlerakte.json fehlt).');
    exitCode = 2;
    return;
  }
  final besetzung = Besetzung(kanon);
  final n = int.parse(wert('personen') ?? wert('n') ?? '8');
  if (n < besetzung.minRollen || n > besetzung.maxRollen) {
    stderr.writeln('--personen muss zwischen ${besetzung.minRollen} und ${besetzung.maxRollen} liegen.');
    exitCode = 2;
    return;
  }
  final ordner = portraetOrdner(wurzel, wert);
  final portraets = portraetsAus(ordner);
  final fehlen = [for (final id in besetzung.besetzt(n)) if (!portraets.containsKey(id)) id];
  if (fehlen.isNotEmpty) {
    stderr
      ..writeln('Achtung: Porträts fehlen (${fehlen.join(', ')}) in ${ordner.path}.')
      ..writeln('Erzeugen im Repo-Wurzelordner mit: flutter test tool/bild/druck_portraets_test.dart')
      ..writeln('Bis dahin stehen in der Akte keine Porträts.');
  }
  final k = ErzaehlerakteKontext(kanon, texte, akte, stil: festStil(wurzel), rollen: n, portraets: FestPortraets(portraets));
  final d = await festErzaehlerakteDatei(k);
  final aus = Directory(wert('aus') ?? '$wurzel/build/druck/$fall-erzaehlerakte-n$n')..createSync(recursive: true);
  File('${aus.path}/${d.name}').writeAsBytesSync(d.bytes);
  stdout
    ..writeln('${d.name.padRight(40)} ${(d.bytes.length / 1024).toStringAsFixed(0).padLeft(6)} KB')
    ..writeln('Erzählerakte für $n Personen in ${aus.path}');
}

/// Die Erzählerakte der Akte, wenn es `erzaehlerakte.json` gibt; sonst null. Die
/// Ziele kommen aus dem Kanon (`persoenlichesZiel`, Druckspiel ohne Schicht); mit
/// [deinMoment] und der Fähigkeit `einfluss` aus den Sternen der Schicht
/// (`content/party/zusatz/<akte>/einfluss.json`).
Erzaehlerakte? erzaehlerakteAus(String wurzel, String fall, Kanon kanon, Texte texte, {bool deinMoment = false}) {
  final datei = File('$wurzel/content/party/$fall/erzaehlerakte.json');
  if (!datei.existsSync()) return null;
  final einfluss = File('$wurzel/content/party/zusatz/$fall/einfluss.json');
  final ziele = deinMoment && faehigkeiten(wurzel, fall).contains('einfluss') && einfluss.existsSync()
      ? EinflussZielQuelle(EinflussRegeln.ausJson(jsonDecode(einfluss.readAsStringSync()) as Map<String, Object?>, Ermittlung(kanon)), texte)
      : null;
  return Erzaehlerakte.ausJson(jsonDecode(datei.readAsStringSync()) as Map<String, Object?>, kanon, ziele: ziele);
}

/// Fähigkeiten der Akte aus `content/party/akten.json` (leer ohne Eintrag).
List<Object?> faehigkeiten(String wurzel, String fall) {
  final datei = File('$wurzel/content/party/akten.json');
  if (!datei.existsSync()) return const [];
  for (final a in (jsonDecode(datei.readAsStringSync()) as Map)['akten'] as List) {
    if ((a as Map)['id'] == fall) return (a['faehigkeiten'] as List?) ?? const [];
  }
  return const [];
}

/// Der festliche Stil mit den Schriften aus `assets/fonts`.
FestStil festStil(String wurzel) {
  Uint8List schrift(String name) => File('$wurzel/assets/fonts/$name').readAsBytesSync();
  return FestStil(
    titel: schrift('PlayfairDisplay-Variabel.ttf'),
    text: schrift('Lora-Variabel.ttf'),
    kursiv: schrift('Lora-Kursiv-Variabel.ttf'),
    hand: schrift('Caveat-Variabel.ttf'),
    maschine: schrift('SpecialElite-Regular.ttf'),
    funktion: schrift('Inter-Regular.ttf'),
    funktionStark: schrift('Inter-SemiBold.ttf'),
  );
}

/// Ordner der Porträts: `--portraets` oder build/druck/portraets.
Directory portraetOrdner(String wurzel, String? Function(String) wert) => Directory(wert('portraets') ?? '$wurzel/build/druck/portraets');

/// Porträts als PNG aus [ordner] (Dateiname ohne `.png` ist der Schlüssel).
Map<String, Uint8List> portraetsAus(Directory ordner) => {
      if (ordner.existsSync())
        for (final f in ordner.listSync().whereType<File>())
          if (f.path.endsWith('.png')) f.uri.pathSegments.last.replaceAll('.png', ''): f.readAsBytesSync(),
    };
