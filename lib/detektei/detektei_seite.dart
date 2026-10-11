import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../app/router.dart';
import '../l10n/lookup.dart';
import '../meta/meta_store.dart';
import '../stil/stil.dart';
import '../ui/widgets/meters.dart' show RankBadge;
import 'akte_bausteine.dart';
import 'akten.dart';
import 'name_dialog.dart';

/// Die Detektei: der Start des Spiels (Route `/`). Name und Rang des Profils,
/// „Neuer Abend“, „Beitreten“, die Akten der Kampagne, die Sammlung und das Profil.
class DetekteiSeite extends StatefulWidget {
  const DetekteiSeite({super.key});

  @override
  State<DetekteiSeite> createState() => _DetekteiSeiteState();
}

class _DetekteiSeiteState extends State<DetekteiSeite> {
  late Future<List<AkteInfo>> _akten = AktenKatalog.laden();

  @override
  void initState() {
    super.initState();
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
    return Scaffold(
      backgroundColor: f.grund,
      body: MRahmen(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _Kopf(),
            const SizedBox(height: MMass.s24),
            MKnopf(
              text: l.detektei_neuer_abend,
              icon: Icons.nightlight_round,
              breit: true,
              gross: true,
              onPressed: () => context.go(Routes.abendNeu),
            ),
            const SizedBox(height: MMass.s12),
            MKnopf(text: l.detektei_beitreten, art: MKnopfArt.zweit, breit: true, onPressed: null),
            const SizedBox(height: MMass.s8),
            Row(
              children: [
                MChip(l.detektei_bald, farbe: f.papierLeise),
                const SizedBox(width: MMass.s8),
                Expanded(child: Text(l.detektei_beitreten_hinweis, style: t.leise.copyWith(fontSize: 13))),
              ],
            ),
            const SizedBox(height: MMass.s32),
            Text(l.detektei_kampagne.toUpperCase(), style: t.marke),
            const SizedBox(height: 2),
            Text(l.detektei_kampagne_hinweis, style: t.leise),
            const SizedBox(height: MMass.s12),
            FutureBuilder<List<AkteInfo>>(
              future: _akten,
              builder: (context, snap) {
                if (snap.hasError) {
                  return MTafel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(l.detektei_akten_fehler, style: t.text),
                        const SizedBox(height: MMass.s12),
                        MKnopf(
                          text: l.detektei_nochmal,
                          art: MKnopfArt.zweit,
                          onPressed: () => setState(() => _akten = AktenKatalog.laden()),
                        ),
                      ],
                    ),
                  );
                }
                final akten = snap.data;
                if (akten == null) return Text(l.appLoading, style: t.leise);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [for (final a in akten) AkteKarte(akte: a, onTap: () => context.go(Routes.akteVon(a.id)))],
                );
              },
            ),
            const SizedBox(height: MMass.s12),
            LayoutBuilder(
              builder: (context, box) {
                final sammlung = _Eintrag(
                  icon: Icons.style_outlined,
                  titel: l.detektei_sammlung,
                  hinweis: l.detektei_sammlung_hinweis,
                  onTap: () => context.go(Routes.sammlung),
                );
                final profil = _Eintrag(
                  icon: Icons.badge_outlined,
                  titel: l.detektei_profil,
                  hinweis: l.detektei_profil_hinweis,
                  onTap: () => context.go(Routes.profile),
                );
                if (box.maxWidth < 440) {
                  return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [sammlung, const SizedBox(height: MMass.s12), profil]);
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [Expanded(child: sammlung), const SizedBox(width: MMass.s12), Expanded(child: profil)],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Titel „Mordakte“ und das Profil (Name, Rang, Erfahrungspunkte).
class _Kopf extends StatelessWidget {
  const _Kopf();

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final f = MFarben.von(context);
    final t = MSchrift.von(context);
    final meta = context.watch<MetaStore>();
    final name = meta.name ?? l.name_default;
    final rang = l.rankName(meta.rank);
    void zumProfil() => context.go(Routes.profile);
    return Column(
      children: [
        const SizedBox(height: MMass.s8),
        // Der Titel schrumpft bei großer Schrift, statt zu umbrechen.
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            l.appTitle.toUpperCase(),
            textAlign: TextAlign.center,
            style: t.titel.copyWith(fontSize: 40, letterSpacing: 6, color: f.papier),
          ),
        ),
        const SizedBox(height: MMass.s4),
        Text(l.appSubtitle.toUpperCase(), textAlign: TextAlign.center, style: t.marke),
        const SizedBox(height: MMass.s16),
        Semantics(
          button: true,
          label: l.profil_chip_semantik(name, rang, meta.xp),
          onTap: zumProfil,
          excludeSemantics: true,
          child: Material(
            color: f.flaeche,
            shape: StadiumBorder(side: BorderSide(color: f.linie)),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: zumProfil,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: MMass.tippflaeche),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 6, 18, 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RankBadge(rank: meta.rank, size: 36),
                      const SizedBox(width: MMass.s12),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: t.text.copyWith(fontSize: 15, fontWeight: FontWeight.w600, height: 1.2)),
                            Text('$rang · ${l.common_xp(meta.xp)}', maxLines: 1, overflow: TextOverflow.ellipsis, style: t.leise.copyWith(fontSize: 12.5, height: 1.2)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Eintrag „Sammlung“ oder „Profil“ unter der Kampagne.
class _Eintrag extends StatelessWidget {
  const _Eintrag({required this.icon, required this.titel, required this.hinweis, required this.onTap});

  final IconData icon;
  final String titel;
  final String hinweis;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final f = MFarben.von(context);
    final t = MSchrift.von(context);
    return Semantics(
      button: true,
      child: MTafel(
        padding: EdgeInsets.zero,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(MMass.s16),
              child: Row(
                children: [
                  Icon(icon, color: f.akzent, size: 28),
                  const SizedBox(width: MMass.s12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(titel, style: t.ueberschrift.copyWith(fontSize: 18)),
                        Text(hinweis, style: t.leise.copyWith(fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
