// Befunde der Runde 3 an den Rollentexten (content/kammerspiel/schlosskeller/rollen/): Regeln, die der Druck
// nach der Behebung einhalten muss, geprüft am aufgelösten Text jeder Besetzung von 6 bis 20 Personen.
// - P1R3-01: Ein Flüster-Auftrag eines Tandems („Sprich leise mit …“) hat eine Fassung für offene Karten.
// - P1R3-02: Ein Runde-3-Auftrag, der einen Auslöser „vor allen“ treffen soll, sagt das; die Tarnzeile der
//   Zeugen gilt in Runde 3 im kleinen Kreis weiter.
// - P1R3-03: Kein Arbeitsvermerk der Bibel („Dazu im Heft“) im Druck; ein Tipp steht nicht als Rede da.
// - P2R3-02: Der Domino-Hinweis („Und noch etwas“) ist neu, nicht schon Stufe-1-Wissen.
// - P3R3-B1: Der Beleg-Streit um die Miete liegt am Jackenständer, nicht beim Einlass.
// - P3R3-B2: Durch den Ost-Saal führt kein Weg (er hat keinen zweiten Ausgang).
// - P4-03: Ein Auslöser nennt keinen Zeugenstreifen einer Rolle, die heute spielt.
// - P4-04: Can schickt niemanden zu einer Person, die heute fehlt.
import 'dart:convert';

import 'package:mordakte_core/kammer_io.dart';
import 'package:mordakte_core/src/party/druck/kammer/kontext.dart';
import 'package:test/test.dart';

import '../kanon_hilfe.dart' show repoWurzel;
import 'kammer_druck_hilfe.dart';

/// Alle Zeichenketten eines JSON-Werts.
Iterable<String> _texte(Object? v) sync* {
  if (v is String) yield v;
  if (v is List) {
    for (final x in v) {
      yield* _texte(x);
    }
  }
  if (v is Map) {
    for (final x in v.values) {
      yield* _texte(x);
    }
  }
}

/// Die Rollendateien roh (Dateiname → JSON).
Map<String, Object?> get _rollenDateien => {
      for (final e in leseKammerDateien(repoWurzel).entries)
        if (e.key.startsWith('rollen/')) e.key: jsonDecode(e.value),
    };

/// Sätze eines Klartexts (an . ! ? getrennt).
Iterable<String> _saetze(String s) => s.split(RegExp(r'(?<=[.!?])\s+'));

/// Die Fassungen eines Textes mit fetten Etiketten („**Karte offen:** …“ je Zeile): Etikett → Text. Ohne
/// Etikett steht der ganze Text unter ''.
Map<String, String> _fassungen(String roh) {
  final aus = <String, String>{};
  for (final zeile in roh.split('\n')) {
    final m = RegExp(r'^\*\*([^*]+):\*\*\s*(.*)$').firstMatch(zeile);
    if (m == null) {
      aus[''] = '${aus[''] ?? ''}$zeile';
    } else {
      aus[m.group(1)!] = m.group(2)!;
    }
  }
  return aus;
}

final _personen = [for (var p = 6; p <= 20; p++) p];

void main() {
  final kontexte = {for (final p in _personen) p: kammerKontext(p)};

  test('P1R3-03: kein Arbeitsvermerk „Dazu im Heft“, ein Tipp steht nicht in Anführungszeichen', () {
    for (final e in _rollenDateien.entries) {
      for (final t in _texte(e.value)) {
        expect(t, isNot(contains('Dazu im Heft')), reason: e.key);
        for (final zeile in t.split('\n').where((z) => z.startsWith('**Tipp:**'))) {
          expect(zeile, isNot(contains('„')), reason: '${e.key}: $zeile');
        }
      }
    }
    final marek = kammerInhalt.rolle('marek').gespraechsauftraege.singleWhere((a) => a.runde == 2 && a.nr == 1);
    expect(marek.frage, contains('**Tipp:**'));
  });

  test('P1R3-01: Flüster-Aufträge der Tandems haben eine Fassung für offene und für zugedeckte Karten', () {
    var gefunden = 0;
    for (final r in kammerInhalt.rollen) {
      for (final a in r.gespraechsauftraege.where((a) => a.frage.contains('Sprich leise'))) {
        gefunden++;
        final f = _fassungen(a.frage);
        final offen = f.keys.where((k) => k.endsWith('Karte offen'));
        final zu = f.keys.where((k) => k.endsWith('Karte zu'));
        expect(offen, hasLength(1), reason: '${r.id} Runde ${a.runde} Ziel ${a.nr}: ${a.frage}');
        expect(zu, hasLength(1), reason: '${r.id} Runde ${a.runde} Ziel ${a.nr}: ${a.frage}');
        // Geflüstert wird nur, solange die Karten zu sind; offen fragt man vor allen.
        expect(f[offen.single], isNot(contains('leise')), reason: '${r.id}: ${f[offen.single]}');
        expect(f[zu.single], contains('Sprich leise'), reason: '${r.id}: ${f[zu.single]}');
      }
    }
    expect(gefunden, greaterThanOrEqualTo(2), reason: 'Serkan an Hana, Damir an Sibel');
  });

  group('P1R3-02: Runde-3-Aufträge an Auslöser „vor allen“', () {
    // Zeugen, deren Karte fällt, sobald man sie in Runde 3 vor allen fragt (Tim, Marek, Zeynep).
    final zeugen = {
      for (final r in kammerInhalt.rollen)
        if (r.stufe2.ausloeser.any((a) => a.contains('in Runde 3 jemand vor allen fragt'))) r.id,
    };
    // „vor allen“ oder „Sag allen“ (Zeynep an Tim) sagen dasselbe: Die Antwort gehört vor den ganzen Tisch.
    final vorAllen = RegExp(r'vor allen|Sag allen');

    test('die Zeugen mit diesem Auslöser', () {
      expect(zeugen, {'tim', 'marek', 'zeynep'});
    });

    test('jede Frage und jedes Ausweichziel an diese Zeugen sagt „vor allen“', () {
      final namen = {for (final p in kammerInhalt.fall.plaetze) p.name: p.id};
      var n = 0;
      for (final r in kammerInhalt.rollen) {
        for (final a in r.gespraechsauftraege.where((a) => a.runde == 3)) {
          if (zeugen.contains(a.ziel)) {
            n++;
            expect(a.frage, matches(vorAllen), reason: '${r.id} Ziel ${a.nr} an ${a.ziel}: ${a.frage}');
          }
          final aus = a.ausweich == null ? null : RegExp(r'^([^\s:*„“]+): ').firstMatch(a.ausweich!);
          if (aus != null && zeugen.contains(namen[aus.group(1)])) {
            n++;
            expect(a.ausweich, matches(vorAllen), reason: '${r.id} Ausweichziel ${a.nr}: ${a.ausweich}');
          }
        }
      }
      expect(n, greaterThanOrEqualTo(11));
    });

    test('Lejla und Joanna an Olli, solange er noch in Stufe 1 ist: vor allen (Ollis Auslöser a und b)', () {
      final olli = kammerInhalt.rolle('olli');
      final k = kontexte[20]!;
      final fragende = {
        for (final a in olli.stufe2.ausloeser)
          if (RegExp(r'^Sobald (\w+) vor allen').firstMatch(k.text(a)) case final m?) m.group(1)!,
      };
      expect(fragende, {'Joanna', 'Lejla'});
      for (final name in fragende) {
        final r = kammerInhalt.rollen.singleWhere((r) => kammerInhalt.platzVon(r.id).name == name);
        for (final a in r.gespraechsauftraege.where((a) => a.ziel == 'olli')) {
          final f = _fassungen(a.frage);
          final vorher = f.keys.where((e) => e.contains('Stufe 1'));
          for (final t in vorher.isEmpty ? [f['']!] : [for (final e in vorher) f[e]!]) {
            expect(t, contains('vor allen'), reason: '$name Runde ${a.runde}: $t');
          }
        }
      }
    });

    test('die Tarnzeile der Zeugen gilt in Runde 3 im kleinen Kreis weiter', () {
      for (final id in zeugen) {
        final tarn = kammerInhalt.rolle(id).stufe1.ausweichsaetze.where((s) => s.frage.contains(RegExp(r'\(.*Runde.*\)')));
        expect(tarn, hasLength(1), reason: id);
        expect(tarn.single.frage, contains('(außer in Runde 3 vor allen)'), reason: id);
      }
    });
  });

  test('P2R3-02: der Domino-Hinweis steht nicht schon in Stufe 1', () {
    for (final p in _personen) {
      final k = kontexte[p]!;
      for (final pl in k.besetzung.besetzt) {
        final r = k.rolle(pl);
        // Wer nichts zu verbergen hat (Tugba, ZR 8.6), sagt alles jedem; ihr Domino ist die Bitte an die Partnerin.
        if (r.stufe1.regie?.contains('nichts zu verbergen') ?? false) continue;
        final domino = k.klartext(r.geheimniskarte.undNochEtwas);
        for (final s in [...r.stufe1.sagstDuJedem, ...r.stufe1.kernsaetze]) {
          final kern = k.klartext(s).replaceAll(RegExp(r'[„“‚‘]'), '').replaceAll(RegExp(r'[.!?]+$'), '').trim();
          if (kern.isEmpty) continue;
          expect(domino, isNot(contains(kern)), reason: '$p Personen, ${pl.name}: „$kern“');
        }
      }
    }
  });

  test('P3R3-B1: der Beleg für die Miete war am Jackenständer, nicht beim Einlass', () {
    for (final e in _rollenDateien.entries) {
      for (final t in _texte(e.value)) {
        for (final s in _saetze(t)) {
          if (s.contains('Beleg')) expect(s, isNot(contains('Einlass')), reason: '${e.key}: $s');
        }
      }
    }
  });

  test('P3R3-B2: kein Weg führt durch den Ost-Saal', () {
    for (final e in _rollenDateien.entries) {
      for (final t in _texte(e.value)) {
        expect(t, isNot(contains('durch den Ost-Saal')), reason: e.key);
      }
    }
    final olli = kammerInhalt.rolle('olli').gespraechsauftraege.singleWhere((a) => a.runde == 1 && a.nr == 2);
    expect(olli.ausweich, allOf(contains('Turm-Toilette'), contains('Kaminsaal'), contains('Turmgang')));
  });

  test('P4-03: kein Auslöser nennt den Zeugenstreifen einer Rolle, die heute spielt', () {
    for (final p in _personen) {
      final k = kontexte[p]!;
      final zeugen = [for (final pl in k.besetzung.besetzt) if (pl.platz >= 5 && pl.platz <= 10) pl.name];
      for (final pl in k.besetzung.besetzt) {
        for (final a in k.rolle(pl).stufe2.ausloeser) {
          for (final s in _saetze(k.klartext(a)).where((s) => s.contains('Zeugenstreifen'))) {
            for (final z in zeugen) {
              expect(s, isNot(contains(z)), reason: '$p Personen, ${pl.name}: $s');
            }
          }
        }
      }
    }
  });

  test('P4-04: Can schickt niemanden zu Zeynep oder zu denen im Durchgang, wenn sie heute fehlen', () {
    for (final p in _personen) {
      final KammerKontext k = kontexte[p]!;
      final can = kammerInhalt.rolle('can');
      final texte = [
        for (final s in can.stufe1.ausweichsaetze) k.klartext(s.antwort),
        for (final s in can.fassung!.wennEsEngWird) k.klartext(s),
      ].join('\n');
      final zeynep = k.besetzung.istBesetzt('zeynep'), tim = k.besetzung.istBesetzt('tim');
      expect(texte.contains(RegExp(r'Frag sie\b')), zeynep, reason: '$p Personen');
      expect(texte.contains('Frag die, die im Durchgang waren'), tim, reason: '$p Personen');
      if (!zeynep) expect(texte, contains('schau dir den Steinbogen an'), reason: '$p Personen');
      if (!tim) expect(texte, contains('schau dir den Durchgang an'), reason: '$p Personen');
    }
  });
}
