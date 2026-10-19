import 'dart:math';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../besetzung.dart';
import '../kanon/kanon.dart';
import '../steckbriefe.dart';
import '../texte.dart';
import 'satz.dart';
import 'satz_stil.dart';

// Steckbriefe und Charakterübersicht (K3, A-059, M5): für die Wochen vor dem Abend.
// Ohne Fall-Code, ohne Druckspielsatz, ohne Pfad: Jede Seite sieht in jedem Fall gleich
// aus. Von einer Figur kommen nur Name, Aussprache, Rollentitel, Alter, Alltag und
// Farbe aus figuren.json, „Wer du bist“ und der Besetzungshinweis aus dem pfadfreien
// Dossier (DossierRoh) und Kostüm, Auftritt und Satz aus steckbriefe.json. Nie:
// Loyalität, Aussehen der Tatnacht (visualSpecs), Lügen, Geheimnis, Motiv, Alibi,
// Profile, Stufe (tier) oder ob jemand als Täter in Frage kommt.

/// Alles, was Steckbrief und Charakterübersicht zum Setzen brauchen: Kanon, Texte,
/// Stil und die Steckbriefe der Akte. Kein Fall-Code, kein [DruckKontext].
class SteckbriefKontext {
  SteckbriefKontext(this.kanon, this.texte, this.stil, {required this.steckbriefe, this.detektiv = 'w'});

  final Kanon kanon;
  final Texte texte;
  final DruckStil stil;
  final Steckbriefe steckbriefe;

  /// Detektiv oder Detektivin (m/w) für den Steckbrief des Detektivs.
  final String detektiv;

  String get fallTitel => kanon.fall['titel'] as String;

  String ui(String kennung, [Map<String, String> werte = const {}]) {
    var t = texte.baustein(kennung);
    for (final e in werte.entries) {
      t = t.replaceAll('{${e.key}}', e.value);
    }
    return t;
  }

  /// Ein neuer Kontext für den anderen Detektiv (m/w).
  SteckbriefKontext mitDetektiv(String g) => SteckbriefKontext(kanon, texte, stil, steckbriefe: steckbriefe, detektiv: g);
}

/// Was ein Steckbrief von einer Figur zeigt. Nur diese Felder verlassen den Kanon.
class SteckbriefFigur {
  final String id, name, aussprache, titel, alltag, wer, besetzung, farbe;
  final int? alter;
  final SteckbriefEintrag eintrag;
  const SteckbriefFigur({
    required this.id,
    required this.name,
    required this.aussprache,
    required this.titel,
    required this.alltag,
    required this.wer,
    required this.besetzung,
    required this.farbe,
    required this.alter,
    required this.eintrag,
  });
}

/// Die Angaben zu [id] (eine Figur oder `Besetzung.detektiv`). Beim Detektiv
/// stehen Name, Titel und Alltag als Bausteine, [uebersicht] wählt die
/// neutrale Form der Charakterübersicht („Detektiv oder Detektivin“).
SteckbriefFigur steckbriefFigur(SteckbriefKontext k, String id, {bool uebersicht = false}) {
  final eintrag = k.steckbriefe.von(id);
  if (id == Besetzung.detektiv) {
    final d = k.kanon.figurenJson['detektiv'] as Map;
    return SteckbriefFigur(
      id: id,
      name: k.ui(uebersicht ? 'ui.druck.uebersicht.detektiv' : 'ui.druck.steckbrief.detektiv.${k.detektiv}'),
      aussprache: '',
      titel: k.ui('ui.druck.steckbrief.detektiv_titel'),
      alltag: k.ui('ui.druck.steckbrief.detektiv_alltag'),
      wer: k.texte.baustein('detektiv.${k.detektiv}.wer'),
      besetzung: k.ui('ui.druck.steckbrief.detektiv_besetzung'),
      farbe: d['colorCode'] as String,
      alter: null,
      eintrag: eintrag,
    );
  }
  final f = k.kanon.figur(id) ?? (throw ArgumentError('unbekannte Figur $id'));
  final roh = k.texte.sammlung.dossiers[id] ?? (throw StateError('kein Dossier für $id'));
  return SteckbriefFigur(
    id: id,
    name: f['name'] as String,
    aussprache: (f['aussprache'] ?? '') as String,
    titel: (f['roleTitle'] ?? '') as String,
    alltag: (f['alltag'] ?? '') as String,
    wer: roh.wer,
    besetzung: roh.besetzung,
    farbe: f['colorCode'] as String,
    alter: (f['age'] as num?)?.toInt(),
    eintrag: eintrag,
  );
}

/// Sortierschlüssel nach DIN 5007 (Umlaute wie ihr Grundbuchstabe).
String _sortier(String s) => s.toLowerCase().replaceAll('ä', 'a').replaceAll('ö', 'o').replaceAll('ü', 'u').replaceAll('ß', 'ss');

/// Die wählbaren Figuren der Übersicht: zuerst der Detektiv, den es immer gibt,
/// dann die Figuren alphabetisch nach Namen, nie in Besetzungsreihenfolge. Mit
/// [rollen] nur die Figuren, die bei dieser Personenzahl dabei sind (`besetzt(n)`).
List<String> uebersichtFiguren(SteckbriefKontext k, {int? rollen}) {
  final figuren = rollen == null ? [for (final f in k.kanon.figuren) f['id'] as String] : k.texte.besetzung.besetzt(rollen);
  String name(String id) => _sortier(k.kanon.figur(id)!['name'] as String);
  return [Besetzung.detektiv, ...figuren.toList()..sort((a, b) => name(a).compareTo(name(b)))];
}

// ---------------------------------------------------------------- Steckbrief

/// Je Figur eine A4-Seite (alle wählbaren, mit [rollen] die bei dieser Zahl, mit
/// [figuren] genau diese). Eine Schriftgröße für alle Figuren der Akte, damit eine
/// Seite allein und im Stapel gleich aussieht. Passt eine Seite nicht, ist das ein
/// Fehler (Überlauf, [DruckStil.passendeGroesse]).
void steckbriefe(pw.Document doc, SteckbriefKontext k, {int? rollen, Iterable<String>? figuren}) {
  final g = _steckbriefGroesse(k);
  for (final id in figuren ?? uebersichtFiguren(k, rollen: rollen)) {
    final f = steckbriefFigur(k, id);
    doc.addPage(pw.Page(
      pageFormat: DruckStil.format,
      margin: DruckStil.rand,
      build: (c) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _steckbriefKopf(k, f),
          _steckbriefInhalt(k, f, g),
          pw.Spacer(),
          _ohneGeheimnis(k),
          pw.SizedBox(height: _fussAbstand),
          k.stil.fuss(c, k.fallTitel),
        ],
      ),
    ));
  }
}

const _fussAbstand = 10.0;
const _fussHoehe = 14.0;

final _groessen = Expando<double>();

/// Größte Schriftgröße, bei der jeder Steckbrief der Akte auf seine Seite passt.
double _steckbriefGroesse(SteckbriefKontext k) => _groessen[k] ??= [
      for (final id in uebersichtFiguren(k))
        () {
          final f = steckbriefFigur(k, id);
          final frei = DruckStil.format.height -
              DruckStil.rand.top -
              DruckStil.rand.bottom -
              k.stil.hoehe(_steckbriefKopf(k, f), DruckStil.breite) -
              k.stil.hoehe(_ohneGeheimnis(k), DruckStil.breite) -
              _fussAbstand -
              _fussHoehe;
          return k.stil.passendeGroesse((g) => _steckbriefInhalt(k, f, g), DruckStil.breite, frei, wo: 'Steckbrief $id');
        }(),
    ].reduce(min);

/// Kopf: Marke, Farbbalken, Name, Rollentitel, Aussprache und Alter.
pw.Widget _steckbriefKopf(SteckbriefKontext k, SteckbriefFigur f) {
  final zeile = [
    if (f.aussprache.isNotEmpty) k.ui('ui.druck.steckbrief.aussprache', {'aussprache': f.aussprache}),
    if (f.alter != null) k.ui('ui.druck.steckbrief.alter', {'alter': '${f.alter}'}),
  ].join('  ·  ');
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(k.ui('ui.druck.steckbrief.marke').toUpperCase(), style: k.stil.marke(10)),
          pw.Text(k.fallTitel, style: k.stil.marke(9)),
        ],
      ),
      pw.SizedBox(height: 10),
      pw.Container(
        width: DruckStil.breite,
        height: 14,
        decoration: pw.BoxDecoration(color: PdfColor.fromHex(f.farbe), border: pw.Border.all(color: DruckStil.linie, width: 0.6)),
      ),
      pw.SizedBox(height: 16),
      pw.Text(f.name, style: k.stil.titel(40)),
      pw.SizedBox(height: 4),
      pw.Text(f.titel, style: k.stil.ueberschrift(16)),
      if (zeile.isNotEmpty) ...[
        pw.SizedBox(height: 4),
        pw.Text(zeile, style: k.stil.text(11)),
      ],
      pw.SizedBox(height: 10),
      pw.Container(height: 0.8, color: DruckStil.linie),
      pw.SizedBox(height: 12),
    ],
  );
}

/// Inhalt: Alltag, Wer du bist, Kostümtipp, Auftritt, Satz, Besetzung.
pw.Widget _steckbriefInhalt(SteckbriefKontext k, SteckbriefFigur f, double g) => pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        if (f.alltag.isNotEmpty) k.stil.abschnitt(k.ui('ui.druck.steckbrief.alltag'), [f.alltag], groesse: g),
        k.stil.abschnitt(k.ui('ui.druck.steckbrief.wer'), [f.wer], groesse: g),
        k.stil.abschnitt(k.ui('ui.druck.steckbrief.kostuem'), [f.eintrag.kostuem], groesse: g),
        k.stil.abschnitt(k.ui('ui.druck.steckbrief.auftritt'), [_punkte(f.eintrag.auftritt)], groesse: g),
        k.stil.abschnitt(k.ui('ui.druck.steckbrief.satz'), [k.ui('ui.druck.steckbrief.zitat', {'satz': f.eintrag.satz})], groesse: g),
        k.stil.abschnitt(k.ui('ui.druck.steckbrief.besetzung'), [f.besetzung], groesse: g),
      ],
    );

pw.Widget _ohneGeheimnis(SteckbriefKontext k) => pw.Container(
      width: DruckStil.breite,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(border: pw.Border.all(color: DruckStil.tinte, width: 1)),
      child: pw.Text(k.ui('ui.druck.steckbrief.ohne_geheimnis'), style: k.stil.text(11)),
    );

String _punkte(List<String> zeilen) => [for (final z in zeilen) '– $z'].join('\n');

// ---------------------------------------------------------------- Charakterübersicht

/// Karten der Übersicht: zwei je Zeile, alle gleich groß.
const _kartenAbstand = 12.0;
const _kartenHoehe = 124.0;
const _farbStreifen = 7.0;
const _kartenRand = 9.0;
double get _kartenBreite => (DruckStil.breite - _kartenAbstand) / 2;
double get _innenBreite => _kartenBreite - _farbStreifen - 2 * _kartenRand - 1.6;
const _innenHoehe = _kartenHoehe - 2 * _kartenRand - 1.6;

/// Alle wählbaren Figuren als gleich große Karten ([uebersichtFiguren]): mit [rollen]
/// nur die Figuren bei dieser Personenzahl und der Satz „Bei n Personen sind diese
/// Figuren dabei“, ohne alle mit dem Hinweis, dass es auf die Zahl ankommt.
void charakteruebersicht(pw.Document doc, SteckbriefKontext k, {int? rollen}) {
  final ids = uebersichtFiguren(k, rollen: rollen);
  final g = _kartenGroesse(k);
  final karten = [for (final id in ids) _karte(k, steckbriefFigur(k, id, uebersicht: true), g)];
  doc.addPage(pw.MultiPage(
    pageFormat: DruckStil.format,
    margin: DruckStil.rand,
    footer: (c) => pw.Padding(padding: const pw.EdgeInsets.only(top: 6), child: k.stil.fuss(c, k.fallTitel)),
    build: (c) => [
      k.stil.kopf(k.ui('ui.druck.uebersicht.marke'), k.fallTitel),
      pw.Text(
        rollen == null ? k.ui('ui.druck.uebersicht.ohne_zahl') : k.ui('ui.druck.uebersicht.mit_zahl', {'anzahl': '$rollen'}),
        style: k.stil.text(12),
      ),
      pw.SizedBox(height: 4),
      pw.Text(k.ui('ui.druck.uebersicht.waehlen'), style: k.stil.text(11)),
      pw.SizedBox(height: 14),
      for (var i = 0; i < karten.length; i += 2)
        pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: _kartenAbstand),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              karten[i],
              pw.SizedBox(width: _kartenAbstand),
              if (i + 1 < karten.length) karten[i + 1] else pw.SizedBox(width: _kartenBreite, height: _kartenHoehe),
            ],
          ),
        ),
    ],
  ));
}

final _kartenGroessen = Expando<double>();

/// Eine Schriftgröße für alle Karten der Akte: die kleinste, bei der jede Karte passt.
double _kartenGroesse(SteckbriefKontext k) => _kartenGroessen[k] ??= [
      for (final id in uebersichtFiguren(k))
        k.stil.passendeGroesse((g) => _karteInhalt(k, steckbriefFigur(k, id, uebersicht: true), g), _innenBreite, _innenHoehe,
            start: 10.5, wo: 'Übersicht $id'),
    ].reduce(min);

pw.Widget _karte(SteckbriefKontext k, SteckbriefFigur f, double g) => pw.Container(
      width: _kartenBreite,
      height: _kartenHoehe,
      decoration: pw.BoxDecoration(border: pw.Border.all(color: DruckStil.linie, width: 0.8)),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          pw.Container(width: _farbStreifen, color: PdfColor.fromHex(f.farbe)),
          pw.Padding(
            padding: const pw.EdgeInsets.all(_kartenRand),
            child: pw.SizedBox(width: _innenBreite, child: _karteInhalt(k, f, g)),
          ),
        ],
      ),
    );

/// Name, Rollentitel, Aussprache und Alter, Alltag und der typische Satz.
pw.Widget _karteInhalt(SteckbriefKontext k, SteckbriefFigur f, double g) {
  final zeile = [
    if (f.aussprache.isNotEmpty) k.ui('ui.druck.steckbrief.aussprache', {'aussprache': f.aussprache}),
    if (f.alter != null) k.ui('ui.druck.steckbrief.alter', {'alter': '${f.alter}'}),
  ].join('  ·  ');
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(f.name, style: k.stil.ueberschrift(15)),
      pw.SizedBox(height: 1),
      pw.Text(f.titel, style: pw.TextStyle(font: k.stil.stark, fontSize: g, color: DruckStil.tinte)),
      if (zeile.isNotEmpty) pw.Text(zeile, style: k.stil.klein(DruckStil.minGroesse)),
      pw.SizedBox(height: 4),
      pw.Text(f.alltag, style: k.stil.text(g)),
      pw.SizedBox(height: 3),
      pw.Text(k.ui('ui.druck.steckbrief.zitat', {'satz': f.eintrag.satz}), style: k.stil.text(g)),
    ],
  );
}

// ---------------------------------------------------------------- Dateien

/// Zusatz für Dateinamen bei gewählter Personenzahl.
String _zahl(int? rollen) => rollen == null ? '' : '-$rollen-personen';

/// Ein Dokument mit dem Titel „Falltitel · [titel]“, gefüllt von [setzen].
pw.Document _dokument(SteckbriefKontext k, String titel, void Function(pw.Document) setzen) {
  final doc = k.stil.neuesDokument('${k.fallTitel} · $titel');
  setzen(doc);
  return doc;
}

/// Die Charakterübersicht als Datei (`charakteruebersicht[-n-personen].pdf`).
Future<DruckDatei> uebersichtDatei(SteckbriefKontext k, {int? rollen}) async {
  final doc = _dokument(k, k.ui('ui.druck.datei.uebersicht'), (d) => charakteruebersicht(d, k, rollen: rollen));
  return DruckDatei('charakteruebersicht${_zahl(rollen)}.pdf', await doc.save());
}

/// Der Steckbrief einer Figur als Datei (`steckbrief-<figur>.pdf`, A-059).
Future<DruckDatei> steckbriefDatei(SteckbriefKontext k, String figur) async {
  final f = steckbriefFigur(k, figur);
  final doc = _dokument(k, '${k.ui('ui.druck.steckbrief.marke')} · ${f.name}', (d) => steckbriefe(d, k, figuren: [figur]));
  final wort = figur == Besetzung.detektiv ? 'detektiv' : dateiWort(f.name);
  return DruckDatei('steckbrief-$wort.pdf', await doc.save(), figur: figur);
}

/// Übersicht und alle Steckbriefe in einer Datei (`steckbriefe[-n-personen].pdf`).
Future<DruckDatei> steckbriefeGesamt(SteckbriefKontext k, {int? rollen}) async {
  final doc = _dokument(k, k.ui('ui.druck.datei.steckbriefe'), (d) {
    charakteruebersicht(d, k, rollen: rollen);
    steckbriefe(d, k, rollen: rollen);
  });
  return DruckDatei('steckbriefe${_zahl(rollen)}.pdf', await doc.save());
}

/// Alle Dateien vor dem Abend: Übersicht, Übersicht mit allen Steckbriefen und je
/// Figur ein Steckbrief (Reihenfolge wie [uebersichtFiguren]).
Future<List<DruckDatei>> steckbriefDateien(SteckbriefKontext k, {int? rollen}) async => [
      await uebersichtDatei(k, rollen: rollen),
      await steckbriefeGesamt(k, rollen: rollen),
      for (final id in uebersichtFiguren(k, rollen: rollen)) await steckbriefDatei(k, id),
    ];
