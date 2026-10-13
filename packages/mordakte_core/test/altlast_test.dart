// A-041: Feinkorn und Burgstadt sind verworfen und kommen nie zurück. Der Test sucht in allen
// getrackten Dateien außerhalb von planung/ nach ihren Paket-, Ordner- und Bezeichnernamen.
// Die Suchwörter werden zusammengesetzt, damit diese Datei sich nicht selbst meldet.
import 'dart:io';

import 'package:test/test.dart';

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

final _woerter = [
  ['burg', 'stadt'],
  ['fein', 'korn'],
  ['pixel', '_engine'],
  ['room', '_host'],
  ['raum', '_host'],
].map((t) => t.join()).toList();

const _ausgenommen = ['planung/', 'pubspec.lock'];

void main() {
  final wurzel = _wurzel();
  final muster = RegExp(_woerter.join('|'), caseSensitive: false);

  test('Keine Reste von Feinkorn und Burgstadt (A-041)', () {
    final git = Process.runSync('git', ['ls-files', '-z'], workingDirectory: wurzel.path);
    if (git.exitCode != 0) {
      markTestSkipped('git nicht verfügbar');
      return;
    }
    final eigene = 'packages/mordakte_core/test/altlast_test.dart';
    final treffer = <String>[];
    for (final pfad in (git.stdout as String).split('\u0000').where((p) => p.isNotEmpty)) {
      if (pfad == eigene || _ausgenommen.any(pfad.startsWith)) continue;
      if (muster.hasMatch(pfad)) {
        treffer.add(pfad);
        continue;
      }
      final datei = File('${wurzel.path}/$pfad');
      if (!datei.existsSync()) continue;
      final String text;
      try {
        text = datei.readAsStringSync();
      } on FileSystemException {
        continue; // Binärdatei
      }
      final zeilen = text.split('\n');
      for (var i = 0; i < zeilen.length; i++) {
        if (muster.hasMatch(zeilen[i])) treffer.add('$pfad:${i + 1}');
      }
    }
    expect(treffer, isEmpty, reason: 'Altlasten gefunden:\n${treffer.join('\n')}');
  });
}
