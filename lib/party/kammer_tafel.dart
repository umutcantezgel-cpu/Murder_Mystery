import 'package:flutter/material.dart';
import 'package:mordakte_core/party_druck.dart';

import '../l10n/gen/app_localizations_de.dart';
import '../stil/stil.dart';
import 'datei_knopf.dart';
import 'party_stil.dart';

final _de = LDe();

/// Das Kammerspiel in der Druckmappe (B1, B3, ARCHITEKTUR A2/A3): fester Fall,
/// ein Satz PDFs für die Personenzahl und den Detektiv des [kontext]. Es ersetzt
/// dort die alte Druckfassung (`DruckTafel` mit Druckspiel); eine Erzählerakte
/// bietet die Tafel nie an (E16).
///
/// Zuerst der Hinweis, dann „Alles in einer Datei“ ([kammerAlles]), die acht
/// Teile ([kammerDruckteile]) und unter „Rollenhefte einzeln senden“ je besetzter
/// Rolle ein Knopf „Senden an …“ ([kammerEinzeldatei]): mit dem Spielernamen der
/// Gästeliste ([KammerKontext.sendenAn]), sonst dem Namen der Rolle. Titel und
/// Dateinamen der Teile kommen aus dem Inhalt (`ui/*.json`), die Sätze der App
/// aus der Lokalisierung; im Code steht kein Text.
///
/// Jede Datei entsteht erst beim Tipp auf ihren Knopf ([DateiKnopf]): auf iOS
/// und am Rechner geht sie gleich an das Teilen des Systems, im Browser und in
/// der Android-App mit einem zweiten Tipp („Herunterladen“, „Teilen“). Die
/// Knöpfe tragen Personenzahl und Detektiv im Schlüssel: Kommt ein Kontext mit
/// anderen Einstellungen, entsteht jede Datei neu.
///
/// Die Tafel ist ein Druckauftrag auf Aktenpapier wie die DruckTafel: Kopf mit
/// Druckersymbol, Hinweis, darunter die Dateien als Knöpfe.
class KammerTafel extends StatelessWidget {
  const KammerTafel({super.key, required this.kontext});

  /// Inhalt, Besetzung, Stil, Detektiv und Spielernamen des Satzes.
  final KammerKontext kontext;

  KammerKontext get k => kontext;

  /// Ein Knopf, der die Datei aus [bauen] erst beim Tipp setzt; [datei] nennt sie
  /// auf den Knöpfen der fertigen Datei, wenn [text] sie nicht nennt. [id] macht
  /// den Schlüssel eindeutig, Personenzahl und Detektiv machen ihn neu.
  Widget _knopf(String id, String text, Future<DruckDatei> Function() bauen,
          {bool haupt = false, IconData icon = Icons.ios_share_rounded, String? datei}) =>
      DateiKnopf(
        key: ValueKey('kammer-$id-${k.personen}-${k.detektiv}'),
        text: text,
        datei: datei,
        haupt: haupt,
        icon: icon,
        bauen: () async {
          final d = await bauen();
          return (name: d.name, bytes: d.bytes);
        },
      );

  /// Name der fertigen Datei je Person: Rollenheft (Platz 1–10) oder Zusatzheft (11–18).
  String _heftVon(KammerPlatz p) =>
      p.art == KammerArt.zusatz ? _de.druck_zusatzheft_von(k.sendenAn(p)) : _de.druck_rollenheft_von(k.sendenAn(p));

  @override
  Widget build(BuildContext context) => MBlatt(
        klammer: true,
        samen: 62,
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
                Expanded(child: MGanzeWorte(kammerKlartext(k.spielTitel), stil: MPapierSchrift.ueberschrift)),
              ],
            ),
            const SizedBox(height: 6),
            Container(height: 1, color: MRoh.tinte.withValues(alpha: 0.3)),
            const SizedBox(height: 10),
            Text(_de.druck_kammer_hinweis('${k.personen}', '${k.besetzung.rollen}'), style: MPapierSchrift.text.copyWith(fontSize: 15)),
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerLeft,
              child: _knopf('alles', kammerKlartext(k.uiGemeinsam('titel.alles')), () => kammerAlles(k), haupt: true, icon: Icons.picture_as_pdf_rounded),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final t in kammerDruckteile(k)) _knopf('teil-${t.nr}', kammerKlartext(t.titel), () => kammerTeilDatei(k, t)),
              ],
            ),
            const SizedBox(height: 18),
            MGanzeWorte(_de.druck_je_person, stil: MPapierSchrift.ueberschrift.copyWith(fontSize: 18)),
            const SizedBox(height: 4),
            Text(_de.druck_kammer_je_person_hinweis, style: MPapierSchrift.leise),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final p in k.besetzung.besetzt)
                  _knopf(
                    'einzeln-${p.id}',
                    _de.druck_senden_an(k.sendenAn(p)),
                    () => kammerEinzeldatei(k, p),
                    icon: Icons.send_rounded,
                    // Nach dem Bauen „Herunterladen: Rollenheft Mia“, nicht „Herunterladen: Senden an Mia“.
                    datei: _heftVon(p),
                  ),
              ],
            ),
          ],
        ),
      );
}
