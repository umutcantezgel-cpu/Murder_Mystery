import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mordakte_core/mordakte_core.dart' show LookDef, detectiveCoats;

import '../l10n/lookup.dart';
import '../meta/meta_store.dart';
import '../meta/progression.dart';
import '../stil/mappe/material.dart' show PapierMaler;
import '../stil/stil.dart';
import '../ui/icons.dart';
import '../ui/widgets/meters.dart' show RankBadge;
import 'schreibtisch.dart';

/// Aussehen des eigenen Detektivs aus der Ausrüstung (Mantel und Hut).
LookDef detektivAussehen(MetaStore meta, {String? hut}) {
  final lo = meta.loadout;
  return LookDef(coat: detectiveCoats[lo.coat.clamp(0, detectiveCoats.length - 1)], hat: hut ?? lo.hat);
}

/// Der Dienstausweis des Detektivs: ein Kartonausweis mit Schutzmuster, oben
/// ein dunkles Band mit „Dienstausweis“ und Ausweisnummer, links der Fotoabzug
/// mit Rangabzeichen und Behördenstempel, rechts Name, Dienstgrad und
/// Erfahrung. [gross] zeigt zusätzlich Klasse und nächsten Rang (Profil).
///
/// Nur Bild und Text; Tippen und Bildschirmleser regelt der Bildschirm. Mit
/// [onName] ist der Name antippbar (Name ändern).
class Dienstausweis extends StatelessWidget {
  const Dienstausweis({super.key, required this.meta, this.gross = false, this.onName});

  final MetaStore meta;
  final bool gross;
  final VoidCallback? onName;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final name = meta.name ?? l.name_default;
    final next = nextRankXp(meta.xp);
    // Ausweisnummer aus dem Namen: gleich bleibend, ohne Zufall.
    final nr = name.codeUnits.fold(7, (a, b) => (a * 31 + b) % 9973).toString().padLeft(4, '0');
    final foto = gross ? 92.0 : 64.0;
    final leise = MPapierSchrift.maschine.copyWith(fontSize: 12, height: 1.3, color: MRoh.tinteLeise);
    Widget nameText = GanzeWorte(name, maxLines: 2, style: MPapierSchrift.ueberschrift.copyWith(fontSize: gross ? 22 : 20, height: 1.2));
    if (onName != null) {
      // Ein kleiner Füllerstrich zeigt, dass sich der Name ändern lässt.
      nameText = InkWell(
        onTap: onName,
        splashFactory: NoSplash.splashFactory,
        child: Row(
          children: [
            Flexible(child: nameText),
            const SizedBox(width: MMass.s8),
            const Icon(Icons.edit_outlined, size: 18, color: MRoh.tinteBlau),
          ],
        ),
      );
    }
    final felder = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(l.name_prompt_hint, style: leise),
        nameText,
        const SizedBox(height: MMass.s8),
        GanzeWorte(l.detektei_dienstgrad, style: leise),
        GanzeWorte(l.rankName(meta.rank), style: MPapierSchrift.maschine.copyWith(fontSize: 15, height: 1.3)),
        if (gross) ...[
          const SizedBox(height: MMass.s4),
          Row(
            children: [
              Icon(GameIcons.cls(meta.loadout.cls), size: 15, color: MRoh.tinteLeise),
              const SizedBox(width: MMass.s4),
              Flexible(child: GanzeWorte(l.className(meta.loadout.cls), style: MPapierSchrift.text.copyWith(fontSize: 14, height: 1.3, color: MRoh.tinteLeise))),
            ],
          ),
        ],
        const SizedBox(height: MMass.s12),
        TintenBalken(wert: rankProgress(meta.xp), hoehe: 9),
        const SizedBox(height: MMass.s4),
        Text(next == null ? l.hub_rank_max : l.hub_rank_progress(meta.xp, next), style: MPapierSchrift.leise.copyWith(fontSize: 12)),
        if (gross && next != null) Text(l.profile_next_rank(l.rankName(meta.rank + 1)), style: MPapierSchrift.leise.copyWith(fontSize: 12)),
      ],
    );
    final bild = Stack(
      clipBehavior: Clip.none,
      children: [
        MFotoabzug(look: detektivAussehen(meta), groesse: foto, neigung: -0.03, akzent: MRoh.messingMitte),
        // Behördenstempel quer über die obere Ecke des Fotos (unten links sitzt das
        // Rangabzeichen); nur auf dem großen Ausweis, denn auf dem kleinen deckte er
        // in lesbarer Größe das Gesicht zu.
        if (gross)
          Positioned(
            right: -foto * 0.16,
            top: -foto * 0.08,
            child: IgnorePointer(
              child: ExcludeSemantics(
                child: Opacity(
                  opacity: 0.78,
                  child: MStempel(text: l.appTitle, farbe: MRoh.tinteBlau, groesse: 12, winkel: 0.2),
                ),
              ),
            ),
          ),
        Positioned(left: -8, bottom: -10, child: RankBadge(rank: meta.rank, size: gross ? 46 : 36)),
      ],
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(9),
        boxShadow: const [
          BoxShadow(color: Color(0x99000000), blurRadius: 16, offset: Offset(0, 7)),
          BoxShadow(color: Color(0x55000000), blurRadius: 2, offset: Offset(0, 1)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(9),
        child: CustomPaint(
          painter: PapierMaler(art: PapierArt.karteikarte, flecken: false, zeilenAbstand: 100000, kopf: 0.5, samen: nr.codeUnits.last),
          foregroundPainter: const _SchutzmusterMaler(),
          child: MFlaeche.papier(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                _Band(titel: l.detektei_dienstausweis, nummer: 'Nr. $nr'),
                Padding(
                  padding: EdgeInsets.fromLTRB(gross ? 18 : 14, 16, gross ? 18 : 14, gross ? 20 : 18),
                  child: LayoutBuilder(
                    builder: (context, box) {
                      // Bei großer Schrift auf schmalem Handy steht das Foto über den Feldern.
                      final skala = MediaQuery.textScalerOf(context).scale(1);
                      if (box.maxWidth - foto - 40 < 140 * skala) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [Align(alignment: Alignment.centerLeft, child: bild), const SizedBox(height: MMass.s24), felder],
                        );
                      }
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          bild,
                          SizedBox(width: gross ? 26 : 22),
                          Expanded(child: felder),
                        ],
                      );
                    },
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

/// Dunkles Band oben auf dem Ausweis mit Messingschrift.
class _Band extends StatelessWidget {
  const _Band({required this.titel, required this.nummer});

  final String titel;
  final String nummer;

  @override
  Widget build(BuildContext context) {
    final stil = MRohSchrift.schreibmaschine.copyWith(fontSize: 13, height: 1.3, letterSpacing: 2, color: MRoh.messingHell);
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF3A2A22), MRoh.leder]),
        border: Border(bottom: BorderSide(color: MRoh.messingMitte, width: 1.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 7, 14, 6),
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: MMass.s12,
          runSpacing: 2,
          children: [
            Text(titel, style: stil),
            Text(nummer, style: stil.copyWith(fontSize: 12, letterSpacing: 1, color: MRoh.messingHell.withValues(alpha: 0.7))),
          ],
        ),
      ),
    );
  }
}

/// Feines Schutzmuster (Guilloche) eines Ausweises in blasser Tinte.
class _SchutzmusterMaler extends CustomPainter {
  const _SchutzmusterMaler();

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6
      ..color = MRoh.tinteBlau.withValues(alpha: 0.07);
    for (var k = 0; k < 9; k++) {
      final pfad = Path();
      final phase = k * 0.7;
      final amp = 6 + k * 1.3;
      final basis = size.height * 0.35 + k * 6;
      for (var x = 0.0; x <= size.width; x += 3) {
        final y = basis + math.sin(x / 26 + phase) * amp + math.sin(x / 9 + phase * 2) * 1.6;
        x == 0 ? pfad.moveTo(x, y) : pfad.lineTo(x, y);
      }
      canvas.drawPath(pfad, p);
    }
    // Wasserzeichen: zwei Ringe rechts unten.
    final m = Offset(size.width * 0.86, size.height * 0.7);
    final r = math.min(size.width, size.height) * 0.32;
    canvas.drawCircle(m, r, p..color = MRoh.tinteBlau.withValues(alpha: 0.06));
    canvas.drawCircle(m, r * 0.8, p);
  }

  @override
  bool shouldRepaint(covariant _SchutzmusterMaler alt) => false;
}
