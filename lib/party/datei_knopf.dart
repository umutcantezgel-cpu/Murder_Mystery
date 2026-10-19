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
/// der Knopf sagt dann „Teilen“ oder „Herunterladen“. Scheitert etwas, steht
/// darunter ein Satz in Handschrift.
///
/// Eine Datei, die von Einstellungen abhängt (Personenzahl, Detektiv), bekommt
/// einen Schlüssel aus diesen Einstellungen: Ändern sie sich, wird neu gebaut.
class DateiKnopf extends StatefulWidget {
  const DateiKnopf({
    super.key,
    required this.text,
    required this.bauen,
    this.icon = Icons.ios_share_rounded,
    this.haupt = false,
    this.typ = 'application/pdf',
  });

  final String text;
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

  Future<void> _tipp() async {
    final fertig = _datei;
    if (fertig != null) return _anbieten(fertig);
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

  /// Bietet die Datei an; bis zum Aufruf ohne `await`, damit der Browser den Tipp noch sieht.
  Future<void> _anbieten(FertigeDatei d) async {
    final ok = await dateiAnbieten(d.name, d.bytes, typ: widget.typ, ursprung: _ursprung());
    if (mounted) setState(() => _fehler = !ok);
  }

  @override
  Widget build(BuildContext context) {
    if (_baut) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 22,
            height: 22,
            child: MBewegung.ruhig(context)
                ? const Icon(Icons.hourglass_top_rounded, size: 22, color: MRoh.stempelRot)
                : const CircularProgressIndicator(strokeWidth: 2.5, color: MRoh.stempelRot),
          ),
          const SizedBox(width: 12),
          Flexible(child: Text(_de.druck_datei_laedt, style: MPapierSchrift.maschine)),
        ],
      );
    }
    final d = _datei;
    final bereit = d != null && zweiterTipp;
    final text = !bereit
        ? widget.text
        : (dateiTeilbar(d.name, typ: widget.typ) ? _de.druck_datei_teilen(widget.text) : _de.druck_datei_laden(widget.text));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        PartyKnopf(text: text, haupt: widget.haupt, icon: bereit ? Icons.download_done_rounded : widget.icon, onPressed: _tipp),
        if (_fehler) ...[
          const SizedBox(height: 6),
          Text(_de.druck_datei_fehler, style: MPapierSchrift.hand.copyWith(fontSize: 19)),
        ],
      ],
    );
  }
}
