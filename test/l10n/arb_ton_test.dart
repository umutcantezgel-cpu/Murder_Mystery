// Oberflächentexte in der ARB folgen denselben Tonregeln wie der Kanon
// (TON-LEITFADEN §4–§6, content/party/textregeln.json). Bestehende Altbefunde
// stehen in arb_ton_bestand.txt; neue Schlüssel müssen ohne Befund sein.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte_core/mordakte_core.dart';

void main() {
  test('ARB-Texte ohne neue Tonbefunde', () {
    final arb = (jsonDecode(File('lib/l10n/app_de.arb').readAsStringSync()) as Map).cast<String, Object?>();
    final regeln = (jsonDecode(File('content/party/textregeln.json').readAsStringSync()) as Map).cast<String, Object?>();
    final bestand = File('test/l10n/arb_ton_bestand.txt')
        .readAsLinesSync()
        .map((z) => z.trim())
        .where((z) => z.isNotEmpty && !z.startsWith('#'))
        .toSet();
    final pruefer = Textpruefer(regeln);
    final neu = <String>[];
    for (final e in arb.entries) {
      if (e.key.startsWith('@') || e.value is! String) continue;
      // Platzhalter wie {name} zählen als ein Wort.
      final text = (e.value as String).replaceAll(RegExp(r'\{[^}]*\}'), 'X');
      final befunde = pruefer.pruefe(TextQuelle(ort: e.key, text: text, vorlesen: false));
      if (befunde.isNotEmpty && !bestand.contains(e.key)) {
        neu.add('${e.key}: ${befunde.map((b) => '${b.regel} „${b.auszug}“').join('; ')}');
      }
    }
    expect(neu, isEmpty, reason: 'Neue Oberflächentexte verletzen die Tonregeln:\n${neu.join('\n')}');
  });
}
