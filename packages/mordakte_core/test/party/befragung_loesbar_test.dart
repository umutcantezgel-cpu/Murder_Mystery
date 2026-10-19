// A-051 (M2a): Der Schlosskeller ist im Modell befragung für 4 bis 20 Rollen und alle vier Pfade lösbar. Der Detektiv
// erfährt nur, was die festen Befragungen preisgeben, was der Erzähler über unbesetzte Gäste sagt (npcPlan, seit E-044
// auch über unbesetzte Zielfiguren) und was die richtigen Optionen aufdecken. Eine NPC-Karte mit dem Wissen der
// Zielfigur gibt es nicht: Die Fundkarte zeigt nur die Fakten der Option. Freie Wahlen zählen nicht mit: Wer sie
// verschenkt, löst den Fall trotzdem.
import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/runden.dart';
import 'package:test/test.dart';

import 'kanon_hilfe.dart';

final _texte = Texte(kanon, Textsammlung.lade((p) => leseJson('$repoWurzel/content/party/schlosskeller/$p')));
final _plan = Befragungsplan(_texte);
final _erm = Ermittlung(kanon);
final _erz = Erzaehler(kanon);

/// Ein Abend mit bestem Spiel: Fehlt einer Entscheidung ein Glied ihrer Kette, steht es in der Liste.
/// Mit [befragen] false lässt der Detektiv auch die festen Befragungen aus (Rot-Probe). Mit [erzaehler] false
/// spricht der Erzähler nicht über unbesetzte Zielfiguren (Rot-Probe für E-044).
List<String> _abend(int n, String pfad, {bool befragen = true, bool erzaehler = true}) {
  final f = <String>[];
  final besetzung = _texte.besetzung;
  final bekannt = <String>{
    for (final x in kanon.figuren) 'merkmal:${x['id']}',
    for (final g in kanon.gegenstaende) if (g['sichtbar'] == true) 'karte:${g['id']}',
    for (final b in kanon.beobachtungen) if (b['kanal'] == 'erzaehler') 'beobachtung:${b['id']}',
  };
  final ziele = {
    for (final e in _erm.entscheidungen)
      for (final o in e.optionen)
        if (o.ziel['person'] case final String p) p,
  };
  for (var r = 1; r <= 3; r++) {
    final br = _plan.fuer(n, r);
    // Feste Befragungen: Die Antwort entsteht aus der Preisgabe; die gewählte Frage ändert nichts.
    for (final x in befragen ? br.pflicht : const <String>[]) {
      final b = br.text(x);
      expect(botAntwort(_texte, b), hasLength(b.preisgabe.length));
      bekannt.addAll(b.preisgabe);
    }
    // Erzähler zum Rundenstart: Wissen unbesetzter Gäste.
    for (final k in _erz.npcWissen(r, besetzt: (x) => besetzung.istBesetzt(x, n))) {
      final figur = k.split('.')[1];
      if (!erzaehler && ziele.contains(figur)) continue;
      bekannt.addAll([for (final b in _erz.npcPlan[r]![figur]!) 'beobachtung:$b']);
    }
    for (final e in _erm.runde(r)) {
      for (final k in e.begruendungFuer(pfad)!.kette) {
        if (!bekannt.contains(k)) f.add('$n Rollen, $pfad, ${e.id}: $k fehlt');
      }
      for (final fakt in _erm.faktenVon(e.richtig[pfad]!, pfad)) {
        bekannt.add('fakt:$fakt');
        if (_erm.fakten[fakt]!.beobachtung case final String b) bekannt.add('beobachtung:$b');
      }
    }
  }
  return f;
}

void main() {
  for (var n = 4; n <= 20; n++) {
    test('$n Rollen, alle vier Pfade: jede Kette rechtzeitig, bestes Spiel endet als Meister-Detektiv', () {
      for (final pfad in kanon.pfade) {
        final f = _abend(n, pfad);
        expect(f, isEmpty, reason: f.join('\n'));
        final s = Spiel(kanon, ermittlung: _erm)
          ..einrichten(Einstellungen(rollen: n, detektiv: n.isEven ? 'm' : 'w', code: FallCode.fuerPfad(pfad, kanon.pfade)));
        while (s.phase != PartyPhase.anklage) {
          if (s.phase == PartyPhase.entscheidungen) {
            for (final x in _erm.runde(s.runde)) {
              s.waehle(x.id, x.richtig[pfad]!);
            }
          }
          if (s.phase == PartyPhase.gruppenwahl) s.abstimmen(kooperativ: n - 1, taeterSabotiert: false);
          s.weiter();
        }
        expect(s.restmenge(), {pfad}, reason: '$n Rollen, $pfad');
        s.anklagen(pfad);
        expect(s.ende.id, 'ende_meister', reason: '$n Rollen, $pfad');
      }
    });
  }

  // E-044: Die Fundkarte einer Zielfigur zeigt nur die Fakten der Option, nicht das Pflichtgespräch-Wissen der Figur.
  // Im Modell befragung spricht der Erzähler es deshalb zum Rundenstart, solange niemand die Figur spielt.
  test('Ohne die Annahme „NPC-Karte“ erreicht jedes Kettenglied den Detektiv', () {
    for (var n = 4; n <= 20; n++) {
      for (final pfad in kanon.pfade) {
        final f = _abend(n, pfad);
        expect(f, isEmpty, reason: f.join('\n'));
      }
    }
  });

  test('Rot-Probe (E-044): ohne den Erzähler für Zielfiguren fehlt deren Wissen bei kleiner Besetzung', () {
    final f = _abend(4, 'ahmet', erzaehler: false);
    expect(f, containsAll([
      '4 Rollen, ahmet, e1_1: beobachtung:b_damir_an_der_theke fehlt',
      '4 Rollen, ahmet, e1_2: beobachtung:b_emine_versteck fehlt',
      '4 Rollen, ahmet, e1_3: beobachtung:b_azra_versteck fehlt',
      '4 Rollen, ahmet, e2_2: beobachtung:b_azra_tasche fehlt',
      '4 Rollen, ahmet, e3_3: beobachtung:b_zeynep_gesicht fehlt',
    ]));
    expect(_abend(4, 'can', erzaehler: false), contains('4 Rollen, can, e3_3: beobachtung:b_aylin_quittung fehlt'));
    // Bei 20 Rollen spielt jemand jede Zielfigur; der Erzähler schweigt, die Befragungen tragen alles.
    expect(_abend(20, 'ahmet', erzaehler: false), isEmpty);
  });

  test('Rot-Probe: ohne die festen Befragungen fehlen Kettenglieder', () {
    final f = _abend(20, 'fatma', befragen: false);
    expect(f, contains('20 Rollen, fatma, e2_1: luege:luege_ahmet_servietten fehlt'));
    expect(f, contains('20 Rollen, fatma, e1_1: beobachtung:b_damir_an_der_theke fehlt'));
    // Bei 4 Rollen trägt der Erzähler das Wissen der Unbesetzten; nur die Lügen der Kernrollen fehlen dann.
    expect(_abend(4, 'fatma', befragen: false).every((x) => x.contains('luege:')), isTrue);
  });
}
