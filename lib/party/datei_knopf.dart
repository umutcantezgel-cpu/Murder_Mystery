import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../l10n/gen/app_localizations_de.dart';
import '../stil/stil.dart';
import 'druck_speichern.dart';
import 'party_stil.dart';

final _de = LDe();

/// Eine fertige Datei zum Anbieten.
typedef FertigeDatei = ({String name, Uint8List bytes});

/// Knopf für eine Datei, die erst beim Tipp entsteht (M5): Der erste Tipp baut
/// sie (einmal, danach liegt sie bereit). In der App geht sie gleich danach an das
/// Teilen des Systems. Im Browser wartet sie auf einen zweiten Tipp
/// ([zweiterTipp]), weil Teilen und Download dort direkt im Tipp liegen müssen;
/// dann steht da ein Knopf je Weg ([dateiWege]): immer „Herunterladen“ und, wenn
/// der Browser Dateien teilen kann, daneben „Teilen“. Scheitert etwas, steht
/// darunter ein Satz in Handschrift.
///
/// Während die Datei entsteht, steht eine ruhende Sanduhr mit Hinweis da, kein
/// Ladekreis: Der Kreis ließ die ganze Seite bei jedem Zwischenschritt neu
/// zeichnen; im Browser kostete das mehr Zeit als die Datei selbst
/// (Browserprobe der Erzählerakte: rund 20 s mit Kreis, 8 s ohne), und das
/// Setzen der PDF hält ihn ohnehin an. Kein Wort bricht mitten durch
/// ([MKnopf.ganzeWorte]).
///
/// Eine Datei, die von Einstellungen abhängt (Personenzahl, Detektiv), bekommt
/// einen Schlüssel aus diesen Einstellungen: Ändern sie sich, wird neu gebaut.
///
/// Auf Papier ([MFlaeche.papier]) stehen Hinweis und Fehler in Tinte, auf dem
/// dunklen Grund (etwa im Fuß einer Seite) in Papierfarbe.
class DateiKnopf extends StatefulWidget {
  const DateiKnopf({
    super.key,
    required this.text,
    required this.bauen,
    this.icon = Icons.ios_share_rounded,
    this.haupt = false,
    this.typ = 'application/pdf',
    this.datei,
    this.kurz = false,
  });

  final String text;

  /// Name der Datei auf den Knöpfen im Browser („Herunterladen: …“); ohne
  /// Angabe [text]. Für Knöpfe wie „Als PDF“, die die Datei nicht nennen.
  final String? datei;

  /// Im Browser stehen auf den Knöpfen der fertigen Datei nur die Wege
  /// („Herunterladen“, „Teilen“); der Bildschirmleser hört sie mit dem
  /// Dateinamen. Für einen engen Fuß wie den der Erzählerakte (320 px, große Schrift).
  final bool kurz;
  final Future<FertigeDatei> Function() bauen;
  final IconData icon;
  final bool haupt;
  final String typ;

  @override
  State<DateiKnopf> createState() => _DateiKnopfState();
}

class _DateiKnopfState extends State<DateiKnopf> {
  FertigeDatei? _datei;
  bool _baut = false;
  bool _fehler = false;

  /// Ort des Knopfs für das Teilen-Fenster (iPad).
  Rect? _ursprung() {
    final box = context.findRenderObject() as RenderBox?;
    return box == null || !box.hasSize ? null : box.localToGlobal(Offset.zero) & box.size;
  }

  Future<void> _tipp([DateiWeg? weg]) async {
    final fertig = _datei;
    if (fertig != null) return _anbieten(fertig, weg);
    setState(() {
      _baut = true;
      _fehler = false;
    });
    try {
      // Erst ein Bild mit dem Hinweis zeigen, dann die rechenlastige Erzeugung.
      await Future<void>.delayed(const Duration(milliseconds: 16));
      final d = await widget.bauen();
      if (!mounted) return;
      setState(() {
        _datei = d;
        _baut = false;
      });
      if (!zweiterTipp) await _anbieten(d);
    } catch (e, st) {
      debugPrint('DATEI bauen fehler $e\n$st');
      if (mounted) {
        setState(() {
          _baut = false;
          _fehler = true;
        });
      }
    }
  }

  /// Bietet die Datei auf dem Weg [weg] an (ohne Angabe: Standardweg); bis zum
  /// Aufruf ohne `await`, damit der Browser den Tipp noch sieht.
  Future<void> _anbieten(FertigeDatei d, [DateiWeg? weg]) async {
    final ok = await dateiAnbieten(d.name, d.bytes, typ: widget.typ, ursprung: _ursprung(), weg: weg);
    if (mounted) setState(() => _fehler = !ok);
  }

  /// Knopf für den Weg [weg] der fertigen Datei; mit [DateiKnopf.kurz] nur der Weg.
  Widget _wegKnopf(DateiWeg weg, {required bool haupt}) {
    final teilen = weg == DateiWeg.teilen;
    final name = widget.datei ?? widget.text;
    final voll = teilen ? _de.druck_datei_teilen(name) : _de.druck_datei_laden(name);
    return PartyKnopf(
      text: widget.kurz ? (teilen ? _de.druck_datei_teilen_kurz : _de.druck_datei_laden_kurz) : voll,
      semantik: widget.kurz ? voll : null,
      haupt: haupt,
      icon: teilen ? Icons.ios_share_rounded : Icons.download_rounded,
      ganzeWorte: true,
      onPressed: () => _tipp(weg),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Tinte auf Papier, Papierfarbe auf dem dunklen Grund.
    final schrift = MFlaeche.hellVon(context) ? null : MFarben.von(context).papier;
    if (_baut) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Ruhend, nie ein Ladekreis (siehe oben).
          const Icon(Icons.hourglass_top_rounded, size: 22, color: MRoh.stempelRot),
          const SizedBox(width: 12),
          Flexible(child: Text(_de.druck_datei_laedt, style: MPapierSchrift.maschine.copyWith(color: schrift))),
        ],
      );
    }
    final d = _datei;
    // Im Browser liegt die fertige Datei bereit: ein Knopf je Weg, der Standard vorn.
    final wege = d != null && zweiterTipp ? dateiWege(d.name, typ: widget.typ) : const <DateiWeg>[];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (wege.isEmpty)
          PartyKnopf(text: widget.text, haupt: widget.haupt, icon: widget.icon, ganzeWorte: true, onPressed: _tipp)
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final (i, weg) in wege.indexed) _wegKnopf(weg, haupt: widget.haupt && i == 0),
            ],
          ),
        if (_fehler) ...[
          const SizedBox(height: 6),
          Text(_de.druck_datei_fehler, style: MPapierSchrift.hand.copyWith(fontSize: 19, color: schrift)),
        ],
      ],
    );
  }
}
