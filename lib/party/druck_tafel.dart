import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mordakte_core/party_druck.dart';

import '../l10n/gen/app_localizations_de.dart';
import '../stil/stil.dart';
import 'datei_knopf.dart';
import 'party_stil.dart';
import 'sitzung.dart';

final _de = LDe();

/// Druckfassung in der App (F5-BAUMEISTER-04, Master 7.6/7.14, M5): Jede Datei
/// entsteht erst beim Tipp auf ihren Knopf und geht dann an das Teilen des
/// Systems (A-059; im Browser mit einem zweiten Tipp, [DateiKnopf]).
///
/// Mit [druckspiel]: der Hinweis mit dem Fall-Code, „Alles in einer Datei“, die
/// acht Teile (Dateinamen nur mit Nummer und Teil) und je Person ein Rollenheft
/// zum Senden. Ohne [druckspiel] (Abend am Bildschirm, reihum): nur das
/// Erzählerheft mit Vorlesetexten und Tisch, ohne Fall-Code-Hinweis.
///
/// Die Tafel ist ein Druckauftrag auf Aktenpapier: Kopf mit Druckersymbol, der
/// Hinweis, darunter die Dateien als Knöpfe.
class DruckTafel extends StatefulWidget {
  const DruckTafel({super.key, required this.sitzung, this.druckspiel = true});

  final PartySitzung sitzung;

  /// Druckspiel mit allen Teilen oder nur das Erzählerheft eines Abends am Bildschirm.
  final bool druckspiel;

  @override
  State<DruckTafel> createState() => _DruckTafelState();
}

class _DruckTafelState extends State<DruckTafel> {
  Future<DruckKontext>? _kontext;

  PartySitzung get s => widget.sitzung;

  /// Schriften und Satz entstehen beim ersten Tipp einmal; scheitert das, baut der nächste Tipp neu.
  Future<DruckKontext> _k() async {
    try {
      return await (_kontext ??= _baueKontext());
    } catch (_) {
      _kontext = null;
      rethrow;
    }
  }

  Future<DruckKontext> _baueKontext() async {
    Future<Uint8List> schrift(String name) async => (await rootBundle.load('assets/fonts/$name')).buffer.asUint8List();
    final stil = DruckStil(
      regular: await schrift('Inter-Regular.ttf'),
      fett: await schrift('Inter-Bold.ttf'),
      schreibmaschine: await schrift('SpecialElite-Regular.ttf'),
    );
    final e = s.einstellungen;
    final satz = DruckSatz.aus(s.kanon, s.daten.texte, s.fallCode, rollen: e.rollen, detektiv: e.detektiv, rundendauerMinuten: e.rundendauerMinuten);
    return DruckKontext(s.kanon, s.daten.texte, satz, stil);
  }

  /// Ein Knopf, der die Datei aus [bauen] erst beim Tipp setzt.
  Widget _knopf(String text, Future<DruckDatei> Function(DruckKontext k) bauen, {bool haupt = false, IconData icon = Icons.ios_share_rounded}) =>
      DateiKnopf(
        text: text,
        haupt: haupt,
        icon: icon,
        bauen: () async {
          final d = await bauen(await _k());
          return (name: d.name, bytes: d.bytes);
        },
      );

  @override
  Widget build(BuildContext context) => MBlatt(
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
                Expanded(
                  child: MGanzeWorte(
                    s.ui(widget.druckspiel ? 'ui.druck.app.titel' : 'ui.druck.datei.spielleitung'),
                    stil: MPapierSchrift.ueberschrift,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Container(height: 1, color: MRoh.tinte.withValues(alpha: 0.3)),
            const SizedBox(height: 10),
            if (widget.druckspiel) ..._druckspiel() else ..._erzaehlerheft(),
          ],
        ),
      );

  /// Nur das Erzählerheft: Vorlesen und Tisch für einen Abend am Bildschirm.
  List<Widget> _erzaehlerheft() => [
        Text(_de.druck_erzaehlerheft_hinweis, style: MPapierSchrift.text.copyWith(fontSize: 15)),
        const SizedBox(height: 14),
        Align(
          alignment: Alignment.centerLeft,
          child: _knopf(s.ui('ui.druck.datei.spielleitung'), (k) => erzaehlerheftDatei(k, druckspiel: false)),
        ),
      ];

  /// Das Druckspiel: Fall-Code, alles in einer Datei, die acht Teile, die Hefte je Person.
  List<Widget> _druckspiel() => [
        Text(s.ui('ui.druck.app.hinweis', {'code': s.fallCode.code}), style: MPapierSchrift.text.copyWith(fontSize: 15)),
        const SizedBox(height: 14),
        Align(
          alignment: Alignment.centerLeft,
          child: _knopf(s.ui('ui.druck.datei.alles'), druckAlles, haupt: true, icon: Icons.picture_as_pdf_rounded),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final t in druckTeile) _knopf(s.ui(t.titel), (k) => teilDatei(k, t)),
          ],
        ),
        const SizedBox(height: 18),
        MGanzeWorte(_de.druck_je_person, stil: MPapierSchrift.ueberschrift.copyWith(fontSize: 18)),
        const SizedBox(height: 4),
        Text(_de.druck_je_person_hinweis, style: MPapierSchrift.leise),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final r in s.besetzt) _knopf(_de.druck_senden_an(s.spielerName(r)), (k) => rollenheftDatei(k, r), icon: Icons.send_rounded),
          ],
        ),
      ];
}
