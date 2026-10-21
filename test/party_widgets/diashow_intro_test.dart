// Langer Abend M4: Diashow zur Einleitung an einem Gerät. Solo und reihum ohne
// Begleiter hält der Vorleser das Gerät: oben das Bild, darunter nur der Text
// dazu; „Nächstes Bild“ schaltet beide weiter. Akten ohne diashow.json zeigen
// die Einleitung wie bisher. (Mit Erzähler-Begleiter: erzaehler_begleiter_test.)
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte/party/bildschirme/intro.dart';
import 'package:mordakte/party/diashow_ansicht.dart';
import 'package:mordakte/party/sitzung.dart';
import 'package:mordakte/party/stimme.dart';
import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/runden.dart' show FesterWuerfel;

import 'hilfe.dart';

/// Das Intro von [s] auf [groesse], mit Schriftfaktor [schrift] und auf Wunsch „Bewegung reduzieren“.
Future<void> _zeige(WidgetTester t, PartySitzung s, {Size groesse = const Size(390, 844), double schrift = 1, bool ruhig = false}) async {
  t.view.physicalSize = groesse;
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.resetPhysicalSize);
  addTearDown(t.view.resetDevicePixelRatio);
  await t.pumpWidget(rahmen(Builder(
    builder: (context) => MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(schrift), disableAnimations: ruhig),
      child: IntroBildschirm(sitzung: s),
    ),
  )));
}

/// Der Anfang des Bausteins [k], wie er auf dem Bildschirm steht.
Finder _text(PartySitzung s, String k) {
  final text = s.text(k);
  return find.textContaining(text.substring(0, text.length < 30 ? text.length : 30));
}

/// Eine Stimme, die jeden Text erst beendet, wenn der Test es sagt ([fertig]).
class _Stimme extends Stimme {
  final gesprochen = <String>[];
  final _laeuft = <Completer<bool>>[];

  @override
  bool get verfuegbar => true;

  @override
  Future<bool> sprich(String text) {
    gesprochen.add(text);
    final c = Completer<bool>();
    _laeuft.add(c);
    return c.future;
  }

  @override
  void stopp() {
    for (final c in _laeuft) {
      if (!c.isCompleted) c.complete(false);
    }
    _laeuft.clear();
  }

  /// Der laufende Text ist zu Ende gelesen.
  void fertig() => _laeuft.removeAt(0).complete(true);
}

Future<void> _naechstes(WidgetTester t) async {
  await t.ensureVisible(find.byKey(const ValueKey('dia-naechstes')));
  await t.tap(find.byKey(const ValueKey('dia-naechstes')));
  await t.pump(const Duration(milliseconds: 700));
}

void main() {
  testWidgets('Solo mit Diashow: oben das Bild, darunter nur der Text dazu; „Nächstes Bild“ schaltet beide, am Ende führt Weiter in die Runde', (t) async {
    final s = neueSitzung(rollen: 4, solo: true, daten: diashowDaten);
    spieleBis(s, PartyPhase.intro);
    final kennungen = s.erzaehler;
    expect(kennungen, hasLength(6));
    await _zeige(t, s);
    for (var i = 0; i < kennungen.length; i++) {
      expect(s.dia, i);
      expect(find.byType(DiashowAnsicht), findsOneWidget);
      expect(find.text(s.ui('ui.intro.bild', {'nr': '${i + 1}', 'anzahl': '6'}).toUpperCase()), findsOneWidget);
      for (var j = 0; j < kennungen.length; j++) {
        expect(_text(s, kennungen[j]), j == i ? findsOneWidget : findsNothing, reason: 'Bild $i, Text $j');
      }
      expect(t.getTopLeft(find.byType(DiashowAnsicht)).dy, lessThan(t.getTopLeft(_text(s, kennungen[i])).dy), reason: 'Das Bild steht über dem Text');
      if (i < kennungen.length - 1) await _naechstes(t);
    }
    expect(find.byKey(const ValueKey('dia-naechstes')), findsNothing, reason: 'Am letzten Bild bleibt nur Weiter');
    await t.ensureVisible(find.text(s.ui('ui.intro.weiter')));
    await t.tap(find.text(s.ui('ui.intro.weiter')));
    await t.pump();
    expect(s.phase, isNot(PartyPhase.intro));
    expect(t.takeException(), isNull);
    await t.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Mit Stimme: Ist ein Text gelesen, schalten Bild und Text zusammen weiter; von Hand liest sie ab dem neuen Bild', (t) async {
    final stimme = _Stimme();
    Stimme.testStimme = () => stimme;
    addTearDown(() => Stimme.testStimme = null);
    final s = neueSitzung(rollen: 4, solo: true, daten: diashowDaten);
    spieleBis(s, PartyPhase.intro);
    s.stimmeAn = true;
    final texte = [for (final k in s.erzaehler) s.text(k)];
    await _zeige(t, s);
    await t.pump();
    expect(stimme.gesprochen, [texte[0]]);
    // Die Stimme ist mit dem ersten Text fertig: Sie meldet den nächsten Baustein, das Bild folgt.
    stimme.fertig();
    await t.pump(const Duration(milliseconds: 700));
    expect(s.dia, 1);
    expect(_text(s, s.erzaehler[1]), findsOneWidget);
    expect(stimme.gesprochen, [texte[0], texte[1]], reason: 'Kein zweiter Anlauf für denselben Text');
    // Von Hand weitergeschaltet: Die Stimme bricht ab und liest ab dem neuen Bild.
    await _naechstes(t);
    expect(s.dia, 2);
    expect(stimme.gesprochen.last, texte[2]);
    expect(stimme.gesprochen.where((x) => x == texte[2]), hasLength(1));
    await t.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Reihum ohne Begleiter: Das Gerät zeigt Bild und Text, der Vorleser hält es', (t) async {
    final s = neueSitzung(rollen: 7, daten: diashowDaten);
    spieleBis(s, PartyPhase.intro);
    expect([s.solo, s.istVorleser, s.diaSteuerbar], [false, true, true]);
    final kennungen = s.erzaehler;
    await _zeige(t, s);
    expect(find.byType(DiashowAnsicht), findsOneWidget);
    expect(_text(s, kennungen[0]), findsOneWidget);
    await _naechstes(t);
    expect(_text(s, kennungen[0]), findsNothing);
    expect(_text(s, kennungen[1]), findsOneWidget);
    await t.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Diashow schmal, mit doppelter Schrift und „Bewegung reduzieren“: kein Überlauf, der Wechsel ist ein Schnitt', (t) async {
    final s = neueSitzung(rollen: 4, solo: true, daten: diashowDaten);
    spieleBis(s, PartyPhase.intro);
    await _zeige(t, s, groesse: const Size(320, 640), schrift: 2, ruhig: true);
    expect(t.takeException(), isNull);
    await t.ensureVisible(find.byKey(const ValueKey('dia-naechstes')));
    await t.tap(find.byKey(const ValueKey('dia-naechstes')));
    await t.pump();
    expect(find.text(s.ui('ui.intro.bild', {'nr': '2', 'anzahl': '6'}).toUpperCase()), findsOneWidget);
    expect(_text(s, s.erzaehler[1]), findsOneWidget);
    expect(t.takeException(), isNull);
    await t.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Akten ohne diashow.json: Die Einleitung bleibt wie bisher, alle Texte, kein Bild', (t) async {
    for (final d in [partyDaten, akteDaten('gewoelbe')]) {
      expect(d.diashow, isNull);
      final s = PartySitzung(d, wuerfel: const FesterWuerfel.neutral())
        ..einrichten(rollen: 4, detektiv: 'w', solo: true, code: FallCode.fuerPfad(d.kanon.pfade.first, d.kanon.pfade).code);
      spieleBis(s, PartyPhase.intro);
      await _zeige(t, s);
      expect(find.byType(DiashowAnsicht), findsNothing, reason: d.fall);
      expect(find.byKey(const ValueKey('dia-naechstes')), findsNothing, reason: d.fall);
      for (final k in s.erzaehler.where(s.hatText)) {
        expect(_text(s, k), findsOneWidget, reason: '${d.fall}: $k');
      }
      await t.pumpWidget(const SizedBox.shrink());
    }
  });
}
