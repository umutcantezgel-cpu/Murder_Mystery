/// Probe-Inhalt der Netz-Matrizen für die Läufe mit Einstimmung (A-063) und
/// „Dein Moment“ (Finale §3): Solange die Akte selbst keine Vorgeschichte, keine
/// Texte dafür oder die Fähigkeit `einfluss` nicht hat, ergänzt der Leser sie –
/// Teile einer Probe-Vorgeschichte im Setting, die Fähigkeiten in `akten.json`
/// und je fehlender Kennung einen Probetext (die Kennung selbst, kein Erzähltext).
/// Hat die Akte alles, liest er sie unverändert. Nur für die Matrizen; der
/// Produktionsserver liest immer das Dateisystem.
library;

import 'dart:convert';
import 'dart:io';

import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/runden.dart';

/// Teile der Probe-Vorgeschichte.
const _probeTeile = ['probe_eins', 'probe_zwei'];

/// Leser des Akten-Ordners [dir] (Pfade relativ dazu, auch `../akten.json` und `../zusatz/…`).
KanonLeser probeLeser(String dir, {bool einstimmung = false, bool einfluss = false}) {
  Map<String, Object?> echt(String p) => (jsonDecode(File('$dir/$p').readAsStringSync()) as Map).cast<String, Object?>();
  if (!einstimmung && !einfluss) return echt;
  final akte = Directory(dir).uri.pathSegments.where((s) => s.isNotEmpty).last;
  final setting = echt('setting.json');
  final mitTeilen = einstimmung && setting['vorgeschichte'] == null ? {...setting, 'vorgeschichte': _probeTeile, 'vorstellung': true} : setting;
  final akten = echt('../akten.json');
  final mitFaehigkeit = {
    ...akten,
    'akten': [
      for (final a in (akten['akten'] as List).cast<Map>())
        if (a['id'] == akte)
          {
            ...a,
            'faehigkeiten': {...(a['faehigkeiten'] as List? ?? const []), if (einstimmung) 'einstimmung', if (einfluss) 'einfluss'}.toList(),
          }
        else
          a,
    ],
  };
  Map<String, Object?> lies(String p) => switch (p) {
        'setting.json' => mitTeilen,
        '../akten.json' => mitFaehigkeit,
        _ => echt(p),
      };
  final kanon = Kanon.lade(lies);
  final e = Einstimmung.aus(kanon);
  final noetig = [
    if (einstimmung && e != null) ...[...e.katalog(), ...e.titel()],
    if (einfluss) ...einflussKatalog(EinflussRegeln.ausJson(echt('../zusatz/$akte/einfluss.json'), Ermittlung(kanon))),
  ];
  final vorhanden = Textsammlung.lade(echt).bausteine.keys.toSet();
  final fehlt = [for (final k in noetig) if (!vorhanden.contains(k)) k];
  if (fehlt.isEmpty) return lies;
  String bereich(String k) => k.startsWith('einfluss.') ? 'einfluss' : (k.startsWith('ui.') ? 'ui' : 'erzaehler');
  final dateien = {
    for (final b in {for (final k in fehlt) bereich(k)})
      'texte/probe-$b.json': <String, Object?>{
        'settingId': kanon.settingId,
        'bereich': b,
        'hinweis': 'Probe',
        'eintraege': [for (final k in fehlt) if (bereich(k) == b) {'id': k, 'text': 'Probe $k'}],
      },
  };
  final index = echt('texte/index.json');
  final mitProbe = {
    ...index,
    'dateien': [
      ...index['dateien'] as List,
      for (final d in dateien.entries) {'datei': d.key.substring('texte/'.length), 'bereich': d.value['bereich']},
    ],
  };
  return (p) => p == 'texte/index.json' ? mitProbe : (dateien[p] ?? lies(p));
}
