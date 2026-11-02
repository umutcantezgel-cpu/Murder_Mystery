/// Teil 11: die vier versiegelten Fassungen WW4, JM3, RN7, YW4 (RK 7.1–7.7,
/// MECH 10.1, 10.4, 10.5, E9).
///
/// Seitenplan, bei jeder Personenzahl gleich: 16 Seiten A4 hoch, je Fassung
/// vier mit eigener Seitenzählung, in der Reihenfolge der Rollen 1–4.
/// 1. Außenseite ohne Kopf und Fuß (RK 7.2): mittig im oberen Drittel nur der
///    Code und `aussen.hinweis`. Zwei Falzlinien teilen das Blatt in Drittel.
///    Im unteren Drittel steht, wie man die Fassung verschließt
///    (`verschliessen.*`, MECH 10.5). Die Seiten 2 bis 4 kommen gefaltet
///    hinter das mittlere Drittel, das untere und das obere Drittel werden
///    darüber nach hinten gefaltet. Außen liegen dann nur der Code und die
///    leere Mitte; direkt hinter dem Code liegt die Anleitung, nie Text der
///    Fassung, damit nichts durchscheint.
/// 2. „Dein Ziel heute Nacht“, „Was wirklich geschah“ (Zeitleiste als
///    Tabelle, die Zeitspalte so breit, dass keine Zeit umbricht).
/// 3. „Was nur du weißt“ (1. bis 5.), „Dein Heft und die Wahrheit“, „Wenn es
///    eng wird“ (der Sobald-Satz fett, die Antwort darunter), „Stufe 3: Wenn
///    du angeklagt wirst“ (Bedingung, Vorlesetext, „Danach …“).
/// 4. „Notizen“ mit Linien.
///
/// Gleiche Gestalt (E9, RK 7.1, MECH 10.4): Je Seite eine Schriftgröße für
/// alle vier, die größte, bei der alle passen; gleiche Spaltenbreiten; jeder
/// Abschnitt ist in allen vier gleich hoch. Absätze, Listen und die
/// Zeitleiste stehen oben in ihrem Abschnitt, mit demselben Abstand zwischen
/// Einträgen und Tabellenzeilen in allen vier; was eine kürzere Fassung nicht
/// braucht, bleibt darunter frei (gestreckt wäre die Fassung mit mehr Text am
/// Seitenbild dichter). So stehen alle Überschriften auf denselben Höhen, und
/// kein Seitenbild verrät, welche Fassung die Tat enthält. Die Längen (RK 7.7:
/// jeder Teil höchstens zehn Prozent vom Mittel) und die gleiche Dichte prüft
/// `teil_11_test.dart` an den gedruckten Seiten jeder Personenzahl.
///
/// Überlauf ist ein Fehler ([KammerUeberlauf] mit Seite, Code und Stelle).
library;

import 'package:pdf/widgets.dart' as pw;

import 'inhalt.dart';
import 'kontext.dart';
import 'satz.dart';

/// Setzt Teil 11 (versiegelte Fassungen) in [doc].
void kammerFassungen(pw.Document doc, KammerKontext k) => kammerTeilSetzen(doc, k, '11', (s) => _Fassungen(k, s).setzen());

/// Ein Baustein einer Seite für Fassung [i] in Schriftgröße [g]: ohne [hoehe]
/// so hoch, wie er ist; mit [hoehe] genau so hoch (nie niedriger als ohne).
typedef _Bau = pw.Widget Function(int i, double g, double? hoehe);

/// Schriftgrößen für den Fließtext, die größte zuerst (Fließtext mindestens 9 pt).
const _groessen = [11.0, 10.75, 10.5, 10.25, 10.0, 9.75, 9.5, 9.25, KammerSatz.kleinsteGroesse];

/// Abstand zwischen den Einträgen einer Liste, relativ zur Schriftgröße.
const _listenAbstand = 0.45;

class _Fassungen {
  _Fassungen(this.k, this.s)
      : x = k.satz,
        fassungen = [for (final p in k.besetzung.verdaechtige) k.rolle(p).fassung!];

  final KammerKontext k;
  final KammerSeiten s;
  final KammerSatz x;
  final List<KammerFassung> fassungen;

  static final double _breite = KammerSatz.satzBreite();
  late final double _platz = s.platz();

  String u(String schluessel) => k.ui('11', schluessel);

  void setzen() {
    final seite2 = _plan(2, 'zeitleiste', _seite2());
    final seite3 = _plan(3, 'stufe3', _seite3());
    final notizen = _notizen();
    for (var i = 0; i < fassungen.length; i++) {
      final code = fassungen[i].code;
      s.bereichSetzen(code, (h) {
        _aussenseite(h, code);
        h.seite(seite2(i), wo: 'zeitleiste');
        h.seite(seite3(i), wo: 'stufe3');
        h.seite(notizen, wo: 'notizen');
      });
    }
  }

  // ---------------------------------------------------------------- Gleiche Gestalt

  /// Plan der Seite [seite] aus [bloecke]: die größte Schriftgröße, bei der
  /// jeder Block so hoch wie in der längsten Fassung ist und alles auf die
  /// Seite passt. Liefert die Seite je Fassung.
  List<pw.Widget> Function(int i) _plan(int seite, String wo, List<_Bau> bloecke) {
    for (final g in _groessen) {
      final hoehen = [
        for (final b in bloecke) [for (var i = 0; i < fassungen.length; i++) x.hoehe(b(i, g, null), _breite)].reduce((a, c) => a > c ? a : c),
      ];
      // Ein halber Punkt Reserve für Rundungen beim Strecken.
      if (hoehen.fold(0.0, (a, h) => a + h) <= _platz - 0.5) {
        return (i) => [for (var j = 0; j < bloecke.length; j++) bloecke[j](i, g, hoehen[j])];
      }
    }
    _ueberlauf(seite, wo, bloecke);
  }

  /// Auch in 9 pt kein gemeinsamer Satz: zuerst die Fassung, die schon allein
  /// nicht passt, sonst alle vier zusammen.
  Never _ueberlauf(int seite, String wo, List<_Bau> bloecke) {
    const g = KammerSatz.kleinsteGroesse;
    for (var i = 0; i < fassungen.length; i++) {
      final h = bloecke.fold(0.0, (a, b) => a + x.hoehe(b(i, g, null), _breite));
      final ort = [k.teilTitel('11'), fassungen[i].code, wo].join(' / ');
      if (h > _platz) KammerUeberlauf.keineGroesse('11', seite, ort, g, h, _platz);
    }
    final ort = [k.teilTitel('11'), for (final f in fassungen) f.code, wo].join(' / ');
    throw KammerUeberlauf.werfen('11', seite, ort, 'in gleicher Gestalt auch in ${g}pt höher als ${_platz.toStringAsFixed(1)} pt');
  }

  /// Überschrift (für alle gleich).
  _Bau _titel(String schluessel) => (i, g, hoehe) => x.ueberschrift(u(schluessel));

  /// Absatz [text] der Fassung [i]; in einem Kasten fester Höhe, der Text oben.
  _Bau _absatz(String Function(int i) text, String wo) => (i, g, hoehe) {
        final a = x.absatz(text(i), groesse: g);
        return hoehe == null ? a : s.fest(a, breite: _breite, hoehe: hoehe, wo: '${fassungen[i].code} / $wo');
      };

  /// Liste je Fassung mit festem Abstand zwischen den Einträgen, in allen vier
  /// gleich dicht (eine gestreckte Liste verriete am Seitenbild, welche
  /// Fassung mehr Text hat); in einem Kasten fester Höhe, der Rest bleibt
  /// unter der Liste frei.
  _Bau _liste(List<String> Function(int i) eintraege, KammerNummer nummer, String wo) => (i, g, hoehe) {
        final liste = x.liste(k.texte(eintraege(i)), nummer: nummer, groesse: g, abstand: g * _listenAbstand);
        return hoehe == null ? liste : s.fest(liste, breite: _breite, hoehe: hoehe, wo: '${fassungen[i].code} / $wo');
      };

  // ---------------------------------------------------------------- Seite 2

  List<_Bau> _seite2() => [
        _titel('deinZiel'),
        _absatz((i) => fassungen[i].ziel, 'ziel'),
        _titel('wasWirklichGeschah'),
        _zeitleiste,
      ];

  /// Zeitleiste als Tabelle mit festem Innenabstand (in allen vier gleich
  /// dicht); in einem Kasten fester Höhe, der Rest bleibt unter der Tabelle frei.
  pw.Widget _zeitleiste(int i, double g, double? hoehe) {
    final zeilen = [
      for (final z in fassungen[i].zeitleiste)
        if (!k.leer(z.zeit) && !k.leer(z.text)) [k.text(z.zeit), k.text(z.text)],
    ];
    final zb = _zeitBreite(g);
    final tabelle = x.tabelle(
      kopf: [u('zeitleiste.zeit'), u('zeitleiste.text')],
      zeilen: zeilen,
      spalten: [zb, _breite - zb],
      groesse: g,
      innen: const pw.EdgeInsets.fromLTRB(4, 3, 4, 3),
    );
    return hoehe == null ? tabelle : s.fest(tabelle, breite: _breite, hoehe: hoehe, wo: '${fassungen[i].code} / zeitleiste');
  }

  /// Breite der Zeitspalte in [g]: keine Zeit der vier Fassungen bricht um (gleich für alle).
  double _zeitBreite(double g) => _zeitBreiten[g] ??= () {
        final zeiten = {
          k.klartext(u('zeitleiste.zeit')),
          for (final f in fassungen)
            for (final z in f.zeitleiste) k.klartext(z.zeit),
        };
        final eineZeile = x.hoehe(pw.Text('0', style: k.stil.ueberschrift(g)), 1000) + 0.01;
        bool passt(double b) => zeiten.every((t) => x.hoehe(pw.Text(t, style: k.stil.ueberschrift(g)), b) <= eineZeile);
        var (a, b) = (8.0, _breite / 3);
        while (b - a > 0.5) {
          final m = (a + b) / 2;
          (a, b) = passt(m) ? (a, m) : (m, b);
        }
        // Innenabstand der Zelle und etwas Luft.
        return b + 8 + 4;
      }();
  final _zeitBreiten = <double, double>{};

  // ---------------------------------------------------------------- Seite 3

  List<_Bau> _seite3() => [
        _titel('wasNurDuWeisst'),
        _liste((i) => fassungen[i].wasNurDuWeisst, KammerNummer.zahl, 'wasNurDuWeisst'),
        _titel('heftUndWahrheit'),
        _absatz((i) => fassungen[i].heftUndWahrheit, 'heftUndWahrheit'),
        _titel('wennEsEngWird'),
        _liste((i) => [for (final t in fassungen[i].wennEsEngWird) _sobald(t)], KammerNummer.strich, 'wennEsEngWird'),
        _titel('stufe3'),
        _absatz((i) => u('stufe3.bedingung'), 'stufe3'),
        (i, g, hoehe) => pw.SizedBox(height: g * 0.6),
        _vorlesen,
        (i, g, hoehe) => pw.SizedBox(height: g * 0.6),
        _absatz((i) => u('stufe3.danach'), 'stufe3'),
      ];

  /// „Sobald …: „Antwort““ (RK 7.1): der Sobald-Satz fett, die Antwort auf der
  /// nächsten Zeile. Ohne diese Form bleibt der Text, wie er ist.
  String _sobald(String roh) {
    final t = k.text(roh);
    final i = t.indexOf(': „');
    if (i < 0 || t.contains('*')) return t;
    return '**${t.substring(0, i + 1)}**\n${t.substring(i + 2)}';
  }

  /// Der Text der Stufe 3 zum Vorlesen (Balken links, Marke „Vorlesen“);
  /// gestreckt mit dem Balken über die ganze Höhe.
  pw.Widget _vorlesen(int i, double g, double? hoehe) {
    pw.Widget kasten(double? h) => x.vorlesenKasten([x.absatz(fassungen[i].stufe3, groesse: g)], marke: KammerSatz.kleinsteGroesse, hoehe: h);
    final natur = kasten(null);
    if (hoehe == null) return natur;
    // Eine Spalte fester Höhe ließe zu viel Text still weg: vorher messen.
    s.pruefeHoehe(x.hoehe(natur, _breite), hoehe + 0.01, wo: '${fassungen[i].code} / stufe3');
    return kasten(hoehe);
  }

  // ---------------------------------------------------------------- Seite 4

  /// „Notizen“ und Linien bis zum Fuß (für alle gleich).
  List<pw.Widget> _notizen() {
    final kopf = x.ueberschrift(k.uiGemeinsam('notizen'));
    const abstand = 22.0;
    final zeilen = ((_platz - x.hoehe(kopf, _breite) - 4) / abstand).floor();
    return [kopf, pw.SizedBox(height: 4), x.notizlinien(zeilen, abstand: abstand)];
  }

  // ---------------------------------------------------------------- Seite 1

  /// Außenseite (RK 7.2, MECH 10.5): Code und Hinweis im oberen Drittel,
  /// Falzlinien und Anleitung wie bei Teil 90 ([KammerSeiten.verschlussSeite]).
  void _aussenseite(KammerSeiten h, String code) {
    final codeStil = k.stil.code(60);
    h.verschlussSeite(
      () => pw.Column(mainAxisSize: pw.MainAxisSize.min, crossAxisAlignment: pw.CrossAxisAlignment.center, children: [
        // Die Sperrung steht auch hinter dem letzten Zeichen; links ebenso viel, damit der Code mittig steht.
        pw.Padding(padding: pw.EdgeInsets.only(left: codeStil.letterSpacing ?? 0), child: pw.Text(code, style: codeStil)),
        pw.SizedBox(height: 10),
        x.absatz(u('aussen.hinweis'), groesse: 13, ausrichtung: pw.TextAlign.center),
      ]),
      verschliessen: [u('verschliessen.titel'), for (var n = 1; n <= 4; n++) u('verschliessen.$n')],
      wo: 'aussen',
    );
  }
}
