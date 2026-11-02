// Platzhalter und Auszeichnung der Kammerspiel-Texte (SCHEMA.md Abschnitte 3 und 4).
import 'package:mordakte_core/kammer_io.dart';
import 'package:test/test.dart';

const rollen = {'lejla', 'marek', 'joanna', 'damir'};

KammerTextWerte werte({Set<String> besetzt = const {}, int personen = 10, bool w = false, Map<String, String> wert = const {}}) =>
    KammerTextWerte(
      besetzt: besetzt,
      namen: const {'lejla': 'Lejla', 'marek': 'Marek', 'joanna': 'Joanna', 'damir': 'Damir'},
      personen: personen,
      detektivWeiblich: w,
      werte: wert,
    );

Matcher fehler(String teil) => throwsA(isA<FormatException>().having((e) => e.message, 'message', contains(teil)));

void main() {
  group('Auflösen', () {
    test('rolle: Name oder Ersatz, Ersatz darf leer sein', () {
      const t = '{rolle:marek|Der Caterer} stand neben mir.';
      expect(loeseKammerText(t, werte(besetzt: {'marek'})), 'Marek stand neben mir.');
      expect(loeseKammerText(t, werte()), 'Der Caterer stand neben mir.');
      expect(loeseKammerText('a{rolle:marek|}b', werte()), 'ab');
    });

    test('wenn: alle genannten Rollen besetzt, Sonst darf fehlen', () {
      const t = 'Das Buffet hab ich {wenn:marek|mit Marek }geplant.';
      expect(loeseKammerText(t, werte(besetzt: {'marek'})), 'Das Buffet hab ich mit Marek geplant.');
      expect(loeseKammerText(t, werte()), 'Das Buffet hab ich geplant.');
      const zwei = '{wenn:marek,joanna|beide|nicht beide}';
      expect(loeseKammerText(zwei, werte(besetzt: {'marek'})), 'nicht beide');
      expect(loeseKammerText(zwei, werte(besetzt: {'marek', 'joanna'})), 'beide');
    });

    test('ab: Personenzahl, detektiv: männlich oder weiblich', () {
      expect(loeseKammerText('{ab:18|sieben|fünf}', werte(personen: 17)), 'fünf');
      expect(loeseKammerText('{ab:18|sieben|fünf}', werte(personen: 18)), 'sieben');
      expect(loeseKammerText('x{ab:13| Karte}', werte(personen: 12)), 'x');
      expect(loeseKammerText('{detektiv:der Detektiv|die Detektivin}', werte()), 'der Detektiv');
      expect(loeseKammerText('{detektiv:der Detektiv|die Detektivin}', werte(w: true)), 'die Detektivin');
    });

    test('verschachtelt und mit Werten', () {
      const t = '{wenn:joanna|Joanna sagt: „{rolle:marek|Der Caterer} war da.“|Niemand sagt etwas.} Code {code}.';
      expect(loeseKammerText(t, werte(besetzt: {'joanna'}, wert: {'code': 'WW4'})),
          'Joanna sagt: „Der Caterer war da.“ Code WW4.');
      expect(loeseKammerText(t, werte(wert: {'code': 'WW4'})), 'Niemand sagt etwas. Code WW4.');
      expect(() => loeseKammerText('Code {code}.', werte()), fehler('{code}'));
    });

    test('Text ohne Platzhalter bleibt gleich, auch mit | außerhalb', () {
      const t = '„Hab ich dich!“ Dann: „Stehen bleiben!“ | 23:57 Uhr';
      expect(loeseKammerText(t, werte()), t);
    });

    test('kammerTextRollen sammelt die genannten Rollen', () {
      expect(kammerTextRollen('{rolle:marek|x} {wenn:joanna,damir|{rolle:lejla|y}}'), {'marek', 'joanna', 'damir', 'lejla'});
      expect(kammerTextRollen('{ab:13|x} {detektiv:a|b}'), isEmpty);
    });
  });

  group('Prüfen', () {
    test('gültige Texte', () {
      for (final t in [
        'Ganz normaler Text.',
        '{rolle:lejla|deine Cousine}',
        '{wenn:damir|Damir war dabei.|Ein Gast war dabei.}',
        '**Karte zu:** „a“\n**Karte offen:** „b“',
        '{ab:14|*leise*}',
        'OFFEN: RK 4.7 (a)',
      ]) {
        expect(() => pruefeKammerText(t, rollen: rollen), returnsNormally, reason: t);
      }
      expect(() => pruefeKammerText('{name} und {code}', rollen: rollen, werte: null), returnsNormally);
      expect(() => pruefeKammerText('{bund}', rollen: rollen, werte: {'bund'}), returnsNormally);
    });

    test('Fehler werden erkannt', () {
      expect(() => pruefeKammerText('{rolle:baran|x}', rollen: rollen), fehler('unbekannte Rolle'));
      expect(() => pruefeKammerText('{wenn:marek,baran|x}', rollen: rollen), fehler('unbekannte Rolle'));
      expect(() => pruefeKammerText('{rolle:marek,lejla|x}', rollen: rollen), fehler('genau eine Rolle'));
      expect(() => pruefeKammerText('{rolle:marek}', rollen: rollen), fehler('braucht „|“'));
      expect(() => pruefeKammerText('{rolle:marek|a|b}', rollen: rollen), fehler('Teile'));
      expect(() => pruefeKammerText('{detektiv:nur eins}', rollen: rollen), fehler('Teile'));
      expect(() => pruefeKammerText('{ab:viele|x}', rollen: rollen), fehler('Personenzahl'));
      expect(() => pruefeKammerText('{farbe:rot|x}', rollen: rollen), fehler('unbekannter Platzhalter'));
      expect(() => pruefeKammerText('offen {rolle:marek|x', rollen: rollen), fehler('ohne „}“'));
      expect(() => pruefeKammerText('zu }', rollen: rollen), fehler('ohne „{“'));
      expect(() => pruefeKammerText('{Name}', rollen: rollen), fehler('Wert-Platzhalter'));
      expect(() => pruefeKammerText('{code}', rollen: rollen), fehler('nicht erlaubt'));
      expect(() => pruefeKammerText('**fett', rollen: rollen), fehler('nicht geschlossen'));
      expect(() => pruefeKammerText('{wenn:marek|**fett|normal}**', rollen: rollen), fehler('nicht geschlossen'));
    });
  });

  group('Auszeichnung', () {
    test('Absätze, Zeilen, fett und kursiv', () {
      final a = kammerAuszeichnung('Erste **fette** Zeile\nzweite *kursive*\n\nZweiter Absatz.');
      expect(a, hasLength(2));
      expect(a[0].zeilen, [
        [const KammerLauf('Erste '), const KammerLauf('fette', fett: true), const KammerLauf(' Zeile')],
        [const KammerLauf('zweite '), const KammerLauf('kursive', kursiv: true)],
      ]);
      expect(a[1].klartext, 'Zweiter Absatz.');
    });

    test('Leerraum wird zusammengefasst, leere Absätze fallen weg', () {
      expect(kammerKlartext('  a   b \n\n\n   \n\n c '), 'a b\n\nc');
      expect(kammerAuszeichnung(''), isEmpty);
    });

    test('fett über Zeilen in einem Absatz, nicht über Absätze', () {
      expect(kammerAuszeichnung('**a\nb**').single.zeilen.expand((z) => z).every((l) => l.fett), isTrue);
      expect(() => kammerAuszeichnung('**a\n\nb**'), throwsFormatException);
    });

    test('OFFEN-Marke', () {
      expect(istKammerOffen('OFFEN: RK 2.7'), isTrue);
      expect(istKammerOffen('Offen gesagt'), isFalse);
      expect(kammerOffenMarke, 'OFFEN:');
    });
  });
}
