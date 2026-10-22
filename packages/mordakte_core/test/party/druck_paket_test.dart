// Druckpaket für den Veranstalter (Abend am Bildschirm): vier Ordner, festlicher Stil.
// Geprüft wird das fertige PDF (pdfinfo, pdftotext): vollständige Ordner, alle Seiten A4,
// kein Überlauf (sonst bricht der Satz ab), Ordner 1 und 2 spoilerfrei wie die
// Steckbriefe (K3), jedes Rollenheft ohne geheime Fünf-Wort-Folgen anderer Rollen, die
// vier Kernhefte gleich lang und gleich gebaut, gleiche Eingaben ⇒ gleiche Bytes.
// Die Datei setzt das ganze Paket zweimal und dazu die Kernhefte aller Pfade: wie die
// anderen schweren Kerntests mit eigenem Zeitlimit (im vollen Kernlauf teilen sich vier
// Prozesse die Kerne; 30 s reichten dort nicht).
@Timeout(Duration(minutes: 2))
library;

import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/party_druck.dart';
import 'package:test/test.dart';

import 'druck_hilfe.dart';
import 'kanon_hilfe.dart';

FestStil? _fest;
FestStil get festStil => _fest ??= () {
      Uint8List f(String n) => File('$repoWurzel/assets/fonts/$n').readAsBytesSync();
      return FestStil(
        titel: f('PlayfairDisplay-Variabel.ttf'),
        text: f('Lora-Variabel.ttf'),
        kursiv: f('Lora-Kursiv-Variabel.ttf'),
        hand: f('Caveat-Variabel.ttf'),
        maschine: f('SpecialElite-Regular.ttf'),
        funktion: f('Inter-Regular.ttf'),
        funktionStark: f('Inter-SemiBold.ttf'),
      );
    }();

/// Kleine Ersatzporträts (einfarbig, je Figur eine Farbe), damit der Test ohne Flutter läuft.
Map<String, Uint8List> _portraets() => {
      for (final (i, id) in [for (final f in kanon.figuren) f['id'] as String, 'detektiv-w', 'detektiv-m'].indexed)
        id: Uint8List.fromList(img.encodePng(img.Image(width: 48, height: 48)..clear(img.ColorRgb8(40 + 9 * i, 120, 200 - 7 * i)))),
    };

const _pfad = 'fatma';

PaketKontext _kontext({Map<String, Uint8List>? portraets, String pfad = _pfad, int n = 12}) => PaketKontext(
      druckKontext(pfad: pfad, n: n, diashow: Diashow.ausJson(leseJson('$repoWurzel/content/welt/schlosskeller/diashow.json'))),
      steckbriefe: Steckbriefe.ausJson(leseJson('$repoWurzel/content/party/schlosskeller/steckbriefe.json')),
      stil: festStil,
      portraets: portraets ?? _portraets(),
    );

/// Text einer PDF in Satzreihenfolge (-raw: so, wie er gesetzt wurde; Spalten und die
/// Registerlasche laufen nicht ineinander).
String _text(Uint8List bytes) {
  final dir = Directory.systemTemp.createTempSync('paket_test');
  try {
    final f = File('${dir.path}/p.pdf')..writeAsBytesSync(bytes);
    return Process.runSync('pdftotext', ['-raw', f.path, '-']).stdout as String;
  } finally {
    dir.deleteSync(recursive: true);
  }
}

/// Fünf-Wort-Folgen aus Texten, die nur in einem Teil der Pfade gelten (wie steckbrief_test).
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

/// Was nie in Ordner 1 und 2 steht: geheime Felder, Dossiers, Täterfassungen, Finale,
/// Auflösung und Pfadwissen als Fünf-Wort-Folgen, ausgenommen die erlaubten Quellen.
Map<String, String> _verboten(PaketKontext k) {
  final erlaubt = {
    for (final id in [Besetzung.detektiv, for (final f in kanon.figuren) f['id'] as String])
      for (final t in [festFigur(k, id).alltag, festFigur(k, id).wer, festFigur(k, id).besetzung]) ...fuenfWortFolgen(t),
  };
  return {
    for (final e in {
      for (final e in {...steckbriefGeschuetzt(druckTexte), ...geheimeFelder(kanon)}.entries)
        for (final f in fuenfWortFolgen(e.value)) f: e.key,
      ..._pfadwissen(),
    }.entries)
      if (!erlaubt.contains(e.key)) e.key: e.value,
  };
}

/// Geheime Texte einer Rolle in diesem Fall: Ziel, Wissen, Verborgenes, Tat, Tarnung, Wahlen.
List<String> _geheim(DruckSatz satz, String rolle) {
  final d = satz.rollenhefte[rolle]!;
  return [
    d.ziel,
    for (final z in [...d.weiss, ...d.verbirgt, ...d.tatwissen]) ...[z.text, ?z.behauptung],
    ?d.tarnung,
    for (final w in d.wahlen.values)
      if (w != null) ...[w.a, w.b, ?w.sabotage],
  ];
}

/// Alles, was im Heft einer Rolle stehen darf: ihr eigenes Dossier mit Gesprächen und
/// Befragung, die Kurzkarten der anderen.
Set<String> _eigen(PaketKontext k, String rolle) {
  final d = k.druck.satz.rollenhefte[rolle]!;
  return {
    for (final t in [
      ..._geheim(k.druck.satz, rolle),
      d.wer,
      d.besetzung,
      for (final l in d.gespraeche.values)
        for (final (g, _) in l) ...[g.thema, g.ziel, g.text, ...g.stichpunkte],
      for (final l in d.alsPartner.values)
        for (final (g, _) in l) g.thema,
      for (final b in d.befragungen.values)
        if (b != null) ...[b.thema, ...b.fragen, ...b.stichpunkte, for (final z in befragungsZettel(k.texte, b).kartenZeilen((x) => x)) ...z],
      for (final id in k.druck.satz.besetzt) ...[festFigur(k, id).alltag, festFigur(k, id).titel],
    ])
      ...fuenfWortFolgen(t),
  };
}

const _woerter = ['Täter', 'Täterin', 'verdächtig', 'Verdächtige', 'Kernrolle', 'Fassung', 'Geburtstag', 'Geburtstagskind'];

void main() {
  late PaketKontext k;
  late List<PaketDatei> dateien;
  late Map<String, String> text;
  late Map<String, PdfBefund> befund;

  DruckDatei datei(String ordner, String name) => dateien.firstWhere((d) => d.ordner == ordner && d.datei.name == name).datei;

  setUpAll(() async {
    k = _kontext();
    dateien = await paketDateien(k);
    text = {for (final d in dateien) '${d.ordner}/${d.datei.name}': flach(_text(d.datei.bytes))};
    befund = {for (final d in dateien) '${d.ordner}/${d.datei.name}': pdfPruefen(d.datei.bytes)};
  });

  test('Ordner und Dateien vollständig, Dateinamen ohne Umlaute und Leerzeichen', () {
    final namen = [for (final id in k.druck.satz.besetzt) dateiWort(kanon.figur(id)!['name'] as String)];
    expect(namen, hasLength(12));
    expect(namen, containsAll(['lejla', 'joanna', 'marek', 'hana']));
    final soll = {
      '1-an-alle': {'charakteruebersicht.pdf', 'steckbriefe-alle.pdf', for (final n in namen) 'steckbrief-$n.pdf', 'steckbrief-detektivin.pdf', 'steckbrief-detektiv.pdf'},
      '2-veranstalter': {'veranstalter.pdf'},
      '3-je-person-ungelesen-weitergeben': {for (final n in namen) 'rollenheft-$n.pdf', 'detektivbogen-detektivin.pdf', 'detektivbogen-detektiv.pdf'},
      '4-nur-erzaehler': {'erzaehlerheft.pdf'},
    };
    expect(paketOrdner, soll.keys.toList());
    for (final o in paketOrdner) {
      expect({for (final d in dateien.where((d) => d.ordner == o)) d.datei.name}, soll[o], reason: o);
    }
    expect(dateien, hasLength(soll.values.fold<int>(0, (a, s) => a + s.length)));
    for (final d in dateien) {
      expect(RegExp(r'^[a-z0-9-]+\.pdf$').hasMatch(d.datei.name), isTrue, reason: d.datei.name);
    }
  });

  test('alle Seiten A4, Seitenzahlen je Datei', () {
    for (final e in befund.entries) {
      expect(e.value.a4, isTrue, reason: e.key);
    }
    int seiten(String o, String n) => befund['$o/$n']!.seiten;
    expect(seiten('1-an-alle', 'charakteruebersicht.pdf'), 2);
    expect(seiten('1-an-alle', 'steckbriefe-alle.pdf'), 2 + 12 + 2);
    for (final d in dateien.where((d) => d.datei.name.startsWith('steckbrief-'))) {
      expect(seiten(d.ordner, d.datei.name), 1, reason: d.datei.name);
    }
    expect(seiten('2-veranstalter', 'veranstalter.pdf'), 3);
    for (final d in dateien.where((d) => d.datei.name.startsWith('rollenheft-'))) {
      expect(seiten(d.ordner, d.datei.name), rollenheftSeiten, reason: d.datei.name);
    }
    expect(seiten('3-je-person-ungelesen-weitergeben', 'detektivbogen-detektivin.pdf'), seiten('3-je-person-ungelesen-weitergeben', 'detektivbogen-detektiv.pdf'));
    expect(seiten('4-nur-erzaehler', 'erzaehlerheft.pdf'), greaterThanOrEqualTo(6));
  });

  test('Steckbriefe zeigen jede Angabe; die Übersicht genau die zwölf und den Detektiv', () {
    for (final id in [...k.druck.satz.besetzt, Besetzung.detektiv]) {
      for (final g in id == Besetzung.detektiv ? ['w', 'm'] : ['w']) {
        final f = festFigur(k, id, detektiv: g);
        final wort = id == Besetzung.detektiv ? (g == 'w' ? 'detektivin' : 'detektiv') : dateiWort(f.name);
        final t = text['1-an-alle/steckbrief-$wort.pdf']!;
        for (final teil in [
          f.name,
          f.titel.toUpperCase(),
          if (f.aussprache.isNotEmpty) k.ui('ui.druck.steckbrief.aussprache', {'aussprache': f.aussprache}),
          if (f.alter != null) k.ui('ui.druck.steckbrief.alter', {'alter': '${f.alter}'}),
          f.alltag,
          f.wer,
          f.eintrag.kostuem,
          ...f.eintrag.auftritt,
          f.eintrag.satz,
          f.besetzung,
          k.ui('ui.druck.fest.spoilerfrei'),
        ]) {
          expect(t, contains(flach(teil)), reason: '$wort: $teil');
        }
      }
    }
    final ueb = text['1-an-alle/charakteruebersicht.pdf']!;
    expect(ueb, contains(k.ui('ui.druck.fest.uebersicht.titel')));
    for (final f in kanon.figuren) {
      final da = RegExp('(?<!\\p{L})${RegExp.escape(f['name'] as String)}(?!\\p{L})', unicode: true).hasMatch(ueb);
      expect(da, k.druck.satz.besetzt.contains(f['id']), reason: '${f['name']}');
    }
    expect(ueb, contains(flach(k.ui('ui.druck.uebersicht.detektiv'))));
  });

  test('Ordner 1 und 2 spoilerfrei: keine geheime Fünf-Wort-Folge, keine verräterischen Wörter, keine Uhrzeit', () {
    final verboten = _verboten(k);
    expect(verboten.values.where((q) => q.contains('roleSecret')), isNotEmpty, reason: 'Die Probe kennt die geheimen Felder');
    for (final e in text.entries.where((e) => e.key.startsWith('1-') || e.key.startsWith('2-'))) {
      final funde = [
        for (final f in fuenfWortFolgen(e.value))
          if (verboten[f] case final q?) '„$f“ aus $q',
      ];
      expect(funde, isEmpty, reason: '${e.key}:\n${funde.join('\n')}');
      for (final w in [..._woerter, if (e.key.startsWith('1-')) 'Fall-Code']) {
        expect(RegExp('(?<!\\p{L})${RegExp.escape(w)}(?!\\p{L})', unicode: true, caseSensitive: false).hasMatch(e.value), isFalse, reason: '${e.key}: „$w“');
      }
      expect(RegExp(r'\d{1,2}:\d{2}').hasMatch(e.value), isFalse, reason: '${e.key}: Uhrzeit');
    }
    // Die Probe schlägt an: Das Rollenheft der Täterin trägt ihre Tat.
    final tat = fuenfWortFolgen(text['3-je-person-ungelesen-weitergeben/rollenheft-fatma.pdf']!);
    expect(tat.where((f) => verboten.containsKey(f)), isNotEmpty);
  });

  test('Veranstalter-Blatt: Fall-Code mit Anleitung, Ablauf mit ca.-Minuten, Gästeliste, Checkliste, Dateien', () {
    final t = text['2-veranstalter/veranstalter.pdf']!;
    for (final z in k.code.split('')) {
      expect(t, contains(z));
    }
    expect(flach(_text(datei('2-veranstalter', 'veranstalter.pdf').bytes)).replaceAll(' ', ''), contains(k.code));
    for (final teil in [
      k.ui('ui.druck.paket.code.anleitung'),
      k.ui('ui.druck.paket.ablauf.ca', {'minuten': '${abendMinutenCa(Abendfassung.kurz, Abendfassung.kurz.standardMinuten)}'}),
      k.ui('ui.druck.paket.ablauf.ca', {'minuten': '${abendMinutenCa(Abendfassung.lang, Abendfassung.lang.standardMinuten)}'}),
      for (final s in ['einrichtung', 'figuren', 'rollen', 'einleitung', 'runden', 'aufloesung']) k.ui('ui.druck.paket.ablauf.$s'),
      for (final c in ['handys', 'drucke', 'umschlaege', 'erzaehler', 'stifte', 'kostueme', 'ecke']) k.ui('ui.druck.paket.check.$c'),
      for (var n = 1; n <= 4; n++) k.ui('ui.druck.paket.dateien.ordner$n.text'),
      k.ui('ui.druck.paket.dateien.warnung'),
      k.ui('ui.druck.paket.gaeste.detektiv'),
      k.ui('ui.druck.paket.gaeste.erzaehler'),
      for (final id in k.druck.satz.besetzt) kanon.figur(id)!['name'] as String,
    ]) {
      expect(t, contains(flach(teil)), reason: teil);
    }
  });

  test('jedes Rollenheft: eigenes Dossier vollständig, keine geheime Fünf-Wort-Folge einer anderen Rolle', () {
    final satz = k.druck.satz;
    for (final rolle in satz.besetzt) {
      final name = dateiWort(kanon.figur(rolle)!['name'] as String);
      final t = text['3-je-person-ungelesen-weitergeben/rollenheft-$name.pdf']!;
      final d = satz.rollenhefte[rolle]!;
      for (final teil in [d.wer, d.ziel, for (final z in [...d.weiss, ...d.tatwissen]) z.text, ?d.tarnung]) {
        expect(t, contains(flach(teil)), reason: '$rolle: $teil');
      }
      for (var r = 1; r <= 3; r++) {
        expect(t, contains(flach(k.ui('ui.druck.fest.runde.erst', {'nr': '$r'}))), reason: '$rolle Runde $r');
      }
      // Wen du kennst: die Kurzkarten der anderen, wortgleich (kein Wort mitten im Wort umbrochen).
      for (final x in satz.besetzt.where((x) => x != rolle)) {
        expect(t, contains(flach(festFigur(k, x).alltag)), reason: '$rolle kennt $x');
      }
      final eigen = _eigen(k, rolle);
      final fremd = {
        for (final x in satz.besetzt)
          if (x != rolle)
            for (final s in _geheim(satz, x))
              for (final f in fuenfWortFolgen(s))
                if (!eigen.contains(f)) f: x,
      };
      final funde = [for (final f in fuenfWortFolgen(t)) if (fremd[f] case final x?) '„$f“ von $x'];
      expect(funde, isEmpty, reason: '$rolle:\n${funde.join('\n')}');
    }
  });

  test('Kernhefte: gleich viele Seiten, gleiche Überschriften, die Fassung steht im Heft, kein Umschlag-Code', () {
    final kern = kanon.kernverdaechtige;
    final seiten = <String, int>{};
    final ueberschriften = <String, List<String>>{};
    final marken = [
      k.ui('ui.druck.fest.wer'),
      k.ui('ui.druck.fest.ziel'),
      k.ui('ui.druck.fest.weiss'),
      k.ui('ui.druck.fest.rundenwahl'),
      k.ui('ui.druck.fest.verbirgst'),
      k.ui('ui.druck.fest.kennst'),
      for (var r = 1; r <= 3; r++) k.ui('ui.druck.fest.runde', {'nr': '$r'}),
      k.ui('ui.druck.fest.notizen'),
    ];
    for (final rolle in kern) {
      final name = dateiWort(kanon.figur(rolle)!['name'] as String);
      final b = befund['3-je-person-ungelesen-weitergeben/rollenheft-$name.pdf']!;
      seiten[rolle] = b.seiten;
      ueberschriften[rolle] = [for (final m in marken) b.seitenText.indexWhere((s) => s.contains(m)).toString()];
      final t = text['3-je-person-ungelesen-weitergeben/rollenheft-$name.pdf']!;
      final taeter = rolle == _pfad;
      expect(t.contains(flach(k.ui('ui.druck.fassung.taeter'))), taeter, reason: rolle);
      expect(t.contains(flach(k.ui('ui.druck.fassung.unschuldig'))), !taeter, reason: rolle);
      expect(t.contains(flach(k.ui('ui.druck.fassung.sabotage'))), taeter, reason: rolle);
      for (final f in k.druck.satz.fassungen) {
        expect(RegExp('(?<![A-Z])${f.code}(?![A-Z0-9])').hasMatch(t), isFalse, reason: '$rolle: Code ${f.code}');
      }
      expect(t, isNot(contains(flach(k.ui('ui.druck.rollen.umschlag', {'code': ''}).split('{').first.trim()))));
    }
    expect(seiten.values.toSet(), {rollenheftSeiten}, reason: '$seiten');
    expect(ueberschriften.values.map((l) => l.join(',')).toSet(), hasLength(1), reason: '$ueberschriften');
  });

  test('Detektivbogen: Fragen und Entscheidungen, nie eine Antwort, kein Kartencode', () {
    final antworten = {
      for (final p in k.druck.satz.erzaehler.values)
        for (final b in p.befragungen)
          for (final z in b.antwort) ...fuenfWortFolgen(z),
    };
    final fragen = {
      for (final b in k.druck.satz.befragungen.values)
        for (final r in [...b.pflicht, ...b.frei]) ...[for (final f in b.text(r).fragen) ...fuenfWortFolgen(f)],
    };
    for (final g in ['detektivin', 'detektiv']) {
      final t = text['3-je-person-ungelesen-weitergeben/detektivbogen-$g.pdf']!;
      for (final b in k.druck.satz.detektivbogen) {
        expect(t, contains(flach(b.frage)), reason: b.frage);
        for (final o in b.optionen) {
          expect(t, contains(flach(o.text)), reason: o.text);
          expect(RegExp('(?<![A-Z])${o.karte}(?![A-Z0-9])').hasMatch(t), isFalse, reason: 'Kartencode ${o.karte}');
        }
      }
      final verraten = fuenfWortFolgen(t).where((f) => antworten.contains(f) && !fragen.contains(f)).toList();
      expect(verraten, isEmpty, reason: '$g: $verraten');
      expect(t, contains(flach(k.ui('ui.druck.fest.bogen.nur.${g == 'detektivin' ? 'w' : 'm'}'))));
    }
  });

  test('Erzählerheft: jeder Vorlesetext, jede Antwort und jedes Tischgespräch, beide Aufträge, kein Fall-Code, keine Lösung', () {
    final t = text['4-nur-erzaehler/erzaehlerheft.pdf']!;
    final heft = k.druck.satz.spielleitung;
    for (final b in [
      for (final i in heft.intro)
        if (i.startsWith('intro.auftrag.')) ...['intro.auftrag.w', 'intro.auftrag.m'] else i,
      for (final r in heft.rundenStart.values) ...r,
    ]) {
      expect(t, contains(flach(k.text(b))), reason: b);
    }
    for (final p in k.druck.satz.erzaehler.values) {
      for (final b in p.befragungen) {
        for (final z in b.antwort) {
          expect(t, contains(flach(z)), reason: z);
        }
      }
      for (final ti in p.tisch) {
        for (final z in ti.stichpunkte) {
          expect(t, contains(flach(z)), reason: z);
        }
      }
    }
    expect(t, contains(flach(k.ui('ui.druck.fest.erzaehler.nur'))));
    expect(RegExp('(?<![A-Z])${k.code}(?![A-Z])').hasMatch(t), isFalse);
    final loesung = {
      for (final d in druckTexte.sammlung.dateien.entries)
        if (RegExp(r'texte/(erzaehler-finale|erzaehler-aufloesung)').hasMatch(d.key))
          for (final e in (d.value['eintraege'] as List? ?? const []))
            if ((e as Map)['text'] is String) ...fuenfWortFolgen(e['text'] as String),
    };
    // Erlaubt ist, was das Erzählerpaket ohnehin enthält: Vorlesetexte, Tisch, Befragungen.
    final erlaubt = {
      for (final b in [...heft.intro, 'intro.auftrag.w', 'intro.auftrag.m', ...heft.rundenStart.values.expand((x) => x)]) ...fuenfWortFolgen(k.text(b)),
      for (final p in k.druck.satz.erzaehler.values) ...[
        for (final ti in p.tisch) for (final z in [ti.thema, ...ti.stichpunkte]) ...fuenfWortFolgen(z),
        for (final b in p.befragungen) for (final z in [b.thema, ...b.fragen, ...b.antwort]) ...fuenfWortFolgen(z),
      ],
    };
    expect(fuenfWortFolgen(t).where((f) => loesung.contains(f) && !erlaubt.contains(f)), isEmpty);
  });

  test('gleicher Code und gleiche Porträts ⇒ bytegleiche Dateien und Archive', () async {
    final noch = await paketDateien(_kontext());
    expect([for (final d in noch) '${d.ordner}/${d.datei.name}'], [for (final d in dateien) '${d.ordner}/${d.datei.name}']);
    for (final (i, d) in noch.indexed) {
      expect(d.datei.bytes, dateien[i].datei.bytes, reason: d.datei.name);
    }
    Uint8List zip(List<PaketDatei> l) => zipArchiv({for (final d in l) '${d.ordner}/${d.datei.name}': d.datei.bytes});
    expect(zip(noch), zip(dateien));
  });

  test('ZIP-Archiv: lesbar, alle Dateien darin, Inhalt unverändert', () {
    final dir = Directory.systemTemp.createTempSync('paket_zip');
    try {
      final inhalt = {for (final d in dateien.take(3)) '${d.ordner}/${d.datei.name}': d.datei.bytes};
      final z = File('${dir.path}/a.zip')..writeAsBytesSync(zipArchiv(inhalt));
      final pruef = Process.runSync('unzip', ['-t', z.path]);
      expect(pruef.exitCode, 0, reason: '${pruef.stdout}');
      Process.runSync('unzip', ['-q', z.path, '-d', '${dir.path}/aus']);
      for (final e in inhalt.entries) {
        expect(File('${dir.path}/aus/${e.key}').readAsBytesSync(), e.value, reason: e.key);
      }
    } finally {
      dir.deleteSync(recursive: true);
    }
  });

  test('ohne Porträts: Schattenrisse, der Kontext nennt, was fehlt', () async {
    final ohne = _kontext(portraets: const {});
    expect(ohne.fehlendePortraets(), containsAll(['detektiv-w', 'detektiv-m', ...k.druck.satz.besetzt]));
    expect(k.fehlendePortraets(), isEmpty);
    final s = await festSteckbriefDatei(ohne, 'can');
    expect(pdfPruefen(s.bytes).seiten, 1);
    expect(pdfPruefen((await festRollenheftDatei(ohne, 'can')).bytes).seiten, rollenheftSeiten);
  });

  test('andere Pfade: Täterheft und Unschuldsheft gleich lang, jede Kernrolle findet ihre Fassung', () async {
    for (final pfad in kanon.pfade) {
      // Jedes Heft nur einmal setzen; der Fall aus setUpAll ([_pfad]) bringt seine Größen schon mit.
      // Doppelt gesetzt lief der Test im vollen Kernlauf (vier Prozesse) über 30 s.
      final kp = pfad == _pfad ? k : _kontext(pfad: pfad);
      for (final rolle in kanon.kernverdaechtige) {
        final heft = (await festRollenheftDatei(kp, rolle)).bytes;
        final t = flach(_text(heft));
        expect(t.contains(flach(kp.ui('ui.druck.fassung.taeter'))), rolle == pfad, reason: '$pfad/$rolle');
        expect(pdfPruefen(heft).seiten, rollenheftSeiten, reason: '$pfad/$rolle');
      }
    }
  });
}
