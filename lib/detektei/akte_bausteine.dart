import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../l10n/lookup.dart';
import '../stil/mappe/material.dart' show MaterialZufall, PapierMaler;
import '../stil/stil.dart';
import 'akten.dart';
import 'schreibtisch.dart' show GanzeWorte;

/// Ton einer Akte in Worten (`spuk` → „Spuk“); unbekannte Töne erscheinen, wie sie in der Datei stehen.
String akteTonText(L l, String ton) => switch (ton) {
      'spuk' => l.detektei_ton_spuk,
      'noir' => l.detektei_ton_noir,
      _ => ton,
    };

/// Kürzel im Siegel einer Akte: das des Akten-Stils, sonst die ersten Buchstaben des Titels.
String akteSigel(AkteInfo akte) {
  final stil = AkteStil.fuer(akte.id);
  return stil.id.isEmpty ? akte.kuerzel : stil.sigel;
}

/// Samen aus den Zeichen einer Kennung (nie `String.hashCode`, das wechselt je Lauf).
int akteSamen(String id) => id.codeUnits.fold(11, (a, b) => (a * 31 + b) & 0xffffff);

/// Akzent einer Akte als Tinte auf Papier: dunkel genug zum Lesen.
Color akteTinte(AkteStil stil) => Color.lerp(stil.akzent, MRoh.tinte, 0.62)!;

/// Wie viele Blätter hinter einer Mappe der Breite [breite] hervorlugen: Auf breiten
/// Mappen hebt die Schräglage jedes weiteren Blatts dessen Kante über den Reiter, darum
/// dort nur eines (bis `MAktenmappe` die Blätter unter den Reiter legt).
int mappenBlaetter(double breite) => breite > 520 ? 1 : 2;

/// Das Bild einer Akte: ein nächtliches Tatortfoto in den Farben der Akte
/// (Gewölbe mit Kerze, Burg im Mond, Herrenhaus im Gewitter, Zug im Schnee,
/// Motel im Neonregen), mit Korn und Vignette. Füllt den verfügbaren Platz.
/// Unbekannte Akten zeigen ihr Siegel als Prägung; [siegel] ist dessen Durchmesser.
class AkteDeckel extends StatelessWidget {
  const AkteDeckel({super.key, required this.akte, this.siegel = 56});

  final AkteInfo akte;
  final double siegel;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
        child: RepaintBoundary(
          child: CustomPaint(
            painter: _TatortMaler(AkteStil.fuer(akte.id), sigel: akteSigel(akte), siegel: siegel),
            child: const SizedBox.expand(),
          ),
        ),
      );
}

/// Abzug des Tatortfotos einer Akte: weißer Rand, Schatten, leicht schräg,
/// wahlweise mit Büroklammer, Klebestreifen und handschriftlicher Zeile.
class AkteTatortfoto extends StatelessWidget {
  const AkteTatortfoto({
    super.key,
    required this.akte,
    this.breite,
    this.seitenverhaeltnis = 1,
    this.neigung = 0,
    this.klammer = false,
    this.klebestreifen = false,
    this.beschriftung,
  });

  final AkteInfo akte;

  /// Breite des ganzen Abzugs; ohne Angabe die verfügbare Breite.
  final double? breite;

  /// Breite zu Höhe des Bildes.
  final double seitenverhaeltnis;
  final double neigung;
  final bool klammer;
  final bool klebestreifen;

  /// Handschriftliche Zeile unter dem Bild.
  final String? beschriftung;

  @override
  Widget build(BuildContext context) {
    final rand = (breite ?? 200) < 120 ? 5.0 : 8.0;
    Widget abzug = DecoratedBox(
      decoration: const BoxDecoration(boxShadow: [BoxShadow(color: Color(0x99000000), blurRadius: 10, offset: Offset(0, 5))]),
      child: CustomPaint(
        painter: PapierMaler(art: PapierArt.foto, flecken: false, samen: akteSamen(akte.id)),
        child: Padding(
          padding: EdgeInsets.fromLTRB(rand, rand, rand, beschriftung == null ? rand * 1.8 : 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DecoratedBox(
                position: DecorationPosition.foreground,
                decoration: BoxDecoration(border: Border.all(color: Colors.black.withValues(alpha: 0.25))),
                child: AspectRatio(aspectRatio: seitenverhaeltnis, child: AkteDeckel(akte: akte, siegel: (breite ?? 200) * 0.4)),
              ),
              if (beschriftung != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(beschriftung!, textAlign: TextAlign.center, style: MPapierSchrift.hand.copyWith(fontSize: 20)),
                ),
            ],
          ),
        ),
      ),
    );
    if (breite != null) abzug = SizedBox(width: breite, child: abzug);
    if (klammer || klebestreifen) {
      abzug = Stack(
        clipBehavior: Clip.none,
        children: [
          abzug,
          if (klebestreifen)
            Positioned(
              top: -9,
              left: 0,
              right: 0,
              child: Center(child: MKlebestreifen(breite: ((breite ?? 200) * 0.55).clamp(40, 90), winkel: -0.07)),
            ),
          if (klammer) const Positioned(top: -15, right: 16, child: MBueroklammer(hoehe: 38)),
        ],
      );
    }
    abzug = ExcludeSemantics(child: RepaintBoundary(child: abzug));
    return neigung == 0 ? abzug : Transform.rotate(angle: neigung, child: abzug);
  }
}

/// Marken einer Akte als gestempelte Etiketten: Ton und (falls bekannt) Zahl der Personen.
/// Auf Papier in Tinte, auf dem Schreibtisch in den hellen Farben.
class AkteMarken extends StatelessWidget {
  const AkteMarken({super.key, required this.akte});

  final AkteInfo akte;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final f = MFarben.von(context);
    final papier = MFlaeche.hellVon(context);
    final stil = AkteStil.fuer(akte.id);
    final min = akte.minRollen, max = akte.maxRollen;
    // Ein Etikett wird nie gekürzt: Reicht die Breite nicht, schrumpft es als Ganzes.
    Widget etikett(Widget chip, double winkel) => Transform.rotate(
          angle: winkel,
          child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: chip),
        );
    return Wrap(
      spacing: MMass.s8,
      runSpacing: MMass.s8,
      children: [
        if (akte.ton.isNotEmpty) etikett(MChip(akteTonText(l, akte.ton), farbe: papier ? akteTinte(stil) : stil.akzent, passend: true), -0.025),
        if (min != null && max != null)
          etikett(MChip(l.detektei_personen(min, max), icon: Icons.group_outlined, farbe: papier ? MRoh.tinte : f.papierLeise, passend: true), 0.018),
      ],
    );
  }
}

/// Eine Akte als Aktenmappe aus Manilakarton: Reiter „Akte Nr. 0X“, Band im
/// Akzent der Akte, Titel in Playfair, Untertitel kursiv, Marken als Stempel,
/// das Tatortfoto mit Klebestreifen und das Siegel der Akte.
///
/// In der Kampagnenliste ([gewaehlt] `null`) ist die Mappe ein Knopf, dessen Text
/// der Bildschirmleser vorliest. Im Assistenten ([gewaehlt] gesetzt) ist sie eine
/// Auswahl mit dem Titel als Beschriftung und dem Untertitel als Hinweis; die
/// gewählte Mappe trägt einen Haken und den Stempel „Gewählt“.
class AkteKarte extends StatelessWidget {
  const AkteKarte({super.key, required this.akte, required this.onTap, this.gewaehlt, this.nummer});

  final AkteInfo akte;
  final VoidCallback onTap;
  final bool? gewaehlt;

  /// Platz in der Kampagne (0 für die erste Akte); ohne Angabe trägt die Mappe keinen Reiter.
  final int? nummer;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final stil = AkteStil.fuer(akte.id);
    final nr = nummer;
    final reiter = nr == null ? null : l.case_file_no(akteNummer(nr));
    final schief = (nr ?? akteSamen(akte.id)).isEven ? -0.004 : 0.005;
    final auswahl = gewaehlt;
    if (auswahl == null) {
      final mappe = MAktenmappe(
        reiter: reiter,
        farbe: stil.akzent,
        siegel: akteSigel(akte),
        blaetter: 2,
        neigung: schief,
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
        onTap: onTap,
        child: _MappenInhalt(akte: akte, schief: schief),
      );
      // Der Bildschirmleser hört denselben Namen wie vor der Mappe (Titel, Untertitel,
      // Ton, Personen), ohne den Reiter „Akte Nr. 0X“ davor.
      final min = akte.minRollen, max = akte.maxRollen;
      final name = [
        akte.titel,
        if (akte.untertitel.isNotEmpty) akte.untertitel,
        if (akte.ton.isNotEmpty) akteTonText(l, akte.ton),
        if (min != null && max != null) l.detektei_personen(min, max),
      ].join('\n');
      return Padding(
        padding: const EdgeInsets.only(bottom: MMass.s24),
        child: Semantics(button: true, label: name, onTap: onTap, excludeSemantics: true, child: mappe),
      );
    }
    final mappe = MAktenmappe(
      reiter: reiter,
      farbe: stil.akzent,
      blaetter: auswahl ? 2 : 1,
      neigung: auswahl ? 0 : schief,
      padding: const EdgeInsets.fromLTRB(14, 12, 12, 14),
      onTap: onTap,
      child: _AuswahlInhalt(akte: akte, gewaehlt: auswahl),
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: MMass.s16),
      child: Semantics(
        button: true,
        selected: auswahl,
        label: akte.titel,
        hint: akte.untertitel,
        onTap: onTap,
        excludeSemantics: true,
        child: mappe,
      ),
    );
  }
}

/// Inhalt der Mappe in der Kampagnenliste: Text links, Tatortfoto rechts; am
/// schmalen Handy oder bei großer Schrift steht das Foto unter dem Titel.
class _MappenInhalt extends StatelessWidget {
  const _MappenInhalt({required this.akte, required this.schief});

  final AkteInfo akte;
  final double schief;

  @override
  Widget build(BuildContext context) {
    final skala = MediaQuery.textScalerOf(context).scale(1);
    final titel = GanzeWorte(akte.titel, style: MPapierSchrift.ueberschrift);
    final unter = akte.untertitel.isEmpty
        ? null
        : GanzeWorte(akte.untertitel, style: MPapierSchrift.kursiv.copyWith(fontSize: 15, height: 1.4, color: MRoh.tinteLeise));
    final marken = AkteMarken(akte: akte);
    return LayoutBuilder(
      builder: (context, box) {
        // Neben dem Foto braucht der Titel Platz für „Schlosskeller“ in einem Stück.
        final nebeneinander = box.maxWidth - 118 >= 170 * skala;
        final foto = AkteTatortfoto(
          akte: akte,
          breite: nebeneinander ? 104 : 96,
          neigung: schief < 0 ? 0.035 : -0.03,
          klebestreifen: true,
        );
        if (nebeneinander) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    titel,
                    if (unter != null) ...[const SizedBox(height: MMass.s4), unter],
                    const SizedBox(height: MMass.s16),
                    marken,
                  ],
                ),
              ),
              const SizedBox(width: MMass.s16),
              Padding(padding: const EdgeInsets.only(top: 6), child: foto),
            ],
          );
        }
        // Schmal: die Marken in voller Breite, das Foto darunter links, gegenüber dem Siegel.
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            titel,
            if (unter != null) ...[const SizedBox(height: MMass.s4), unter],
            const SizedBox(height: MMass.s16),
            marken,
            const SizedBox(height: MMass.s20),
            Align(alignment: Alignment.centerLeft, child: Padding(padding: const EdgeInsets.only(left: MMass.s4), child: foto)),
          ],
        );
      },
    );
  }
}

/// Inhalt der Mappe im Assistenten: kleines Foto, Titel, Marken und ein Ankreuzfeld.
class _AuswahlInhalt extends StatelessWidget {
  const _AuswahlInhalt({required this.akte, required this.gewaehlt});

  final AkteInfo akte;
  final bool gewaehlt;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, box) {
          final schmal = box.maxWidth < 260;
          final l = L.of(context);
          final fotoBreite = schmal ? 52.0 : 66.0;
          final foto = AkteTatortfoto(akte: akte, breite: fotoBreite, neigung: -0.03);
          final stempel = IgnorePointer(child: MStempel(text: l.profil_klasse_gewaehlt, groesse: 12, winkel: -0.16, aufschlagen: true));
          final kreuz = Padding(padding: const EdgeInsets.only(top: 4), child: AnkreuzFeld(an: gewaehlt));
          final text = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GanzeWorte(akte.titel, style: MPapierSchrift.ueberschrift.copyWith(fontSize: 20)),
              if (akte.untertitel.isNotEmpty) ...[
                const SizedBox(height: 2),
                GanzeWorte(akte.untertitel, style: MPapierSchrift.kursiv.copyWith(fontSize: 14, height: 1.4, color: MRoh.tinteLeise)),
              ],
              const SizedBox(height: MMass.s12),
              AkteMarken(akte: akte),
            ],
          );
          // Bei großer Schrift bliebe zwischen Foto und Kästchen zu wenig Platz: Dann
          // liegen Foto, Stempel und Kästchen oben und der Text in voller Breite darunter.
          final skala = MediaQuery.textScalerOf(context).scale(1);
          if (box.maxWidth - fotoBreite - 46 < 130 * skala) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    foto,
                    const SizedBox(width: MMass.s16),
                    Expanded(
                      child: gewaehlt
                          ? Align(alignment: Alignment.centerLeft, child: FittedBox(fit: BoxFit.scaleDown, child: stempel))
                          : const SizedBox.shrink(),
                    ),
                    const SizedBox(width: MMass.s8),
                    kreuz,
                  ],
                ),
                const SizedBox(height: MMass.s12),
                text,
              ],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  foto,
                  // Der Stempel der gewählten Akte sitzt auf dem Foto, nicht auf dem Text.
                  if (gewaehlt)
                    Positioned(
                      // Links über den Rand des Fotos hinaus, damit er den Untertitel nicht verdeckt.
                      left: schmal ? -24 : -18,
                      bottom: -28,
                      child: stempel,
                    ),
                ],
              ),
              const SizedBox(width: MMass.s12),
              Expanded(child: text),
              const SizedBox(width: MMass.s8),
              kreuz,
            ],
          );
        },
      );
}

/// Ein Kästchen in Tinte, angekreuzt mit einem Füllerhaken. Nur Bild; die
/// Auswahl meldet der umgebende Knopf.
class AnkreuzFeld extends StatelessWidget {
  const AnkreuzFeld({super.key, required this.an, this.groesse = 26});

  final bool an;
  final double groesse;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
        child: SizedBox.square(dimension: groesse, child: CustomPaint(painter: _KreuzMaler(an))),
      );
}

class _KreuzMaler extends CustomPainter {
  _KreuzMaler(this.an);

  final bool an;

  @override
  void paint(Canvas canvas, Size size) {
    final r = Rect.fromLTWH(2, 4, size.width - 6, size.height - 6);
    canvas.drawRect(
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..color = MRoh.tinte.withValues(alpha: 0.75),
    );
    if (!an) return;
    final p = Path()
      ..moveTo(r.left + r.width * 0.12, r.top + r.height * 0.52)
      ..quadraticBezierTo(r.left + r.width * 0.32, r.top + r.height * 0.6, r.left + r.width * 0.42, r.bottom - 1)
      ..quadraticBezierTo(r.left + r.width * 0.62, r.top + r.height * 0.3, size.width + 2, -2);
    canvas.drawPath(
      p,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..color = MRoh.tinteBlau,
    );
  }

  @override
  bool shouldRepaint(covariant _KreuzMaler alt) => alt.an != an;
}

/// Malt das Tatortfoto einer Akte: Szene in den Farben der Akte, darüber
/// Lichtschein, Korn, Kratzer und Vignette wie bei einem alten Abzug.
class _TatortMaler extends CustomPainter {
  _TatortMaler(this.stil, {required this.sigel, required this.siegel});

  final AkteStil stil;
  final String sigel;
  final double siegel;

  Color get _licht => stil.akzent2 ?? stil.akzentHell;
  Color get _schatten => Color.lerp(stil.hintergrund, Colors.black, 0.62)!;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final w = size.width, h = size.height;
    final rect = Offset.zero & size;
    canvas.save();
    canvas.clipRect(rect);
    // Grund: ein Nachthimmel bzw. Raum in den Farben der Akte.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = ui.Gradient.linear(
          rect.topCenter,
          rect.bottomCenter,
          [Color.lerp(stil.hintergrund, stil.akzent, 0.32)!, Color.lerp(stil.hintergrund, stil.akzent, 0.1)!, _schatten],
          const [0, 0.55, 1],
        ),
    );
    final z = MaterialZufall(akteSamen(stil.id.isEmpty ? sigel : stil.id) + w.round());
    switch (stil.id) {
      case 'schlosskeller':
        _gewoelbekeller(canvas, w, h);
      case 'gewoelbe':
        _burg(canvas, w, h, z);
      case 'ravensmoor':
        _herrenhaus(canvas, w, h, z);
      case 'nachtexpress':
        _zug(canvas, w, h, z);
      case 'blue_palm':
        _motel(canvas, w, h, z);
      default:
        _praegung(canvas, w, h);
    }
    // Korn und Staub des Abzugs.
    final korn = Paint();
    final n = (w * h / 24).clamp(60, 5000).toInt();
    for (var i = 0; i < n; i++) {
      korn.color = (z.naechste() < 0.5 ? Colors.black : Colors.white).withValues(alpha: z.zwischen(0.03, 0.11));
      canvas.drawCircle(Offset(z.naechste() * w, z.naechste() * h), z.zwischen(0.3, 0.9), korn);
    }
    final kratzer = Paint()
      ..strokeWidth = 0.6
      ..color = Colors.white.withValues(alpha: 0.08);
    for (var i = 0; i < 3; i++) {
      final x = z.naechste() * w;
      canvas.drawLine(Offset(x, z.zwischen(0, h * 0.4)), Offset(x + z.zwischen(-3, 3), z.zwischen(h * 0.5, h)), kratzer);
    }
    // Vignette und ein Hauch Sepia.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = ui.Gradient.radial(
          rect.center,
          size.longestSide * 0.72,
          [Colors.transparent, Colors.black.withValues(alpha: 0.62)],
          const [0.45, 1],
        ),
    );
    canvas.drawRect(rect, Paint()..color = const Color(0x147A5A2A));
    canvas.restore();
  }

  /// Ein schwacher Lichtkegel an [mitte] mit Radius [r].
  void _schein(Canvas canvas, Offset mitte, double r, Color farbe, [double staerke = 0.55]) {
    canvas.drawCircle(
      mitte,
      r,
      Paint()..shader = ui.Gradient.radial(mitte, r, [farbe.withValues(alpha: staerke), farbe.withValues(alpha: 0)]),
    );
  }

  /// Schlosskeller: ein Gewölbegang mit Bögen, hinten eine Kerze auf der Tafel.
  void _gewoelbekeller(Canvas canvas, double w, double h) {
    final hinten = Offset(w * 0.5, h * 0.6);
    _schein(canvas, hinten, h * 0.75, _licht, 0.7);
    final wand = Paint()..color = _schatten;
    // Drei Bögen, die nach hinten kleiner werden.
    for (final (breite, oben, kampfer, deckung) in [(0.98, 0.04, 0.42, 1.0), (0.66, 0.2, 0.52, 0.75), (0.4, 0.33, 0.6, 0.55)]) {
      final l = w * (0.5 - breite / 2), r = w * (0.5 + breite / 2);
      final bogen = Path()
        ..moveTo(l, h)
        ..lineTo(l, h * kampfer)
        ..quadraticBezierTo(w * 0.5, h * (oben - (kampfer - oben) * 0.9), r, h * kampfer)
        ..lineTo(r, h)
        ..close();
      final rahmen = Path()
        ..fillType = PathFillType.evenOdd
        ..addRect(Rect.fromLTWH(0, 0, w, h))
        ..addPath(bogen, Offset.zero);
      canvas.drawPath(rahmen, wand..color = _schatten.withValues(alpha: deckung));
    }
    // Boden und die lange Tafel.
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.82, w, h * 0.18),
      Paint()..shader = ui.Gradient.linear(Offset(0, h * 0.82), Offset(0, h), [_schatten.withValues(alpha: 0.6), _schatten]),
    );
    canvas.drawRect(Rect.fromLTWH(w * 0.3, h * 0.7, w * 0.4, h * 0.05), Paint()..color = _schatten);
    canvas.drawRect(Rect.fromLTWH(w * 0.33, h * 0.75, w * 0.02, h * 0.12), Paint()..color = _schatten);
    canvas.drawRect(Rect.fromLTWH(w * 0.65, h * 0.75, w * 0.02, h * 0.12), Paint()..color = _schatten);
    // Kerze mit Flamme.
    final kerze = Offset(w * 0.5, h * 0.66);
    canvas.drawRect(Rect.fromCenter(center: kerze, width: w * 0.022, height: h * 0.07), Paint()..color = Color.lerp(_licht, Colors.white, 0.4)!);
    _schein(canvas, kerze.translate(0, -h * 0.06), h * 0.14, Colors.white, 0.75);
    _schein(canvas, kerze.translate(0, -h * 0.06), h * 0.28, _licht, 0.5);
  }

  /// Gewölbe: Burg Schartenfels auf dem Berg im Mondlicht, Nebel im Tal.
  void _burg(Canvas canvas, double w, double h, MaterialZufall z) {
    final mond = Offset(w * 0.76, h * 0.24);
    final r = math.min(w, h) * 0.11;
    _schein(canvas, mond, r * 4, stil.akzentHell, 0.35);
    canvas.drawCircle(mond, r, Paint()..color = Color.lerp(stil.akzentHell, Colors.white, 0.55)!);
    final schatten = Paint()..color = _schatten;
    final berg = Path()
      ..moveTo(0, h * 0.86)
      ..quadraticBezierTo(w * 0.22, h * 0.62, w * 0.44, h * 0.62)
      ..quadraticBezierTo(w * 0.7, h * 0.64, w, h * 0.8)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    // Mauer mit Zinnen und zwei Türme.
    void zinnen(double l, double r, double oben, double unten) {
      final p = Path()..moveTo(l, unten);
      p.lineTo(l, oben);
      final schritt = (r - l) / 7;
      for (var x = l; x < r - 0.1; x += schritt) {
        p
          ..lineTo(x, oben - h * 0.03)
          ..lineTo(x + schritt * 0.5, oben - h * 0.03)
          ..lineTo(x + schritt * 0.5, oben)
          ..lineTo(math.min(x + schritt, r), oben);
      }
      p
        ..lineTo(r, unten)
        ..close();
      canvas.drawPath(p, schatten);
    }

    zinnen(w * 0.26, w * 0.62, h * 0.47, h * 0.66);
    zinnen(w * 0.3, w * 0.4, h * 0.27, h * 0.5);
    zinnen(w * 0.53, w * 0.6, h * 0.36, h * 0.5);
    canvas.drawPath(berg, schatten);
    final fenster = Paint()..color = Color.lerp(_licht, Colors.white, 0.3)!;
    canvas.drawRect(Rect.fromLTWH(w * 0.34, h * 0.34, w * 0.02, h * 0.04), fenster);
    canvas.drawRect(Rect.fromLTWH(w * 0.46, h * 0.53, w * 0.018, h * 0.035), fenster);
    _schein(canvas, Offset(w * 0.47, h * 0.55), h * 0.08, _licht, 0.5);
    // Eisnebel im Tal.
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.72, w, h * 0.2),
      Paint()
        ..shader = ui.Gradient.linear(Offset(0, h * 0.72), Offset(0, h * 0.92), [
          stil.akzentHell.withValues(alpha: 0),
          stil.akzentHell.withValues(alpha: 0.22),
          stil.akzentHell.withValues(alpha: 0),
        ], const [
          0,
          0.5,
          1
        ]),
    );
  }

  /// Ravensmoor: das Herrenhaus im Gewitter, ein Blitz, Regenschnüre.
  void _herrenhaus(Canvas canvas, double w, double h, MaterialZufall z) {
    final blitz = Path()
      ..moveTo(w * 0.2, 0)
      ..lineTo(w * 0.16, h * 0.14)
      ..lineTo(w * 0.22, h * 0.15)
      ..lineTo(w * 0.15, h * 0.34);
    _schein(canvas, Offset(w * 0.18, h * 0.12), h * 0.5, stil.akzentHell, 0.4);
    canvas.drawPath(
      blitz,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.2, w * 0.008)
        ..color = Colors.white.withValues(alpha: 0.85),
    );
    final haus = Paint()..color = _schatten;
    final p = Path()
      ..moveTo(w * 0.1, h * 0.86)
      ..lineTo(w * 0.1, h * 0.52)
      ..lineTo(w * 0.27, h * 0.36)
      ..lineTo(w * 0.42, h * 0.52)
      ..lineTo(w * 0.45, h * 0.52)
      ..lineTo(w * 0.45, h * 0.4)
      ..lineTo(w * 0.5, h * 0.27)
      ..lineTo(w * 0.55, h * 0.4)
      ..lineTo(w * 0.55, h * 0.52)
      ..lineTo(w * 0.58, h * 0.52)
      ..lineTo(w * 0.73, h * 0.36)
      ..lineTo(w * 0.9, h * 0.52)
      ..lineTo(w * 0.9, h * 0.86)
      ..close();
    canvas.drawPath(p, haus);
    canvas.drawRect(Rect.fromLTWH(w * 0.2, h * 0.33, w * 0.03, h * 0.08), haus);
    canvas.drawRect(Rect.fromLTWH(w * 0.78, h * 0.34, w * 0.03, h * 0.08), haus);
    // Fenster: einige erleuchtet.
    final hell = Paint()..color = Color.lerp(stil.akzentHell, const Color(0xFFFFE2A0), 0.6)!;
    final dunkel = Paint()..color = Colors.black.withValues(alpha: 0.35);
    for (var reihe = 0; reihe < 2; reihe++) {
      for (var i = 0; i < 6; i++) {
        final x = w * (0.15 + i * 0.125);
        final y = h * (0.58 + reihe * 0.13);
        canvas.drawRect(Rect.fromLTWH(x, y, w * 0.035, h * 0.07), z.naechste() < 0.35 ? hell : dunkel);
      }
    }
    canvas.drawRect(Rect.fromLTWH(0, h * 0.84, w, h * 0.16), haus);
    final regen = Paint()
      ..strokeWidth = 0.7
      ..color = stil.akzentHell.withValues(alpha: 0.22);
    for (var i = 0; i < (w / 3).clamp(12, 120); i++) {
      final x = z.naechste() * w * 1.2, y = z.naechste() * h;
      canvas.drawLine(Offset(x, y), Offset(x - h * 0.05, y + h * 0.12), regen);
    }
  }

  /// Nachtexpress: Lok und Schlafwagen im Schneetreiben vor den Bergen.
  void _zug(Canvas canvas, double w, double h, MaterialZufall z) {
    final berge = Path()
      ..moveTo(0, h * 0.62)
      ..lineTo(w * 0.18, h * 0.32)
      ..lineTo(w * 0.34, h * 0.52)
      ..lineTo(w * 0.52, h * 0.26)
      ..lineTo(w * 0.74, h * 0.5)
      ..lineTo(w * 0.88, h * 0.36)
      ..lineTo(w, h * 0.46)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(berge, Paint()..color = Color.lerp(_schatten, stil.akzentHell, 0.16)!);
    final zug = Paint()..color = _schatten;
    // Schlafwagen mit gewölbtem Dach.
    canvas.drawRRect(RRect.fromLTRBR(w * 0.04, h * 0.5, w * 0.6, h * 0.78, Radius.circular(h * 0.05)), zug);
    // Lok mit Kessel, Führerhaus und Schornstein.
    canvas.drawRect(Rect.fromLTRB(w * 0.62, h * 0.56, w * 0.88, h * 0.78), zug);
    canvas.drawRect(Rect.fromLTRB(w * 0.62, h * 0.46, w * 0.72, h * 0.6), zug);
    canvas.drawRect(Rect.fromLTRB(w * 0.8, h * 0.46, w * 0.84, h * 0.57), zug);
    final licht = Paint()..color = Color.lerp(_licht, const Color(0xFFFFE6A8), 0.5)!;
    for (var i = 0; i < 6; i++) {
      canvas.drawRect(Rect.fromLTWH(w * (0.08 + i * 0.085), h * 0.56, w * 0.05, h * 0.07), licht);
    }
    final lampe = Offset(w * 0.9, h * 0.64);
    _schein(canvas, lampe, h * 0.35, const Color(0xFFFFE6A8), 0.55);
    canvas.drawCircle(lampe, h * 0.02, Paint()..color = Colors.white);
    // Räder und Gleis.
    for (var i = 0; i < 7; i++) {
      canvas.drawCircle(Offset(w * (0.1 + i * 0.12), h * 0.8), h * 0.035, zug);
    }
    canvas.drawRect(Rect.fromLTWH(0, h * 0.83, w, h * 0.17), Paint()..color = Color.lerp(_schatten, Colors.white, 0.08)!);
    final schnee = Paint()..color = Colors.white.withValues(alpha: 0.7);
    for (var i = 0; i < (w * h / 260).clamp(20, 300); i++) {
      canvas.drawCircle(Offset(z.naechste() * w, z.naechste() * h), z.zwischen(0.5, 1.6), schnee);
    }
  }

  /// Blue Palm: das Motel mit Neonschild, Palmen im Sturm, Regen.
  void _motel(Canvas canvas, double w, double h, MaterialZufall z) {
    final dunkel = Paint()..color = _schatten;
    canvas.drawRect(Rect.fromLTRB(w * 0.04, h * 0.56, w * 0.7, h * 0.8), dunkel);
    final tuer = Paint()..color = Color.lerp(stil.akzent, Colors.white, 0.2)!.withValues(alpha: 0.55);
    for (var i = 0; i < 5; i++) {
      canvas.drawRect(Rect.fromLTWH(w * (0.08 + i * 0.12), h * 0.63, w * 0.05, h * 0.12), i == 3 ? tuer : (Paint()..color = Colors.black.withValues(alpha: 0.4)));
    }
    // Neonschild am Mast.
    final rosa = stil.akzent2 ?? stil.akzentHell;
    canvas.drawRect(Rect.fromLTRB(w * 0.82, h * 0.42, w * 0.84, h * 0.8), dunkel);
    final schild = RRect.fromLTRBR(w * 0.72, h * 0.18, w * 0.94, h * 0.42, Radius.circular(h * 0.03));
    _schein(canvas, schild.center, h * 0.32, rosa, 0.45);
    canvas.drawRRect(schild, Paint()..color = Colors.black.withValues(alpha: 0.55));
    canvas.drawRRect(
      schild.deflate(h * 0.025),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.2, h * 0.018)
        ..color = rosa,
    );
    canvas.drawLine(
      Offset(w * 0.75, h * 0.3),
      Offset(w * 0.91, h * 0.3),
      Paint()
        ..strokeWidth = math.max(1, h * 0.014)
        ..color = stil.akzentHell,
    );
    // Palme: Stamm und Wedel.
    final stamm = Path()
      ..moveTo(w * 0.18, h * 0.82)
      ..quadraticBezierTo(w * 0.2, h * 0.5, w * 0.3, h * 0.24);
    canvas.drawPath(
      stamm,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(2, w * 0.022)
        ..strokeCap = StrokeCap.round
        ..color = _schatten,
    );
    final wedel = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.6, w * 0.014)
      ..strokeCap = StrokeCap.round
      ..color = _schatten;
    final krone = Offset(w * 0.3, h * 0.24);
    for (final (dx, dy) in [(-0.18, 0.12), (-0.1, 0.18), (0.14, 0.14), (0.2, 0.06), (-0.16, -0.02), (0.04, -0.08)]) {
      final ende = krone.translate(w * dx, h * dy);
      canvas.drawPath(
        Path()
          ..moveTo(krone.dx, krone.dy)
          ..quadraticBezierTo(krone.dx + w * dx * 0.5, krone.dy - h * 0.08, ende.dx, ende.dy),
        wedel,
      );
    }
    canvas.drawRect(Rect.fromLTWH(0, h * 0.8, w, h * 0.2), Paint()..color = Color.lerp(_schatten, stil.akzent, 0.12)!);
    // Spiegelung des Neons auf dem nassen Boden.
    _schein(canvas, Offset(w * 0.83, h * 0.9), h * 0.16, rosa, 0.3);
    final regen = Paint()
      ..strokeWidth = 0.7
      ..color = Colors.white.withValues(alpha: 0.2);
    for (var i = 0; i < (w / 3).clamp(12, 120); i++) {
      final x = z.naechste() * w * 1.2, y = z.naechste() * h;
      canvas.drawLine(Offset(x, y), Offset(x - h * 0.06, y + h * 0.13), regen);
    }
  }

  /// Unbekannte Akte: das Siegel als Prägung in zwei Ringen.
  void _praegung(Canvas canvas, double w, double h) {
    final m = Offset(w / 2, h / 2);
    final r = math.min(siegel, math.min(w, h) * 0.8) / 2;
    _schein(canvas, Offset(w * 0.9, h * 0.1), w, _licht, 0.3);
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..color = stil.akzentHell.withValues(alpha: 0.8)
      ..strokeWidth = 2;
    canvas.drawCircle(m, r, Paint()..color = const Color(0x33000000));
    canvas.drawCircle(m, r, ring);
    canvas.drawCircle(m, r - 5, ring..color = stil.akzentHell.withValues(alpha: 0.4));
    final tp = TextPainter(
      text: TextSpan(
        text: sigel,
        style: TextStyle(fontFamily: MRohSchrift.anzeige, fontSize: r * 0.72, letterSpacing: 1, color: stil.akzentHell),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    tp.paint(canvas, m - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _TatortMaler alt) => alt.stil.id != stil.id || alt.sigel != sigel || alt.siegel != siegel;
}
