// Druckpaket per Werkzeug (`party_druck.dart --paket`): vier Ordner mit allen Dateien, je
// Ordner eine ZIP und das ganze Paket als ZIP, der Fall-Code im Ordnernamen. Außerhalb des
// Repos bricht das Werkzeug mit einer Meldung ab, statt endlos nach der Wurzel zu suchen.
// Finale (A-063): Mit erzaehlerakte.json liegt die Erzählerakte in Ordner 4 (eine PDF mehr);
// `--erzaehlerakte` setzt sie allein, ohne Fall-Code. Bis die echte Akte eingespielt ist,
// läuft das Werkzeug in einer Kopie des Repos (Verweise auf die echten Dateien) mit der Fixture.
import 'dart:convert';
import 'dart:io';

import 'package:image/image.dart' as img;
import 'package:mordakte_core/mordakte_core.dart';
import 'package:test/test.dart';

import 'einstimmung_hilfe.dart' show erzaehlerakteFixture;
import 'kanon_hilfe.dart';

/// Ein Repo aus Verweisen auf die echten Dateien unter [ziel]: `content/party/schlosskeller`
/// Datei für Datei, mit [akte] die Erzählerakte (die echte, sonst die Fixture), ohne
/// [akte] keine. Werkzeug und Schriften liest das Werkzeug von dort wie aus dem Repo.
Directory _repo(Directory ziel, {required bool akte}) {
  void verweis(String pfad) => Link('${ziel.path}/$pfad').createSync('$repoWurzel/$pfad', recursive: true);
  for (final e in Directory('$repoWurzel/content').listSync()) {
    final name = e.uri.pathSegments.where((s) => s.isNotEmpty).last;
    if (name != 'party') verweis('content/$name');
  }
  for (final e in Directory('$repoWurzel/content/party').listSync()) {
    final name = e.uri.pathSegments.where((s) => s.isNotEmpty).last;
    if (name != 'schlosskeller') verweis('content/party/$name');
  }
  for (final e in Directory('$repoWurzel/content/party/schlosskeller').listSync()) {
    final name = e.uri.pathSegments.where((s) => s.isNotEmpty).last;
    if (name != 'erzaehlerakte.json') verweis('content/party/schlosskeller/$name');
  }
  verweis('assets');
  if (akte) {
    final echt = File('$repoWurzel/content/party/schlosskeller/erzaehlerakte.json');
    File('${ziel.path}/content/party/schlosskeller/erzaehlerakte.json')
        .writeAsStringSync(echt.existsSync() ? echt.readAsStringSync() : jsonEncode(erzaehlerakteFixture()));
  }
  return ziel;
}

void main() {
  final skript = '$repoWurzel/packages/mordakte_core/bin/party_druck.dart';
  final pakete = '$repoWurzel/packages/mordakte_core/.dart_tool/package_config.json';
  late Directory tmp;

  setUp(() => tmp = Directory.systemTemp.createTempSync('paket_cli'));
  tearDown(() => tmp.deleteSync(recursive: true));

  Directory bilder() {
    final d = Directory('${tmp.path}/portraets')..createSync();
    for (final id in [for (final f in kanon.figuren) f['id'] as String, 'detektiv-w', 'detektiv-m']) {
      File('${d.path}/$id.png').writeAsBytesSync(img.encodePng(img.Image(width: 32, height: 32)..clear(img.ColorRgb8(90, 120, 150))));
    }
    return d;
  }

  test('--paket: vier Ordner, alle Dateien samt Erzählerakte, ZIPs, Code im Namen, Porträts aus --portraets', () async {
    final repo = _repo(Directory('${tmp.path}/repo'), akte: true);
    final code = FallCode.fuerPfad('olli', kanon.pfade).code;
    final r = await Process.run(
      Platform.resolvedExecutable,
      ['--packages=$pakete', skript, '--paket', '--n', '12', '--code', code, '--aus', '${tmp.path}/aus', '--portraets', bilder().path],
      workingDirectory: repo.path,
    );
    expect(r.exitCode, 0, reason: '${r.stdout}\n${r.stderr}');
    expect('${r.stderr}', isNot(contains('Porträts fehlen')));
    expect('${r.stdout}', contains(code));
    final paket = Directory('${tmp.path}/aus/schlosskeller-n12-$code');
    int pdfs(String o) => Directory('${paket.path}/$o').listSync().where((f) => f.path.endsWith('.pdf')).length;
    expect(pdfs('1-an-alle'), 2 + 12 + 2);
    expect(pdfs('2-veranstalter'), 1);
    expect(pdfs('3-je-person-ungelesen-weitergeben'), 12 + 2);
    expect(pdfs('4-nur-erzaehler'), 1 + 1);
    expect(File('${paket.path}/4-nur-erzaehler/erzaehlerakte.pdf').existsSync(), isTrue);
    for (final z in ['${tmp.path}/aus/schlosskeller-n12-$code.zip', for (final o in ['1-an-alle', '2-veranstalter', '3-je-person-ungelesen-weitergeben', '4-nur-erzaehler']) '${paket.path}/$o.zip']) {
      final t = Process.runSync('unzip', ['-t', z]);
      expect(t.exitCode, 0, reason: '$z\n${t.stdout}');
    }
    final liste = Process.runSync('unzip', ['-Z1', '${tmp.path}/aus/schlosskeller-n12-$code.zip']).stdout as String;
    expect(liste.trim().split('\n'), hasLength(32 + 1));
    expect(liste, contains('schlosskeller-n12-$code/3-je-person-ungelesen-weitergeben/rollenheft-olli.pdf'));
    expect(liste, contains('schlosskeller-n12-$code/4-nur-erzaehler/erzaehlerakte.pdf'));
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

  test('--erzaehlerakte: nur die Erzählerakte, ohne Fall-Code, für --personen Personen', () async {
    final repo = _repo(Directory('${tmp.path}/repo'), akte: true);
    final aus = '${tmp.path}/akte';
    final r = await Process.run(
      Platform.resolvedExecutable,
      ['--packages=$pakete', skript, '--erzaehlerakte', '--personen', '8', '--aus', aus, '--portraets', bilder().path],
      workingDirectory: repo.path,
    );
    expect(r.exitCode, 0, reason: '${r.stdout}\n${r.stderr}');
    expect('${r.stderr}', isNot(contains('Porträts fehlen')));
    expect('${r.stdout}', contains('erzaehlerakte.pdf'));
    expect([for (final f in Directory(aus).listSync()) f.uri.pathSegments.last], ['erzaehlerakte.pdf']);
    // Kein Fall-Code: weder in der Ausgabe noch im Ordner; die Datei hat Deckblatt, Personen, Netz und je Figur eine Seite.
    expect(RegExp(r'\b[A-Z0-9]{5}\b').hasMatch('${r.stdout}'.replaceAll(aus, '')), isFalse, reason: '${r.stdout}');
    final info = Process.runSync('pdfinfo', ['$aus/erzaehlerakte.pdf']).stdout as String;
    expect(int.parse(RegExp(r'Pages:\s+(\d+)').firstMatch(info)!.group(1)!), greaterThanOrEqualTo(3 + kanon.figuren.length));
  }, timeout: const Timeout(Duration(minutes: 3)));

  test('--erzaehlerakte ohne erzaehlerakte.json oder mit falscher Personenzahl: Abbruch mit Meldung', () async {
    final ohne = _repo(Directory('${tmp.path}/ohne'), akte: false);
    final r = await Process.run(
      Platform.resolvedExecutable,
      ['--packages=$pakete', skript, '--erzaehlerakte', '--personen', '8', '--aus', '${tmp.path}/akte'],
      workingDirectory: ohne.path,
    );
    expect(r.exitCode, 2, reason: '${r.stdout}\n${r.stderr}');
    expect('${r.stderr}', contains('keine Erzählerakte'));
    expect(Directory('${tmp.path}/akte').existsSync(), isFalse);
    final mit = _repo(Directory('${tmp.path}/mit'), akte: true);
    final falsch = await Process.run(
      Platform.resolvedExecutable,
      ['--packages=$pakete', skript, '--erzaehlerakte', '--personen', '30', '--aus', '${tmp.path}/akte'],
      workingDirectory: mit.path,
    );
    expect(falsch.exitCode, 2, reason: '${falsch.stdout}\n${falsch.stderr}');
    expect('${falsch.stderr}', contains('--personen'));
  }, timeout: const Timeout(Duration(minutes: 3)));

  test('außerhalb des Repos: Abbruch mit Meldung statt endloser Suche', () async {
    final r = await Process.run(Platform.resolvedExecutable, ['--packages=$pakete', skript, '--paket'], workingDirectory: tmp.path)
        .timeout(const Duration(minutes: 2));
    expect(r.exitCode, 2);
    expect('${r.stderr}', contains('Kein Mordakte-Repo gefunden'));
  }, timeout: const Timeout(Duration(minutes: 3)));
}
