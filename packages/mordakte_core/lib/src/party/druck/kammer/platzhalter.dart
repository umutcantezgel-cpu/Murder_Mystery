/// Platzhalter und Auszeichnung der Kammerspiel-Texte
/// (`content/kammerspiel/schlosskeller/SCHEMA.md`, Abschnitte 3 und 4).
///
/// Reine Textlogik ohne Spieltext und ohne `dart:io`: Die Texte kommen aus dem
/// Inhalt, hier werden sie nur geprüft, je Besetzung aufgelöst und in Absätze,
/// Zeilen und Läufe (fett, kursiv) zerlegt.
///
/// Platzhalter (verschachtelbar):
/// - `{rolle:ID|Ersatz}`: Name der Rolle, wenn sie heute gespielt wird, sonst der Ersatz.
/// - `{wenn:ID[,ID…]|Text|Sonst}`: Text, wenn alle Rollen gespielt werden, sonst Sonst (darf fehlen).
/// - `{ab:N|Text|Sonst}`: Text ab N Personen, sonst Sonst (darf fehlen).
/// - `{detektiv:männlich|weiblich}`: Fassung nach dem Detektiv.
/// - `{wert}`: Wert, den der Generator einsetzt (nur wo das Schema es erlaubt).
///
/// Auszeichnung nach dem Auflösen: `**fett**`, `*kursiv*`, `\n` Zeilenumbruch,
/// Leerzeile (`\n\n`) neuer Absatz.
library;

/// Kennzeichen eines Texts, den die Schreib-Phase noch füllen muss.
const String kammerOffenMarke = 'OFFEN:';

/// Ob [text] noch nicht geschrieben ist.
bool istKammerOffen(String text) => text.startsWith(kammerOffenMarke);

/// Wovon die Auflösung eines Texts abhängt: Besetzung, Namen, Personenzahl,
/// Detektiv und die Werte der Wert-Platzhalter.
class KammerTextWerte {
  const KammerTextWerte({
    required this.besetzt,
    required this.namen,
    required this.personen,
    this.detektivWeiblich = false,
    this.werte = const {},
  });

  /// Rollen-IDs, die heute gespielt werden.
  final Set<String> besetzt;

  /// Rollen-ID → Name, wie er gedruckt wird.
  final Map<String, String> namen;

  /// Personen am Tisch (Rollen, Detektiv, Erzähler).
  final int personen;

  final bool detektivWeiblich;

  /// Werte der Wert-Platzhalter `{name}`.
  final Map<String, String> werte;
}

/// Ein Lauf gleicher Auszeichnung.
class KammerLauf {
  const KammerLauf(this.text, {this.fett = false, this.kursiv = false});

  final String text;
  final bool fett;
  final bool kursiv;

  @override
  bool operator ==(Object other) =>
      other is KammerLauf && other.text == text && other.fett == fett && other.kursiv == kursiv;

  @override
  int get hashCode => Object.hash(text, fett, kursiv);

  @override
  String toString() => '${fett ? '**' : ''}${kursiv ? '*' : ''}$text${kursiv ? '*' : ''}${fett ? '**' : ''}';
}

/// Ein Absatz: Zeilen aus Läufen.
class KammerAbsatz {
  const KammerAbsatz(this.zeilen);

  final List<List<KammerLauf>> zeilen;

  /// Text ohne Auszeichnung, Zeilen mit `\n` verbunden.
  String get klartext => zeilen.map((z) => z.map((l) => l.text).join()).join('\n');
}

const _arten = {'rolle', 'wenn', 'ab', 'detektiv'};
final _wertName = RegExp(r'^[a-z][A-Za-z0-9]*$');
final _rollenId = RegExp(r'^[a-z][a-z0-9]*$');

sealed class _Teil {
  const _Teil(this.stelle);
  final int stelle;
}

class _Text extends _Teil {
  const _Text(this.text, super.stelle);
  final String text;
}

class _Wert extends _Teil {
  const _Wert(this.name, super.stelle);
  final String name;
}

class _Platzhalter extends _Teil {
  const _Platzhalter(this.art, this.argument, this.zweige, super.stelle);
  final String art;
  final String argument;
  final List<List<_Teil>> zweige;

  List<String> get ids => argument.split(',');
}

/// Zerlegt einen Text in Teile; wirft [FormatException] bei falscher Syntax.
List<_Teil> _zerlege(String text) {
  final leser = _Leser(text);
  final teile = leser.folge(imPlatzhalter: false);
  if (leser.i < text.length) throw FormatException('„}“ oder „|“ ohne Platzhalter', text, leser.i);
  return teile;
}

class _Leser {
  _Leser(this.s);

  final String s;
  int i = 0;

  List<_Teil> folge({required bool imPlatzhalter}) {
    final teile = <_Teil>[];
    final puffer = StringBuffer();
    var start = i;
    void abschliessen() {
      if (puffer.isNotEmpty) teile.add(_Text(puffer.toString(), start));
      puffer.clear();
    }

    while (i < s.length) {
      final c = s[i];
      if (c == '{') {
        abschliessen();
        teile.add(platzhalter());
        start = i;
        continue;
      }
      if (c == '}' || (c == '|' && imPlatzhalter)) {
        if (!imPlatzhalter) throw FormatException('„}“ ohne „{“', s, i);
        break;
      }
      puffer.write(c);
      i++;
    }
    abschliessen();
    return teile;
  }

  _Teil platzhalter() {
    final start = i;
    i++;
    final ende = s.indexOf(RegExp(r'[:}|{]'), i);
    if (ende < 0) throw FormatException('„{“ ohne „}“', s, start);
    final art = s.substring(i, ende);
    if (s[ende] == '}') {
      if (!_wertName.hasMatch(art)) throw FormatException('ungültiger Wert-Platzhalter „{$art}“', s, start);
      i = ende + 1;
      return _Wert(art, start);
    }
    if (s[ende] != ':') throw FormatException('Platzhalter ohne „:“ oder „}“', s, start);
    if (!_arten.contains(art)) throw FormatException('unbekannter Platzhalter „$art“', s, start);
    i = ende + 1;
    var argument = '';
    if (art != 'detektiv') {
      final strich = s.indexOf(RegExp(r'[|}{]'), i);
      if (strich < 0 || s[strich] != '|') throw FormatException('Platzhalter „$art“ braucht „|“', s, start);
      argument = s.substring(i, strich);
      i = strich + 1;
    }
    final zweige = <List<_Teil>>[];
    while (true) {
      zweige.add(folge(imPlatzhalter: true));
      if (i >= s.length) throw FormatException('„{“ ohne „}“', s, start);
      if (s[i] == '|') {
        i++;
        continue;
      }
      i++;
      break;
    }
    final (min, max) = switch (art) { 'rolle' => (1, 1), 'detektiv' => (2, 2), _ => (1, 2) };
    if (zweige.length < min || zweige.length > max) throw FormatException('Platzhalter „$art“ hat ${zweige.length} Teile', s, start);
    return _Platzhalter(art, argument, zweige, start);
  }
}

/// Prüft Platzhalter und Auszeichnung von [text]. [rollen] sind die gültigen
/// Rollen-IDs; [werte] die erlaubten Wert-Platzhalter (null: alle erlaubt).
/// Wirft [FormatException] mit dem Grund.
void pruefeKammerText(String text, {required Set<String> rollen, Set<String>? werte = const {}}) {
  final teile = _zerlege(text);
  void pruefe(List<_Teil> folge) {
    for (final t in folge) {
      switch (t) {
        case _Text():
          break;
        case _Wert(:final name):
          if (werte != null && !werte.contains(name)) throw FormatException('Wert-Platzhalter „{$name}“ ist hier nicht erlaubt', text, t.stelle);
        case _Platzhalter(:final art, :final argument, :final zweige):
          if (art == 'ab') {
            final n = int.tryParse(argument);
            if (n == null || n < 1) throw FormatException('„{ab:$argument|…}“ braucht eine Personenzahl', text, t.stelle);
          } else if (art != 'detektiv') {
            final ids = argument.split(',');
            if (art == 'rolle' && ids.length != 1) throw FormatException('„{rolle:…}“ nennt genau eine Rolle', text, t.stelle);
            for (final id in ids) {
              if (!_rollenId.hasMatch(id) || !rollen.contains(id)) throw FormatException('unbekannte Rolle „$id“', text, t.stelle);
            }
          }
          zweige.forEach(pruefe);
      }
    }
  }

  pruefe(teile);
  // Auszeichnung in beiden Extremen der Besetzung prüfen.
  final namen = {for (final r in rollen) r: r};
  final probeWerte = _ProbeWerte();
  for (final alle in [true, false]) {
    final w = KammerTextWerte(
      besetzt: alle ? rollen : const {},
      namen: namen,
      personen: alle ? 20 : 6,
      detektivWeiblich: !alle,
    );
    kammerAuszeichnung(_loese(teile, w, probeWerte));
  }
}

/// Werte für die Prüfung: Jeder Wert-Platzhalter wird zu einem Wort.
class _ProbeWerte {
  String? operator [](String name) => 'x';
}

/// Löst alle Platzhalter in [text] nach [werte] auf. Wirft [FormatException],
/// wenn ein Wert fehlt oder die Syntax falsch ist.
String loeseKammerText(String text, KammerTextWerte werte) => _loese(_zerlege(text), werte, null);

String _loese(List<_Teil> teile, KammerTextWerte w, _ProbeWerte? probe) {
  final aus = StringBuffer();
  for (final t in teile) {
    switch (t) {
      case _Text(:final text):
        aus.write(text);
      case _Wert(:final name):
        final wert = probe != null ? probe[name] : w.werte[name];
        if (wert == null) throw FormatException('kein Wert für „{$name}“');
        aus.write(wert);
      case _Platzhalter(:final art, :final argument, :final zweige):
        final sonst = zweige.length > 1 ? zweige[1] : const <_Teil>[];
        switch (art) {
          case 'rolle':
            if (w.besetzt.contains(argument)) {
              final name = w.namen[argument];
              if (name == null) throw FormatException('kein Name für Rolle „$argument“');
              aus.write(name);
            } else {
              aus.write(_loese(zweige[0], w, probe));
            }
          case 'wenn':
            final alle = t.ids.every(w.besetzt.contains);
            aus.write(_loese(alle ? zweige[0] : sonst, w, probe));
          case 'ab':
            aus.write(_loese(w.personen >= int.parse(argument) ? zweige[0] : sonst, w, probe));
          case 'detektiv':
            aus.write(_loese(zweige[w.detektivWeiblich ? 1 : 0], w, probe));
        }
    }
  }
  return aus.toString();
}

/// Rollen-IDs, die [text] in Platzhaltern nennt (für Prüfungen).
Set<String> kammerTextRollen(String text) {
  final ids = <String>{};
  void sammle(List<_Teil> folge) {
    for (final t in folge) {
      if (t is _Platzhalter) {
        if (t.art == 'rolle' || t.art == 'wenn') ids.addAll(t.ids);
        t.zweige.forEach(sammle);
      }
    }
  }

  sammle(_zerlege(text));
  return ids;
}

/// Zerlegt einen aufgelösten Text in Absätze, Zeilen und Läufe. Mehrfache
/// Leerzeichen werden zu einem, Zeilen ohne Rand. Wirft [FormatException], wenn
/// `**` oder `*` in einem Absatz nicht geschlossen werden.
List<KammerAbsatz> kammerAuszeichnung(String text) {
  final absaetze = <KammerAbsatz>[];
  for (final roh in text.split(RegExp(r'\n[ \t]*\n'))) {
    var fett = false;
    var kursiv = false;
    final zeilen = <List<KammerLauf>>[];
    for (final zeileRoh in roh.split('\n')) {
      final zeile = zeileRoh.replaceAll(RegExp(r'[ \t]+'), ' ').trim();
      final laeufe = <KammerLauf>[];
      final puffer = StringBuffer();
      void abschliessen() {
        if (puffer.isNotEmpty) laeufe.add(KammerLauf(puffer.toString(), fett: fett, kursiv: kursiv));
        puffer.clear();
      }

      var i = 0;
      while (i < zeile.length) {
        if (zeile.startsWith('**', i)) {
          abschliessen();
          fett = !fett;
          i += 2;
        } else if (zeile[i] == '*') {
          abschliessen();
          kursiv = !kursiv;
          i += 1;
        } else {
          puffer.write(zeile[i]);
          i += 1;
        }
      }
      abschliessen();
      if (laeufe.isNotEmpty) zeilen.add(laeufe);
    }
    if (fett || kursiv) throw FormatException('Auszeichnung „${fett ? '**' : '*'}“ nicht geschlossen', roh);
    if (zeilen.isNotEmpty) absaetze.add(KammerAbsatz(zeilen));
  }
  return absaetze;
}

/// Text ohne Auszeichnung (Absätze mit Leerzeile getrennt), etwa zum Zählen.
String kammerKlartext(String text) => kammerAuszeichnung(text).map((a) => a.klartext).join('\n\n');
