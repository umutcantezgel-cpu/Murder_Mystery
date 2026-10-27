// TON §1 (F-15, E-040): Der Schlag gegen Herrn Schneider wird nur angedeutet,
// als Schatten und Geräusch. Kein Spielertext beschreibt ihn als Handlung.
import 'dart:convert';
import 'dart:io';

import 'package:mordakte_core/mordakte_core.dart' show schlagVerbRe;
import 'package:test/test.dart';

import 'kanon_hilfe.dart';

Iterable<String> _texte(Object? o) sync* {
  if (o is String) yield o;
  if (o is Map) {
    for (final v in o.values) {
      yield* _texte(v);
    }
  }
  if (o is List) {
    for (final v in o) {
      yield* _texte(v);
    }
  }
}

List<String> _treffer(Map<String, Object?> dateien) => [
      for (final e in dateien.entries)
        for (final t in _texte(e.value))
          if (schlagVerbRe.hasMatch(t)) '${e.key}: ${schlagVerbRe.firstMatch(t)![0]}',
    ];

void main() {
  final ordner = Directory('$repoWurzel/content/party/schlosskeller/texte');
  final dateien = {
    for (final f in ordner.listSync().whereType<File>().where((f) => f.path.endsWith('.json')))
      f.uri.pathSegments.last: jsonDecode(f.readAsStringSync()),
  };

  test('kein Spielertext beschreibt den Schlag als Handlung', () {
    expect(_treffer(dateien), isEmpty);
  });

  test('Rot-Probe: „Du schlägst einmal zu.“ würde gemeldet; „ein dumpfer Schlag“ bleibt erlaubt', () {
    expect(_treffer({'probe.json': {'text': 'Du schlägst einmal zu.'}}), hasLength(1));
    expect(_treffer({'probe.json': {'text': 'Dann ist da nur ein dumpfer Schlag und Poltern.'}}), isEmpty);
  });
}
