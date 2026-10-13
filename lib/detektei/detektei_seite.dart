import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mordakte_core/runden.dart' show KartenKatalog;
import 'package:provider/provider.dart';

import '../abend/online/rueckkehr.dart';
import '../app/router.dart';
import '../karten/katalog_laden.dart';
import '../l10n/lookup.dart';
import '../meta/meta_store.dart';
import '../stil/stil.dart';
import 'akte_bausteine.dart';
import 'akten.dart';
import 'dienstausweis.dart';
import 'name_dialog.dart';
import 'schreibtisch.dart';

/// Die Detektei: der Start des Spiels (Route `/`), der Schreibtisch bei Nacht.
/// Oben die Wortmarke und der Dienstausweis (Name, Rang, Erfahrung), daneben
/// „Neuer Abend“ als Messingschild und „Beitreten“ als Etikett, darunter die
/// Akten der Kampagne als Aktenmappen und Sammlung und Profil als Karteikarten.
class DetekteiSeite extends StatefulWidget {
  const DetekteiSeite({super.key});

  @override
  State<DetekteiSeite> createState() => _DetekteiSeiteState();
}

class _DetekteiSeiteState extends State<DetekteiSeite> {
  late Future<List<AkteInfo>> _akten = AktenKatalog.laden();

  /// Katalog der Sammelkarten für den Fortschritt auf dem Eintrag „Sammlung“.
  KartenKatalog? _katalog;

  @override
  void initState() {
    super.initState();
    kartenBereit(context.read<MetaStore>()).then((k) {
      if (mounted) setState(() => _katalog = k);
    }).catchError((Object e) {
      // Ohne Katalog zeigt der Eintrag nur seinen Hinweis.
      debugPrint('DETEKTEI karten fehler $e');
    });
    // Beim ersten Start fragt die Detektei nach dem Namen (wie früher der Hub).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!context.read<MetaStore>().hasName) showNameDialog(context, first: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final t = MSchrift.von(context);
    final f = MFarben.von(context);
    final meta = context.watch<MetaStore>();
    final katalog = _katalog;
    final neueste = katalog == null || meta.neuesteKarte == null ? null : katalog[meta.neuesteKarte!];
    final knoepfe = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Ein Platz in einem Online-Abend, in den man zurückkehren kann.
        const OnlineRueckkehr(),
        MKnopf(
          text: l.detektei_neuer_abend,
          icon: Icons.nightlight_round,
          breit: true,
          gross: true,
          onPressed: () => context.go(Routes.abendNeu),
        ),
        const SizedBox(height: MMass.s12),
        MKnopf(text: l.detektei_beitreten, art: MKnopfArt.zweit, breit: true, onPressed: () => context.go(Routes.beitreten)),
        const SizedBox(height: MMass.s8),
        Text(l.detektei_beitreten_hinweis, style: t.leise.copyWith(fontSize: 13)),
      ],
    );
    return Scaffold(
      backgroundColor: f.grund,
      body: MRahmen(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                const MordakteWortmarke(),
                Positioned(top: 0, right: 0, child: MTonSchalter(an: l.ton_an, aus: l.ton_aus)),
              ],
            ),
            const SizedBox(height: MMass.s24),
            LayoutBuilder(
              builder: (context, box) {
                const ausweis = _Ausweis();
                if (box.maxWidth >= 600) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(flex: 11, child: ausweis),
                      const SizedBox(width: MMass.s24),
                      Expanded(flex: 9, child: Padding(padding: const EdgeInsets.only(top: MMass.s8), child: knoepfe)),
                    ],
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [ausweis, const SizedBox(height: MMass.s24), knoepfe],
                );
              },
            ),
            const SizedBox(height: MMass.s32),
            SchreibtischKopf(marke: l.detektei_kampagne.toUpperCase(), hinweis: l.detektei_kampagne_hinweis),
            const SizedBox(height: MMass.s20),
            FutureBuilder<List<AkteInfo>>(
              future: _akten,
              builder: (context, snap) {
                if (snap.hasError) {
                  return MBlatt(
                    art: PapierArt.notiz,
                    neigung: -0.006,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(l.detektei_akten_fehler, style: MPapierSchrift.text),
                        const SizedBox(height: MMass.s12),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: MKnopf(
                            text: l.detektei_nochmal,
                            art: MKnopfArt.zweit,
                            onPressed: () => setState(() => _akten = AktenKatalog.laden()),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                final akten = snap.data;
                if (akten == null) return Text(l.appLoading, style: t.leise);
                final mappen = [
                  for (var i = 0; i < akten.length; i++) AkteKarte(akte: akten[i], nummer: i, onTap: () => context.go(Routes.akteVon(akten[i].id))),
                ];
                return LayoutBuilder(
                  builder: (context, box) {
                    // Auf breiten Bildschirmen liegen die Mappen zu zweit nebeneinander.
                    if (box.maxWidth < 640) return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: mappen);
                    const abstand = MMass.s20;
                    final breite = (box.maxWidth - abstand) / 2;
                    return Wrap(spacing: abstand, children: [for (final m in mappen) SizedBox(width: breite, child: m)]);
                  },
                );
              },
            ),
            const SizedBox(height: MMass.s12),
            LayoutBuilder(
              builder: (context, box) {
                // Nebeneinander teilen sich die Karten die Breite (Abstand 16).
                final breite = box.maxWidth < 440 ? box.maxWidth : (box.maxWidth - MMass.s16) / 2;
                final sammlung = _Eintrag(
                  icon: Icons.style_outlined,
                  titel: l.detektei_sammlung,
                  hinweis: l.detektei_sammlung_hinweis,
                  breite: breite,
                  neigung: -0.006,
                  samen: 31,
                  zusatz: [
                    if (katalog != null) l.karten_sammlung_fortschritt(katalog.alle.where((k) => meta.besitztKarte(k.id)).length, katalog.alle.length),
                    if (neueste != null) l.karten_detektei_neueste(neueste.titel),
                  ],
                  onTap: () => context.go(Routes.sammlung),
                );
                final profil = _Eintrag(
                  icon: Icons.badge_outlined,
                  titel: l.detektei_profil,
                  hinweis: l.detektei_profil_hinweis,
                  breite: breite,
                  neigung: 0.007,
                  samen: 47,
                  onTap: () => context.go(Routes.profile),
                );
                if (box.maxWidth < 440) {
                  return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [sammlung, const SizedBox(height: MMass.s16), profil]);
                }
                // Gleich hohe Karten ohne unbegrenzte Höhe in der Spalte.
                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [Expanded(child: sammlung), const SizedBox(width: MMass.s16), Expanded(child: profil)],
                  ),
                );
              },
            ),
            const SizedBox(height: MMass.s12),
          ],
        ),
      ),
    );
  }
}

/// Der Dienstausweis als Knopf zum Profil; der Bildschirmleser liest Name, Rang
/// und Erfahrungspunkte in einem Satz.
class _Ausweis extends StatelessWidget {
  const _Ausweis();

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final meta = context.watch<MetaStore>();
    final name = meta.name ?? l.name_default;
    void zumProfil() => context.go(Routes.profile);
    return Semantics(
      button: true,
      label: l.profil_chip_semantik(name, l.rankName(meta.rank), meta.xp),
      onTap: zumProfil,
      excludeSemantics: true,
      child: Transform.rotate(
        angle: -0.008,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: zumProfil,
            borderRadius: BorderRadius.circular(9),
            splashFactory: NoSplash.splashFactory,
            highlightColor: Colors.white.withValues(alpha: 0.05),
            child: Dienstausweis(meta: meta),
          ),
        ),
      ),
    );
  }
}

/// Eintrag „Sammlung“ oder „Profil“ unter der Kampagne: eine Karteikarte mit
/// Titel über der roten Kopflinie, Hinweis in Tinte und Randnotizen in Füller.
class _Eintrag extends StatelessWidget {
  const _Eintrag({
    required this.icon,
    required this.titel,
    required this.hinweis,
    required this.onTap,
    required this.breite,
    this.zusatz = const [],
    this.neigung = 0,
    this.samen = 7,
  });

  final IconData icon;
  final String titel;
  final String hinweis;
  final VoidCallback onTap;

  /// Breite der Karte. Sie steht unter [IntrinsicHeight] und misst sich deshalb
  /// nicht selbst (kein [LayoutBuilder]).
  final double breite;

  /// Zusätzliche Zeilen unter dem Hinweis (z. B. Fortschritt der Sammlung).
  final List<String> zusatz;
  final double neigung;
  final int samen;

  static const _rand = EdgeInsets.fromLTRB(16, 12, 16, 18);

  @override
  Widget build(BuildContext context) {
    // Platz des Titels zwischen Symbol (22 + 8) und Pfeil (20). Das Wort bleibt ganz
    // (bei großer Schrift auf schmalem Handy etwas kleiner), und die rote Kopflinie
    // liegt unter der gemessenen Höhe des Titels.
    final titelBreite = breite - _rand.horizontal - 50;
    final titelStil = GanzeWorte.passend(context, titel, MPapierSchrift.ueberschrift.copyWith(fontSize: 20, height: 1.3), titelBreite);
    final tp = TextPainter(
      text: TextSpan(text: titel, style: DefaultTextStyle.of(context).style.merge(titelStil)),
      textDirection: TextDirection.ltr,
      textScaler: MediaQuery.textScalerOf(context),
    )..layout(maxWidth: titelBreite > 0 ? titelBreite : double.infinity);
    final kopf = _rand.top + tp.height + 8;
    tp.dispose();
    return Semantics(
      button: true,
      child: MBlatt(
        art: PapierArt.karteikarte,
        kopfLinie: kopf,
        neigung: neigung,
        samen: samen,
        onTap: onTap,
        padding: _rand,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(icon, color: MRoh.tinte, size: 22),
                const SizedBox(width: MMass.s8),
                Expanded(child: Text(titel, style: titelStil)),
                const Icon(Icons.arrow_forward_rounded, color: MRoh.tinteLeise, size: 20),
              ],
            ),
            const SizedBox(height: MMass.s16),
            Text(hinweis, style: MPapierSchrift.text.copyWith(fontSize: 15, height: 1.45)),
            for (final z in zusatz) ...[
              const SizedBox(height: MMass.s4),
              Text(z, style: MPapierSchrift.hand.copyWith(fontSize: 20)),
            ],
          ],
        ),
      ),
    );
  }
}
