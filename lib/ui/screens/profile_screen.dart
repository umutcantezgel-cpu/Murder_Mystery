import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:mordakte_core/mordakte_core.dart';
import 'package:provider/provider.dart';

import '../../app/router.dart';
import '../../abend/einrichtung/klasse_zeile.dart' show klassenNachRang;
import '../../app/theme.dart';
import '../../l10n/lookup.dart';
import '../../meta/meta_store.dart';
import '../../meta/progression.dart';
import '../../stil/stil.dart';
import '../icons.dart';
import '../widgets/buttons.dart';
import '../widgets/meters.dart';
import '../widgets/panels.dart';
import '../widgets/paper.dart';
import '../widgets/portrait.dart';
import 'collection_screen.dart';
import 'hub_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final meta = context.watch<MetaStore>();
    final next = nextRankXp(meta.xp);
    final lo = meta.loadout;
    return Scaffold(
      body: MHintergrund(
        child: SafeArea(
          child: Column(
            children: [
              ContentWidth(
                child: NoirTopBar(title: l.profile_title, onBack: () => context.go(Routes.start)),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(18, 10, 18, 30),
                  children: [
                    ContentWidth(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Dienstausweis
                          PaperCard(
                            clip: true,
                            padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(3),
                                  color: Noir.ink,
                                  child: Portrait(
                                    look: LookDef(
                                      coat: detectiveCoats[lo.coat.clamp(0, detectiveCoats.length - 1)],
                                      hat: lo.hat,
                                    ),
                                    size: 96,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l.rankName(meta.rank).toUpperCase(),
                                        style: Noir.label(11, color: Noir.blood, spacing: 2, weight: FontWeight.w700),
                                      ),
                                      const SizedBox(height: 2),
                                      InkWell(
                                        onTap: () => showNameDialog(context),
                                        child: Text(
                                          meta.name ?? l.name_default,
                                          style: Noir.title(24, color: Noir.ink),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(GameIcons.cls(lo.cls), size: 15, color: Noir.inkSoft),
                                          const SizedBox(width: 4),
                                          Text(l.className(lo.cls), style: Noir.text(12.5, color: Noir.inkSoft)),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      XpBar(xp: meta.xp, color: Noir.blood, showLabel: false),
                                      const SizedBox(height: 5),
                                      Text(
                                        next == null ? l.hub_rank_max : l.hub_rank_progress(meta.xp, next),
                                        style: Noir.text(11.5, color: Noir.inkSoft),
                                      ),
                                      if (next != null)
                                        Text(
                                          l.profile_next_rank(l.rankName(meta.rank + 1)),
                                          style: Noir.text(11.5, color: Noir.inkSoft),
                                        ),
                                    ],
                                  ),
                                ),
                                RankBadge(rank: meta.rank, size: 46),
                              ],
                            ),
                          ).animate().fadeIn(duration: 400.ms),
                          const SizedBox(height: 22),
                          SectionLabel(l.profile_record),
                          _Stats(meta: meta),
                          const SizedBox(height: 22),
                          SectionLabel(l.profile_classes),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Text(l.profil_klasse_hinweis, style: Noir.text(12.5, color: Noir.smoke, height: 1.3)),
                          ),
                          for (final c in klassenNachRang())
                            _ClassRow(
                              cls: c,
                              rank: meta.rank,
                              selected: c.id == lo.cls,
                              onTap: () => meta.loadout = Loadout(cls: c.id, coat: lo.coat, hat: lo.hat),
                            ),
                          const SizedBox(height: 18),
                          SectionLabel(l.profile_hats),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              for (final h in detectiveHats)
                                _Unlockable(
                                  locked: meta.rank < hatRank(h),
                                  label: meta.rank < hatRank(h)
                                      ? l.common_unlock_at(l.rankName(hatRank(h)))
                                      : l.hatName(h),
                                  child: Portrait(
                                    look: LookDef(coat: detectiveCoats[lo.coat.clamp(0, 7)], hat: h),
                                    size: 58,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          SectionLabel(l.profile_coats),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              for (var i = 0; i < detectiveCoats.length; i++)
                                Tooltip(
                                  message: meta.rank < coatRank(i)
                                      ? l.common_unlock_at(l.rankName(coatRank(i)))
                                      : l.coat_name(i + 1),
                                  child: Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: coatColor(i).withValues(alpha: meta.rank < coatRank(i) ? 0.35 : 1),
                                      border: Border.all(color: Noir.lineStrong),
                                    ),
                                    child: meta.rank < coatRank(i)
                                        ? const Icon(Icons.lock_rounded, size: 16, color: Noir.whiteSoft)
                                        : null,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 22),
                          SectionLabel(l.collection_achievements),
                          AchievementList(meta: meta),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stats extends StatelessWidget {
  const _Stats({required this.meta});

  final MetaStore meta;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final items = [
      (l.stat_cases, meta.stat('cases'), Icons.folder_rounded),
      (l.stat_solved, meta.stat('solved'), Icons.task_alt_rounded),
      (l.stat_perfect, meta.stat('perfect'), Icons.verified_rounded),
      (l.stat_revives, meta.stat('revives'), Icons.favorite_rounded),
      (l.stat_combos, meta.stat('combos'), Icons.hub_rounded),
      (l.stat_best_streak, meta.bestStreak, Icons.local_fire_department_rounded),
    ];
    return LayoutBuilder(
      builder: (context, box) {
        final w = (box.maxWidth - 20) / 3;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final (label, value, icon) in items)
              SizedBox(
                width: w,
                child: GlassPanel(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  child: Column(
                    children: [
                      Icon(icon, size: 18, color: MFarben.von(context).akzent),
                      const SizedBox(height: 4),
                      Text('$value', style: Noir.title(24)),
                      Text(
                        label,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Noir.label(10, color: Noir.smoke, spacing: 0.3),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Eine Klasse im Profil: Tippen wählt sie als Ermittlerklasse des Geräts.
/// Gesperrte Klassen sind nicht wählbar und nennen den nötigen Rang.
class _ClassRow extends StatelessWidget {
  const _ClassRow({required this.cls, required this.rank, required this.selected, required this.onTap});

  final DetectiveClass cls;
  final int rank;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final locked = rank < cls.unlockRank;
    final akzent = MFarben.von(context).akzent;
    final name = l.className(cls.id);
    final rahmen = BorderRadius.circular(6);
    return Semantics(
      button: true,
      selected: selected,
      enabled: !locked,
      label: locked ? l.abend_klasse_gesperrt(name, l.common_unlock_at(l.rankName(cls.unlockRank))) : name,
      hint: l.classAbility(cls.id),
      onTap: locked ? null : onTap,
      excludeSemantics: true,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: selected ? Color.lerp(Noir.panel, akzent, 0.14) : Noir.panel,
          borderRadius: rahmen,
          border: Border.all(color: selected ? akzent : Noir.lineSoft, width: selected ? 2 : 1),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: rahmen,
            onTap: locked ? null : onTap,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Opacity(
                opacity: locked ? 0.55 : 1,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: locked ? Noir.lineSoft : akzent),
                      child: Icon(
                        locked ? Icons.lock_rounded : GameIcons.cls(cls.id),
                        size: 20,
                        color: locked ? Noir.smoke : Noir.night,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(child: Text(name, style: Noir.title(16))),
                              if (locked)
                                Text(
                                  l.common_unlock_at(l.rankName(cls.unlockRank)),
                                  style: Noir.label(11, color: akzent, spacing: 0.3),
                                ),
                            ],
                          ),
                          if (selected) ...[
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Icon(Icons.check_circle_rounded, size: 14, color: akzent),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    l.profil_klasse_gewaehlt.toUpperCase(),
                                    style: Noir.label(11, color: akzent, spacing: 0.8),
                                  ),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 3),
                          Text(l.classAbility(cls.id), style: Noir.text(12, height: 1.3)),
                          const SizedBox(height: 2),
                          Text(l.classPassive(cls.id), style: Noir.text(12, color: Noir.smoke, height: 1.3)),
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
    );
  }
}

class _Unlockable extends StatelessWidget {
  const _Unlockable({required this.locked, required this.label, required this.child});

  final bool locked;
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 70,
    child: Column(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Noir.line),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Opacity(opacity: locked ? 0.3 : 1, child: child),
                if (locked) Icon(Icons.lock_rounded, color: MFarben.von(context).akzent, size: 18),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Noir.label(10, color: locked ? Noir.smokeDim : Noir.smoke, spacing: 0.1, weight: FontWeight.w500),
        ),
      ],
    ),
  );
}
