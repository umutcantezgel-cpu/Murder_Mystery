// Druckpaket: Bild und Text der Schlosskeller-Figuren passen zusammen. Brille, Bart, Schal,
// Krawatte, Kopftuch, Kappe, Dutt, Hut und genannte Frisuren der gezeichneten Büste (im Spiel
// und im Druck derselbe Zeichner) stimmen mit Kostümtipp, Alltag und Aussehen der Figur.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte/game/scene/figure_painter.dart';
import 'package:mordakte_core/mordakte_core.dart';

import 'portraet_merkmale.dart';

void main() {
  final json = jsonDecode(File('content/party/schlosskeller/figuren.json').readAsStringSync()) as Map<String, dynamic>;
  final kostuem = {
    for (final e in (jsonDecode(File('content/party/schlosskeller/steckbriefe.json').readAsStringSync())['eintraege'] as List))
      (e as Map)['figur'] as String: e['kostuem'] as String,
  };
  final detektiv = (json['detektiv'] as Map).cast<String, Object?>();
  final figuren = [for (final f in json['figuren'] as List) (f as Map).cast<String, Object?>()];

  test('jede Figur: die Büste zeigt, was der Text sagt, und nichts Auffälliges, das er nicht sagt', () {
    final befunde = [
      for (final f in figuren)
        for (final w in widersprueche(aussehenAus(FigureLook.fromLook(LookDef.fromJson(renderLook(f)))), aussehenText(f, kostuem[f['id']])))
          '${f['id']}: $w',
      for (final g in ['w', 'm'])
        for (final w in widersprueche(aussehenAus(FigureLook.fromLook(detektivLook(detektiv, g))), aussehenText(detektiv, kostuem['detective'])))
          'detektiv-$g: $w',
    ];
    expect(befunde, isEmpty, reason: befunde.join('\n'));
  });

  test('Rot-Probe: Eine Brille im Text ohne Brille im Bild und ein Bart im Bild ohne Text fallen auf', () {
    final ahmet = figuren.firstWhere((f) => f['id'] == 'ahmet');
    final a = aussehenAus(FigureLook.fromLook(LookDef.fromJson(renderLook(ahmet))));
    expect(a.brille, isTrue);
    expect(widersprueche(a, 'Schwarzer Pulli'), containsAll(['Bild mit Brille, Text ohne', 'Bild mit Bart, Text ohne']));
    final can = figuren.firstWhere((f) => f['id'] == 'can');
    expect(widersprueche(aussehenAus(FigureLook.fromLook(LookDef.fromJson(renderLook(can)))), 'Brille und kurzer Bart'),
        containsAll(['Text mit Brille, Bild ohne', 'Text mit Bart, Bild ohne']));
  });

  test('der Detektiv (m) im Druck ist die Figur des Spiels', () {
    final spiel = aussehenAus(FigureLook.fromLook(LookDef.fromJson(renderLook(detektiv))));
    final druck = aussehenAus(FigureLook.fromLook(detektivLook(detektiv, 'm')));
    expect(druck.variante, spiel.variante);
    expect(merkmale(druck), merkmale(spiel));
  });
}
