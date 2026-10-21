import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/runden.dart';

import 'bildschirme/rundgang.dart';
import 'sitzung.dart';

/// Entwickler-Einstieg des Partymodus (F4-ORCH-02):
/// `?party=schlosskeller&pfad=ahmet&n=7&detektiv=w&skript=best,a,richtig&dauer=20&takt=700&zeitraffer=60`.
///
/// - `code` oder `pfad`: Fall-Code bzw. Täter-Pfad (für Testläufe)
/// - `n`: Personenzahl, `detektiv`: m oder w, `dauer`: Rundendauer in Sekunden
/// - `skript`: Entscheidungen (`best`, `schlecht`, `erste`), Gruppe (`a`, `b`,
///   `gemischt`), Anklage (`richtig`, `falsch` oder eine Kennung)
/// - `takt`: Pause zwischen zwei Schritten in Millisekunden
/// - `zeitraffer`: Spielsekunden je echter Sekunde in der Rückblende
/// - `fotos=0`: Fotostellen nur melden, ohne auf den Fotografen zu warten
/// - `fotopause`: Wartezeit an einer Fotostelle in Millisekunden (Vorgabe 1200)
/// - `bis=<phase>` (ohne Skript): bis zu diesem Abschnitt vorspielen (beste Wahl, alle A, richtige Anklage)
/// - `at=x,y`: Detektiv auf der Karte an diese Stelle setzen; `zoom`: Zoom der Karte
/// - `gespraech=<figur>[,<schritte>]` (mit `bis`): in Runde 1 ein Randgespräch mit
///   dieser Figur beginnen und je Schritt die erste Wahl nehmen; liegt `bis`
///   hinter den Entscheidungen, wird es zu Ende geführt (Nachspiel)
/// - `fassung=lang`: der lange Abend (M7b), nur in Akten mit Langfassung;
///   sonst und ohne Angabe der kurze. Mit Skript geht er Vorspiel und Morgen
///   Station für Station ab (Fotostellen `vorspiel` und `morgen` in der Mitte
///   des Rundgangs); `bis=` überspringt sie
///
/// Im Modell befragung erledigt das Skript die Befragungen jeder Runde selbst
/// (erste Frage, feste und so viele freie wie erlaubt).
class PartyDev {
  final String fall;
  final String? code;
  final String? pfad;
  final int? rollen;
  final String detektiv;
  final List<String>? skript;
  final int? dauerSekunden;
  final int takt;
  final double? zeitraffer;
  final bool fotos;
  final int fotopause;
  final PartyPhase? bis;
  final (double, double)? at;
  final double? zoom;
  final String? gespraech;
  final int gespraechSchritte;

  /// Kurzer oder langer Abend (`fassung=lang`).
  final Abendfassung fassung;

  const PartyDev({
    this.fall = 'schlosskeller',
    this.code,
    this.pfad,
    this.rollen,
    this.detektiv = 'w',
    this.skript,
    this.dauerSekunden,
    this.takt = 700,
    this.zeitraffer,
    this.fotos = true,
    this.fotopause = 1200,
    this.bis,
    this.at,
    this.zoom,
    this.gespraech,
    this.gespraechSchritte = 0,
    this.fassung = Abendfassung.kurz,
  });

  /// Aus den URL-Parametern; `null` ohne `party=`.
  static PartyDev? ausUrl(Map<String, String> q) {
    final fall = q['party'];
    if (fall == null) return null;
    return PartyDev(
      fall: fall.isEmpty ? 'schlosskeller' : fall,
      code: q['code'],
      pfad: q['pfad'],
      rollen: int.tryParse(q['n'] ?? ''),
      detektiv: q['detektiv'] == 'm' ? 'm' : 'w',
      skript: q['skript']?.split(','),
      dauerSekunden: int.tryParse(q['dauer'] ?? ''),
      takt: int.tryParse(q['takt'] ?? '') ?? 700,
      zeitraffer: double.tryParse(q['zeitraffer'] ?? ''),
      fotos: q['fotos'] != '0',
      fotopause: int.tryParse(q['fotopause'] ?? '') ?? 1200,
      bis: PartyPhase.values.where((p) => p.name == q['bis']).firstOrNull,
      at: switch ((q['at'] ?? '').split(',').map(double.tryParse).toList()) {
        [final double x, final double y] => (x, y),
        _ => null,
      },
      zoom: double.tryParse(q['zoom'] ?? ''),
      gespraech: q['gespraech']?.split(',').first,
      gespraechSchritte: int.tryParse(q['gespraech']?.split(',').elementAtOrNull(1) ?? '') ?? 0,
      fassung: Abendfassung.lesen(q['fassung']),
    );
  }

  /// Fassung für die Sitzung [s]: lang nur, wenn die Akte eine Langfassung hat.
  Abendfassung fassungFuer(PartySitzung s) => s.daten.hat('langfassung') ? fassung : Abendfassung.kurz;

  /// Fall-Code aus `code` oder `pfad`.
  String? fallCode(Kanon kanon) => code ?? (pfad == null ? null : FallCode.fuerPfad(pfad!, kanon.pfade).code);
}

/// Spielt einen Abend automatisch durch (E2E-Läufe). Benutzt nur die
/// öffentliche API der Sitzung und meldet Fotostellen als `PARTY foto=<name>`.
class PartySkript {
  PartySkript(this.sitzung, this.dev);

  final PartySitzung sitzung;
  final PartyDev dev;
  bool _laeuft = false;
  final _fotografierteAktionen = <int>{};

  String get _entscheidungen => (dev.skript?.elementAtOrNull(0) ?? 'best');
  String get _gruppe => (dev.skript?.elementAtOrNull(1) ?? 'a');
  String get _anklage => (dev.skript?.elementAtOrNull(2) ?? 'richtig');

  Future<void> _warte([double faktor = 1]) => Future<void>.delayed(Duration(milliseconds: (dev.takt * faktor).round()));

  /// Fotostelle melden und dem Fotografen Zeit lassen (mindestens 1,2 s).
  /// Gemeldet wird erst nach dem nächsten Frame: Dann zeigen Foto und
  /// Bildschirmtext den neuen Bildschirm, auch wenn der Rechner ausgelastet ist.
  Future<void> _foto(String name) async {
    await SchedulerBinding.instance.endOfFrame;
    debugPrint('PARTY foto=$name');
    await Future<void>.delayed(Duration(milliseconds: dev.fotos && dev.takt < dev.fotopause ? dev.fotopause : dev.takt));
  }

  Future<void> starten() async {
    if (_laeuft) return;
    _laeuft = true;
    try {
      // Im langen Abend läuft im Ende noch der Morgen (M7b), dann erst das Schlussbild.
      while (sitzung.phase != PartyPhase.ende || sitzung.rundgang != null) {
        await _schritt();
        await _warte();
      }
      await _foto('ende');
      final s = sitzung.spiel;
      debugPrint('PARTY fertig pfad=${s.pfad} ende=${s.ende.id} punkte=${s.punkte} rollen=${s.einstellungen.rollen}');
    } catch (e, st) {
      debugPrint('PARTY fehler $e\n$st');
    }
  }

  Future<void> _schritt() async {
    final s = sitzung;
    switch (s.phase) {
      case PartyPhase.titel:
        await _foto('titel');
        s.zurEinrichtung();
      case PartyPhase.einrichtung:
        await _foto('einrichtung');
        s.einrichten(rollen: dev.rollen ?? 7, detektiv: dev.detektiv, code: dev.fallCode(s.kanon), fassung: dev.fassungFuer(s));
        if (dev.dauerSekunden != null) s.rundendauer = Duration(seconds: dev.dauerSekunden!);
        if (dev.zeitraffer != null) s.zeitraffer = dev.zeitraffer!;
      case PartyPhase.intro || PartyPhase.ende when s.rundgang != null:
        await _rundgang();
      case PartyPhase.rollen:
        await _foto('rollen');
        s.zeigeVerdeckt(s.besetzt.last);
        await _warte();
        await _foto('dossier');
        s.verdecken();
        // Die Täteransicht einmal im Fotosatz, damit Lesbarkeit und Verdecktheit prüfbar sind (F6-SPIEL-01).
        s.zeigeVerdeckt(s.spiel.pfad);
        await _warte();
        await _foto('dossier_taeter');
        s.verdecken();
        s.weiter();
      case PartyPhase.entscheidungen:
        await _entscheiden();
      case PartyPhase.gruppenwahl:
        if (s.verdeckt != null) {
          final i = s.besetzt.indexOf(s.verdeckt!);
          final a = switch (_gruppe) { 'b' => false, 'gemischt' => i.isEven, _ => true };
          if (i == 0) {
            await _foto('wahl_verdeckt_r${s.runde}');
          }
          if (s.verdeckt == s.spiel.pfad) {
            await _foto('wahl_taeter_r${s.runde}');
          }
          s.stimme(s.verdeckt!, kooperativ: a);
        } else if (s.offeneWaehler.isNotEmpty) {
          s.zeigeVerdeckt(s.offeneWaehler.first);
        } else {
          await _foto('gruppenwahl_r${s.runde}');
          s.weiter();
        }
      case PartyPhase.anklage:
        if (s.angeklagt == null) {
          await _foto('anklage');
          final pfad = s.spiel.pfad;
          final wer = switch (_anklage) {
            'richtig' => pfad,
            'falsch' => s.kernverdaechtige.firstWhere((p) => p != pfad),
            final x => x,
          };
          s.anklagen(wer);
        } else {
          s.weiter();
        }
      case PartyPhase.finale:
        await _foto('finale');
        if (!s.hatRueckblende) {
          // Akte ohne Simulation: nur ein Text als Rückblende, kein Zeitraffer.
          await _foto('rueckblende_text');
          s.weiter();
          return;
        }
        final dauer = s.rueckblende.schritte.last.minus(s.rueckblende.schritte.first) / (dev.zeitraffer ?? 25);
        // Das erste Rückblendenfoto liegt im Stromausfall, kurz nach dem Knall, in jedem
        // Pfad zur selben Kanon-Uhrzeit (F6-SICHT-04 Nr. 3). Höchstens 20 s warten.
        final stromausfall = Uhrzeit.parse('23:58:05');
        for (var i = 0; i < 400 && (s.rueckblendeZeit == null || s.rueckblendeZeit! < stromausfall); i++) {
          await Future<void>.delayed(const Duration(milliseconds: 50));
        }
        await _foto('rueckblende_1');
        for (var i = 2; i <= 3; i++) {
          await Future<void>.delayed(Duration(milliseconds: (dauer * 1000 * 0.2).round()));
          await _foto('rueckblende_$i');
        }
        await Future<void>.delayed(Duration(milliseconds: (dauer * 1000 * 0.45).round()));
        s.weiter();
      case PartyPhase.ende:
        return;
      default:
        await _foto('${s.phase.name}${s.runde > 0 ? '_r${s.runde}' : ''}');
        befragungenErledigen(s);
        s.weiter();
    }
  }

  /// Geht den laufenden Rundgang (Vorspiel oder Morgen, M7b) Station für
  /// Station ab: Je Station wartet das Skript, bis der Detektiv angekommen ist
  /// (höchstens 20 s, die Karte geht sichtbar), in der Mitte des Rundgangs ist
  /// die Fotostelle `vorspiel` bzw. `morgen`.
  Future<void> _rundgang() async {
    final s = sitzung;
    final teil = s.rundgang;
    if (teil == null) return;
    final mitte = s.rundgangStationen.length ~/ 2;
    while (s.rundgang == teil) {
      final nr = s.rundgangStation;
      await _warte();
      for (var i = 0; i < 400 && (RundgangBildschirm.letzteKarte.value?.laeuft ?? false); i++) {
        await Future<void>.delayed(const Duration(milliseconds: 50));
      }
      if (nr == mitte) await _foto(teil.name);
      if (s.rundgang != teil || s.rundgangStation != nr) continue;
      s.rundgangWeiter();
    }
  }

  /// Erledigt die Befragungen der laufenden Runde (Modell befragung, A-051): jede
  /// feste und so viele freie, wie die Runde erlaubt, je mit der ersten Frage.
  /// Reihum ist die Person danach beantwortet. Ohne Befragungen geschieht nichts.
  static void befragungenErledigen(PartySitzung s) {
    // Im Druckspiel stehen die Befragungen auf dem Bogen; die App führt sie nicht.
    if (s.phase != PartyPhase.gespraeche || s.befragungAufPapier) return;
    var frei = s.befragungenFrei;
    for (final k in s.befragungen) {
      if (k.erledigt) continue;
      if (!k.gefragt) {
        if (!k.pflicht) {
          if (frei <= 0) continue;
          frei--;
        }
        s.befragen(k.id, 0);
      }
      if (k.mensch) s.befragungErledigt(k.id);
    }
  }

  /// Wie [vorspielen], mit dem Randgespräch aus `gespraech=`: Es beginnt in den
  /// Entscheidungen der ersten Runde; liegt [ziel] dahinter, wird es beendet.
  static void vorspielenMitGespraech(PartySitzung s, PartyDev dev, PartyPhase ziel) {
    final figur = dev.gespraech;
    if (figur == null || ziel.index < PartyPhase.entscheidungen.index) return vorspielen(s, dev, ziel);
    vorspielen(s, dev, PartyPhase.entscheidungen);
    // Ein laufender Auftakt-Zug sperrt die Karte: erst zu Ende spielen.
    for (var i = 0; s.zug != null && i < 12; i++) {
      final z = s.zug!;
      switch (z.phase) {
        case RundenZugPhase.aktion: s.aktionFertig(z.aktion);
        case RundenZugPhase.wurf: s.wuerfeln();
        case RundenZugPhase.tischruf: s.tischruf(Tischruf.umweg);
        case RundenZugPhase.fund: s.fundGelesen();
      }
    }
    if (s.letzterFund != null) s.fundGelesen();
    if (s.randgespraechBeginnen(figur)) {
      final weiter = ziel != PartyPhase.entscheidungen;
      for (var i = 0; (weiter || i < dev.gespraechSchritte) && !s.gespraech!.fertig; i++) {
        s.randgespraechWaehlen(s.gespraech!.wahlen.first);
      }
      if (weiter) s.randgespraechBeenden();
    }
    if (ziel != PartyPhase.entscheidungen) vorspielen(s, dev, ziel);
  }

  /// Ohne Pausen bis zu [ziel] vorspielen (Sichtprüfung, Fotos einzelner Abschnitte).
  static void vorspielen(PartySitzung s, PartyDev dev, PartyPhase ziel) {
    var schritte = 0;
    while (s.phase != ziel && s.phase != PartyPhase.ende && schritte++ < 500) {
      switch (s.phase) {
        case PartyPhase.titel:
          s.zurEinrichtung();
        case PartyPhase.einrichtung:
          s.einrichten(rollen: dev.rollen ?? 7, detektiv: dev.detektiv, code: dev.fallCode(s.kanon), fassung: dev.fassungFuer(s));
        case PartyPhase.entscheidungen:
          // Nur der explizite Standbild-Einstieg überspringt das Rendering.
          // Der vollständige E2E-Lauf unten wartet auf echte Kartenaktionen.
          final z = s.zug;
          if (z != null) {
            switch (z.phase) {
              case RundenZugPhase.aktion: s.aktionFertig(z.aktion);
              case RundenZugPhase.wurf: s.wuerfeln();
              case RundenZugPhase.tischruf: s.tischruf(Tischruf.umweg);
              case RundenZugPhase.fund: s.fundGelesen();
            }
            continue;
          }
          final e = s.laufendeEntscheidung;
          if (e == null) {
            s.weiter();
          } else {
            s.schlageVor(e.richtig[s.spiel.pfad]!);
            s.bestaetigen();
            if (!s.mitWuerfel) s.fundGelesen();
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
        default:
          // Langer Abend (M7b): Das Vorspiel überspringt der Standbild-Einstieg.
          if (s.rundgang != null) {
            s.rundgangUeberspringen();
            continue;
          }
          befragungenErledigen(s);
          s.weiter();
      }
    }
  }

  Future<void> _entscheiden() async {
    final s = sitzung;
    final zug = s.zug;
    if (zug != null) {
      switch (zug.phase) {
        case RundenZugPhase.aktion:
          if (_fotografierteAktionen.add(zug.aktion)) await _foto('aktion_${zug.id}_${zug.aktion}');
          // Kein Teleport, kein aktionFertig: Flame muss Weg UND Pose abspielen.
          return;
        case RundenZugPhase.wurf:
          await _foto('wurf_${zug.id}_${zug.aktion}');
          s.wuerfeln();
          return;
        case RundenZugPhase.tischruf:
          await _foto('pech_${zug.id}_${zug.aktion}');
          s.tischruf(zug.wurf!.anlauf.isOdd ? Tischruf.umweg : Tischruf.nochmal);
          return;
        case RundenZugPhase.fund:
          if (zug.istAuftakt) {
            await _foto('auftakt_fund');
            s.fundGelesen();
            return;
          }
      }
    }
    final fund = s.letzterFund;
    if (fund != null) {
      await _foto('fund_${fund.entscheidung}');
      s.fundGelesen();
      return;
    }
    final v = s.vorschlag;
    if (v != null) {
      await _foto('endgueltig_${v.entscheidung}');
      s.bestaetigen();
      return;
    }
    final e = s.laufendeEntscheidung;
    if (e == null) {
      if (!s.kannWeiter) throw StateError('Eine offene Aktion darf keine Runde beenden.');
      await _foto('entscheidungen_fertig_r${s.runde}');
      s.weiter();
      return;
    }
    final pfad = s.spiel.pfad;
    final richtig = e.richtig[pfad]!;
    final option = switch (_entscheidungen) {
      'schlecht' => e.optionen.firstWhere((o) => o.id != richtig).id,
      'erste' => s.optionen(e.id).first.id,
      _ => richtig,
    };
    await _foto('ziel_${e.id}');
    s.schlageVor(option);
  }
}
