/// Schlüssel, Raumcode und Sitzungsschlüssel des Online-Spiels.
///
/// **Raumcode (an den Gastgeberschlüssel gebunden).** Der Code besteht aus 6
/// Zeichen des Alphabets [raumCodeAlphabet] (23 Zeichen ohne Verwechslungsgefahr).
/// Er entsteht aus den ersten 30 Bit von SHA-256("mordakte/raum/v1" ‖ hostPub),
/// gelesen als Zahl (große Bytes zuerst). Weil 23^6 = 148 035 889 zwischen
/// 2^27 und 2^28 liegt, passt der 30-Bit-Wert nicht in 6 Stellen. Darum gilt
/// `wert mod 23^6`, dargestellt als 6 Ziffern zur Basis 23 (höchste zuerst). Das
/// sind rund 27,1 Bit. Die leichte Schieflage durch `mod` ist ohne Bedeutung:
/// Der Code ist eine Bindung und kein Geheimnis. Gäste prüfen, dass
/// der vom Gastgeber gemeldete öffentliche Schlüssel zu ihrem Code hasht; damit
/// kann ein zufälliger Dritter im Relais sich nicht als Gastgeber ausgeben.
/// (Wer gezielt rund 150 Mio. Schlüssel durchprobiert, könnte einen passenden
/// finden; das ist ein bewusst akzeptiertes Restrisiko eines kurzen Codes.)
///
/// **Gast.** Jeder Gast erzeugt je Raum ein X25519-Schlüsselpaar. Seine Kennung
/// `cid` sind die ersten 16 Zeichen von base32(SHA-256(gastPub)) in
/// Kleinbuchstaben, die Spieler-ID im Raum ist `g_<cid>`. Das Paar liegt in
/// der [Ablage] und ist zugleich das Wiederverbindungs-Token.
///
/// **Sitzungsschlüssel.** HKDF-SHA256 über das X25519-Geheimnis, Salz = Code,
/// Info = `mordakte/v1|<epoch>|<cid>|h2c` bzw. `…|c2h`.
library;

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart' show sha256;
import 'package:cryptography/cryptography.dart';

const raumCodeAlphabet = 'ACDEFHJKLMNPRTUVWXY3479';
const raumCodeLaenge = 6;
const _basisHoch6 = 148035889; // 23^6

/// Raumcode: Ableitung, Eingabe lesen, Bindung prüfen.
abstract final class RaumCode {
  /// Der Code zum öffentlichen Gastgeberschlüssel [hostPub] (32 Bytes).
  static String ausSchluessel(List<int> hostPub) {
    final d = sha256.convert([...utf8.encode('mordakte/raum/v1'), ...hostPub]).bytes;
    final wert30 = (d[0] << 22) | (d[1] << 14) | (d[2] << 6) | (d[3] >> 2);
    var rest = wert30 % _basisHoch6;
    final z = List<String>.filled(raumCodeLaenge, 'A');
    for (var i = raumCodeLaenge - 1; i >= 0; i--) {
      z[i] = raumCodeAlphabet[rest % raumCodeAlphabet.length];
      rest ~/= raumCodeAlphabet.length;
    }
    return z.join();
  }

  /// Passt [hostPub] zu [code]?
  static bool passt(String code, List<int> hostPub) => ausSchluessel(hostPub) == code;

  /// Liest eine Eingabe (Groß-/Kleinschreibung, Leer- und Trennzeichen
  /// egal). `null`, wenn sie kein gültiger Code ist.
  static String? lesen(String eingabe) {
    final c = eingabe.toUpperCase().replaceAll(RegExp(r'[\s-]'), '');
    if (c.length != raumCodeLaenge) return null;
    for (final z in c.split('')) {
      if (!raumCodeAlphabet.contains(z)) return null;
    }
    return c;
  }
}

const _base32 = 'abcdefghijklmnopqrstuvwxyz234567';

/// base32 (RFC 4648, Kleinbuchstaben, ohne Auffüllung).
String base32Klein(List<int> bytes) {
  final out = StringBuffer();
  var puffer = 0, bits = 0;
  for (final b in bytes) {
    puffer = (puffer << 8) | b;
    bits += 8;
    while (bits >= 5) {
      out.write(_base32[(puffer >> (bits - 5)) & 31]);
      bits -= 5;
    }
    puffer &= (1 << bits) - 1;
  }
  if (bits > 0) out.write(_base32[(puffer << (5 - bits)) & 31]);
  return out.toString();
}

/// Kennung eines Gastes: 16 Zeichen base32 aus SHA-256 seines öffentlichen Schlüssels.
String cidVon(List<int> gastPub) => base32Klein(sha256.convert(gastPub).bytes).substring(0, 16);

final _cidMuster = RegExp(r'^[a-z2-7]{16}$');

/// Hat [cid] die Form einer Kennung?
bool istCid(Object? cid) => cid is String && _cidMuster.hasMatch(cid);

String b64(List<int> bytes) => base64Encode(bytes);

/// Dekodiert Base64; `null` bei ungültiger Eingabe.
Uint8List? unB64(Object? text) {
  if (text is! String) return null;
  try {
    return base64Decode(text);
  } on FormatException {
    return null;
  }
}

/// Zufällige Bytes aus dem sicheren Zufall des Systems (VM und Web).
Uint8List zufallsBytes(int n, [Random? zufall]) {
  final r = zufall ?? Random.secure();
  return Uint8List.fromList([for (var i = 0; i < n; i++) r.nextInt(256)]);
}

/// X25519-Schlüsselpaar (Gastgeber oder Gast).
class Schluesselpaar {
  Schluesselpaar._(this._paar, this.oeffentlich, this.geheim);

  final SimpleKeyPair _paar;

  /// Öffentlicher Schlüssel, 32 Bytes.
  final Uint8List oeffentlich;

  /// Geheimer Schlüssel (Seed), 32 Bytes. Nur in die [Ablage] des eigenen Geräts.
  final Uint8List geheim;

  static final _x25519 = X25519();

  static Future<Schluesselpaar> erzeugen([Random? zufall]) => ausGeheimnis(zufallsBytes(32, zufall));

  static Future<Schluesselpaar> ausGeheimnis(List<int> geheim) async {
    final paar = await _x25519.newKeyPairFromSeed(geheim);
    final pub = await paar.extractPublicKey();
    return Schluesselpaar._(paar, Uint8List.fromList(pub.bytes), Uint8List.fromList(geheim));
  }

  /// Raumcode, wenn dies der Gastgeberschlüssel ist.
  String get raumCode => RaumCode.ausSchluessel(oeffentlich);

  /// Kennung, wenn dies ein Gastschlüssel ist.
  String get cid => cidVon(oeffentlich);
}

/// Die beiden Richtungsschlüssel eines Sitzes.
class Sitzungsschluessel {
  const Sitzungsschluessel(this.hostZuGast, this.gastZuHost);

  final SecretKey hostZuGast;
  final SecretKey gastZuHost;

  static final _hkdf = Hkdf(hmac: Hmac.sha256(), outputLength: 32);

  /// Beide Seiten rufen dies mit ihrem eigenen Paar und dem fremden öffentlichen
  /// Schlüssel auf und erhalten dieselben Schlüssel. Wirft [FormatException]
  /// bei ungültigem Schlüssel (falsche Länge, Punkt kleiner Ordnung).
  static Future<Sitzungsschluessel> ableiten({
    required Schluesselpaar eigen,
    required List<int> fremdOeffentlich,
    required String code,
    required int epoch,
    required String cid,
  }) async {
    if (fremdOeffentlich.length != 32) throw const FormatException('Schlüssel hat nicht 32 Bytes');
    final geteilt = await Schluesselpaar._x25519.sharedSecretKey(
      keyPair: eigen._paar,
      remotePublicKey: SimplePublicKey(fremdOeffentlich, type: KeyPairType.x25519),
    );
    final roh = await geteilt.extractBytes();
    if (roh.every((b) => b == 0)) throw const FormatException('Ungültiger öffentlicher Schlüssel');
    Future<SecretKey> richtung(String r) => _hkdf.deriveKey(
          secretKey: geteilt,
          nonce: utf8.encode(code),
          info: utf8.encode('mordakte/v1|$epoch|$cid|$r'),
        );
    return Sitzungsschluessel(await richtung('h2c'), await richtung('c2h'));
  }
}
