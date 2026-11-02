// Kammerspiel-Inhalt (content/kammerspiel/schlosskeller/, SCHEMA.md): Die echten
// Dateien laden ohne Fehler, die Struktur ist vollständig (18 Plätze, vier
// Fassungen, 19 Indizkarten, Felder des Lageplans, neun Meilensteine), und der
// Lader wirft bei fehlenden, unbekannten oder falschen Feldern mit Datei und Pfad.
// Ob noch OFFEN-Texte da sind, prüft hier niemand (das macht später ein
// Vollständigkeitstest); geprüft wird nur, dass jeder OFFEN-Text eine Bibel-Kennung nennt.
import 'dart:convert';

import 'package:mordakte_core/kammer_io.dart';
import 'package:test/test.dart';

import '../kanon_hilfe.dart';

KammerInhalt? _inhalt;
KammerInhalt get inhalt => _inhalt ??= ladeKammerInhalt(repoWurzel);

/// Frische, veränderbare Kopie aller Dateien (für Rot-Proben).
Map<String, Map<String, Object?>> kopie() => {
      for (final e in leseKammerDateien(repoWurzel).entries) e.key: jsonDecode(e.value) as Map<String, Object?>,
    };

Matcher wirft(List<String> teile) => throwsA(isA<FormatException>().having(
      (e) => e.message,
      'message',
      allOf([for (final t in teile) contains(t)]),
    ));

/// Alle Zeichenketten eines JSON-Werts.
Iterable<String> texteIn(Object? v) sync* {
  if (v is String) yield v;
  if (v is List) {
    for (final x in v) {
      yield* texteIn(x);
    }
  }
  if (v is Map) {
    for (final x in v.values) {
      yield* texteIn(x);
    }
  }
}

void main() {
  test('alle Inhaltsdateien laden ohne Fehler', () {
    expect(inhalt.rollen, hasLength(18));
    expect(kammerInhaltDateien, hasLength(17 + 18));
    expect(kammerInhaltDateien.toSet(), hasLength(kammerInhaltDateien.length));
  });

  group('fall.json', () {
    test('Kennung, Fall-Code, Täter, Personenbereich', () {
      final f = inhalt.fall;
      expect(f.kennung, 'schlosskeller');
      expect(f.fallCode, 'U4YRK');
      expect(f.taeter, 'olli');
      expect((f.personenMin, f.personenMax, f.personenVorgabe), (6, 20, 10));
      expect(f.ohneRolle, ['erzaehler', 'detektiv']);
      expect(f.untersuchungenJeRunde, 3);
      expect([for (final r in f.runden) r.name],
          ['Das Alibi-Geflecht', 'Die Indizien-Filterung', 'Die finale Gegenüberstellung']);
      expect(f.teile, ['00', '01', '02', '10', '11', '12', '20', '90']);
    });

    test('18 Plätze in Reihenfolge mit Figuren-ID und Namen aus dem Kanon', () {
      const erwartet = [
        ('ahmet', 'ahmet'), ('fatma', 'fatma'), ('olli', 'olli'), ('can', 'can'), ('lejla', 'leyla'),
        ('emine', 'emine'), ('tim', 'tim'), ('joanna', 'johanna'), ('marek', 'murat'), ('zeynep', 'zeynep'),
        ('sibel', 'selin'), ('damir', 'enes'), ('hana', 'meryem'), ('serkan', 'serkan'), ('azra', 'dilara'),
        ('wojtek', 'kaan'), ('aylin', 'aylin'), ('tugba', 'tugba'),
      ];
      final plaetze = inhalt.fall.plaetze;
      expect([for (final p in plaetze) (p.id, p.kanonFigur)], erwartet);
      for (final p in plaetze) {
        expect(kanon.figur(p.kanonFigur)?['name'], p.name, reason: p.id);
        // Rollenbezeichnung aus dem Kanon (ZR-22), klein mit Artikel für „Lejla, die Apothekerin“ (MECH 9.4, 5.3).
        final titel = kanon.figur(p.kanonFigur)!['roleTitle']! as String;
        expect(p.bezeichnung, titel.substring(0, 1).toLowerCase() + titel.substring(1), reason: p.id);
        final art = p.platz <= 4 ? KammerArt.verdaechtig : (p.platz <= 10 ? KammerArt.zeuge : KammerArt.zusatz);
        expect(p.art, art, reason: p.id);
        expect(p.datei, 'rollen/${p.platz.toString().padLeft(2, '0')}-${p.id}.json');
      }
    });

    test('Tandems 1 bis 4 nach E6: Sibel & Damir, Hana & Serkan, Azra & Wojtek, Aylin & Tugba', () {
      expect([for (final t in inhalt.fall.tandems) '${t.nr}:${t.plaetze.join(',')}'], ['1:11,12', '2:13,14', '3:15,16', '4:17,18']);
      for (final p in inhalt.fall.plaetze.skip(10)) {
        expect(p.tandem, (p.platz - 9) ~/ 2, reason: p.id);
      }
    });

    test('Felder und Zonen nach WELT 2.1 und MECH 10.2', () {
      expect([for (final x in inhalt.fall.felder) '${x.id} ${x.name}'], [
        '1 Ost-Saal',
        '2 Linkes Buffet',
        '3 Rechtes Buffet',
        '4a Theke Westende mit Theken-Klappe',
        '4b Vor der Theke mit Eiskübel',
        '4c Hinter der Theke: Anrichte, Vorratsraumtür',
        '4d Theke Ostende',
        '5 Vorratsraum',
        '6 Durchgang mit Steinbogen',
        '7 Kaminsaal',
        '8a Turmgang',
        '8b Wendeltreppe und Turm-Toilette',
        'W Windfang',
      ]);
      expect([for (final z in inhalt.fall.zonen) z.name], [
        'Ost-Saal',
        'Buffetsaal – Linkes Buffet',
        'Buffetsaal – Rechtes Buffet',
        'Theke & Anrichte',
        'Vorratsraum',
        'Durchgang mit Steinbogen',
        'Kaminsaal',
        'Turmgang & Turm',
        'Windfang',
      ]);
      expect(inhalt.fall.zeitpunkte, ['z2357', 'scheppern']);
    });

    test('Uhrzeiten nach WELT 0.2, Raumnamen', () {
      final u = inhalt.fall.uhrzeiten;
      for (final z in ['18:00', '18:35', '20:15', '23:50', '23:57', '23:59', '0:00', '0:12', '7:00']) {
        expect(u, contains(z));
      }
      expect(u, isNot(contains('23:49')));
      expect(u, isNot(contains('0:04')));
      expect(u.toSet(), hasLength(u.length));
      expect(inhalt.fall.raumnamen, containsAll(['Ost-Saal', 'Buffetsaal', 'Vorratsraum', 'Durchgang', 'Kaminsaal',
          'Turmgang', 'Windfang', 'Steinbogen', 'Turm-Toilette', 'Theke', 'Theken-Klappe']));
    });

    test('Meilensteine M1 bis M9 mit zusammen höchstens 9 Punkten, Punkte und Enden', () {
      final f = inhalt.fall;
      expect([for (final m in f.meilensteine) m.nr], [for (var i = 1; i <= 9; i++) 'M$i']);
      expect(f.meilensteine.fold<int>(0, (s, m) => s + m.punkte), f.punkte.detektivMax);
      expect(f.punkte.detektivMax, 9);
      expect([for (final m in f.meilensteine) '${m.zeile}/${m.spalte}'], [
        'alibi/ahmet', 'alibi/fatma', 'alibi/can', 'heimlichtuerei/ahmet', 'heimlichtuerei/fatma',
        'heimlichtuerei/can', 'heimlichtuerei/olli', 'fundort/null', 'schluesselbeweis/olli',
      ]);
      final p = f.punkte;
      expect((p.tippTaeter, p.tippVersteck, p.tippBonus, p.taeterSonder, p.jePersonMax), (2, 1, 2, 3, 5));
      expect(p.tippTaeter + p.tippVersteck + p.tippBonus, p.jePersonMax);
      // Jede Anklage und jede Punktzahl 0..9 trifft genau ein Ende (MECH 8.2).
      for (final taeter in [true, false]) {
        for (var n = 0; n <= 9; n++) {
          expect(f.enden.where((e) => e.passt(taeterAngeklagt: taeter, punkte: n)), hasLength(1), reason: '$taeter $n');
        }
      }
    });

    test('Codes: Format, kein Buchstabenpaar doppelt (E3)', () {
      final codes = [...inhalt.fall.fassungsCodes, ...inhalt.fall.indizCodes];
      for (final c in codes) {
        expect(c, matches(RegExp(r'^[A-Z]{2}[3479]$')));
      }
      expect({for (final c in codes) c.substring(0, 2)}, hasLength(codes.length));
    });
  });

  group('Rollen', () {
    test('vier versiegelte Fassungen mit den Codes aus E3, nur bei Platz 1 bis 4', () {
      expect([for (final r in inhalt.rollen) r.fassung?.code], [
        'WW4', 'JM3', 'RN7', 'YW4', ...List.filled(14, null),
      ]);
      expect(inhalt.rolle(inhalt.fall.taeter).fassung!.code, 'RN7');
      for (final r in inhalt.rollen.take(4)) {
        final f = r.fassung!;
        expect(f.wasNurDuWeisst, hasLength(5), reason: r.id);
        expect(f.wennEsEngWird, hasLength(5), reason: r.id);
        expect(f.zeitleiste.length, inInclusiveRange(16, 17), reason: r.id);
      }
    });

    test('Marker nach WELT 4.1 und 4.2: nur die vier Verdächtigen behaupten falsch', () {
      String m(String id) {
        final x = inhalt.rolle(id).marker;
        return '${x.behauptet2357}/${x.behauptetScheppern} → ${x.wahr2357}/${x.wahrScheppern}';
      }

      expect(m('ahmet'), '4d/4d → 4d/4d');
      expect(m('fatma'), '2/2 → 4a/2');
      expect(m('olli'), '1/1 → 4b/4c');
      expect(m('can'), '8b/8b → 5/8b');
      expect(m('tim'), '4c/6 → 4c/6');
      expect(m('damir'), '1/4d → 1/4d');
      expect(m('serkan'), 'W/W → W/W');
      for (final r in inhalt.rollen.skip(4)) {
        expect(r.marker.behauptet2357, r.marker.wahr2357, reason: r.id);
        expect(r.marker.behauptetScheppern, r.marker.wahrScheppern, reason: r.id);
      }
    });

    test('Teile je Art: Haltung, Wissen, Freigabe, Tandem-Kasten, Solo', () {
      for (final r in inhalt.rollen) {
        final p = inhalt.platzVon(r.id);
        final verd = p.art == KammerArt.verdaechtig;
        expect(r.freigabe != null, verd, reason: r.id);
        expect(r.wasDuWeisst == null, verd, reason: r.id);
        expect(r.haltung == null, verd, reason: r.id);
        expect(r.tandemKasten != null, p.art == KammerArt.zusatz, reason: r.id);
        expect(r.solo != null, const {11, 13, 15, 17}.contains(p.platz), reason: r.id);
        expect(r.notiz != null, r.id == 'joanna', reason: r.id);
        expect(r.wennDerErzaehlerFragt.map((e) => e.impuls),
            ['I-1.1', 'I-1.2', 'I-1.3', 'I-2.1', 'I-2.2', 'I-2.3', 'I-3.1', 'I-3.3'], reason: r.id);
        // „Was du verbirgst“, „Was du dann sagst“, Marker und „Ab dann“ gibt es nur bei den vier (RK 1.1, ZG 0.6, ZR 0.7).
        final s2 = r.stufe2;
        expect([s2.wasDuVerbirgst, s2.wasDuDannSagst, s2.marker, s2.abDann].every((t) => t != null), verd, reason: r.id);
        expect([s2.wasDuVerbirgst, s2.wasDuDannSagst, s2.marker, s2.abDann].every((t) => t == null), !verd, reason: r.id);
        expect(r.stufe1.kernsaetze.isEmpty && r.stufe1.markersatz == null, !verd, reason: r.id);
        if (!verd) expect(r.stufe1.sagstDuJedem, isNotEmpty, reason: r.id);
      }
      expect(inhalt.rolle('joanna').notiz!.zeilen, hasLength(13));
      // Tugba hat keine Tarnung: nur „Das sagst du jedem“ mit Einleitung (ZR 8.6, ZG-03).
      final tugba = inhalt.rolle('tugba').stufe1;
      expect(tugba.ausweichsaetze, isEmpty);
      expect(tugba.verboten, isEmpty);
      expect(tugba.regie, startsWith('Du hast nichts zu verbergen.'));
      expect([for (final r in inhalt.rollen.skip(4)) if (r.stufe1.regie != null) r.id], ['tugba']);
    });

    test('Geheimniskarten: Rundensperre und Pflicht-Codes nach MECH 4.2 und 9.14', () {
      String g(String id) {
        final k = inhalt.rolle(id).geheimniskarte;
        return '${k.sperre} ${k.pflichtCodes.join(',')}';
      }

      expect(g('lejla'), '2 WE3,PM3,WM9');
      expect(g('emine'), '2 FM9,NN3');
      expect(g('tim'), '3 MR4,FK3');
      expect(g('joanna'), '2 WE3,PM3,WM9');
      expect(g('marek'), '3 XD3,JT3');
      expect(g('zeynep'), '3 FK3,JT3');
      expect(g('wojtek'), '2 MR4');
      expect(g('aylin'), '2 PM3,WE3');
      for (final id in ['ahmet', 'fatma', 'olli', 'can', 'sibel', 'damir', 'hana', 'serkan', 'azra', 'tugba']) {
        expect(inhalt.rolle(id).geheimniskarte.sperre, 1, reason: id);
      }
      for (final r in inhalt.rollen) {
        expect(r.geheimniskarte.vermerke, isNotEmpty, reason: r.id);
      }
      // Verdächtige: je ein Vermerk „Heimlichtuerei“ und „Ort um 23:57“ (MECH 4.2).
      for (final r in inhalt.rollen.take(4)) {
        expect(r.geheimniskarte.vermerke.map((v) => v.split(' · ').first), ['Heimlichtuerei', 'Ort um 23:57'],
            reason: r.id);
      }
    });

    test('Aktionskarten nach MECH 4.4', () {
      expect([for (final r in inhalt.rollen) r.aktionskarte.name], [
        'Einspruch', 'Gegenfrage', 'Themenwechsel', 'Retourkutsche', 'Krankenbesuch', 'Kreuzverhör', 'Stirnlampe',
        'Zeitstempel', 'Taschenkontrolle', 'Gelbe Karte', 'Noch mal rückwärts', 'Teepause', 'Spurenlesen',
        'Lagebesprechung', 'Lupe', 'Maßband', 'Beleg bitte!', 'Handzeichen',
      ]);
      for (final r in inhalt.rollen) {
        expect(r.aktionskarte.abRunde, const {'tim', 'marek'}.contains(r.id) ? 2 : 1, reason: r.id);
      }
      expect({for (final r in inhalt.rollen.take(4)) r.aktionskarte.klasse}, {KammerKlasse.schutz});
      expect([for (final r in inhalt.rollen) r.wasDuBeiDirTraegst.indizkarte].whereType<String>(), ['NN3', 'FN3', 'JT3']);
    });

    test('Gesprächsaufträge: je Runde zwei, Ziel 1 der Verdächtigen nach RK 1.2, Ausweichziel genau bei höherem Platz', () {
      for (final r in inhalt.rollen) {
        final eigener = inhalt.platzVon(r.id).platz;
        expect([for (final a in r.gespraechsauftraege) '${a.runde}/${a.nr}'],
            ['1/1', '1/2', '2/1', '2/2', '3/1', '3/2'], reason: r.id);
        for (final a in r.gespraechsauftraege) {
          final ziel = inhalt.platzVon(a.ziel).platz;
          final grenze = eigener > 4 ? eigener : 4;
          expect(a.ausweich != null, ziel > grenze, reason: '${r.id} ${a.runde}/${a.nr} → ${a.ziel}');
          if (inhalt.platzVon(r.id).art == KammerArt.zusatz) expect(ziel, lessThan(eigener), reason: r.id);
        }
      }
      String ziel1(String id, int runde) =>
          inhalt.rolle(id).gespraechsauftraege.firstWhere((a) => a.runde == runde && a.nr == 1).ziel;
      expect([for (final id in ['ahmet', 'fatma', 'olli', 'can']) ziel1(id, 1)], ['fatma', 'can', 'ahmet', 'olli']);
      expect([for (final id in ['ahmet', 'fatma', 'olli', 'can']) ziel1(id, 2)], ['olli', 'ahmet', 'can', 'fatma']);
      expect([for (final id in ['ahmet', 'fatma', 'olli', 'can']) ziel1(id, 3)], ['can', 'olli', 'fatma', 'ahmet']);
    });

    test('Verdächtige: gleiche Gestalt von Stufe 1 und 2 (RK 1.1, 1.3, 8.2, E9)', () {
      for (final r in inhalt.rollen.take(4)) {
        final s1 = r.stufe1;
        expect(s1.kernsaetze, hasLength(2), reason: r.id);
        expect(s1.ausweichsaetze, hasLength(7), reason: r.id);
        expect(s1.regie, isNotNull, reason: r.id);
        expect(s1.markersatz, isNotNull, reason: r.id);
        expect(s1.sagstDuJedem, isEmpty, reason: r.id);
        expect(s1.verboten, isEmpty, reason: r.id);
        // Bei allen vier fragt die zweite Ausweich-Zeile nach 23:51 Uhr (RK 8.2, P2-21).
        expect(s1.ausweichsaetze[1].frage, 'Wo warst du um 23:51 Uhr?', reason: r.id);
        final s2 = r.stufe2;
        for (final t in [s2.wasDuVerbirgst, s2.wasDuDannSagst, s2.marker, s2.abDann]) {
          expect(t, isNotNull, reason: r.id);
        }
        // Gemeinsamer Schlusssatz von „Ab dann“ (RK 8.2, P5-B3), außer solange der Text noch offen ist.
        if (!istKammerOffen(s2.abDann!)) expect(s2.abDann, endsWith('Mehr gibst du nicht zu. Dabei bleibst du.'), reason: r.id);
        expect(s2.nachDemUmdrehen, isEmpty, reason: r.id);
      }
    });

    test('Verdächtige: drei Pflicht-Auslöser, Freigabe 3 / 1 / 3 (RK 1.3, 1.4)', () {
      for (final r in inhalt.rollen.take(4)) {
        expect(r.stufe2.ausloeser, hasLength(3), reason: r.id);
        final f = r.freigabe!;
        expect((f.sofort.length, f.nachDemMarker.length, f.nachDerKarte.length), (3, 1, 3), reason: r.id);
        expect(r.bonusZiel.text, inhalt.rolle('ahmet').bonusZiel.text, reason: r.id);
      }
    });
  });

  group('Indizkarten', () {
    final alle = ['AD3', 'DM3', 'FK3', 'FM9', 'FN3', 'FX3', 'JA9', 'JT3', 'MR4', 'NN3', 'PM3', 'PP9', 'RH3', 'VP7', 'WE3',
        'WJ9', 'WM9', 'XD3', 'YT4'];

    test('19 Karten AD3 bis YT4, nach Code sortiert, wie fall.json', () {
      final codes = [for (final k in inhalt.indizkarten.karten) k.code];
      expect(codes, alle);
      expect(codes, inhalt.fall.indizCodes);
      expect((codes.first, codes.last), ('AD3', 'YT4'));
    });

    test('Rundenbindung (E12): neun ab Runde 1, sechs ab Runde 2, vier ab Runde 3', () {
      List<String> ab(int n) => [for (final k in inhalt.indizkarten.karten) if (k.abRunde == n) k.code];
      expect(ab(1), hasLength(9));
      expect(ab(2), ['FN3', 'JT3', 'MR4', 'NN3', 'PM3', 'WM9']);
      expect(ab(3), ['FK3', 'PP9', 'VP7', 'XD3']);
    });

    test('XD3, FN3, PP9, JT3, FK3 wie E3', () {
      final xd3 = inhalt.karte('XD3');
      expect(xd3.titel, 'Messingkerzenständer und Vorratsraum');
      expect(xd3.vermerke.single, startsWith('Schlüsselbeweis, Teil 1:'));
      expect(xd3.vermerke.single, isNot(contains('Olli')));
      expect(xd3.wasDuFindest, contains('Holzsplitter und weißer Kalk'));
      final fn3 = inhalt.karte('FN3');
      expect(fn3.titel, 'Olli: Taschen und Kleidung');
      expect(fn3.wasDuFindest, contains('rechter Arbeitshandschuh'));
      expect(fn3.vermerke.join(), isNot(contains('Schlüsselbeweis')));
      final pp9 = inhalt.karte('PP9');
      expect(pp9.felder, ['4b']);
      expect(pp9.vermerke.single, startsWith('Fundort:'));
      expect(pp9.meilensteine, ['M8']);
      final jt3 = inhalt.karte('JT3');
      expect(jt3.titel, 'Can: Taschen und Kleidung');
      expect(jt3.vermerke.single, contains('Leuchtfarbe'));
      final fk3 = inhalt.karte('FK3');
      expect(fk3.art, KammerKartenArt.ortstermin);
      expect(fk3.zeugen, ['zeynep']);
      expect(fk3.meilensteine, containsAll(['M3', 'M6']));
      expect(inhalt.karte('XD3').meilensteine, ['M9']);
    });

    test('Ortstermine öffnen genau die Streifen ihrer Zeugen (MECH 5.3)', () {
      final ortstermine = [for (final k in inhalt.indizkarten.karten) if (k.art == KammerKartenArt.ortstermin) k];
      expect([for (final k in ortstermine) '${k.code}:${k.zeugen.join('+')}'],
          ['AD3:tim+zeynep', 'DM3:lejla', 'FK3:zeynep', 'FX3:joanna', 'RH3:emine', 'WJ9:marek']);
      for (final s in inhalt.streifen) {
        expect(s.oeffnen, [for (final k in ortstermine) if (k.zeugen.contains(s.zeuge)) k.code], reason: s.zeuge);
      }
    });
  });

  group('Lageplan und Tisch', () {
    final plan = inhalt.tisch.lageplan;
    KammerFlaeche feld(String id) => plan.felder.firstWhere((f) => f.id == id);
    List<String> felderBei(double x, double y) => [for (final f in plan.felder) if (f.enthaelt(x, y)) f.id];

    test('Raster 25 × 22 m, 8,5 mm je Meter (MECH 10.2)', () {
      expect((plan.x0, plan.y0, plan.breite, plan.hoehe, plan.mmJeMeter), (1, 1, 25, 22, 8.5));
      for (final f in [...plan.felder, ...plan.raeume, ...plan.moebel]) {
        for (final b in f.kacheln) {
          expect(b.x0 >= plan.x0 && b.x1 < plan.x0 + plan.breite && b.y0 >= plan.y0 && b.y1 < plan.y0 + plan.hoehe,
              isTrue, reason: f.id);
        }
      }
    });

    test('Felder überlappen nicht, jeder Gegenstand liegt in seinem Feld', () {
      for (var x = plan.x0; x < plan.x0 + plan.breite; x++) {
        for (var y = plan.y0; y < plan.y0 + plan.hoehe; y++) {
          expect(felderBei(x + 0.5, y + 0.5).length, lessThanOrEqualTo(1), reason: '$x/$y');
        }
      }
      for (final g in plan.gegenstaende) {
        expect(felderBei(g.x, g.y), [g.zusatz], reason: g.id);
      }
    });

    test('alle Gegenstände und Türen aus WELT 2.1 und 2.2 stehen auf dem Plan (MECH 10.2)', () {
      final namen = <String>[for (final g in plan.gegenstaende) g.name, for (final t in plan.tueren) t.name, for (final m in plan.moebel) m.name!];
      bool steht(String wort) => namen.any((n) => n.contains(wort));
      for (final wort in [
        'Kopf der Tafel', 'Jackenständer', 'Wandtafel', 'Handykorb', 'Ehrenplatz', 'Musikbox', 'lange Tafel',
        'Gebäck', 'Thermoskanne', 'Warmhaltebehälter', 'Theke', 'Theken-Klappe', 'Eiskübel (vor dem Ostende)', 'Spüle',
        'Messingkerzenständer', 'Teekocher', 'Kaffeemaschine', 'Werkzeugkasten', 'Anrichte Ost', 'Mitternachtstorte',
        'Erste-Hilfe-Kasten', 'Notlaterne', 'Fundort Herr Schneider', 'Getränkekisten', 'Sicherungskasten', 'Steinbogen',
        'Kamin-Nische', 'Ascheneimer', 'Wandbank', 'Lichtschächte', 'Bogentür', 'Ritterrüstung', 'Schauvitrine',
        'Wendeltreppe', 'Hoftür', 'Schlüsselkasten', 'Innentür', 'Außentor', 'Sandsteinstufen', 'Tür zum Ost-Saal',
        'Vorratsraumtür', 'Tür zum Durchgang',
      ]) {
        expect(steht(wort), isTrue, reason: wort);
      }
      // Kein Rollenname auf dem Plan.
      final rollen = RegExp('\\b(${[for (final p in inhalt.fall.plaetze) p.name].join('|')})s?\\b');
      expect(namen.where(rollen.hasMatch), isEmpty);
    });

    test('feste Punkte aus WELT 2.3 liegen im richtigen Feld', () {
      final punkte = [
        (13.5, 8.5, '4c'),
        (14.5, 7.5, '4c'),
        (14.5, 5.5, '5'),
        (11.5, 9.5, '4a'),
        (12.5, 10.5, '4a'),
        (17.5, 10.5, '4b'),
        (18.5, 9.5, '4d'),
        (16.5, 8.5, '4c'),
        (17.5, 8.5, '4d'),
        (18.5, 8.5, '4d'),
        (16.5, 13.5, '3'),
        (11.5, 13.5, '2'),
        (19.5, 9.5, '1'),
        (24.5, 12.5, '1'),
        (22.5, 10.5, '1'),
        (20.5, 8.5, '1'),
        (21.5, 13.5, '1'),
        (24.5, 16.5, '1'),
        (25.5, 15.5, '1'),
        (9.5, 8.5, '6'),
        (7.5, 9.5, '6'),
        (2.5, 8.5, '7'),
        (2.5, 13.5, '7'),
        (1.5, 14.5, '7'),
        (3.5, 18.5, '7'),
      ];
      for (final (x, y, f) in punkte) {
        expect(felderBei(x, y), [f], reason: '$x/$y');
      }
      expect(feld('4b').enthaelt(17.5, 10.5), isTrue);
    });

    test('Blatt B: 5 × 3 Zellen, jede einmal, Feld 1 oben über drei Zellen, 2, 3, 4d, 6 am Rand (MECH 10.2)', () {
      final mf = inhalt.tisch.markerfelder;
      expect((mf.spalten, mf.reihen, mf.zelleBreiteMm, mf.zelleHoeheMm), (5, 3, 54, 58));
      final zellen = [for (final b in mf.belegung) ...b.zellen];
      expect(zellen.toSet(), hasLength(15));
      expect(zellen.every((z) => z.$1 >= 0 && z.$1 < 5 && z.$2 >= 0 && z.$2 < 3), isTrue);
      final eins = mf.belegung.firstWhere((b) => b.feld == '1');
      expect(eins.zellen.map((z) => z.$2).toSet(), {0});
      expect(eins.zellen, hasLength(3));
      expect(eins.plaettchen, greaterThanOrEqualTo(18));
      bool amRand((int, int) z) => z.$1 == 0 || z.$1 == 4 || z.$2 == 0 || z.$2 == 2;
      for (final f in ['2', '3', '4d', '6']) {
        expect(mf.belegung.firstWhere((b) => b.feld == f).zellen.every(amRand), isTrue, reason: f);
      }
      for (final f in ['4a', '4b', '4c']) {
        expect(mf.belegung.firstWhere((b) => b.feld == f).zellen.single.$2, 1, reason: f);
        expect(amRand(mf.belegung.firstWhere((b) => b.feld == f).zellen.single), isFalse, reason: f);
      }
    });

    test('Marker, Tipp-Zettel und Abwesenheitsblatt', () {
      final m = inhalt.tisch.marker;
      expect((m.breiteMm, m.hoeheMm, m.jeRolle, m.max), (26, 18, 2, 40));
      expect([for (final f in m.feste) '${f.wer} ${f.z2357}/${f.scheppern}'], ['detektiv 1/1', 'schneider 4d/4c']);
      final t = inhalt.tisch.tippZettel;
      expect([for (final f in t.fragen) '${f.art}:${f.punkte}'], ['taeter:2', 'versteck:1', 'bonus:2']);
      expect(t.jeBlatt, 4);
      final a = inhalt.tisch.abwesenheitsblatt;
      expect((a.spalten, a.reihen, a.streifenBreiteMm, a.streifenHoeheMm, a.etikettHoeheMm), (2, 3, 100, 95, 30));
      expect([for (final s in inhalt.streifen) s.zeuge], ['lejla', 'emine', 'tim', 'joanna', 'marek', 'zeynep']);
      expect([for (final s in inhalt.streifen) s.feld], ['3', '2', '6', '1', '4d', '6']);
      expect([for (final s in inhalt.streifen) if (s.mitNotiz) s.zeuge], ['joanna']);
    });
  });

  group('Beschriftungen und Teile', () {
    test('Dateinamen nach ARCHITEKTUR A2', () {
      expect({for (final t in kammerTeile) t: inhalt.uiText(t, 'datei')}, {
        '00': '00-erzaehlerheft.pdf',
        '01': '01-detektivbogen.pdf',
        '02': '02-tisch.pdf',
        '10': '10-rollenhefte.pdf',
        '11': '11-fassungen.pdf',
        '12': '12-zusatzrollen.pdf',
        '20': '20-karten.pdf',
        '90': '90-aufloesung-versiegelt.pdf',
      });
      expect(inhalt.uiText('gemeinsam', 'datei.alles'), 'kammerspiel-alles.pdf');
      expect(inhalt.uiText('10', 'dateiEinzeln'), '10-rollenheft-{figur}.pdf');
      expect(inhalt.uiText('12', 'dateiEinzeln'), '12-zusatzheft-{figur}.pdf');
      expect(() => inhalt.uiText('00', 'gibtsnicht'), throwsArgumentError);
    });

    test('Detektiv: „Wenn Rollen fehlen“ nach RK 6.12, Bereiche überschneiden sich', () {
      final d = inhalt.detektiv;
      expect([for (final h in d.wennRollenFehlen) '${h.von}–${h.bis}'], ['6–11', '6–6', '12–20', '15–20']);
      expect(d.wennRollenFehlenBei(6), hasLength(2));
      expect(d.wennRollenFehlenBei(10), hasLength(1));
      expect(d.wennRollenFehlenBei(13), hasLength(1));
      expect(d.wennRollenFehlenBei(16), hasLength(2));
      // Die Frage an Gäste im Windfang und im Kaminsaal trägt ein Ziel auf Serkan (P145R2-M05).
      expect(d.wennRollenFehlenBei(16).last, contains('„Was wolltest du kurz vor zwölf dort, und warum?“'));
      expect(d.wennRollenFehlenBei(14).join(), isNot(contains('Windfang')));
    });

    test('Erzählerheft: Impulse I-1.1 bis I-3.4, Ablauf, Skalierungshinweise', () {
      final e = inhalt.erzaehlerheft;
      expect([for (final i in e.impulse) i.id],
          [for (var r = 1; r <= 3; r++) for (var n = 1; n <= 4; n++) 'I-$r.$n']);
      expect(e.runden.last.schluss, isNull);
      expect([for (final s in e.ablauf) s.minutenBei(6)].fold<int>(0, (a, b) => a + b), 155);
      expect([for (final s in e.ablauf) s.minutenBei(12)].fold<int>(0, (a, b) => a + b), 167);
      expect([for (final s in e.ablauf) s.minutenBei(20)].fold<int>(0, (a, b) => a + b), 176);
      expect(e.skalierungsHinweis(9), isNull);
      expect(e.skalierungsHinweis(16), isNotNull);
    });
  });

  group('Texte', () {
    test('Uhrzeiten in fertigen Texten stehen in der Liste aus WELT 0.2 (ohne Teil 90)', () {
      final erlaubt = inhalt.fall.uhrzeiten.toSet();
      final zeit = RegExp(r'(?<![\d:])(\d{1,2}:\d{2})(?![\d:])');
      final dateien = leseKammerDateien(repoWurzel);
      for (final d in kammerInhaltDateien.where((d) => d != 'aufloesung.json')) {
        for (final t in texteIn(jsonDecode(dateien[d]!))) {
          if (istKammerOffen(t)) continue;
          for (final m in zeit.allMatches(t)) {
            expect(erlaubt, contains(m.group(1)), reason: '$d: $t');
          }
        }
      }
    });

    test('jeder OFFEN-Text nennt seine Bibel-Kennung, offeneFelder zeigt auf Datei und Pfad', () {
      final dateien = leseKammerDateien(repoWurzel);
      for (final d in kammerInhaltDateien) {
        for (final t in texteIn(jsonDecode(dateien[d]!))) {
          if (istKammerOffen(t)) expect(t, matches(RegExp(r'^OFFEN: (RK|ZG|ZR|MECH|WELT) \d')), reason: d);
        }
      }
      for (final o in inhalt.offeneFelder) {
        expect(kammerInhaltDateien.any((d) => o.startsWith('$d: ')), isTrue, reason: o);
      }
    });

    test('ungespielte Zusatzrollen stehen nirgends mit Namen (WELT 1.1, MECH 8.3)', () {
      // Bei 6 und 12 Personen spielt keine Zusatzrolle; ihre Hefte, Karten und Absätze werden nicht gedruckt.
      final zusatz = [for (final p in inhalt.fall.plaetze) if (p.art == KammerArt.zusatz) p];
      final name = RegExp('\\b(${[for (final p in zusatz) p.name].join('|')})s?\\b');
      final dateien = leseKammerDateien(repoWurzel);
      const werte = {'name': 'X', 'codes': 'X', 'runde': '1', 'bund': 'X'};
      for (final personen in [6, 12]) {
        final b = KammerBesetzung.fuer(inhalt, personen: personen);
        for (final d in kammerInhaltDateien) {
          if (d == 'fall.json' || d.startsWith('ui/') || zusatz.any((p) => p.datei == d)) continue;
          for (final t in texteIn(jsonDecode(dateien[d]!))) {
            if (istKammerOffen(t)) continue;
            expect(b.text(t, werte: werte), isNot(matches(name)), reason: '$personen Personen, $d: $t');
          }
        }
      }
      expect(KammerBesetzung.fuer(inhalt, personen: 14).text(inhalt.aufloesung.meilensteine.first.stichwort),
          contains('„bei Damir“'));
    });

    test('offene Listen sind ganz offen oder ganz geschrieben (SCHEMA §2 „Offene Listen“)', () {
      void ganz(List<String> texte, String wo) {
        if (texte.any(istKammerOffen)) expect(texte, hasLength(1), reason: wo);
      }

      for (final r in inhalt.rollen) {
        ganz(r.stufe1.sagstDuJedem, '${r.id} sagstDuJedem');
        ganz(r.stufe1.verboten, '${r.id} verboten');
        ganz([for (final a in r.stufe1.ausweichsaetze) a.frage], '${r.id} ausweichsaetze');
        ganz([for (final z in r.wasDuWeisst?.zeilen ?? const <KammerWissenZeile>[]) z.text], '${r.id} wasDuWeisst');
      }
      ganz([for (final z in inhalt.aufloesung.zeitleiste) z.zeit], 'aufloesung zeitleiste');
    });

    test('Platzhalter nennen nur Rollen 5 bis 18', () {
      final dateien = leseKammerDateien(repoWurzel);
      final hauptrollen = {for (final p in inhalt.fall.plaetze.take(4)) p.id};
      for (final d in kammerInhaltDateien) {
        for (final t in texteIn(jsonDecode(dateien[d]!))) {
          expect(kammerTextRollen(t).intersection(hauptrollen), isEmpty, reason: '$d: $t');
        }
      }
    });
  });

  group('Rot-Proben: der Lader wirft mit Datei und Pfad', () {
    test('fehlende Datei', () {
      final k = kopie()..remove('fall.json');
      expect(() => KammerInhalt.ausJson(k), wirft(['fall.json', 'Datei fehlt']));
    });

    test('unbekannte Datei', () {
      final k = kopie();
      k['ui/99.json'] = {'datei': 'x', 'titel': 'x'};
      expect(() => KammerInhalt.ausJson(k), wirft(['ui/99.json', 'unbekannte Inhaltsdatei']));
    });

    test('repo-relative Schlüssel und Text als Wert gehen auch', () {
      final k = {for (final e in leseKammerDateien(repoWurzel).entries) '$kammerInhaltOrdner/${e.key}': e.value};
      expect(KammerInhalt.ausJson(k).rollen, hasLength(18));
    });

    test('fehlendes Feld', () {
      final k = kopie();
      ((k['rollen/03-olli.json']!['geheimniskarte']) as Map).remove('vermerke');
      expect(() => KammerInhalt.ausJson(k), wirft(['rollen/03-olli.json', 'geheimniskarte.vermerke', 'Feld fehlt']));
    });

    test('unbekanntes Feld', () {
      final k = kopie();
      (((k['indizkarten.json']!['karten']) as List)[0] as Map)['quatsch'] = 1;
      expect(() => KammerInhalt.ausJson(k), wirft(['indizkarten.json', 'karten[0].quatsch', 'unbekanntes Feld']));
    });

    test('unbekanntes Feld oben in fall.json', () {
      final k = kopie();
      k['fall.json']!['extra'] = true;
      expect(() => KammerInhalt.ausJson(k), wirft(['fall.json', 'extra', 'unbekanntes Feld']));
    });

    test('falscher Typ', () {
      final k = kopie();
      (k['fall.json']!['personen'] as Map)['min'] = '6';
      expect(() => KammerInhalt.ausJson(k), wirft(['fall.json', 'personen.min', 'ganze Zahl']));
    });

    test('Platzhalter mit unbekannter Rolle', () {
      final k = kopie();
      (k['gemeinsam.json']!['wasAlleWissen'] as List)[2] = 'Hallo {rolle:baran|ein Gast}.';
      expect(() => KammerInhalt.ausJson(k), wirft(['gemeinsam.json', 'wasAlleWissen[2]', 'unbekannte Rolle']));
    });

    test('Wert-Platzhalter, wo das Schema keinen erlaubt', () {
      final k = kopie();
      k['gemeinsam.json']!['licht'] = 'Licht für {name}.';
      expect(() => KammerInhalt.ausJson(k), wirft(['gemeinsam.json', 'licht', '{name}']));
    });

    test('offene Auszeichnung', () {
      final k = kopie();
      k['detektiv.json']!['auftritt'] = '**Halb fett.';
      expect(() => KammerInhalt.ausJson(k), wirft(['detektiv.json', 'auftritt', 'nicht geschlossen']));
    });

    test('Verdächtiger ohne Fassung, Zeuge mit Fassung', () {
      final k = kopie();
      k['rollen/02-fatma.json']!['fassung'] = null;
      expect(() => KammerInhalt.ausJson(k), wirft(['rollen/02-fatma.json', 'fassung']));
      final k2 = kopie();
      k2['rollen/05-lejla.json']!['fassung'] = k2['rollen/02-fatma.json']!['fassung'];
      expect(() => KammerInhalt.ausJson(k2), wirft(['rollen/05-lejla.json', 'fassung']));
    });

    test('Indizkarte mit unbekanntem Feld des Lageplans', () {
      final k = kopie();
      (((k['indizkarten.json']!['karten']) as List)[0] as Map)['felder'] = ['9z'];
      expect(() => KammerInhalt.ausJson(k), wirft(['indizkarten.json', 'AD3', 'felder']));
    });

    test('Platz mit falscher Art', () {
      final k = kopie();
      ((k['fall.json']!['plaetze'] as List)[4] as Map)['art'] = 'verdaechtig';
      expect(() => KammerInhalt.ausJson(k), wirft(['fall.json', 'plaetze[4].art']));
    });

    test('Personenbereich außerhalb 6 bis 20', () {
      final k = kopie();
      ((k['detektiv.json']!['wennRollenFehlen'] as List)[0] as Map)['von'] = 4;
      expect(() => KammerInhalt.ausJson(k), wirft(['detektiv.json#wennRollenFehlen']));
      final k2 = kopie();
      ((k2['fall.json']!['plaetze'] as List)[0] as Map).remove('bezeichnung');
      expect(() => KammerInhalt.ausJson(k2), wirft(['fall.json', 'plaetze[0].bezeichnung', 'Feld fehlt']));
    });

    test('unbekannter Aufzählungswert', () {
      final k = kopie();
      (k['rollen/07-tim.json']!['aktionskarte'] as Map)['klasse'] = 'zauber';
      expect(() => KammerInhalt.ausJson(k), wirft(['rollen/07-tim.json', 'aktionskarte.klasse']));
    });
  });
}
