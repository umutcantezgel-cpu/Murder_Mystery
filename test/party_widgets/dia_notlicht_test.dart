// M7b: Bild 2 der Diashow (der Stromausfall im Vorratsraum) ist heller und
// zeigt Herrn Schneider. Das Bild hat Notlicht (DiaStimmung.notlicht) statt
// des dunklen Stromausfalls, und der unsichtbare Detektiv steht am Ziel der
// Kamera: Der Renderer schneidet dann die Wand vor dem Vorratsraum auf. Bild 6
// (der Auftrag im Dunkel) bleibt, wie es war.
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flame/game.dart' show Vector2;
import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte/game/mordakte_game.dart';
import 'package:mordakte/party/dia_session.dart';
import 'package:mordakte_core/mordakte_core.dart';

import 'luminanz.dart';
import 'rundgang_hilfe.dart';

const _groesse = Size(600, 400);

/// So viele Pixel ändert Herr Schneider mindestens, wenn er zu sehen ist.
const _figurPixelMin = 200;

Map<String, Object?> _json() => jsonDecode(File('content/welt/schlosskeller/diashow.json').readAsStringSync()) as Map<String, Object?>;

/// Die Diashow der Akte, Bild [nr] mit [aendern] verändert.
Diashow _show({int nr = 1, void Function(Map<String, Object?> dia)? aendern}) {
  final j = _json();
  aendern?.call(((j['dias'] as List)[nr] as Map).cast<String, Object?>());
  return Diashow.ausJson(j);
}

/// Szene für Bild [nr] von [show], ruhig (kein Flackern, keine Fahrt).
DiaSession _szene(Diashow show, int nr) {
  final s = DiaSession(rundgangDaten, show, nr: nr, testUhr: () => 0)..bewegungReduziert = true;
  addTearDown(s.dispose);
  return s;
}

/// Zeichnet [s] zwei Sekunden lang Bild für Bild, bis Kamera, Wandschnitt
/// und Überblendung ruhen, und liefert das letzte Bild (RGBA) samt dem Renderer.
Future<(ByteData, MordakteGame)> _bild(DiaSession s) async {
  final game = MordakteGame(session: s)..onGameResize(Vector2(_groesse.width, _groesse.height));
  addTearDown(game.dispose);
  for (var i = 0; i < 120; i++) {
    game.update(1 / 60);
    final r = PictureRecorder();
    game.render(Canvas(r));
    r.endRecording().dispose();
  }
  final rec = PictureRecorder();
  game.render(Canvas(rec));
  final bild = await rec.endRecording().toImage(_groesse.width.round(), _groesse.height.round());
  final roh = (await bild.toByteData())!;
  bild.dispose();
  return (roh, game);
}

/// Wo der (unsichtbare) Detektiv der Szene [s] steht, laut ihrem Weltzustand.
Offset _detektiv(DiaSession s) {
  final d = s.world.value!.detectives.single;
  return Offset(d.x, d.y);
}

double _luminanz(ByteData roh) => mittlereLuminanz(roh, _groesse.width.round(), _groesse.height.round(), Offset.zero & _groesse);

/// Zahl der Pixel im Ausschnitt [r], die sich zwischen [a] und [b] deutlich unterscheiden.
int _unterschied(ByteData a, ByteData b, Rect r) {
  final breite = _groesse.width.round();
  var n = 0;
  for (var y = r.top.floor(); y < r.bottom.ceil(); y++) {
    for (var x = r.left.floor(); x < r.right.ceil(); x++) {
      final i = (y * breite + x) * 4;
      final d = (a.getUint8(i) - b.getUint8(i)).abs() + (a.getUint8(i + 1) - b.getUint8(i + 1)).abs() + (a.getUint8(i + 2) - b.getUint8(i + 2)).abs();
      if (d > 30) n++;
    }
  }
  return n;
}

/// Bildausschnitt um die einzige Figur von [s]: ihre Kachel, knapp, mit etwas
/// Platz nach oben. Die Tür daneben (sie geht auf, wenn jemand nahe steht)
/// liegt außerhalb.
Rect _umFigur(MordakteGame game, DiaSession s) {
  final n = s.figurenAnsicht().npcs.single;
  const r = 0.4;
  final links = game.worldToScreen(n.x - r, n.y + r), rechts = game.worldToScreen(n.x + r, n.y - r);
  final oben = game.worldToScreen(n.x - r, n.y - r, 0.5), unten = game.worldToScreen(n.x + r, n.y + r);
  return Rect.fromLTRB(links.dx, oben.dy, rechts.dx, unten.dy);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Inhalt: Bild 2 hat Notlicht, Bild 6 bleibt im Dunkel des Stromausfalls; der Prüfer ist ohne Befund', () {
    final show = rundgangDaten.diashow!;
    expect([show.dias[1].stimmung, show.dias[1].figuren, show.dias[1].liegt], [DiaStimmung.notlicht, ['schneider'], ['schneider']]);
    expect(show.dias[5].stimmung, DiaStimmung.stromausfall);
    final d = rundgangDaten;
    expect(pruefeDiashow(show, d.kanon, (k) => d.texte.sammlung.bausteine[k]), isEmpty);
  });

  test('Der unsichtbare Detektiv steht am Ziel jedes Bildes; in Bild 6 dort, wo er immer stand', () {
    final show = rundgangDaten.diashow!;
    final s = _szene(show, 0);
    final graph = rundgangDaten.kanon.graph;
    for (var i = 0; i < show.dias.length; i++) {
      s.zeige(i);
      expect(_detektiv(s), s.ziel, reason: 'Bild ${i + 1}');
    }
    // Bild 2: im Vorratsraum, hinter der Wand y = 6.
    s.zeige(1);
    expect(graph.raumAn(_detektiv(s).dx, _detektiv(s).dy)?.id, 'vorratsraum');
    // Bild 6: Ziel ist der Ermittlungsort des Detektivs, also bleibt alles wie bisher.
    s.zeige(5);
    final kanon = rundgangDaten.kanon;
    final ort = graph.orte[kanon.figur((kanon.figurenJson['detektiv'] as Map)['id'] as String)!['ermittlungsOrt'] as String]!;
    expect(_detektiv(s), Offset(ort.x, ort.y));
  });

  test('Licht: Notlicht ist heller als der Stromausfall; der Stromausfall (Bild 6) bleibt wie vor M7b', () {
    final show = rundgangDaten.diashow!;
    final s = _szene(show, 1);
    final not = s.licht!;
    expect([not.dunkel, not.taschenlampe, not.tag], [DiaSession.notlichtDunkel, false, false]);
    expect(not.dunkel, lessThan(0.8));
    expect(not.punkte.map((p) => p.radius).reduce((a, b) => a > b ? a : b), greaterThan(2.6), reason: 'Der Kegel ist größer als der Schein im Stromausfall');
    s.zeige(5);
    final aus = s.licht!;
    final z = s.ziel;
    expect([aus.dunkel, aus.taschenlampe, aus.helleRaeume, aus.punkte.length], [0.8, false, isEmpty, 2]);
    final schein = aus.punkte.last;
    expect([schein.x, schein.y, schein.z, schein.radius, schein.flackern], [z.dx, z.dy, 1.4, 2.6, 0]);
  });

  test('Im Bild: Bild 2 ist deutlich heller als mit dem alten Stromausfall, und Herr Schneider ist zu sehen', () async {
    final szene = _szene(_show(), 1);
    final (neu, game) = await _bild(szene);
    final (alt, _) = await _bild(_szene(_show(aendern: (d) => d['stimmung'] = 'stromausfall'), 1));
    final (leer, _) = await _bild(_szene(_show(aendern: (d) => d..['figuren'] = <String>[]..['liegt'] = <String>[]), 1));
    final hell = _luminanz(neu), dunkel = _luminanz(alt), figur = _unterschied(neu, leer, _umFigur(game, szene));
    // ignore: avoid_print
    print('Bild 2: Luminanz Notlicht ${hell.toStringAsFixed(4)}, Stromausfall ${dunkel.toStringAsFixed(4)}; Pixel der Figur $figur');
    expect(hell, greaterThan(dunkel * 1.4));
    expect(hell, lessThan(0.3), reason: 'Es bleibt Nacht ohne Strom');
    // Herr Schneider: Mit ihm sieht seine Stelle im Bild deutlich anders aus
    // als ohne ihn (hinter der ungeschnittenen Wand ändert sich dort nichts).
    expect(figur, greaterThan(_figurPixelMin));
    expect(game.spielerRaum, 'vorratsraum', reason: 'Der Renderer schneidet die Wände vor dem Raum des Bildes auf');
  });

  test('Im Bild: Bild 6 bleibt dunkel; der Spielerraum ist der Saal wie zuvor', () async {
    final (sechs, game) = await _bild(_szene(rundgangDaten.diashow!, 5));
    expect(game.spielerRaum, 'ost_saal');
    final (zwei, _) = await _bild(_szene(rundgangDaten.diashow!, 1));
    expect(_luminanz(sechs), lessThan(_luminanz(zwei)), reason: 'Notlicht nur in Bild 2');
  });
}
