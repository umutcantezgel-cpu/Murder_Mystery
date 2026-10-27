// Kern-Hilfen der Einfluss-Schicht für Raum und App (Finale §3.11, §3.12, §3.14): Reaktionsblasen der Bots
// (höchstens drei je Folgen, nur Bot-Rollen, aus dem Salz), die private Nachricht „ertappt“ an die gefasste
// Rolle, erlaubte Züge, Live-Stand der Sterne, Wortlaut der Auspack-Fakten und der Zug aus der Ansicht.
@TestOn('vm')
library;

import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/runden.dart';
import 'package:test/test.dart';

import '../party/kanon_hilfe.dart';
import 'einfluss_hilfe.dart';
import 'einfluss_lauf.dart';

EinflussRegeln get _r => einflussRegeln;

/// Folgen einer Runde mit Gerüchten, Geständnis und Ablenkern für die Blasen-Proben.
EinflussFolgen _folgen(List<String> besetzt, List<EinflussZug> zuege, {int runde = 1}) {
  final s = EinflussStand(_r, besetzt: besetzt);
  for (var r = 1; r < runde; r++) {
    s.auswerten(r);
  }
  for (final z in zuege) {
    s.setze(runde, z);
  }
  return s.auswerten(runde);
}

void main() {
  final besetzt = Besetzung(kanon).besetzt(12);

  group('Reaktionsblasen der Bots', () {
    test('Anlässe aus Öffentlichem, je Figur eine, nur Bots, höchstens drei, gleiche Eingaben gleiche Blasen', () {
      // leyla und johanna (Freund ahmet) sehen ahmet auspacken; can und olli werden beredet; baran lenkt ab.
      final f = _folgen(besetzt, [
        const EinflussZug('ahmet', ZugArt.auspacken),
        const EinflussZug('fatma', ZugArt.zeigen, ziel: 'can'),
        const EinflussZug('emine', ZugArt.zeigen, ziel: 'olli'),
        const EinflussZug('baran', ZugArt.ablenken),
      ]);
      expect((_r.bots['leyla']!.freund, _r.bots['johanna']!.freund), ('ahmet', 'ahmet'));
      final alle = botBlasen(_r, f, salz: 's', istBot: (_) => true, ertappt: ['tim']);
      expect(alle.length, lessThanOrEqualTo(botBlasenHoechstens));
      final ohneGrenze = {
        const BotBlase('olli', 'geruecht'), const BotBlase('can', 'geruecht'), const BotBlase('leyla', 'freund_gestanden'),
        const BotBlase('johanna', 'freund_gestanden'), const BotBlase('tim', 'ertappt'), const BotBlase('baran', 'ablenken'),
      };
      expect(ohneGrenze, containsAll(alle));
      expect([for (final b in alle) besetzt.indexOf(b.figur)], orderedEquals([for (final b in alle) besetzt.indexOf(b.figur)]..sort()));
      expect(botBlasen(_r, f, salz: 's', istBot: (_) => true, ertappt: ['tim']), alle, reason: 'deterministisch');
      final salze = {for (var i = 0; i < 40; i++) botBlasen(_r, f, salz: 'salz$i', istBot: (_) => true, ertappt: ['tim']).join()};
      expect(salze.length, greaterThan(1), reason: 'das Salz wählt aus');
      // Nur Bots: Menschen bekommen keine Blase.
      final nurBots = botBlasen(_r, f, salz: 's', istBot: (r) => r == 'olli' || r == 'baran');
      expect(nurBots, [const BotBlase('olli', 'geruecht'), const BotBlase('baran', 'ablenken')]);
      expect(nurBots.first.schluessel, 'einfluss.bot.olli.geruecht');
      // Ertappt hat Vorrang vor dem Gerücht.
      expect(botBlasen(_r, f, salz: 's', istBot: (r) => r == 'can', ertappt: ['can']), [const BotBlase('can', 'ertappt')]);
      // Ohne Anlass keine Blase.
      final still = _folgen(besetzt, [for (final b in besetzt) EinflussZug(b, ZugArt.helfen)]);
      expect(botBlasen(_r, still, salz: 's', istBot: (_) => true), isEmpty);
    });

    test('jeder Schlüssel steht im Katalog', () {
      final katalog = einflussKatalog(_r).toSet();
      for (final f in _r.figuren) {
        for (final a in botAnlaesse) {
          expect(katalog, contains(BotBlase(f, a).schluessel));
        }
      }
    });
  });

  group('Privat und Ertappt', () {
    test('ertappt geht privat genau an die gefasste Rolle, in der Runde der Suche; Blasen der nächsten Folgen', () {
      var gefunden = 0;
      for (var i = 0; i < 60 && gefunden < 3; i++) {
        final p = spieleEinflussAbend(
          pfad: kanon.pfade[i % 4], rollen: 8 + i % 12, folge: gezogeneFolge(einflussErmittlung, Rng(i)),
          quelle: const FesterWuerfel.erfolg(), salz: 'ertappt$i', profil: Tischprofil.stoeren,
        );
        final e = p.einfluss!;
        final faelle = [
          for (final f in e.funde.entries)
            if (f.value.ertappt case final rolle?) (rolle: rolle, runde: einflussErmittlung.entscheidung(f.key).runde),
        ];
        for (final rolle in e.stand.besetzt) {
          final privat = [for (final n in e.privatFuer(rolle)) if (n.nachricht.art == PrivatArt.ertappt) n.runde];
          expect(privat, [for (final f in faelle) if (f.rolle == rolle) f.runde], reason: '$rolle in Abend $i');
          for (final n in e.privatFuer(rolle).where((n) => n.nachricht.art == PrivatArt.ertappt)) {
            expect(n.nachricht.schluessel, 'einfluss.privat.ertappt');
          }
        }
        for (var runde = 1; runde <= 3; runde++) {
          expect(e.ertapptIn(runde), [for (final f in faelle) if (f.runde == runde) f.rolle]);
          final blasen = e.blasen(runde, istBot: (_) => true);
          expect(blasen.length, lessThanOrEqualTo(botBlasenHoechstens));
          if (runde > 1 && e.ertapptIn(runde - 1).isNotEmpty && blasen.length < botBlasenHoechstens) {
            // Wer ertappt wurde, bekommt die Blase, sofern die Grenze nicht greift.
            expect(blasen.where((b) => b.anlass == 'ertappt').map((b) => b.figur), everyElement(isIn(e.ertapptIn(runde - 1))));
          }
        }
        gefunden += faelle.isEmpty ? 0 : 1;
      }
      expect(gefunden, greaterThan(0), reason: 'kein Ertappt in 60 Abenden');
    });
  });

  group('Erlaubte Züge, Sterne, Wortlaut', () {
    test('erlaubteArten und erlaubteZiele wie pruefeZug', () {
      final s = EinflussStand(_r, besetzt: besetzt);
      expect(s.erlaubteArten('ahmet'), ZugArt.waehlbar);
      expect(s.erlaubteZiele('ahmet', ZugArt.zeigen), [for (final b in besetzt) if (b != 'ahmet') b]);
      expect(s.erlaubteZiele('ahmet', ZugArt.decken), besetzt);
      expect(s.erlaubteZiele('ahmet', ZugArt.helfen), isEmpty);
      s.setze(1, const EinflussZug('ahmet', ZugArt.auspacken));
      s.auswerten(1);
      expect(s.erlaubteArten('ahmet'), isNot(contains(ZugArt.auspacken)), reason: 'einmal am Abend');
      expect(() => s.pruefeZug(2, const EinflussZug('ahmet', ZugArt.auspacken)), throwsArgumentError);
      expect(() => s.erlaubteArten('tugba'), throwsArgumentError, reason: 'nicht besetzt');
    });

    test('Live-Stand der zwei Sterne je Rolle: Kennung, Nummer, Schlüssel und Stand', () {
      final p = spieleEinflussAbend(
        pfad: 'can', rollen: 6, folge: gezogeneFolge(einflussErmittlung, Rng(3)), quelle: const SalzWuerfel('sterne'), salz: 'sterne',
      );
      final e = p.einfluss!;
      for (final rolle in e.stand.besetzt) {
        final staende = e.zielStaende(rolle);
        expect([for (final z in staende) z.ziel.nr], [1, 2]);
        expect([for (final z in staende) z.stand], e.zielStand(rolle));
        expect(staende.first.ziel.schluessel, 'einfluss.ziel.$rolle.1');
        expect(staende.every((z) => z.stand != ZielStand.offen), isTrue, reason: 'nach der Anklage steht alles fest');
      }
    });

    test('Wortlaut der Auspack-Fakten ohne Fall', () {
      for (final q in _r.auspacken.values) {
        if (q.fakt case final f?) expect(faktWortlaut(einflussErmittlung, f), isNotEmpty, reason: f);
      }
      expect(() => faktWortlaut(einflussErmittlung, 'f_gibt_es_nicht'), throwsArgumentError);
    });
  });

  group('Zug aus der Ansicht', () {
    test('RundenZug.ansicht trägt Tischwert, Verwischt und Kennzeichen; EinflussFund liest seine Ansicht', () {
      const fund = EinflussFund(
        tisch: -1, randnotizen: ['b_joanna_foto'], ertappt: 'leyla', ertapptZiel: 'ahmet', verwischt: true, verzoegert: true,
        befragung: BefragungsLage.zoegert,
      );
      final wieder = EinflussFund.ausJson(fund.toJson());
      expect(wieder.toJson(), fund.toJson());
      expect(EinflussFund.ausJson(const {'tisch': 0, 'verwischt': false, 'verzoegert': false}).randnotizen, isEmpty);
      expect(() => EinflussFund.ausJson(const {'tisch': 'x'}), throwsFormatException);
      expect(() => EinflussFund.ausJson(const {'tisch': 0, 'befragung': 'schweigt'}), throwsFormatException);
      final z = RundenZug.ansicht(id: 'e1_1', option: 'e1_1_joanna', suche: true, phase: RundenZugPhase.fund, aktion: 3, tisch: -1, verwischt: true, einfluss: wieder);
      expect((z.tisch, z.verwischt, z.einfluss?.ertappt), (-1, true, 'leyla'));
      const ohne = RundenZug.ansicht(id: 'e1_1', phase: RundenZugPhase.aktion, aktion: 1);
      expect((ohne.tisch, ohne.verwischt, ohne.einfluss), (null, false, null));
    });
  });
}
