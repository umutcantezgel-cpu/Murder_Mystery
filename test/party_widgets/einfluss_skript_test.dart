// Finale Schlosskeller: das Entwickler-Skript mit „Dein Moment“
// (`?party=schlosskeller&einstimmung=1&einfluss=1`, Finale §3) über die echten
// Bildschirme eines Geräts. Es geht Vorgeschichte und Vorstellung durch, zieht
// je Runde für jede Rolle verdeckt den Zug eines Bots, lässt zu Beginn der
// Ermittlung die Folgen lesen, ermittelt ohne Gruppenwahl, nutzt vor der
// Anklage eine offene Nachfrage und läuft bis zum Schluss. Die Fotostellen
// sind die der Browserprobe `tool/e2e/finale.mjs`. Ohne `einfluss=1` bleibt
// das Skript, wie es war.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte/l10n/gen/app_localizations.dart';
import 'package:mordakte/party/party_seite.dart';
import 'package:mordakte/party/sitzung.dart';
import 'package:mordakte/party/skript.dart';
import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/runden.dart';

import 'einfluss_hilfe.dart';
import 'hilfe.dart';

const _runde = ['gespraeche', 'entscheidungen', 'bonus', 'resuemee'];

/// Phasen mit „Dein Moment“: wie im kurzen Abend, nur ohne Gruppenwahl.
const _phasen = ['einrichtung', 'rollen', 'intro', ..._runde, ..._runde, ..._runde, 'anklage', 'finale', 'aufloesung', 'ende'];

/// Folge ohne direkte Wiederholungen (`kollabiere` in tool/e2e/e2e.mjs).
List<String> _kollabiere(List<String> l) => [for (var i = 0; i < l.length; i++) if (i == 0 || l[i] != l[i - 1]) l[i]];

List<Map<String, Object?>> _befehle(PartySitzung s, String b) =>
    [for (final x in (s.abendstand['befehle'] as List).cast<Map<String, Object?>>()) if (x['b'] == b) x];

/// Die Adresse der Browserprobe, nur schneller und ohne Fotografen.
PartyDev _dev({bool einfluss = true}) => PartyDev.ausUrl({
      'party': 'schlosskeller',
      'pfad': 'ahmet',
      'n': '5',
      'skript': 'best,a,richtig',
      'einstimmung': '1',
      if (einfluss) 'einfluss': '1',
      'takt': '60',
      'fotos': '0',
      'zeitraffer': '600',
    })!;

void main() {
  test('Entwicklerroute: einfluss=1 schaltet „Dein Moment“ ein, nur in Akten mit der Schicht', () {
    final dev = _dev();
    expect([dev.einfluss, dev.einstimmung], [true, true]);
    expect(_dev(einfluss: false).einfluss, isFalse);
    expect(PartyDev.ausUrl({'party': '', 'einfluss': '0'})!.einfluss, isFalse);
    final mit = PartySitzung(einflussDaten, salz: 'einfluss-skript');
    final ohne = PartySitzung(partyDaten, salz: 'einfluss-skript');
    addTearDown(mit.dispose);
    addTearDown(ohne.dispose);
    expect([dev.einflussFuer(mit), dev.einflussFuer(ohne), _dev(einfluss: false).einflussFuer(mit)], [true, false, false]);
  });

  test('Standbild-Einstieg (bis=) mit einfluss=1: Die Bots ziehen für alle, die Gruppenwahl entfällt', () {
    final s = PartySitzung(einflussDaten, salz: 'einfluss-skript-bis');
    addTearDown(s.dispose);
    final phasen = <PartyPhase>[];
    s.addListener(() {
      if (phasen.lastOrNull != s.phase) phasen.add(s.phase);
    });
    PartySkript.vorspielen(s, _dev(), PartyPhase.anklage);
    expect([s.phase, s.einfluss, s.mitEinstimmung], [PartyPhase.anklage, true, true]);
    expect(phasen, isNot(contains(PartyPhase.gruppenwahl)));
    for (var r = 1; r <= 3; r++) {
      for (final rolle in s.besetzt) {
        expect(s.einflussAbend!.stand.zug(r, rolle)?.art, isNot(anyOf(isNull, ZugArt.abgewartet)), reason: 'Runde $r, $rolle');
      }
    }
    expect(_befehle(s, 'moment'), hasLength(3 * s.besetzt.length));
  });

  testWidgets('Skript mit einfluss=1: Einstimmung, Moment je Runde, Folgen, Abzeichen, Nachfrage, Auflösung mit Sternen', (t) async {
    t.view.physicalSize = const Size(390, 844);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    final s = PartySitzung(einflussDaten, salz: 'einfluss-skript');
    addTearDown(s.dispose);
    testAbendzeit(t, s);
    // Was das Skript sieht, bevor es weitergeht: Nachfragen vor der Anklage, Tischwerte der Wahlen.
    int? nachfragenVorAnklage;
    final tisch = <String, int>{};
    s.addListener(() {
      if (s.phase == PartyPhase.anklage && s.angeklagt == null) nachfragenVorAnklage ??= s.nachfragenOffen;
      if (s.vorschlag case final v?) tisch[v.entscheidung] = s.tischwert(v.option) ?? 0;
    });

    final zeilen = <String>[];
    final vorher = debugPrint;
    debugPrint = (String? m, {int? wrapWidth}) {
      if (m != null) zeilen.add(m);
    };
    PartySitzung.protokoll = true;
    try {
      await t.pumpWidget(MaterialApp(
        theme: ThemeData.dark(),
        localizationsDelegates: L.localizationsDelegates,
        supportedLocales: L.supportedLocales,
        locale: const Locale('de'),
        home: Scaffold(body: PartyAblauf(sitzung: s)),
      ));
      await t.pump();
      unawaited(PartySkript(s, _dev()).starten());
      for (var i = 0; i < 30000 && !zeilen.any((z) => z.startsWith('PARTY fertig') || z.startsWith('PARTY fehler')); i++) {
        await t.pump(const Duration(milliseconds: 100));
      }
    } finally {
      debugPrint = vorher;
      PartySitzung.protokoll = false;
    }
    expect(zeilen.where((z) => z.startsWith('PARTY fehler')), isEmpty, reason: zeilen.reversed.take(8).join(' | '));
    expect(zeilen.where((z) => z.startsWith('PARTY fertig pfad=ahmet')), hasLength(1), reason: 'Der Abend läuft durch');
    expect([s.phase, s.einfluss, s.mitEinstimmung, s.einstimmung], [PartyPhase.ende, true, true, null]);

    // Phasen ohne Gruppenwahl.
    final phasen = [for (final z in zeilen) if (z.startsWith('PARTY phase=')) RegExp(r'phase=(\w+)').firstMatch(z)!.group(1)!];
    expect(_kollabiere(phasen.where((p) => p != 'titel').toList()), _phasen);

    // Fotostellen der Browserprobe in ihrer Folge.
    final fotos = [for (final z in zeilen) if (z.startsWith('PARTY foto=')) z.substring('PARTY foto='.length)];
    int pos(String f) {
      expect(fotos.where((x) => x == f), hasLength(1), reason: '$f in ${fotos.join(' > ')}');
      return fotos.indexOf(f);
    }

    expect(pos('dossier_taeter'), lessThan(pos('vorgeschichte')));
    expect(pos('vorgeschichte'), lessThan(pos('vorstellung')));
    expect(pos('vorstellung'), lessThan(pos('intro')), reason: 'Erst die Einstimmung, dann die Einleitung');
    for (var r = 1; r <= 3; r++) {
      expect(pos('gespraeche_r$r'), lessThan(pos('moment_r$r')));
      expect(pos('moment_r$r'), lessThan(pos('folgen_r$r')), reason: 'Erst ziehen alle, dann die Folgen');
      expect(pos('folgen_r$r'), lessThan(pos('entscheidungen_fertig_r$r')));
      expect(pos('entscheidungen_fertig_r$r'), lessThan(pos('resuemee_r$r')));
    }
    expect(fotos.where((f) => f.startsWith('wahl_') || f.startsWith('gruppenwahl_')), isEmpty, reason: 'Keine Gruppenwahl');
    if (_r1Auftakt(fotos) case final i?) expect(pos('folgen_r1'), lessThan(i), reason: 'Die Folgen liegen vor dem Auftaktwurf');

    // Jede Rolle zog in jeder Runde selbst (reihum verdeckt), niemand wartete ab.
    for (var r = 1; r <= 3; r++) {
      for (final rolle in s.besetzt) {
        expect(s.einflussAbend!.stand.zug(r, rolle)?.art, isNot(anyOf(isNull, ZugArt.abgewartet)), reason: 'Runde $r, $rolle');
      }
    }
    expect(_befehle(s, 'moment'), hasLength(3 * s.besetzt.length));

    // Abzeichen: genau die endgültigen Wahlen mit Tischwert tragen die Endung.
    final abzeichen = {for (final f in fotos) if (f.startsWith('endgueltig_') && f.endsWith('_abzeichen')) f.substring('endgueltig_'.length, f.length - '_abzeichen'.length)};
    expect(abzeichen, {for (final e in tisch.entries) if (e.value != 0) e.key});
    expect(abzeichen, isNotEmpty, reason: 'Mit diesem Salz trägt mindestens eine Wahl ein Abzeichen');

    // Nachfrage: genau eine, wenn eine offen war, und dann vor der Anklage.
    expect(nachfragenVorAnklage, isNotNull);
    expect(nachfragenVorAnklage, greaterThan(0), reason: 'Mit diesem Salz ist vor der Anklage eine Nachfrage offen');
    expect(_befehle(s, 'nachfrage'), hasLength(1));
    expect(pos('nachfrage'), lessThan(pos('anklage')));

    // Auflösung mit Sternen und Auszeichnungen.
    expect(s.einflussAufloesung, isNotNull);
    expect(pos('aufloesung_r3'), lessThan(pos('ende')));
    await t.pumpWidget(const SizedBox());
    await t.pump(const Duration(seconds: 2));
  });
}

/// Index der ersten Kartenaktion von Runde 1 (Auftakt), sonst `null`.
int? _r1Auftakt(List<String> fotos) {
  final i = fotos.indexWhere((f) => f.startsWith('aktion_auftakt'));
  return i < 0 ? null : i;
}
