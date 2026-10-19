import '../util/geom.dart';
import 'kanon/kanon.dart';
import 'raumgraph.dart';
import 'tatmatrix.dart';
import 'wahrnehmung.dart';
import 'zeit.dart';

/// Ein Verstoß des Plausibilitätsprüfers.
class Verstoss {
  final String pfad;
  final String regel;
  final String text;
  Verstoss(this.pfad, this.regel, this.text);
  @override
  String toString() => '[$pfad] $regel: $text';
}

/// Ergebnis je Pfad: Ablauf und alle Wahrnehmungen.
class PfadAuswertung {
  final String pfad;
  final Ablauf ablauf;
  final WahrnehmungsRechner rechner;
  final List<Wahrnehmung> wahrnehmungen;
  PfadAuswertung(this.pfad, this.ablauf, this.rechner, this.wahrnehmungen);

  Iterable<Wahrnehmung> von(String person) => wahrnehmungen.where((w) => w.wer == person);
}

/// Der Plausibilitätsprüfer (F-04): Wege, Wahrnehmung, Lügen, Gegenstände,
/// Ausgangslage und Wissensgrenzen für alle Pfade.
class Plausibilitaet {
  final Kanon kanon;
  final Map<String, PfadAuswertung> auswertung = {};
  final List<Verstoss> verstoesse = [];

  Plausibilitaet(this.kanon) {
    for (final p in kanon.pfade) {
      final m = kanon.tatmatrix(p);
      final a = Ablauf(kanon.graph, m, start: kanon.regeln.planVon, ende: kanon.regeln.planBis);
      final r = WahrnehmungsRechner(kanon.graph, a, kanon.regeln);
      auswertung[p] = PfadAuswertung(p, a, r, r.berechne());
    }
  }

  RaumGraph get graph => kanon.graph;
  WahrnehmungsRegeln get regeln => kanon.regeln;

  /// Führt alle Prüfungen aus und liefert die Verstöße.
  List<Verstoss> pruefe() {
    verstoesse.clear();
    for (final p in kanon.pfade) {
      final a = auswertung[p]!;
      _plaene(a);
      _wege(a);
      _abdeckung(a);
      _gegenstaende(a);
      _ausgangslage(a);
      _detektiv(a);
    }
    _beobachtungen();
    _luegen();
    _wissensgrenzen();
    return verstoesse;
  }

  void _v(String pfad, String regel, String text) => verstoesse.add(Verstoss(pfad, regel, text));

  void _plaene(PfadAuswertung a) {
    for (final f in a.ablauf.fehler) {
      _v(a.pfad, 'Plan', f.toString());
    }
    const haltungen = {'steht', 'sitzt', 'kauert', 'augenbinde', 'liegt'};
    for (final e in a.ablauf.matrix.plaene.entries) {
      for (final s in e.value) {
        if (s.haltung != null && !haltungen.contains(s.haltung)) _v(a.pfad, 'Plan', '${e.key} @${s.t}: unbekannte Haltung ${s.haltung}');
        if (s.istWeg && s.tempo != 'gehen' && s.tempo != 'rennen' && s.tempo != 'faellt') _v(a.pfad, 'Plan', '${e.key} @${s.t}: unbekanntes Tempo ${s.tempo}');
        if (s.licht != null && !graph.lichtquellen.containsKey(s.licht)) _v(a.pfad, 'Plan', '${e.key} @${s.t}: unbekanntes Licht ${s.licht}');
        if (s.lautstaerke != 'leise' && s.lautstaerke != 'laut' && s.lautstaerke != 'sehr_laut') {
          _v(a.pfad, 'Plan', '${e.key} @${s.t}: unbekannte Lautstärke ${s.lautstaerke}');
        }
      }
    }
    for (final e in a.ablauf.matrix.ereignisse) {
      if (!graph.orte.containsKey(e.ort)) _v(a.pfad, 'Ereignis', '${e.id}: unbekannter Ort ${e.ort}');
      if (e.person != null && !kanon.personen.contains(e.person)) _v(a.pfad, 'Ereignis', '${e.id}: unbekannte Person ${e.person}');
      if (e.tuer != null && !graph.tueren.containsKey(e.tuer)) _v(a.pfad, 'Ereignis', '${e.id}: unbekannte Tür ${e.tuer}');
    }
  }

  /// Wege: dunkel ≤ 1 m/s, hell ≤ 1,5 m/s, rennen ≤ 2,5 m/s.
  void _wege(PfadAuswertung a) {
    for (final e in a.ablauf.abschnitte.entries) {
      for (final ab in e.value) {
        if (!ab.istWeg) continue;
        final dauer = ab.bis.minus(ab.von);
        final v = ab.laenge / dauer;
        final double grenze;
        if (ab.tempo == 'rennen' || ab.tempo == 'faellt') {
          grenze = regeln.tempoRennen;
        } else {
          final s = ab.linie.first, z = ab.linie.last;
          final hellStart = a.rechner.lichtStufe(s.$1, s.$2, graph.raumAn(s.$1, s.$2)?.id, ab.von).index >= LichtStufe.schwach.index;
          final hellZiel = a.rechner.lichtStufe(z.$1, z.$2, graph.raumAn(z.$1, z.$2)?.id, ab.bis).index >= LichtStufe.schwach.index;
          grenze = hellStart && hellZiel ? regeln.tempoHell : regeln.tempoDunkel;
        }
        if (v > grenze + 0.005) {
          _v(a.pfad, 'Weg', '${e.key} ${ab.von}–${ab.bis} nach ${ab.zielOrt}: ${ab.laenge.toStringAsFixed(1)} m in $dauer s = ${v.toStringAsFixed(2)} m/s > $grenze m/s');
        }
      }
    }
  }

  /// Jede Person steht in jedem 15-Sekunden-Schritt des Fensters an einem Ort.
  void _abdeckung(PfadAuswertung a) {
    for (final p in kanon.personen) {
      if (!a.ablauf.abschnitte.containsKey(p)) {
        _v(a.pfad, 'Abdeckung', '$p hat keinen Plan');
        continue;
      }
      for (var t = regeln.fensterVon; t <= regeln.fensterBis; t = t.plus(regeln.matrixSchritt)) {
        final z = a.ablauf.zustand(p, t);
        if (z == null || z.raum == null) _v(a.pfad, 'Abdeckung', '$p @$t ohne Ort');
      }
    }
    for (final p in a.ablauf.abschnitte.keys) {
      if (!kanon.personen.contains(p)) _v(a.pfad, 'Abdeckung', 'Plan für unbekannte Person $p');
    }
  }

  (double, double)? _gegenstandPos(SpurPunkt s, Ablauf ablauf, Uhrzeit t) {
    if (s.traeger != null) {
      final z = ablauf.zustand(s.traeger!, t);
      return z == null ? null : (z.x, z.y);
    }
    if (s.einrichtung != null) {
      final e = graph.einrichtung[s.einrichtung];
      return e == null ? null : (e.x + 0.5, e.y + 0.5);
    }
    if (s.ort != null) {
      final o = graph.orte[s.ort];
      return o == null ? null : (o.x, o.y);
    }
    return null;
  }

  /// Gegenstände wechseln nur in Griffweite (1,5 m) den Träger oder Platz.
  void _gegenstaende(PfadAuswertung a) {
    for (final g in a.ablauf.matrix.gegenstaende.values) {
      for (var i = 0; i < g.spur.length; i++) {
        final s = g.spur[i];
        if (s.traeger != null && !kanon.personen.contains(s.traeger)) _v(a.pfad, 'Gegenstand', '${g.id}: unbekannter Träger ${s.traeger}');
        if (s.ort != null && !graph.orte.containsKey(s.ort)) _v(a.pfad, 'Gegenstand', '${g.id}: unbekannter Ort ${s.ort}');
        if (s.einrichtung != null && !graph.einrichtung.containsKey(s.einrichtung)) {
          _v(a.pfad, 'Gegenstand', '${g.id}: unbekannte Einrichtung ${s.einrichtung}');
        }
        if (i == 0) continue;
        final vorher = g.spur[i - 1];
        final alt = _gegenstandPos(vorher, a.ablauf, s.t);
        final neu = _gegenstandPos(s, a.ablauf, s.t);
        if (alt == null || neu == null) continue;
        final d = dist(alt.$1, alt.$2, neu.$1, neu.$2);
        if (d > 1.5) _v(a.pfad, 'Gegenstand', '${g.id} @${s.t}: Übergabe über ${d.toStringAsFixed(1)} m');
      }
    }
  }

  /// Ausgangslage in jedem Pfad (7.5) und Verbleib des Bunds wie im Gegenstandskanon.
  void _ausgangslage(PfadAuswertung a) {
    final m = a.ablauf.matrix;
    if (!m.ereignisse.any((e) => e.id == 'ev_knall')) _v(a.pfad, 'Ausgangslage', 'kein Stromausfall (ev_knall)');
    if (!m.ereignisse.any((e) => e.id == 'ev_scheppern')) _v(a.pfad, 'Ausgangslage', 'kein Schlag (ev_scheppern)');
    final schneider = a.ablauf.zustand('schneider', Uhrzeit.parse('23:59:30'));
    if (schneider?.haltung != 'liegt') _v(a.pfad, 'Ausgangslage', 'Herr Schneider liegt um 23:59:30 nicht bewusstlos');
    final aussentor = graph.tueren['aussentor'];
    if (aussentor == null || !aussentor.verschlossen) _v(a.pfad, 'Ausgangslage', 'Außentor nicht verschlossen');
    if (((kanon.json['setting.json']!['empfang'] as String?) ?? '').isEmpty) _v(a.pfad, 'Ausgangslage', 'Empfang nicht geregelt');
    final bund = m.gegenstaende['bund_schneider'];
    final ende = bund?.stand(regeln.fensterBis);
    if (ende == null || ende.traeger == 'schneider') {
      _v(a.pfad, 'Ausgangslage', 'Schlüsselbund ist um ${regeln.fensterBis} nicht weg');
    } else {
      Map? soll;
      for (final g in kanon.gegenstaende) {
        if (g['id'] == 'bund_schneider') soll = (g['versteckJePfad'] as Map?)?[a.pfad] as Map?;
      }
      if (soll == null) {
        _v(a.pfad, 'Ausgangslage', 'Versteck des Bunds fehlt im Gegenstandskanon');
      } else if ((soll['einrichtung'] != null && soll['einrichtung'] != ende.einrichtung) ||
          (soll['einrichtung'] == null && soll['ort'] != ende.ort)) {
        _v(a.pfad, 'Ausgangslage', 'Bund endet bei ${ende.einrichtung ?? ende.ort}, Kanon sagt ${soll['einrichtung'] ?? soll['ort']}');
      }
    }
  }

  /// Der Detektiv sitzt als blinde Kuh mit Augenbinde im Ost-Saal und ist nie in Tatnähe.
  void _detektiv(PfadAuswertung a) {
    final tatort = graph.orte['vor_vorratstuer']!;
    for (var t = Uhrzeit.parse('23:55:30'); t <= Uhrzeit.parse('00:00:30'); t = t.plus(1)) {
      final z = a.ablauf.zustand('detective', t);
      if (z == null) continue;
      if (z.haltung != 'augenbinde') {
        _v(a.pfad, 'Detektiv', 'um $t ohne Augenbinde');
        return;
      }
      if (dist(z.x, z.y, tatort.x, tatort.y) < 5 || z.raum != 'ost_saal') {
        _v(a.pfad, 'Detektiv', 'um $t nicht sicher im Ost-Saal');
        return;
      }
    }
  }

  // ---------- Beobachtungen ----------

  bool _passt(Wahrnehmung w, Map muster) {
    if (w.sinn != muster['sinn']) return false;
    final q = muster['quelle'] as String;
    if (q.endsWith('*') ? !w.quelle.startsWith(q.substring(0, q.length - 1)) : w.quelle != q) return false;
    final details = muster['detail'] as List?;
    if (details != null && !details.contains(w.detail)) return false;
    if (muster['von'] != null && w.bis < Uhrzeit.parse(muster['von'] as String)) return false;
    if (muster['bis'] != null && w.von > Uhrzeit.parse(muster['bis'] as String)) return false;
    if (muster['umfasst'] != null) {
      final t = Uhrzeit.parse(muster['umfasst'] as String);
      if (w.von > t || w.bis < t) return false;
    }
    return true;
  }

  Uhrzeit? _erstesMal(PfadAuswertung a, String wer, Map muster) {
    Uhrzeit? best;
    for (final w in a.von(wer)) {
      if (!_passt(w, muster)) continue;
      var t = w.von;
      if (muster['von'] != null) {
        final v = Uhrzeit.parse(muster['von'] as String);
        if (t < v) t = v;
      }
      if (best == null || t < best) best = t;
    }
    return best;
  }

  /// Hält der Beleg einer Beobachtung im Pfad? Liefert den Grund, wenn nicht.
  String? belegHaelt(Map<String, Object?> b, String pfad) {
    final a = auswertung[pfad]!;
    final wer = b['wer'] as String;
    final beleg = b['beleg'] as Map;
    for (final m in (beleg['alle'] as List? ?? const [])) {
      if (!a.von(wer).any((w) => _passt(w, m as Map))) return 'fehlt: $m';
    }
    for (final m in (beleg['keine'] as List? ?? const [])) {
      if (a.von(wer).any((w) => _passt(w, m as Map))) return 'unerwartet vorhanden: $m';
    }
    final folge = beleg['reihenfolge'] as List?;
    if (folge != null) {
      Uhrzeit? vorher;
      for (final m in folge) {
        final t = _erstesMal(a, wer, m as Map);
        if (t == null) return 'Reihenfolge: fehlt $m';
        if (vorher != null && !(vorher < t)) return 'Reihenfolge verletzt bei $m ($vorher ≥ $t)';
        vorher = t;
      }
    }
    final auf = beleg['aufenthalt'] as Map?;
    if (auf != null) {
      for (var t = Uhrzeit.parse(auf['von'] as String); t <= Uhrzeit.parse(auf['bis'] as String); t = t.plus(1)) {
        if (a.ablauf.zustand(auf['person'] as String, t)?.ort != auf['ort']) return 'Aufenthalt verletzt um $t';
      }
    }
    for (final z in (beleg['zeitleiste'] as List? ?? const [])) {
      if (!kanon.zeitleiste.any((e) => e['id'] == z)) return 'Zeitleisten-Eintrag $z fehlt';
    }
    for (final g in (beleg['gegenstand'] as List? ?? const [])) {
      if (!kanon.gegenstaende.any((e) => e['id'] == g)) return 'Gegenstand $g fehlt';
    }
    for (final e in (beleg['ereignis'] as List? ?? const [])) {
      if (!a.ablauf.matrix.ereignisse.any((x) => x.id == e)) return 'Ereignis $e fehlt';
    }
    return null;
  }

  void _beobachtungen() {
    final ids = <String>{};
    for (final b in kanon.beobachtungen) {
      final id = b['id'] as String;
      if (!ids.add(id)) _v('alle', 'Beobachtung', 'doppelte Kennung $id');
      if (!kanon.personen.contains(b['wer'])) _v('alle', 'Beobachtung', '$id: unbekannte Person ${b['wer']}');
      final pfadabhaengig = b['art'] == 'pfadabhaengig';
      if (pfadabhaengig && b['kanal'] == 'pflichtgespraech') _v('alle', 'Beobachtung', '$id: pfadabhängig, aber im Pflichtgespräch (P-1)');
      for (final p in kanon.pfade) {
        final gilt = Kanon.giltIn(b['pfade'], p);
        final grund = belegHaelt(b, p);
        if (gilt && grund != null) _v(p, 'Beobachtung', '$id (${b['wer']}): Beleg hält nicht – $grund');
        if (!gilt && pfadabhaengig && grund == null) _v(p, 'Beobachtung', '$id gilt nicht in $p, der Beleg hält dort aber auch');
      }
    }
  }

  // ---------- Lügen ----------

  void _luegen() {
    final widerlegt = <String>{};
    for (final b in kanon.beobachtungen) {
      for (final l in (b['widerlegt'] as List? ?? const [])) {
        widerlegt.add(l as String);
      }
    }
    for (final g in kanon.gegenstaende) {
      for (final s in (g['spuren'] as List? ?? const [])) {
        for (final l in ((s as Map)['widerlegt'] as List? ?? const [])) {
          widerlegt.add(l as String);
        }
      }
    }
    final luegen = <String>{};
    for (final f in kanon.figuren) {
      for (final l in (f['luegen'] as List? ?? const [])) {
        final id = (l as Map)['id'] as String;
        luegen.add(id);
        if (!widerlegt.contains(id)) _v('alle', 'Lüge', '$id (${f['id']}) wird durch nichts widerlegt');
      }
    }
    for (final w in widerlegt) {
      if (!luegen.contains(w)) _v('alle', 'Lüge', 'Verweis auf unbekannte Lüge $w');
    }
  }

  // ---------- Wissensgrenzen ----------

  /// Merkmale einer Wahrnehmung, wie die Person sie kennt (ohne verborgene Identität).
  String _merkmal(Wahrnehmung w, Uhrzeit scheppern, bool hoertScheppern, Ablauf ablauf) {
    final art = w.quelle.contains(':') ? w.quelle.split(':').first : w.quelle;
    final anonym = w.detail == 'anonym' || w.detail == 'umriss' || w.detail == 'leuchten';
    final wer = anonym ? (w.sinn == 'fuehlen' ? 'jemand' : (w.detail == 'leuchten' ? 'leuchtendes Gesicht' : art)) : w.quelle;
    final raum = (w.person == null || w.detail == 'leuchten') ? '' : ' @${ablauf.zustand(w.person!, w.von)?.raum ?? '?'}';
    final lage = !hoertScheppern ? '' : (w.bis < scheppern ? ' vor' : (w.von > scheppern ? ' nach' : ' während'));
    return '${w.sinn} $wer ${w.detail}$raum$lage';
  }

  /// Je Person die Merkmale, die sich zwischen den Pfaden unterscheiden, in denen sie unschuldig ist.
  Map<String, Map<String, List<String>>> wissensUnterschiede() {
    final von = Uhrzeit.parse('23:58:00'), bis = Uhrzeit.parse('00:00:00'), scheppern = Uhrzeit.parse('23:58:40');
    final luecke = (kanon.figurenJson['opfer'] as Map)['gedaechtnisLueckeAb'] as String?;
    final wissen = <String, Map<String, Set<String>>>{};
    for (final p in kanon.pfade) {
      final a = auswertung[p]!;
      final hoert = {for (final w in a.wahrnehmungen) if (w.quelle == 'ev_scheppern') w.wer};
      for (final w in a.wahrnehmungen) {
        if (w.bis < von || w.von > bis || w.sinn == 'riechen') continue;
        var x = w;
        if (w.wer == 'schneider' && luecke != null) {
          // Gedächtnislücke: Was danach kam, weiß Herr Schneider nicht mehr.
          final l = Uhrzeit.parse(luecke);
          if (w.von >= l) continue;
          if (w.bis >= l) {
            x = Wahrnehmung(wer: w.wer, sinn: w.sinn, quelle: w.quelle, detail: w.detail, person: w.person, text: w.text, von: w.von, bis: l.plus(-1));
          }
        }
        ((wissen[w.wer] ??= {})[p] ??= {}).add(_merkmal(x, scheppern, hoert.contains(w.wer), a.ablauf));
      }
    }
    final out = <String, Map<String, List<String>>>{};
    for (final person in wissen.keys) {
      final relevant = [for (final p in kanon.pfade) if (p != person) p];
      final alle = <String>{for (final p in relevant) ...?wissen[person]![p]};
      for (final mk in alle) {
        final in_ = [for (final p in relevant) if (wissen[person]![p]?.contains(mk) ?? false) p];
        if (in_.length != relevant.length) (out[person] ??= {})[mk] = in_;
      }
    }
    return out;
  }

  /// Nur erklärte Trenner-Zeugen dürfen pfadabhängiges Wissen haben, und jede
  /// Kernperson hat genau einen Trenner-Zeugen. Ausnahme: Eine Kernperson mit
  /// erklärtem eigenem Pfadverhalten (`eigenwissen`, E-039) weiß in diesem Pfad,
  /// was sie selbst getan hat.
  void _wissensgrenzen() {
    final zeugen = <String, Set<String>>{};
    for (final b in kanon.beobachtungen) {
      final t = b['trenner'] as String?;
      if (t != null) (zeugen[t] ??= {}).add(b['wer'] as String);
    }
    for (final k in kanon.kernverdaechtige) {
      final z = zeugen[k] ?? const {};
      if (z.length != 1) _v('alle', 'Wissen', 'Trenner für $k hat ${z.length} Zeugen (${z.join(', ')}), erwartet genau 1');
    }
    final erlaubt = {
      for (final s in zeugen.values) ...s,
      for (final b in kanon.beobachtungen)
        if (b['eigenwissen'] == true && kanon.kernverdaechtige.contains(b['wer'])) b['wer'] as String,
    };
    for (final e in wissensUnterschiede().entries) {
      if (erlaubt.contains(e.key)) continue;
      for (final m in e.value.entries) {
        _v('alle', 'Wissen', '${e.key} weiß pfadabhängig „${m.key}“ (nur in ${m.value.join(', ')}), ist aber kein erklärter Trenner-Zeuge');
      }
    }
  }

  // ---------- Matrix ----------

  /// Die 15-Sekunden-Tatmatrix eines Pfads als Markdown-Tabelle.
  String matrixMarkdown(String pfad) {
    final a = auswertung[pfad]!;
    final zeiten = <Uhrzeit>[for (var t = regeln.fensterVon; t <= regeln.fensterBis; t = t.plus(regeln.matrixSchritt)) t];
    final b = StringBuffer();
    b.writeln('| Zeit | ${kanon.personen.join(' | ')} |');
    b.writeln('|${List.filled(kanon.personen.length + 1, '---').join('|')}|');
    for (final t in zeiten) {
      final zellen = [
        for (final p in kanon.personen)
          () {
            final z = a.ablauf.zustand(p, t);
            if (z == null) return '–';
            final ort = a.ablauf.ortText(p, t);
            return z.haltung == 'steht' ? ort : '$ort (${z.haltung})';
          }(),
      ];
      b.writeln('| $t | ${zellen.join(' | ')} |');
    }
    return b.toString();
  }
}
