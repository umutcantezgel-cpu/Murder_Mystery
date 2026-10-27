// Erschöpfender Simulator für den Partymodus (F-06, F-07, F-08).
//
//   dart run bin/party_simulate.dart            Bericht und Prüfung
//   dart run bin/party_simulate.dart --pruefen  nur Prüfung, Exitcode 1 bei Verstoß
//   dart run bin/party_simulate.dart --einfluss [--salze N]
//                                               Bericht der Einfluss-Schicht (Finale §3, Feinabstimmung)
import 'dart:convert';
import 'dart:io';

import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/runden.dart';

Map<String, Object?> _lies(String wurzel, String p) => jsonDecode(File('$wurzel/$p').readAsStringSync()) as Map<String, Object?>;

String _wurzel() {
  var d = Directory.current;
  while (!Directory('${d.path}/content/party').existsSync()) {
    final p = d.parent;
    if (p.path == d.path) throw StateError('content/party nicht gefunden');
    d = p;
  }
  return '${d.path}/content/party/schlosskeller';
}

void main(List<String> args) {
  final uhr = Stopwatch()..start();
  final w = _wurzel();
  final kanon = Kanon.lade((p) => _lies(w, p));
  if (args.contains('--einfluss')) {
    final i = args.indexOf('--salze');
    _einflussBericht(kanon, w, salze: i >= 0 && i + 1 < args.length ? int.parse(args[i + 1]) : 250);
    stdout.writeln('(${uhr.elapsedMilliseconds} ms)');
    return;
  }
  final sim = Simulator(kanon);
  final verstoesse = [...sim.pruefe(), ...sim.pruefeSchwellen()];
  if (!args.contains('--pruefen')) {
    final berichte = sim.auszaehlen();
    final folgen = sim.folgen().length;
    stdout.writeln('Simulator · ${kanon.fall['titel']} · $folgen Optionsfolgen je Pfad × ${kanon.kernverdaechtige.length} Anklagen');
    stdout.writeln('Gruppenergebnisse ändern die Restmenge nie (W-1); geprüft über alle Hinweise.\n');
    for (final b in berichte.values) {
      stdout.writeln('Pfad ${b.pfad}: ${b.spiele} Spiele');
      stdout.writeln('  Enden: ${[for (final e in sim.enden.regeln) '${e.name} ${b.enden[e.id] ?? 0}'].join(' · ')}');
      stdout.writeln('  Punkte: ${[for (var p = 0; p <= 9; p++) '$p:${b.punkte[p] ?? 0}'].join(' ')}');
      stdout.writeln('  Restmenge nach Runde 3: ${[for (var n = 1; n <= 4; n++) '$n:${b.restGroesse[n] ?? 0}'].join(' ')}');
      stdout.writeln('  Rate-Enden (Anklage außerhalb der Restmenge): ${b.rateEnden}; Treffer trotz Restmenge > 1: ${b.rateTreffer}');
      stdout.writeln('  Restmenge 1 mit weniger als 9 Punkten: ${b.kuerzerAlsBest} Folgen');
      final best = sim.verlauf(b.pfad, sim.ermittlung.bestesSpiel(b.pfad));
      stdout.writeln('  Bestes Spiel: Restmenge nach Runde 1/2/3 = ${best.restNachRunde.map((r) => r.length).join('/')}');
    }
    stdout.writeln('Ratestrategien (Kanon-Reihenfolge; die App mischt die Anzeige je Fall-Code), Punkte je Pfad:');
    final e = sim.ermittlung.entscheidungen;
    final strategien = <String, List<String> Function(String)>{
      'immer erste Option': (p) => [for (final x in e) x.optionen.first.id],
      'immer letzte Option': (p) => [for (final x in e) x.optionen.last.id],
      'immer Person, sonst erste': (p) => [for (final x in e) (x.optionen.where((o) => o.ziel.containsKey('person')).firstOrNull ?? x.optionen.first).id],
    };
    for (final s in strategien.entries) {
      stdout.writeln('  ${s.key}: ${[for (final p in kanon.pfade) '$p ${sim.verlauf(p, s.value(p)).punkte}'].join(' · ')}');
    }
    // Feste Folgen ohne Pfadwissen (E-039 zu F6-GEGEN-03 Nr. 1): Wer den Fall
    // mehrfach spielt, kann eine Folge lernen. Bericht, kein Verstoß.
    var besteMin = -1;
    List<String>? besteFolge;
    var alleMeister = 0;
    for (final f in sim.folgen()) {
      final pk = [for (final p in kanon.pfade) sim.verlauf(p, f).punkte];
      final mn = pk.reduce((a, b) => a < b ? a : b);
      if (mn >= 7) alleMeister++;
      if (mn > besteMin) {
        besteMin = mn;
        besteFolge = f;
      }
    }
    stdout.writeln('  beste feste Folge ohne Pfadwissen: ${[for (final p in kanon.pfade) '$p ${sim.verlauf(p, besteFolge!).punkte}'].join(' · ')}; feste Folgen mit 7 Punkten in allen Pfaden: $alleMeister');
    stdout.writeln('');
  }
  stdout.writeln(verstoesse.isEmpty ? 'Simulator: OK (${uhr.elapsedMilliseconds} ms)' : 'Simulator: ${verstoesse.length} Verstöße');
  for (final v in verstoesse) {
    stdout.writeln('  - $v');
  }
  exitCode = verstoesse.isEmpty ? 0 : 1;
}

// ---------------------------------------------------------------- Einfluss-Schicht (Finale §3, Stufe 5)

/// Detektiv im Bericht. [zufaellig]: Wahl, „gründlich“, Marke, Tischruf und Anklage (aus der öffentlichen
/// Restmenge) gezogen. [einfach]: immer die erste angezeigte Option, nie gründlich, Marke wenn möglich, immer
/// „Nochmal“, Anklage der ersten Verdächtigen der Restmenge.
enum _Detektiv { zufaellig, einfach }

/// Zählstand einer Zelle (Pfad × Rollenzahl).
class _Zelle {
  final Map<String, int> meister = {}, abendeJe = {};
  int abende = 0, suchen = 0, verwischt = 0, zusatzfunde = 0, ertappt = 0, nachfragen = 0, zusammenhalt = 0, spuk = 0;
  final Map<int, int> tischbonus = {};
  final List<int> rest = [0, 0, 0];

  void meisterZaehlen(String art, bool ja) {
    abendeJe[art] = (abendeJe[art] ?? 0) + 1;
    if (ja) meister[art] = (meister[art] ?? 0) + 1;
  }

  String quote(String art) => _prozent(meister[art] ?? 0, abendeJe[art] ?? 0);
}

String _prozent(int a, int b) => b == 0 ? '–' : '${(100 * a / b).toStringAsFixed(1).replaceAll('.', ',')} %';
String _schnitt(int a, int b) => b == 0 ? '–' : (a / b).toStringAsFixed(2).replaceAll('.', ',');

/// Ein Fall-Code für [pfad], gezogen aus dem Strom des Salzes (damit Anzeige-Reihenfolgen wechseln).
FallCode _codeFuer(String pfad, List<String> pfade, String salz) {
  final r = Rng(Rng.hashString('sim-code:$salz'));
  while (true) {
    final c = FallCode.zufall(r);
    if (c.pfad(pfade) == pfad) return c;
  }
}

/// Ein Abend am Bot-Tisch, mit oder ohne Schicht ([regeln]); gibt die Partie zurück.
RundenPartie _botAbend(Kanon kanon, Ermittlung erm, EinflussRegeln? regeln, String pfad, int n, String salz, _Detektiv d) {
  final p = RundenPartie(kanon, quelle: SalzWuerfel(salz), ermittlung: erm, einfluss: regeln)
    ..einrichten(Einstellungen(rollen: n, detektiv: 'w', code: _codeFuer(pfad, kanon.pfade, salz)));
  final r = Rng(Rng.hashString('sim-detektiv:$salz'));
  for (var schritte = 0; p.phase != PartyPhase.ende; schritte++) {
    if (schritte > 400) throw StateError('Sackgasse: $salz');
    if (p.zug case final z?) {
      switch (z.phase) {
        case RundenZugPhase.aktion:
          p.aktionFertig(z.aktion);
        case RundenZugPhase.wurf:
          p.wuerfeln(marke: d == _Detektiv.einfach || r.chance(0.5));
        case RundenZugPhase.tischruf:
          p.tischruf(d == _Detektiv.einfach || r.chance(0.5) ? Tischruf.nochmal : Tischruf.umweg);
        case RundenZugPhase.fund:
          p.fundGelesen();
      }
    } else if (p.naechsteEntscheidung case final e?) {
      final optionen = p.spiel.optionen(e.id);
      final o = d == _Detektiv.einfach ? optionen.first : optionen[r.nextInt(optionen.length)];
      p.waehle(o.id, gruendlich: d == _Detektiv.zufaellig && istSuche(e) && r.chance(0.25));
    } else {
      if (p.phase == PartyPhase.gruppenwahl) {
        // Ohne Schicht: Bot-Stimmen wie am Tisch (K-20), die Täterrolle sabotiert mit B.
        final stimmen = {for (final rolle in p.spiel.besetzt) rolle: botKooperativ(salz: salz, rolle: rolle, runde: p.runde)};
        p.abstimmen(
          kooperativ: stimmen.entries.where((x) => x.key != p.spiel.pfad && x.value).length,
          taeterSabotiert: stimmen[p.spiel.pfad] == false,
        );
      }
      if (p.phase == PartyPhase.anklage) {
        while (p.nachfragenOffen > 0 && p.nachfrageOptionen.isNotEmpty) {
          p.nachfrage(p.nachfrageOptionen.first);
        }
        final rest = [for (final k in kanon.kernverdaechtige) if (p.spiel.restmenge().contains(k)) k];
        p.anklagen(d == _Detektiv.einfach ? rest.first : rest[r.nextInt(rest.length)]);
      }
      p.weiter();
    }
  }
  return p;
}

/// Bericht der Einfluss-Schicht je Pfad und Rollenzahl über [salze] Salze am Bot-Tisch: Meister-Quote für den
/// zufälligen und den einfachen Detektiv (mit und ohne Schicht), Anteil verwischter Suchen, Zusatzfunde,
/// Ertappte, Nachfragen, Tischbonus, Leisten und Minuten am Rundenende, dazu die Ziel-Erreichung je Figur.
void _einflussBericht(Kanon kanon, String akte, {required int salze}) {
  final datei = File('${Directory(akte).parent.path}/zusatz/schlosskeller/einfluss.json');
  final erm = Ermittlung(kanon);
  final regeln = EinflussRegeln.ausJson(jsonDecode(datei.readAsStringSync()) as Map<String, Object?>, erm);
  final ziele = EinflussZiele.aus(regeln);
  const rollen = [4, 7, 12, 20];
  final zielZahl = <String, List<int>>{for (final f in regeln.figuren) f: [0, 0, 0]};
  final zielJePfad = <String, Map<String, List<int>>>{for (final p in kanon.pfade) p: {for (final f in regeln.figuren) f: [0, 0, 0]}};
  stdout.writeln('Einfluss-Schicht · ${kanon.fall['titel']} · Bot-Tisch, $salze Salze je Pfad und Rollenzahl, Salz-Würfel');
  stdout.writeln('Meister-Quote: mit Schicht (ohne Schicht in Klammern, gleiche Salze und Detektivzüge).\n');
  for (final pfad in kanon.pfade) {
    for (final n in rollen) {
      final z = _Zelle();
      for (var i = 0; i < salze; i++) {
        final salz = 'einfluss-sim:$pfad:$n:$i';
        for (final d in _Detektiv.values) {
          final ohne = _botAbend(kanon, erm, null, pfad, n, salz, d);
          z.meisterZaehlen('${d.name}-ohne', ohne.spiel.ende.id == 'ende_meister');
          final p = _botAbend(kanon, erm, regeln, pfad, n, salz, d);
          z.meisterZaehlen(d.name, p.spiel.ende.id == 'ende_meister');
          if (d != _Detektiv.zufaellig) continue;
          final e = p.einfluss!;
          z.abende++;
          for (final f in e.funde.entries) {
            if (!istSuche(erm.entscheidung(f.key))) continue;
            z.suchen++;
            if (f.value.verwischt) z.verwischt++;
            if (f.value.ertappt != null) z.ertappt++;
            z.zusatzfunde += f.value.randnotizen.length;
          }
          z.nachfragen += e.nachfragen.length;
          z.tischbonus[e.stand.tischbonus] = (z.tischbonus[e.stand.tischbonus] ?? 0) + 1;
          z.zusammenhalt += e.stand.zusammenhalt;
          z.spuk += e.stand.spuk;
          for (var r = 0; r < 3; r++) {
            z.rest[r] += p.restJeRunde[r];
          }
          final prot = e.protokoll();
          for (final f in p.spiel.besetzt) {
            final st = [for (final ziel in ziele.von(f)) ziele.stand(ziel, prot) == ZielStand.erreicht];
            for (final zahl in [zielZahl[f]!, zielJePfad[pfad]![f]!]) {
              zahl[0]++;
              if (st[0]) zahl[1]++;
              if (st[1]) zahl[2]++;
            }
          }
        }
      }
      stdout.writeln('Pfad $pfad · n = $n');
      stdout.writeln('  Meister: zufällig ${z.quote('zufaellig')} (${z.quote('zufaellig-ohne')}) · einfach ${z.quote('einfach')} (${z.quote('einfach-ohne')})');
      stdout.writeln('  Suchen: verwischt ${_prozent(z.verwischt, z.suchen)} · Zusatzfunde ${_schnitt(z.zusatzfunde, z.abende)} je Abend · '
          'Ertappt ${_schnitt(z.ertappt, z.abende)} je Abend · Nachfragen ${_schnitt(z.nachfragen, z.abende)} je Abend');
      stdout.writeln('  Tischbonus: ${[for (final b in [-1, 0, 1]) '${b > 0 ? '+' : ''}$b ${_prozent(z.tischbonus[b] ?? 0, z.abende)}'].join(' · ')} · '
          'Leisten am Ende Ø Zusammenhalt ${_schnitt(z.zusammenhalt, z.abende)}, Spuk ${_schnitt(z.spuk, z.abende)}');
      stdout.writeln('  Minuten am Rundenende Ø ${[for (final r in z.rest) _schnitt(r, z.abende)].join(' / ')}');
    }
    stdout.writeln('');
  }
  stdout.writeln('Ziele (zufälliger Detektiv, Bot-Tisch): Stern I / Stern II erreicht, gesamt und je Pfad');
  for (final f in regeln.figuren) {
    final g = zielZahl[f]!;
    final jePfad = [for (final p in kanon.pfade) '$p ${_prozent(zielJePfad[p]![f]![1], zielJePfad[p]![f]![0])}/${_prozent(zielJePfad[p]![f]![2], zielJePfad[p]![f]![0])}'];
    stdout.writeln('  ${f.padRight(8)} ${_prozent(g[1], g[0])} / ${_prozent(g[2], g[0])}  (${g[0]} Abende; ${jePfad.join(' · ')})');
  }
}
