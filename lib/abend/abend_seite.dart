import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../app/router.dart';
import '../l10n/lookup.dart';
import '../meta/meta_store.dart';
import '../party/bildschirme/detektiv_karte.dart';
import '../party/party_seite.dart';
import '../party/sitzung.dart';
import '../stil/stil.dart';
import 'abend_halter.dart';
import 'abend_speicher.dart';
import 'online/gastgeber_ablauf.dart';
import 'online/gastgeber_sitzung.dart';
import 'online/online_halter.dart';

/// Der laufende Abend (Route `/abend`): zeigt je Abschnitt dieselben
/// Bildschirme wie der alte Einstieg `/party`, teilt sich mit ihm den
/// Phasenwechsel ([PartyAblauf]), beginnt aber hinter dem Assistenten bei den
/// Rollen. Am Ende führt die Abschlusstafel zur Belohnung (`/abend/belohnung`),
/// von dort geht es in die Detektei zurück. Solo und reihum lässt sich der Abend
/// in jeder Phase abbrechen („Abend abbrechen“, Zurück-Taste); gefragt wird beim
/// Verlassen der Route ([abendVerlassen]). Solo und reihum liegt der Abend nach
/// jedem Schritt auf dem Gerät ([AbendAblage]); nach dem Neuladen setzt ihn die
/// Detektei fort („Abend fortsetzen“).
class AbendSeite extends StatefulWidget {
  const AbendSeite({super.key});

  @override
  State<AbendSeite> createState() => _AbendSeiteState();
}

class _AbendSeiteState extends State<AbendSeite> {
  late final AbendHalter _halter = context.read<AbendHalter>();
  late final PartySitzung? _sitzung = _halter.sitzung;

  /// Legt Solo- und Reihum-Abende nach jedem Schritt ab.
  AbendAblage? _ablage;

  /// Online-Verbindung des Geräts (fehlt in Umgebungen ohne Online-Spiel).
  OnlineHalter? _online;

  @override
  void initState() {
    super.initState();
    _online = context.read<OnlineHalter?>();
    final s = _sitzung;
    if (s == null) {
      // Ohne Abend zurück in die Detektei; einen abgelegten setzt sie fort.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go(Routes.start);
      });
    } else if (s is! GastgeberSitzung) {
      _ablage = AbendAblage(s);
    }
  }

  @override
  void dispose() {
    final s = _sitzung;
    // Wer die Seite verlässt, hat den Abend abgebrochen oder geht zur
    // Belohnung; nur ein Neuladen oder das Schließen der App lässt den Stand
    // sonst liegen. Auf dem Weg zur Belohnung bleibt er, bis sie gebucht ist.
    _ablage?.beenden(loeschen: _halter.abschluss == null);
    if (s != null) {
      _halter.freigeben(s);
      // Online-Abend: Die Sitzung hat den Raum schon geschlossen (siehe GastgeberSitzung.dispose).
      if (s is GastgeberSitzung) _online?.vergissDienst(s.dienst);
    }
    super.dispose();
  }

  /// Das Ende ist gelesen: Ergebnis für die Belohnung merken und dorthin wechseln.
  /// Die Rolle des Geräts ist die Detektivklasse (`klasse:<name>`), aber nur auf
  /// dem Gerät, das den Detektiv führt (M6.4); online die Klasse des Sitzes. Ein
  /// Erzähler-Gastgeber bekommt keine Klassenkarte.
  void _zurBelohnung() {
    final s = _sitzung;
    if (s == null) return;
    final klasse = s.detektivKlasse ?? context.read<MetaStore>().loadout.cls;
    _halter.beende(AbendAbschluss(
      abendId: s.abendId,
      ergebnis: s.abendErgebnis(rolle: s.detektivAmGeraet ? 'klasse:$klasse' : null),
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
    // Gleich löschen: Die Detektei liest die Ablage, bevor diese Seite abgebaut ist.
    _ablage?.beenden();
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
                  _AbbrechenLeiste(onPressed: _abbrechen, onDetektivKarte: () => zeigeDetektivKarte(context, s)),
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
FutureOr<bool> abendVerlassen(BuildContext context, AbendHalter halter) async {
  final s = halter.sitzung;
  if (s == null || s is GastgeberSitzung || halter.abschluss != null || halter.abbruchBestaetigt) return true;
  final ja = await _abbruchFragen(context);
  // Abgebrochen: den abgelegten Abend sofort löschen (siehe _abbrechen).
  if (ja) unawaited(AbendSpeicher.loeschen());
  return ja;
}

/// Die Rückfrage als Karteikarte: „Weiterspielen“ als Etikett, „Abend abbrechen“
/// als rotes Stempelschild. Wegtippen gilt als Weiterspielen.
Future<bool> _abbruchFragen(BuildContext context) {
  final l = L.of(context);
  return frageKarteikarte(
    context,
    titel: l.abend_abbrechen_titel,
    text: l.abend_abbrechen_text,
    ja: l.abend_abbrechen_ja,
    nein: l.abend_abbrechen_nein,
    gefaehrlich: true,
  );
}

/// Schmale Leiste über dem Abend (Solo und reihum) mit dem Ausgang „Abend abbrechen“
/// und der Detektivkarte: die Lederkante des Schreibtischs mit einer Messinglinie.
class _AbbrechenLeiste extends StatelessWidget {
  const _AbbrechenLeiste({required this.onPressed, required this.onDetektivKarte});

  final VoidCallback onPressed;

  /// Öffnet die Karte des Detektivs (Auftrag, Regeln, Klasse, Befragungen).
  final VoidCallback onDetektivKarte;

  @override
  Widget build(BuildContext context) {
    final f = MFarben.von(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color.lerp(MRoh.leder, f.grund, 0.35)!, f.grund2],
        ),
        border: Border(bottom: BorderSide(color: MRoh.messingMitte.withValues(alpha: 0.35))),
        boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: MMass.s4),
          // Je Knopf höchstens die halbe Breite: Mit großer Schrift brechen die Texte um, statt überzulaufen.
          child: Row(
            children: [
              Flexible(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: MKnopf(text: L.of(context).detektiv_karte_oeffnen, art: MKnopfArt.leise, icon: Icons.badge_outlined, onPressed: onDetektivKarte),
                ),
              ),
              Flexible(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: MKnopf(
                    text: L.of(context).abend_abbrechen,
                    art: MKnopfArt.leise,
                    icon: Icons.close_rounded,
                    onPressed: onPressed,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
