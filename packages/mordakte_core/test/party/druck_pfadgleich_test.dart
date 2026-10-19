// F-14, E-008, E-036: Die offenen Druckteile verraten den Pfad nicht. Wer das
// Spielleitungsheft, den Detektivbogen, die Stimmkarten oder ein Kernrollen-Heft
// in der Hand hält, sieht in allen vier Pfaden dasselbe – bis auf die neutralen
// Codes und die Reihenfolge der Optionen, die am Fall-Code hängt.
import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/party_druck.dart';
import 'package:test/test.dart';

import 'kanon_hilfe.dart';

/// Das Spielleitungsheft ohne Codes: Bausteine und Schwellen.
Object _heft(Spielleitungsheft h) => [
      h.intro,
      h.rundenStart,
      h.resuemeeGruppe,
      h.resuemeeRest,
      h.resuemeeLage,
      h.anklage,
      [for (final a in h.auszaehlung) [for (final s in a.stufen) s.abSumme]],
      // Die Werte der Codetabelle als Menge: Welche Rolle −1 hat, steht nur auf den Karten.
      [for (final a in h.auszaehlung) (a.werte.values.toList()..sort())],
    ];

/// Der Detektivbogen ohne Codes: je Entscheidung Frage und die Menge der Optionstexte.
Object _bogen(List<BogenEntscheidung> b) => [
      for (final e in b) [e.id, e.frage, {for (final o in e.optionen) o.text}],
    ];

/// Die offenen Stimmkarten ohne Codes.
Object _stimmen(List<Stimmkarte> k) => [for (final s in k) [s.rolle, s.runde, s.a, s.text, s.wert]];

/// Das Rollenheft einer Kernrolle: Es zeigt Wer, Besetzung, Tischgespräche mit Stichpunkten, wer sie
/// anspricht und den Spickzettel ihrer Befragungen (Ziel und Wissen stehen in der Fassung).
Object _kernheft(Texte t, Dossier d) => [
      d.wer,
      d.besetzung,
      for (final r in d.gespraeche.keys.toList()..sort())
        for (final (g, partner) in d.gespraeche[r]!) [g.id, g.thema, g.ziel, g.text, g.stichpunkte, partner],
      for (final r in d.alsPartner.keys.toList()..sort())
        for (final (g, sprecher) in d.alsPartner[r]!) [g.id, sprecher],
      for (final r in [1, 2, 3])
        if (d.befragungen[r] case final b?) [b.id, b.thema, b.fragen, befragungsZettel(t, b).stichpunkte, befragungsZettel(t, b).behaupten],
    ];

/// Die Befragungen des Detektivs je Runde (Spielleitungsheft und Detektivbogen).
Object _befragungen(Map<int, BefragungsRunde> b) => [
      for (final r in b.keys.toList()..sort()) [b[r]!.pflicht, b[r]!.frei, b[r]!.freiWahlen],
    ];

void main() {
  late Texte texte;
  setUpAll(() => texte = Texte(kanon, Textsammlung.lade((p) => leseJson('$repoWurzel/content/party/schlosskeller/$p'))));

  for (final n in [4, 7, 12, 20]) {
    test('Bei $n Rollen sind Spielleitungsheft, Detektivbogen, Stimmkarten und Kernrollen-Hefte in allen Pfaden gleich', () {
      final saetze = {
        for (final p in kanon.pfade) p: DruckSatz.aus(kanon, texte, FallCode.fuerPfad(p, kanon.pfade), rollen: n, detektiv: 'w'),
      };
      final ref = saetze[kanon.pfade.first]!;
      for (final MapEntry(key: p, value: s) in saetze.entries) {
        expect(_heft(s.spielleitung), _heft(ref.spielleitung), reason: '$n/$p: Spielleitungsheft');
        expect(_bogen(s.detektivbogen), _bogen(ref.detektivbogen), reason: '$n/$p: Detektivbogen');
        expect(_stimmen(s.stimmkarten), _stimmen(ref.stimmkarten), reason: '$n/$p: Stimmkarten');
        expect(s.besetzt, ref.besetzt, reason: '$n/$p: Besetzung');
        expect(_befragungen(s.befragungen), _befragungen(ref.befragungen), reason: '$n/$p: Befragungen');
        expect(s.befragungen, hasLength(3), reason: 'Modell befragung: drei Runden mit Befragungen');
        for (final k in kanon.kernverdaechtige) {
          expect(_kernheft(texte, s.rollenhefte[k]!), _kernheft(texte, ref.rollenhefte[k]!), reason: '$n/$p: Rollenheft $k');
        }
        // Fassungen: gleiche Rollen in gleicher Reihenfolge, je drei B-Streifen.
        expect([for (final f in s.fassungen) [f.rolle, f.streifen.keys.toList()]], [for (final f in ref.fassungen) [f.rolle, f.streifen.keys.toList()]]);
      }
    });
  }

  test('Rot-Probe: offene Karten der Kernrollen mit −1 beim Täter (vor E-036) wären aufgefallen', () {
    final a = DruckSatz.aus(kanon, texte, FallCode.fuerPfad('ahmet', kanon.pfade), rollen: 7, detektiv: 'w');
    final b = DruckSatz.aus(kanon, texte, FallCode.fuerPfad('fatma', kanon.pfade), rollen: 7, detektiv: 'w');
    // Vor E-036 hatte jede Kernrolle offene Karten, und die Karte B der Täterrolle zählte −1.
    List<Stimmkarte> alt(DruckSatz s, String pfad) => [
          ...s.stimmkarten,
          for (final r in [1, 2, 3])
            for (final rolle in kanon.kernverdaechtige) ...[
              Stimmkarte(rolle, r, true, 'A', 1, ''),
              Stimmkarte(rolle, r, false, 'B', rolle == pfad ? -1 : 0, ''),
            ],
        ];
    expect(_stimmen(a.stimmkarten), _stimmen(b.stimmkarten));
    expect(_stimmen(alt(a, 'ahmet')), isNot(_stimmen(alt(b, 'fatma'))));
    // Seit E-039 haben die Kernrollen gar keine offenen Karten: Die Spielleitung kennt keinen ihrer Codes.
    expect(a.stimmkarten.where((k) => kanon.kernverdaechtige.contains(k.rolle)), isEmpty);
    // Ebenso die B-Streifen-Werte der Fassungen: Sie sind pfadabhängig und stehen deshalb nur versiegelt.
    expect([for (final f in a.fassungen) f.streifenWert], isNot([for (final f in b.fassungen) f.streifenWert]));
  });
}
