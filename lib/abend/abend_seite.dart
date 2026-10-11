import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../app/router.dart';
import '../l10n/lookup.dart';
import '../meta/meta_store.dart';
import '../party/party_seite.dart';
import '../party/sitzung.dart';
import '../stil/stil.dart';
import 'abend_halter.dart';
import 'online/gastgeber_ablauf.dart';
import 'online/gastgeber_sitzung.dart';
import 'online/online_halter.dart';

/// Der laufende Abend (Route `/abend`): zeigt je Abschnitt dieselben
/// Bildschirme wie der alte Einstieg `/party`, teilt sich mit ihm den
/// Phasenwechsel ([PartyAblauf]), beginnt aber hinter dem Assistenten bei den
/// Rollen. Am Ende führt die Abschlusstafel zur Belohnung (`/abend/belohnung`),
/// von dort geht es in die Detektei zurück. Solo und reihum lässt sich der Abend
/// in jeder Phase abbrechen („Abend abbrechen“, Zurück-Taste); gefragt wird beim
/// Verlassen der Route ([abendVerlassen]).
class AbendSeite extends StatefulWidget {
  const AbendSeite({super.key});

  @override
  State<AbendSeite> createState() => _AbendSeiteState();
}

class _AbendSeiteState extends State<AbendSeite> {
  late final AbendHalter _halter = context.read<AbendHalter>();
  late final PartySitzung? _sitzung = _halter.sitzung;

  /// Online-Verbindung des Geräts (fehlt in Umgebungen ohne Online-Spiel).
  OnlineHalter? _online;

  @override
  void initState() {
    super.initState();
    _online = context.read<OnlineHalter?>();
    // Ohne Abend (z. B. nach dem Neuladen der Seite) zurück in die Detektei.
    if (_sitzung == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go(Routes.start);
      });
    }
  }

  @override
  void dispose() {
    final s = _sitzung;
    if (s != null) {
      _halter.freigeben(s);
      // Online-Abend: Die Sitzung hat den Raum schon geschlossen (siehe GastgeberSitzung.dispose).
      if (s is GastgeberSitzung) _online?.vergissDienst(s.dienst);
    }
    super.dispose();
  }

  /// Das Ende ist gelesen: Ergebnis für die Belohnung merken und dorthin wechseln.
  /// Die Rolle des Geräts ist die gewählte Detektivklasse (`klasse:<name>`).
  void _zurBelohnung() {
    final s = _sitzung;
    if (s == null) return;
    final klasse = context.read<MetaStore>().loadout.cls;
    _halter.beende(AbendAbschluss(
      abendId: s.abendId,
      ergebnis: s.abendErgebnis(rolle: 'klasse:$klasse'),
      punkte: s.spiel.punkte,
      endeName: s.ende.name,
    ));
    context.go(Routes.abendBelohnung);
  }

  /// Zurück zur Detektei. Leiste und Zurück-Taste fragen selbst vorher nach:
  /// „Weiterspielen“ löst so gar keine Navigation aus (im Web sonst ein
  /// zusätzlicher Verlaufseintrag), und [abendVerlassen] fragt nach dem Ja nicht
  /// ein zweites Mal.
  Future<void> _abbrechen() async {
    if (!await _abbruchFragen(context) || !mounted) return;
    _halter.bestaetigeAbbruch();
    context.go(Routes.start);
  }

  @override
  Widget build(BuildContext context) {
    final s = _sitzung;
    // Online-Abende (Gastgeber) haben eigene Ausgänge im Menü der Leiste.
    final abbrechbar = s != null && s is! GastgeberSitzung;
    // Der ganze Abend steht im Stil seiner Akte (Akzent, Hintergrundton), auch
    // Rahmen und Hinweise des Gerüsts; PartyAblauf und GastgeberAblauf färben
    // ihre Bildschirme zusätzlich selbst.
    return AkteThema(
      akte: s?.daten.fall ?? '',
      // Die Zurück-Taste (Android) fragt nach, statt die App zu verlassen.
      child: PopScope(
        canPop: !abbrechbar,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _abbrechen();
        },
        child: Scaffold(
          backgroundColor: MFarben.von(context).grund,
          body: switch (s) {
            null => const PartyMeldung(fehler: false),
            GastgeberSitzung() => GastgeberAblauf(sitzung: s, onEnde: _zurBelohnung),
            _ => Column(
                children: [
                  _AbbrechenLeiste(onPressed: _abbrechen),
                  Expanded(
                    child: MediaQuery.removePadding(
                      context: context,
                      removeTop: true,
                      child: PartyAblauf(sitzung: s, onEnde: _zurBelohnung),
                    ),
                  ),
                ],
              ),
          },
        ),
      ),
    );
  }
}

/// Fragt beim Verlassen des laufenden Abends (Route `/abend`) nach: bei „Abend
/// abbrechen“, der Zurück-Taste und der Browser-Zurück-Taste. Ohne Rückfrage
/// bleiben der Weg zur Belohnung (der Abschluss ist dann gemerkt), Online-Abende
/// des Gastgebers (eigene Ausgänge) und die Seite ohne Abend.
FutureOr<bool> abendVerlassen(BuildContext context, AbendHalter halter) {
  final s = halter.sitzung;
  if (s == null || s is GastgeberSitzung || halter.abschluss != null || halter.abbruchBestaetigt) return true;
  return _abbruchFragen(context);
}

Future<bool> _abbruchFragen(BuildContext context) async {
  final l = L.of(context);
  final ja = await showDialog<bool>(
    context: context,
    builder: (c) => AlertDialog(
      title: Text(l.abend_abbrechen_titel),
      content: Text(l.abend_abbrechen_text),
      actions: [
        TextButton(onPressed: () => Navigator.of(c).pop(false), child: Text(l.abend_abbrechen_nein)),
        TextButton(onPressed: () => Navigator.of(c).pop(true), child: Text(l.abend_abbrechen_ja)),
      ],
    ),
  );
  return ja == true;
}

/// Schmale Leiste über dem Abend (Solo und reihum) mit dem Ausgang „Abend abbrechen“.
class _AbbrechenLeiste extends StatelessWidget {
  const _AbbrechenLeiste({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final f = MFarben.von(context);
    return DecoratedBox(
      decoration: BoxDecoration(color: f.grund2, border: Border(bottom: BorderSide(color: f.linie))),
      child: SafeArea(
        bottom: false,
        child: Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: MMass.s4),
            child: MKnopf(
              text: L.of(context).abend_abbrechen,
              art: MKnopfArt.leise,
              icon: Icons.close_rounded,
              onPressed: onPressed,
            ),
          ),
        ),
      ),
    );
  }
}
