// A-063, SPEZIFIKATION §1: pruefeEinstimmung. Die Fixture (einstimmung_hilfe.dart)
// erfüllt alle Regeln; jede Fehlerprobe verletzt genau eine und wird gemeldet:
// verbotener Name in der Vorgeschichte, nicht erlaubter Name in einer Vorstellung,
// Fünf-Wort-Kopie aus einem Nebendelikt, Ziffer, zu langer Block, unausgewogene
// Kernfiguren, heimliche Kante genannt, Satz aus dem Intro.
import 'package:mordakte_core/mordakte_core.dart';
import 'package:test/test.dart';

import 'einstimmung_hilfe.dart';
import 'kanon_hilfe.dart';

final _ton = Textpruefer(leseJson('$repoWurzel/content/party/textregeln.json'));
final _vorspiel = VorspielMorgen.ausJson(leseJson('$repoWurzel/content/welt/schlosskeller/vorspiel_morgen.json'));

List<String> _pruefe({Map<String, String> aenderung = const {}, Kanon? k, List<NetzKante>? netz, Textpruefer? ton}) {
  final kk = k ?? einstimmungKanon;
  return pruefeEinstimmung(Einstimmung.aus(kk)!, einstimmungTexteMit(k: kk, aenderung: aenderung),
      netz: netz ?? fixtureNetz, ton: ton ?? _ton, vorspiel: _vorspiel);
}

String _text(String kennung) => einstimmungTexte()[kennung]!;

void main() {
  test('Die Fixture erfüllt alle Regeln (Größen, Namen, Fünf-Wort-Regel, Wörter, Ton)', () {
    final f = _pruefe();
    expect(f, isEmpty, reason: f.join('\n'));
  });

  test('Fehlerprobe: verbotener Name in der Vorgeschichte (Lejla ist nicht immer besetzt)', () {
    final f = _pruefe(aenderung: {'vorgeschichte.clique': '${_text('vorgeschichte.clique')} Lejla kam erst später dazu.'});
    expect(f, contains('vorgeschichte.clique: nennt Lejla, die Figur ist nicht immer besetzt'));
  });

  test('Fehlerprobe: Vorgeschichte nennt den Detektiv', () {
    final f = _pruefe(aenderung: {'vorgeschichte.heute': '${_text('vorgeschichte.heute')} Auch ein Detektiv ist eingeladen.'});
    expect(f.where((x) => x.startsWith('vorgeschichte.heute: nennt den Detektiv')), hasLength(1), reason: f.join('\n'));
  });

  test('Fehlerprobe: nicht erlaubter Name in einer Vorstellung (später vorgestellt oder ohne öffentliche Kante)', () {
    final f = _pruefe(aenderung: {
      'vorstellung.ahmet': '${_text('vorstellung.ahmet')} Mit Wojtek trägt er gern Kisten.',
      'vorstellung.tim': '${_text('vorstellung.tim')} Mit Fatma redet er über Farben.',
    });
    expect(f, contains('vorstellung.ahmet: nennt Wojtek (Platz 15), die vielleicht noch nicht vorgestellt ist'));
    expect(f, contains('vorstellung.tim: nennt Fatma, das Paar tim–fatma ist keine öffentliche Kante'));
  });

  test('Fehlerprobe: eine Vorstellung ohne den eigenen Namen, Sammelblock und Detektiv mit Namen', () {
    final f = _pruefe(aenderung: {
      'vorstellung.olli': _text('vorstellung.olli').replaceAll('Olli', 'Er'),
      'vorstellung.npc': 'Am Tisch sitzen noch weitere Gäste, etwa Tugba. Sie kommen später zu Wort.',
      'vorstellung.detektiv.w': '${_text('vorstellung.detektiv.w')} Ahmet winkt dir zu.',
    });
    expect(f, containsAll(['vorstellung.olli: nennt Olli nicht', 'vorstellung.npc: nennt Tugba', 'vorstellung.detektiv.w: nennt Ahmet']));
  });

  test('Fehlerprobe: Fünf-Wort-Kopie aus einem Nebendelikt', () {
    final nd = (kanon.figur('olli')!['nebendelikt'] as Map)['text'] as String;
    final f = _pruefe(aenderung: {'vorstellung.olli': '${_text('vorstellung.olli')} $nd'});
    expect(f.where((x) => x.startsWith('vorstellung.olli: „') && x.endsWith('stammt aus olli.nebendelikt')), isNotEmpty, reason: f.join('\n'));
  });

  test('Fehlerprobe: Ziffer', () {
    final f = _pruefe(aenderung: {'vorstellung.ahmet': _text('vorstellung.ahmet').replaceFirst('Das ist Ahmet', 'Das ist Ahmet mit 27')});
    expect(f.where((x) => x.startsWith('vorstellung.ahmet: Ziffern')), hasLength(1), reason: f.join('\n'));
    // Der Textprüfer meldet die Ziffer im Vorlesetext ebenfalls.
    expect(f.where((x) => x.startsWith('vorstellung.ahmet: Ziffer (nur Vorlesen)')), hasLength(1), reason: f.join('\n'));
  });

  test('Fehlerprobe: zu langer Block und zu lange Vorgeschichte', () {
    final lang = [for (var i = 0; i < 3; i++) _text('vorgeschichte.keller')].join(' ');
    final f = _pruefe(aenderung: {'vorgeschichte.keller': lang});
    final n = stichpunktWoerter(lang);
    expect(f, contains('vorgeschichte.keller: $n Wörter statt 70 bis 120'));
    expect(f.where((x) => x.startsWith('Vorgeschichte: ') && x.endsWith('Wörter statt 600 bis 750')), hasLength(1), reason: f.join('\n'));
  });

  test('Fehlerprobe: unausgewogene Kernfiguren und eine Kernfigur, die nie vorkommt', () {
    String ohneCan(String t) => t.replaceAll(RegExp(r'Can\b'), 'Er').replaceAll(', Olli und Er', ' und Olli');
    final aenderung = {
      for (final t in fixtureTeile) 'vorgeschichte.$t': ohneCan(_text('vorgeschichte.$t')),
    };
    final f = _pruefe(aenderung: aenderung);
    expect(f, contains('Vorgeschichte: nennt Can nie'));
    // Can einmal, die anderen je fünfmal: mehr als doppelt so oft.
    final g = _pruefe(aenderung: {...aenderung, 'vorgeschichte.heute': '${aenderung['vorgeschichte.heute']} Can kommt zuletzt.'});
    expect(g.where((x) => x.startsWith('Vorgeschichte: unausgewogen (Ahmet 5, Fatma 5, Olli 5, Can 1)')), hasLength(1), reason: g.join('\n'));
  });

  test('Fehlerprobe: eine heimliche Kante wird in der Vorstellung genannt', () {
    final f = _pruefe(aenderung: {'vorstellung.johanna': '${_text('vorstellung.johanna')} Ahmet kennt sie gut.'});
    expect(f, contains('vorstellung.johanna: nennt Ahmet, das Paar johanna–ahmet ist keine öffentliche Kante'));
    // Gegenprobe: Lejla nennt Ahmet über die öffentliche Kante; ohne Netz ist auch das verboten.
    expect(_pruefe(netz: const []), contains('vorstellung.leyla: nennt Ahmet, das Paar leyla–ahmet ist keine öffentliche Kante'));
  });

  test('Fehlerprobe: ein Satz aus dem Intro', () {
    final intro = Textsammlung.lade((p) => leseJson('$repoWurzel/content/party/schlosskeller/$p')).bausteine['intro.start']!;
    final satz = _ton.saetze(intro).firstWhere((s) => stichpunktWoerter(s) >= 8);
    final f = _pruefe(aenderung: {'vorgeschichte.schloss': '${_text('vorgeschichte.schloss')} $satz'});
    expect(f.where((x) => x.startsWith('vorgeschichte.schloss: „') && x.endsWith('stammt aus intro.start')), isNotEmpty, reason: f.join('\n'));
  });

  test('Fehlerprobe: Zeitleiste ab 18:00 und Vorspiel', () {
    final z = kanon.zeitleiste.firstWhere((x) => x['id'] == 'z_ankunft')['text'] as String;
    final station = _vorspiel.vorspiel.stationen.first.texte.first.$2.vorlesen;
    final f = _pruefe(aenderung: {
      'vorgeschichte.heute': '${_text('vorgeschichte.heute')} $z',
      'vorgeschichte.keller': '${_text('vorgeschichte.keller')} $station',
    });
    expect(f.where((x) => x.startsWith('vorgeschichte.heute: „') && x.endsWith('stammt aus Zeitleiste z_ankunft')), isNotEmpty, reason: f.join('\n'));
    expect(f.where((x) => x.startsWith('vorgeschichte.keller: „') && x.contains('stammt aus Vorspiel ')), isNotEmpty, reason: f.join('\n'));
  });

  test('Fehlerprobe: Spoilerwort, Kennwort eines Gegenstands, Urteilswort, Geburtstag und Keller-Geld', () {
    final f = _pruefe(aenderung: {
      'vorstellung.fatma': '${_text('vorstellung.fatma')} Sie trägt gern einen Silberring.',
      'vorstellung.olli': '${_text('vorstellung.olli')} Er sucht oft nach Spuren.',
      'vorstellung.can': '${_text('vorstellung.can')} Er ist sicher unschuldig.',
      'vorstellung.tim': '${_text('vorstellung.tim')} Heute ist sein Geburtstag.',
      'vorgeschichte.einladung': '${_text('vorgeschichte.einladung')} Jeder gab etwas Geld für die Miete.',
    });
    expect(f, containsAll([
      'vorstellung.fatma: „Silberring“ gehört nicht in die Einstimmung',
      'vorstellung.olli: „Spuren“ gehört nicht in die Einstimmung',
      'vorstellung.can: Urteilswort „unschuldig“',
      'vorstellung.tim: Geburtstag (A-061)',
      'vorgeschichte.einladung: „Geld“ gehört nicht in die Vorgeschichte (öffentliche Keller-Fassung)',
      'vorgeschichte.einladung: „Miete“ gehört nicht in die Vorgeschichte (öffentliche Keller-Fassung)',
    ]));
    // Herr Schneider gehört zum Rahmen und bleibt erlaubt (siehe Fixture).
    expect(_pruefe().where((x) => x.contains('Schneider')), isEmpty);
  });

  test('Fehlerprobe: Teilezahl, fehlender Text und Kapiteltitel', () {
    final k = kanonMit(setting: settingMitEinstimmung(teile: [...fixtureTeile, 'neu', 'noch']));
    final f = _pruefe(k: k);
    expect(f, containsAll([
      'Vorgeschichte: 9 Teile statt 6 bis 8',
      'vorgeschichte.neu fehlt',
      'Kapiteltitel ui.einstimmung.titel.noch fehlt',
    ]));
    final g = _pruefe(aenderung: {'ui.einstimmung.titel.heute': 'Heute am frühen kalten Abend'});
    expect(g, contains('ui.einstimmung.titel.heute: 5 Wörter statt höchstens 4'));
  });

  test('Ohne Vorstellung prüft der Prüfer nur die Vorgeschichte', () {
    final k = kanonMit(setting: settingMitEinstimmung(vorstellung: false));
    final f = pruefeEinstimmung(Einstimmung.aus(k)!, einstimmungTexteMit(k: k, aenderung: {'vorstellung.ahmet': 'Ahmet mit 27.'}), ton: _ton);
    expect(f, isEmpty, reason: f.join('\n'));
  });
}
