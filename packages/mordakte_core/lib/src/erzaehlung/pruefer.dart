// Prüfer der Gespräche mit Wahl (M6, Regeln R1–R12).
import '../party/kanon/kanon.dart';
import '../party/textpruefer.dart';
import 'erzaehlung.dart';

/// Prüft eine [Erzaehlung] gegen den [kanon]. Liefert Befunde als Sätze; leer
/// heißt: in Ordnung.
///
/// - Nur unbesetzbare Zeugen sprechen: keine Kernverdächtigen (R1, R3).
/// - Graph: Start und Ziele gibt es, jeder Knoten ist erreichbar, keine
///   Kreise, je Knoten 2–4 Wahlen mit verschiedenen Haltungen.
/// - Preisgaben nur aus Pflichtgesprächen der eigenen Figur, gültig in allen
///   Pfaden, oder ihre öffentliche Behauptung (R2).
/// - Kein Text teilt fünf Wörter am Stück mit verborgenen Beobachtungen,
///   Wahrheiten, Rollengeheimnissen oder [geschuetzt] (R2); Folgen aus
///   öffentlichen Beobachtungen und aus [offen] (etwa dem Erzähler-Intro) sind frei.
/// - Flags, die verlangt werden, setzt irgendein Knoten (R9).
/// - Tonregeln über [ton] (R12).
List<String> pruefeErzaehlung(
  Erzaehlung e,
  Kanon kanon, {
  Textpruefer? ton,
  Iterable<String> geschuetzt = const [],
  Iterable<String> offen = const [],
}) {
  final befunde = <String>[];
  final figuren = {for (final f in kanon.figuren) f['id'] as String: f};
  final kern = kanon.kernverdaechtige.toSet();
  final beob = {
    for (final b in kanon.json['beobachtungen.json']!['beobachtungen'] as List) (b as Map)['id'] as String: b.cast<String, Object?>(),
  };

  // Texte, aus denen nichts in Gespräche wandern darf.
  final sperre = <String>[
    ...geschuetzt,
    for (final b in beob.values)
      if (b['kanal'] != 'pflichtgespraech' || b['pfade'] != 'alle') b['text'] as String,
    for (final f in figuren.values) ...[
      if (f['roleSecret'] case final String s) s,
      for (final l in (f['luegen'] as List? ?? const [])) ...[
        if ((l as Map)['wahrheit'] case final String w) w,
        if (l['duWahrheit'] case final String w) w,
      ],
    ],
  ];
  // Öffentliche Sätze (Pflichtgespräche, in allen Pfaden, und der Rahmen des
  // Falls) verraten nichts, auch wenn sie zusätzlich in geschützten Texten stehen.
  final oeffentlich = <String>{
    for (final b in beob.values)
      if (b['kanal'] == 'pflichtgespraech' && b['pfade'] == 'alle') ..._fuenfer(b['text'] as String),
    for (final t in offen) ..._fuenfer(t),
  };
  final gesperrt = <String>{for (final t in sperre) ..._fuenfer(t)}..removeAll(oeffentlich);

  final gesetzt = <String>{for (final g in e.gespraeche) for (final k in g.knoten.values) ...k.setzt};
  final ids = <String>{};

  void text(String ort, String t) {
    for (final f in _fuenfer(t)) {
      if (gesperrt.contains(f)) {
        befunde.add('$ort: übernimmt „$f“ aus einer geschützten Kanonstelle (R2)');
        break;
      }
    }
    if (ton != null) {
      for (final b in ton.pruefe(TextQuelle(ort: ort, text: t, vorlesen: false))) {
        befunde.add('$ort: ${b.regel} („${b.auszug}“)');
      }
    }
  }

  for (final g in e.gespraeche) {
    final o = 'gespraech ${g.id}';
    if (!ids.add(g.id)) befunde.add('$o: Kennung doppelt');
    final f = figuren[g.figur];
    if (f == null) {
      befunde.add('$o: Figur ${g.figur} gibt es nicht');
      continue;
    }
    if (kern.contains(g.figur) || f['isPotentialKiller'] == true) befunde.add('$o: ${g.figur} ist verdächtig; Gespräche nur mit Zeugen (R1/R3)');
    if (g.abRunde < 1 || g.abRunde > 3) befunde.add('$o: abRunde ${g.abRunde} außerhalb 1–3');
    for (final fl in g.brauchtFlags) {
      if (!gesetzt.contains(fl)) befunde.add('$o: Flag $fl wird nirgends gesetzt (R9)');
    }
    if (!g.knoten.containsKey(g.start)) {
      befunde.add('$o: Start ${g.start} fehlt');
      continue;
    }
    // Erreichbarkeit und Kreise (Tiefensuche).
    final erreicht = <String>{};
    final aufStapel = <String>{};
    void besuche(String id, List<String> weg) {
      final k = g.knoten[id];
      if (k == null) {
        befunde.add('$o: Ziel $id fehlt (von ${weg.isEmpty ? g.start : weg.last})');
        return;
      }
      if (aufStapel.contains(id)) {
        befunde.add('$o: Kreis über $id');
        return;
      }
      if (!erreicht.add(id)) return;
      aufStapel.add(id);
      for (final w in k.wahlen) {
        for (final z in w.ziele) {
          besuche(z.knoten, [...weg, id]);
        }
      }
      aufStapel.remove(id);
    }

    besuche(g.start, const []);
    for (final id in g.knoten.keys) {
      if (!erreicht.contains(id)) befunde.add('$o: Knoten $id ist unerreichbar');
    }
    for (final k in g.knoten.values) {
      final ko = '$o/${k.id}';
      text(ko, k.text);
      if (k.wahlen.isNotEmpty && (k.wahlen.length < 2 || k.wahlen.length > 4)) befunde.add('$ko: ${k.wahlen.length} Wahlen (erlaubt 2–4)');
      final haltungen = <Haltung>{};
      for (final w in k.wahlen) {
        if (!haltungen.add(w.haltung)) befunde.add('$ko: Haltung ${w.haltung.name} doppelt');
        text('$ko/${w.haltung.name}', w.text);
        if (w.ziele.isEmpty) befunde.add('$ko/${w.haltung.name}: kein Ziel');
        if (w.ziele.isNotEmpty && !w.ziele.last.wenn.leer) befunde.add('$ko/${w.haltung.name}: letztes Ziel braucht keine Bedingung (Rückfall)');
        if (w.brauchtFlag case final fl? when !gesetzt.contains(fl)) befunde.add('$ko: Flag $fl wird nirgends gesetzt (R9)');
        for (final z in w.ziele) {
          if (z.wenn.flag case final fl? when !gesetzt.contains(fl)) befunde.add('$ko: Flag $fl wird nirgends gesetzt (R9)');
        }
      }
      // Ohne Wahl ohne vorlegen muss es weitergehen (vorlegen braucht einen Fund).
      if (k.wahlen.isNotEmpty && k.wahlen.every((w) => w.haltung == Haltung.vorlegen || w.brauchtFlag != null)) {
        befunde.add('$ko: ohne Fund und Flag bleibt keine Wahl');
      }
      for (final p in k.preisgabe) {
        final teile = p.split(':');
        if (teile.length != 2) {
          befunde.add('$ko: Preisgabe $p unlesbar');
          continue;
        }
        switch (teile[0]) {
          case 'beobachtung':
            final b = beob[teile[1]];
            if (b == null) {
              befunde.add('$ko: Beobachtung ${teile[1]} gibt es nicht');
            } else if (b['wer'] != g.figur || b['kanal'] != 'pflichtgespraech' || b['pfade'] != 'alle') {
              befunde.add('$ko: ${teile[1]} ist nicht öffentlich von ${g.figur} (R2)');
            }
          case 'luege':
            final hat = (f['luegen'] as List? ?? const []).any((l) => (l as Map)['id'] == teile[1]);
            if (!hat) befunde.add('$ko: Behauptung ${teile[1]} gehört nicht zu ${g.figur}');
          default:
            befunde.add('$ko: Preisgabe $p unbekannter Art');
        }
      }
    }
  }

  final epIds = <String>{};
  for (final ep in e.epiloge) {
    final o = 'epilog ${ep.id}';
    if (!epIds.add(ep.id)) befunde.add('$o: Kennung doppelt');
    if (ep.figur != null && !figuren.containsKey(ep.figur)) befunde.add('$o: Figur ${ep.figur} gibt es nicht');
    if (ep.ergebnis != null && ep.ergebnis != 'richtig' && ep.ergebnis != 'falsch') befunde.add('$o: Ergebnis ${ep.ergebnis} unbekannt');
    for (final fl in ep.flags) {
      if (!gesetzt.contains(fl)) befunde.add('$o: Flag $fl wird nirgends gesetzt (R9)');
    }
    text(o, ep.text);
  }
  return befunde;
}

final _wortRe = RegExp(r'[\p{L}\p{N}]+', unicode: true);

/// Alle Folgen aus fünf Wörtern (klein geschrieben) eines Textes.
Set<String> _fuenfer(String t) {
  final w = [for (final m in _wortRe.allMatches(t)) m.group(0)!.toLowerCase()];
  return {for (var i = 0; i + 5 <= w.length; i++) w.sublist(i, i + 5).join(' ')};
}
