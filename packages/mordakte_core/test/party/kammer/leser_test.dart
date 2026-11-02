// Kammerspiel P2 (ARCHITEKTUR A1/A2): Leser-Prüfung (leserpruefung.dart) für den Inhalt unter
// content/kammerspiel/schlosskeller/: Wer liest welchen Text wann (FALL-BIBEL E3, E7–E11, MECH 3.1, 4.1, 9,
// 10.4, RK 1, RK 7.7, RK 8, WELT 0.2).
// (a) Leser-Zuordnung; Rot-Proben je Regel mit eingebauten Verstößen auf Kopien des echten Inhalts; Grün-Proben;
//     jede erlaubte Folge und jede Vorgabe-Ausnahme aus textregeln.json wird gebraucht;
// (b) der echte Inhalt: keine Befunde. Texte mit „OFFEN:“ prüft die Leser-Prüfung nicht; Vergleiche, die sie
//     bräuchten, stehen in `ausgelassen` (kein Fehlalarm, kein Überspringen des Tests).
import 'dart:convert';

import 'package:mordakte_core/kammer_io.dart';
import 'package:mordakte_core/src/party/druck/kammer/leserpruefung.dart';
import 'package:mordakte_core/src/party/druck/kammer/textpruefer.dart';
import 'package:test/test.dart';

import '../kanon_hilfe.dart' show leseJson, repoWurzel;

final _regeln = leseJson('$repoWurzel/content/kammerspiel/schlosskeller/textregeln.json');
final _pruefer = KammerLeserpruefer(_regeln);
final Map<String, Object?> _echt = {
  for (final e in leseKammerDateien(repoWurzel).entries) e.key: jsonDecode(e.value),
};
final _basis = _pruefer.pruefe(_echt);

/// Tiefe Kopie des echten Inhalts zum Verändern.
Map<String, dynamic> _kopie() => jsonDecode(jsonEncode(_echt)) as Map<String, dynamic>;

/// Ein JSON-Objekt in [d] unter [datei] und den Schlüsseln [weg].
Map<String, dynamic> _obj(Map<String, dynamic> d, String datei, [List<Object> weg = const []]) {
  Object? v = d[datei];
  for (final s in weg) {
    v = s is int ? (v as List)[s] : (v as Map)[s];
  }
  return v as Map<String, dynamic>;
}

/// Index der Indizkarte [code] in indizkarten.json.
int _karte(String code) => ((_echt['indizkarten.json'] as Map)['karten'] as List).indexWhere((k) => (k as Map)['code'] == code);

String _str(String datei, List<Object> weg) {
  Object? v = _echt[datei];
  for (final s in weg) {
    v = s is int ? (v as List)[s] : (v as Map)[s];
  }
  return v as String;
}

bool _gleich(KammerTextBefund b, String regel, String datei, String pfad, String? treffer) =>
    b.regel == regel && b.datei == datei && b.jsonPfad == pfad && (treffer == null || b.treffer == treffer);

/// Eine Rot-Probe: Änderung an einer Kopie und der Befund, den sie auslösen muss.
class _Probe {
  const _Probe(this.name, this.datei, this.pfad, this.aendern, {this.treffer});

  final String name;
  final String datei;
  final String pfad;
  final void Function(Map<String, dynamic> d) aendern;
  final String? treffer;
}

final Map<String, List<_Probe>> _rot = {
  KammerLeserRegel.taeterwissen: [
    _Probe('Tat-Satz aus Teil 90 in Tims Heft', 'rollen/07-tim.json', r'$.werDuBist', (d) {
      _obj(d, 'rollen/07-tim.json')['werDuBist'] = 'Du bist Tim. Den Schlüsselbund hat Olli unter die Eiswürfel im Eiskübel geschoben.';
    }),
    _Probe('Tat-Zeile aus RN7 in Ollis eigenem Heft', 'rollen/03-olli.json', r'$.stufe1.regie', (d) {
      _obj(d, 'rollen/03-olli.json', ['stufe1'])['regie'] = 'Im Dunkeln reißt du ihm den Schlüsselbund von der Gürtelschlaufe.';
    }),
    _Probe('Satz aus „Was wirklich war“ im Detektivbogen', 'detektiv.json', r'$.untersuchungen[0]', (d) {
      ((d['detektiv.json'] as Map)['untersuchungen'] as List)[0] =
          'Als das leuchtende Gesicht schon weg war, ging er über die Theken-Klappe zur Vorratsraumtür.';
    }),
  ],
  KammerLeserRegel.tatwort: [
    _Probe('„Ich war es.“ auf einer Geheimniskarte', 'rollen/02-fatma.json', r'$.geheimniskarte.undNochEtwas', (d) {
      _obj(d, 'rollen/02-fatma.json', ['geheimniskarte'])['undNochEtwas'] = 'Ich war es.';
    }, treffer: 'ich war es'),
    _Probe('„Panik“ in einem Zeugenheft', 'rollen/09-marek.json', r'$.aktionskarte.tipp', (d) {
      _obj(d, 'rollen/09-marek.json', ['aktionskarte'])['tipp'] = 'Keine Panik, frag einfach.';
    }, treffer: 'panik'),
  ],
  KammerLeserRegel.geheimnis: [
    _Probe('Ahmets Geheimniskarte im Detektivbogen', 'detektiv.json', r'$.untersuchungen[1]', (d) {
      ((d['detektiv.json'] as Map)['untersuchungen'] as List)[1] = _str('rollen/01-ahmet.json', ['geheimniskarte', 'wasIchZugebe']);
    }),
    _Probe('Cans Geheimniskarte in einer Beschriftung', 'ui/gemeinsam.json', r'$.notizen', (d) {
      (d['ui/gemeinsam.json'] as Map)['notizen'] = _str('rollen/04-can.json', ['geheimniskarte', 'wasIchZugebe']);
    }),
    _Probe('Lejlas Geheimniskarte auf ihrem eigenen Streifen', 'abwesenheit.json', r'$.streifen[0].protokoll', (d) {
      _obj(d, 'abwesenheit.json', ['streifen', 0])['protokoll'] = _str('rollen/05-lejla.json', ['geheimniskarte', 'wasIchZugebe']);
    }),
  ],
  KammerLeserRegel.fassungscode: [
    _Probe('Code der Täterfassung im Erzählerheft', 'erzaehlerheft.json', r'$.fassungenOeffnen', (d) {
      (d['erzaehlerheft.json'] as Map)['fassungenOeffnen'] = 'Gib Olli die Fassung RN7.';
    }, treffer: 'RN7'),
  ],
  KammerLeserRegel.indizName: [
    _Probe('Name auf XD3', 'indizkarten.json', '\$.karten[${_karte('XD3')}].vermerke[0]', (d) {
      final v = _obj(d, 'indizkarten.json', ['karten', _karte('XD3')])['vermerke'] as List;
      v[0] = '${v[0]} Das war Olli.';
    }, treffer: 'Olli'),
    _Probe('Name im Fundort-Vermerk', 'indizkarten.json', '\$.karten[${_karte('PP9')}].vermerke[0]', (d) {
      final v = _obj(d, 'indizkarten.json', ['karten', _karte('PP9')])['vermerke'] as List;
      v[0] = 'Fundort: Can hat den Schlüsselbund dort versteckt.';
    }, treffer: 'Can'),
  ],
  KammerLeserRegel.indizGestaendnis: [
    _Probe('„gibt zu“ auf FN3', 'indizkarten.json', '\$.karten[${_karte('FN3')}].wasDuFindest', (d) {
      final k = _obj(d, 'indizkarten.json', ['karten', _karte('FN3')]);
      k['wasDuFindest'] = '${k['wasDuFindest']} Olli gibt zu, dass er an der Bogentür war.';
    }, treffer: 'gibt zu'),
    _Probe('was eine Person sah, auf AD3', 'indizkarten.json', '\$.karten[${_karte('AD3')}].wasDuFindest', (d) {
      final k = _obj(d, 'indizkarten.json', ['karten', _karte('AD3')]);
      k['wasDuFindest'] = '${k['wasDuFindest']} Can sah im Dunkeln das Gesicht.';
    }, treffer: 'Can sah'),
  ],
  KammerLeserRegel.indizWort: [
    _Probe('Spoiler-Wort auf JA9', 'indizkarten.json', '\$.karten[${_karte('JA9')}].wasDuFindest', (d) {
      final k = _obj(d, 'indizkarten.json', ['karten', _karte('JA9')]);
      k['wasDuFindest'] = '${k['wasDuFindest']} Eine falsche Fährte.';
    }, treffer: 'falsche'),
    _Probe('rote Teilchen am Fundort PP9', 'indizkarten.json', '\$.karten[${_karte('PP9')}].wasDuFindest', (d) {
      final k = _obj(d, 'indizkarten.json', ['karten', _karte('PP9')]);
      k['wasDuFindest'] = '${k['wasDuFindest']} Daneben liegen rote Teilchen.';
    }, treffer: 'rote'),
  ],
  KammerLeserRegel.vorderseite: [
    _Probe('Bedingung und fremder Wert auf der Vorderseite der Geheimniskarte', 'ui/20.json', r'$["geheimnis.vorne"]', (d) {
      (d['ui/20.json'] as Map)['geheimnis.vorne'] = 'Geheimnis · {name} · Platz {platz} · umdrehen, sobald {codes} offen liegt';
    }, treffer: '{codes}'),
    _Probe('Name auf der Außenseite der Fassung', 'ui/11.json', r'$["aussen.hinweis"]', (d) {
      (d['ui/11.json'] as Map)['aussen.hinweis'] = 'Versiegelt. Olli öffnet zuerst.';
    }, treffer: 'Olli'),
    _Probe('Vorderseite fehlt', 'ui/20.json', r'$["geheimnis.vorne.fehlt"]', (d) {
      (d['ui/20.json'] as Map).remove('geheimnis.vorne.fehlt');
    }, treffer: 'geheimnis.vorne.fehlt'),
  ],
  KammerLeserRegel.bedingung: [
    _Probe('Bedingung auf Fatmas Geheimniskarte', 'rollen/02-fatma.json', r'$.geheimniskarte.undNochEtwas', (d) {
      _obj(d, 'rollen/02-fatma.json', ['geheimniskarte'])['undNochEtwas'] = 'Umdreh-Hinweis: NN3 liegt offen.';
    }, treffer: 'NN3'),
    _Probe('Bedingungswort auf Lejlas Geheimniskarte', 'rollen/05-lejla.json', r'$.geheimniskarte.wasIchZugebe', (d) {
      _obj(d, 'rollen/05-lejla.json', ['geheimniskarte'])['wasIchZugebe'] = 'Sobald die Miete offen liegt, sag ich alles.';
    }, treffer: 'sobald'),
    _Probe('Heft ohne Auslöser', 'rollen/01-ahmet.json', r'$.stufe2.ausloeser', (d) {
      _obj(d, 'rollen/01-ahmet.json', ['stufe2'])['ausloeser'] = <Object?>[];
    }),
  ],
  KammerLeserRegel.kopftuch: [
    _Probe('Vermerk auf Tugbas Karte', 'rollen/18-tugba.json', r'$.geheimniskarte.vermerke[0]', (d) {
      _obj(d, 'rollen/18-tugba.json', ['geheimniskarte'])['vermerke'] = ['Heimlichtuerei · Tugba: hat die Dankeskarte versteckt.'];
    }),
    _Probe('Pflicht-Code auf Tugbas Karte', 'rollen/18-tugba.json', r'$.geheimniskarte.pflichtCodes[0]', (d) {
      _obj(d, 'rollen/18-tugba.json', ['geheimniskarte'])['pflichtCodes'] = ['VP7'];
    }),
    _Probe('Rundensperre für Tugba', 'rollen/18-tugba.json', r'$.geheimniskarte.sperre', (d) {
      _obj(d, 'rollen/18-tugba.json', ['geheimniskarte'])['sperre'] = 2;
    }),
    _Probe('Tarnsatz für Tugba', 'rollen/18-tugba.json', r'$.stufe1.verboten[0]', (d) {
      _obj(d, 'rollen/18-tugba.json', ['stufe1'])['verboten'] = ['„Ich war nie am Kamin.“'];
    }),
    _Probe('Tarnung in Tugbas Regie (erlaubt ist nur der Satz aus ZR 8.6)', 'rollen/18-tugba.json', r'$.stufe1.regie', (d) {
      _obj(d, 'rollen/18-tugba.json', ['stufe1'])['regie'] = 'Sag niemandem, dass du um halb acht am Kamin warst.';
    }),
    _Probe('Tugbas Marker gelogen', 'rollen/18-tugba.json', r'$.marker', (d) {
      _obj(d, 'rollen/18-tugba.json', ['marker', 'behauptet'])['z2357'] = '7';
    }),
    _Probe('belastendes Wort neben Tugbas Namen', 'rollen/17-aylin.json', r'$.haltung', (d) {
      _obj(d, 'rollen/17-aylin.json')['haltung'] = 'Tugba hat heute gelogen.';
    }, treffer: 'gelogen'),
  ],
  KammerLeserRegel.platzhalter: [
    _Probe('Marek ohne Platzhalter in Ahmets Heft', 'rollen/01-ahmet.json', r'$.werDuBist', (d) {
      final r = _obj(d, 'rollen/01-ahmet.json');
      r['werDuBist'] = '${r['werDuBist']} Marek ist dein Caterer.';
    }, treffer: 'Marek'),
    _Probe('Zusatzrolle ohne Platzhalter in Teil 90', 'aufloesung.json', r'$.pruefung', (d) {
      (d['aufloesung.json'] as Map)['pruefung'] = 'Sibel hat es auch gesehen.';
    }, treffer: 'Sibel'),
    _Probe('Zusatzrolle ohne Platzhalter auf einer Indizkarte', 'indizkarten.json', '\$.karten[${_karte('WE3')}].wasDuFindest', (d) {
      final k = _obj(d, 'indizkarten.json', ['karten', _karte('WE3')]);
      k['wasDuFindest'] = '${k['wasDuFindest']} Daneben hängt Azras Strickjacke.';
    }, treffer: 'Azra'),
  ],
  KammerLeserRegel.gestaltGliederung: [
    _Probe('Olli mit sechs statt sieben Ausweichsätzen', 'rollen/03-olli.json', r'$.stufe1.ausweichsaetze', (d) {
      (_obj(d, 'rollen/03-olli.json', ['stufe1'])['ausweichsaetze'] as List).removeLast();
    }, treffer: '6'),
    _Probe('Ahmet mit anderem Impuls in derselben Zeile', 'rollen/01-ahmet.json', r'$.wennDerErzaehlerFragt[2].impuls', (d) {
      _obj(d, 'rollen/01-ahmet.json', ['wennDerErzaehlerFragt', 2])['impuls'] = 'I-2.4';
    }),
    _Probe('Feld nur bei einer der vier', 'rollen/04-can.json', r'$.bonusZiel.hinweis', (d) {
      _obj(d, 'rollen/04-can.json', ['bonusZiel'])['hinweis'] = 'Nur für Can.';
    }),
  ],
  KammerLeserRegel.gestaltLaenge: [
    _Probe('Cans Auftritt viel länger', 'rollen/04-can.json', r'$.vorstellung.auftritt', (d) {
      final v = _obj(d, 'rollen/04-can.json', ['vorstellung']);
      v['auftritt'] = '${v['auftritt']} Und dann noch das Video vom letzten Sommer, das kennt ihr alle, oder? '
          'Da springt der Hund in den See, und alle springen hinterher, auch ich, mit Kamera.';
    }),
  ],
  KammerLeserRegel.gestaltSchluss: [
    _Probe('Ollis Stufe 2 mit anderem Schlusssatz', 'rollen/03-olli.json', r'$.stufe2.abDann', (d) {
      final s = _obj(d, 'rollen/03-olli.json', ['stufe2']);
      s['abDann'] = (s['abDann'] as String).replaceAll('Mehr gibst du nicht zu. Dabei bleibst du.', 'Mehr sagst du nicht.');
    }),
    _Probe('Satz der unschuldigen Fassungen in Ahmets Heft', 'rollen/01-ahmet.json', r'$.werDuBist', (d) {
      final r = _obj(d, 'rollen/01-ahmet.json');
      r['werDuBist'] = '${r['werDuBist']} Mit dem Scheppern hast du nichts zu tun.';
    }),
  ],
  KammerLeserRegel.gestaltAktion: [
    _Probe('Ollis Aktionskarte verräterisch benannt', 'rollen/03-olli.json', r'$.aktionskarte.name', (d) {
      _obj(d, 'rollen/03-olli.json', ['aktionskarte'])['name'] = 'Veto';
    }, treffer: 'veto'),
    _Probe('Ollis Aktionskarte in anderer Klasse', 'rollen/03-olli.json', r'$.aktionskarte.klasse', (d) {
      _obj(d, 'rollen/03-olli.json', ['aktionskarte'])['klasse'] = 'frage';
    }),
    _Probe('Cans Aktionskarte mit anderen Grenzen', 'rollen/04-can.json', r'$.aktionskarte.grenzen', (d) {
      _obj(d, 'rollen/04-can.json', ['aktionskarte'])['grenzen'] = 'Nur in Runde 1.';
    }),
  ],
  KammerLeserRegel.gestaltTat: [
    _Probe('Geständnis in Ahmets Stufe 3', 'rollen/01-ahmet.json', r'$.fassung.stufe3', (d) {
      final f = _obj(d, 'rollen/01-ahmet.json', ['fassung']);
      f['stufe3'] = '${f['stufe3']} Im Dunkeln hat mich die Panik gepackt.';
    }, treffer: 'panik'),
    _Probe('Tat-Satz in Fatmas Fassung', 'rollen/02-fatma.json', r'$.fassung.wasNurDuWeisst[0]', (d) {
      (_obj(d, 'rollen/02-fatma.json', ['fassung'])['wasNurDuWeisst'] as List)[0] =
          'Den Schlüsselbund hat Olli unter die Eiswürfel im Eiskübel geschoben.';
    }),
    _Probe('Ollis Stufe 3 ohne Tat', 'rollen/03-olli.json', r'$.fassung.stufe3', (d) {
      _obj(d, 'rollen/03-olli.json', ['fassung'])['stufe3'] = _str('rollen/01-ahmet.json', ['fassung', 'stufe3']);
    }),
  ],
};

void main() {
  group('Leser-Zuordnung', () {
    List<String> l(String datei, String pfad) => [for (final x in _pruefer.leserVon(datei, pfad)) '$x'];

    test('Rollendateien: Heft, Erzähler, Karten, Fassung, Teil 90, Struktur', () {
      expect(l('rollen/03-olli.json', r'$.stufe1.kernsaetze[0]'), ['heft:olli/10']);
      expect(l('rollen/12-damir.json', r'$.werDuBist'), ['heft:damir/12']);
      expect(l('rollen/03-olli.json', r'$.vorstellung.frage'), ['erzaehler:olli/00']);
      expect(l('rollen/03-olli.json', r'$.fassung.stufe3'), ['fassung:olli/11']);
      expect(l('rollen/03-olli.json', r'$.teil90'), ['aufloesung:olli/90']);
      expect(l('rollen/03-olli.json', r'$.geheimniskarte.wasIchZugebe'), ['geheimniskarte:olli/20']);
      expect(l('rollen/05-lejla.json', r'$.geheimniskarte.wasIchZugebe'), ['geheimniskarte:lejla/20', 'heft:lejla/10']);
      expect(l('rollen/05-lejla.json', r'$.aktionskarte.wirkung'), ['aktionskarte:lejla/20', 'heft:lejla/10', 'detektiv:lejla/01']);
      expect(l('rollen/13-hana.json', r'$.aktionskarte.wirkung'), ['aktionskarte:hana/20', 'heft:hana/12']);
      expect(l('rollen/05-lejla.json', r'$.aktionskarte.tipp'), ['heft:lejla/10']);
      expect(l('rollen/08-joanna.json', r'$.notiz.zeilen[3]'), ['heft:joanna/10', 'streifen:joanna/02']);
      expect(l('rollen/03-olli.json', r'$.marker.behauptet.z2357'), ['struktur']);
      expect(l('rollen/03-olli.json', r'$.gespraechsauftraege[0].ziel'), ['struktur']);
      expect(l('rollen/03-olli.json', r'$.fassung.code'), ['struktur']);
    });

    test('übrige Dateien und Beschriftungen', () {
      expect(l('fall.json', r'$.plaetze[11].name'), ['struktur']);
      expect(l('gemeinsam.json', r'$.wasAlleWissen[0]'), ['alle']);
      expect(l('ui/gemeinsam.json', r'$.notizen'), ['alle']);
      expect(l('erzaehlerheft.json', r'$.tatMoment'), ['erzaehler/00']);
      expect(l('detektiv.json', r'$.auftritt'), ['detektiv/01']);
      expect(l('tisch.json', r'$.tippZettel.titel'), ['tisch/02']);
      expect(l('abwesenheit.json', r'$.streifen[0].protokoll'), ['streifen/02']);
      expect(l('abwesenheit.json', r'$.streifen[0].zeuge'), ['struktur']);
      expect(l('indizkarten.json', r'$.karten[0].titel'), ['indizkarte/20', 'detektiv/01']);
      expect(l('indizkarten.json', r'$.karten[0].wasDuFindest'), ['indizkarte/20']);
      expect(l('indizkarten.json', r'$.karten[0].code'), ['struktur']);
      expect(l('aufloesung.json', r'$.wasWirklichWar'), ['aufloesung/90']);
      expect(l('ui/90.json', r'$.titel'), ['aufloesung/90']);
      expect(l('ui/20.json', r'$["indiz.aussen"]'), ['karteAussen/20']);
      expect(l('ui/20.json', r'$["geheimnis.vorne"]'), ['karteAussen/20']);
      expect(l('ui/20.json', r'$["indiz.wasDuFindest"]'), ['indizkarte/20']);
      expect(l('ui/20.json', r'$["aktion.wirkung"]'), ['aktionskarte/20']);
      expect(l('ui/20.json', r'$.titel'), ['indizkarte/20', 'geheimniskarte/20', 'aktionskarte/20']);
      expect(l('ui/11.json', r'$["aussen.hinweis"]'), ['fassungAussen/11']);
      expect(l('ui/11.json', r'$.stufe3'), ['fassung/11']);
      expect(l('ui/10.json', r'$.kopf'), ['heft/10']);
      expect(l('ui/12.json', r'$.kopf'), ['heft/12']);
      expect(l('textregeln.json', r'$.beschreibung'), isEmpty);
    });

    test('Struktur sind nur Kennungen (ohne Leerraum) und fall.json; alle Texte haben einen Leser', () {
      final texte = [
        for (final s in kammerTextStellen(_echt))
          if (s.datei != 'fall.json' && _pruefer.leserVon(s.datei, s.jsonPfad).first.art == KammerLeserArt.struktur && s.text.contains(RegExp(r'\s')))
            '${s.datei} ${s.jsonPfad}',
      ];
      expect(texte, isEmpty);
      expect(l('rollen/03-olli.json', r'$.fassung.ziel'), ['fassung:olli/11']);
      expect(l('aufloesung.json', r'$.meilensteine[0].feld'), ['aufloesung/90']);
    });

    test('jede Zeichenkette des echten Inhalts hat einen Leser', () {
      final ohne = [
        for (final s in kammerTextStellen(_echt))
          if (_pruefer.leserVon(s.datei, s.jsonPfad).isEmpty) '${s.datei} ${s.jsonPfad}',
      ];
      expect(ohne, isEmpty);
    });
  });

  group('Satzfolgen', () {
    test('Fünf-Wort-Folgen reichen nicht über ein Satzende', () {
      expect(kammerSaetze('Herr Schneider packt es: „Hab ich dich!“ Du gehst.\nZweite Zeile'),
          ['Herr Schneider packt es:', '„Hab ich dich!“', 'Du gehst.', 'Zweite Zeile']);
      expect(kammerSatzFolgen('Ein leuchtendes Gesicht aus dem Vorratsraum. Herr Schneider packte es.'),
          {'ein leuchtendes gesicht aus dem', 'leuchtendes gesicht aus dem vorratsraum'});
      expect(kammerSatzFolgen('Er verlangt 2.000 € bis Mitternacht.'), {'er verlangt 2 000 bis', 'verlangt 2 000 bis mitternacht'});
    });
  });

  group('Rot-Proben', () {
    test('jede Regel hat mindestens eine Rot-Probe', () {
      expect(_rot.keys.toSet(), _pruefer.regeln.toSet());
      expect(_rot.values.every((p) => p.isNotEmpty), isTrue);
    });

    for (final e in _rot.entries) {
      for (final p in e.value) {
        test('${e.key}: ${p.name}', () {
          final d = _kopie();
          p.aendern(d);
          final befunde = _pruefer.pruefe(d).befunde;
          expect(_basis.befunde.where((b) => _gleich(b, e.key, p.datei, p.pfad, p.treffer)), isEmpty,
              reason: 'Der echte Inhalt darf den Befund noch nicht haben.');
          expect(
            befunde.where((b) => _gleich(b, e.key, p.datei, p.pfad, p.treffer)),
            isNotEmpty,
            reason: 'Erwartet: ${p.datei} ${p.pfad} [${e.key}]${p.treffer == null ? '' : ' „${p.treffer}“'}\n'
                'Gefunden:\n${befunde.join('\n')}',
          );
        });
      }
    }
  });

  group('Grün-Proben', () {
    List<KammerTextBefund> neu(void Function(Map<String, dynamic> d) aendern) {
      final d = _kopie();
      aendern(d);
      final alt = {for (final b in _basis.befunde) '$b'};
      return [for (final b in _pruefer.pruefe(d).befunde) if (!alt.contains('$b')) b];
    }

    test('„Ich war es nicht.“ ist kein Tatwort, „gestanden“ kein Geständnis, ein Genitiv kein Zeuge', () {
      expect(
        neu((d) {
          _obj(d, 'rollen/09-marek.json', ['aktionskarte'])['tipp'] = 'Wenn du angeklagt wirst, sagst du: „Ich war es nicht.“';
          final k = _obj(d, 'indizkarten.json', ['karten', _karte('FN3')]);
          k['wasDuFindest'] = '${k['wasDuFindest']} Ollis Weste hängt dort, wo er gestanden hat.';
        }).map((b) => '$b'),
        isEmpty,
      );
    });

    test('ein Zeuge 5–10 darf in Teil 90 mit Namen stehen, eine Zusatzrolle mit Platzhalter auch', () {
      expect(
        neu((d) {
          (d['aufloesung.json'] as Map)['pruefung'] = 'Frag Lejla und {rolle:sibel|einen Gast}, was sie gesehen haben.';
        }).map((b) => '$b'),
        isEmpty,
      );
    });

    test('ein Verweis auf eine andere Karte ist keine Bedingung', () {
      expect(
        neu((d) {
          _obj(d, 'rollen/02-fatma.json', ['geheimniskarte'])['undNochEtwas'] = 'Vergleiche die Schauvitrine (FM9).';
        }).where((b) => b.regel == KammerLeserRegel.bedingung).map((b) => '$b'),
        isEmpty,
      );
    });

    test('gedruckt wird nur, was zur Besetzung passt: Frage nur mit Ziel, Ausweichziel nur ohne', () {
      // Ahmets Ausweichziel nennt Marek mit Namen: Es wird nur gedruckt, wenn Marek fehlt; dann ist es ein Befund.
      final ausweich = neu((d) {
        _obj(d, 'rollen/01-ahmet.json', ['gespraechsauftraege', 1])['ausweich'] = 'Frag Marek.';
      });
      expect(ausweich.where((b) => b.regel == KammerLeserRegel.platzhalter && b.jsonPfad == r'$.gespraechsauftraege[1].ausweich'), isNotEmpty);
      // Die Frage an Marek nennt ihn ebenfalls, wird aber nur gedruckt, wenn er spielt.
      expect(_basis.befunde.where((b) => b.jsonPfad.startsWith(r'$.gespraechsauftraege[1].frage')), isEmpty);
    });
  });

  group('Regeldaten', () {
    test('Hinweis für jede Regel; unbekannter Abschnitt wirft', () {
      final hinweise = ((_regeln['leser'] as Map)['hinweise'] as Map).keys.toSet();
      expect(hinweise, _pruefer.regeln.toSet());
      expect(() => KammerLeserpruefer({..._regeln}..remove('leser')), throwsFormatException);
    });

    test('jede erlaubte Folge und jede Vorgabe-Ausnahme wird gebraucht', () {
      final ohne = jsonDecode(jsonEncode(_regeln)) as Map<String, dynamic>;
      (ohne['leser'] as Map)
        ..['erlaubteFolgen'] = <String, Object?>{}
        ..['ausnahmen'] = <String, Object?>{};
      final roh = KammerLeserpruefer(ohne).pruefe(_echt).befunde;
      for (final e in _pruefer.erlaubteFolgen.entries) {
        for (final f in e.value.keys) {
          expect(roh.where((b) => b.regel == e.key && b.treffer == f), isNotEmpty, reason: 'erlaubte Folge „$f“ (${e.key}) wird nicht gebraucht');
        }
      }
      for (final e in _pruefer.vorgabeAusnahmen.entries) {
        for (final m in e.value) {
          final i = m.indexOf('#');
          final datei = m.substring(0, i);
          final pfad = m.substring(i + 1);
          expect(roh.where((b) => b.regel == e.key && b.datei == datei && b.jsonPfad.startsWith(pfad)), isNotEmpty,
              reason: 'Vorgabe-Ausnahme $m (${e.key}) wird nicht gebraucht');
          expect(_pruefer.ausnahmeGruende['${e.key} $m'], isNotNull);
        }
      }
    });

    test('Ausnahmen als Parameter: Muster wie beim Textprüfer', () {
      final d = _kopie();
      final r = _obj(d, 'rollen/01-ahmet.json');
      r['werDuBist'] = '${r['werDuBist']} Marek ist dein Caterer.';
      expect(_pruefer.pruefe(d).befunde.where((b) => b.regel == KammerLeserRegel.platzhalter && b.datei == 'rollen/01-ahmet.json'), isNotEmpty);
      final mit = _pruefer.pruefe(d, ausnahmen: {
        KammerLeserRegel.platzhalter: [r'rollen/01-*.json#$.werDuBist'],
      });
      expect(mit.befunde.where((b) => b.regel == KammerLeserRegel.platzhalter && b.datei == 'rollen/01-ahmet.json'), isEmpty);
    });
  });

  test('gleiche Eingabe, gleiche Befunde in gleicher Reihenfolge', () {
    final d = _kopie();
    final r = _obj(d, 'rollen/01-ahmet.json');
    r['werDuBist'] = '${r['werDuBist']} Marek ist dein Caterer. Mit dem Scheppern hast du nichts zu tun.';
    final a = _pruefer.pruefe(d).befunde.map((b) => '$b').toList();
    final b = _pruefer.pruefe(jsonDecode(jsonEncode(d)) as Map<String, Object?>).befunde.map((b) => '$b').toList();
    expect(a, b);
    expect(a.length, greaterThanOrEqualTo(2));
  });

  test('(b) echter Inhalt unter content/kammerspiel/schlosskeller: keine Befunde der Leser-Prüfung', () {
    expect(
      _basis.befunde.map((b) => '$b'),
      isEmpty,
      reason: '${_basis.befunde.length} Befunde; ausgelassen wegen „OFFEN:“: ${_basis.ausgelassen.join('; ')}\n'
          '${_basis.befunde.join('\n')}',
    );
  });
}
