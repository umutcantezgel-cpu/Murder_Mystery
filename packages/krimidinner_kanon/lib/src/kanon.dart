/// Kanon „Spuk im Gewölbe“: Datensätze einlesen und abfragen.
///
/// Die Klasse heißt `KrimiKanon`, weil mordakte_core schon eine Klasse `Kanon`
/// exportiert; ein Overlay gibt es nicht. Das Einlesen folgt
/// weiter `krimidinner/spuk-im-gewoelbe/90_werkzeug/kanon.py`.
library;

import 'dart:convert';

/// Sichtklasse eines Datensatzes: `O` öffentlich, `G` Rollengeheimnis, `L` Lösung.
enum Sicht {
  o,
  g,
  l;

  /// Kürzel wie im Kanon (`O`, `G` oder `L`).
  String get kuerzel => name.toUpperCase();
}

/// Ein Datensatz: eine Zeile `@ID [S] | Feld: Wert | …`.
class KanonDatensatz {
  KanonDatensatz({
    required this.id,
    required this.sicht,
    required this.felder,
    required this.datei,
    required this.zeile,
  });

  final String id;
  final Sicht sicht;

  /// Felder in Dateireihenfolge. Ein Wert `–` steht als leerer Text.
  final Map<String, String> felder;

  /// Datei und Zeile (1-basiert) der Definition.
  final String datei;
  final int zeile;

  /// Wert des Feldes [name]; `null`, wenn das Feld fehlt.
  String? feld(String name) => felder[name];

  /// Die Zeile im Kanon-Format; leere Werte stehen wieder als `–`.
  String get alsZeile {
    final buf = StringBuffer('@$id [${sicht.kuerzel}]');
    felder.forEach(
      (name, wert) => buf.write(' | $name: ${wert.isEmpty ? '–' : wert}'),
    );
    return buf.toString();
  }
}

/// Der Kanon des Krimidinners: alle Datensätze in Lesereihenfolge.
class KrimiKanon {
  KrimiKanon._(this.datensaetze, this.lesefehler);

  /// Datensätze nach Kennung.
  final Map<String, KanonDatensatz> datensaetze;

  /// Syntaxbefunde beim Einlesen (Kopf unlesbar, Feld ohne Doppelpunkt).
  final List<String> lesefehler;

  /// Liest Kanon-Dateien aus einer Map von Dateiname zu Inhalt, in Namensreihenfolge.
  ///
  /// Nur Dateien nach [istKanonDatei] zählen. Doppelte Kennungen werfen eine
  /// [FormatException] mit Datei und Zeile.
  static KrimiKanon ausText(Map<String, String> dateiInhalte) {
    final recs = <String, KanonDatensatz>{};
    final fehler = <String>[];
    final namen = dateiInhalte.keys.where(istKanonDatei).toList()..sort();
    for (final name in namen) {
      final zeilen = const LineSplitter().convert(dateiInhalte[name]!);
      for (var i = 0; i < zeilen.length; i++) {
        final satz = _lesZeile(zeilen[i], name, i + 1, fehler);
        if (satz == null) continue;
        final alt = recs[satz.id];
        if (alt != null) {
          throw FormatException(
            'DOPPELT ${satz.id}: ${alt.datei}:${alt.zeile} und $name:${satz.zeile}',
          );
        }
        recs[satz.id] = satz;
      }
    }
    return KrimiKanon._(recs, fehler);
  }

  /// Datensätze, deren Kennung mit [praefix] beginnt.
  Iterable<KanonDatensatz> mitPraefix(String praefix) =>
      datensaetze.values.where((d) => d.id.startsWith(praefix));
}

final _kopf = RegExp(
  r'^@([A-Za-zÄÖÜäöü0-9\-_.]+)\s*\[([OGL])\]\s*(.*)$',
  dotAll: true,
);

/// Gehört die Datei [name] zum Kanon?
///
/// Nur `K*.md`; damit fallen GESAMT-KANON, FORMAT, VERSION, PROTOKOLL und
/// SELBSTPRUEFUNG heraus. Ein Pfad zählt nach seinem letzten Teil.
bool istKanonDatei(String name) {
  final datei = name.split('/').last;
  return datei.startsWith('K') && datei.endsWith('.md');
}

/// Liest eine Zeile. `null` für Zeilen ohne `@`; Syntaxbefunde gehen nach [fehler].
KanonDatensatz? _lesZeile(
  String zeile,
  String datei,
  int nr,
  List<String> fehler,
) {
  if (!zeile.startsWith('@')) return null;
  final kopf = _kopf.firstMatch(zeile);
  if (kopf == null) {
    fehler.add('SYNTAX $datei:$nr: Kopf unlesbar: ${_kuerzen(zeile, 80)}');
    return null;
  }
  final id = kopf.group(1)!;
  final felder = <String, String>{};
  var rest = kopf.group(3)!.trim();
  if (rest.startsWith('|')) rest = rest.substring(1);
  for (final teil in rest.split(' | ')) {
    if (teil.trim().isEmpty) continue;
    final t = teil.trim().replaceFirst(RegExp(r'^\|+'), '').trim();
    final paar = _feldPaar(t);
    if (paar == null) {
      fehler.add(
        'SYNTAX $datei:$nr: Feld ohne Doppelpunkt in $id: ${_kuerzen(t, 60)}',
      );
      continue;
    }
    felder[paar.$1] = paar.$2;
  }
  return KanonDatensatz(
    id: id,
    sicht: switch (kopf.group(2)!) {
      'O' => Sicht.o,
      'G' => Sicht.g,
      _ => Sicht.l,
    },
    felder: felder,
    datei: datei,
    zeile: nr,
  );
}

/// Trennt `Name: Wert` am ersten `: `; steht der Doppelpunkt am Ende, ist der Wert leer.
(String, String)? _feldPaar(String t) {
  final i = t.indexOf(': ');
  if (i >= 0) return (t.substring(0, i).trim(), _wert(t.substring(i + 2)));
  if (t.endsWith(':')) return (t.substring(0, t.length - 1).trim(), '');
  return null;
}

/// Getrimmter Wert; `–` bedeutet leer.
String _wert(String s) {
  final v = s.trim();
  return v == '–' ? '' : v;
}

/// Kürzt [s] auf höchstens [n] Zeichen (Unicode-Zeichen, nicht Code-Units).
String _kuerzen(String s, int n) =>
    s.runes.length <= n ? s : String.fromCharCodes(s.runes.take(n));
