// F-11/F-16 (F6-TEST-01): Kein Spielertext außerhalb des Kanons. Bildschirme
// (lib/party) und Druckteile (druck/*) holen jeden sichtbaren Satz aus
// Bausteinen oder Kanon-Daten; im Code stehen nur Kennungen, Formate und
// technische Werte.
import 'dart:io';

import 'package:test/test.dart';

import 'kanon_hilfe.dart';

/// Zeichenketten-Literale einer Zeile (einfache und doppelte Anführungszeichen).
final _literal = RegExp(r"'((?:[^'\\]|\\.)*)'" r'|"((?:[^"\\]|\\.)*)"');

/// Zeilen, deren Literale nie Spielern gezeigt werden.
final _technischeZeile = RegExp(r'^\s*(import|export|part|//)|debugPrint\(|throw |Error\(|assert\(|RegExp\(|\.startsWith\(|\.endsWith\(|\.split\(|\.replaceAll\(|Uri\.|@JS\(|neuesDokument\(|\bwo: ');

/// Ein Literal ist verdächtig, wenn es Wörter mit Leerzeichen enthält oder
/// ein großgeschriebenes Wort ist (Knopfbeschriftung) – Kennungen, Pfade,
/// Formate und Interpolationen ohne eigenen Text sind erlaubt.
bool _sichtbar(String s) {
  // Bruchstück einer Interpolation mit inneren Anführungszeichen: kein eigener Text.
  if (s.contains(r'${') && !s.contains('}')) return false;
  final ohne = s.replaceAll(RegExp(r'\$\{[^}]*\}|\$[A-Za-z_][A-Za-z0-9_]*'), ' ').trim();
  if (!RegExp(r'[A-Za-zÄÖÜäöüß]{3,}').hasMatch(ohne)) return false;
  if (RegExp(r'^[a-z0-9_.\-/{}<>]+$').hasMatch(ohne)) return false; // Kennung, Schlüssel, Pfad, Dateiname
  if (RegExp(r'^[a-z][A-Za-z0-9]*$').hasMatch(ohne)) return false; // Bezeichner
  if (RegExp(r'^[A-Za-z0-9_\-/]+\.(ttf|otf|png|json|pdf)$').hasMatch(ohne)) return false; // Dateiname
  return RegExp(r'[A-Za-zÄÖÜäöüß]{2,}\s+[A-Za-zÄÖÜäöüß]{2,}').hasMatch(ohne) || RegExp(r'^[A-ZÄÖÜ][a-zäöüß]{2,}').hasMatch(ohne);
}

/// Erlaubte Literale mit Begründung (technische Namen, kein Spielertext).
const _erlaubt = {
  'Inter': 'Schriftname',
  'SpecialElite': 'Schriftname',
  'Mordakte Partymodus': 'PDF-Metadatum Autor, nicht sichtbar',
  'AbortError': 'Name des Browser-Fehlers, wenn das Teilen-Fenster abgebrochen wird (druck_speichern_web.dart)',
};

Iterable<File> _dartDateien(String ordner) => Directory(ordner)
    .listSync(recursive: true)
    .whereType<File>()
    .where((f) => f.path.endsWith('.dart'));

/// Fundstellen „Datei:Zeile: 'Text'“ in [dateien].
List<String> funde(Iterable<File> dateien) {
  final f = <String>[];
  for (final d in dateien) {
    final zeilen = d.readAsLinesSync();
    for (var i = 0; i < zeilen.length; i++) {
      final z = zeilen[i];
      if (_technischeZeile.hasMatch(z) || z.trimLeft().startsWith('///')) continue;
      for (final m in _literal.allMatches(z)) {
        final s = m.group(1) ?? m.group(2) ?? '';
        if (_erlaubt.containsKey(s)) continue;
        if (_sichtbar(s)) f.add("${d.path.replaceFirst('$repoWurzel/', '')}:${i + 1}: '$s'");
      }
    }
  }
  return f;
}

void main() {
  test('Bildschirme des Partymodus enthalten keinen Spielertext im Code', () {
    final f = funde(_dartDateien('$repoWurzel/lib/party'));
    expect(f, isEmpty, reason: f.join('\n'));
  });

  test('Druckteile enthalten keinen Spielertext im Code', () {
    final f = funde(_dartDateien('$repoWurzel/packages/mordakte_core/lib/src/party/druck'));
    expect(f, isEmpty, reason: f.join('\n'));
  });

  test('Rot-Probe: ein Satz im Code wird gefunden, Kennungen nicht', () {
    final dir = Directory.systemTemp.createTempSync('story_text');
    try {
      final datei = File('${dir.path}/probe.dart')
        ..writeAsStringSync("""
final a = sitzung.ui('ui.karte.weiter');
final b = Text('Geh jetzt zur Theke');
final c = PartyKnopf(text: 'Weiter');
final d = '\${x}';
final e = load('Inter-Bold.ttf');
""");
      final f = funde([datei]);
      expect(f, hasLength(2), reason: f.join('\n'));
    } finally {
      dir.deleteSync(recursive: true);
    }
  });
}
