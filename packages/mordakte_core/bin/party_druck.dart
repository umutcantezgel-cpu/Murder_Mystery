// Druckspiel des Partymodus als PDF-Satz (F5, Master 7.14) und Steckbriefe (K3, M5).
// Aufruf (im Paketordner):
//   dart run bin/party_druck.dart [--fall schlosskeller] [--code XXXXX | --pfad <ahmet|fatma|olli|can>] [--n 12] [--detektiv w] [--dauer 30] [--alles] [--aus ordner]
//   dart run bin/party_druck.dart --steckbriefe [--fall schlosskeller] [--n 12] [--detektiv w] [--aus ordner]
// Ohne Code und Pfad entsteht ein Zufallsfall. Der Pfad ist nur für Testläufe
// des Erzählers gedacht; im Ordnernamen steht nur der Code. --alles setzt die acht
// Teile in eine Datei. --steckbriefe braucht keinen Fall-Code: Übersicht, alle
// Steckbriefe in einer Datei und je Figur ein Steckbrief (ohne --n alle Figuren).
import 'dart:convert';
import 'dart:io';

import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/party_druck.dart';

Future<void> main(List<String> args) async {
  String? wert(String name) {
    final i = args.indexOf('--$name');
    return i >= 0 && i + 1 < args.length ? args[i + 1] : null;
  }

  var d = Directory.current;
  while (!Directory('${d.path}/content/party').existsSync()) {
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
  final k = DruckKontext(kanon, texte, satz, stil);
  schreibe(aus, args.contains('--alles') ? [await druckAlles(k)] : await druckDateien(k));
  stdout.writeln('Druckspiel ${code.code} für $rollen Rollen und den Detektiv in ${aus.path}');
}
