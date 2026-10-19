// Klassenfähigkeiten auf der Karte (A-055, M6): feste Werte je Klasse,
// Architektur-Wächter (keine Partie, keine Zugschicht, keine Würfel, keine
// zustandsändernden Aufrufe) und die Gerüchte des Schlosskellers.
import 'dart:io';

import 'package:mordakte_core/mordakte_core.dart';
import 'package:test/test.dart';

import '../party/kanon_hilfe.dart';

/// Dateien der Klassenfähigkeiten in Kern und App.
const _dateien = [
  'packages/mordakte_core/lib/src/karten/klassen.dart',
  'packages/mordakte_core/lib/src/karten/geruechte.dart',
  'packages/mordakte_core/lib/src/karten/sperrwoerter.dart',
  'lib/party/klasse_wirkung.dart',
];

/// Importe, die eine Klassenfähigkeit nie braucht: Partie, Zugschicht, Würfel
/// und die Bibliothek, die sie bündelt.
final _verbotenerImport = RegExp(r'''^\s*import\s+['"][^'"]*(runden/partie|zugschicht|wuerfel|package:mordakte_core/runden\.dart)''');

/// Aufrufe, die den Abend verändern (Sitzung, Partie, Raum).
final _zustandsAufruf = RegExp(
  r'\.(wuerfeln|aktionFertig|tischruf|fundGelesen|schlageVor|schlageVorAn|bestaetigen|weiter|einrichten|anklagen|stimme|'
  r'karteSpielen|starteAbstecher|randgespraechBeginnen|randgespraechWaehlen|randgespraechBeenden|zeigeVerdeckt|verdecken|nachricht|senden|send|move)\(',
);

Geruechte _schlosskeller() => Geruechte.ausJson(leseJson('$repoWurzel/content/welt/schlosskeller/geruechte.json'));

Map<String, Object?> _textregeln() => leseJson('$repoWurzel/content/party/textregeln.json');

void main() {
  group('Klassen', () {
    test('jede Detektivklasse hat genau eine Fähigkeit und umgekehrt', () {
      final faehigkeiten = {for (final k in detectiveClasses.keys) k: KlassenFaehigkeit.vonKlasse(k)};
      expect(faehigkeiten.values, everyElement(isNotNull));
      expect(faehigkeiten.values.toSet(), hasLength(KlassenFaehigkeit.values.length));
      for (final f in KlassenFaehigkeit.values) {
        expect(KlassenFaehigkeit.vonKlasse(f.klasse), f);
      }
      expect(KlassenFaehigkeit.vonKlasse('unbekannt'), isNull);
      expect(KlassenFaehigkeit.vonKlasse(null), isNull);
    });

    test('feste Werte: Spurenblick 6 statt 3, Laufschritt × 1,3, sonst Grundtempo', () {
      for (final f in KlassenFaehigkeit.values) {
        final p = KlassenParameter.von(f);
        expect(p.glanzRadius, f == KlassenFaehigkeit.spurenblick ? 6 : 3, reason: f.name);
        expect(p.tempoFaktor, f == KlassenFaehigkeit.laufschritt ? 1.3 : 1, reason: f.name);
        expect(p.tuerenZeigen, f == KlassenFaehigkeit.ortskundig, reason: f.name);
        expect(p.gespraechsMarker, f == KlassenFaehigkeit.menschenkenner, reason: f.name);
        expect(p.stimmungZeigen, f == KlassenFaehigkeit.menschenkenner, reason: f.name);
        expect(p.geruechte, f == KlassenFaehigkeit.geruechte, reason: f.name);
      }
    });

    test('Architektur: keine Partie, keine Zugschicht, keine Würfel, keine zustandsändernden Aufrufe', () {
      final befunde = <String>[];
      for (final pfad in _dateien) {
        final datei = File('$repoWurzel/$pfad');
        expect(datei.existsSync(), isTrue, reason: '$pfad fehlt');
        final zeilen = datei.readAsLinesSync();
        for (var i = 0; i < zeilen.length; i++) {
          final z = zeilen[i];
          if (z.trimLeft().startsWith('//')) continue;
          if (_verbotenerImport.hasMatch(z)) befunde.add('$pfad:${i + 1}: Import $z');
          if (_zustandsAufruf.firstMatch(z) case final m?) befunde.add('$pfad:${i + 1}: Aufruf ${m.group(0)}');
        }
      }
      expect(befunde, isEmpty);
    });

    test('Gegenprobe: der Wächter erkennt einen Würfelimport und einen Zustandsaufruf', () {
      expect(_verbotenerImport.hasMatch("import '../runden/wuerfel.dart';"), isTrue);
      expect(_verbotenerImport.hasMatch("import 'package:mordakte_core/runden.dart' show KlassenParameter;"), isTrue);
      expect(_zustandsAufruf.hasMatch('sitzung.wuerfeln();'), isTrue);
      expect(_zustandsAufruf.hasMatch('quelle.runde'), isFalse);
    });
  });

  group('Gerüchte', () {
    final kanon = ladeKanon();
    final ton = Textpruefer(_textregeln());

    test('Schema der Gerüchtdatei', () {
      final schema = SchemaPruefer(leseJson('$repoWurzel/content/welt/geruechte.schema.json'));
      expect(schema.pruefe(leseJson('$repoWurzel/content/welt/schlosskeller/geruechte.json')), isEmpty);
    });

    test('Schlosskeller: jede Figur, jede Runde, ohne Befund (R15, R17, Fünf-Wort-Regel, Ton)', () {
      final g = _schlosskeller();
      expect(g.akte, 'schlosskeller');
      expect(pruefeGeruechte(g, kanon, ton: ton), isEmpty);
      for (final f in kanon.figuren) {
        for (var r = 1; r <= 3; r++) {
          expect(g.zeilen(f['id'] as String, r), isNotEmpty, reason: '${f['id']} Runde $r');
        }
      }
    });

    test('nur der Schlosskeller hat Gerüchte, und welt.json nennt sie', () {
      for (final d in Directory('$repoWurzel/content/welt').listSync().whereType<Directory>()) {
        final akte = d.uri.pathSegments.where((s) => s.isNotEmpty).last;
        expect(File('${d.path}/geruechte.json').existsSync(), akte == 'schlosskeller', reason: akte);
        expect(leseJson('${d.path}/welt.json')['geruechte'], akte == 'schlosskeller' ? 'geruechte.json' : isNull, reason: akte);
      }
    });

    /// Gerüchte des Schlosskellers mit [zeile] statt der ersten Zeile von Tim in Runde 1.
    Geruechte mit(String zeile) {
      final j = leseJson('$repoWurzel/content/welt/schlosskeller/geruechte.json');
      final eintraege = [for (final e in j['geruechte'] as List) Map<String, Object?>.of(e as Map<String, Object?>)];
      final tim = eintraege.firstWhere((e) => e['figur'] == 'tim' && e['runde'] == 1);
      tim['zeilen'] = [zeile];
      return Geruechte.ausJson({...j, 'geruechte': eintraege});
    }

    test('Gegenproben: Name, Sperrwort, Sperrort, Gegenstand, Länge, Ton und Lücke fallen auf', () {
      expect(pruefeGeruechte(mit('Ahmet war vorhin lange weg.'), kanon), isNotEmpty, reason: 'Name');
      expect(pruefeGeruechte(mit('Der Schlüssel liegt sicher oben.'), kanon), isNotEmpty, reason: 'Sperrwort');
      expect(pruefeGeruechte(mit('Am Jackenständer hängt viel Zeug.'), kanon), isNotEmpty, reason: 'Sperrort');
      expect(pruefeGeruechte(mit('Die Leuchtmaske ist unheimlich.'), kanon), isNotEmpty, reason: 'Gegenstand');
      expect(pruefeGeruechte(mit('Eins zwei drei vier fünf sechs sieben acht neun.'), kanon), isNotEmpty, reason: 'Länge');
      expect(pruefeGeruechte(mit('Hier gab es früher viel Bier.'), kanon, ton: ton), isNotEmpty, reason: 'Ton');
      final j = leseJson('$repoWurzel/content/welt/schlosskeller/geruechte.json');
      final ohneTim = Geruechte.ausJson({
        ...j,
        'geruechte': [for (final e in j['geruechte'] as List) if ((e as Map)['figur'] != 'tim' || e['runde'] != 2) e],
      });
      expect(pruefeGeruechte(ohneTim, kanon), contains(startsWith('tim, Runde 2')));
    });
  });
}
