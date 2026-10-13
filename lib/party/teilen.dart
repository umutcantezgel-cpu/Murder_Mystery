import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';

import '../l10n/gen/app_localizations_de.dart';
import '../stil/stil.dart';
import 'sitzung.dart';

final _de = LDe();

/// Teilkarte eines geschlossenen Falls (M8): ohne Täter und ohne Lösung, damit
/// sie niemandem den Fall verdirbt. Akte, Urteil, Punkte und Ende; gibt es einen
/// Fall-Code, lädt er ein, denselben Fall zu spielen.
class TeilKarte extends StatelessWidget {
  const TeilKarte({
    super.key,
    required this.akte,
    required this.akteId,
    required this.richtig,
    required this.urteil,
    required this.punkte,
    required this.ende,
    this.code,
  });

  final String akte;
  final String akteId;
  final bool richtig;
  final String urteil;
  final String punkte;
  final String ende;
  final String? code;

  /// Format der Karte (Hochformat 4:5, gut für Nachrichten und Status).
  static const groesse = Size(360, 450);

  @override
  Widget build(BuildContext context) {
    final farbe = richtig ? const Color(0xFF2F6B37) : MRoh.stempelRot;
    final stil = AkteStil.fuer(akteId);
    return Container(
      width: groesse.width,
      height: groesse.height,
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color.lerp(stil.hintergrund, MRoh.grund, 0.3)!, MRoh.grund]),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _de.appTitle.toUpperCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: MRohSchrift.anzeige,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              fontVariations: [FontVariation('wght', 800)],
              letterSpacing: 6,
              color: MRoh.messingHell,
            ),
          ),
          const Spacer(),
          MAktenmappe(
            reiter: akte,
            farbe: farbe,
            siegel: stil.sigel,
            blaetter: 2,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_de.teilen_marke, style: MPapierSchrift.zwischentitel.copyWith(color: MRoh.stempelRot)),
                const SizedBox(height: 6),
                MGanzeWorte(ende, stil: MPapierSchrift.titel.copyWith(fontSize: 26), minimum: 16),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: Text(punkte, style: MPapierSchrift.maschine.copyWith(fontSize: 20))),
                    MStempel(text: urteil, farbe: farbe, groesse: 17, winkel: -0.14),
                  ],
                ),
                const SizedBox(height: 22),
                if (code case final c?) ...[
                  Text(_de.teilen_code_aufruf, style: MPapierSchrift.hand.copyWith(fontSize: 19)),
                  const SizedBox(height: 2),
                  Text(c, style: MPapierSchrift.maschine.copyWith(fontSize: 22, letterSpacing: 2.4)),
                ] else
                  Text(_de.teilen_aufruf, style: MPapierSchrift.hand.copyWith(fontSize: 19)),
              ],
            ),
          ),
          const Spacer(),
          Text(
            _de.teilen_fuss,
            textAlign: TextAlign.center,
            style: MRohSchrift.leise.copyWith(color: MRoh.messingHell.withValues(alpha: 0.8), fontSize: 12),
          ),
        ],
      ),
    );
  }
}

/// Die Teilkarte eines beendeten Abends (erst nach dem Finale).
TeilKarte teilKarteFuer(PartySitzung s) {
  final ende = s.ende;
  return TeilKarte(
    akte: s.kanon.fall['titel'] as String,
    akteId: s.daten.fall,
    richtig: ende.richtig,
    urteil: ende.richtig ? _de.verdict_stamp_solid : _de.verdict_stamp_wrong,
    punkte: s.ui('ui.aufloesung.punkte', {'punkte': '${s.spiel.punkte}'}),
    ende: ende.name,
    code: s.daten.kanon.festeLoesung ? null : s.fallCode.code,
  );
}

/// Der Begleittext zur Teilkarte, ebenfalls ohne Täter.
String teilText(PartySitzung s) {
  final akte = s.kanon.fall['titel'] as String;
  final punkte = s.ui('ui.aufloesung.punkte', {'punkte': '${s.spiel.punkte}'});
  return s.daten.kanon.festeLoesung ? _de.teilen_text(akte, s.ende.name, punkte) : _de.teilen_text_code(akte, s.ende.name, punkte, s.fallCode.code);
}

/// Zeichnet [kind] abseits des Bildschirms in der Größe [groesse] und liefert
/// ein PNG. Thema und Farben kommen aus [context]; Texte bringt [kind] selbst mit.
Future<Uint8List?> widgetAlsPng(BuildContext context, Widget kind, {required Size groesse, double pixel = 3}) async {
  final grenze = RenderRepaintBoundary();
  final ansicht = RenderView(
    view: View.of(context),
    child: RenderPositionedBox(child: grenze),
    configuration: ViewConfiguration(
      logicalConstraints: BoxConstraints.tight(groesse),
      physicalConstraints: BoxConstraints.tight(groesse * pixel),
      devicePixelRatio: pixel,
    ),
  );
  final pipeline = PipelineOwner()..rootNode = ansicht;
  ansicht.prepareInitialFrame();
  final fokus = FocusManager();
  final bau = BuildOwner(focusManager: fokus);
  final wurzel = RenderObjectToWidgetAdapter<RenderBox>(
    container: grenze,
    child: InheritedTheme.captureAll(
      context,
      MediaQuery(
        data: MediaQueryData(size: groesse, devicePixelRatio: pixel),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Material(type: MaterialType.transparency, child: kind),
        ),
      ),
    ),
  ).attachToRenderTree(bau);
  bau.buildScope(wurzel);
  bau.finalizeTree();
  pipeline
    ..flushLayout()
    ..flushCompositingBits()
    ..flushPaint();
  try {
    final bild = await grenze.toImage(pixelRatio: pixel);
    try {
      final daten = await bild.toByteData(format: ui.ImageByteFormat.png);
      return daten?.buffer.asUint8List();
    } finally {
      bild.dispose();
    }
  } finally {
    // Den Baum abseits des Bildschirms wieder abbauen: ohne Kind neu anhängen,
    // dann räumt finalizeTree die Elemente ab; der FocusManager meldet sich ab.
    RenderObjectToWidgetAdapter<RenderBox>(container: grenze).attachToRenderTree(bau, wurzel);
    bau.finalizeTree();
    fokus.dispose();
    pipeline
      ..rootNode = null
      ..dispose();
  }
}

/// Das Teilen des Systems; Tests setzen hier einen Zeugen ein.
@visibleForTesting
Future<ShareResult> Function(ShareParams) teilenUeber = (p) => SharePlus.instance.share(p);

bool _teiltGerade = false;

/// Teilt den beendeten Abend: Karte als Bild und Text über das Teilen des
/// Systems, immer nur einmal zur Zeit (Doppeltipp). Im Browser nur den Text:
/// Viele Browser können keine Dateien teilen und laden das Bild sonst
/// stillschweigend herunter. [ursprung] ist der Knopf (iPad: Ort des Fensters).
Future<void> abendTeilen(BuildContext context, PartySitzung s, {Rect? ursprung}) async {
  if (_teiltGerade) return;
  _teiltGerade = true;
  try {
    final text = teilText(s);
    final name = 'mordakte-${s.daten.fall}.png';
    Uint8List? png;
    if (!kIsWeb) {
      try {
        png = await widgetAlsPng(context, teilKarteFuer(s), groesse: TeilKarte.groesse);
      } catch (e) {
        debugPrint('TEILEN bild fehler $e');
      }
    }
    await teilenUeber(
      ShareParams(
        text: text,
        subject: _de.teilen_betreff(s.kanon.fall['titel'] as String),
        files: png == null ? null : [XFile.fromData(png, mimeType: 'image/png', name: name)],
        fileNameOverrides: png == null ? null : [name],
        sharePositionOrigin: ursprung,
      ),
    );
  } catch (e) {
    debugPrint('TEILEN fehler $e');
  } finally {
    _teiltGerade = false;
  }
}
