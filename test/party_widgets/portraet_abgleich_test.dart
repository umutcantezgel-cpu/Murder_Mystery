// Druckpaket: Bild und Text der Schlosskeller-Figuren passen zusammen. Brille, Bart, Schal,
// Krawatte, Kopftuch, Kappe, Dutt, Hut und genannte Frisuren der gezeichneten Büste (im Spiel
// und im Druck derselbe Zeichner) stimmen mit Kostümtipp, Alltag und Aussehen der Figur.
//
// Protokoll des Abgleichs (Druckpaket P1; Bilder angesehen). Behoben über minimal verschobene
// Haut-/Haarfarben in figuren.json (±1–3 je Kanal), Spiel und Druck zeigen dasselbe:
//   Brille fehlte trotz Text: Ahmet, Wojtek, Detektiv  →  jetzt mit Brille
//   Brille ohne Text: Can, Tim, Zeynep, Baran           →  ohne
//   Bart ohne Text: Marek, Baran, Wojtek, Damir, Pawel  →  ohne (nur Ahmet trägt den kurzen Bart)
//   Krawatte ohne Text: Ahmet, Olli, Can, Tim, Marek, Baran, Damir, Detektiv  →  offener Kragen
//   Schal ohne Text: Joanna, Serkan, Azra, Damir        →  ohne
//   Frisur laut Text: Tim Locken, Azra lange Haare       →  so gezeichnet
//   Detektivin (nur im Druck; das Spiel kennt eine Detektivfigur): Zopf verschwand unter dem Hut,
//   die Büste wirkte männlich  →  lange Haare unter dem Hut (siehe detektivLook)
// Kleine Requisiten aus den Texten (Stirnlampe, Armband, Pfeife, Notizbuch …) zeichnet die Büste
// nicht; das ist kein Widerspruch, sie fehlen nur im Bild.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte/game/scene/figur_rig.dart';
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

  test('die Detektivin ist erkennbar eine Frau: lange Haare unter dem Hut, kein Bart, Brille wie im Text', () {
    final w = aussehenAus(FigureLook.fromLook(detektivLook(detektiv, 'w')));
    expect(w.weiblich, isTrue);
    expect(w.frisur, Frisur.lang);
    expect(w.bart, 0);
    expect(w.brille, isTrue);
    // Rot-Probe: Mit der Haarfarbe des Kanons fiele der Zopf unter den Hut, die Büste wirkte männlich.
    final ohne = aussehenAus(FigureLook.fromLook(LookDef.fromJson({...renderLook(detektiv), 'gender': 'w'})));
    expect(ohne.frisur, isNot(Frisur.lang));
  });

  test('der Detektiv (m) im Druck ist die Figur des Spiels', () {
    final spiel = aussehenAus(FigureLook.fromLook(LookDef.fromJson(renderLook(detektiv))));
    final druck = aussehenAus(FigureLook.fromLook(detektivLook(detektiv, 'm')));
    expect(druck.variante, spiel.variante);
    expect(merkmale(druck), merkmale(spiel));
  });
}
