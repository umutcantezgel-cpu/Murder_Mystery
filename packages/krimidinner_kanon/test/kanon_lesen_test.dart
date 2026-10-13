// Kanonleser: Zeilen-Parser, Lesebefunde, DOPPELT und die Auswahl der Kanondateien.
import 'package:krimidinner_kanon/krimidinner_kanon.dart';
import 'package:test/test.dart';

/// Kleiner, absichtlich kaputter Kanon. Die Befundtexte stammen aus `kanon.py`.
KrimiKanon kleinesKanon() => KrimiKanon.ausText({
  'K1-KLEIN.md': [
    '@Z-1 [L] | Zeit: 23:47 | Wer: R03 | Ort: Hof | Was: a',
    '@Z-2 [L] | Zeit: 23:47 | Wer: R03, R04 | Ort: Speisekammer | Was: b',
    '@S-1 [L] | Schlussfolgerung: x | Notwendig: ja | Hinweise: H-05',
    '@H-05 [O] | Inhalt: x | Form: Karte | Quelle: Station Burgtor | Phase: 1 | Min: 4',
  ].join('\n'),
  'K4-KLEIN.md':
      '@G1-01 [G] | Von: R03 | Ziel: R07 | Ersatz: – | Min: 5 | Bedingung: x | '
      'Frage: x | Antwort: x | Antwortart: wahr | Gibt heraus: H-101 | '
      'Ersatz-Bedingung: – | Ersatz-Frage: – | Ersatz-Antwort: – | Ersatz-Antwortart: – | '
      'Ersatz gibt heraus: nichts | Zusammenfall: nein',
  'K5-KLEIN.md': [
    '@D1-1 [O] | Phase: 1 | Frage: x | Option A: R05 kommt | Option B: y | Option C: z | '
        'Begründbar durch: H-05',
    '@DW1-1 [L] | Echte Spur: A | Falsche Fährte: B | Ablenkung: C | Ergebnis A: a | '
        'Ergebnis B: b | Ergebnis C: c',
    '@E1-07 [G] | Rolle: R07 | Lage: x | Option 1: a → Folge: b | Umsetzung: Kartenaktion',
  ].join('\n'),
});

void main() {
  group('Zeilen-Parser', () {
    test('Felder am ersten ": ", Werte getrimmt, – ist leer', () {
      final k = KrimiKanon.ausText({
        'K1-T.md':
            '@A-1 [O] | Name:  Anna  | Leer: – | Frage: Wie: spät? | Zeit:12:30: Ende\n',
      });
      final a = k.datensaetze['A-1']!;
      expect(a.sicht, Sicht.o);
      expect(a.felder.keys.toList(), ['Name', 'Leer', 'Frage', 'Zeit:12:30']);
      expect(a.feld('Name'), 'Anna');
      expect(a.feld('Leer'), '');
      expect(a.feld('Frage'), 'Wie: spät?');
      expect(a.feld('Zeit:12:30'), 'Ende');
      expect(a.feld('Fehlt'), isNull);
      expect(k.lesefehler, isEmpty);
    });

    test('Zeilen ohne @ fallen weg, Kopf- und Feldfehler melden Lesebefunde', () {
      final k = KrimiKanon.ausText({
        'K1-T.md':
            'Überschrift\n@X 2 [O] | A: b\n@X-3 [O] Kaputt\n@X-4 [O] | Name: ok\n',
      });
      expect(k.datensaetze.keys.toList(), ['X-3', 'X-4']);
      expect(k.lesefehler, [
        'SYNTAX K1-T.md:2: Kopf unlesbar: @X 2 [O] | A: b',
        'SYNTAX K1-T.md:3: Feld ohne Doppelpunkt in X-3: Kaputt',
      ]);
    });

    test(
      'doppelte Kennung wirft FormatException DOPPELT mit Datei und Zeile',
      () {
        expect(
          () => KrimiKanon.ausText({
            'K1-A.md': '@D-1 [O] | A: 1\n',
            'K2-B.md': '\n@D-1 [G] | A: 2\n',
          }),
          throwsA(
            isA<FormatException>().having(
              (e) => e.message,
              'message',
              'DOPPELT D-1: K1-A.md:1 und K2-B.md:2',
            ),
          ),
        );
      },
    );

    test('liest nur K*.md in Namensreihenfolge', () {
      final k = KrimiKanon.ausText({
        'PROTOKOLL.md': '@P-1 [O] | A: b\n',
        'GESAMT-KANON.md': '@A-1 [O] | A: doppelt\n',
        'K2-B.md': '@B-1 [O] | A: x\n',
        'K1-A.md': '@A-1 [O] | A: y\n',
      });
      expect(k.datensaetze.keys.toList(), ['A-1', 'B-1']);
      expect(k.datensaetze['A-1']!.feld('A'), 'y');
    });

    test('istKanonDatei: K*.md ja, Begleitdateien nein', () {
      expect(istKanonDatei('K1-GRUNDWAHRHEIT.md'), isTrue);
      expect(istKanonDatei('K9-LOOKBIBEL.md'), isTrue);
      for (final name in [
        'GESAMT-KANON.md',
        'FORMAT.md',
        'VERSION.md',
        'PROTOKOLL.md',
        'SELBSTPRUEFUNG.md',
        'K1-GRUNDWAHRHEIT.txt',
      ]) {
        expect(istKanonDatei(name), isFalse, reason: name);
      }
      expect(
        istKanonDatei(
          'krimidinner/spuk-im-gewoelbe/10_kanon/K4-GESPRAECHE-P1.md',
        ),
        isTrue,
      );
      expect(
        istKanonDatei('krimidinner/spuk-im-gewoelbe/10_kanon/FORMAT.md'),
        isFalse,
      );
    });

    test('alsZeile schreibt leere Werte wieder als –', () {
      final k = KrimiKanon.ausText({'K1-T.md': '@A-1 [G] | X: – | Y: v\n'});
      expect(k.datensaetze['A-1']!.alsZeile, '@A-1 [G] | X: – | Y: v');
    });

    test('mitPraefix liefert Datensätze in Lesereihenfolge', () {
      final k = KrimiKanon.ausText({
        'K1-T.md':
            '@R01-STAMM [O] | A: 1\n@R01-GEHEIM [G] | A: 2\n@R02-STAMM [O] | A: 3\n',
      });
      expect(k.mitPraefix('R01-').map((d) => d.id), [
        'R01-STAMM',
        'R01-GEHEIM',
      ]);
    });
  });

  group('Proben wie kanon.py (gleiche Befundtexte)', () {
    test('Gespräch mit falschem Min und fehlendem Ersatzziel', () {
      expect(probeErsatz(kleinesKanon()), [
        'ERSATZ G1-01: Ziel R07 > R03 braucht Ersatzziel',
        'SPIEGEL G1-01: Ersatz-Bedingung fehlt',
        'SPIEGEL G1-01: Ersatz-Frage fehlt',
        'SPIEGEL G1-01: Ersatz-Antwort fehlt',
        'SPIEGEL G1-01: Ersatz-Antwortart fehlt',
        'MIN G1-01: Min 5 statt 7',
      ]);
    });

    test('fehlender HW-Datensatz und Absicherung', () {
      expect(probeAbsicherung(kleinesKanon()), [
        'ABSICHERUNG S-1: kein unblockierbarer Hinweis',
        for (var n = 4; n <= 19; n++)
          'ABSICHERUNG S-1 N=$n: 1 unabhängige Quellen (Soll 2)',
        'ABSICHERUNG S-1 N=20: 1 unabhängige Quellen (Soll 3)',
        'HINWEIS H-05: Wahrheitsdatensatz HW-05 fehlt',
      ]);
    });

    test('Zeitkonflikt einer Person zur selben Minute', () {
      expect(probeZeit(kleinesKanon()), [
        'ZEIT R03 23:47:00: Hof (Z-1) und Speisekammer (Z-2)',
      ]);
    });

    test('Erweiterungsrolle in einer Option des Detektiv-Entscheids', () {
      expect(
        probeD(kleinesKanon()).where((z) => z.startsWith('D1-1')).toList(),
        ['D1-1: Option A nennt Erweiterungsrolle R05'],
      );
    });

    test('Ereignis mit nur einer Option', () {
      expect(
        probeE(kleinesKanon()).where((z) => z.startsWith('E1-07')).toList(),
        ['E1-07: 1 Optionen (2–3 verlangt)'],
      );
    });

    test('unbekannte Kennung im Verweis', () {
      expect(probeSyntax(kleinesKanon()), [
        'VERWEIS G1-01.Gibt heraus: unbekannte Kennung H-101',
      ]);
    });

    test('tatsaechliche: regulär, Ersatz und fehlendes Ziel', () {
      final k = KrimiKanon.ausText({
        'K4-T.md': [
          '@G1-01 [G] | Von: R01 | Ziel: R02 | Ersatz: –',
          '@G1-02 [G] | Von: R02 | Ziel: R07 | Ersatz: R03',
          '@G1-03 [G] | Von: R03 | Ziel: R09 | Ersatz: –',
          '@G2-01 [G] | Von: R01 | Ziel: R02 | Ersatz: –',
        ].join('\n'),
      });
      final p1 = tatsaechliche(k, 1, 6);
      expect(p1.map((t) => (t.$1, t.$2, t.$3.id, t.$4)), [
        (1, 2, 'G1-01', 'regulär'),
        (2, 3, 'G1-02', 'ersatz'),
        (3, null, 'G1-03', 'FEHLT'),
      ]);
      expect(tatsaechliche(k, 1, 7)[1].$4, 'regulär');
      expect(gespraeche(k, 2).single.$2.id, 'G2-01');
    });
  });
}
