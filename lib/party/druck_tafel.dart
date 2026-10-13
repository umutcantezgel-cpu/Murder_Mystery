import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mordakte_core/party_druck.dart';

import '../stil/stil.dart';
import 'druck_speichern.dart';
import 'party_stil.dart';
import 'sitzung.dart';

/// Druckfassung in der App (F5-BAUMEISTER-04, Master 7.6/7.14): erzeugt den
/// PDF-Satz für Fall-Code und Personenzahl dieser Sitzung und bietet jede
/// Datei einzeln zum Herunterladen an. Dateinamen tragen nur Nummer und Teil.
///
/// Die Tafel ist ein Druckauftrag auf Aktenpapier: Kopf mit Druckersymbol, der
/// Hinweis mit dem Fall-Code, darunter die Dateien als Aktenetiketten.
class DruckTafel extends StatefulWidget {
  const DruckTafel({super.key, required this.sitzung});

  final PartySitzung sitzung;

  @override
  State<DruckTafel> createState() => _DruckTafelState();
}

class _DruckTafelState extends State<DruckTafel> {
  List<DruckDatei>? _dateien;
  bool _laeuft = false;
  bool _ohneBrowser = false;

  PartySitzung get s => widget.sitzung;

  Future<void> _erstellen() async {
    setState(() => _laeuft = true);
    // Erst ein Bild mit dem Hinweis zeigen, dann die (rechenlastige) Erzeugung.
    await Future<void>.delayed(const Duration(milliseconds: 16));
    Future<Uint8List> schrift(String name) async => (await rootBundle.load('assets/fonts/$name')).buffer.asUint8List();
    final stil = DruckStil(
      regular: await schrift('Inter-Regular.ttf'),
      fett: await schrift('Inter-Bold.ttf'),
      schreibmaschine: await schrift('SpecialElite-Regular.ttf'),
    );
    final e = s.einstellungen;
    final satz = DruckSatz.aus(s.kanon, s.daten.texte, s.fallCode, rollen: e.rollen, detektiv: e.detektiv, rundendauerMinuten: e.rundendauerMinuten);
    final dateien = await druckDateien(DruckKontext(s.kanon, s.daten.texte, satz, stil));
    if (!mounted) return;
    setState(() {
      _dateien = dateien;
      _laeuft = false;
    });
  }

  String _teil(String name) => switch (name.substring(0, 2)) {
        '00' => 'spielleitung',
        '01' => 'detektivbogen',
        '10' => 'rollenhefte',
        '11' => 'fassungen',
        '12' => 'stimmkarten',
        '20' => 'indizkarten',
        '21' => 'umschlaege',
        _ => 'aufloesung',
      };

  @override
  Widget build(BuildContext context) {
    final dateien = _dateien;
    return MBlatt(
      klammer: true,
      samen: 61,
      neigung: -0.003,
      randFarbe: context.farben.akzent,
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.print_outlined, color: MRoh.tinte, size: 24),
              const SizedBox(width: 10),
              Expanded(child: Text(s.ui('ui.druck.app.titel'), style: MPapierSchrift.ueberschrift)),
            ],
          ),
          const SizedBox(height: 6),
          Container(height: 1, color: MRoh.tinte.withValues(alpha: 0.3)),
          const SizedBox(height: 10),
          Text(s.ui('ui.druck.app.hinweis', {'code': s.fallCode.code}), style: MPapierSchrift.text.copyWith(fontSize: 15)),
          const SizedBox(height: 14),
          if (dateien == null)
            Align(
              alignment: Alignment.centerLeft,
              child: _laeuft
                  ? Row(children: [
                      SizedBox(
                        width: 22,
                        height: 22,
                        child: MBewegung.ruhig(context)
                            ? const Icon(Icons.hourglass_top_rounded, size: 22, color: MRoh.stempelRot)
                            : const CircularProgressIndicator(strokeWidth: 2.5, color: MRoh.stempelRot),
                      ),
                      const SizedBox(width: 12),
                      Flexible(child: Text(s.ui('ui.druck.app.laedt'), style: MPapierSchrift.maschine)),
                    ])
                  : PartyKnopf(text: s.ui('ui.druck.app.erstellen'), haupt: false, icon: Icons.print_rounded, onPressed: _erstellen),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final d in dateien)
                  PartyKnopf(
                    text: s.ui('ui.druck.datei.${_teil(d.name)}'),
                    haupt: false,
                    icon: Icons.download_rounded,
                    onPressed: () {
                      final ok = dateiAnbieten(d.name, d.bytes);
                      if (!ok) setState(() => _ohneBrowser = true);
                    },
                  ),
              ],
            ),
          if (_ohneBrowser) ...[
            const SizedBox(height: 10),
            Text(s.ui('ui.druck.app.nur_browser'), style: MPapierSchrift.hand.copyWith(fontSize: 20)),
          ],
        ],
      ),
    );
  }
}
