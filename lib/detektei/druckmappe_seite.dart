import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../abend/einrichtung/abschnitte.dart';
import '../app/router.dart';
import '../l10n/lookup.dart';
import '../party/daten.dart';
import '../party/druck_tafel.dart';
import '../party/sitzung.dart';
import '../stil/stil.dart';
import 'akte_bausteine.dart';
import 'akten.dart';

/// Druckmappe einer Akte (Route `/akte/:id/druck`): Personen und Fall-Code
/// einstellen, dann die PDF-Dateien erzeugen ([DruckTafel]). Es entsteht dabei
/// kein Abend; die Sitzung dient nur dem Satz der Druckdateien.
///
/// Oben liegt die Mappe der Druckfassung (Reiter mit der Aktennummer, Titel der
/// Akte, Anleitung), darunter die Einstellungen auf dem Schreibtisch.
class DruckmappeSeite extends StatefulWidget {
  const DruckmappeSeite({super.key, required this.akteId});

  final String akteId;

  @override
  State<DruckmappeSeite> createState() => _DruckmappeSeiteState();
}

class _DruckmappeSeiteState extends State<DruckmappeSeite> {
  PartySitzung? _sitzung;
  EinrichtungsWerte? _werte;
  bool _fehler = false;
  bool _bereit = false;

  /// Titel und Platz der Akte für die Mappe; ohne Kampagne bleibt die Mappe schlicht.
  late final Future<List<AkteInfo>> _akten = AktenKatalog.laden().catchError((Object _) => const <AkteInfo>[]);

  @override
  void initState() {
    super.initState();
    _laden();
  }

  Future<void> _laden() async {
    if (_fehler) setState(() => _fehler = false);
    try {
      final daten = await PartyDaten.laden(rootBundle, fall: widget.akteId);
      if (!mounted) return;
      final s = PartySitzung(daten);
      setState(() {
        _sitzung = s;
        _werte = EinrichtungsWerte(s);
      });
    } catch (e, st) {
      debugPrint('DRUCKMAPPE laden fehler $e\n$st');
      if (mounted) setState(() => _fehler = true);
    }
  }

  @override
  void dispose() {
    _werte?.dispose();
    _sitzung?.dispose();
    super.dispose();
  }

  void _vorbereiten() {
    _werte!.starten(druckErzwingen: true);
    setState(() => _bereit = true);
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final s = _sitzung, w = _werte;
    return AkteThema(
      akte: widget.akteId,
      child: Builder(
        builder: (context) => Scaffold(
          backgroundColor: MFarben.von(context).grund,
          body: MRahmen(
            aktionen: [
              MKnopf(
                text: l.common_back,
                art: MKnopfArt.zweit,
                icon: Icons.arrow_back_rounded,
                onPressed: () => context.go(Routes.akteVon(widget.akteId)),
              ),
              if (!_bereit && w != null)
                ListenableBuilder(
                  listenable: w,
                  builder: (context, _) => MKnopf(
                    text: l.detektei_druck_vorbereiten,
                    icon: Icons.print_rounded,
                    onPressed: w.codeOk ? _vorbereiten : null,
                  ),
                ),
            ],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: MMass.s8),
                FutureBuilder<List<AkteInfo>>(
                  future: _akten,
                  builder: (context, snap) => _Deckel(akteId: widget.akteId, akten: snap.data ?? const []),
                ),
                const SizedBox(height: MMass.s32),
                if (_fehler)
                  MBlatt(
                    art: PapierArt.notiz,
                    neigung: -0.006,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(l.abend_fehler, style: MPapierSchrift.text),
                        const SizedBox(height: MMass.s12),
                        Align(alignment: Alignment.centerLeft, child: MKnopf(text: l.abend_nochmal, art: MKnopfArt.zweit, onPressed: _laden)),
                      ],
                    ),
                  )
                else if (s == null || w == null)
                  Text(l.abend_laedt, style: MSchrift.von(context).leise)
                else if (_bereit)
                  DruckTafel(sitzung: s)
                else ...[
                  PersonenAbschnitt(werte: w),
                  DetektivAbschnitt(werte: w),
                  FallAbschnitt(werte: w),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Die Mappe der Druckfassung: Reiter „Akte Nr. 0X“, Formularkopf mit dem Titel
/// der Akte, „Druckmappe“ in Playfair und die Anleitung in Tinte.
class _Deckel extends StatelessWidget {
  const _Deckel({required this.akteId, required this.akten});

  final String akteId;
  final List<AkteInfo> akten;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final index = akten.indexWhere((a) => a.id == akteId);
    final akte = index < 0 ? null : akten[index];
    return MAktenmappe(
      reiter: index < 0 ? l.detektei_akte_druckmappe : l.case_file_no(akteNummer(index)),
      farbe: AkteStil.fuer(akteId).akzent,
      siegel: akte == null ? null : akteSigel(akte),
      blaetter: 3,
      neigung: -0.003,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 26),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (akte != null) MBlattKopf(zeile: akte.titel),
                Semantics(header: true, child: Text(l.detektei_druck_titel, style: MPapierSchrift.titel)),
                const SizedBox(height: MMass.s12),
                Text(l.detektei_druck_hinweis, style: MPapierSchrift.text),
              ],
            ),
          ),
          const SizedBox(width: MMass.s12),
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Icon(Icons.print_rounded, size: 30, color: MRoh.tinteLeise),
          ),
        ],
      ),
    );
  }
}
