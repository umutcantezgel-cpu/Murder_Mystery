// Kammerspiel (ARCHITEKTUR A1, SCHEMA.md §2 „OFFEN“): Die Schreib-Phase ist abgeschlossen. Der Inhalt unter
// content/kammerspiel/schlosskeller/ hat keine OFFEN-Felder mehr (KammerInhalt.offeneFelder ist leer), und kein
// String irgendwo im Ordner (Schlüssel und Werte aller JSON-Dateien, auch solcher, die der Lader nicht liest)
// beginnt mit „OFFEN“ oder enthält „OFFENE FRAGE“. Ausgenommen sind nur SCHEMA.md (beschreibt die Marke) und
// textregeln.json (Regeldaten des Textprüfers, nennen die Marken).
// Rot-Proben: ein OFFEN-Feld, eine „OFFENE FRAGE“ mitten im Text und ein OFFEN-Text in einer Datei, die der Lader
// nicht kennt, werden je mit Datei und Pfad erkannt.
import 'dart:convert';
import 'dart:io';

import 'package:mordakte_core/kammer_io.dart';
import 'package:test/test.dart';

import '../kanon_hilfe.dart' show repoWurzel;

/// Dateien im Inhaltsordner, die keine Spieltexte sind und die Marken nennen dürfen.
const _ausgenommen = {'SCHEMA.md', 'textregeln.json'};

/// Alle Dateien im Inhaltsordner (rekursiv), ordner-relativ, ohne [_ausgenommen].
Map<String, String> _ordner() {
  final wurzel = Directory('$repoWurzel/$kammerInhaltOrdner');
  final dateien = <String, String>{};
  for (final e in wurzel.listSync(recursive: true)) {
    if (e is! File) continue;
    final name = e.path.substring(wurzel.path.length + 1).replaceAll(r'\', '/');
    if (_ausgenommen.contains(name)) continue;
    dateien[name] = e.readAsStringSync();
  }
  return dateien;
}

/// Ist [s] ein unfertiger Text: beginnt (ohne Rand) mit „OFFEN“ oder enthält „OFFENE FRAGE“?
bool _unfertig(String s) => s.trimLeft().startsWith('OFFEN') || s.contains('OFFENE FRAGE');

/// „datei: pfad“ jedes unfertigen Strings (Schlüssel oder Wert) in [v].
List<String> _funde(String datei, Object? v, [String pfad = r'$']) {
  final funde = <String>[];
  if (v is String) {
    if (_unfertig(v)) funde.add('$datei: $pfad');
  } else if (v is List) {
    for (var i = 0; i < v.length; i++) {
      funde.addAll(_funde(datei, v[i], '$pfad[$i]'));
    }
  } else if (v is Map) {
    for (final e in v.entries) {
      final k = '${e.key}';
      if (_unfertig(k)) funde.add('$datei: $pfad (Schlüssel „$k“)');
      funde.addAll(_funde(datei, e.value, '$pfad.$k'));
    }
  }
  return funde;
}

/// Funde in allen [dateien] (Name → Inhalt). JSON-Dateien Schlüssel und Werte, andere Dateien zeilenweise.
List<String> _fundeIn(Map<String, Object?> dateien) {
  final funde = <String>[];
  for (final e in dateien.entries) {
    final v = e.value;
    if (e.key.endsWith('.json')) {
      funde.addAll(_funde(e.key, v is String ? jsonDecode(v) : v));
    } else if (v is String) {
      final zeilen = const LineSplitter().convert(v);
      for (var i = 0; i < zeilen.length; i++) {
        if (_unfertig(zeilen[i])) funde.add('${e.key}: Zeile ${i + 1}');
      }
    }
  }
  return funde;
}

/// Frische, veränderbare Kopie der Inhaltsdateien des Laders.
Map<String, Map<String, Object?>> _kopie() => {
      for (final e in leseKammerDateien(repoWurzel).entries) e.key: jsonDecode(e.value) as Map<String, Object?>,
    };

void main() {
  test('der Lader findet keine OFFEN-Felder (KammerInhalt.offeneFelder ist leer)', () {
    final inhalt = ladeKammerInhalt(repoWurzel);
    expect(inhalt.offeneFelder, isEmpty);
  });

  test('der Inhaltsordner enthält alle Dateien des Laders', () {
    final ordner = _ordner();
    for (final d in kammerInhaltDateien) {
      expect(ordner.containsKey(d), isTrue, reason: d);
    }
  });

  test('kein String im Inhalt beginnt mit „OFFEN“ oder enthält „OFFENE FRAGE“ (außer SCHEMA.md, textregeln.json)', () {
    final funde = _fundeIn(_ordner());
    expect(funde, isEmpty, reason: funde.join('\n'));
  });

  group('Rot-Proben', () {
    test('ein OFFEN-Feld erkennen Lader und Suche mit Datei und Pfad', () {
      final k = _kopie();
      ((k['rollen/05-lejla.json']!['stufe1'] as Map)['sagstDuJedem'] as List)[0] = 'OFFEN: ZG 1 Stufe 1 „Das sagst du jedem“';
      final inhalt = KammerInhalt.ausJson(k);
      expect(inhalt.offeneFelder, [startsWith('rollen/05-lejla.json: stufe1.sagstDuJedem')]);
      expect(_fundeIn(k), [r'rollen/05-lejla.json: $.stufe1.sagstDuJedem[0]']);
    });

    test('„OFFENE FRAGE“ mitten im Text, OFFEN mit Rand und als Schlüssel', () {
      final k = _kopie();
      final a = k['aufloesung.json']!;
      a['wasWirklichWar'] = '${a['wasWirklichWar']} OFFENE FRAGE: Wer war es?';
      (a['zeitleiste'] as List)[1] = {'zeit': '  OFFEN', 'text': 'x'};
      final g = k['gemeinsam.json']!;
      g['OFFEN'] = 'x';
      expect(_fundeIn(k), unorderedEquals([
        r'aufloesung.json: $.wasWirklichWar',
        r'aufloesung.json: $.zeitleiste[1].zeit',
        r'gemeinsam.json: $ (Schlüssel „OFFEN“)',
      ]));
      // Der Lader sieht „OFFENE FRAGE“ in der Mitte nicht als OFFEN-Feld; erst die Suche fängt sie.
      g.remove('OFFEN');
      (a['zeitleiste'] as List)[1] = {'zeit': '23:50', 'text': 'x'};
      expect(KammerInhalt.ausJson(k).offeneFelder, isEmpty);
      expect(_fundeIn(k), [r'aufloesung.json: $.wasWirklichWar']);
    });

    test('auch Dateien, die der Lader nicht liest, und Textdateien werden durchsucht', () {
      final dateien = <String, Object?>{
        'notizen/entwurf.json': {'zeilen': ['fertig', 'OFFEN: ZR 7.4']},
        'liesmich.txt': 'Erste Zeile\nOFFENE FRAGE zur Uhrzeit\n',
        'gut.json': {'text': 'Offen, dass er Tee ausschenkt.'},
      };
      expect(_fundeIn(dateien), unorderedEquals([
        r'notizen/entwurf.json: $.zeilen[1]',
        'liesmich.txt: Zeile 2',
      ]));
    });

    test('„Offen“ in normaler Schreibung ist kein Fund', () {
      expect(_unfertig('Offen, dass er Tee ausschenkt; den Vorwurf behält er für sich'), isFalse);
      expect(_unfertig('offen'), isFalse);
      expect(_unfertig('Die Tür steht OFFEN.'), isFalse);
      expect(_unfertig('OFFEN: MECH 8.3'), isTrue);
    });
  });
}
