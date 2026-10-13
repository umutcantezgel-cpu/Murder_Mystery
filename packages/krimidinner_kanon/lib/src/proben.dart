/// Mechanische Proben des Kanons, 1:1 aus `90_werkzeug/kanon.py` portiert.
///
/// Gleiche Logik und gleiche Befundtexte wie Python. `\b` wird wie Pythons Unicode-`\b`
/// über Buchstaben, Ziffern und `_` nachgebildet. Ein Wert `–` ist hier leer.
library;

import 'dart:math' show max;

import 'kanon.dart';

// Wortgrenzen wie Pythons \b (Unicode-Wortzeichen).
final _rolle = RegExp(
  r'(?<![\p{L}\p{N}_])R(\d\d)(?![\p{L}\p{N}_])',
  unicode: true,
);
final _gRef = RegExp(
  r'(?<![\p{L}\p{N}_])(G\d-\d+)(?![\p{L}\p{N}_])',
  unicode: true,
);
final _verweis = RegExp(
  r'(?<![\p{L}\p{N}_])(H-\d+|HW-\d+|G\d-\d+|D\d-\d|E\d-\d\d|S-\d+|BS-\d+|K-\d+)(?![\p{L}\p{N}_])',
  unicode: true,
);
final _wer = RegExp(
  r'(?<![\p{L}\p{N}_])(R\d\d|DET|BW)(?![\p{L}\p{N}_])',
  unicode: true,
);
final _hRef = RegExp(r'H-\d+');
final _gespraech = RegExp(r'^G(\d)-(\d+)$');
final _schluessel = RegExp(r'^S-\d+$');
final _hKennung = RegExp(r'^H-\d+$');
final _uhrzeit = RegExp(r'^\d\d:\d\d(:\d\d)?$');
final _leer = RegExp(r'\s+');

/// Gespräche `G<Phase>-<Nr>` in Reihenfolge, optional nur einer Phase.
List<(int, KanonDatensatz)> gespraeche(KrimiKanon k, [int? phase]) {
  final out = <(int, KanonDatensatz)>[];
  for (final r in k.datensaetze.values) {
    final m = _gespraech.firstMatch(r.id);
    if (m == null) continue;
    final p = int.parse(m.group(1)!);
    if (phase == null || p == phase) out.add((p, r));
  }
  return out;
}

/// Die bei Besetzung [n] tatsächlich stattfindenden Gespräche als (von, an, Datensatz, Art).
List<(int, int?, KanonDatensatz, String)> tatsaechliche(
  KrimiKanon k,
  int phase,
  int n,
) {
  final res = <(int, int?, KanonDatensatz, String)>[];
  for (final (_, g) in gespraeche(k, phase)) {
    final von = _rnum(g.feld('Von'));
    final ziel = _rnum(g.feld('Ziel'));
    final ers = _rnum(g.feld('Ersatz'));
    if (von == null || von > n) continue;
    if (ziel != null && ziel <= n) {
      res.add((von, ziel, g, 'regulär'));
    } else if (ers != null && ers <= n) {
      res.add((von, ers, g, 'ersatz'));
    } else {
      res.add((von, null, g, 'FEHLT'));
    }
  }
  return res;
}

/// Ist Hinweis [h] bei Besetzung [n] erreichbar (über Gesprächsquelle oder Min)?
bool verfuegbar(KrimiKanon k, KanonDatensatz h, int n) {
  final q = h.feld('Quelle') ?? '';
  final m = _gRef.firstMatch(q);
  if (m != null && k.datensaetze.containsKey(m.group(1))) {
    final g = k.datensaetze[m.group(1)]!;
    final von = _rnum(g.feld('Von'));
    final ziel = _rnum(g.feld('Ziel'));
    if (von == null || von > n) return false;
    if (ziel != null && ziel <= n) {
      return (g.feld('Gibt heraus') ?? '').contains(h.id);
    }
    return (g.feld('Ersatz gibt heraus') ?? '').contains(h.id);
  }
  final mn = h.feld('Min') ?? '4';
  return (_istZiffern(mn) ? int.parse(mn) : 4) <= n;
}

/// Syntax: Lesebefunde und Verweise auf unbekannte Kennungen.
List<String> probeSyntax(KrimiKanon k) {
  final f = [...k.lesefehler];
  for (final r in k.datensaetze.values) {
    for (final e in r.felder.entries) {
      for (final m in _verweis.allMatches(e.value)) {
        final ref = m.group(1)!;
        if (!k.datensaetze.containsKey(ref)) {
          f.add('VERWEIS ${r.id}.${e.key}: unbekannte Kennung $ref');
        }
      }
    }
  }
  return f;
}

/// Ersatzziele, Mindestbesetzung und Pflichtfelder der Gespräche.
List<String> probeErsatz(KrimiKanon k) {
  final f = <String>[];
  for (final (_, g) in gespraeche(k)) {
    final von = _rnum(g.feld('Von'));
    final ziel = _rnum(g.feld('Ziel'));
    final ers = _rnum(g.feld('Ersatz'));
    if (von == null || ziel == null) {
      f.add('ERSATZ ${g.id}: Von/Ziel unlesbar');
      continue;
    }
    if (von == ziel) f.add('ERSATZ ${g.id}: Gespräch mit sich selbst');
    final braucht = ziel >= 5 && ziel > von;
    if (braucht && ers == null) {
      f.add(
        'ERSATZ ${g.id}: Ziel R${_nr2(ziel)} > R${_nr2(von)} braucht Ersatzziel',
      );
    }
    if (braucht && ers != null && !(ers <= 4 || ers < von)) {
      f.add(
        'ERSATZ ${g.id}: Ersatz R${_nr2(ers)} ist nicht sicher anwesend '
        '(muss 1–4 oder < R${_nr2(von)} sein)',
      );
    }
    if (braucht && ers == von) {
      f.add('ERSATZ ${g.id}: Ersatz ist der Auftraggeber selbst');
    }
    if (!braucht && ers != null) {
      f.add(
        'ERSATZ ${g.id}: Ersatz angegeben, obwohl Ziel sicher anwesend ist',
      );
    }
    if (braucht) {
      for (final feld in [
        'Ersatz-Bedingung',
        'Ersatz-Frage',
        'Ersatz-Antwort',
        'Ersatz-Antwortart',
      ]) {
        final v = g.feld(feld) ?? '';
        if (v.isEmpty || v == '–' || v == '-') {
          f.add('SPIEGEL ${g.id}: $feld fehlt');
        }
      }
      if ((g.feld('Ersatz gibt heraus') ?? '').isEmpty) {
        f.add("SPIEGEL ${g.id}: Feld 'Ersatz gibt heraus' fehlt");
      }
    }
    final mn = g.feld('Min') ?? '';
    final soll = max(max(von, ziel), 4);
    if (mn.isNotEmpty && _istZiffern(mn) && int.parse(mn) != soll) {
      f.add('MIN ${g.id}: Min $mn statt $soll');
    }
    for (final feld in [
      'Bedingung',
      'Frage',
      'Antwort',
      'Antwortart',
      'Gibt heraus',
    ]) {
      if ((g.feld(feld) ?? '').isEmpty) {
        f.add("SPIEGEL ${g.id}: Feld '$feld' fehlt");
      }
    }
  }
  return f;
}

/// Lastprobe: je Rolle drei ausgehende Aufträge, Gesprächszahlen je Besetzung.
List<String> probeLast(KrimiKanon k, {int grenze = 8}) {
  final f = <String>[];
  for (final p in [1, 2, 3]) {
    final aus = <int, int>{};
    for (final (_, g) in gespraeche(k, p)) {
      final v = _rnum(g.feld('Von'));
      if (v != null && v != 0) aus[v] = (aus[v] ?? 0) + 1;
    }
    for (var r = 1; r <= 20; r++) {
      if ((aus[r] ?? 0) != 3) {
        f.add(
          'LAST P$p: R${_nr2(r)} hat ${aus[r] ?? 0} ausgehende Aufträge statt 3',
        );
      }
    }
    for (var n = 4; n <= 20; n++) {
      final paare = <(int, int)>{};
      for (final (von, an, g, _) in tatsaechliche(k, p, n)) {
        if (an == null) {
          f.add('LAST P$p N=$n: ${g.id} hat kein anwesendes Ziel');
          continue;
        }
        paare.add(von <= an ? (von, an) : (an, von));
      }
      final last = <int, int>{};
      for (final (a, b) in paare) {
        last[a] = (last[a] ?? 0) + 1;
        last[b] = (last[b] ?? 0) + 1;
      }
      for (var r = 1; r <= n; r++) {
        final l = last[r] ?? 0;
        if (l > grenze) {
          f.add('LAST P$p N=$n: R${_nr2(r)} hat $l Gespräche (> $grenze)');
        }
        if (l == 0) f.add('LAST P$p N=$n: R${_nr2(r)} hat kein Gespräch');
      }
    }
  }
  return f;
}

/// Absicherung der notwendigen Schlussfolgerungen S-… durch unabhängige Quellen.
List<String> probeAbsicherung(KrimiKanon k) {
  final f = <String>[];
  final schluesse = k.datensaetze.values
      .where((r) => _schluessel.hasMatch(r.id))
      .toList();
  if (schluesse.isEmpty) {
    return ['ABSICHERUNG: keine Schlussfolgerungen S-… gefunden'];
  }
  for (final s in schluesse) {
    if ((s.feld('Notwendig') ?? '').toLowerCase() != 'ja') continue;
    final ids = <String>{
      for (final m in _hRef.allMatches(s.feld('Hinweise') ?? '')) m.group(0)!,
    };
    final sId = RegExp(
      r'(?<![\p{L}\p{N}_])' + RegExp.escape(s.id) + r'(?![\p{L}\p{N}_])',
      unicode: true,
    );
    for (final hw in k.datensaetze.values) {
      if (hw.id.startsWith('HW-') && sId.hasMatch(hw.feld('Stützt') ?? '')) {
        ids.add('H-${hw.id.substring(3)}');
      }
    }
    final sortiert = ids.toList()..sort();
    final hs = [
      for (final x in sortiert)
        if (k.datensaetze.containsKey(x)) k.datensaetze[x]!,
    ];
    final unblock = hs.where((h) {
      final hw = k.datensaetze['HW-${h.id.substring(2)}'];
      return hw != null &&
          (hw.feld('Blockierbar durch') ?? '').toLowerCase().startsWith('nein');
    });
    if (unblock.isEmpty) {
      f.add('ABSICHERUNG ${s.id}: kein unblockierbarer Hinweis');
    }
    for (var n = 4; n <= 20; n++) {
      final da = hs.where((h) => verfuegbar(k, h, n));
      final quellen = <String>{
        for (final h in da) (h.feld('Quelle') ?? '').replaceAll(_leer, ' '),
      };
      final soll = n == 20 ? 3 : 2;
      if (quellen.length < soll) {
        f.add(
          'ABSICHERUNG ${s.id} N=$n: ${quellen.length} unabhängige Quellen (Soll $soll)',
        );
      }
    }
  }
  for (final h in k.datensaetze.values) {
    if (!_hKennung.hasMatch(h.id)) continue;
    final mn = h.feld('Min') ?? '';
    int? echt;
    for (var n = 4; n <= 20; n++) {
      if (verfuegbar(k, h, n)) {
        echt = n;
        break;
      }
    }
    if (_istZiffern(mn) &&
        echt != null &&
        int.parse(mn) != echt &&
        (h.feld('Quelle') ?? '').contains('G')) {
      f.add(
        echt > int.parse(mn)
            ? 'MIN ${h.id}: Min $mn, erreichbar aber erst ab $echt'
            : 'MIN ${h.id}: Min $mn, erreichbar schon ab $echt',
      );
    }
    if (echt == null) f.add('MIN ${h.id}: in keiner Besetzung erreichbar');
    if (!k.datensaetze.containsKey('HW-${h.id.substring(2)}')) {
      f.add(
        'HINWEIS ${h.id}: Wahrheitsdatensatz HW-${h.id.substring(2)} fehlt',
      );
    }
  }
  return f;
}

/// Zeitleiste: eine Person kann zur selben Uhrzeit nur an einem Ort sein.
List<String> probeZeit(KrimiKanon k) {
  final f = <String>[];
  final belegt = <String, Map<String, (String, String)>>{};
  for (final z in k.datensaetze.values) {
    if (!z.id.startsWith('Z-')) continue;
    var t = z.feld('Zeit') ?? '';
    if (!_uhrzeit.hasMatch(t)) continue;
    if (t.length == 5) t += ':00';
    for (final m in _wer.allMatches(z.feld('Wer') ?? '')) {
      final wer = m.group(1)!;
      final ort = z.feld('Ort') ?? '';
      final proWer = belegt.putIfAbsent(
        wer,
        () => <String, (String, String)>{},
      );
      final alt = proWer[t];
      if (alt != null && alt.$1 != ort) {
        f.add('ZEIT $wer $t: ${alt.$1} (${alt.$2}) und $ort (${z.id})');
      }
      proWer[t] = (ort, z.id);
    }
  }
  return f;
}

/// Entscheidungsbaum: Datensätze D/DW je Phase, Optionen A/B/C und Ergebnisse.
List<String> probeD(KrimiKanon k) {
  final f = <String>[];
  for (final p in [1, 2, 3]) {
    for (final i in [1, 2, 3]) {
      final d = k.datensaetze['D$p-$i'];
      final dw = k.datensaetze['DW$p-$i'];
      if (d == null || dw == null) {
        f.add('D$p-$i: Datensatz D oder DW fehlt');
        continue;
      }
      for (final m in _hRef.allMatches(d.feld('Begründbar durch') ?? '')) {
        final h = m.group(0)!;
        final hr = k.datensaetze[h];
        if (hr == null) continue;
        final ph = hr.feld('Phase') ?? '';
        if (_istZiffern(ph) && int.parse(ph) > p) {
          f.add('D$p-$i: $h erst ab Phase $ph');
        }
        if (!verfuegbar(k, hr, 4)) f.add('D$p-$i: $h bei N=4 nicht erreichbar');
      }
      final werte = {
        dw.feld('Echte Spur') ?? '',
        dw.feld('Falsche Fährte') ?? '',
        dw.feld('Ablenkung') ?? '',
      };
      if (!(werte.length == 3 && werte.containsAll(['A', 'B', 'C']))) {
        f.add(
          'DW$p-$i: Optionen nicht genau A/B/C verteilt: ${_pyMenge(werte)}',
        );
      }
      for (final o in ['A', 'B', 'C']) {
        if ((dw.feld('Ergebnis $o') ?? '').isEmpty) {
          f.add('DW$p-$i: Ergebnis $o fehlt');
        }
      }
      for (final o in ['Option A', 'Option B', 'Option C']) {
        final txt = d.feld(o) ?? '';
        for (final m in _rolle.allMatches(txt)) {
          final r = m.group(1)!;
          if (int.parse(r) > 4) f.add('D$p-$i: $o nennt Erweiterungsrolle R$r');
        }
      }
    }
  }
  return f;
}

/// Ereignisse: je Rolle und Phase ein Datensatz E mit zwei bis drei Optionen und Folgen.
List<String> probeE(KrimiKanon k) {
  final f = <String>[];
  for (final p in [1, 2, 3]) {
    for (var r = 1; r <= 20; r++) {
      final rr = _nr2(r);
      final e = k.datensaetze['E$p-$rr'];
      if (e == null) {
        f.add('E$p-$rr fehlt');
        continue;
      }
      final opts = e.felder.keys
          .where((name) => name.startsWith('Option '))
          .toList();
      if (opts.length < 2 || opts.length > 3) {
        f.add('E$p-$rr: ${opts.length} Optionen (2–3 verlangt)');
      }
      for (final o in opts) {
        if (!(e.feld(o) ?? '').contains('→ Folge:')) {
          f.add('E$p-$rr.$o: Folge fehlt');
        }
      }
    }
  }
  return f;
}

/// Vollständigkeit: Rollenregister, Geschlechterverteilung je Block und Pflichtfragen.
List<String> probeVollst(KrimiKanon k) {
  final f = <String>[];
  const teile = [
    'STAMM',
    'ÖFFENTLICH',
    'GEHEIM',
    'WISSEN',
    'VERBINDUNGEN',
    'PLOT',
    'LÜGE',
  ];
  for (var r = 1; r <= 20; r++) {
    for (final t in teile) {
      if (!k.datensaetze.containsKey('R${_nr2(r)}-$t')) {
        f.add('K2: R${_nr2(r)}-$t fehlt');
      }
    }
  }
  // Je Block (vier Rollen) zwei weibliche [0] und zwei männliche [1] Rollen.
  final ges = <int, List<int>>{};
  for (var r = 1; r <= 20; r++) {
    final st = k.datensaetze['R${_nr2(r)}-STAMM'];
    if (st == null) continue;
    final g = st.feld('Geschlecht') ?? '';
    final zaehler = ges.putIfAbsent((r - 1) ~/ 4, () => [0, 0]);
    zaehler[g.startsWith('w') ? 0 : 1]++;
  }
  final bloecke = ges.keys.toList()..sort();
  for (final b in bloecke) {
    final w = ges[b]![0];
    final m = ges[b]![1];
    if (w != 2 || m != 2) {
      f.add('K2: Block ${b * 4 + 1}–${b * 4 + 4} hat $w w / $m m (Soll 2/2)');
    }
  }
  for (var i = 1; i <= 7; i++) {
    if (!k.datensaetze.containsKey('PF-$i')) {
      f.add('K1: Pflichtfrage PF-$i fehlt');
    }
  }
  return f;
}

/// Alle Proben in der Reihenfolge von kanon.py.
Map<String, List<String>> alleProben(KrimiKanon k) => {
  'syntax': probeSyntax(k),
  'vollst': probeVollst(k),
  'ersatz': probeErsatz(k),
  'last': probeLast(k),
  'absicherung': probeAbsicherung(k),
  'zeit': probeZeit(k),
  'd': probeD(k),
  'e': probeE(k),
};

/// Rollennummer aus einem Text (`R07` → 7), `null` wenn keine vorkommt.
int? _rnum(String? s) {
  final m = _rolle.firstMatch(s ?? '');
  return m == null ? null : int.parse(m.group(1)!);
}

/// Zwei Stellen mit führender Null, wie `:02d` in Python.
String _nr2(int n) => n.toString().padLeft(2, '0');

/// Ganzzahl aus reinen ASCII-Ziffern (Pythons `isdigit` für den Kanon).
bool _istZiffern(String s) =>
    s.isNotEmpty && s.codeUnits.every((c) => c >= 0x30 && c <= 0x39);

/// Mengendarstellung wie in Python, etwa `{'A', 'B'}` (sortiert).
String _pyMenge(Set<String> s) {
  final sortiert = s.toList()..sort();
  return '{${sortiert.map((x) => "'$x'").join(', ')}}';
}
