// „Dein Moment“ am eigenen Gerät (Finale §3, online): Den Knopf haben nur
// Gäste mit Figur; das Lauschergebnis sieht nur, wer lauschte; die Zug-Tafel
// nur der Erzähler-Sitz; wer leitet, gibt den letzten Aufruf, und nach dem
// Countdown geht es weiter. Ein echter Raum mit Schicht, Gäste über LiveGast.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte/abend/online/erzaehler_ablauf.dart' show ErzaehlerPultOnline;
import 'package:mordakte/abend/online/gastgeber_sitzung.dart';
import 'package:mordakte/l10n/gen/app_localizations_de.dart';
import 'package:mordakte/party/bildschirme/moment.dart' show momentTexte;
import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/runden.dart';

import '../party_widgets/einfluss_hilfe.dart' show einflussDaten;
import 'online_hilfe.dart';

Map<String, Object?> _map(Object? v) => (v as Map).cast<String, Object?>();

/// Ein gestarteter Raum mit Schicht: Anna (Gastgeberin, Detektiv), Ben (`g1`,
/// Erzähler), Cleo (`g2`) und Dora (`g3`) mit Figuren; vier Rollen, zwei davon
/// spielt die App.
SchlosskellerRaum _raum({bool einfluss = true, bool gastgeberErzaehler = false}) {
  final d = einflussDaten;
  final raum = SchlosskellerRaum(
    raumCode: 'ABCDEF',
    kanon: d.kanon,
    texte: d.texte,
    fallCode: FallCode.fuerPfad('ahmet', d.kanon.pfade),
    salz: 'salz-moment',
    festerGastgeber: true,
    gastgeberSitz: gastgeberErzaehler ? Sitz.erzaehler : Sitz.detektiv,
    einfluss: einfluss ? d.einfluss : null,
  );
  for (final (id, name) in [('gastgeber', 'Anna'), ('g1', 'Ben'), ('g2', 'Cleo'), ('g3', 'Dora')]) {
    raum.beitreten(id, name);
  }
  raum.nachricht('gastgeber', {'typ': 'sitz', 'spieler': 'g1', 'sitz': gastgeberErzaehler ? 'detektiv' : 'erzaehler'});
  for (final id in ['g1', 'g2', 'g3', 'gastgeber']) {
    raum.nachricht(id, {'typ': 'bereit', 'wert': true});
  }
  raum.nachricht('gastgeber', {'typ': 'start', 'rollen': 4, 'detektiv': 'w', 'vorrat': const <String>[]});
  return raum;
}

String _rolle(SchlosskellerRaum raum, String id) => _map(raum.zustandFuer(id)['privat'])['rolle'] as String;

/// Bis zu den Gesprächen von Runde [runde]; in jeder Runde davor ziehen die Gäste [zuege] (Gerät → Zug).
void _bisGespraeche(SchlosskellerRaum raum, int runde, {Map<String, Map<String, Object?>> Function(SchlosskellerRaum)? zuege, String leiter = 'g1', String detektiv = 'gastgeber'}) {
  for (var i = 0; i < 400; i++) {
    final s = raum.zustandFuer('gastgeber');
    if (s['phase'] == 'gespraeche' && s['runde'] == runde) return;
    if (s['phase'] == 'gespraeche') {
      befragungenImRaum(raum, detektiv: detektiv);
      if (raum.einfluss != null) {
        for (final e in (zuege?.call(raum) ?? {for (final g in ['g2', 'g3']) g: {'art': 'helfen'}}).entries) {
          raum.nachricht(e.key, {'typ': 'zug', ...e.value});
        }
      }
      raum.nachricht(leiter, {'typ': 'weiter'});
      continue;
    }
    if (s['phase'] == 'rollen') {
      for (final g in ['g2', 'g3']) {
        raum.nachricht(g, {'typ': 'rollenGelesen'});
      }
      raum.nachricht(leiter, {'typ': 'weiter'});
      continue;
    }
    if (s['phase'] == 'entscheidungen') {
      if (s['zug'] case final Map z) {
        switch (z['phase']) {
          case 'aktion':
            raum.nachricht(detektiv, {'typ': 'aktionFertig', 'aktion': z['aktion']});
          case 'wurf':
            raum.nachricht(s['wuerfelPate'] as String, {'typ': 'wurf'});
          case 'tischruf':
            raum.nachricht(detektiv, {'typ': 'tischruf', 'ruf': 'umweg'});
          case 'fund':
            raum.nachricht(detektiv, {'typ': 'fundGelesen'});
        }
        continue;
      }
      if (s['entscheidung'] case final Map e) {
        final erm = raum.partieFuerGastgeber!.spiel.ermittlung;
        raum.nachricht(detektiv, {'typ': 'wahl', 'option': erm.entscheidung(e['id'] as String).optionen.first.id});
        continue;
      }
    }
    raum.nachricht(leiter, {'typ': 'weiter'});
  }
  fail('Gespräche von Runde $runde nicht erreicht');
}

void main() {
  testWidgets('Den Knopf „Dein Moment“ haben nur Gäste mit Figur; der Zug geht als Nachricht hinaus', (t) async {
    final raum = _raum();
    _bisGespraeche(raum, 1);
    final cleo = LiveGast(raum, spielerId: 'g2', daten: einflussDaten);
    final ben = LiveGast(raum, spielerId: 'g1', daten: einflussDaten);
    await zeigeImThema(t, (_) => gastSeiteLive(ben));
    expect(find.byKey(const ValueKey('gast-moment-knopf')), findsNothing, reason: 'Der Erzähler zieht nicht');
    await zeigeImThema(t, (_) => gastSeiteLive(cleo));
    expect(find.byKey(const ValueKey('gast-moment-knopf')), findsOneWidget);
    await t.ensureVisible(find.byKey(const ValueKey('gast-moment-knopf')));
    await t.tap(find.byKey(const ValueKey('gast-moment-knopf')));
    await t.pump();
    expect(find.byKey(const ValueKey('gast-moment-offen')), findsOneWidget);
    expect(find.byKey(const ValueKey('stern-1')), findsOneWidget);
    await t.ensureVisible(find.byKey(const ValueKey('zug-helfen')));
    await t.tap(find.byKey(const ValueKey('zug-helfen')));
    await t.pump();
    await t.ensureVisible(find.byKey(const ValueKey('moment-bestaetigen')));
    await t.tap(find.byKey(const ValueKey('moment-bestaetigen')));
    await t.pump();
    expect(cleo.befehle.last.$1, {'typ': 'zug', 'art': 'helfen'});
    expect(cleo.befehle.last.$2, isNull);
    expect(_map(_map(raum.zustandFuer('g2')['privat'])['moment'])['zug'], {'art': 'helfen'});
    expect(find.byKey(const ValueKey('gast-moment-gezogen')), findsOneWidget);
    // Öffentlich steht nur, wer gezogen hat, nie was.
    final oeffentlich = _map(raum.zustandFuer('g3')['einfluss']);
    expect(oeffentlich['gezogen'], [_rolle(raum, 'g2')]);
    expect(oeffentlich.toString(), isNot(contains('helfen')));
  });

  testWidgets('Das Lauschergebnis sieht nur, wer lauschte', (t) async {
    final raum = _raum();
    _bisGespraeche(raum, 2, zuege: (r) => {
          'g2': {'art': 'lauschen', 'ziel': _rolle(r, 'g3')},
          'g3': {'art': 'decken', 'ziel': _rolle(r, 'g3')},
        });
    final g2 = _map(_map(raum.zustandFuer('g2')['privat'])['moment']);
    final g3 = _map(_map(raum.zustandFuer('g3')['privat'])['moment']);
    expect(g2['gelauscht'], isA<List>());
    expect(g3.containsKey('gelauscht'), isFalse);
    final cleo = LiveGast(raum, spielerId: 'g2', daten: einflussDaten);
    await zeigeImThema(t, (_) => gastSeiteLive(cleo));
    await t.ensureVisible(find.byKey(const ValueKey('gast-moment-knopf')));
    await t.tap(find.byKey(const ValueKey('gast-moment-knopf')));
    await t.pump();
    final text = einflussDaten.texte.einflussText('einfluss.privat.gelauscht', figur: _rolle(raum, 'g3'), ziel: _rolle(raum, 'g3'), zug: 'decken');
    expect(find.text(text), findsOneWidget);
    final dora = LiveGast(raum, spielerId: 'g3', daten: einflussDaten);
    await zeigeImThema(t, (_) => gastSeiteLive(dora));
    await t.ensureVisible(find.byKey(const ValueKey('gast-moment-knopf')));
    await t.tap(find.byKey(const ValueKey('gast-moment-knopf')));
    await t.pump();
    expect(find.text(text), findsNothing);
    expect(find.text(einflussDaten.texte.einflussText('einfluss.privat.haelt_zu_dir')), findsNothing, reason: 'Selbst-Decken meldet nichts');
  });

  testWidgets('Die Zug-Tafel sieht nur der Erzähler-Sitz', (t) async {
    final raum = _raum();
    _bisGespraeche(raum, 1);
    raum.nachricht('g2', {'typ': 'zug', 'art': 'helfen'});
    for (final id in ['gastgeber', 'g2', 'g3']) {
      expect(_map(raum.zustandFuer(id)['privat']).containsKey('einflussTafel'), isFalse, reason: id);
    }
    expect(_map(raum.zustandFuer('g1')['privat'])['einflussTafel'], isA<Map>());
    final ben = LiveGast(raum, spielerId: 'g1', daten: einflussDaten);
    await zeigeImThema(t, (_) => gastSeiteLive(ben));
    expect(find.byKey(const ValueKey('zug-tafel-erzaehler')), findsOneWidget);
    final cleo = LiveGast(raum, spielerId: 'g2', daten: einflussDaten);
    await zeigeImThema(t, (_) => gastSeiteLive(cleo));
    expect(find.byKey(const ValueKey('zug-tafel-erzaehler')), findsNothing);
  });

  testWidgets('Letzter Aufruf: Countdown, danach geht es ohne die fehlenden Züge weiter', (t) async {
    final raum = _raum();
    _bisGespraeche(raum, 1);
    befragungenImRaum(raum);
    var jetzt = 1000000;
    final ben = LiveGast(raum, spielerId: 'g1', daten: einflussDaten)..abendzeit = (() => jetzt);
    raum.nachricht('g2', {'typ': 'zug', 'art': 'helfen'});
    await zeigeImThema(t, (_) => gastSeiteLive(ben));
    // Dora fehlt: Weiter ruht, der Leiter gibt den letzten Aufruf.
    expect(find.byKey(const ValueKey('gast-moment-aufruf')), findsOneWidget);
    await t.ensureVisible(find.byKey(const ValueKey('gast-letzter-aufruf')));
    await t.tap(find.byKey(const ValueKey('gast-letzter-aufruf')));
    await t.pump();
    expect(ben.befehle.last.$2, isNull);
    expect(_map(raum.zustandFuer('g1')['einfluss'])['aufruf'], jetzt);
    final l = momentTexte(t.element(find.byKey(const ValueKey('gast-moment-aufruf'))));
    expect(find.text(l.moment_aufruf_laeuft(momentAufrufFrist ~/ 1000)), findsOneWidget);
    // Zu früh: Der Raum lehnt ab.
    expect(await ben.befehl({'typ': 'weiter'}), 'not_ready');
    jetzt += 20000;
    await t.pump(const Duration(seconds: 1));
    expect(find.text(l.moment_aufruf_laeuft((momentAufrufFrist - 20000) ~/ 1000)), findsOneWidget);
    jetzt += momentAufrufFrist;
    await t.pump(const Duration(seconds: 1));
    expect(find.byKey(const ValueKey('gast-aufruf-vorbei')), findsOneWidget);
    await t.ensureVisible(find.byKey(const ValueKey('gast-aufruf-weiter')));
    await t.tap(find.byKey(const ValueKey('gast-aufruf-weiter')));
    await t.pump();
    expect(raum.zustandFuer('gastgeber')['phase'], 'entscheidungen');
    // Dora hat abgewartet; die Rolle der App zog als Bot.
    final p = raum.partieFuerGastgeber!;
    final f = p.einfluss!.stand.folgenVon(1)!;
    expect(f.zuege[_rolle(raum, 'g3')]!.art, ZugArt.abgewartet);
    expect(f.zuege.values.where((z) => z.art == ZugArt.abgewartet), hasLength(1));
  });

  testWidgets('Ohne Schicht kein Knopf, kein Aufruf, keine Tafel', (t) async {
    final raum = _raum(einfluss: false);
    _bisGespraeche(raum, 1);
    expect(raum.zustandFuer('g2').containsKey('einfluss'), isFalse);
    final cleo = LiveGast(raum, spielerId: 'g2', daten: einflussDaten);
    await zeigeImThema(t, (_) => gastSeiteLive(cleo));
    expect(find.byKey(const ValueKey('gast-moment-knopf')), findsNothing);
    final ben = LiveGast(raum, spielerId: 'g1', daten: einflussDaten);
    await zeigeImThema(t, (_) => gastSeiteLive(ben));
    expect(find.byKey(const ValueKey('gast-moment-aufruf')), findsNothing);
    expect(find.byKey(const ValueKey('zug-tafel-erzaehler')), findsNothing);
  });

  test('Gastgeber als Erzähler: Lage, Zug-Tafel und letzter Aufruf aus dem Raum', () async {
    final raum = _raum(gastgeberErzaehler: true);
    _bisGespraeche(raum, 1, leiter: 'gastgeber', detektiv: 'g1');
    befragungenImRaum(raum, detektiv: 'g1');
    final s = GastgeberSitzung(SitzDienst(raum, daten: einflussDaten));
    addTearDown(s.dispose);
    expect(s.einfluss, isTrue);
    expect(s.leitet, isTrue);
    expect(s.momentOffen, unorderedEquals([_rolle(raum, 'g2'), _rolle(raum, 'g3')]));
    raum.nachricht('g2', {'typ': 'zug', 'art': 'helfen'});
    expect(s.momentOffen, [_rolle(raum, 'g3')]);
    expect(s.momentGezogen(_rolle(raum, 'g2')), isTrue);
    expect(s.kannWeiter, isFalse, reason: 'Dora fehlt noch');
    // Die Zug-Tafel kommt privat vom Raum: der Erzähler sieht, wer was spielte.
    expect([for (final z in s.einflussTafel!.zuege) (z.rolle, z.art)], [(_rolle(raum, 'g2'), ZugArt.helfen)]);
    expect(() => s.momentZeigen(_rolle(raum, 'g3')), throwsStateError, reason: 'Online ziehen die Gäste');
    s.letzterAufruf();
    await pumpEventQueue();
    expect(s.momentAufruf, isNotNull);
    expect(s.momentFertig, isFalse, reason: 'Die Frist läuft noch');
    expect(s.einflussLage!.aufruf, s.momentAufruf);
  });

  test('Wer den Abend verlässt, zieht als Bot: Der Gastgeber wartet nicht auf ihn, ein getrenntes Gerät bleibt offen', () async {
    final raum = _raum(gastgeberErzaehler: true);
    _bisGespraeche(raum, 1, leiter: 'gastgeber', detektiv: 'g1');
    befragungenImRaum(raum, detektiv: 'g1');
    final s = GastgeberSitzung(SitzDienst(raum, daten: einflussDaten));
    addTearDown(s.dispose);
    final cleo = LiveGast(raum, spielerId: 'g2', daten: einflussDaten);
    final dora = _rolle(raum, 'g3');
    raum.nachricht('g2', {'typ': 'zug', 'art': 'helfen'});
    // Dora ist nur getrennt: Auf sie wartet der Raum noch.
    raum.verbunden('g3', false);
    expect(s.momentOffen, [dora]);
    expect([s.momentFertig, s.kannWeiter, raum.zustandFuer('gastgeber')['kannWeiter']], [false, false, false]);
    expect(_map(cleo.ansicht['einfluss'])['offen'], [dora], reason: 'Gäste lesen dieselbe Liste (gastMomentOffen)');
    // Dora verlässt den Abend: Ihre Figur zieht als Bot, niemand muss den letzten Aufruf geben.
    raum.verlassen('g3');
    expect(raum.zustandFuer('gastgeber')['kannWeiter'], isTrue);
    expect(s.momentOffen, isEmpty);
    expect([s.momentFertig, s.kannWeiter], [true, true]);
    expect(_map(raum.zustandFuer('g2')['einfluss'])['offen'], isEmpty, reason: 'Für alle Geräte gleich');
    s.weiter();
    await pumpEventQueue();
    expect(raum.zustandFuer('gastgeber')['phase'], 'entscheidungen');
    expect(raum.partieFuerGastgeber!.einfluss!.stand.folgenVon(1)!.zuege[dora]!.art, isNot(ZugArt.abgewartet), reason: 'Der Bot zog für Dora');
  });

  testWidgets('Pult der Gastgeberin: Wer noch zieht, steht mit Namen da; nach den Befragungen kein „befragt den Tisch“', (t) async {
    final raum = _raum(gastgeberErzaehler: true);
    _bisGespraeche(raum, 1, leiter: 'gastgeber', detektiv: 'g1');
    befragungenImRaum(raum, detektiv: 'g1');
    final s = GastgeberSitzung(SitzDienst(raum, daten: einflussDaten));
    addTearDown(s.dispose);
    await zeigeImThema(t, (_) => ErzaehlerPultOnline(sitzung: s), ruhig: true);
    final l = momentTexte(t.element(find.byType(ErzaehlerPultOnline)));
    for (final (g, name) in [('g2', 'Cleo'), ('g3', 'Dora')]) {
      expect(find.text('$name: ${l.moment_offen}'), findsOneWidget, reason: g);
    }
    expect(find.text(l.moment_zeile(l.moment_offen)), findsNothing, reason: 'Nie ohne Namen');
    expect(find.text(LDe().erzaehler_befragt), findsNothing, reason: 'Die Befragungen sind durch, es fehlen nur Züge');
    raum.nachricht('g2', {'typ': 'zug', 'art': 'helfen'});
    s.notifyListeners();
    await t.pump();
    expect(find.text('Cleo: ${l.moment_offen}'), findsNothing);
    expect(find.text('Dora: ${l.moment_offen}'), findsOneWidget);
    await t.pumpWidget(const SizedBox.shrink());
  });
}
