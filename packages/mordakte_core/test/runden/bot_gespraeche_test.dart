import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/runden.dart';
import 'package:test/test.dart';

import '../party/kanon_hilfe.dart';

/// Texte einer Akte. Die Altfälle des Gesprächsmodells legacy laufen über das Gewölbe (Rollenzahl 4 bis 20) und
/// Ravensmoor (vier Pfade); der Schlosskeller hat das Modell befragung (A-051).
Texte texteLaden([String akte = 'schlosskeller']) =>
    Texte(ladeKanon(akte), Textsammlung.lade((p) => leseJson('$repoWurzel/content/party/$akte/$p')));

/// Ist [quelle] ein Tisch-Kettenglied (Lüge oder Beobachtung mit Kanal pflichtgespraech)?
bool _tisch(Texte texte, String quelle) =>
    quelle.startsWith('luege:') ||
    (quelle.startsWith('beobachtung:') && texte.beobachtung(quelle.split(':').last)!['kanal'] == 'pflichtgespraech');

void main() {
  test('Gewölbe (legacy), 4–20 Rollen: drei Sprechblasen pro Bot und Runde, nur freigegebene Quellen', () {
    final texte = texteLaden('gewoelbe');
    for (var rollen = 4; rollen <= 20; rollen++) {
      final besetzt = texte.besetzung.besetzt(rollen);
      for (var runde = 1; runde <= 3; runde++) {
        final liste = botGespraeche(texte, rollen: rollen, runde: runde);
        expect(liste, hasLength(rollen * 3));
        for (final g in liste) {
          final roh = texte.sammlung.gespraeche.singleWhere((x) => x.id == g.id);
          expect(g.text, roh.text);
          expect(g.thema, roh.thema);
          expect(g.runde, runde);
          expect(g.partner, isNot(g.rolle));
          expect([...besetzt, Besetzung.detektiv], contains(g.partner));
          expect(g.preisgaben.map((z) => z.quelle), roh.preisgabe);
          for (final z in g.preisgaben) {
            final id = z.quelle.split(':').last;
            if (z.quelle.startsWith('beobachtung:')) {
              final b = texte.beobachtung(id)!;
              expect(b['wer'], g.rolle);
              expect(b['kanal'], 'pflichtgespraech');
              expect(z.text, b['text']);
              for (final pfad in texte.kanon.pfade) { expect(Kanon.giltIn(b['pfade'], pfad), isTrue); }
            } else {
              final l = texte.luege(id)!;
              expect(l['person'], g.rolle);
              expect(z.text, l['behauptung']);
              expect(z.text, isNot(l['wahrheit']));
            }
          }
        }
      }
    }
  });

  test('Ravensmoor (legacy, vier Pfade): alle Tisch-Kettenglieder sind vor ihrer Entscheidung in Sprechblasen erreichbar', () {
    final texte = texteLaden('ravensmoor');
    final ermittlung = Ermittlung(texte.kanon);
    expect(texte.kanon.pfade.length, greaterThan(1));
    for (final pfad in texte.kanon.pfade) {
      for (final e in ermittlung.entscheidungen) {
        final erreichbar = {
          for (var r = 1; r <= e.runde; r++)
            for (final g in botGespraeche(texte, rollen: texte.besetzung.maxRollen, runde: r))
              for (final z in g.preisgaben) z.quelle,
        };
        for (final quelle in e.begruendungFuer(pfad)!.kette) {
          if (_tisch(texte, quelle)) expect(erreichbar, contains(quelle), reason: '${e.id} / $pfad');
        }
      }
    }
  });

  for (final akte in ['gewoelbe', 'ravensmoor']) {
    test('$akte (legacy), alle Rollenzahlen und Pfade: Bots, Erzähler und Funde liefern jede Kette rechtzeitig', () {
      final texte = texteLaden(akte);
      final kanon = texte.kanon;
      final e = Ermittlung(kanon);
      final erz = Erzaehler(kanon);
      for (var n = texte.besetzung.minRollen; n <= texte.besetzung.maxRollen; n++) {
        final besetzt = texte.besetzung.besetzt(n).toSet();
        for (final pfad in kanon.pfade) {
          final bekannt = <String>{
            for (final f in kanon.figuren) 'merkmal:${f['id']}',
            for (final g in kanon.gegenstaende) if (g['sichtbar'] == true) 'karte:${g['id']}',
            for (final b in kanon.beobachtungen) if (b['kanal'] == 'erzaehler') 'beobachtung:${b['id']}',
          };
          for (var r = 1; r <= 3; r++) {
            bekannt.addAll([
              for (final g in botGespraeche(texte, rollen: n, runde: r, mitNpc: true))
                for (final z in g.preisgaben) z.quelle,
              for (final rolle in erz.npcPlan[r]?.entries ?? const <MapEntry<String, List<String>>>[])
                if (!besetzt.contains(rolle.key))
                  for (final b in rolle.value) 'beobachtung:$b',
            ]);
            for (final x in e.runde(r)) {
              expect(bekannt, containsAll(x.begruendungFuer(pfad)!.kette), reason: '$akte / $n Rollen / $pfad / ${x.id}');
              for (final fakt in e.faktenVon(x.richtig[pfad]!, pfad)) {
                bekannt.add('fakt:$fakt');
                final beobachtung = e.fakten[fakt]!.beobachtung;
                if (beobachtung != null) bekannt.add('beobachtung:$beobachtung');
              }
            }
          }
        }
      }
    });
  }

  test('Schlosskeller (befragung), 4–20 Rollen: ein Tischgespräch pro Bot und Runde, nie mit dem Detektiv, ohne Kettenglied', () {
    final texte = texteLaden();
    final glieder = tischKettenglieder(texte.kanon);
    for (var rollen = 4; rollen <= 20; rollen++) {
      final besetzt = texte.besetzung.besetzt(rollen);
      for (var runde = 1; runde <= 3; runde++) {
        final liste = botGespraeche(texte, rollen: rollen, runde: runde);
        expect(liste, hasLength(rollen));
        expect(liste.map((g) => g.rolle).toSet(), besetzt.toSet());
        for (final g in liste) {
          expect(g.partner, isNot(g.rolle));
          expect(besetzt, contains(g.partner));
          expect(g.text, isEmpty);
          expect(g.preisgaben.where((z) => glieder.containsKey(z.quelle)), isEmpty, reason: g.id);
        }
        // Kettenglieder erreichen den Detektiv nur in Befragungen, auch nicht über zusätzliche NPC-Blasen.
        final mitNpc = botGespraeche(texte, rollen: rollen, runde: runde, mitNpc: true);
        expect(mitNpc.expand((g) => g.preisgaben).where((z) => glieder.containsKey(z.quelle)), isEmpty);
      }
    }
  });

  test('Projektionen sind unveränderlich und enthalten keine Dossier-Struktur', () {
    final texte = texteLaden();
    final liste = botGespraeche(texte, rollen: 4, runde: 1);
    expect(() => liste.clear(), throwsUnsupportedError);
    expect(() => liste.first.preisgaben.clear(), throwsUnsupportedError);
    expect(() => botGespraeche(texte, rollen: 4, runde: 0), throwsArgumentError);
    expect(() => botAntwort(texte, texte.sammlung.befragungen['bf_ahmet_1']!).clear(), throwsUnsupportedError);
  });

  for (final akte in ['schlosskeller', 'gewoelbe', 'ravensmoor']) {
    test('$akte: fremde, verborgene und wertende Preisgaben scheitern geschlossen', () {
      final kanon = texteLaden(akte).kanon;
      // Kennungen der geladenen Akte: erste Kernrolle als Sprecherin, zweite als Partnerin, fremde Quellen aus ihrem Kanon.
      final rolle = kanon.kernverdaechtige.first;
      final partner = kanon.kernverdaechtige[1];
      final verboten = [
        'fakt:fremd', 'zeitleiste:fremd', 'unbekannt',
        if (kanon.beobachtungen.any((b) => b['kanal'] != 'pflichtgespraech'))
          'beobachtung:${kanon.beobachtungen.firstWhere((b) => b['kanal'] != 'pflichtgespraech')['id']}',
        'beobachtung:${kanon.beobachtungen.firstWhere((b) => b['kanal'] == 'pflichtgespraech' && b['wer'] != rolle)['id']}',
      ];
      for (final quelle in verboten) {
        final t = texteLaden(akte);
        t.sammlung.gespraeche
          ..clear()
          ..add(Gespraech({'id': 'g_${rolle}_1_1', 'rolle': rolle, 'runde': 1, 'nr': 1, 'partner': partner,
            'thema': 'probe', 'ziel': 'privat', 'text': 'probe', 'preisgabe': [quelle]}));
        expect(() => botGespraeche(t, rollen: 4, runde: 1), throwsStateError, reason: quelle);
        final b = BefragungText({'id': BefragungText.kennung(rolle, 1), 'rolle': rolle, 'runde': 1, 'thema': 'probe',
          'fragen': ['Wo warst du?', 'Was hast du gesehen?'], 'stichpunkte': <String>[], 'preisgabe': [quelle]});
        expect(() => botAntwort(t, b), throwsStateError, reason: quelle);
      }
    });
  }
}
