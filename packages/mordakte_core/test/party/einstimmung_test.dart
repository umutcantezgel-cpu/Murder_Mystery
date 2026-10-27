// A-063, SPEZIFIKATION §1: Einstimmung (Vorgeschichte und Vorstellung). Nur Akten
// mit setting.vorgeschichte haben eine; ohne bleibt alles wie bisher (Katalog,
// Lückenliste, Setting-Schema). Die Schritte hängen nur an Rollenzahl und
// Detektiv: Blöcke, Start, besetzte Figuren in Besetzungsreihenfolge, Sammelblock
// für Unbesetzte, Detektiv. EinstimmungLauf ist die gemeinsame Zustandsmaschine.
import 'package:mordakte_core/mordakte_core.dart';
import 'package:test/test.dart';

import 'einstimmung_hilfe.dart';
import 'kanon_hilfe.dart';

const _akten = ['schlosskeller', 'gewoelbe', 'ravensmoor', 'nachtexpress', 'blue_palm'];

void main() {
  group('Kanon und Einstimmung.aus', () {
    test('Keine Akte hat heute eine Einstimmung; der Katalog bleibt ohne vorgeschichte.* und vorstellung.*', () {
      for (final a in _akten) {
        final k = ladeKanon(a);
        expect([k.vorgeschichte, k.vorstellung, Einstimmung.aus(k)], [null, false, null], reason: a);
        expect(Erzaehler(k).katalog().where((x) => x.startsWith('vorgeschichte.') || x.startsWith('vorstellung.')), isEmpty, reason: a);
      }
    });

    test('Setting mit Vorgeschichte: Teile und Vorstellung sind im Kanon lesbar', () {
      final e = Einstimmung.aus(einstimmungKanon)!;
      expect(einstimmungKanon.vorgeschichte, fixtureTeile);
      expect(einstimmungKanon.vorstellung, isTrue);
      expect([e.teile, e.vorstellung], [fixtureTeile, true]);
      final ohne = kanonMit(setting: settingMitEinstimmung(vorstellung: false));
      expect(Einstimmung.aus(ohne)!.vorstellung, isFalse);
    });

    test('Strenges und gelockertes Setting-Schema kennen vorgeschichte (6 bis 8 Kennungen) und vorstellung', () {
      for (final ordner in ['schema', 'schema-akte']) {
        final schema = SchemaPruefer(leseJson('$repoWurzel/content/party/$ordner/setting.schema.json'));
        expect(schema.pruefe(settingMitEinstimmung()), isEmpty, reason: ordner);
        expect(schema.pruefe(settingMitEinstimmung(teile: fixtureTeile.take(5).toList())), isNotEmpty, reason: '$ordner: 5 Teile');
        expect(schema.pruefe(settingMitEinstimmung(teile: [...fixtureTeile, 'a', 'b'])), isNotEmpty, reason: '$ordner: 9 Teile');
        expect(schema.pruefe(settingMitEinstimmung(teile: ['schloss', 'schloss', 'a', 'b', 'c', 'd'])), isNotEmpty, reason: '$ordner: doppelt');
        expect(schema.pruefe({...settingMitEinstimmung(), 'vorstellung': 'ja'}), isNotEmpty, reason: '$ordner: vorstellung');
      }
    });
  });

  group('Schritte', () {
    final e = Einstimmung.aus(einstimmungKanon)!;
    final reihe = Besetzung(kanon).reihenfolge;

    test('je Rollenzahl: Blöcke, Start, besetzte Figuren in Reihenfolge, Sammelblock nur mit Unbesetzten, Detektiv', () {
      for (var n = 4; n <= 20; n++) {
        for (final g in ['m', 'w']) {
          final s = e.schritte(rollen: n, detektiv: g);
          final vor = s.where((x) => x.teil == EinstimmungTeil.vorgeschichte).toList();
          final vorst = s.where((x) => x.teil == EinstimmungTeil.vorstellung).toList();
          expect([for (final x in vor) x.kennung], [for (final t in fixtureTeile) 'vorgeschichte.$t']);
          expect([for (final x in vor) (x.nr, x.von, x.figur, x.titel)], [for (final (i, t) in fixtureTeile.indexed) (i + 1, 7, null, 'ui.einstimmung.titel.$t')]);
          expect([for (final x in vorst) x.kennung], [
            'vorstellung.start',
            for (final f in reihe.take(n)) 'vorstellung.$f',
            if (n < 20) 'vorstellung.npc',
            'vorstellung.detektiv.$g',
          ], reason: '$n $g');
          expect([for (final x in vorst) x.figur], [null, ...reihe.take(n), if (n < 20) null, Besetzung.detektiv]);
          expect([for (final x in vorst) x.nr], [for (var i = 1; i <= vorst.length; i++) i]);
          expect(vorst.every((x) => x.von == vorst.length && x.titel == null), isTrue);
          expect(s.take(vor.length), vor, reason: 'Die Vorgeschichte kommt zuerst');
        }
      }
    });

    test('ohne Vorstellung nur die Vorgeschichte; ungültige Eingaben werfen', () {
      final k = kanonMit(setting: settingMitEinstimmung(vorstellung: false));
      expect([for (final x in Einstimmung.aus(k)!.schritte(rollen: 8, detektiv: 'w')) x.kennung], [for (final t in fixtureTeile) 'vorgeschichte.$t']);
      expect(() => e.schritte(rollen: 3, detektiv: 'm'), throwsRangeError);
      expect(() => e.schritte(rollen: 21, detektiv: 'm'), throwsRangeError);
      expect(() => e.schritte(rollen: 8, detektiv: 'x'), throwsArgumentError);
    });

    test('Katalog: alle Blöcke, Start, jede Figur, Sammelblock, beide Detektiv-Fassungen; der Erzähler hängt ihn an', () {
      expect(e.katalog(), [
        for (final t in fixtureTeile) 'vorgeschichte.$t',
        'vorstellung.start',
        for (final f in reihe) 'vorstellung.$f',
        'vorstellung.npc',
        'vorstellung.detektiv.m',
        'vorstellung.detektiv.w',
      ]);
      expect(e.titel(), [for (final t in fixtureTeile) 'ui.einstimmung.titel.$t']);
      final alt = Erzaehler(kanon).katalog();
      expect(Erzaehler(einstimmungKanon).katalog(), [...alt, ...e.katalog()]);
      // Jede Kennung jedes Abends steht im Katalog.
      final katalog = e.katalog().toSet();
      for (var n = 4; n <= 20; n++) {
        expect(e.schritte(rollen: n, detektiv: 'w').every((x) => katalog.contains(x.kennung)), isTrue);
      }
    });

    test('Textsammlung: Die Texte der Einstimmung gehören zum Katalog; ohne sie meldet die Lückenliste genau sie', () {
      final t = einstimmungTexteMit();
      expect(textVerweise(einstimmungKanon, t.sammlung), isEmpty);
      final ohne = textLuecken(einstimmungKanon, Textsammlung.lade((p) => leseJson('$repoWurzel/content/party/schlosskeller/$p')));
      expect(ohne, [for (final k in e.katalog()) 'Erzähler-Baustein $k fehlt']);
      expect(textLuecken(einstimmungKanon, t.sammlung), isEmpty);
      // Ohne Einstimmung im Setting gehören die Texte nicht zum Katalog.
      expect(textVerweise(kanon, t.sammlung).where((x) => x.contains('gehört nicht zum Erzähler-Katalog')), hasLength(e.katalog().length));
    });

    test('toJson und Gleichheit', () {
      final s = e.schritte(rollen: 4, detektiv: 'm');
      expect(s[7].toJson(), {'teil': 'vorstellung', 'kennung': 'vorstellung.start', 'nr': 1, 'von': 7});
      expect(s[8].toJson(), {'teil': 'vorstellung', 'kennung': 'vorstellung.ahmet', 'figur': 'ahmet', 'nr': 2, 'von': 7});
      expect(e.schritte(rollen: 4, detektiv: 'm'), s);
    });
  });

  group('EinstimmungLauf', () {
    final schritte = Einstimmung.aus(einstimmungKanon)!.schritte(rollen: 5, detektiv: 'w');

    test('weiter nur vom laufenden Schritt; ein doppelter Tipp überspringt nichts', () {
      final l = EinstimmungLauf(schritte);
      expect([l.schritt, l.fertig, l.aktuell], [0, false, schritte.first]);
      expect(l.weiter(1), isFalse);
      expect(l.weiter(0), isTrue);
      expect(l.weiter(0), isFalse, reason: 'veraltet');
      expect(l.schritt, 1);
      for (var i = 1; i < schritte.length; i++) {
        expect(l.weiter(i), isTrue);
      }
      expect([l.fertig, l.aktuell, l.schritt], [true, null, schritte.length]);
      expect(l.weiter(schritte.length), isFalse);
    });

    test('ueberspringen: Rest der Vorgeschichte, dann Rest der Vorstellung', () {
      final l = EinstimmungLauf(schritte);
      l.weiter(0);
      l.weiter(1);
      expect(l.ueberspringen(), isTrue);
      expect([l.schritt, l.aktuell!.kennung], [7, 'vorstellung.start']);
      l.weiter(7);
      expect(l.ueberspringen(), isTrue);
      expect(l.fertig, isTrue);
      expect(l.ueberspringen(), isFalse);
    });

    test('Start mitten im Lauf (Wiederaufnahme) und Grenzen', () {
      expect(EinstimmungLauf(schritte, schritt: 8).aktuell!.kennung, 'vorstellung.ahmet');
      expect(EinstimmungLauf(schritte, schritt: 99).fertig, isTrue);
      expect(EinstimmungLauf(schritte, schritt: -3).schritt, 0);
      expect(EinstimmungLauf(const []).fertig, isTrue);
    });
  });

  test('Zeit: ein Abend mit Einstimmung ist bei derselben Rollenzahl länger, ohne bleibt er gleich', () {
    for (final f in Abendfassung.values) {
      for (final m in f.minutenOptionen) {
        expect(abendMinutenGenau(f, m, einstimmungRollen: null), abendMinutenGenau(f, m));
        expect(abendMinutenGenau(f, m, einstimmungRollen: 12), greaterThan(abendMinutenGenau(f, m)));
      }
    }
  });
}
