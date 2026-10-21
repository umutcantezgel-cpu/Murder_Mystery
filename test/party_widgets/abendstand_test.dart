// M8 Abendstand: Ein Abend läuft nach dem Neuladen genau dort weiter, wo er war.
// Nach jedem Schritt geht der Stand durch JSON und wird neu abgespielt; was die
// Bildschirme zeigen, muss gleich sein, und ab dort spielen Original und
// Fortsetzung mit gleichen Schritten dasselbe Ende (Würfel hängen am Salz).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte/party/daten.dart';
import 'package:mordakte/party/sitzung.dart';
import 'package:mordakte/party/stand/befragung_stand.dart';
import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/runden.dart';

import 'hilfe.dart';

List<AbstecherOrt> _abstecher(String akte) {
  final f = File('content/party/zusatz/$akte/abstecher.json');
  return f.existsSync() ? AbstecherOrt.liste(jsonDecode(f.readAsStringSync()) as Map<String, Object?>) : const [];
}

KartenKatalog get _katalog {
  final dateien = Directory('content/karten').listSync().whereType<File>()
      .where((f) => f.path.endsWith('.json') && !f.path.endsWith('.schema.json'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));
  return KartenKatalog.ausDateien([for (final f in dateien) jsonDecode(f.readAsStringSync()) as Map<String, Object?>]);
}

/// Was die Bildschirme vom Abend zeigen, als vergleichbarer Text.
String _bild(PartySitzung s) => [
      s.phase,
      s.runde,
      s.restMinuten,
      s.reserveMinuten,
      s.marken,
      [for (final w in s.wuerfe) '${w.a}${w.b}${w.stufe.name}'],
      {for (final e in s.funde.entries) e.key: e.value.length},
      s.laufendeEntscheidung?.id,
      s.vorschlag?.option,
      s.zug?.id,
      s.zug?.phase,
      s.zug?.aktion,
      s.letzterFund?.entscheidung,
      s.offeneWaehler,
      s.erzaehlFlags.toList()..sort(),
      s.gespraech?.knoten.id,
      s.erzaehler,
      s.besetzt,
      if (s.eingerichtet) s.fallCode.code,
      s.angeklagt,
      s.spiel.punkte,
      s.erzaehltiefe,
      s.stimmeAn,
      s.namen,
      [for (final k in s.vorrat.karten) k.id],
      s.abstecherErgebnis,
      [for (final k in s.befragungen) '${k.id}:${k.frage}:${k.erledigt}:${k.antwort?.length}'],
      s.befragungenFrei,
      s.befragungsNotizen.length,
      s.fassung,
      s.uhrInPhase,
      s.weltSamen,
      if (s.nachFinale) s.ende.id,
    ].toString();

/// Ein Schritt am Tisch, abwechslungsreich nach [i]: mal die erste, mal die
/// letzte Option, Randgespräche, Erkundungen, gründlich, Umweg und Nochmal.
/// `false` am Ende des Abends.
bool _schritt(PartySitzung s, int i) {
  switch (s.phase) {
    case PartyPhase.ende:
      return false;
    case PartyPhase.titel:
      s.zurEinrichtung();
    case PartyPhase.gespraeche:
      final offen = s.soloGespraeche.where((g) => !s.soloNotizen.any((n) => n.id == g.id)).toList();
      final befragung = _befragung(s, i);
      if (offen.isNotEmpty) {
        s.soloGespraechGelesen(offen.first.id);
      } else if (befragung != null) {
        // Modell befragung: je Schritt ein Handgriff, mal die erste, mal die letzte Frage.
        if (!befragung.gefragt) {
          s.befragen(befragung.id, i % befragung.fragen.length);
        } else if (s.verdeckt == null && i.isOdd) {
          s.zeigeVerdeckt(befragung.rolle);
        } else {
          if (s.verdeckt != null) s.verdecken();
          s.befragungErledigt(befragung.id);
        }
      } else {
        s.weiter();
      }
    case PartyPhase.entscheidungen:
      final g = s.gespraech;
      final z = s.zug;
      if (g != null) {
        g.fertig ? s.randgespraechBeenden() : s.randgespraechWaehlen(g.wahlen[i % g.wahlen.length]);
      } else if (z != null) {
        switch (z.phase) {
          case RundenZugPhase.aktion: s.aktionFertig(z.aktion);
          case RundenZugPhase.wurf: s.wuerfeln(marke: i % 4 == 0 && s.marken > 0);
          case RundenZugPhase.tischruf: s.tischruf(i.isEven ? Tischruf.umweg : Tischruf.nochmal);
          case RundenZugPhase.fund: s.fundGelesen();
        }
      } else if (s.letzterFund != null) {
        s.fundGelesen();
      } else if (s.vorschlag != null) {
        i % 3 == 0 ? s.verwerfen() : s.bestaetigen(gruendlich: i % 5 == 0 && istSuche(s.laufendeEntscheidung!));
      } else if (s.laufendeEntscheidung case final e?) {
        final zeuge = s.karte.figuren.where((f) => s.randgespraechMoeglich(f.id)).firstOrNull;
        if (i % 6 == 0 && zeuge != null) {
          s.randgespraechBeginnen(zeuge.id);
        } else if (i % 9 == 0 && s.abstecherOffen.isNotEmpty) {
          s.starteAbstecher(s.abstecherOffen.first.id);
        } else {
          s.schlageVor((i.isEven ? e.optionen.first : e.optionen.last).id);
        }
      } else {
        s.weiter();
      }
    case PartyPhase.gruppenwahl:
      if (s.offeneWaehler.isEmpty) {
        s.weiter();
      } else {
        final r = s.offeneWaehler.first;
        s.verdeckt == r ? s.stimme(r, kooperativ: i % 3 != 0) : s.zeigeVerdeckt(r);
      }
    case PartyPhase.anklage:
      s.angeklagt == null ? s.anklagen(s.kernverdaechtige[i % s.kernverdaechtige.length]) : s.weiter();
    default:
      s.weiter();
  }
  return true;
}

/// Die nächste offene Befragung: feste zuerst, dann eine freie (mal von vorn, mal von hinten).
BefragungKarte? _befragung(PartySitzung s, int i) {
  final offen = [for (final k in s.befragungen) if (!k.erledigt && (k.pflicht || k.gefragt)) k];
  if (offen.isNotEmpty) return offen.first;
  if (s.befragungenFrei <= 0) return null;
  final frei = [for (final k in s.befragungen) if (!k.pflicht && k.waehlbar && !k.gefragt) k];
  return frei.isEmpty ? null : (i.isEven ? frei.first : frei.last);
}

PartySitzung _fortgesetzt(PartySitzung s, List<AbstecherOrt> abstecher) =>
    PartySitzung.fortsetzen(s.daten, jsonDecode(jsonEncode(s.abendstand)) as Map<String, Object?>, katalog: _katalog, abstecher: abstecher);

/// Spielt den Abend Schritt für Schritt; nach jedem Schritt muss die Fortsetzung
/// gleich aussehen, und an jedem siebten spielen beide bis zum Ende dasselbe.
void _pruefeAbend(PartySitzung s, List<AbstecherOrt> abstecher) {
  var i = 0;
  var fortsetzungen = 0;
  while (true) {
    final r = _fortgesetzt(s, abstecher);
    // Eine offene verdeckte Ansicht schließt die Fortsetzung; sonst gleich.
    if (s.verdeckt == null) expect(_bild(r), _bild(s), reason: 'Schritt $i');
    if (i % 7 == 0 && s.verdeckt == null) {
      var j = i, k = i;
      while (_schritt(r, j++)) {}
      final kopie = _fortgesetzt(s, abstecher);
      while (_schritt(kopie, k++)) {}
      expect(_bild(r), _bild(kopie), reason: 'Ende ab Schritt $i');
      kopie.dispose();
      fortsetzungen++;
    }
    r.dispose();
    if (!_schritt(s, i++)) break;
    expect(i, lessThan(600), reason: 'Abend endet');
  }
  expect(s.phase, PartyPhase.ende);
  expect(fortsetzungen, greaterThan(5));
}

void main() {
  test('Ravensmoor reihum: Namen, Randgespräche, Gruppenwahl, Anklage', () {
    final s = PartySitzung(akteDaten('ravensmoor'), salz: 'ab12cd34ef56ab78');
    s.einrichten(rollen: 4, detektiv: 'm', code: FallCode.fuerPfad('witwe', s.kanon.pfade).code, namen: {'witwe': 'Ada', 'butler': 'Bo'});
    s.stimmeAn = true;
    s.erzaehltiefe = Erzaehltiefe.voll;
    _pruefeAbend(s, const []);
    expect(s.erzaehlFlags, isNotEmpty, reason: 'Gespräche geführt');
    s.dispose();
  });

  test('Schlosskeller solo mit Deck und Erkundungen; Zufallscode bleibt gleich', () {
    final abstecher = _abstecher('schlosskeller');
    final s = PartySitzung(partyDaten, salz: '0011223344556677');
    s.kartenAnlegen(vorrat: TischVorrat.aus(['schlosskeller:tim:stirnlampe'], _katalog), abstecher: abstecher);
    s.einrichten(rollen: 5, detektiv: 'w', solo: true);
    final code = s.fallCode.code;
    expect(_fortgesetzt(s, abstecher).fallCode.code, code);
    _pruefeAbend(s, abstecher);
    expect(s.abstecherErgebnis, isNotEmpty, reason: 'Erkundung gespielt');
    s.dispose();
  });

  test('Schlosskeller reihum: Befragungen, verdeckte Antwort und Spickzettel überstehen das Neuladen', () {
    final s = PartySitzung(partyDaten, salz: '7766554433221100');
    s.einrichten(rollen: 6, detektiv: 'm', code: FallCode.fuerPfad('can', s.kanon.pfade).code, namen: {'can': 'Cem'});
    _pruefeAbend(s, const []);
    expect(s.befragungsNotizen, isEmpty, reason: 'Reihum antworten Menschen, nicht die App');
    s.dispose();
  });

  test('Ein Abendstand der Fassung 1 des Schlosskellers wird mit Hinweis verworfen, andere Akten lesen ihn weiter', () {
    final s = PartySitzung(partyDaten, salz: 'aabbccddeeff0011')..einrichten(rollen: 4, detektiv: 'w');
    final stand = jsonDecode(jsonEncode(s.abendstand)) as Map<String, Object?>;
    expect(stand['format'], PartySitzung.abendstandFormat);
    expect(() => PartySitzung.fortsetzen(partyDaten, {...stand, 'format': 'abendstand/1'}), throwsA(isA<AbendstandVeraltet>()));
    expect(() => PartySitzung.fortsetzen(partyDaten, {...stand, 'format': 'abendstand/0'}), throwsA(isNot(isA<AbendstandVeraltet>())));
    final r = PartySitzung(akteDaten('ravensmoor'), salz: '1122334455667788')..einrichten(rollen: 4, detektiv: 'w');
    final alt = {...jsonDecode(jsonEncode(r.abendstand)) as Map<String, Object?>, 'format': 'abendstand/1'};
    expect(PartySitzung.fortsetzen(akteDaten('ravensmoor'), alt).phase, r.phase);
    s.dispose();
    r.dispose();
  });

  test('Ein Stand einer anderen Akte oder mit kaputtem Befehl wird abgelehnt', () {
    final s = PartySitzung(partyDaten, salz: 'feedfacecafebeef')..einrichten(rollen: 4, detektiv: 'w');
    final stand = jsonDecode(jsonEncode(s.abendstand)) as Map<String, Object?>;
    expect(() => PartySitzung.fortsetzen(akteDaten('ravensmoor'), stand), throwsFormatException);
    final kaputt = {...stand, 'befehle': [...stand['befehle'] as List, {'b': 'vor', 'option': 'gibt_es_nicht'}]};
    expect(() => PartySitzung.fortsetzen(partyDaten, kaputt), throwsFormatException);
    final fremd = {...stand, 'befehle': [{'b': 'zaubern'}]};
    expect(() => PartySitzung.fortsetzen(partyDaten, fremd), throwsFormatException);
    s.dispose();
  });

  group('Fassung (M7b)', () {
    test('Schlosskeller lang: Die Fassung steht im Journal, kommt nach dem Neuladen wieder und spielt den Abend zu Ende', () {
      final s = PartySitzung(langDaten, salz: '1357924680abcdef');
      s.einrichten(rollen: 5, detektiv: 'w', code: FallCode.fuerPfad('fatma', s.kanon.pfade).code, rundendauerMinuten: 25, fassung: Abendfassung.lang);
      expect([s.fassung, s.lang], [Abendfassung.lang, true]);
      final einrichten = (s.abendstand['befehle'] as List).cast<Map<String, Object?>>().firstWhere((b) => b['b'] == 'einrichten');
      expect(einrichten['fassung'], 'lang');
      final r = _fortgesetzt(s, const []);
      expect([r.fassung, r.rundendauer, r.weltSamen], [Abendfassung.lang, const Duration(minutes: 25), s.weltSamen]);
      r.dispose();
      _pruefeAbend(s, const []);
      s.dispose();
    });

    test('Kurz bleibt der Journal-Eintrag bytegleich wie vor M7b (kein Schlüssel fassung)', () {
      final s = PartySitzung(langDaten, salz: '0f0f0f0f0f0f0f0f');
      final code = FallCode.fuerPfad('olli', s.kanon.pfade).code;
      s.einrichten(rollen: 4, detektiv: 'm', code: code, rundendauerMinuten: 15);
      final befehle = jsonEncode(s.abendstand['befehle']);
      // Genau die Form vor M7b: dieselben Schlüssel in derselben Reihenfolge.
      expect(
        befehle,
        '[{"b":"einrichten","rollen":4,"detektiv":"m","code":"$code","druck":false,"solo":false,'
        '"minuten":15,"namen":{},"detektivName":""}]',
      );
      expect(befehle.contains('fassung'), isFalse);
      expect(_fortgesetzt(s, const []).fassung, Abendfassung.kurz);
      s.dispose();
    });

    test('Ein alter Stand ohne Schlüssel bleibt kurz; lang verlangt eine Akte mit Langfassung', () {
      final s = PartySitzung(partyDaten, salz: '2468ace013579bdf')..einrichten(rollen: 4, detektiv: 'w');
      expect(_fortgesetzt(s, const []).fassung, Abendfassung.kurz);
      final stand = jsonDecode(jsonEncode(s.abendstand)) as Map<String, Object?>;
      final befehle = [
        for (final b in (stand['befehle'] as List).cast<Map<String, Object?>>()) b['b'] == 'einrichten' ? {...b, 'fassung': 'lang'} : b,
      ];
      expect(() => PartySitzung.fortsetzen(partyDaten, {...stand, 'befehle': befehle}), throwsFormatException, reason: 'Ohne Akteneintrag kein langer Abend');
      expect(PartySitzung.fortsetzen(langDaten, {...stand, 'befehle': befehle}).fassung, Abendfassung.lang);
      expect(() => PartySitzung(akteDaten('ravensmoor'), salz: 'aa').einrichten(rollen: 4, detektiv: 'w', fassung: Abendfassung.lang), throwsArgumentError);
      expect(() => PartySitzung(langDaten, salz: 'bb').einrichten(rollen: 4, detektiv: 'w', druck: true, fassung: Abendfassung.lang), throwsArgumentError,
          reason: 'Das Druckspiel ist kurz');
      s.dispose();
    });

    test('Die Uhr gehört kurz nur zu den Gesprächen, lang zum ganzen Streifzug; eine Uhr je Runde', () {
      for (final f in Abendfassung.values) {
        final s = PartySitzung(langDaten, salz: 'c0ffee00c0ffee00', wuerfel: const FesterWuerfel.neutral());
        var t = 0;
        s.abendzeit = () => t;
        s.einrichten(rollen: 4, detektiv: 'w', code: FallCode.fuerPfad('ahmet', s.kanon.pfade).code, fassung: f);
        while (s.phase != PartyPhase.gespraeche) {
          s.weiter();
        }
        expect(s.uhrInPhase, isTrue);
        expect(s.uhrAktion(UhrAktion.start), isTrue);
        final gestartet = s.uhr;
        while (s.phase == PartyPhase.gespraeche) {
          if (!_schritt(s, 1)) break;
        }
        expect(s.phase, PartyPhase.entscheidungen);
        expect(s.uhrInPhase, f.istLang, reason: '$f');
        if (f.istLang) expect(s.uhr, gestartet, reason: 'Dieselbe Uhr läuft weiter');
        var i = 0;
        while (s.phase == PartyPhase.entscheidungen) {
          _schritt(s, i++);
        }
        expect(s.uhrInPhase, isFalse, reason: 'Gruppenwahl: keine Uhr');
        while (s.phase != PartyPhase.gespraeche) {
          _schritt(s, i++);
        }
        expect(s.uhr.gestartet, isFalse, reason: 'Neue Runde, neue Uhr ($f)');
        s.dispose();
      }
    });

    test('Der Weltsamen hängt nur am Salz und lässt den Würfelstrom unberührt', () {
      final a = PartySitzung(langDaten, salz: 'abcdefabcdef0123'), b = PartySitzung(langDaten, salz: 'abcdefabcdef0123');
      final c = PartySitzung(langDaten, salz: 'abcdefabcdef0124');
      expect(a.weltSamen, b.weltSamen);
      expect(a.weltSamen, isNot(c.weltSamen));
      expect(a.weltSamen, Rng.hashString('welt:abcdefabcdef0123'));
      // Den Samen zu lesen, ändert keinen Wurf: zwei gleiche Abende, nur einer liest ihn oft.
      final code = FallCode.fuerPfad('can', a.kanon.pfade).code;
      final kurz = PartySitzung(langDaten, salz: '99887766554433aa')..einrichten(rollen: 4, detektiv: 'w', code: code);
      final lang = PartySitzung(langDaten, salz: '99887766554433aa')..einrichten(rollen: 4, detektiv: 'w', code: code, fassung: Abendfassung.lang);
      var i = 0;
      while (_schritt(kurz, i)) {
        for (var k = 0; k < 3; k++) {
          lang.weltSamen;
        }
        expect(_schritt(lang, i), isTrue);
        i++;
      }
      expect(lang.phase, PartyPhase.ende);
      expect([for (final w in lang.wuerfe) w.toJson()], [for (final w in kurz.wuerfe) w.toJson()]);
      expect([lang.spiel.punkte, lang.ende.id, lang.restMinuten, lang.spiel.pfad], [kurz.spiel.punkte, kurz.ende.id, kurz.restMinuten, kurz.spiel.pfad]);
      for (final x in [a, b, c, kurz, lang]) {
        x.dispose();
      }
    });
  });

  test('Die Daten der Fortsetzung kommen aus derselben Akte', () {
    final PartyDaten d = akteDaten('ravensmoor');
    final s = PartySitzung(d, salz: '1234123412341234')..einrichten(rollen: 6, detektiv: 'w');
    expect(PartySitzung.fortsetzen(d, s.abendstand).daten, same(d));
    s.dispose();
  });
}
