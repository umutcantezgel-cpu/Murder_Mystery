import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../besetzung.dart';
import '../kanon/kanon.dart';
import '../steckbriefe.dart';
import '../texte.dart';
import 'fest_rollenheft.dart';
import 'fest_spielleitung.dart';
import 'fest_steckbrief.dart';
import 'satz.dart';
import 'satz_fest.dart';
import 'steckbrief.dart';
import 'veranstalter.dart';

// Druckpaket für den Veranstalter (Abend am Bildschirm): alle Hefte im festlichen
// Stil ([FestStil]), in vier Ordnern nach Empfängern. Ordner 1 und 2 sind spoilerfrei,
// Ordner 3 geht je Person ungelesen weiter, Ordner 4 nur an die Person, die erzählt.

/// Die vier Ordner des Pakets in fester Reihenfolge.
const paketOrdner = ['1-an-alle', '2-veranstalter', '3-je-person-ungelesen-weitergeben', '4-nur-erzaehler'];

/// Alles, was das Paket zum Setzen braucht: der Druckkontext des Falls (Code,
/// Personenzahl, Satz), die Steckbriefe der Akte, der festliche Stil und die
/// Porträts als PNG (Schlüssel: Figur oder `detektiv-w`/`detektiv-m`). Die
/// Porträts gehen als JPEG in die PDFs: groß für Fotoabzüge, klein (240 px) für
/// Karten und Listen; so bleiben die Dateien klein genug zum Verschicken.
class PaketKontext {
  PaketKontext(this.druck, {required this.steckbriefe, required this.stil, Map<String, Uint8List> portraets = const {}})
      : _png = portraets;

  final DruckKontext druck;
  final Steckbriefe steckbriefe;
  final FestStil stil;
  final Map<String, Uint8List> _png;
  final Map<String, pw.MemoryImage> _gross = {}, _klein = {};

  Kanon get kanon => druck.kanon;
  Texte get texte => druck.texte;
  int get rollen => druck.satz.rollen;
  String get code => druck.satz.code.code;

  /// Falltitel und Untertitel aus `fall.json`.
  String get fallTitel => druck.fallTitel;
  String get untertitel => (kanon.fall['untertitel'] ?? '') as String;

  String ui(String kennung, [Map<String, String> werte = const {}]) => druck.ui(kennung, werte);
  String text(String kennung) => druck.text(kennung);

  /// Porträt einer Figur oder des Detektivs ([detektiv] `w`/`m`), mit [klein] in
  /// 240 px; null, wenn keins vorliegt.
  pw.ImageProvider? bild(String id, {String detektiv = 'w', bool klein = false}) {
    final schluessel = id == Besetzung.detektiv ? 'detektiv-$detektiv' : id;
    final png = _png[schluessel];
    if (png == null) return null;
    return (klein ? _klein : _gross)[schluessel] ??= pw.MemoryImage(_jpeg(png, klein ? 240 : null));
  }

  static Uint8List _jpeg(Uint8List png, int? breite) {
    var b = img.decodeImage(png) ?? (throw ArgumentError('Porträt ist kein lesbares Bild'));
    if (breite != null && b.width > breite) b = img.copyResize(b, width: breite, interpolation: img.Interpolation.average);
    if (b.hasAlpha) {
      // Durchsichtige Porträts auf Papierton legen (JPEG kennt keine Transparenz).
      final grund = img.Image(width: b.width, height: b.height)..clear(img.ColorRgb8(251, 248, 240));
      b = img.compositeImage(grund, b);
    }
    return img.encodeJpg(b, quality: 90);
  }

  /// Welche Porträts fehlen für das Paket (besetzte Figuren, Detektivin, Detektiv)?
  List<String> fehlendePortraets() => [
        for (final id in [...druck.satz.besetzt, 'detektiv-w', 'detektiv-m'])
          if (!_png.containsKey(id)) id,
      ];

  /// Steckbriefkontext (spoilerfreie Angaben) für Detektivin `w` oder Detektiv `m`.
  SteckbriefKontext steckbrief([String detektiv = 'w']) =>
      _sk[detektiv] ??= SteckbriefKontext(kanon, texte, druck.stil, steckbriefe: steckbriefe, detektiv: detektiv);
  final Map<String, SteckbriefKontext> _sk = {};

  /// Figurenfarbe aus `colorCode`.
  PdfColor farbe(String id) => PdfColor.fromHex((kanon.figur(id)!['colorCode']) as String);

  String figurName(String id) => druck.figurName(id);

  /// Die besetzten Figuren alphabetisch (wie die Charakterübersicht), ohne Detektiv.
  List<String> get figurenAlphabetisch => uebersichtFiguren(steckbrief(), rollen: rollen).skip(1).toList();

  /// Seitenzahl „Seite x von y“.
  String seite(int nr, int von) => ui('ui.druck.fest.seite', {'nr': '$nr', 'von': '$von'});
}

/// Eine Datei des Pakets mit ihrem Ordner.
typedef PaketDatei = ({String ordner, DruckDatei datei});

/// Dateiname einer Figur: ihr Name ohne Umlaute (`lejla`, `joanna`).
String paketName(PaketKontext k, String id) => dateiWort(k.figurName(id));

/// Alle Dateien des Pakets, Ordner für Ordner (siehe [paketOrdner]).
Future<List<PaketDatei>> paketDateien(PaketKontext k) async => [
      for (final d in await anAlleDateien(k)) (ordner: paketOrdner[0], datei: d),
      (ordner: paketOrdner[1], datei: await veranstalterDatei(k)),
      for (final id in k.druck.satz.besetzt) (ordner: paketOrdner[2], datei: await festRollenheftDatei(k, id)),
      for (final g in ['w', 'm']) (ordner: paketOrdner[2], datei: await festDetektivbogenDatei(k, g)),
      (ordner: paketOrdner[3], datei: await festErzaehlerheftDatei(k)),
    ];

/// Ordner 1: Übersicht, alle Steckbriefe in einer Datei, je Figur ein Steckbrief,
/// dazu Detektivin und Detektiv.
Future<List<DruckDatei>> anAlleDateien(PaketKontext k) async => [
      await festUebersichtDatei(k),
      await festSteckbriefeAlleDatei(k),
      for (final id in k.druck.satz.besetzt) await festSteckbriefDatei(k, id),
      for (final g in ['w', 'm']) await festSteckbriefDatei(k, Besetzung.detektiv, detektiv: g),
    ];

// ---------------------------------------------------------------- ZIP

/// Ein ZIP-Archiv ohne Kompression (die PDFs sind schon komprimiert) mit festem
/// Zeitstempel: gleiche Dateien ⇒ gleiche Bytes. [dateien]: Pfad im Archiv → Inhalt.
Uint8List zipArchiv(Map<String, Uint8List> dateien) {
  final aus = BytesBuilder(copy: false);
  final zentral = BytesBuilder(copy: false);
  const zeit = (18 << 11) | (0 << 5); // 18:00:00
  const datum = ((2026 - 1980) << 9) | (10 << 5) | 31; // 31.10.2026
  var anzahl = 0;
  for (final e in dateien.entries) {
    final name = Uint8List.fromList(e.key.codeUnits);
    final crc = _crc32(e.value);
    final versatz = aus.length;
    void kopf(BytesBuilder b, {required bool lokal}) {
      final d = ByteData(lokal ? 30 : 46);
      var i = 0;
      void u32(int v) {
        d.setUint32(i, v, Endian.little);
        i += 4;
      }

      void u16(int v) {
        d.setUint16(i, v, Endian.little);
        i += 2;
      }

      u32(lokal ? 0x04034b50 : 0x02014b50);
      if (!lokal) u16(20);
      u16(20);
      u16(0);
      u16(0);
      u16(zeit);
      u16(datum);
      u32(crc);
      u32(e.value.length);
      u32(e.value.length);
      u16(name.length);
      u16(0);
      if (!lokal) {
        u16(0);
        u16(0);
        u16(0);
        u32(0);
        u32(versatz);
      }
      b
        ..add(d.buffer.asUint8List())
        ..add(name);
    }

    kopf(aus, lokal: true);
    aus.add(e.value);
    kopf(zentral, lokal: false);
    anzahl++;
  }
  final start = aus.length;
  final groesse = zentral.length;
  aus.add(zentral.takeBytes());
  final ende = ByteData(22)
    ..setUint32(0, 0x06054b50, Endian.little)
    ..setUint16(8, anzahl, Endian.little)
    ..setUint16(10, anzahl, Endian.little)
    ..setUint32(12, groesse, Endian.little)
    ..setUint32(16, start, Endian.little);
  aus.add(ende.buffer.asUint8List());
  return aus.takeBytes();
}

final _crcTabelle = List<int>.generate(256, (n) {
  var c = n;
  for (var k = 0; k < 8; k++) {
    c = (c & 1) != 0 ? 0xEDB88320 ^ (c >> 1) : c >> 1;
  }
  return c;
});

int _crc32(Uint8List daten) {
  var c = 0xFFFFFFFF;
  for (final b in daten) {
    c = _crcTabelle[(c ^ b) & 0xFF] ^ (c >> 8);
  }
  return c ^ 0xFFFFFFFF;
}
