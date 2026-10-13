// Store-Paket (M8): Längen der Felder nach den Grenzen von Play und App Store, die
// Tonregeln des Kanons (kein Alkohol, kein Rauchen) und kein Täter in den Texten.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte_core/mordakte_core.dart';

String _lies(String pfad) => File('store/metadata/$pfad').readAsStringSync();

void main() {
  const grenzen = {
    'android/de-DE/title.txt': 30,
    'android/de-DE/short_description.txt': 80,
    'android/de-DE/full_description.txt': 4000,
    'android/de-DE/changelog_default.txt': 500,
    'ios/de-DE/name.txt': 30,
    'ios/de-DE/subtitle.txt': 30,
    'ios/de-DE/promotional_text.txt': 170,
    'ios/de-DE/description.txt': 4000,
    'ios/de-DE/keywords.txt': 100,
    'ios/de-DE/release_notes.txt': 4000,
  };

  test('Jedes Feld hält die Grenze seines Stores ein und ist nicht leer', () {
    for (final e in grenzen.entries) {
      final t = _lies(e.key).trim();
      expect(t, isNotEmpty, reason: e.key);
      expect(t.runes.length, lessThanOrEqualTo(e.value), reason: '${e.key}: ${t.runes.length} Zeichen');
    }
  });

  test('Tonregeln des Kanons gelten auch im Store', () {
    final regeln = jsonDecode(File('content/party/textregeln.json').readAsStringSync()) as Map<String, Object?>;
    final pruefer = Textpruefer(regeln);
    for (final datei in grenzen.keys) {
      // Die Satzlänge gilt für Vorlesetexte, nicht für Listen im Store.
      final befunde = pruefer.pruefe(TextQuelle(ort: datei, text: _lies(datei), vorlesen: false)).where((b) => !b.regel.startsWith('Satzlänge'));
      expect(befunde.map((b) => '${b.regel}: ${b.auszug}'), isEmpty, reason: datei);
    }
  });

  test('Kein Täter und keine Lösung in den Store-Texten', () {
    final texte = [for (final d in grenzen.keys) _lies(d)].join('\n');
    for (final akte in ['schlosskeller', 'gewoelbe', 'ravensmoor', 'nachtexpress', 'blue_palm']) {
      final fall = jsonDecode(File('content/party/$akte/fall.json').readAsStringSync()) as Map<String, Object?>;
      final figuren = jsonDecode(File('content/party/$akte/figuren.json').readAsStringSync()) as Map<String, Object?>;
      final kern = {for (final k in fall['kernverdaechtige'] as List) k as String};
      for (final f in figuren['figuren'] as List) {
        final figur = f as Map;
        final name = RegExp('(?<![\\p{L}])${RegExp.escape(figur['name'] as String)}(?![\\p{L}])', unicode: true);
        if (kern.contains(figur['id'])) expect(name.hasMatch(texte), isFalse, reason: '$akte: ${figur['name']}');
      }
    }
  });

  test('Android und iOS beschreiben dasselbe', () {
    expect(_lies('ios/de-DE/description.txt'), _lies('android/de-DE/full_description.txt'));
  });
}
