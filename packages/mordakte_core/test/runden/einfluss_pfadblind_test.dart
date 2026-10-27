// T-P · Pfadblind (Finale §0.4, §4): Gleiche Eingaben – Züge, Salz, Wahlfolge, Strategie, Anklage – ergeben
// in allen vier Pfaden dieselbe öffentliche Spur der Einfluss-Schicht bis zur Anklage: Folgen (ohne Privates),
// Abzeichen, Würfe, Minuten, Marken, Zug-Kennzeichen (Randnotizen, Ertappt, Verwischt, Verzögerung,
// Befragungslage), Leisten, Ertappte, Flüstern, Nachfragen und ihre Bausteine. Fakten, Funde, Restmenge und
// Hinweistexte zeigt die Kanon-Engine pfadgemäß wie ohne Schicht; sie gehören nicht zur Spur.
@TestOn('vm')
library;

import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/runden.dart';
import 'package:test/test.dart';

import '../party/kanon_hilfe.dart';
import 'einfluss_hilfe.dart';
import 'einfluss_lauf.dart';

WuerfelQuelle _strom(int i, String salz) => switch (i % 4) {
      0 => const FesterWuerfel.pech(),
      1 => const FesterWuerfel.erfolg(),
      2 => const FesterWuerfel.neutral(),
      _ => SalzWuerfel(salz),
    };

void _gleicheSpur({
  required int rollen,
  required List<String> folge,
  required WuerfelQuelle Function() quelle,
  required String salz,
  required Tischprofil profil,
  required Detektivweise Function() weise,
  required String anklage,
}) {
  List<String>? erste;
  for (final pfad in kanon.pfade) {
    final spur = oeffentlicheSpur(
      pfad: pfad, rollen: rollen, folge: folge, quelle: quelle(), salz: salz, profil: profil, weise: weise(), anklage: anklage,
    );
    if (erste == null) {
      erste = spur;
      expect(spur.length, greaterThan(20), reason: salz);
      continue;
    }
    expect(spur.length, erste.length, reason: '$salz: Spurlänge im Pfad $pfad');
    for (var i = 0; i < spur.length; i++) {
      if (spur[i] != erste[i]) fail('$salz: Pfad $pfad weicht in Schritt $i ab\n  ${kanon.pfade.first}: ${erste[i]}\n  $pfad: ${spur[i]}');
    }
  }
}

void main() {
  final folgen = Simulator(kanon).folgen().toList();
  final kern = kanon.kernverdaechtige;

  test('768 Wahlfolgen × Profil, n, Würfelstrom und Anklage reihum: gleiche Spur in allen 4 Pfaden', () {
    for (final (fi, folge) in folgen.indexed) {
      final salz = 'pfadblind:$fi';
      final profil = Tischprofil.values[fi % Tischprofil.values.length];
      _gleicheSpur(
        rollen: 4 + fi % 17,
        folge: folge,
        quelle: () => _strom(fi, salz),
        salz: salz,
        profil: profil,
        weise: () => Detektivweise.fest(fi.isEven ? Tischruf.umweg : Tischruf.nochmal, gruendlich: fi % 3 == 0),
        anklage: kern[fi % kern.length],
      );
    }
  }, timeout: const Timeout(Duration(minutes: 3)));

  test('Bot-Tische mit Salz-Würfeln und freier Strategie (300 Salze, n = 4–20)', () {
    for (var i = 0; i < 300; i++) {
      final salz = 'pfadblind-bots:$i';
      final r = Rng(Rng.hashString('pfadblind-wahl:$i'));
      _gleicheSpur(
        rollen: 4 + i % 17,
        folge: gezogeneFolge(einflussErmittlung, r),
        quelle: () => SalzWuerfel(salz),
        salz: salz,
        profil: Tischprofil.bots,
        weise: () => Detektivweise.strom(Rng(Rng.hashString('pfadblind-weise:$i'))),
        anklage: kern[r.nextInt(kern.length)],
      );
    }
  });

  test('Die Spur ist nicht leer: Folgen, Abzeichen, Kennzeichen und Flüstern kommen vor', () {
    final spur = oeffentlicheSpur(
      pfad: 'can', rollen: 12, folge: einflussErmittlung.bestesSpiel('olli'), quelle: const SalzWuerfel('probe'), salz: 'probe',
      weise: Detektivweise.fest(Tischruf.umweg),
    ).join('\n');
    for (final teil in ['"folgen"', '"abzeichen"', '"einfluss"', '"fluestern"', 'einfluss.folgen.start.3', '"wurf"']) {
      expect(spur, contains(teil));
    }
  });
}
