// KammerBesetzung für 6 bis 20 Personen (E6, E7, MECH 4.6, 5.1, 9.13, 10.1,
// 10.2, ZR 0.2, ZR 13): welche Hefte, Tandems und Solo-Rollen, Abwesenheitsblatt
// genau dann, wenn einer der Plätze 5–10 fehlt, Tipp-Zettel für alle Rollen und
// den Erzähler, Marker zwei je Rolle plus Detektiv und Herr Schneider.
import 'package:mordakte_core/kammer_io.dart';
import 'package:test/test.dart';

import '../kanon_hilfe.dart';

KammerInhalt? _inhalt;
KammerInhalt get inhalt => _inhalt ??= ladeKammerInhalt(repoWurzel);

KammerBesetzung bei(int personen) => KammerBesetzung.fuer(inhalt, personen: personen);

/// Skalierungstabelle MECH 9.13: neu besetzt, Streifen, Aktionskarten beim Detektiv, Zusatzhefte, allein.
const tabelle = {
  6: (null, 6, 6, 0, null),
  7: ('lejla', 5, 5, 0, null),
  8: ('emine', 4, 4, 0, null),
  9: ('tim', 3, 3, 0, null),
  10: ('joanna', 2, 2, 0, null),
  11: ('marek', 1, 1, 0, null),
  12: ('zeynep', 0, 0, 0, null),
  13: ('sibel', 0, 0, 1, 'sibel'),
  14: ('damir', 0, 0, 2, null),
  15: ('hana', 0, 0, 3, 'hana'),
  16: ('serkan', 0, 0, 4, null),
  17: ('azra', 0, 0, 5, 'azra'),
  18: ('wojtek', 0, 0, 6, null),
  19: ('aylin', 0, 0, 7, 'aylin'),
  20: ('tugba', 0, 0, 8, null),
};

/// Aktionskarten beim Detektiv nach MECH 4.6.
const beimDetektiv = {
  6: ['Krankenbesuch', 'Kreuzverhör', 'Stirnlampe', 'Zeitstempel', 'Taschenkontrolle', 'Gelbe Karte'],
  7: ['Kreuzverhör', 'Stirnlampe', 'Zeitstempel', 'Taschenkontrolle', 'Gelbe Karte'],
  8: ['Stirnlampe', 'Zeitstempel', 'Taschenkontrolle', 'Gelbe Karte'],
  9: ['Zeitstempel', 'Taschenkontrolle', 'Gelbe Karte'],
  10: ['Taschenkontrolle', 'Gelbe Karte'],
  11: ['Gelbe Karte'],
};

List<String> ids(Iterable<KammerPlatz> p) => [for (final x in p) x.id];

void main() {
  test('außerhalb von 6 bis 20 Personen: RangeError', () {
    for (final p in [-1, 0, 4, 5, 21, 40]) {
      expect(() => bei(p), throwsRangeError, reason: '$p');
    }
  });

  for (var personen = 6; personen <= 20; personen++) {
    group('$personen Personen', () {
      final b = bei(personen);
      final rollen = personen - 2;
      final (neu, streifen, aktionen, zusatzhefte, allein) = tabelle[personen]!;

      test('Rollen = Personen − 2, besetzt sind die Plätze 1 bis Rollen (E6)', () {
        expect(b.rollen, rollen);
        expect([for (final p in b.besetzt) p.platz], [for (var i = 1; i <= rollen; i++) i]);
        expect(b.neuBesetzt?.id, neu);
        expect(ids(b.verdaechtige), ['ahmet', 'fatma', 'olli', 'can']);
      });

      test('Hefte: Teil 10 für Plätze 1–10, Teil 12 für 11–18', () {
        expect([for (final p in b.hauptrollen) p.platz], [for (var i = 1; i <= (rollen < 10 ? rollen : 10); i++) i]);
        expect(b.zusatzrollen, hasLength(zusatzhefte));
        expect([for (final p in b.zusatzrollen) p.platz], [for (var i = 11; i <= rollen; i++) i]);
        expect(b.hauptrollen.length + b.zusatzrollen.length, rollen);
      });

      test('fehlende Zeugen, Abwesenheitsblatt genau dann, wenn einer der Plätze 5–10 fehlt (E7)', () {
        final fehlend = [for (var p = 5; p <= 10; p++) if (p > rollen) inhalt.platz(p).id];
        expect(ids(b.fehlendeZeugen), fehlend);
        expect(b.fehlendeZeugen, hasLength(streifen));
        expect(b.abwesenheitsblatt, fehlend.isNotEmpty);
        expect(b.abwesenheitsblatt, personen <= 11);
        expect([for (final s in b.streifen) s.zeuge], fehlend);
      });

      test('Aktionskarten fehlender Zeugen beim Detektiv (MECH 4.6)', () {
        expect(b.aktionskartenBeimDetektiv, hasLength(aktionen));
        expect([for (final p in b.aktionskartenBeimDetektiv) inhalt.rolle(p.id).aktionskarte.name],
            beimDetektiv[personen] ?? const <String>[]);
      });

      test('Geheimnis- und Aktionskarten: besetzte Rollen und fehlende Zeugen (MECH 10.1)', () {
        final erwartet = personen <= 12 ? 10 : rollen;
        expect(b.geheimniskarten, hasLength(erwartet));
        expect(b.aktionskarten, hasLength(erwartet));
        expect([for (final p in b.geheimniskarten) p.platz], [for (var i = 1; i <= erwartet; i++) i]);
        expect(b.geheimniskarten.where((p) => p.art == KammerArt.zusatz && !b.istBesetzt(p.id)), isEmpty);
      });

      test('Tandems und Solo (E6, ZR 0.2, ZR 13)', () {
        final zusatz = rollen > 10 ? rollen - 10 : 0;
        expect(b.tandems, hasLength((zusatz + 1) ~/ 2));
        expect(b.solo?.id, allein);
        expect(b.solo != null, zusatz.isOdd);
        for (final t in b.tandems) {
          expect([for (final p in t.besetzt) p.platz], [for (final p in t.tandem.plaetze) if (p <= rollen) p]);
          if (t.solo) {
            // Allein spielt immer der kleinere Platz; der Partner fehlt.
            expect(t.besetzt.single.platz, t.tandem.plaetze.first);
            expect(b.istBesetzt(inhalt.platz(t.tandem.plaetze.last).id), isFalse);
          }
        }
        if (b.solo != null) expect(inhalt.rolle(b.solo!.id).solo, isNotNull);
      });

      test('Tipp-Zettel für alle Rollen und den Erzähler, nicht für den Detektiv (MECH 7.1)', () {
        expect(b.tippZettel, rollen + 1);
        expect(b.tippZettel, personen - 1);
      });

      test('Marker: zwei je Rolle, zwei für den Detektiv, zwei für Herrn Schneider (MECH 10.2)', () {
        final m = b.marker;
        expect(m, hasLength(2 * rollen + 4));
        expect(m.length, lessThanOrEqualTo(inhalt.tisch.marker.max));
        expect(m.toSet(), hasLength(m.length));
        for (final p in b.besetzt) {
          expect([for (final x in m) if (x.wer == p.id) x.zeitpunkt], ['z2357', 'scheppern'], reason: p.id);
        }
        expect([for (final x in m) if (x.platz == null) '${x.wer}/${x.zeitpunkt}'],
            ['$kammerDetektiv/z2357', '$kammerDetektiv/scheppern', '$kammerSchneider/z2357', '$kammerSchneider/scheppern']);
        final fehlend = [for (final p in inhalt.fall.plaetze) if (!b.istBesetzt(p.id)) p.id];
        expect(m.where((x) => fehlend.contains(x.wer)), isEmpty);
      });

      test('Blatt B hat Platz für alle Marker, wie behauptet und wie wahr (MECH 10.2, WELT 4)', () {
        final platz = {for (final f in inhalt.tisch.markerfelder.belegung) f.feld: f.plaettchen};
        String feld(KammerMarker m, {required bool wahr}) {
          if (m.platz == null) {
            final f = inhalt.tisch.marker.feste.firstWhere((x) => x.wer == m.wer);
            return m.zeitpunkt == 'z2357' ? f.z2357 : f.scheppern;
          }
          final x = inhalt.rolle(m.wer).marker;
          if (m.zeitpunkt == 'z2357') return wahr ? x.wahr2357 : x.behauptet2357;
          return wahr ? x.wahrScheppern : x.behauptetScheppern;
        }

        // Obergrenze: ein Marker zählt in jedem Feld, auf dem er im Lauf des Abends stehen kann.
        final belegt = <String, int>{};
        for (final m in b.marker) {
          for (final f in {feld(m, wahr: false), feld(m, wahr: true)}) {
            belegt[f] = (belegt[f] ?? 0) + 1;
          }
        }
        for (final e in belegt.entries) {
          expect(e.value, lessThanOrEqualTo(platz[e.key]!), reason: 'Feld ${e.key}');
        }
      });

      test('Schwellen: Verhörstuhl leise ab 12, Gegenüberstellung ab 14, kurze Runde bis 8', () {
        expect(b.verhoerLeise, personen >= 12);
        expect(b.gegenueberstellung, personen >= 14);
        expect(b.rollenAmTischSelbst, personen >= 14);
        expect(b.abschnittBKurz, personen <= 8);
      });

      test('Platzhalter je Besetzung', () {
        expect(b.text('{rolle:marek|der Caterer}'), personen >= 11 ? 'Marek' : 'der Caterer');
        expect(b.text('{wenn:joanna,marek|beide|nicht beide}'), personen >= 11 ? 'beide' : 'nicht beide');
        expect(b.text('{ab:13|Dankeskarte}'), personen >= 13 ? 'Dankeskarte' : '');
        expect(b.text('{detektiv:der Detektiv|die Detektivin}'), 'der Detektiv');
        expect(b.text('{detektiv:der Detektiv|die Detektivin}', detektivWeiblich: true), 'die Detektivin');
        final wissen = b.text(inhalt.gemeinsam.wasAlleWissen.first);
        expect(wissen.contains('Dankeskarte'), personen >= inhalt.fall.schwellen.dankeskarteAb);
        expect(b.text(inhalt.gemeinsam.wasAlleWissen[2]), contains(personen >= 17 ? 'Azra ruft' : 'Ein Gast ruft'));
      });
    });
  }

  test('ZR 13.1: allein spielen Sibel (13), Hana (15), Azra (17), Aylin (19)', () {
    expect({for (var p = 6; p <= 20; p++) if (bei(p).solo != null) p: bei(p).solo!.id},
        {13: 'sibel', 15: 'hana', 17: 'azra', 19: 'aylin'});
  });

  test('Standardrunde 10 Personen: Streifen für Marek und Zeynep', () {
    expect([for (final s in bei(10).streifen) s.zeuge], ['marek', 'zeynep']);
    expect(inhalt.fall.personenVorgabe, 10);
  });
}
