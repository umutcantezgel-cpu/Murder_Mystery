// A-002/A-050: Die Kanon-Ordner bleiben unverändert. Geprüft wird gegen
// tool/kanon_pruefsummen.txt (Format: "<sha256>  <relativer Pfad>"). Den Schlosskeller
// baselined `bash tool/kanon_neu.sh` neu; tool/kanon_fest.txt (Beweis-Teilmenge,
// krimidinner, scenarios) bleibt fest und wird nie neu erzeugt.
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:test/test.dart';

const _ordner = [
  'content/party/schlosskeller',
  'content/party/basis-ui',
  'krimidinner',
  'content/scenarios',
];

Directory _wurzel() {
  var dir = Directory.current.absolute;
  while (!(File('${dir.path}/pubspec.yaml').existsSync() &&
      Directory('${dir.path}/content').existsSync())) {
    if (dir.parent.path == dir.path) {
      throw StateError('Repo-Wurzel (pubspec.yaml + content/) nicht gefunden.');
    }
    dir = dir.parent;
  }
  return dir;
}
String _liste(List<String> pfade) => pfade.map((p) => '  - $p').join('\n');

void main() {
  final wurzel = _wurzel();
  final eintrag = RegExp(r'^([0-9a-f]{64})  (.+)$');
  final zeilen = File('${wurzel.path}/tool/kanon_pruefsummen.txt')
      .readAsLinesSync()
      .where((z) => z.trim().isNotEmpty);

  test('Feste Beweis-Teilmenge ist bytegleich (A-050)', () {
    final abweichend = <String>[];
    for (final zeile in File('${wurzel.path}/tool/kanon_fest.txt')
        .readAsLinesSync()
        .where((z) => z.trim().isNotEmpty)) {
      final m = eintrag.firstMatch(zeile);
      if (m == null) fail('Ungültige Zeile in kanon_fest.txt: $zeile');
      final datei = File('${wurzel.path}/${m.group(2)}');
      if (!datei.existsSync() ||
          sha256.convert(datei.readAsBytesSync()).toString() != m.group(1)) {
        abweichend.add(m.group(2)!);
      }
    }
    expect(abweichend, isEmpty,
        reason: 'Diese Dateien sind die Beweisbasis und bleiben bytegleich.');
  });

  test('Kanon-Ordner entsprechen den Prüfsummen (A-002/A-050)', () {
    final geaendert = <String>[], fehlt = <String>[], gelistet = <String>{};
    for (final zeile in zeilen) {
      final m = eintrag.firstMatch(zeile);
      if (m == null) fail('Ungültige Zeile in kanon_pruefsummen.txt: $zeile');
      final pfad = m.group(2)!;
      gelistet.add(pfad);
      final datei = File('${wurzel.path}/$pfad');
      final hash = datei.existsSync()
          ? sha256.convert(datei.readAsBytesSync()).toString()
          : null;
      if (hash == null) {
        fehlt.add(pfad);
      } else if (hash != m.group(1)) {
        geaendert.add(pfad);
      }
    }

    // Zusatzcheck: Dateien in den Kanon-Ordnern, die getrackt oder untracked
    // (nicht ignoriert) sind, aber nicht in der Liste stehen. Ohne git entfällt er.
    final neu = <String>[];
    try {
      final git = Process.runSync(
        'git',
        ['ls-files', '-z', '-co', '--exclude-standard', '--', ..._ordner],
        workingDirectory: wurzel.path,
      );
      if (git.exitCode == 0) {
        neu.addAll((git.stdout as String).split('\u0000').where(
            (p) => p.isNotEmpty && !gelistet.contains(p)));
      }
    } on ProcessException {
      // git fehlt: nur die Prüfsummen-Liste gilt.
    }
    final probleme = [
      if (geaendert.isNotEmpty) 'Geändert:\n${_liste(geaendert)}',
      if (fehlt.isNotEmpty) 'Fehlt:\n${_liste(fehlt)}',
      if (neu.isNotEmpty) 'Nicht in der Liste:\n${_liste(neu)}',
    ];
    if (probleme.isNotEmpty) {
      fail('A-002/A-050 verletzt: Kanon-Ordner weichen von tool/kanon_pruefsummen.txt ab.\n'
          '${probleme.join('\n')}\n'
          'Beabsichtigte Schlosskeller-Änderungen: bash tool/kanon_tor.sh. '
          'krimidinner und scenarios bleiben unverändert.');
    }
  });
}
