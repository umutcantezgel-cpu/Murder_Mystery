import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:krimidinner_kanon/krimidinner_kanon.dart'
    show Gewoelbe, GewoelbeTexte, mappeHtml, steckbriefeHtml;

import '../../party/druck_speichern.dart';
import '../../party/party_stil.dart';
import '../abschnitt_ansicht.dart';
import '../gewoelbe_stil.dart';
import 'steckbriefe.dart' show BesetzungsLeiste;

/// Druck: Steckbriefe für alle (mit Vorschau auf Papierweiß) und die geheimen
/// Rollenmappen ohne Vorschau, je Person eine Datei. Keine Spielleitungs- und
/// keine Lösungsdatei.
class DruckTeil extends StatefulWidget {
  const DruckTeil({super.key, required this.gewoelbe, required this.rollen, required this.onBesetzung});

  final Gewoelbe gewoelbe;
  final int rollen;
  final VoidCallback onBesetzung;

  @override
  State<DruckTeil> createState() => _DruckTeilState();
}

class _DruckTeilState extends State<DruckTeil> {
  /// Rückmeldung nach dem letzten Speichern (Dateiname oder Browser-Hinweis).
  String? _status;
  bool _ohneBrowser = false;

  /// Die Rückmeldung steht bei der Tafel, deren Knopf gedrückt wurde.
  bool _beiMappen = false;

  Gewoelbe get g => widget.gewoelbe;

  /// Bietet die Datei an: in der App über das Teilen des Systems, im Browser als
  /// Download, damit sie sich wie im Hinweis speichern und drucken lässt (A-059).
  /// Das HTML entsteht im Tipp selbst, darum reicht im Browser ein Tipp. Nur wenn
  /// das Anbieten scheitert, kommt der Browser-Hinweis.
  Future<void> _speichern(String datei, String html, {required bool mappe}) async {
    final ok = await dateiAnbieten(datei, utf8.encode(html), typ: 'text/html');
    if (!mounted) return;
    setState(() {
      _ohneBrowser = !ok;
      _beiMappen = mappe;
      _status = ok ? GewoelbeTexte.erstellt(datei) : GewoelbeTexte.nurBrowser;
    });
  }

  Future<void> _steckbriefe() =>
      _speichern(GewoelbeTexte.dateiSteckbriefe(widget.rollen), steckbriefeHtml(g, widget.rollen), mappe: false);

  /// Erst beim Tipp wird die Mappe erzeugt; im Bildschirm steht nie ihr Inhalt.
  Future<void> _mappe(String person) {
    final m = g.mappeFuer(person, widget.rollen);
    return _speichern(GewoelbeTexte.dateiMappe(m.nummer), mappeHtml(m), mappe: true);
  }

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BesetzungsLeiste(rollen: widget.rollen, onBesetzung: widget.onBesetzung),
          const SizedBox(height: 8),
          _steckbriefTafel(),
          const SizedBox(height: 14),
          // Die Mappen-Knöpfe stehen vor der langen Vorschau, damit sie auch bei
          // vielen Rollen ohne langes Rollen erreichbar sind.
          _mappenTafel(),
          const SizedBox(height: 18),
          // Die Vorschau steht außerhalb der Tafel: Sie misst ihre Breite selbst.
          Text(GewoelbeTexte.vorschau.toUpperCase(), style: Keller.marke),
          const SizedBox(height: 8),
          _vorschau(),
        ],
      );

  /// Rückmeldung unter dem Knopf, der sie ausgelöst hat.
  List<Widget> _rueckmeldung({required bool mappe}) {
    final status = _status;
    if (status == null || _beiMappen != mappe) return const [];
    return [
      const SizedBox(height: 12),
      GewoelbeHinweis(
        text: status,
        icon: _ohneBrowser ? Icons.public_off_rounded : Icons.download_done_rounded,
        akzent: _ohneBrowser ? Keller.gefahr : Keller.notlicht,
      ),
    ];
  }

  Widget _steckbriefTafel() => PartyTafel(
        akzent: K9.akzent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(GewoelbeTexte.druckSteckbriefe, style: Keller.ueberschrift),
            const SizedBox(height: 6),
            const Text(GewoelbeTexte.druckSteckbriefeHinweis, style: Keller.leise),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: PartyKnopf(text: GewoelbeTexte.alsDateiSpeichern, icon: Icons.download_rounded, onPressed: _steckbriefe),
            ),
            ..._rueckmeldung(mappe: false),
          ],
        ),
      );

  /// Vorschau auf Papierweiß, so wie die Datei gedruckt aussieht.
  Widget _vorschau() {
    final karten = g.steckbriefe(widget.rollen);
    return Container(
      decoration: BoxDecoration(
        color: Papier.grund,
        borderRadius: BorderRadius.circular(6),
        boxShadow: const [BoxShadow(color: Color(0x88000000), blurRadius: 16, offset: Offset(0, 6))],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(GewoelbeTexte.titel, style: Papier.titel.copyWith(fontSize: 24)),
          Text(
            '${GewoelbeTexte.untertitel} · ${GewoelbeTexte.druckSteckbriefe} · ${GewoelbeTexte.personen(widget.rollen)}',
            style: Papier.leise,
          ),
          const Divider(color: K9.kerzenbernstein, thickness: 2, height: 22),
          LayoutBuilder(
            builder: (context, box) {
              final spalten = box.maxWidth >= 560 ? 2 : 1;
              final breite = (box.maxWidth - (spalten - 1) * 10) / spalten;
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final a in karten) SizedBox(width: breite, child: AbschnittAnsicht(a, hell: true)),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _mappenTafel() => PartyTafel(
        akzent: Keller.gefahr,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.lock_rounded, color: Keller.gefahr, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text(GewoelbeTexte.druckMappen, style: Keller.ueberschrift)),
              ],
            ),
            const SizedBox(height: 8),
            const Text(GewoelbeTexte.druckMappenWarnung, style: Keller.text),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final person in g.mappenPersonen(widget.rollen))
                  PartyKnopf(
                    text: GewoelbeTexte.mappeFuer(g.name(person)),
                    haupt: false,
                    icon: Icons.download_rounded,
                    onPressed: () => _mappe(person),
                  ),
              ],
            ),
            ..._rueckmeldung(mappe: true),
          ],
        ),
      );
}
