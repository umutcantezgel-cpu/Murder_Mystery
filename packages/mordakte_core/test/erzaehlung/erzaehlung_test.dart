// Gespräche mit Wahl (M6): Prüfer gegen den echten Kanon, Wege, Determinismus,
// Ereignisketten, Nachspiel und Architektur (ERZAEHLREGELN.md R1–R12).
import 'dart:io';

import 'package:mordakte_core/mordakte_core.dart';
import 'package:test/test.dart';

import '../party/kanon_hilfe.dart';

/// Alle Akten mit Gesprächen.
List<String> get _akten => [
      for (final d in Directory('$repoWurzel/content/erzaehlung').listSync().whereType<Directory>())
        if (File('${d.path}/gespraeche.json').existsSync()) d.uri.pathSegments.where((s) => s.isNotEmpty).last,
    ]..sort();

Erzaehlung _lade(String akte) => Erzaehlung.ausJson(leseJson('$repoWurzel/content/erzaehlung/$akte/gespraeche.json'));

/// Öffentlicher Rahmen des Falls (Erzähler-Intro und Rundenstarts): frei für Gespräche.
List<String> _offen(String akte) {
  final texte = <String>[];
  for (final n in ['erzaehler-intro.json', 'erzaehler-runden.json']) {
    final f = File('$repoWurzel/content/party/$akte/texte/$n');
    if (!f.existsSync()) continue;
    void sammle(Object? o) {
      if (o is Map) {
        if (o['text'] case final String t) texte.add(t);
        o.values.forEach(sammle);
      } else if (o is List) {
        o.forEach(sammle);
      }
    }

    sammle(leseJson(f.path));
  }
  return texte;
}

/// Alle Texte aus Täterfassungen, Finale und Auflösung: Daraus darf nichts in Gespräche wandern.
List<String> _geschuetzt(String akte) {
  final texte = <String>[];
  void sammle(Object? o) {
    if (o is Map) {
      if (o['text'] case final String t) texte.add(t);
      o.values.forEach(sammle);
    } else if (o is List) {
      o.forEach(sammle);
    } else if (o is String && o.length > 30) {
      texte.add(o);
    }
  }

  for (final f in Directory('$repoWurzel/content/party/$akte/texte').listSync().whereType<File>()) {
    final n = f.uri.pathSegments.last;
    if (n.startsWith('taeter-') || n.startsWith('erzaehler-finale') || n.startsWith('erzaehler-aufloesung')) sammle(leseJson(f.path));
  }
  return texte;
}

/// Alle Wahlfolgen eines Gesprächs (mit Fund und allen Flags), je als Liste der Wahlindizes.
List<List<int>> _wege(Randgespraech g, ErzaehlUmwelt u) {
  final wege = <List<int>>[];
  void geh(List<int> weg) {
    final lauf = GespraechsLauf(g, u);
    for (final i in weg) {
      lauf.waehle(lauf.wahlen[i]);
    }
    if (lauf.fertig) {
      wege.add(weg);
      return;
    }
    if (weg.length > 12) fail('${g.id}: Weg ohne Ende');
    for (var i = 0; i < lauf.wahlen.length; i++) {
      geh([...weg, i]);
    }
  }

  geh(const []);
  return wege;
}

void main() {
  final regeln = leseJson('$repoWurzel/content/party/textregeln.json');

  test('Es gibt Gespräche für mindestens Ravensmoor', () {
    expect(_akten, contains('ravensmoor'));
  });

  test('Das Verzeichnis nennt genau die Akten mit Gesprächen', () {
    final index = leseJson('$repoWurzel/content/erzaehlung/index.json');
    expect(index['format'], 'erzaehlung-index/1');
    expect([for (final a in index['akten'] as List) a as String]..sort(), _akten);
  });

  for (final akte in _akten) {
    group(akte, () {
      final e = _lade(akte);
      final k = ladeKanon(akte);

      test('Prüfer ohne Befund (Graph, Preisgaben, Fünf-Wort-Regel, Flags, Ton)', () {
        expect(pruefeErzaehlung(e, k, ton: Textpruefer(regeln), geschuetzt: _geschuetzt(akte), offen: _offen(akte)), isEmpty);
      });

      test('Jeder Weg endet, jeder Knoten wird erreicht, gleiche Wahlen geben gleichen Verlauf', () {
        final alleFlags = {for (final g in e.gespraeche) for (final n in g.knoten.values) ...n.setzt};
        for (final g in e.gespraeche) {
          final u = ErzaehlUmwelt(runde: 3, flags: alleFlags, hatFund: true);
          final erreicht = <String>{};
          for (final weg in _wege(g, u)) {
            final a = GespraechsLauf(g, u), b = GespraechsLauf(g, u);
            for (final i in weg) {
              a.waehle(a.wahlen[i]);
              b.waehle(b.wahlen[i]);
            }
            expect(a.knoten.id, b.knoten.id);
            expect(a.neueFlags, b.neueFlags);
            expect([for (final v in a.verlauf) v.figur], [for (final v in b.verlauf) v.figur]);
            final c = GespraechsLauf(g, u);
            erreicht.add(c.knoten.id);
            for (final i in weg) {
              c.waehle(c.wahlen[i]);
              erreicht.add(c.knoten.id);
            }
          }
          expect(erreicht, g.knoten.keys.toSet(), reason: '${g.id}: alle Knoten erreichbar');
        }
      });

      test('Kurze Tiefe: eine Wahl, dann Ende; aus: kein Gespräch', () {
        for (final g in e.gespraeche.where((g) => g.brauchtFlags.isEmpty)) {
          final kurz = GespraechsLauf(g, const ErzaehlUmwelt(runde: 1, tiefe: Erzaehltiefe.kurz));
          expect(kurz.wahlen, isNotEmpty);
          kurz.waehle(kurz.wahlen.first);
          expect(kurz.fertig, isTrue, reason: g.id);
          expect(g.verfuegbar(const ErzaehlUmwelt(runde: 3, tiefe: Erzaehltiefe.aus)), isFalse);
        }
      });

      test('Ereignisketten: Folgegespräche nur mit ihren Flags, ab ihrer Runde, in voller Tiefe', () {
        for (final g in e.gespraeche.where((g) => g.brauchtFlags.isNotEmpty)) {
          expect(g.verfuegbar(const ErzaehlUmwelt(runde: 3)), isFalse, reason: '${g.id} ohne Flag');
          expect(g.verfuegbar(ErzaehlUmwelt(runde: 3, flags: g.brauchtFlags.toSet())), isTrue, reason: '${g.id} mit Flag');
          expect(g.verfuegbar(ErzaehlUmwelt(runde: g.abRunde - 1, flags: g.brauchtFlags.toSet())), isFalse, reason: '${g.id} zu früh');
          expect(g.verfuegbar(ErzaehlUmwelt(runde: 3, flags: g.brauchtFlags.toSet(), tiefe: Erzaehltiefe.kurz)), isFalse);
        }
      });

      test('Jeder Zeuge hat ein erstes Gespräch ab Runde 1; geführte kommen nicht wieder', () {
        final figuren = {for (final g in e.gespraeche) g.figur};
        for (final f in figuren) {
          final erstes = e.offenFuer(f, const ErzaehlUmwelt(runde: 1));
          expect(erstes, isNotNull, reason: f);
          expect(e.offenFuer(f, const ErzaehlUmwelt(runde: 1), gefuehrt: {erstes!.id}), isNull, reason: f);
        }
      });

      test('Nachspiel: je Figur höchstens ein Satz, mindestens drei Enden je Figur', () {
        final alleFlags = {for (final g in e.gespraeche) for (final n in g.knoten.values) ...n.setzt};
        for (final richtig in [true, false]) {
          final n = e.nachspiel(alleFlags, richtig: richtig);
          final figuren = [for (final x in n) x.figur];
          expect(figuren.toSet().length, figuren.length);
        }
        final jeFigur = <String, int>{};
        for (final ep in e.epiloge) {
          if (ep.figur != null) jeFigur[ep.figur!] = (jeFigur[ep.figur!] ?? 0) + 1;
        }
        for (final f in {for (final g in e.gespraeche) g.figur}) {
          expect(jeFigur[f] ?? 0, greaterThanOrEqualTo(3), reason: '$f braucht mindestens drei Enden (R10)');
        }
      });
    });
  }

  test('Gegenprobe: Der Prüfer erkennt Verrat, Verdächtige, fehlende Ziele und Flags', () {
    final k = ladeKanon('ravensmoor');
    Map<String, Object?> knoten(String text, {List<String> preisgabe = const [], List<Map<String, Object?>> wahlen = const []}) =>
        {'text': text, 'preisgabe': preisgabe, 'wahlen': wahlen};
    final e = Erzaehlung.ausJson({
      'format': 'erzaehlung/1',
      'akte': 'ravensmoor',
      'gespraeche': [
        {
          'id': 'verrat',
          'figur': 'zofe',
          'start': 'a',
          'knoten': {
            'a': knoten('Beim Donnerschlag war Lady Constances Zimmer leer.', preisgabe: ['beobachtung:b_zofe_lady_leer'], wahlen: [
              {'haltung': 'freundlich', 'text': 'Danke.', 'ziel': 'b'},
              {'haltung': 'draengen', 'text': 'Weiter.', 'ziel': 'fehlt'},
            ]),
            'b': knoten('Ende.'),
          },
        },
        {'id': 'verdacht', 'figur': 'butler', 'start': 'a', 'brauchtFlags': ['nie_gesetzt'], 'knoten': {'a': knoten('Guten Abend.')}},
      ],
      'epiloge': const [],
    });
    final b = pruefeErzaehlung(e, k).join('\n');
    expect(b, contains('übernimmt'));
    expect(b, contains('nicht öffentlich'));
    expect(b, contains('Ziel fehlt'));
    expect(b, contains('verdächtig'));
    expect(b, contains('nie_gesetzt'));
  });

  test('Architektur: kein Würfel, kein Zufall, keine Zeit, kein Pfad im Erzählkern (R4–R6)', () {
    // Der Ablauf (erzaehlung.dart) kennt keinen Pfad; der Prüfer darf das Feld
    // `pfade` lesen, um „gilt in allen Pfaden“ zu prüfen.
    final immer = RegExp(r'\b(wuerfel|Wuerfel|nachtminute|Nachtminute|Rng|Random|FallCode|wertung|Wertung)\w*');
    final laufzeit = RegExp(r'\b(pfad|Pfad|taeter|Taeter)\w*');
    for (final f in Directory('$repoWurzel/packages/mordakte_core/lib/src/erzaehlung').listSync().whereType<File>()) {
      final code = [for (final z in f.readAsLinesSync()) if (!z.trimLeft().startsWith('//')) z].join('\n');
      expect(immer.allMatches(code).map((m) => m.group(0)).toList(), isEmpty, reason: f.path);
      if (f.path.endsWith('erzaehlung.dart')) expect(laufzeit.allMatches(code).map((m) => m.group(0)).toList(), isEmpty, reason: f.path);
      for (final m in RegExp(r"import '([^']+)'").allMatches(code)) {
        expect(['../party/kanon/kanon.dart', '../party/textpruefer.dart', 'erzaehlung.dart'], contains(m.group(1)), reason: '${f.path}: ${m.group(1)}');
      }
    }
  });
}
