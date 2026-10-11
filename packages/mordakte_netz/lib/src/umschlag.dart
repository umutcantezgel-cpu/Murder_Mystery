/// Verschlüsselte Umschläge für die Sitz-Themen.
///
/// Umschlag: `{"s":"h"|"c","n":<int>,"iv":<b64>,"ct":<b64>}`. `s` nennt den
/// Absender (Gastgeber `h`, Gast `c`), `n` zählt je Richtung und Epoche
/// aufwärts, `iv` ist ein zufälliger 12-Byte-Nonce, `ct` ist Chiffretext samt
/// 16-Byte-Tag (ChaCha20-Poly1305). Zugehörige Daten (AAD): `topic|s|n`. So
/// kann ein Mithörer im Relais weder lesen noch fälschen noch ein Thema,
/// eine Richtung oder die Zählung vertauschen.
///
/// Der Empfänger verwirft jeden Umschlag, dessen `n` nicht größer ist als das
/// größte bisher erfolgreich geöffnete `n` dieser Richtung (Wiederholschutz).
library;

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

import 'krypto.dart';
import 'phoenix.dart';

/// Größte Umschlaggröße (Zeichen), die ein Empfänger überhaupt auspackt.
/// Supabase erlaubt 256 KB je Nachricht.
const maxUmschlagZeichen = 240 * 1024;

/// Führt asynchrone Schritte strikt nacheinander aus (Krypto ist asynchron,
/// die Reihenfolge der Nachrichten darf sich dabei nicht verschieben).
class Reihe {
  Future<void> _ende = Future<void>.value();

  Future<T> einreihen<T>(Future<T> Function() f) {
    final c = Completer<T>();
    _ende = _ende.then((_) async {
      try {
        c.complete(await f());
      } catch (e, s) {
        c.completeError(e, s);
      }
    });
    return c.future;
  }
}

/// Ein erfolgreich geöffneter Umschlag: Inhalt und seine Zählnummer.
class Geoeffnet {
  const Geoeffnet(this.nachricht, this.n);
  final Map<String, Object?> nachricht;
  final int n;
}

/// Ein Sitz (Gastgeber ↔ ein Gast) aus Sicht einer Seite: Absender-Seite,
/// beide Richtungsschlüssel, Sendezähler und Empfangsstand.
class UmschlagPaar {
  UmschlagPaar({
    required this.topic,
    required this.eigeneSeite,
    required Sitzungsschluessel schluessel,
    int startN = 0,
    Random? zufall,
  })  : assert(eigeneSeite == 'h' || eigeneSeite == 'c'),
        _senden = eigeneSeite == 'h' ? schluessel.hostZuGast : schluessel.gastZuHost,
        _empfangen = eigeneSeite == 'h' ? schluessel.gastZuHost : schluessel.hostZuGast,
        _n = startN,
        _zufall = zufall ?? Random.secure();

  /// Thema ohne `realtime:`-Präfix (geht in die AAD ein).
  final String topic;

  /// `h` (Gastgeber) oder `c` (Gast).
  final String eigeneSeite;
  final SecretKey _senden;
  final SecretKey _empfangen;
  final Random _zufall;
  final Reihe _sendeReihe = Reihe();
  final Reihe _empfangsReihe = Reihe();
  int _n;
  int _letztesEmpfangen = 0;
  static final _aead = Chacha20.poly1305Aead();

  String get gegenSeite => eigeneSeite == 'h' ? 'c' : 'h';

  /// Zuletzt vergebenes `n` (Sendeseite).
  int get gesendetN => _n;

  /// Größtes erfolgreich geöffnetes `n` der Gegenseite.
  int get empfangenN => _letztesEmpfangen;

  /// Setzt den Wiederholschutz der Empfangsrichtung auf [n] (nur wachsend).
  /// Der Gast nutzt das nach dem `willkommen`: Alles Ältere ist Wiederholung.
  void empfangsUntergrenze(int n) {
    if (n > _letztesEmpfangen) _letztesEmpfangen = n;
  }

  /// Verschlüsselt [nachricht] und schickt sie als Umschlag über [kanal].
  /// Aufrufe werden in Reihenfolge abgearbeitet. `false`: nicht gesendet.
  Future<bool> senden(PhoenixKanal kanal, Map<String, Object?> nachricht) => _sendeReihe.einreihen(() async {
        final umschlag = await verpacken(nachricht);
        return kanal.sende('m', umschlag);
      });

  /// Nur verschlüsseln (Zähler wird erhöht).
  Future<Map<String, Object?>> verpacken(Map<String, Object?> nachricht) async {
    final n = ++_n;
    final nonce = zufallsBytes(12, _zufall);
    final box = await _aead.encrypt(
      utf8.encode(jsonEncode(nachricht)),
      secretKey: _senden,
      nonce: nonce,
      aad: utf8.encode('$topic|$eigeneSeite|$n'),
    );
    return {
      's': eigeneSeite,
      'n': n,
      'iv': b64(nonce),
      'ct': b64([...box.cipherText, ...box.mac.bytes]),
    };
  }

  /// Öffnet einen empfangenen Umschlag. `null`, wenn er ungültig, gefälscht,
  /// von der falschen Seite, für ein anderes Thema oder eine Wiederholung ist.
  Future<Geoeffnet?> oeffnen(Object? roh) => _empfangsReihe.einreihen(() => _oeffne(roh));

  Future<Geoeffnet?> _oeffne(Object? roh) async {
    if (roh is! Map) return null;
    final s = roh['s'], n = roh['n'];
    if (s != gegenSeite || n is! int || n <= _letztesEmpfangen) return null;
    final iv = unB64(roh['iv']);
    final ct = unB64(roh['ct']);
    if (iv == null || ct == null || iv.length != 12 || ct.length < 16 || ct.length > maxUmschlagZeichen) return null;
    final Uint8List klar;
    try {
      klar = Uint8List.fromList(await _aead.decrypt(
        SecretBox(ct.sublist(0, ct.length - 16), nonce: iv, mac: Mac(ct.sublist(ct.length - 16))),
        secretKey: _empfangen,
        aad: utf8.encode('$topic|$s|$n'),
      ));
    } on SecretBoxAuthenticationError {
      return null;
    } catch (_) {
      return null;
    }
    _letztesEmpfangen = n;
    try {
      final j = jsonDecode(utf8.decode(klar));
      return j is Map ? Geoeffnet(j.cast<String, Object?>(), n) : null;
    } on FormatException {
      return null;
    }
  }
}
