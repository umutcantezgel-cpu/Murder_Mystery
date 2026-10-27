// Finale Schlosskeller: Die Server-Fabrik lädt „Dein Moment“ nur mit der Fähigkeit `einfluss` der Akte
// (akten.json) und nur, wenn eingeschaltet; Einstimmung nur mit Vorgeschichte. Ohne bleibt der Raum wie bisher.
import 'dart:convert';
import 'dart:io';

import 'package:mordakte_server/party.dart';
import 'package:mordakte_server/runtime.dart' show RuntimeFactory;
import 'package:test/test.dart';

import '../tool/probe_inhalt.dart';

SchlosskellerRuntime _raum(RuntimeFactory f) => f('ABCDEF') as SchlosskellerRuntime;

void main() {
  final dir = resolvePartyDir(null);
  final akte = (jsonDecode(File('$dir/../akten.json').readAsStringSync())['akten'] as List).cast<Map>().firstWhere((a) => a['id'] == 'schlosskeller');
  final faehigkeiten = (akte['faehigkeiten'] as List?) ?? const [];

  test('Dein Moment nur mit Fähigkeit und eingeschaltet; die Lobby zeigt die Schicht', () {
    expect(_raum(loadSchlosskellerFactory(dir)).inner.einfluss, isNull);
    expect(_raum(loadSchlosskellerFactory(dir, einfluss: true)).inner.einfluss != null, faehigkeiten.contains('einfluss'),
        reason: 'ohne Fähigkeit der Akte keine Schicht');
    final probe = probeLeser(dir, einfluss: true);
    expect(_raum(loadSchlosskellerFactory(dir, lesen: probe)).inner.einfluss, isNull, reason: 'nicht eingeschaltet');
    final mit = _raum(loadSchlosskellerFactory(dir, einfluss: true, lesen: probe));
    expect(mit.inner.einfluss?.akte, 'schlosskeller');
    expect(mit.join('a', 'Anna'), isTrue);
    expect(mit.stateFor('a')!['einfluss'], {'runde': 0});
    final ohne = _raum(loadSchlosskellerFactory(dir));
    expect(ohne.join('a', 'Anna'), isTrue);
    expect(ohne.stateFor('a')!.containsKey('einfluss'), isFalse);
  });

  test('Einstimmung nur mit Vorgeschichte und eingeschaltet', () {
    expect(_raum(loadSchlosskellerFactory(dir, lesen: probeLeser(dir, einstimmung: true))).inner.einstimmung, isNull);
    expect(_raum(loadSchlosskellerFactory(dir, einstimmung: true, lesen: probeLeser(dir, einstimmung: true))).inner.einstimmung, isNotNull);
  });
}
