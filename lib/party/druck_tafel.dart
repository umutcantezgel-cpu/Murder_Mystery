import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mordakte_core/party_druck.dart';

import '../l10n/gen/app_localizations_de.dart';
import '../stil/stil.dart';
import 'datei_knopf.dart';
import 'erzaehlerakte_druck.dart';
import 'party_stil.dart';
import 'sitzung.dart';

final _de = LDe();

/// Druckfassung in der App (F5-BAUMEISTER-04, Master 7.6/7.14, M5): Jede Datei
/// entsteht erst beim Tipp auf ihren Knopf und geht dann an das Teilen des
/// Systems (A-059; im Browser und in der Android-App mit einem zweiten Tipp:
/// „Herunterladen“ oder „Teilen“, [DateiKnopf]).
///
/// Mit [druckspiel]: der Hinweis mit dem Fall-Code, „Alles in einer Datei“, die
/// acht Teile (Dateinamen nur mit Nummer und Teil) und je Person ein Rollenheft
/// zum Senden. Ohne [druckspiel] (Abend am Bildschirm, reihum): nur das
/// Erzählerheft mit Vorlesetexten und Tisch, ohne Fall-Code-Hinweis.
///
/// Mit [erzaehlerakte] (nur die Druckmappe der Akte, nie die Rollenvergabe, die
/// der ganze Tisch sieht) kommt im Druckspiel darunter die Erzählerakte (A-063)
/// für die Person, die erzählt: ohne Satz und Fall-Code, mit den Zielen des
/// Kanons wie das Druckspiel.
///
/// Die Tafel ist ein Druckauftrag auf Aktenpapier: Kopf mit Druckersymbol, der
/// Hinweis, darunter die Dateien als Knöpfe.
class DruckTafel extends StatefulWidget {
  const DruckTafel({super.key, required this.sitzung, this.druckspiel = true, this.erzaehlerakte = false});

  final PartySitzung sitzung;

  /// Druckspiel mit allen Teilen oder nur das Erzählerheft eines Abends am Bildschirm.
  final bool druckspiel;

  /// Bietet die Tafel auch die Erzählerakte an? Nur in der Druckmappe der Akte.
  final bool erzaehlerakte;

  @override
  State<DruckTafel> createState() => _DruckTafelState();
}

class _DruckTafelState extends State<DruckTafel> {
  Future<DruckKontext>? _kontext;
  Future<ErzaehlerakteKontext?>? _akte;

  /// Personenzahl, für die [_akte] entstand.
  int? _akteRollen;

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
    return DruckKontext(s.kanon, s.daten.texte, satz, stil, diashow: s.daten.diashow);
  }

  /// Schriften und Porträts der Erzählerakte entstehen beim ersten Tipp auf ihren
  /// Knopf; scheitert das, baut der nächste Tipp neu. Ziele des Kanons wie im
  /// Druckspiel (nie die Sterne von „Dein Moment“), Personenzahl der Einstellung.
  /// Ändert sie sich, entsteht der Kontext neu (wie der Knopf mit seinem Schlüssel).
  Future<ErzaehlerakteKontext> _ka() async {
    final n = s.einstellungen.rollen;
    if (_akteRollen != n) {
      _akte = null;
      _akteRollen = n;
    }
    final laeuft = _akte ??= erzaehlerakteKontext(s.daten, einfluss: false, rollen: n);
    try {
      final k = await laeuft;
      return k ?? (throw StateError('Diese Akte hat keine Erzählerakte.'));
    } catch (_) {
      if (identical(_akte, laeuft)) _akte = null;
      rethrow;
    }
  }

  /// Gibt es hier die Erzählerakte? Nur in der Druckmappe, im Druckspiel, nie im
  /// Solo und nur bei Akten mit Erzählerakte.
  bool get _mitErzaehlerakte => widget.erzaehlerakte && widget.druckspiel && !s.solo && s.daten.erzaehlerakteFuer(einfluss: false) != null;

  /// Ein Knopf, der die Datei aus [bauen] erst beim Tipp setzt; [datei] nennt sie
  /// auf den Knöpfen der fertigen Datei, wenn [text] sie nicht nennt.
  Widget _knopf(String text, Future<DruckDatei> Function(DruckKontext k) bauen, {bool haupt = false, IconData icon = Icons.ios_share_rounded, String? datei}) =>
      DateiKnopf(
        text: text,
        datei: datei,
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
            for (final r in s.besetzt)
              _knopf(
                _de.druck_senden_an(s.spielerName(r)),
                (k) => rollenheftDatei(k, r),
                icon: Icons.send_rounded,
                // Nach dem Bauen „Herunterladen: Rollenheft Ayla“, nicht „Herunterladen: Senden an Ayla“.
                datei: _de.druck_rollenheft_von(s.spielerName(r)),
              ),
          ],
        ),
        if (_mitErzaehlerakte) ..._erzaehlerakte(),
      ];

  /// Die Erzählerakte (A-063) als eigener Abschnitt: nur für die Person, die erzählt.
  List<Widget> _erzaehlerakte() => [
        const SizedBox(height: 18),
        MGanzeWorte(s.ui('ui.druck.paket.dateien.ordner4'), stil: MPapierSchrift.ueberschrift.copyWith(fontSize: 18)),
        const SizedBox(height: 4),
        Text(_de.druck_erzaehlerakte_hinweis, style: MPapierSchrift.leise),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerLeft,
          child: DateiKnopf(
            key: ValueKey('druck-erzaehlerakte-${s.einstellungen.rollen}'),
            text: s.ui('ui.druck.akte.titel'),
            icon: Icons.folder_shared_outlined,
            bauen: () async => erzaehlerakteDatei(await _ka()),
          ),
        ),
      ];
}
