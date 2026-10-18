// A-061 (K1.0): Der Schlosskeller-Kanon ist offen, die übrigen Akten bleiben bytegleich.
// Ihre aufgelösten Oberflächentexte (eigene ui-Texte plus eingefrorene Basis
// content/party/basis-ui) sind hier als Prüfsumme festgehalten.
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:mordakte_core/mordakte_core.dart';
import 'package:test/test.dart';

import 'kanon_hilfe.dart' show leseJson, repoWurzel;

/// Prüfsumme über alle `ui.*`-Bausteine, sortiert nach Kennung.
String uiPruefsumme(String akte) {
  final sammlung = Textsammlung.lade((f) => leseJson('$repoWurzel/content/party/$akte/$f'));
  sammlung.ergaenzeUi(Textsammlung.lade((f) => leseJson('$repoWurzel/content/party/basis-ui/$f')));
  final ui = sammlung.bausteine.entries.where((e) => e.key.startsWith('ui.')).toList()
    ..sort((a, b) => a.key.compareTo(b.key));
  return sha256.convert(utf8.encode(jsonEncode({for (final e in ui) e.key: e.value}))).toString();
}

const _soll = {
  'gewoelbe': 'b50b9d750936f123c7ed122798bffdad2bdedb00a6a4a5d19fe85728290b794f',
  'ravensmoor': 'ce99969a0a0f6aeeab7f0d10eef02232b1fd939c9a696db92da2d30aecd176ee',
  'nachtexpress': '78c2e666e602d3ebe43027399959e698692c73fbd83da50719c8757051b4e475',
  'blue_palm': '96f1cc63ada43ab7872ca0acd6a5c51c1079e93993bb9043e3546d140fa3bed8',
};

void main() {
  for (final e in _soll.entries) {
    test('ui-Texte von ${e.key} sind unverändert (A-061)', () {
      expect(uiPruefsumme(e.key), e.value,
          reason: 'Die ui-Texte der übrigen Akten bleiben bytegleich. Neue Texte gehören in die ARB oder in neue Dateien.');
    });
  }
}
