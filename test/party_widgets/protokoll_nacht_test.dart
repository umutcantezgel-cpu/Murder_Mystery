// Protokoll der Nacht in der Auflösung (Finale §3.10): Bei 320 und 390 Pixel Breite, mit normaler und
// doppelter Schrift überlappt nichts. Jede Zeile hält Namen, Sinnbilder und Zielfotos in ihrem eigenen
// Rechteck; die Sinnbilder stehen auf der Höhe des Namens, nie darüber in der Zeile davor; unter einem
// Zielfoto bleibt bis zur nächsten Zeile Platz für seinen Schatten. Kein Überlauf im ganzen Blatt (auch die
// Leisten: „Zusammenhalt“ lief bei 320 px und 200 % über den Rand).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte/party/bildschirme/einfluss_teile.dart';
import 'package:mordakte/party/bildschirme/moment.dart';
import 'package:mordakte/stil/mappe/foto.dart';
import 'package:mordakte_core/mordakte_core.dart';

import 'einfluss_hilfe.dart';
import 'hilfe.dart';

/// Schatten eines Fotoabzugs nach unten: Versatz 5 und Unschärfe 10 (`MFotoabzug`).
const _schatten = 10.0;

/// Das Blatt liegt leicht schräg (`MBlatt.neigung`): Rechtecke weichen darum um Bruchteile eines Pixels ab.
const _toleranz = 1.0;

Future<void> _zeigen(WidgetTester t, Widget kind, double breite, double schrift) async {
  t.view.physicalSize = Size(breite, 2400);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.resetPhysicalSize);
  addTearDown(t.view.resetDevicePixelRatio);
  await t.pumpWidget(MaterialApp(
    theme: ThemeData.dark(),
    builder: (context, child) => MediaQuery(data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(schrift)), child: child!),
    home: Scaffold(body: SingleChildScrollView(padding: const EdgeInsets.all(20), child: kind)),
  ));
  await t.pump();
}

/// Rechtecke aller Treffer von [f] in Baumreihenfolge.
List<Rect> _rechtecke(WidgetTester t, Finder f) => [for (var i = 0; i < f.evaluate().length; i++) t.getRect(f.at(i))];

void main() {
  setUpAll(echteSchriften);

  for (final breite in [320.0, 390.0]) {
    for (final schrift in [1.0, 2.0]) {
      testWidgets('Protokoll der Nacht bei $breite px, Schrift ${schrift * 100} %: keine Überlappung', (t) async {
        // Vier Rollen: Ahmet deckt sich, Fatma zeigt, Olli hilft, Can lauscht – Zeilen mit und ohne Zielfoto im Wechsel.
        final s = einflussSitzung();
        einflussBis(s, PartyPhase.aufloesung);
        final a = s.einflussAufloesung!;
        final d = EinflussDarstellung.sitzung(s);
        await _zeigen(t, EinflussAufloesungAnsicht(aufloesung: a, darstellung: d, punkte: s.spiel.punkte), breite, schrift);
        expect(t.takeException(), isNull);

        final zeilen = [
          for (final r in a.rollen)
            (
              rolle: r,
              zeile: find.byKey(ValueKey('protokoll-$r')),
            ),
        ];
        var mitFoto = 0, ohneFoto = 0;
        Rect? vorige;
        double? fotoUnten;
        for (final (:rolle, :zeile) in zeilen) {
          final z = t.getRect(zeile);
          final name = t.getRect(find.descendant(of: zeile, matching: find.text(d.name(rolle))));
          final symbole = _rechtecke(t, find.descendant(of: zeile, matching: find.byType(Icon)));
          final fotos = _rechtecke(t, find.descendant(of: zeile, matching: find.byType(MFotoabzug)));
          expect(symbole, hasLength(a.protokoll.length), reason: '$rolle: ein Sinnbild je Runde');
          fotos.isEmpty ? ohneFoto++ : mitFoto++;
          // Zeilen liegen untereinander, ohne sich zu schneiden.
          if (vorige != null) expect(z.top, greaterThanOrEqualTo(vorige.bottom - _toleranz), reason: '$rolle unter der Zeile davor');
          // Was zur Zeile gehört, liegt in ihrem Rechteck.
          for (final r in [name, ...symbole, ...fotos]) {
            expect(z.inflate(_toleranz).contains(r.topLeft) && z.inflate(_toleranz).contains(r.bottomRight), isTrue, reason: '$rolle: $r in $z');
          }
          // Sinnbilder auf der Höhe des Namens: Ihre Mitte liegt in der Namenszeile, nie darüber.
          for (final r in symbole) {
            expect(r.top, greaterThanOrEqualTo(name.top - _toleranz), reason: '$rolle: Sinnbild nicht über dem Namen');
            expect(r.center.dy, inInclusiveRange(name.top - _toleranz, name.bottom + _toleranz), reason: '$rolle: Sinnbild auf der Höhe des Namens');
          }
          // Zielfotos hängen unter ihrem Sinnbild, nie darüber und nie daneben in die Spalte.
          for (final f in fotos) {
            expect(symbole.any((r) => f.top >= r.bottom - _toleranz && f.center.dx > r.left && f.center.dx < r.right), isTrue,
                reason: '$rolle: Foto $f unter einem Sinnbild');
          }
          // Unter dem Foto der vorigen Zeile bleibt Platz für den Schatten bis zum Inhalt dieser Zeile.
          final oben = [name, ...symbole, ...fotos].map((r) => r.top).reduce((x, y) => x < y ? x : y);
          if (fotoUnten != null) expect(oben - fotoUnten, greaterThanOrEqualTo(_schatten), reason: '$rolle: Abstand zum Foto darüber');
          fotoUnten = fotos.isEmpty ? null : fotos.map((r) => r.bottom).reduce((x, y) => x > y ? x : y);
          vorige = z;
        }
        expect((mitFoto, ohneFoto), (3, 1), reason: 'Zeilen mit und ohne Zielfoto');
      });
    }
  }
}
