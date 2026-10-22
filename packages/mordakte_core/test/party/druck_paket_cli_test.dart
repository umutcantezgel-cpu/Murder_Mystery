// Druckpaket per Werkzeug (`party_druck.dart --paket`): vier Ordner mit allen Dateien, je
// Ordner eine ZIP und das ganze Paket als ZIP, der Fall-Code im Ordnernamen. Außerhalb des
// Repos bricht das Werkzeug mit einer Meldung ab, statt endlos nach der Wurzel zu suchen.
import 'dart:io';

import 'package:image/image.dart' as img;
import 'package:mordakte_core/mordakte_core.dart';
import 'package:test/test.dart';

import 'kanon_hilfe.dart';

void main() {
  final skript = '$repoWurzel/packages/mordakte_core/bin/party_druck.dart';
  final pakete = '$repoWurzel/packages/mordakte_core/.dart_tool/package_config.json';
  late Directory tmp;

  setUp(() => tmp = Directory.systemTemp.createTempSync('paket_cli'));
  tearDown(() => tmp.deleteSync(recursive: true));

  test('--paket: vier Ordner, alle Dateien, ZIPs, Code im Namen, Porträts aus --portraets', () async {
    final bilder = Directory('${tmp.path}/portraets')..createSync();
    for (final id in [for (final f in kanon.figuren) f['id'] as String, 'detektiv-w', 'detektiv-m']) {
      File('${bilder.path}/$id.png').writeAsBytesSync(img.encodePng(img.Image(width: 32, height: 32)..clear(img.ColorRgb8(90, 120, 150))));
    }
    final code = FallCode.fuerPfad('olli', kanon.pfade).code;
    final r = await Process.run(
      Platform.resolvedExecutable,
      ['--packages=$pakete', skript, '--paket', '--n', '12', '--code', code, '--aus', '${tmp.path}/aus', '--portraets', bilder.path],
      workingDirectory: '$repoWurzel/packages/mordakte_core',
    );
    expect(r.exitCode, 0, reason: '${r.stdout}\n${r.stderr}');
    expect('${r.stderr}', isNot(contains('Porträts fehlen')));
    expect('${r.stdout}', contains(code));
    final paket = Directory('${tmp.path}/aus/schlosskeller-n12-$code');
    int pdfs(String o) => Directory('${paket.path}/$o').listSync().where((f) => f.path.endsWith('.pdf')).length;
    expect(pdfs('1-an-alle'), 2 + 12 + 2);
    expect(pdfs('2-veranstalter'), 1);
    expect(pdfs('3-je-person-ungelesen-weitergeben'), 12 + 2);
    expect(pdfs('4-nur-erzaehler'), 1);
    for (final z in ['${tmp.path}/aus/schlosskeller-n12-$code.zip', for (final o in ['1-an-alle', '2-veranstalter', '3-je-person-ungelesen-weitergeben', '4-nur-erzaehler']) '${paket.path}/$o.zip']) {
      final t = Process.runSync('unzip', ['-t', z]);
      expect(t.exitCode, 0, reason: '$z\n${t.stdout}');
    }
    final liste = Process.runSync('unzip', ['-Z1', '${tmp.path}/aus/schlosskeller-n12-$code.zip']).stdout as String;
    expect(liste.trim().split('\n'), hasLength(32));
    expect(liste, contains('schlosskeller-n12-$code/3-je-person-ungelesen-weitergeben/rollenheft-olli.pdf'));
  }, timeout: const Timeout(Duration(minutes: 5)));

  test('--paket ohne Porträts: Hinweis, wie man sie erzeugt; das Paket entsteht trotzdem', () async {
    final r = await Process.run(
      Platform.resolvedExecutable,
      ['--packages=$pakete', skript, '--paket', '--n', '4', '--aus', '${tmp.path}/aus', '--portraets', '${tmp.path}/fehlt'],
      workingDirectory: '$repoWurzel/packages/mordakte_core',
    );
    expect(r.exitCode, 0, reason: '${r.stdout}\n${r.stderr}');
    expect('${r.stderr}', contains('Porträts fehlen'));
    expect('${r.stderr}', contains('flutter test tool/bild/druck_portraets_test.dart'));
    expect(Directory('${tmp.path}/aus').listSync().whereType<Directory>().single.path, contains('schlosskeller-n4-'));
  }, timeout: const Timeout(Duration(minutes: 5)));

  test('außerhalb des Repos: Abbruch mit Meldung statt endloser Suche', () async {
    final r = await Process.run(Platform.resolvedExecutable, ['--packages=$pakete', skript, '--paket'], workingDirectory: tmp.path)
        .timeout(const Duration(minutes: 2));
    expect(r.exitCode, 2);
    expect('${r.stderr}', contains('Kein Mordakte-Repo gefunden'));
  }, timeout: const Timeout(Duration(minutes: 3)));
}
