// F6-GEGEN-05 (E-040): Nachbesserungen am Druckspiel nach der Nachprüfung.
// Ermittlungsbogen mit allen Arten der Indizkarten, gewählte Rundendauer im Heft,
// Vier-Rollen-Abend ohne Gästekarten, Streifentext der Fassung, Rollenheft sagt „Fassung“.
import 'package:mordakte_core/src/party/druck/rollen.dart';
import 'package:mordakte_core/src/party/druck/satz.dart';
import 'package:mordakte_core/src/party/druck/spielleitung.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:test/test.dart';

import 'druck_hilfe.dart';
import 'kanon_hilfe.dart';

Future<String> _pdf(void Function(pw.Document, DruckKontext) teil, DruckKontext k) async {
  final doc = k.stil.neuesDokument('Test');
  teil(doc, k);
  return flach(pdfPruefen(await doc.save()).text);
}

void main() {
  test('Ermittlungsbogen hat für jede Art, die eine Indizkarte ankreuzen lässt, eine Zeile', () {
    for (final p in kanon.pfade) {
      final k = druckKontext(pfad: p, n: 7);
      final arten = {for (final karte in k.satz.indizkarten) for (final kreuz in karte.kreuze) kreuz.typ};
      expect(arten.difference(k.satz.ermittlungsbogen.typen.toSet()), isEmpty, reason: p);
      expect(k.satz.ermittlungsbogen.typen, contains('motiv'));
    }
  });

  test('Rot-Probe: ein Bogen ohne Motiv-Zeile fiele auf', () {
    final k = druckKontext(pfad: 'ahmet', n: 7);
    final arten = {for (final karte in k.satz.indizkarten) for (final kreuz in karte.kreuze) kreuz.typ};
    expect(arten.difference({...k.satz.ermittlungsbogen.typen}..remove('motiv')), contains('motiv'));
  });

  test('das Spielleitungsheft nennt die gewählte Rundendauer, ohne Angabe die Vorgabe', () async {
    final k45 = druckKontext(pfad: 'olli', n: 7, dauer: 45);
    expect(k45.satz.rundendauerMinuten, 45);
    // Modell befragung (A-051): Die Uhr steht im Baustein der Tischgespräche und Befragungen.
    expect(await _pdf(spielleitungsheft, k45), contains(flach(k45.ui('ui.druck.spielleitung.befragungen', {'minuten': '45'}))));
    final k = druckKontext(pfad: 'olli', n: 7);
    expect(k.satz.rundendauerMinuten, kanon.fall['rundendauerMinuten']);
  });

  test('bei vier Rollen sprechen Vorbereitung und Gruppenwahl nur von Fassungsstreifen', () async {
    final k4 = druckKontext(pfad: 'can', n: 4);
    final heft4 = await _pdf(spielleitungsheft, k4);
    expect(heft4, contains(flach(k4.ui('ui.druck.spielleitung.teile.stimme_keine'))));
    expect(heft4, contains(flach(k4.ui('ui.druck.spielleitung.gruppenwahl_kern'))));
    expect(heft4, isNot(contains(flach(k4.ui('ui.druck.spielleitung.teile.stimme')))));
    expect(heft4, isNot(contains(flach(k4.ui('ui.druck.spielleitung.gruppenwahl')))));
    final k9 = druckKontext(pfad: 'can', n: 9);
    final heft9 = await _pdf(spielleitungsheft, k9);
    expect(heft9, contains(flach(k9.ui('ui.druck.spielleitung.gruppenwahl'))));
    expect(heft9, isNot(contains(flach(k9.ui('ui.druck.spielleitung.gruppenwahl_kern')))));
  });

  test('die Streifen der Fassung sagen „nur den Streifen deiner Wahl“, das Rollenheft sagt „Fassung“', () async {
    final k = druckKontext(pfad: 'fatma', n: 7);
    final fassungen_ = await _pdf(fassungen, k);
    expect(fassungen_, contains(flach(k.ui('ui.druck.stimme.falz_fassung'))));
    expect(fassungen_, isNot(contains(flach(k.ui('ui.druck.stimme.falz')))));
    final hefte = await _pdf(rollenhefte, k);
    for (final f in k.satz.fassungen) {
      expect(hefte, contains(flach(k.ui('ui.druck.rollen.umschlag', {'code': f.code}))), reason: f.rolle);
    }
    expect(hefte, isNot(contains('Dein Umschlag')));
  });
}
