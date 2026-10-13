// Testhilfe für die Party-Bildschirme (F4): Sitzung aus den Repo-Dateien,
// Rahmen mit MaterialApp. Tests laufen im Repo-Wurzelordner.
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/runden.dart';
import 'package:mordakte/party/daten.dart';
import 'package:mordakte/party/sitzung.dart';

PartyDaten? _daten;

/// Einmal geladene Daten des Schlosskellers.
PartyDaten get partyDaten => _daten ??= PartyDaten.aus(
      (p) => jsonDecode(File('content/party/schlosskeller/$p').readAsStringSync()) as Map<String, Object?>,
      jsonDecode(File('content/scenarios/ravensmoor.json').readAsStringSync()) as Map<String, dynamic>,
    );

final _akten = <String, PartyDaten>{};

/// Einmal geladene Daten einer anderen Akte (fehlende Oberflächentexte aus dem
/// Schlosskeller, Gespräche mit Wahl aus `content/erzaehlung`, wenn vorhanden).
PartyDaten akteDaten(String fall) => _akten[fall] ??= () {
      Map<String, Object?> lies(String ordner, String p) => jsonDecode(File('$ordner/$p').readAsStringSync()) as Map<String, Object?>;
      final erzaehlung = File('content/erzaehlung/$fall/gespraeche.json');
      return PartyDaten.aus(
        (p) => lies('content/party/$fall', p),
        jsonDecode(File('content/scenarios/ravensmoor.json').readAsStringSync()) as Map<String, dynamic>,
        fall: fall,
        basis: (p) => lies('content/party/schlosskeller', p),
        erzaehlung: erzaehlung.existsSync() ? jsonDecode(erzaehlung.readAsStringSync()) as Map<String, Object?> : null,
      );
    }();

/// Neue Sitzung, auf Wunsch schon eingerichtet ([rollen] Personen, Pfad [pfad]).
PartySitzung neueSitzung({int? rollen, String pfad = 'ahmet', String detektiv = 'w', bool solo = false,
    String? salz, WuerfelQuelle wuerfel = const FesterWuerfel.neutral()}) {
  final s = PartySitzung(partyDaten, wuerfel: wuerfel, salz: salz);
  if (rollen != null) s.einrichten(rollen: rollen, detektiv: detektiv, solo: solo, code: FallCode.fuerPfad(pfad, partyDaten.kanon.pfade).code);
  return s;
}

/// Spielt bis zur Phase [ziel] vor (Entscheidungen: beste Wahl, Gruppe: alle A).
void spieleBis(PartySitzung s, PartyPhase ziel, {int? runde}) {
  while (s.phase != ziel || (runde != null && s.runde != runde) || (ziel == PartyPhase.entscheidungen && s.zug?.istAuftakt == true)) {
    switch (s.phase) {
      case PartyPhase.titel:
        s.zurEinrichtung();
      case PartyPhase.einrichtung:
        s.einrichten(rollen: 7, detektiv: 'w', code: FallCode.fuerPfad('ahmet', s.kanon.pfade).code);
      case PartyPhase.gespraeche:
        for (final g in s.soloGespraeche) { s.soloGespraechGelesen(g.id); }
        s.weiter();
      case PartyPhase.entscheidungen:
        if (s.zug != null) {
          spieleZug(s);
          continue;
        }
        final e = s.laufendeEntscheidung;
        if (e == null) {
          s.weiter();
        } else {
          s.schlageVor(e.richtig[s.spiel.pfad]!);
          s.bestaetigen();
          spieleZug(s);
        }
      case PartyPhase.gruppenwahl:
        if (s.offeneWaehler.isEmpty) {
          s.weiter();
        } else {
          final r = s.offeneWaehler.first;
          s.zeigeVerdeckt(r);
          s.stimme(r, kooperativ: true);
        }
      case PartyPhase.anklage:
        if (s.angeklagt == null) s.anklagen(s.spiel.pfad);
        s.weiter();
      case PartyPhase.ende:
        throw StateError('Phase $ziel nicht erreicht');
      default:
        s.weiter();
    }
  }
}

/// Treiber für Sitzungs-/Widgettests: alle Zugphasen, niemals Würfel abschalten.
/// Der Renderer selbst und seine tatsächlichen Wege werden gesondert geprüft.
void spieleZug(PartySitzung s, {bool lesen = true}) {
  for (var i = 0; i < 12; i++) {
    final z = s.zug;
    if (z == null) { if (s.letzterFund != null && lesen) s.fundGelesen(); return; }
    switch (z.phase) {
      case RundenZugPhase.aktion: s.aktionFertig(z.aktion);
      case RundenZugPhase.wurf: s.wuerfeln();
      case RundenZugPhase.tischruf: s.tischruf(Tischruf.umweg);
      case RundenZugPhase.fund:
        if (lesen) s.fundGelesen();
        return;
    }
  }
  throw StateError('Zug nicht beendet');
}

/// Bildschirm in einer MaterialApp mit festem Format (Querformat 1280 × 800).
Widget rahmen(Widget kind) => MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: Scaffold(body: kind),
    );

/// Lädt die echten Schriften der App (statt der Testschrift Ahem), damit Breiten
/// und Bilder wie auf dem Gerät ausfallen. Einmal je Testdatei in `setUpAll`.
Future<void> echteSchriften() async {
  final schriften = {
    'SpecialElite': ['SpecialElite-Regular.ttf'],
    'Inter': ['Inter-Regular.ttf', 'Inter-SemiBold.ttf', 'Inter-Bold.ttf'],
    'Playfair': ['PlayfairDisplay-Variabel.ttf'],
    'Lora': ['Lora-Variabel.ttf', 'Lora-Kursiv-Variabel.ttf'],
    'CourierPrime': ['CourierPrime-Regular.ttf'],
    'Caveat': ['Caveat-Variabel.ttf'],
  };
  for (final e in schriften.entries) {
    final l = FontLoader(e.key);
    for (final d in e.value) {
      l.addFont(rootBundle.load('assets/fonts/$d'));
    }
    await l.load();
  }
}
