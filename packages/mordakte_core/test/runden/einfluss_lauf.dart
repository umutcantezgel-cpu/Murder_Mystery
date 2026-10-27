// Treiber ganzer Abende mit Einfluss-Schicht (Finale §3, §4): RundenPartie mit echten Daten der Akte,
// Zugprofil des Tisches, Wahlfolge und Strategie des Detektivs. Gemeinsam für die Beweise T-B, T-W, T-L,
// T-P, das Ende und den Determinismus (einfluss_soll.g.dart). Nur VM (liest die Akte mit dart:io).
import 'dart:convert';

import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/runden.dart';

import '../party/kanon_hilfe.dart';
import 'einfluss_hilfe.dart';

/// Zugprofil des Tisches im Moment (Finale §4, T-B). [stuetzen]: alle zeigen auf Kernfiguren (Spuk steigt);
/// [stoeren]: alle decken Kernfiguren, jede dritte Rolle lenkt ab; [auspacken]: wer kann, packt in Runde 1
/// aus, danach helfen alle; [bots]: niemand zieht selbst, alle Züge kommen aus dem Bot-Strom.
enum Tischprofil { stuetzen, stoeren, auspacken, bots }

/// Strategie des Detektivs neben der Wahl (gründlich, Werkzeug, Marke, Tischruf); fest oder aus einem Strom.
class Detektivweise {
  final bool Function(String entscheidung) gruendlich;
  final Tischruf Function(String entscheidung, int anlauf) ruf;
  final bool Function() werkzeug, marke;
  const Detektivweise({required this.gruendlich, required this.ruf, required this.werkzeug, required this.marke});

  /// Nie gründlich, ohne Werkzeug und Marke, immer derselbe Ruf.
  factory Detektivweise.fest(Tischruf r, {bool gruendlich = false}) =>
      Detektivweise(gruendlich: (_) => gruendlich, ruf: (_, _) => r, werkzeug: () => false, marke: () => false);

  /// Alles aus dem Strom [rng] (gleiche Folge von Fragen, gleiche Antworten).
  factory Detektivweise.strom(Rng rng) => Detektivweise(
        gruendlich: (_) => rng.chance(0.25),
        ruf: (_, _) => rng.chance(0.5) ? Tischruf.nochmal : Tischruf.umweg,
        werkzeug: () => rng.chance(0.3),
        marke: () => rng.chance(0.3),
      );
}

/// Zug von [rolle] (Index [i] in der Besetzung) in [runde] für ein festes Profil; `null` bei [Tischprofil.bots].
EinflussZug? profilZug(Tischprofil profil, EinflussRegeln r, List<String> besetzt, int i, int runde) {
  final rolle = besetzt[i];
  final tipp = runde == r.zahlen.tippRunde ? r.kern[i % r.kern.length] : null;
  String kernZiel({required bool ichErlaubt}) {
    for (var k = 0; k < r.kern.length; k++) {
      final f = r.kern[(i + runde + k) % r.kern.length];
      if (ichErlaubt || f != rolle) return f;
    }
    throw StateError('keine Kernfigur');
  }

  return switch (profil) {
    Tischprofil.stuetzen => EinflussZug(rolle, ZugArt.zeigen, ziel: kernZiel(ichErlaubt: false), tipp: tipp),
    Tischprofil.stoeren => i % 3 == 2
        ? EinflussZug(rolle, ZugArt.ablenken, tipp: tipp)
        : EinflussZug(rolle, ZugArt.decken, ziel: kernZiel(ichErlaubt: true), tipp: tipp),
    Tischprofil.auspacken => runde == 1 && r.auspacken.containsKey(rolle)
        ? EinflussZug(rolle, ZugArt.auspacken, tipp: tipp)
        : EinflussZug(rolle, ZugArt.helfen, tipp: tipp),
    Tischprofil.bots => null,
  };
}

/// Beobachter eines Abends: [art] des Schritts und seine Daten; die Partie steht im Zustand danach.
typedef EinflussBeobachter = void Function(String art, Map<String, Object?> daten, RundenPartie p);

/// Spielt einen ganzen Abend mit Einfluss-Schicht bis zum Ende. [folge]: Option je Entscheidung in
/// Kanon-Reihenfolge; [anklage] Standard: der Täter des Pfads. [vorOeffnen] sieht die Partie, bevor eine
/// Entscheidung gewählt wird; [beobachter] jeden Schritt. Nachfragen werden alle gestellt (erste Option).
RundenPartie spieleEinflussAbend({
  required String pfad,
  required int rollen,
  required List<String> folge,
  required WuerfelQuelle quelle,
  required String salz,
  Tischprofil profil = Tischprofil.bots,
  Detektivweise? weise,
  String? anklage,
  String detektiv = 'm',
  EinflussRegeln? regeln,
  void Function(RundenPartie p, Entscheidung e)? vorOeffnen,
  EinflussBeobachter? beobachter,
}) {
  final r = regeln ?? einflussRegeln;
  final w = weise ?? Detektivweise.fest(Tischruf.nochmal);
  final p = RundenPartie(kanon, quelle: quelle, ermittlung: einflussErmittlung, einfluss: r, salz: salz)
    ..einrichten(Einstellungen(rollen: rollen, detektiv: detektiv, code: FallCode.fuerPfad(pfad, kanon.pfade)));
  void sieh(String art, [Map<String, Object?> d = const {}]) => beobachter?.call(art, d, p);
  var index = 0;
  for (var schritte = 0; p.phase != PartyPhase.ende; schritte++) {
    if (schritte > 400) throw StateError('Sackgasse: $salz');
    final z = p.zug;
    if (z != null) {
      switch (z.phase) {
        case RundenZugPhase.aktion:
          p.aktionFertig(z.aktion);
          sieh('aktion');
        case RundenZugPhase.wurf:
          final werkzeug = w.werkzeug(), marke = w.marke();
          final t = p.tischVorschau();
          final v = p.vorschau(werkzeug: werkzeug, marke: marke);
          final wurf = p.wuerfeln(werkzeug: werkzeug, marke: marke);
          sieh('wurf', {'wurf': wurf.zeile, 'vorschauMod': v.mod, 'tisch': ?t?.tisch, 'umweg': ?t?.umweg});
        case RundenZugPhase.tischruf:
          final ruf = w.ruf(z.id, z.wurf!.anlauf);
          p.tischruf(ruf);
          sieh('tischruf', {'ruf': ruf.name});
        case RundenZugPhase.fund:
          p.fundGelesen();
          sieh('fund', {'id': z.id, 'einfluss': z.einfluss?.toJson(), 'funde': z.funde.length});
      }
    } else if (p.naechsteEntscheidung case final e?) {
      vorOeffnen?.call(p, e);
      final option = folge[index++];
      p.waehle(option, gruendlich: istSuche(e) && w.gruendlich(e.id));
      sieh('waehle', {'id': e.id, 'option': option, 'tisch': p.tisch(option)});
    } else {
      final schritt = <String, Object?>{'phase': p.phase.name, 'runde': p.runde};
      if (p.phase == PartyPhase.gespraeche) {
        final besetzt = p.spiel.besetzt;
        for (var i = 0; i < besetzt.length; i++) {
          if (profilZug(profil, r, besetzt, i, p.runde) case final m?) p.zugSetzen(m.rolle, m.art, ziel: m.ziel, tipp: m.tipp);
        }
      }
      if (p.phase == PartyPhase.anklage) {
        final fragen = <String>[];
        while (p.nachfragenOffen > 0 && p.nachfrageOptionen.isNotEmpty) {
          fragen.add(p.nachfrage(p.nachfrageOptionen.first));
        }
        schritt['nachfragen'] = fragen;
        p.anklagen(anklage ?? pfad);
      }
      final vorher = p.spiel.bausteine.length;
      p.weiter();
      schritt['bausteine'] = p.spiel.bausteine.sublist(vorher);
      sieh('weiter', schritt);
    }
  }
  if (index != folge.length) throw StateError('Wahlfolge nicht ausgeschöpft: $index');
  return p;
}

/// Öffentliche Spur eines Abends bis zur Anklage (Finale §3.12, T-P): Folgen ohne private Teile,
/// Tischwerte, Würfe, Zug-Kennzeichen, Minuten, Flüstern, Randnotizen, Nachfragen. Keine Fakten, keine
/// Funde, keine Restmenge, kein Hinweistext (die zeigt die Kanon-Engine pfadgemäß, wie ohne Schicht).
List<String> oeffentlicheSpur({
  required String pfad,
  required int rollen,
  required List<String> folge,
  required WuerfelQuelle quelle,
  required String salz,
  Tischprofil profil = Tischprofil.bots,
  Detektivweise? weise,
  String? anklage,
}) {
  final spur = <String>[];
  var vorAnklage = true;
  spieleEinflussAbend(
    pfad: pfad,
    rollen: rollen,
    folge: folge,
    quelle: quelle,
    salz: salz,
    profil: profil,
    weise: weise,
    anklage: anklage,
    beobachter: (art, d, p) {
      if (!vorAnklage) return;
      final e = p.einfluss!;
      final zeile = <String, Object?>{'art': art, 'rest': p.restMinuten, 'marken': p.marken, 'randnotizen': e.randnotizen};
      switch (art) {
        case 'weiter':
          final bausteine = [for (final b in d['bausteine'] as List<String>) if (b.startsWith('einfluss.')) b];
          zeile['bausteine'] = bausteine;
          zeile['phase'] = p.phase.name;
          zeile['nachfragen'] = d['nachfragen'];
          if (p.phase == PartyPhase.entscheidungen) {
            final f = e.stand.folgenVon(p.runde)!.toJson();
            for (final privat in ['zuege', 'privat', 'tafel']) {
              f.remove(privat);
            }
            zeile['folgen'] = f;
            zeile['abzeichen'] = {for (final o in e.regeln.optionen(p.runde)) o: p.tisch(o)};
          }
          if (p.phase == PartyPhase.bonus) zeile['fluestern'] = e.bonusQualitaet(p.runde)?.name;
          if (p.phase == PartyPhase.finale) vorAnklage = false;
        case 'fund':
          zeile['einfluss'] = d['einfluss'];
        default:
          zeile.addAll({for (final x in d.entries) if (x.key != 'funde') x.key: x.value});
      }
      zeile['leisten'] = [e.stand.zusammenhalt, e.stand.spuk];
      zeile['ertappt'] = e.stand.ertappt;
      spur.add(jsonEncode(zeile));
    },
  );
  return spur;
}

/// Gezogene Wahlfolge (eine Option je Entscheidung) aus [rng].
List<String> gezogeneFolge(Ermittlung erm, Rng rng) => [for (final e in erm.entscheidungen) e.optionen[rng.nextInt(e.optionen.length)].id];

/// Determinismus der Einfluss-Schicht (Finale §4): je Code ein ganzer Abend (Pfad reihum, Rollenzahl,
/// Wahlfolge, Profil, Strategie und Anklage aus eigenen Strömen, Salz-Würfel) und eine FNV-Summe über jeden
/// Schritt (Daten, Restminuten) sowie den Endstand: Folgen mit Privatem und Zugtafel, Kennzeichen,
/// Randnotizen, Nachfragen, Minuten, sichtbare Fakten, Wertung, Ende, Sterne, Auszeichnungen.
/// Vergleichsstand: einfluss_soll.g.dart (tool/bollwerk/einfluss_soll.dart, nie neu schreiben).
List<int> einflussDeterminismusListe([int n = 1000]) {
  final erm = einflussErmittlung;
  final kern = kanon.kernverdaechtige;
  final aus = <int>[];
  for (var i = 0; i < n; i++) {
    final pfad = kanon.pfade[i % kanon.pfade.length];
    final r = Rng(Rng.hashString('einfluss-wahl:$i'));
    final folge = gezogeneFolge(erm, r);
    final rollen = 4 + r.nextInt(17);
    final anklage = r.nextInt(5) == 0 ? kern[r.nextInt(kern.length)] : pfad;
    final profil = switch (i % 7) {
      0 => Tischprofil.stuetzen,
      1 => Tischprofil.stoeren,
      2 => Tischprofil.auspacken,
      _ => Tischprofil.bots,
    };
    final salz = 'einfluss-code$i';
    var h = Rng.hashString('$pfad|$rollen|${profil.name}|$anklage');
    final p = spieleEinflussAbend(
      pfad: pfad,
      rollen: rollen,
      folge: folge,
      quelle: SalzWuerfel(salz),
      salz: salz,
      profil: profil,
      weise: Detektivweise.strom(Rng(Rng.hashString('einfluss-strat:$i'))),
      anklage: anklage,
      detektiv: i.isEven ? 'm' : 'w',
      beobachter: (art, d, p) => h = Rng.hashString('$h|$art|${jsonEncode(d)}|${p.restMinuten}|${p.marken}'),
    );
    final e = p.einfluss!;
    final s = p.spiel;
    h = Rng.hashString('$h|${jsonEncode({
      'folgen': [for (final f in e.stand.folgen) f.toJson()],
      'funde': {for (final f in e.funde.entries) f.key: f.value.toJson()},
      'randnotizen': e.randnotizen,
      'nachfragen': [for (final x in e.nachfragen) '${x.option}:${x.notiz}'],
      'rest': p.restJeRunde,
      'wuerfe': [for (final w in p.wuerfe) w.zeile],
      'sichtbar': [...p.fakten]..sort(),
      'gewaehlt': [for (final x in erm.entscheidungen) s.gewaehlt[x.id]],
      'punkte': s.punkte,
      'endwert': s.endwert,
      'ende': s.ende.id,
      'leisten': [e.stand.zusammenhalt, e.stand.spuk, e.stand.tischbonus, e.stand.morgen.name],
      'ertappt': e.stand.ertappt,
      'tipps': e.stand.tipps,
      'sterne': e.sterne(),
      'auszeichnungen': e.auszeichnungen().toJson(),
      'bausteine': s.bausteine,
    })}');
    aus.add(h);
  }
  return aus;
}
