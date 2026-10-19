// K3, A-059, M5: Steckbriefe und Charakterübersicht für die Wochen vor dem Abend.
// Geprüft wird das fertige PDF (pdfinfo, pdftotext): A4 und kein Überlauf, je Figur genau
// eine Seite, nichts aus den geheimen Feldern und kein Pfadwissen (Fünf-Wort-Folgen), gleich
// über Fall-Codes und Pfade, die Übersicht bei n Personen zeigt genau besetzt(n) alphabetisch.
import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/party_druck.dart';
import 'package:test/test.dart';

import 'druck_hilfe.dart';
import 'kanon_hilfe.dart';

Steckbriefe _steckbriefe([Map<String, Object?>? json]) =>
    Steckbriefe.ausJson(json ?? leseJson('$repoWurzel/content/party/schlosskeller/steckbriefe.json'));

SteckbriefKontext _kontext({String detektiv = 'w'}) => SteckbriefKontext(kanon, druckTexte, druckStil, steckbriefe: _steckbriefe(), detektiv: detektiv);

/// Fünf-Wort-Folgen aus Texten, die nur in einem Teil der Pfade gelten (wie spoiler_test): Spuren
/// mit Rolle, Beobachtungen ohne „alle“, Täter- und Unschuldsprofile der Kernfiguren, Ereignisse
/// der Tatmatrizen. Folgen, die auch in pfadneutralen Kanon-Texten stehen, zählen nicht.
Map<String, String> _pfadwissen() {
  final neutral = {
    for (final b in kanon.beobachtungen)
      if (b['pfade'] == 'alle') ...fuenfWortFolgen(b['text'] as String),
    for (final z in kanon.zeitleiste)
      if (z['pfade'] == 'alle') ...fuenfWortFolgen(z['text'] as String),
    for (final g in kanon.gegenstaende)
      if (g['beschreibung'] is String) ...fuenfWortFolgen(g['beschreibung'] as String),
  };
  final q = <String, String>{};
  void add(String wo, String text) {
    for (final f in fuenfWortFolgen(text)) {
      if (!neutral.contains(f)) q.putIfAbsent(f, () => wo);
    }
  }

  for (final g in kanon.gegenstaende) {
    for (final s in (g['spuren'] as List? ?? const [])) {
      if ((s as Map).containsKey('rolle')) add('Spur ${s['id']}', s['zeigt'] as String);
    }
  }
  for (final b in kanon.beobachtungen) {
    if (b['pfade'] != 'alle') add('Beobachtung ${b['id']}', b['text'] as String);
    if (b['pfade'] != 'alle' && b['duText'] is String) add('Beobachtung ${b['id']} (du)', b['duText'] as String);
  }
  for (final p in kanon.pfade) {
    for (final e in kanon.json['tatmatrix/$p.json']!['ereignisse'] as List) {
      if ((e as Map)['text'] is String) add('Ereignis ${e['id']}', e['text'] as String);
    }
  }
  return q;
}

/// Was nie auf einem Steckbrief steht: die geheimen Felder als Fünf-Wort-Folgen, dazu das Pfadwissen.
/// Ausgenommen sind Folgen, die auch in den erlaubten Quellen stehen ([erlaubt]): Die pfadfreie
/// Vorstellung `wer` beschreibt dasselbe Aussehen und dieselbe Freundschaft, nie die Tatnacht.
Map<String, String> _verboten(Set<String> erlaubt) => {
      for (final e in {
        for (final e in geheimeFelder(kanon).entries)
          for (final f in fuenfWortFolgen(e.value)) f: e.key,
        ..._pfadwissen(),
      }.entries)
        if (!erlaubt.contains(e.key)) e.key: e.value,
    };

/// Fünf-Wort-Folgen der erlaubten Quellen eines Steckbriefs: Name, Rollentitel, Alltag, Wer du bist, Besetzung.
Set<String> _erlaubt(SteckbriefKontext k) => {
      for (final id in uebersichtFiguren(k))
        for (final t in [steckbriefFigur(k, id).alltag, steckbriefFigur(k, id).wer, steckbriefFigur(k, id).besetzung]) ...fuenfWortFolgen(t),
    };

/// Wörter, die auf keinem Steckbrief und keiner Übersicht stehen.
const _woerter = ['Täter', 'Täterin', 'verdächtig', 'Verdächtige', 'Kernrolle', 'Fassung', 'Fall-Code', 'Geburtstag', 'Geburtstagskind'];

void main() {
  late SteckbriefKontext k;
  late String alle;
  late PdfBefund gesamt;

  setUpAll(() async {
    k = _kontext();
    gesamt = pdfPruefen((await steckbriefeGesamt(k)).bytes);
    alle = flach(gesamt.text);
  });

  test('die Steckbriefe der Akte sind vollständig und ohne Befund (pruefeSteckbriefe)', () {
    final b = pruefeSteckbriefe(k.steckbriefe, kanon, ton: Textpruefer(leseJson('$repoWurzel/content/party/textregeln.json')));
    expect(b, isEmpty, reason: b.join('\n'));
    expect(k.steckbriefe.je.keys.toSet(), {for (final f in kanon.figuren) f['id'] as String, Besetzung.detektiv});
  });

  test('Rot-Proben: geheimes Aussehen, Geburtstag, Uhrzeit, fremder Name, zu viele Wörter und eine fehlende Figur fallen auf', () {
    final j = leseJson('$repoWurzel/content/party/schlosskeller/steckbriefe.json');
    final eintraege = [for (final e in j['eintraege'] as List) Map<String, Object?>.of(e as Map<String, Object?>)];
    final ahmet = kanon.figur('ahmet')!;
    eintraege[0]['kostuem'] = (ahmet['visualSpecs'] as Map)['outfit'];
    eintraege[1]['satz'] = 'Heute feiern wir Geburtstag.';
    eintraege[2]['auftritt'] = ['Sei um zwölf an der Theke', 'Komm 23:55 zurück'];
    eintraege[3]['auftritt'] = ['Bleib nah bei Emine', 'Lach viel und gern', 'Sing laut', 'Tanz wild'];
    eintraege[4]['kostuem'] = 'Ein sehr langer Mantel mit vielen bunten und glänzenden Knöpfen';
    eintraege.removeLast();
    final b = pruefeSteckbriefe(_steckbriefe({...j, 'eintraege': eintraege}), kanon);
    expect(b.where((x) => x.startsWith('Steckbrief ahmet.kostuem') && x.contains('visualSpecs')), isNotEmpty, reason: b.join('\n'));
    expect(b.where((x) => x.contains('fatma.satz: Geburtstag')), isNotEmpty);
    expect(b.where((x) => x.contains('olli.auftritt[1]: Ziffern')), isNotEmpty);
    expect(b.where((x) => x.contains('can: 4 Auftritts-Stichpunkte')), isNotEmpty);
    expect(b.where((x) => x.contains('can.auftritt[0]: nennt Emine')), isNotEmpty);
    expect(b.where((x) => x.contains('leyla.kostuem') && x.contains('Wörter')), isNotEmpty);
    expect(b, contains('Steckbrief ${Besetzung.detektiv} fehlt'));
  });

  test('alle Steckbriefe: A4, je Figur genau eine Seite, kein Überlauf, Übersicht vorneweg', () async {
    final ueb = pdfPruefen((await uebersichtDatei(k)).bytes);
    expect(ueb.a4, isTrue);
    expect(gesamt.a4, isTrue);
    expect(gesamt.seiten, ueb.seiten + kanon.figuren.length + 1);
    for (final id in uebersichtFiguren(k)) {
      final b = pdfPruefen((await steckbriefDatei(k, id)).bytes);
      expect(b.a4, isTrue, reason: id);
      expect(b.seiten, 1, reason: '$id: ein Steckbrief, eine Seite');
    }
  });

  test('jeder Steckbrief zeigt Name, Aussprache, Rolle, Alter, Alltag, Wer du bist, Kostüm, Auftritt, Satz und Besetzung', () async {
    for (final id in uebersichtFiguren(k)) {
      final f = steckbriefFigur(k, id);
      final text = flach(pdfPruefen((await steckbriefDatei(k, id)).bytes).text);
      for (final teil in [
        f.name,
        f.titel,
        if (f.aussprache.isNotEmpty) k.ui('ui.druck.steckbrief.aussprache', {'aussprache': f.aussprache}),
        if (f.alter != null) k.ui('ui.druck.steckbrief.alter', {'alter': '${f.alter}'}),
        f.alltag,
        f.wer,
        f.eintrag.kostuem,
        ...f.eintrag.auftritt,
        k.ui('ui.druck.steckbrief.zitat', {'satz': f.eintrag.satz}),
        f.besetzung,
        k.ui('ui.druck.steckbrief.ohne_geheimnis'),
      ]) {
        expect(text, contains(flach(teil)), reason: '$id: $teil');
      }
    }
    // Der Detektiv heißt im eigenen Steckbrief Detektiv oder Detektivin, je nach Wahl.
    expect(flach(pdfPruefen((await steckbriefDatei(_kontext(detektiv: 'm'), Besetzung.detektiv)).bytes).text),
        contains(k.ui('ui.druck.steckbrief.detektiv.m')));
  });

  test('pdftotext: kein Wort aus den geheimen Feldern, kein Pfadwissen als Fünf-Wort-Folge, keine verräterischen Wörter', () async {
    final verboten = _verboten(_erlaubt(k));
    expect(verboten, isNotEmpty);
    expect(verboten.values.where((q) => q.contains('roleSecret')), isNotEmpty, reason: 'Die Probe kennt die geheimen Felder');
    final texte = {
      'alle Steckbriefe': alle,
      for (final n in [4, 12]) 'Übersicht bei $n': flach(pdfPruefen((await uebersichtDatei(k, rollen: n)).bytes).text),
      'Detektiv m': flach(pdfPruefen((await steckbriefDatei(_kontext(detektiv: 'm'), Besetzung.detektiv)).bytes).text),
    };
    for (final e in texte.entries) {
      final funde = [
        for (final f in fuenfWortFolgen(e.value))
          if (verboten[f] case final q?) '„$f“ aus $q',
      ];
      expect(funde, isEmpty, reason: '${e.key}:\n${funde.join('\n')}');
      for (final w in _woerter) {
        expect(RegExp('(?<!\\p{L})${RegExp.escape(w)}(?!\\p{L})', unicode: true, caseSensitive: false).hasMatch(e.value), isFalse,
            reason: '${e.key}: „$w“');
      }
      // Keine Uhrzeit: Zeiten der Tatnacht sind Fallwissen.
      expect(RegExp(r'\d{1,2}:\d{2}').hasMatch(e.value), isFalse, reason: '${e.key}: Uhrzeit');
    }
  });

  test('gleich über Fall-Codes und Pfade: „Wer du bist“ ist das Wer jedes Rollenhefts in jedem Pfad, der Satz ist reproduzierbar', () async {
    final codes = [for (final p in kanon.pfade) FallCode.fuerPfad(p, kanon.pfade)];
    final saetze = [for (final c in codes) DruckSatz.aus(kanon, druckTexte, c, rollen: 20, detektiv: 'w')];
    for (final f in kanon.figuren) {
      final id = f['id'] as String;
      final wer = steckbriefFigur(k, id).wer;
      for (final s in saetze) {
        expect(s.rollenhefte[id]!.wer, wer, reason: '${s.code.code}: $id');
      }
    }
    // Der Kontext kennt weder Code noch Pfad: Zweimal gesetzt ergibt denselben Text.
    final nochmal = flach(pdfPruefen((await steckbriefeGesamt(_kontext())).bytes).text);
    expect(nochmal, alle);
    for (final n in [7, 20]) {
      final a = flach(pdfPruefen((await uebersichtDatei(k, rollen: n)).bytes).text);
      final b = flach(pdfPruefen((await uebersichtDatei(_kontext(), rollen: n)).bytes).text);
      expect(a, b, reason: 'Übersicht bei $n');
    }
  });

  test('Übersicht bei n: genau die Figuren aus besetzt(n), alphabetisch, nie in Besetzungsreihenfolge, der Detektiv vorn', () {
    final b = Besetzung(kanon);
    for (var n = b.minRollen; n <= b.maxRollen; n++) {
      final ids = uebersichtFiguren(k, rollen: n);
      expect(ids.first, Besetzung.detektiv);
      final figuren = ids.skip(1).toList();
      for (final id in figuren) {
        expect(b.besetzt(n), contains(id), reason: 'n=$n: $id ist in der Lobby zuteilbar');
      }
      expect(figuren.toSet(), b.besetzt(n).toSet(), reason: 'n=$n');
      final namen = [for (final id in figuren) kanon.figur(id)!['name'] as String];
      expect(namen, [...namen]..sort(), reason: 'n=$n: alphabetisch');
    }
    // Bei vier Personen wäre die Besetzungsreihenfolge Ahmet, Fatma, Olli, Can.
    expect(uebersichtFiguren(k, rollen: 4).skip(1), isNot(b.besetzt(4)));
    expect(uebersichtFiguren(k).skip(1).toSet(), {for (final f in kanon.figuren) f['id'] as String});
  });

  for (final n in [4, 12]) {
    test('Übersicht bei $n Personen: Hinweis, gleich große Karten nur der besetzten Figuren, A4', () async {
      final b = pdfPruefen((await uebersichtDatei(k, rollen: n)).bytes);
      expect(b.a4, isTrue);
      final text = flach(b.text);
      expect(text, contains(flach(k.ui('ui.druck.uebersicht.mit_zahl', {'anzahl': '$n'}))));
      expect(text, contains(flach(k.ui('ui.druck.uebersicht.detektiv'))));
      final besetzt = Besetzung(kanon).besetzt(n);
      for (final f in kanon.figuren) {
        final name = f['name'] as String;
        final da = RegExp('(?<!\\p{L})${RegExp.escape(name)}(?!\\p{L})', unicode: true).hasMatch(text);
        expect(da, besetzt.contains(f['id']), reason: 'n=$n: $name');
      }
    });
  }

  test('Übersicht ohne Zahl: alle Figuren mit dem Hinweis, dass es auf die Zahl ankommt', () async {
    final text = flach(pdfPruefen((await uebersichtDatei(k)).bytes).text);
    expect(text, contains(flach(k.ui('ui.druck.uebersicht.ohne_zahl'))));
    for (final f in kanon.figuren) {
      expect(text, contains(f['name'] as String));
    }
  });

  test('Dateien: Übersicht, alles in einer Datei, je Figur ein Steckbrief mit Figurennamen (A-059)', () async {
    final dateien = await steckbriefDateien(k, rollen: 5);
    final ids = uebersichtFiguren(k, rollen: 5);
    expect(dateien.map((d) => d.name).take(2), ['charakteruebersicht-5-personen.pdf', 'steckbriefe-5-personen.pdf']);
    expect([for (final d in dateien.skip(2)) d.figur], ids);
    expect([for (final d in dateien.skip(2)) d.name], [
      'steckbrief-detektiv.pdf',
      for (final id in ids.skip(1)) 'steckbrief-${dateiWort(kanon.figur(id)!['name'] as String)}.pdf',
    ]);
    expect((await steckbriefDateien(k)).map((d) => d.name).take(2), ['charakteruebersicht.pdf', 'steckbriefe.pdf']);
  });
}
