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

/// Druckmappe einer Akte (Route `/akte/:id/druck`): Personen und Fall-Code
/// einstellen, dann die PDF-Dateien erzeugen ([DruckTafel]). Es entsteht dabei
/// kein Abend; die Sitzung dient nur dem Satz der Druckdateien.
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
    final t = MSchrift.von(context);
    final s = _sitzung, w = _werte;
    return AkteThema(
      akte: widget.akteId,
      child: Builder(
        builder: (context) => Scaffold(
          backgroundColor: MFarben.von(context).grund,
          body: MRahmen(
            marke: l.detektei_akte_druckmappe,
            titel: l.detektei_druck_titel,
            untertitel: l.detektei_druck_hinweis,
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
            child: _fehler
                ? MTafel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(l.abend_fehler, style: t.text),
                        const SizedBox(height: MMass.s12),
                        MKnopf(text: l.abend_nochmal, art: MKnopfArt.zweit, onPressed: _laden),
                      ],
                    ),
                  )
                : s == null || w == null
                    ? Text(l.abend_laedt, style: t.leise)
                    : _bereit
                        ? DruckTafel(sitzung: s)
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              PersonenAbschnitt(werte: w),
                              DetektivAbschnitt(werte: w),
                              FallAbschnitt(werte: w),
                            ],
                          ),
          ),
        ),
      ),
    );
  }
}
