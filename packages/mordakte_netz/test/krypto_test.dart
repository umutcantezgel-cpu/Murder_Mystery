import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart' show sha256;
import 'package:mordakte_netz/mordakte_netz.dart';
import 'package:test/test.dart';

// RFC 7748 §6.1 (Alice = Gast, Bob = Gastgeber). Öffentliche Werte, Gemeinsames
// Geheimnis und die HKDF-Ergebnisse sind außerhalb von Dart nachgerechnet
// (OpenSSL für X25519, Python für HKDF-SHA256 mit Salz = Code).
const _alicePriv = '77076d0a7318a57d3c16c17251b26645df4c2f87ebc0992ab177fba51db92c2a';
const _alicePub = '8520f0098930a754748b7ddcb43ef75a0dbf3a0d26381af4eba4a98eaa9b4e6a';
const _bobPub = 'de9edb7d7b7dc1b4d35b61c2ece435373f8343c85b78674dadfc7e146f882b4f';

List<int> _hex(String h) => [for (var i = 0; i < h.length; i += 2) int.parse(h.substring(i, i + 2), radix: 16)];

Future<List<List<int>>> _roh(Sitzungsschluessel s) async => [await s.hostZuGast.extractBytes(), await s.gastZuHost.extractBytes()];

Future<Sitzungsschluessel> _ableiten(Schluesselpaar eigen, List<int> fremd, {String code = 'AYYEHJ', int epoch = 1, String cid = 'gagjzfqdxevewopn'}) =>
    Sitzungsschluessel.ableiten(eigen: eigen, fremdOeffentlich: fremd, code: code, epoch: epoch, cid: cid);

void main() {
  group('Raumcode', () {
    test('Alphabet und Länge', () {
      expect(raumCodeAlphabet, 'ACDEFHJKLMNPRTUVWXY3479');
      expect(raumCodeLaenge, 6);
    });

    test('Bekannter Wert: Gastgeber Bob ergibt AYYEHJ', () {
      expect(RaumCode.ausSchluessel(_hex(_bobPub)), 'AYYEHJ');
    });

    test('jeder Code ist 6 Zeichen aus dem Alphabet und folgt dem Schlüssel', () async {
      final r = Random(5);
      for (var i = 0; i < 40; i++) {
        final h = await Schluesselpaar.erzeugen(r);
        expect(h.raumCode, matches(RegExp(r'^[ACDEFHJKLMNPRTUVWXY3479]{6}$')));
        expect(RaumCode.ausSchluessel(h.oeffentlich), h.raumCode);
      }
    });

    test('passt bindet den Code an genau einen Gastgeberschlüssel', () async {
      final host = await Schluesselpaar.erzeugen(Random(1));
      final fremd = await Schluesselpaar.erzeugen(Random(2));
      expect(RaumCode.passt(host.raumCode, host.oeffentlich), isTrue);
      expect(RaumCode.passt(host.raumCode, fremd.oeffentlich), isFalse);
      expect(RaumCode.passt(fremd.raumCode, host.oeffentlich), isFalse);
    });

    test('lesen normalisiert Groß-/Kleinschreibung, Trennzeichen und Leerraum', () {
      expect(RaumCode.lesen('acdef-h'), 'ACDEFH');
      expect(RaumCode.lesen(' a c-d e f h '), 'ACDEFH');
      expect(RaumCode.lesen('ACD EFH'), 'ACDEFH');
      expect(RaumCode.lesen('ayy-ehj'), 'AYYEHJ');
    });

    test('lesen lehnt falsche Länge und Zeichen außerhalb des Alphabets ab', () {
      for (final f in ['', 'ACDEF', 'ACDEFHJ', 'ACDEF0', 'ACDEFO', 'ACDEFI', 'ACDEFB', 'ACDEFS']) {
        expect(RaumCode.lesen(f), isNull, reason: 'Eingabe "$f"');
      }
    });
  });

  group('Kennung (cid) und base32', () {
    test('bekannte Werte für Alice und Bob (16 Zeichen, klein)', () {
      expect(cidVon(_hex(_alicePub)), 'gagjzfqdxevewopn');
      expect(cidVon(_hex(_bobPub)), '6npfmfqwbiyl6pdo');
    });

    test('ein Gastschlüssel hat genau die Kennung seines öffentlichen Schlüssels', () async {
      final g = await Schluesselpaar.erzeugen(Random(9));
      expect(g.cid, cidVon(g.oeffentlich));
      expect(g.cid, base32Klein(sha256.convert(g.oeffentlich).bytes).substring(0, 16));
      expect(istCid(g.cid), isTrue);
    });

    test('istCid akzeptiert nur die Form [a-z2-7]{16}', () {
      expect(istCid('gagjzfqdxevewopn'), isTrue);
      expect(istCid('gagjzfqdxevewop'), isFalse); // 15 Zeichen
      expect(istCid('gagjzfqdxevewopn0'), isFalse); // 17 Zeichen, '0' nicht in base32
      expect(istCid('GAGJZFQDXEVEWOPN'), isFalse);
      expect(istCid(null), isFalse);
    });

    test('base32 nach RFC 4648 ohne Auffüllung, klein', () {
      expect(base32Klein(utf8.encode('foobar')), 'mzxw6ytboi');
      expect(base32Klein(utf8.encode('fo')), 'mzxq');
      expect(base32Klein(utf8.encode('f')), 'my');
    });
  });

  group('Sitzungsschlüssel', () {
    test('X25519-Schlüssel aus RFC 7748 und abgeleitete Richtungsschlüssel stimmen mit der Referenz überein', () async {
      final gast = await Schluesselpaar.ausGeheimnis(_hex(_alicePriv));
      expect(gast.oeffentlich, _hex(_alicePub));
      final s = await _ableiten(gast, _hex(_bobPub));
      final r = await _roh(s);
      expect(r[0], _hex('d4f4242709436aaf7d13a0fe2879a6040150d1975a719fb4c8f73d4e072206ec'));
      expect(r[1], _hex('9785c0c5688b4c45906fb1902c589e61cf472509ad2659640823187e5f56c367'));
    });

    test('Gastgeber und Gast leiten dieselben Schlüssel ab', () async {
      final host = await Schluesselpaar.erzeugen(Random(3));
      final gast = await Schluesselpaar.erzeugen(Random(4));
      final a = await Sitzungsschluessel.ableiten(eigen: host, fremdOeffentlich: gast.oeffentlich, code: host.raumCode, epoch: 1, cid: gast.cid);
      final b = await Sitzungsschluessel.ableiten(eigen: gast, fremdOeffentlich: host.oeffentlich, code: host.raumCode, epoch: 1, cid: gast.cid);
      expect(await _roh(a), await _roh(b));
    });

    test('h2c und c2h unterscheiden sich; Epoche, Kennung und Code gehen ein', () async {
      final host = await Schluesselpaar.erzeugen(Random(3));
      final gast = await Schluesselpaar.erzeugen(Random(4));
      final basis = await _roh(await _ableiten(host, gast.oeffentlich));
      expect(basis[0], isNot(equals(basis[1])), reason: 'h2c == c2h');
      for (final anders in [
        _ableiten(host, gast.oeffentlich, epoch: 2),
        _ableiten(host, gast.oeffentlich, cid: 'aaaaaaaaaaaaaaaa'),
        _ableiten(host, gast.oeffentlich, code: 'ACDEFH'),
      ]) {
        final r = await _roh(await anders);
        expect(r[0], isNot(equals(basis[0])));
        expect(r[1], isNot(equals(basis[1])));
      }
    });

    test('Punkt kleiner Ordnung und falsche Länge werfen FormatException', () async {
      final host = await Schluesselpaar.erzeugen(Random(3));
      final kaputt = <List<int>>[
        List.filled(32, 0), // u = 0
        [1, ...List.filled(31, 0)], // u = 1
        List.filled(31, 7), // zu kurz
        List.filled(33, 7), // zu lang
      ];
      for (final k in kaputt) {
        await expectLater(_ableiten(host, k), throwsA(isA<FormatException>()), reason: 'Länge ${k.length}, erstes Byte ${k[0]}');
      }
    });
  });
}
