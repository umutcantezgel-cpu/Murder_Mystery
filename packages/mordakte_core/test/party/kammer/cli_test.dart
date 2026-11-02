// Werkzeug `bin/party_druck.dart` (ARCHITEKTUR A3): Ohne Modus setzt es das
// Kammerspiel für den Schlosskeller (--personen 6..20, Vorgabe 10; --detektiv;
// --alles; --aus; --probe für 6, 10 und 20 Personen) nach
// build/druck/kammerspiel-U4YRK-p<personen>/. Falsche Angaben brechen mit Exit 2 und
// einer klaren Meldung ab, ohne Dateien: fremder --code („fester Fall U4YRK“), --n und
// --pfad (Personen statt Rollen, altes Druckspiel mit --druckspiel-alt), --personen
// 5 oder 21, eine Akte ohne Kammerspiel, eine Angabe ohne Wert und eine unbekannte
// Angabe. --druckspiel-alt setzt die acht alten Dateien.
//
// Das Werkzeug wird einmal als Kernel übersetzt und dann je Fall gestartet; es läuft
// in einer Kopie des Repos (Verweise auf content/ und assets/), damit der Standardpfad
// build/druck/ nicht im Repo landet.
import 'dart:io';

import 'package:test/test.dart';

import '../kanon_hilfe.dart';

const teile = [
  '00-erzaehlerheft.pdf',
  '01-detektivbogen.pdf',
  '02-tisch.pdf',
  '10-rollenhefte.pdf',
  '11-fassungen.pdf',
  '12-zusatzrollen.pdf',
  '20-karten.pdf',
  '90-aufloesung-versiegelt.pdf',
];

/// Einzeldateien bei 10 Personen (Plätze 1 bis 8).
const einzelnBei10 = [
  '10-rollenheft-ahmet.pdf',
  '10-rollenheft-fatma.pdf',
  '10-rollenheft-olli.pdf',
  '10-rollenheft-can.pdf',
  '10-rollenheft-lejla.pdf',
  '10-rollenheft-emine.pdf',
  '10-rollenheft-tim.pdf',
  '10-rollenheft-joanna.pdf',
];

const altesDruckspiel = [
  '00-erzaehlerheft.pdf',
  '01-detektivbogen.pdf',
  '10-rollenhefte.pdf',
  '11-fassungen.pdf',
  '12-stimmkarten.pdf',
  '20-indizkarten.pdf',
  '21-umschlaege.pdf',
  '90-aufloesung-versiegelt.pdf',
];

void main() {
  final paket = '$repoWurzel/packages/mordakte_core';
  late Directory tmp;
  late String kern;
  late Directory repo;

  setUpAll(() async {
    tmp = Directory.systemTemp.createTempSync('kammer_cli');
    kern = '${tmp.path}/party_druck.dill';
    final r = await Process.run(
      Platform.resolvedExecutable,
      ['compile', 'kernel', '--packages=$paket/.dart_tool/package_config.json', '$paket/bin/party_druck.dart', '-o', kern],
    );
    expect(r.exitCode, 0, reason: '${r.stdout}\n${r.stderr}');
    // Kopie des Repos aus Verweisen: content/ und assets/ wie im Repo, build/ nur hier.
    repo = Directory('${tmp.path}/repo')..createSync();
    for (final name in ['content', 'assets']) {
      Link('${repo.path}/$name').createSync('$repoWurzel/$name');
    }
  });
  tearDownAll(() => tmp.deleteSync(recursive: true));

  Future<ProcessResult> werkzeug(List<String> args) =>
      Process.run(Platform.resolvedExecutable, [kern, ...args], workingDirectory: repo.path);

  List<String> pdfs(String ordner) {
    final d = Directory(ordner);
    if (!d.existsSync()) return const [];
    return [for (final f in d.listSync().whereType<File>()) if (f.path.endsWith('.pdf')) f.uri.pathSegments.last]..sort();
  }

  test('Standardmodus: Kammerspiel für 10 Personen in build/druck/kammerspiel-U4YRK-p10', () async {
    final r = await werkzeug([]);
    expect(r.exitCode, 0, reason: '${r.stdout}\n${r.stderr}');
    expect('${r.stdout}', contains('10 Personen'));
    expect(pdfs('${repo.path}/build/druck/kammerspiel-U4YRK-p10'), ([...teile, ...einzelnBei10]..sort()));
  });

  test('--probe: Sätze für 6, 10 und 20 Personen, je mit Teilen und Einzeldateien', () async {
    final r = await werkzeug(['--probe', '--aus', '${tmp.path}/probe']);
    expect(r.exitCode, 0, reason: '${r.stdout}\n${r.stderr}');
    for (final (p, rollen) in [(6, 4), (10, 8), (20, 18)]) {
      final dateien = pdfs('${tmp.path}/probe/kammerspiel-U4YRK-p$p');
      expect(dateien.where(teile.contains), hasLength(8), reason: '$p');
      expect(dateien.where((d) => d.startsWith('10-rollenheft-') || d.startsWith('12-zusatzheft-')), hasLength(rollen), reason: '$p');
      expect(dateien, hasLength(8 + rollen), reason: '$p');
    }
    expect(pdfs('${tmp.path}/probe/kammerspiel-U4YRK-p20'), contains('12-zusatzheft-tugba.pdf'));
  });

  test('--alles mit --personen und --detektiv m: nur kammerspiel-alles.pdf; --code U4YRK ist erlaubt', () async {
    final aus = '${tmp.path}/alles';
    final r = await werkzeug(['--alles', '--personen', '13', '--detektiv', 'm', '--code', 'U4YRK', '--aus', aus]);
    expect(r.exitCode, 0, reason: '${r.stdout}\n${r.stderr}');
    expect(pdfs(aus), ['kammerspiel-alles.pdf']);
    expect('${r.stdout}', contains('13 Personen'));
  });

  group('Abbrüche mit Exit 2, Meldung und ohne Dateien', () {
    for (final (args, meldung) in [
      (['--code', 'ABCDE'], 'fester Fall U4YRK'),
      (['--n', '10'], '--personen'),
      (['--n', '10'], '--druckspiel-alt'),
      (['--pfad', 'olli'], 'fester Fall U4YRK'),
      (['--pfad', 'olli'], '--druckspiel-alt'),
      (['--personen', '5'], 'zwischen 6 und 20'),
      (['--personen', '21'], 'zwischen 6 und 20'),
      (['--fall', 'gewoelbe'], 'kein Kammerspiel'),
      (['--detektiv', 'x'], 'w oder m'),
      (['--probe', '--personen', '10'], '--probe'),
      (['--dauer', '30'], '--druckspiel-alt'),
      // Ohne Wert fiele die Angabe still auf die Vorgabe zurück (10 Personen, Detektivin).
      (['--detektiv', '--alles'], '--detektiv braucht einen Wert'),
      (['--code', '--alles'], '--code braucht einen Wert'),
      // Vertippte oder fremde Angaben fielen sonst still weg (10 Personen statt 8).
      (['--persnen', '8'], 'Unbekannte Angabe --persnen'),
      (['--personen', '8', '9'], 'Unbekannte Angabe 9'),
      (['--portraets', 'bilder'], 'Unbekannte Angabe --portraets'),
    ]) {
      test('${args.join(' ')} → „$meldung“', () async {
        final aus = '${tmp.path}/abbruch-${args.join('_')}';
        final r = await werkzeug([...args, '--aus', aus]);
        expect(r.exitCode, 2, reason: '${r.stdout}\n${r.stderr}');
        expect('${r.stderr}', contains(meldung));
        expect(pdfs(aus), isEmpty);
        expect(Directory('$aus/kammerspiel-U4YRK-p6').existsSync(), isFalse);
      });
    }
  });

  test('--personen und --aus am Ende ohne Wert: Abbruch statt Vorgabe', () async {
    for (final (args, meldung) in [
      (['--personen'], '--personen braucht einen Wert'),
      (['--alles', '--aus'], '--aus braucht einen Wert'),
    ]) {
      final r = await werkzeug(args);
      expect(r.exitCode, 2, reason: '$args\n${r.stdout}\n${r.stderr}');
      expect('${r.stderr}', contains(meldung));
      expect(pdfs('${repo.path}/build/druck/kammerspiel-U4YRK-p10'), isNot(contains('kammerspiel-alles.pdf')));
    }
  });

  test('--druckspiel-alt: die acht Dateien des alten Druckspiels wie bisher', () async {
    final aus = '${tmp.path}/alt';
    final r = await werkzeug(['--druckspiel-alt', '--pfad', 'olli', '--n', '7', '--aus', aus]);
    expect(r.exitCode, 0, reason: '${r.stdout}\n${r.stderr}');
    expect(pdfs(aus), ([...altesDruckspiel]..sort()));
    expect('${r.stdout}', contains('Druckspiel'));
  });
}
