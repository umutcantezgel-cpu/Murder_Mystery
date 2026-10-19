import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mordakte_core/mordakte_core.dart' show DetectiveClass, detectiveClasses;
import 'package:mordakte_core/runden.dart' show KartenKatalog;
import 'package:provider/provider.dart';

import '../../l10n/lookup.dart';
import '../../meta/meta_store.dart';
import '../../stil/mappe/assistent_formular.dart' show MFormkopf;
import '../../stil/mappe/material.dart' show MaterialZufall;
import '../../stil/stil.dart';
import '../../ui/icons.dart';

/// Die fünf Detektivklassen nach Freischaltung: erst die frei verfügbaren, dann
/// die höheren Ränge (bei gleichem Rang bleibt die Reihenfolge der Regeln).
List<DetectiveClass> klassenNachRang() {
  final liste = detectiveClasses.values.toList();
  final reihenfolge = {for (var i = 0; i < liste.length; i++) liste[i].id: i};
  liste.sort((a, b) {
    final r = a.unlockRank.compareTo(b.unlockRank);
    return r != 0 ? r : reihenfolge[a.id]!.compareTo(reihenfolge[b.id]!);
  });
  return liste;
}

/// „Deine Ermittlerklasse“: eine Karteikarte mit den Klassen dieses Geräts als
/// Etiketten; die gewählte ist mit Füllertinte umkringelt. Die Wahl liegt im
/// [MetaStore] (Ausrüstung), gilt für jeden Abend und bestimmt die Rolle
/// `klasse:<name>` für die Belohnung. Noch nicht freigeschaltete Klassen sind
/// gesperrt und nennen den nötigen Rang.
///
/// Darunter steht, was die gewählte Klasse auf der Karte tut, wenn die Akte
/// Klassen kennt ([karte], `AkteInfo.hat('klassen')`), mit dem Satz „Diese
/// Fähigkeit ändert nie Fakten, Punkte oder Würfel“ (A-055). Getrennt davon
/// folgen die Sammelkarten der Klasse aus dem [katalog]: Sie wirken erst, wenn
/// jemand sie ausspielt, und nicht jede ist schon in der Sammlung dieses
/// Geräts; die besessenen sind markiert.
class KlasseZeile extends StatelessWidget {
  const KlasseZeile({super.key, this.karte = false, this.katalog});

  /// Wirkt die Klasse in dieser Akte auf der Karte?
  final bool karte;

  /// Katalog der Sammelkarten (Klassenkarten der Akte `mordakte`); `null`, solange er lädt.
  final KartenKatalog? katalog;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final meta = context.watch<MetaStore>();
    final gewaehlt = meta.loadout.cls;
    return MBlatt(
      art: PapierArt.karteikarte,
      kopfLinie: 7,
      linien: false,
      klebestreifen: true,
      neigung: 0.003,
      samen: 53,
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MFormkopf(l.abend_klasse_titel.toUpperCase()),
          const SizedBox(height: MMass.s4),
          Container(height: 1, color: MRoh.tinte.withValues(alpha: 0.3)),
          const SizedBox(height: MMass.s12),
          Wrap(
            spacing: MMass.s12,
            runSpacing: MMass.s12,
            children: [
              for (final c in klassenNachRang())
                _KlasseKapsel(
                  klasse: c,
                  gewaehlt: c.id == gewaehlt,
                  gesperrt: !meta.classUnlocked(c.id),
                  onTap: () => _waehle(meta, c.id),
                ),
            ],
          ),
          if (karte) ...[
            const SizedBox(height: MMass.s16),
            Text(l.abend_klasse_karte_titel.toUpperCase(), style: MPapierSchrift.marke),
            const SizedBox(height: MMass.s4),
            Text('${l.klasseFaehigkeitName(gewaehlt)}: ${l.klasseFaehigkeit(gewaehlt)}', style: MPapierSchrift.text.copyWith(fontSize: 15)),
            Text(l.abend_klasse_fair, style: MPapierSchrift.leise),
          ],
          if (katalog?.vonFigur('mordakte', 'klasse:$gewaehlt') case final karten? when karten.isNotEmpty) ...[
            const SizedBox(height: MMass.s16),
            Text(l.abend_klasse_karten_titel.toUpperCase(), style: MPapierSchrift.marke),
            const SizedBox(height: MMass.s4),
            for (final k in karten)
              Padding(
                padding: const EdgeInsets.only(bottom: MMass.s4),
                child: Text.rich(
                  TextSpan(children: [
                    TextSpan(text: k.titel, style: MPapierSchrift.maschine.copyWith(fontSize: 14)),
                    TextSpan(text: ' · ${k.text}', style: MPapierSchrift.leise),
                    if (meta.besitztKarte(k.id))
                      TextSpan(text: ' · ${l.abend_klasse_karte_besessen}', style: MPapierSchrift.leise.copyWith(color: MRoh.tinteBlau)),
                  ]),
                ),
              ),
          ],
          const SizedBox(height: MMass.s12),
          Text(l.abend_klasse_hinweis, style: MPapierSchrift.leise),
        ],
      ),
    );
  }

  /// Merkt die Klasse in der Ausrüstung; Mantel und Hut bleiben unverändert.
  static void _waehle(MetaStore meta, String id) {
    final lo = meta.loadout;
    if (lo.cls == id || !meta.classUnlocked(id)) return;
    meta.loadout = Loadout(cls: id, coat: lo.coat, hat: lo.hat);
  }
}

/// Eine Klasse zur Wahl: ein Etikett mit Symbol und Namen, bei gesperrten der
/// nötige Rang. Die gewählte Klasse ist mit Füllertinte umkringelt.
class _KlasseKapsel extends StatelessWidget {
  const _KlasseKapsel({required this.klasse, required this.gewaehlt, required this.gesperrt, required this.onTap});

  final DetectiveClass klasse;
  final bool gewaehlt;
  final bool gesperrt;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final name = l.className(klasse.id);
    final rang = l.common_unlock_at(l.rankName(klasse.unlockRank));
    final tinte = gesperrt ? MRoh.tinteLeise : MRoh.tinte;
    return Semantics(
      button: true,
      selected: gewaehlt,
      enabled: !gesperrt,
      label: gesperrt ? l.abend_klasse_gesperrt(name, rang) : name,
      excludeSemantics: true,
      onTap: gesperrt ? null : onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: gesperrt ? null : onTap,
        child: CustomPaint(
          foregroundPainter: gewaehlt ? _Umkringelt(samen: klasse.id.codeUnits.fold(7, (a, b) => (a * 31 + b) & 0xffff)) : null,
          child: Container(
            constraints: const BoxConstraints(minHeight: MMass.tippflaeche),
            padding: const EdgeInsets.fromLTRB(MMass.s12, MMass.s8, 14, MMass.s8),
            decoration: BoxDecoration(
              color: gewaehlt ? MRoh.tinteBlau.withValues(alpha: 0.06) : Colors.transparent,
              borderRadius: BorderRadius.circular(3),
              border: Border.all(color: MRoh.tinte.withValues(alpha: gesperrt ? 0.25 : 0.45), width: 1.2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(gesperrt ? Icons.lock_rounded : GameIcons.cls(klasse.id), size: 18, color: gesperrt ? MRoh.tinteLeise : MRoh.tinteBlau),
                const SizedBox(width: MMass.s8),
                Flexible(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Ein Wort: lieber etwas kleiner als mitten im Wort getrennt.
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(name, maxLines: 1, style: MPapierSchrift.maschine.copyWith(fontSize: 15, color: tinte)),
                      ),
                      if (gesperrt) Text(rang, style: MPapierSchrift.leise.copyWith(fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Ein schneller Kringel in Füllertinte um das gewählte Etikett: eine etwas
/// unruhige Ellipse, deren Enden sich überkreuzen.
class _Umkringelt extends CustomPainter {
  _Umkringelt({required this.samen});

  final int samen;

  @override
  void paint(Canvas canvas, Size size) {
    final z = MaterialZufall(samen);
    final m = size.center(Offset.zero);
    final rx = size.width / 2 + 7;
    final ry = size.height / 2 + 6;
    final start = -2.4 + z.zwischen(-0.2, 0.2);
    final pfad = Path();
    const schritte = 40;
    for (var i = 0; i <= schritte; i++) {
      // Etwas mehr als eine Runde, damit sich Anfang und Ende überkreuzen.
      final w = start + i / schritte * (math.pi * 2 + 0.5);
      final wackel = 1 + 0.03 * math.sin(w * 3 + z.zwischen(0, 6));
      final p = m + Offset(math.cos(w) * rx * wackel, math.sin(w) * ry * wackel + (i / schritte) * 3);
      i == 0 ? pfad.moveTo(p.dx, p.dy) : pfad.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(
      pfad,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = MRoh.tinteBlau.withValues(alpha: 0.9),
    );
  }

  @override
  bool shouldRepaint(covariant _Umkringelt alt) => alt.samen != samen;
}
