import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/runden.dart';
import 'package:test/test.dart';

import '../party/kanon_hilfe.dart';

Texte texteLaden() => Texte(kanon, Textsammlung.lade((p) => leseJson('$repoWurzel/content/party/schlosskeller/$p')));

void main() {
  final texte = texteLaden();

  test('4–20 Rollen: drei Sprechblasen pro Bot und Runde, nur freigegebene Quellen', () {
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
              for (final pfad in kanon.pfade) { expect(Kanon.giltIn(b['pfade'], pfad), isTrue); }
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

  test('Alle Tisch-Kettenglieder sind vor ihrer Entscheidung in Sprechblasen erreichbar', () {
    final ermittlung = Ermittlung(kanon);
    for (final pfad in kanon.pfade) {
      for (final e in ermittlung.entscheidungen) {
        final erreichbar = {
          for (var r = 1; r <= e.runde; r++)
            for (final g in botGespraeche(texte, rollen: 20, runde: r))
              for (final z in g.preisgaben) z.quelle,
        };
        for (final quelle in e.begruendungFuer(pfad)!.kette) {
          if (quelle.startsWith('luege:') ||
              (quelle.startsWith('beobachtung:') && texte.beobachtung(quelle.split(':').last)!['kanal'] == 'pflichtgespraech')) {
            expect(erreichbar, contains(quelle), reason: '${e.id} / $pfad');
          }
        }
      }
    }
  });

  test('4–20 Rollen und alle Pfade: Bots, Erzähler und Funde liefern jede Kette rechtzeitig', () {
    final e = Ermittlung(kanon);
    final erz = Erzaehler(kanon);
    for (var n = 4; n <= 20; n++) {
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
            expect(bekannt, containsAll(x.begruendungFuer(pfad)!.kette), reason: '$n Rollen / $pfad / ${x.id}');
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

  test('Projektionen sind unveränderlich und enthalten keine Dossier-Struktur', () {
    final liste = botGespraeche(texte, rollen: 4, runde: 1);
    expect(() => liste.clear(), throwsUnsupportedError);
    expect(() => liste.first.preisgaben.clear(), throwsUnsupportedError);
    expect(() => botGespraeche(texte, rollen: 4, runde: 0), throwsArgumentError);
  });

  test('Fremde, verborgene und wertende Preisgaben scheitern geschlossen', () {
    final verboten = [
      'fakt:fremd', 'zeitleiste:fremd', 'unbekannt',
      'beobachtung:${kanon.beobachtungen.firstWhere((b) => b['kanal'] != 'pflichtgespraech')['id']}',
      'beobachtung:${kanon.beobachtungen.firstWhere((b) => b['kanal'] == 'pflichtgespraech' && b['wer'] != 'ahmet')['id']}',
    ];
    for (final quelle in verboten) {
      final t = texteLaden();
      t.sammlung.gespraeche
        ..clear()
        ..add(Gespraech({'id': 'g_ahmet_1_1', 'rolle': 'ahmet', 'runde': 1, 'nr': 1, 'partner': 'fatma',
          'thema': 'probe', 'ziel': 'privat', 'text': 'probe', 'preisgabe': [quelle]}));
      expect(() => botGespraeche(t, rollen: 4, runde: 1), throwsStateError);
    }
  });
}
