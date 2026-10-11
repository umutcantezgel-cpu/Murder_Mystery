import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:provider/provider.dart';

import '../../session/session_factory.dart';

import '../../app/app_state.dart';
import '../../app/router.dart';
import '../../app/theme.dart';
import '../../detektei/name_dialog.dart';
import '../../l10n/lookup.dart';
import '../../meta/meta_store.dart';
import '../../meta/progression.dart';
import '../widgets/bento.dart';
import '../widgets/buttons.dart';
import '../widgets/logo.dart';
import '../widgets/meters.dart';
import '../widgets/noir_backdrop.dart';
import '../widgets/panels.dart';
import '../widgets/paper.dart';

// Der Namensdialog liegt in der Detektei; der alte Hub und das Profil benutzen ihn weiter.
export '../../detektei/name_dialog.dart' show showNameDialog;

class HubScreen extends StatefulWidget {
  const HubScreen({super.key});

  @override
  State<HubScreen> createState() => _HubScreenState();
}

class _HubScreenState extends State<HubScreen> {
  bool _starting = false;
  String? _lastRoom;

  @override
  void initState() {
    super.initState();
    SessionFactory.storedOnlineRoom().then((code) {
      if (mounted && code != null) setState(() => _lastRoom = code);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final app = context.read<AppState>();
      final lost = app.lostKey;
      if (lost != null) {
        app.lostKey = null;
        final l = L.of(context);
        showNoirSnack(
          context,
          '${l.error_room_lost} ${l.errorText(lost)}',
          icon: Icons.wifi_off_rounded,
          color: Noir.bloodBright,
        );
      }
      if (!context.read<MetaStore>().hasName) showNameDialog(context, first: true);
    });
  }

  Future<void> _playDaily() async {
    final app = context.read<AppState>();
    final id = app.daily.scenarioId;
    final s = id == null ? null : app.scenarios[id];
    if (s == null) return;
    setState(() => _starting = true);
    await app.startSolo(s, 'daily');
    if (mounted) context.go(Routes.lobby);
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final meta = context.watch<MetaStore>();
    final app = context.read<AppState>();
    final daily = app.daily;
    final dailyScenario = daily.scenarioId == null ? null : app.scenarios[daily.scenarioId];
    final accent = accentOf(dailyScenario);
    final now = DateTime.now();
    const gap = 12.0;
    // Gestaffeltes Einblenden der Kacheln. Die Überschrift „Partyabende“ (0) und
    // die beiden Partykacheln (1, 2) stehen fest vorn, danach zählt [stagger] weiter.
    var step = 3;
    const partyStufe = 1;
    Widget staggerAt(int i, Widget w) => w
        .animate()
        .fadeIn(delay: (120 + 70 * i).ms, duration: 420.ms)
        .slideY(begin: 0.08, curve: Curves.easeOutCubic);
    Widget stagger(Widget w) => staggerAt(step++, w);

    return Scaffold(
      body: NoirBackdrop(
        accent: accent,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 26),
            child: ContentWidth(
              maxWidth: 520,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 14),
                  Center(child: MordakteLogo(size: 44, subtitle: l.appSubtitle))
                      .animate()
                      .fadeIn(duration: 700.ms)
                      .slideY(begin: -0.08, curve: Curves.easeOutCubic),
                  const SizedBox(height: 30),
                  // Partyabende: beide Abende gleichrangig, gleich groß und in gleicher Schrift.
                  staggerAt(0, _Abschnitt(l.hub_section_party)),
                  _PartyReihe(
                    kacheln: [
                      _PartyKachel(
                        icon: Icons.celebration_rounded,
                        titel: l.hub_party_keller,
                        untertitel: l.hub_party_keller_sub,
                        onTap: () => context.go(Routes.party),
                      ),
                      _PartyKachel(
                        icon: Icons.castle_rounded,
                        titel: l.hub_party_gewoelbe,
                        untertitel: l.hub_party_gewoelbe_sub,
                        onTap: () => context.go(Routes.gewoelbe),
                      ),
                    ],
                    gap: gap,
                    einblenden: (i, w) => staggerAt(partyStufe + i, w),
                  ),
                  const SizedBox(height: 26),
                  // Klassische Fälle: Fall des Tages, Fallakten und Online.
                  stagger(_Abschnitt(l.hub_section_classic)),
                  if (dailyScenario != null) ...[
                    stagger(
                      _DailyCard(
                        title: dailyScenario.title.resolve(),
                        tagline: dailyScenario.tagline.resolve(),
                        date: DateFormat('d. MMMM', 'de').format(now),
                        accent: accent,
                        done: meta.dailyDone(now),
                        busy: _starting,
                        onPlay: _playDaily,
                      ),
                    ),
                    const SizedBox(height: gap + 4),
                  ],
                  // Fallakten (Hauptkachel mit Glow) + Online
                  SizedBox(
                    height: 156,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 3,
                          child: stagger(
                            BentoTile(
                                  highlight: true,
                                  onTap: () => context.go(Routes.cases),
                                  padding: const EdgeInsets.all(16),
                                  child: _TileBody(
                                    icon: Icons.folder_open_rounded,
                                    title: l.hub_cases,
                                    subtitle: l.hub_cases_sub,
                                    dark: true,
                                    big: true,
                                  ),
                                )
                                .animate(onPlay: (c) => c.repeat())
                                .shimmer(
                                  delay: 2600.ms,
                                  duration: 1800.ms,
                                  color: Noir.whiteSoft.withValues(alpha: 0.35),
                                ),
                          ),
                        ),
                        const SizedBox(width: gap),
                        Expanded(
                          flex: 2,
                          child: stagger(
                            BentoTile(
                              onTap: () => context.go(Routes.online),
                              child: _TileBody(
                                icon: Icons.public_rounded,
                                title: l.hub_online,
                                subtitle: _lastRoom == null ? l.hub_online_sub : l.hub_online_rejoin(_lastRoom!),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 26),
                  // Sammlung und Profil: Dienstmarke (2/3) + Serie (1/3), dann Sammlung + Profil.
                  stagger(_Abschnitt(l.hub_section_meta)),
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(flex: 2, child: stagger(_BadgeTile(meta: meta))),
                        const SizedBox(width: gap),
                        Expanded(child: stagger(_StreakTile(streak: meta.streak))),
                      ],
                    ),
                  ),
                  const SizedBox(height: gap),
                  SizedBox(
                    height: 112,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: stagger(
                            BentoTile(
                              onTap: () => context.go(Routes.collection),
                              child: _TileBody(
                                icon: Icons.collections_bookmark_rounded,
                                title: l.hub_collection,
                                subtitle: l.collection_discovered(meta.totalEndings),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: gap),
                        Expanded(
                          child: stagger(
                            BentoTile(
                              onTap: () => context.go(Routes.profile),
                              child: _TileBody(
                                icon: Icons.badge_rounded,
                                title: l.hub_profile,
                                subtitle: l.collection_achievements_count(
                                  meta.achievements.length,
                                  achievementIds.length,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 26),
                  Text(
                    '„${l.hub_motto}“',
                    textAlign: TextAlign.center,
                    style: Noir.typed(13, color: Noir.smokeDim),
                  ).animate().fadeIn(delay: 900.ms, duration: 600.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Überschrift eines Hub-Bereichs: Schreibmaschine in hellem Messing, dahinter eine feine Linie.
class _Abschnitt extends StatelessWidget {
  const _Abschnitt(this.titel);

  final String titel;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      children: [
        Text(titel, style: Noir.title(13, color: Noir.brassLight, spacing: 1.6)),
        const SizedBox(width: 10),
        const Expanded(child: Divider(color: Noir.lineSoft, thickness: 1, height: 1)),
      ],
    ),
  );
}

/// Daten einer Partyabend-Kachel; gesetzt wird sie von [_PartyReihe].
class _PartyKachel {
  const _PartyKachel({required this.icon, required this.titel, required this.untertitel, required this.onTap});

  final IconData icon;
  final String titel;
  final String untertitel;
  final VoidCallback onTap;
}

/// Die Partyabende gleichrangig: gleich groß, gleiche Titelschrift, kein Text abgeschnitten.
///
/// Beide Titel bekommen dieselbe Größe, die größte, bei der jeder Titel ohne
/// Worttrennung passt. Reicht der Platz nebeneinander dafür nicht (am Telefon),
/// stehen die Kacheln untereinander in voller Breite. Titel und Untertitel
/// nehmen in jeder Kachel die Höhe des längsten ein, so sind beide gleich hoch.
class _PartyReihe extends StatelessWidget {
  const _PartyReihe({required this.kacheln, required this.gap, required this.einblenden});

  final List<_PartyKachel> kacheln;
  final double gap;

  /// Blendet die Kachel mit dem Index ein (gestaffelt wie der übrige Hub).
  final Widget Function(int index, Widget kachel) einblenden;

  static const _innen = 16.0;
  static const _maxTitel = 26.0;
  static const _minTitel = 16.0;

  /// Kleinere Titel als diese stehen nicht nebeneinander, sondern untereinander.
  static const _minNebeneinander = 20.0;

  static TextStyle _titelStil(double groesse) => Noir.title(groesse, color: Noir.night, spacing: 1.4);
  static final _unterStil = Noir.text(12.5, color: Noir.night.withValues(alpha: 0.78), height: 1.3);

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      final scaler = MediaQuery.textScalerOf(context);
      final titel = [for (final k in kacheln) k.titel];
      final halb = (box.maxWidth - gap * (kacheln.length - 1)) / kacheln.length - 2 * _innen;
      final voll = box.maxWidth - 2 * _innen;
      final nebenGroesse = _gemeinsameGroesse(titel, halb, 2, scaler);
      final nebeneinander = nebenGroesse >= _minNebeneinander;
      final double breite;
      final double groesse;
      if (nebeneinander) {
        breite = halb;
        groesse = nebenGroesse;
      } else {
        breite = voll;
        final einzeilig = _gemeinsameGroesse(titel, voll, 1, scaler);
        groesse = einzeilig >= _minNebeneinander ? einzeilig : _gemeinsameGroesse(titel, voll, 2, scaler);
      }
      final titelHoehe = _maxHoehe(titel, _titelStil(groesse), breite, scaler);
      final unterHoehe = _maxHoehe([for (final k in kacheln) _zusammen(k.untertitel)], _unterStil, breite, scaler);
      final tiles = [
        for (var i = 0; i < kacheln.length; i++) einblenden(i, _kachel(kacheln[i], groesse, titelHoehe, unterHoehe)),
      ];
      if (!nebeneinander) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < tiles.length; i++) ...[if (i > 0) SizedBox(height: gap), tiles[i]],
          ],
        );
      }
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < tiles.length; i++) ...[if (i > 0) SizedBox(width: gap), Expanded(child: tiles[i])],
          ],
        ),
      );
    },
  );

  Widget _kachel(_PartyKachel k, double groesse, double titelHoehe, double unterHoehe) => BentoTile(
    highlight: true,
    accent: Noir.flame,
    onTap: k.onTap,
    padding: const EdgeInsets.all(_innen),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            TileIcon(k.icon, onDark: false, size: 24),
            const Spacer(),
            Icon(Icons.arrow_forward_rounded, size: 18, color: Noir.night.withValues(alpha: 0.55)),
          ],
        ),
        const SizedBox(height: 18),
        ConstrainedBox(
          constraints: BoxConstraints(minHeight: titelHoehe),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Text(k.titel, style: _titelStil(groesse)),
          ),
        ),
        const SizedBox(height: 4),
        ConstrainedBox(
          constraints: BoxConstraints(minHeight: unterHoehe),
          child: Align(
            alignment: Alignment.topLeft,
            child: Text(_zusammen(k.untertitel), style: _unterStil),
          ),
        ),
      ],
    ),
  );

  /// Zahlen bleiben bei ihren Nachbarwörtern („4 bis 20 Personen“ bricht nicht um).
  static String _zusammen(String s) => s.replaceAllMapped(RegExp(r'(?<=\d) | (?=\d)(?<![·] )'), (m) => '\u00a0');

  /// Größte Titelgröße, bei der jeder Titel in [zeilen] Zeilen passt, ohne ein Wort zu trennen.
  static double _gemeinsameGroesse(List<String> titel, double breite, int zeilen, TextScaler scaler) {
    for (var s = _maxTitel; s > _minTitel; s -= 0.5) {
      if (titel.every((t) => _passt(t, _titelStil(s), breite, zeilen, scaler))) return s;
    }
    return _minTitel;
  }

  static bool _passt(String text, TextStyle stil, double breite, int zeilen, TextScaler scaler) {
    if (breite <= 0) return false;
    final ganz = _maler(text, stil, scaler, maxLines: zeilen)..layout(maxWidth: breite);
    var ok = !ganz.didExceedMaxLines;
    ganz.dispose();
    for (final wort in text.split(' ')) {
      if (!ok) break;
      final w = _maler(wort, stil, scaler)..layout();
      ok = w.width <= breite;
      w.dispose();
    }
    return ok;
  }

  static double _maxHoehe(List<String> texte, TextStyle stil, double breite, TextScaler scaler) {
    var hoehe = 0.0;
    for (final t in texte) {
      final p = _maler(t, stil, scaler)..layout(maxWidth: breite > 1 ? breite : 1);
      if (p.height > hoehe) hoehe = p.height;
      p.dispose();
    }
    return hoehe;
  }

  static TextPainter _maler(String text, TextStyle stil, TextScaler scaler, {int? maxLines}) => TextPainter(
    text: TextSpan(text: text, style: stil),
    textDirection: TextDirection.ltr,
    maxLines: maxLines,
    textScaler: scaler,
  );
}

/// Inhalt einer Bento-Kachel: Symbol oben, Titel + Untertitel unten.
class _TileBody extends StatelessWidget {
  const _TileBody({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.dark = false,
    this.big = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool dark;
  final bool big;

  @override
  Widget build(BuildContext context) {
    final fg = dark ? Noir.night : Noir.cream;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            TileIcon(icon, onDark: !dark, size: big ? 24 : 20),
            const Spacer(),
            Icon(Icons.arrow_forward_rounded, size: 18, color: fg.withValues(alpha: 0.55)),
          ],
        ),
        const Spacer(),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            title,
            maxLines: 1,
            style: Noir.title(big ? 26 : 18, color: fg, spacing: big ? 1.4 : 0.8),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Noir.text(12, color: fg.withValues(alpha: dark ? 0.75 : 0.62), height: 1.25),
        ),
      ],
    );
  }
}

class _BadgeTile extends StatelessWidget {
  const _BadgeTile({required this.meta});

  final MetaStore meta;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return BentoTile(
      onTap: () => showNameDialog(context),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              RankBadge(rank: meta.rank, size: 46),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            meta.name ?? l.name_default,
                            style: Noir.title(20),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.edit_rounded, size: 13, color: Noir.smokeDim),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l.rankName(meta.rank).toUpperCase(),
                      style: Noir.label(11, color: Noir.brass, spacing: 2.2, weight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          XpBar(xp: meta.xp),
        ],
      ),
    );
  }
}

class _StreakTile extends StatelessWidget {
  const _StreakTile({required this.streak});

  final int streak;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final on = streak > 0;
    Widget flame = Icon(Icons.local_fire_department_rounded, size: 34, color: on ? Noir.flame : Noir.smokeDim);
    if (on) {
      flame = flame
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scaleXY(begin: 0.92, end: 1.08, duration: 900.ms, curve: Curves.easeInOut);
    }
    return BentoTile(
      accent: Noir.flame,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          flame,
          const SizedBox(height: 2),
          Text('$streak', style: Noir.title(28, color: on ? Noir.cream : Noir.smoke)),
          Text(
            l.hub_streak_label(streak),
            textAlign: TextAlign.center,
            maxLines: 2,
            style: Noir.label(10, color: Noir.smoke, spacing: 0.3, weight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _DailyCard extends StatelessWidget {
  const _DailyCard({
    required this.title,
    required this.tagline,
    required this.date,
    required this.accent,
    required this.done,
    required this.busy,
    required this.onPlay,
  });

  final String title;
  final String tagline;
  final String date;
  final Color accent;
  final bool done;
  final bool busy;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return PaperCard(
      tape: true,
      padding: EdgeInsets.zero,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 7, color: accent),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 12, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          l.hub_daily_title.toUpperCase(),
                          style: Noir.label(11, color: Noir.blood, spacing: 2, weight: FontWeight.w700),
                        ),
                        const Spacer(),
                        Text(date, style: Noir.typed(12, color: Noir.inkSoft)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(title, style: Noir.title(22, color: Noir.ink, spacing: 0.6)),
                    const SizedBox(height: 4),
                    Text(tagline, style: Noir.typed(13.5, color: Noir.inkSoft)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        if (done)
                          Row(
                            children: [
                              const Icon(Icons.check_circle_rounded, color: Noir.success, size: 18),
                              const SizedBox(width: 6),
                              Text(l.hub_daily_done, style: Noir.label(13, color: Noir.success, spacing: 0.3)),
                            ],
                          )
                        else
                          TagChip(l.hub_daily_bonus(dailyBonusXp), color: Noir.blood, icon: Icons.bolt_rounded),
                        const Spacer(),
                        SizedBox(
                          width: 148,
                          child: NoirButton(
                            label: l.hub_daily_play,
                            height: 42,
                            accent: accent,
                            busy: busy,
                            icon: Icons.search_rounded,
                            onPressed: onPlay,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
