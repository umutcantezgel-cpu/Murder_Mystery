import 'package:flutter/material.dart';

import '../tokens.dart';
import '../widgets/m_ganze_worte.dart';
import 'material.dart';
import 'zeichen.dart';

/// Ein Blatt Papier auf dem Schreibtisch: das Dokument der Ermittlungsmappe.
///
/// Alles darunter liegt auf hellem Papier ([MFlaeche.papier]): [MFarben.von] und
/// [MSchrift.von] liefern Tintenfarben, der Standardtext ist Lora in Tinte.
/// Klammer, Klebestreifen, Reißnagel und Stempel sind Zierde und bleiben für den
/// Bildschirmleser stumm (außer dem Stempeltext).
class MBlatt extends StatelessWidget {
  const MBlatt({
    super.key,
    required this.child,
    this.art = PapierArt.akte,
    this.padding = const EdgeInsets.fromLTRB(20, 18, 20, 20),
    this.neigung = 0,
    this.klammer = false,
    this.klebestreifen = false,
    this.reissnagel = false,
    this.stempel,
    this.stempelFarbe = MRoh.stempelRot,
    this.aktenzeichen,
    this.knick = false,
    this.samen = 7,
    this.randFarbe,
    this.onTap,
    this.hervorgehoben = false,
    this.kopfLinie,
    this.linien = true,
  });

  final Widget child;
  final PapierArt art;
  final EdgeInsets padding;

  /// Leichte Drehung in Bogenmaß (z. B. −0,012), wie ein hingelegtes Blatt.
  final double neigung;

  /// Büroklammer links oben.
  final bool klammer;

  /// Klebestreifen mittig oben.
  final bool klebestreifen;

  /// Reißnagel mittig oben (Korkwand).
  final bool reissnagel;

  /// Stempel rechts oben (z. B. „Geheim“, „Ermittelt“).
  final String? stempel;
  final Color stempelFarbe;

  /// Kleine Schreibmaschinenzeile oben rechts (z. B. „Akte 03 · Blatt 2“).
  final String? aktenzeichen;

  /// Waagerechter Knick in der Mitte.
  final bool knick;

  /// Samen der Papiertextur (gleicher Samen, gleiches Blatt).
  final int samen;

  /// Farbiger Rand links (z. B. Farbcode einer Figur), wie ein Registerstreifen.
  final Color? randFarbe;

  /// Tippen auf das ganze Blatt.
  final VoidCallback? onTap;

  /// Hervorgehobenes Blatt (gewählt): Akzentrahmen und stärkerer Schatten.
  final bool hervorgehoben;

  /// Lage der roten Kopflinie einer Karteikarte (Vorgabe 38; klein für Listenzeilen).
  final double? kopfLinie;

  /// Blaue Linien auf Karteikarte und Notiz.
  final bool linien;

  @override
  Widget build(BuildContext context) {
    final f = MFarben.von(context);
    final kopf = art == PapierArt.karteikarte ? (kopfLinie ?? 38.0) : 0.0;
    var innen = padding;
    if (klammer && innen.top < 28) innen = innen.copyWith(top: 28);
    if (art == PapierArt.notiz && innen.left < 40) innen = innen.copyWith(left: 40);
    if (art == PapierArt.foto) innen = const EdgeInsets.fromLTRB(10, 10, 10, 34);

    Widget inhalt = MFlaeche.papier(
      child: Builder(
        builder: (context) {
          final s = MSchrift.von(context);
          return DefaultTextStyle.merge(
            style: s.text,
            child: IconTheme.merge(data: IconThemeData(color: MFarben.von(context).papier), child: child),
          );
        },
      ),
    );
    if (aktenzeichen != null) {
      inhalt = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Text(aktenzeichen!, style: MRohSchrift.schreibmaschine.copyWith(fontSize: 12, color: MRoh.tinteLeise)),
          ),
          const SizedBox(height: 6),
          inhalt,
        ],
      );
    }

    final schatten = hervorgehoben
        ? [BoxShadow(color: Colors.black.withValues(alpha: 0.55), blurRadius: 22, offset: const Offset(0, 10))]
        : [
            BoxShadow(color: Colors.black.withValues(alpha: 0.45), blurRadius: 14, offset: const Offset(0, 6)),
            BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 2, offset: const Offset(0, 1)),
          ];

    Widget blatt = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(art == PapierArt.foto ? 2 : 3),
        boxShadow: schatten,
        border: hervorgehoben ? Border.all(color: f.akzent, width: 2) : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(art == PapierArt.foto ? 2 : 3),
        child: CustomPaint(
          painter: PapierMaler(art: art, samen: samen, knick: knick, kopf: kopf, zeilenAbstand: linien ? 26 : 100000),
          child: Stack(
            children: [
              if (randFarbe != null) Positioned(left: 0, top: 0, bottom: 0, width: 5, child: ColoredBox(color: randFarbe!)),
              Padding(padding: innen.copyWith(left: innen.left + (randFarbe != null ? 4 : 0)), child: inhalt),
            ],
          ),
        ),
      ),
    );
    if (onTap != null) {
      blatt = Material(
        type: MaterialType.transparency,
        child: InkWell(onTap: onTap, splashFactory: NoSplash.splashFactory, highlightColor: f.akzentSchwach, child: blatt),
      );
    }
    blatt = RepaintBoundary(child: blatt);
    if (klammer || klebestreifen || reissnagel || stempel != null) {
      blatt = Stack(
        clipBehavior: Clip.none,
        children: [
          blatt,
          if (klebestreifen) const Positioned(top: -10, left: 0, right: 0, child: Center(child: MKlebestreifen())),
          if (reissnagel) const Positioned(top: -6, left: 0, right: 0, child: Center(child: MReissnagel())),
          if (klammer) const Positioned(top: -14, left: 18, child: MBueroklammer()),
          if (stempel != null) Positioned(top: 6, right: 8, child: MStempel(text: stempel!, farbe: stempelFarbe, groesse: 13)),
        ],
      );
    }
    return neigung == 0 ? blatt : Transform.rotate(angle: neigung, child: blatt);
  }
}

/// Kopf eines Blatts: Schreibmaschinenzeile (z. B. „Vernehmung“) über einer
/// Linie, darunter optional ein Titel in Playfair.
class MBlattKopf extends StatelessWidget {
  const MBlattKopf({super.key, this.zeile, this.titel, this.unter});

  /// Kleine Schreibmaschinenzeile (Formularkopf), in Originalschreibung.
  final String? zeile;
  final String? titel;
  final String? unter;

  @override
  Widget build(BuildContext context) {
    final s = MSchrift.von(context);
    final f = MFarben.von(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (zeile != null) ...[
          Text(zeile!, style: s.zwischentitel.copyWith(color: f.akzent)),
          const SizedBox(height: 4),
          Container(height: 1, color: f.linieStark),
          const SizedBox(height: 10),
        ],
        if (titel != null) MGanzeWorte(titel!, stil: s.ueberschrift, minimum: 15),
        if (unter != null) ...[const SizedBox(height: 4), Text(unter!, style: s.leise)],
        if (titel != null || unter != null) const SizedBox(height: 12),
      ],
    );
  }
}

/// Formularzeile auf einem Blatt: Feldname in Schreibmaschine, Wert in Lora.
class MFeld extends StatelessWidget {
  const MFeld({super.key, required this.name, required this.wert, this.kursiv = false});

  final String name;
  final String wert;
  final bool kursiv;

  @override
  Widget build(BuildContext context) {
    final s = MSchrift.von(context);
    final f = MFarben.von(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(name, style: s.maschine.copyWith(fontSize: 13, color: f.papierLeise)),
          const SizedBox(height: 2),
          MGanzeWorte(wert, stil: kursiv ? s.kursiv : s.text),
        ],
      ),
    );
  }
}
