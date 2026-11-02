/// Teil 11: die vier versiegelten Fassungen WW4, JM3, RN7, YW4 (RK 7, MECH 10.4,
/// Kap. 17 der Fall-Bibel). Je Fassung vier Seiten mit gleicher Gestalt (E9):
/// Außenseite nur mit Code, Ziel und Zeitleiste, Was nur du weißt bis Stufe 3,
/// Notizen. Eine Schriftgröße je Seite für alle vier, damit Länge und Aufbau
/// nichts verraten.
///
/// Stand: einfache, aber echte Fassung aus dem Inhalt (Gerüst G2); Feinheiten
/// baut der Teil-Agent 11.
library;

import 'package:pdf/widgets.dart' as pw;

import 'inhalt.dart';
import 'kontext.dart';
import 'satz.dart';

/// Setzt Teil 11 (versiegelte Fassungen) in [doc].
void kammerFassungen(pw.Document doc, KammerKontext k) => kammerTeilSetzen(doc, k, '11', (s) {
      final x = k.satz;
      String u(String schluessel) => k.ui('11', schluessel);
      final fassungen = [for (final p in k.besetzung.verdaechtige) k.rolle(p).fassung!];

      List<pw.Widget> seite2(KammerFassung f, double g) => [
            x.ueberschrift(u('deinZiel')),
            x.absatz(f.ziel, groesse: g),
            x.ueberschrift(u('wasWirklichGeschah')),
            x.tabelle(kopf: [u('zeitleiste.zeit'), u('zeitleiste.text')], zeilen: [for (final z in f.zeitleiste) [z.zeit, z.text]], spalten: [1, 6], groesse: g),
          ];
      List<pw.Widget> seite3(KammerFassung f, double g) => [
            x.ueberschrift(u('wasNurDuWeisst')),
            x.liste(f.wasNurDuWeisst, groesse: g),
            x.ueberschrift(u('heftUndWahrheit')),
            x.absatz(f.heftUndWahrheit, groesse: g),
            x.ueberschrift(u('wennEsEngWird')),
            x.liste(f.wennEsEngWird, groesse: g),
            x.ueberschrift(u('stufe3')),
            x.absatz(u('stufe3.bedingung'), groesse: g),
            pw.SizedBox(height: 4),
            x.kasten([x.absatz(f.stufe3, groesse: g)]),
            pw.SizedBox(height: 4),
            x.absatz(u('stufe3.danach'), groesse: g),
          ];

      // Eine Schriftgröße je Seite für alle vier Fassungen (gleiche Gestalt, E9).
      final breite = KammerSatz.satzBreite();
      final platz = s.platz();
      final g2 = s.gemeinsameGroesse([for (final f in fassungen) (g) => pw.Column(children: seite2(f, g))], breite: breite, hoehe: platz, start: 11, wo: 'zeitleiste');
      final g3 = s.gemeinsameGroesse([for (final f in fassungen) (g) => pw.Column(children: seite3(f, g))], breite: breite, hoehe: platz, start: 11, wo: 'stufe3');

      for (final f in fassungen) {
        s.bereichSetzen(f.code, (h) {
          h.versiegelt(code: f.code, hinweis: u('aussen.hinweis'));
          h.seite(seite2(f, g2), wo: 'zeitleiste');
          h.seite(seite3(f, g3), wo: 'stufe3');
          h.seite(const [], notizen: true, wo: 'notizen');
        });
      }
    });
