// Ziele der Erzählerakte aus der Einfluss-Schicht (Finale §2, §3.9): je Figur die zwei Sterne aus
// einfluss.json mit ihren Kartentexten einfluss.ziel.<figur>.<nr>; ohne Schicht das persönliche Ziel.
// Die Quelle kennt weder Pfad noch Täter (wie einfluss.dart).
import 'dart:io';

import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/runden.dart';
import 'package:test/test.dart';

import '../party/einstimmung_hilfe.dart' show erzaehlerakteFixture;
import '../party/kanon_hilfe.dart';
import 'einfluss_hilfe.dart';

/// Texte des Schlosskellers mit [zusatz] als Datei im Bereich `einfluss`.
Texte _texte(Map<String, String> zusatz) {
  final ordner = '$repoWurzel/content/party/schlosskeller';
  final index = leseJson('$ordner/texte/index.json');
  return Texte(
    kanon,
    Textsammlung.lade((p) {
      if (p == 'texte/index.json') {
        return {
          ...index,
          'dateien': [...index['dateien'] as List, {'datei': 'einfluss-ziele-probe.json', 'bereich': 'einfluss'}],
        };
      }
      if (p == 'texte/einfluss-ziele-probe.json') {
        return {
          'settingId': kanon.settingId,
          'bereich': 'einfluss',
          'hinweis': 'Fixture',
          'eintraege': [for (final e in zusatz.entries) {'id': e.key, 'text': e.value}],
        };
      }
      return leseJson('$ordner/$p');
    }),
  );
}

void main() {
  final r = einflussRegeln;
  final ziele = {for (final f in r.figuren) for (final nr in [1, 2]) 'einfluss.ziel.$f.$nr': 'Stern $nr von @figur'};
  final texte = _texte(ziele);

  test('je Figur zwei Sterne in ihrer Reihenfolge: Kennung aus einfluss.json, Text aus einfluss.ziel.<figur>.<nr>', () {
    final q = EinflussZielQuelle(r, texte);
    expect(r.figuren, hasLength(20));
    for (final f in r.figuren) {
      final l = q.zieleVon(f);
      expect([for (final z in l) z.id], [for (final z in r.ziele[f]!) z.id], reason: f);
      expect([for (final z in l) z.text], [for (final nr in [1, 2]) texte.einflussText('einfluss.ziel.$f.$nr', figur: f)], reason: f);
      for (final z in l) {
        expect(z.text, isNot(contains('@')), reason: f);
      }
    }
    expect(q.zieleVon('detective'), isEmpty);
  });

  test('die Erzählerakte zeigt mit der Quelle die Sterne statt des persönlichen Ziels', () {
    final ohne = Erzaehlerakte.ausJson(erzaehlerakteFixture(), kanon);
    final mit = Erzaehlerakte.ausJson(erzaehlerakteFixture(), kanon, ziele: EinflussZielQuelle(r, texte));
    for (final f in mit.figuren) {
      expect(mit.figur(f.figur)!.ziele, hasLength(2), reason: f.figur);
      expect([for (final z in mit.figur(f.figur)!.ziele) z.id], isNot(contains('persoenlichesZiel')), reason: f.figur);
      expect([for (final z in ohne.figur(f.figur)!.ziele) z.id], everyElement('persoenlichesZiel'), reason: f.figur);
    }
  });

  test('ein fehlender Kartentext ist ein Fehler wie überall (F-11)', () {
    final luecke = _texte({...ziele}..remove('einfluss.ziel.ahmet.2'));
    if (luecke.sammlung.bausteine.containsKey('einfluss.ziel.ahmet.2')) return; // die echten Texte sind eingespielt
    expect(() => EinflussZielQuelle(r, luecke).zieleVon('ahmet'), throwsArgumentError);
  });

  test('Architektur: die Quelle nennt weder Pfad noch Täter noch Qualität noch FallCode', () {
    final quelle = File('$repoWurzel/packages/mordakte_core/lib/src/runden/einfluss_zielquelle.dart').readAsStringSync();
    expect([for (final m in RegExp(r'pfad|taeter|täter|qualit', caseSensitive: false).allMatches(quelle)) m[0]], isEmpty);
    expect(quelle.contains('FallCode'), isFalse);
  });
}
