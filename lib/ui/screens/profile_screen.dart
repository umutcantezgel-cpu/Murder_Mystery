import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mordakte_core/mordakte_core.dart';
import 'package:provider/provider.dart';

import '../../abend/einrichtung/klasse_zeile.dart' show klassenNachRang;
import '../../app/router.dart';
import '../../app/theme.dart' show coatColor;
import '../../detektei/akte_bausteine.dart' show mappenBlaetter;
import '../../detektei/dienstausweis.dart';
import '../../detektei/name_dialog.dart';
import '../../detektei/schreibtisch.dart' show GanzeWorte;
import '../../klang/klang.dart';
import '../../l10n/lookup.dart';
import '../../meta/meta_store.dart';
import '../../meta/progression.dart';
import '../../stil/mappe/assistent_formular.dart' show MPapierRegler;
import '../../stil/stil.dart';
import '../icons.dart';

/// Profil (Route `/profile`): die Personalakte des Detektivs.
///
/// - Der Dienstausweis (Name antippen ändert ihn).
/// - Die Dienstakte mit den Zahlen der bisherigen Fälle.
/// - Die Klassen als Karteikarten in einer Mappe; die gewählte trägt den Stempel „Gewählt“.
/// - Die Garderobe: Hüte als Fotoabzüge, Mäntel als Stoffmuster.
/// - Die Erfolge als Urkundenblatt mit Messingmedaillen.
/// - Der Ton: Kippschalter und Messingregler für Geräusche und Atmosphäre.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final meta = context.watch<MetaStore>();
    final lo = meta.loadout;
    final klassen = klassenNachRang();
    return Scaffold(
      backgroundColor: MFarben.von(context).grund,
      body: MRahmen(
        titel: l.profile_title,
        aktionen: [
          MKnopf(text: l.common_back, art: MKnopfArt.zweit, icon: Icons.arrow_back_rounded, onPressed: () => context.go(Routes.start)),
        ],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Ein Ausweis bleibt eine Karte, auch auf breiten Bildschirmen.
            Align(
              alignment: Alignment.centerLeft,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Transform.rotate(
                  angle: -0.006,
                  child: Dienstausweis(meta: meta, gross: true, onName: () => showNameDialog(context)),
                ),
              ),
            ),
            const SizedBox(height: MMass.s32),
            _Dienstakte(meta: meta),
            const SizedBox(height: MMass.s32),
            LayoutBuilder(
              builder: (context, aussen) => MAktenmappe(
                reiter: l.profile_classes,
                // Höchstens zwei Blätter: weitere schöben sich auf breiten Mappen über den Reiter.
                blaetter: mappenBlaetter(aussen.maxWidth),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(l.profil_klasse_hinweis, style: MPapierSchrift.text.copyWith(fontSize: 15, height: 1.45, color: MRoh.tinteLeise)),
                    const SizedBox(height: MMass.s16),
                    for (var i = 0; i < klassen.length; i++)
                      _ClassRow(
                        cls: klassen[i],
                        rank: meta.rank,
                        selected: klassen[i].id == lo.cls,
                        nr: i,
                        onTap: () => meta.loadout = Loadout(cls: klassen[i].id, coat: lo.coat, hat: lo.hat),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: MMass.s32),
            _Garderobe(meta: meta),
            const SizedBox(height: MMass.s32),
            _Erfolge(meta: meta),
            const SizedBox(height: MMass.s32),
            const _Tonregler(),
            const SizedBox(height: MMass.s16),
          ],
        ),
      ),
    );
  }
}

/// Ton auf einer Karteikarte: Kippschalter, darunter je ein Messingregler für
/// Geräusche und Atmosphäre. Beim Loslassen des Geräuschreglers klingt ein
/// Knopf in der neuen Lautstärke; gespeichert wird erst dann.
class _Tonregler extends StatelessWidget {
  const _Tonregler();

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final k = Klang.instanz;
    return ListenableBuilder(
      listenable: Listenable.merge([k.an, k.lautstaerke]),
      builder: (context, _) {
        final an = k.an.value;
        final (effekte, atmosphaere) = k.lautstaerke.value;
        Widget regler(String titel, double wert, ValueChanged<double> setze, VoidCallback fertig) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(titel, style: MPapierSchrift.text.copyWith(color: an ? MRoh.tinte : MRoh.tinteLeise)),
                Semantics(
                  label: titel,
                  child: MPapierRegler(
                    child: Slider(
                      value: wert,
                      onChanged: an ? setze : null,
                      onChangeEnd: an ? (_) => fertig() : null,
                      semanticFormatterCallback: (v) => '${(v * 100).round()} %',
                    ),
                  ),
                ),
              ],
            );
        return MBlatt(
          art: PapierArt.karteikarte,
          kopfLinie: 7,
          linien: false,
          neigung: -0.003,
          samen: 83,
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(child: Text(l.ton_titel, style: MPapierSchrift.ueberschrift)),
                  MSchalter(
                    wert: an,
                    onChanged: (w) => unawaited(k.schalten(w)),
                    semantik: an ? l.ton_an : l.ton_aus,
                    symbolAn: Icons.volume_up_rounded,
                    symbolAus: Icons.volume_off_rounded,
                  ),
                ],
              ),
              const SizedBox(height: MMass.s8),
              regler(l.ton_effekte, effekte, (v) => k.setzeLautstaerke(effekte: v), () {
                k.setzeLautstaerke(speichern: true);
                k.spiele('knopf');
              }),
              regler(l.ton_atmosphaere, atmosphaere, (v) => k.setzeLautstaerke(atmosphaere: v), () => k.setzeLautstaerke(speichern: true)),
            ],
          ),
        );
      },
    );
  }
}

/// Die Dienstakte: Fälle, Lösungen, Serien als Formular mit großen Ziffern.
class _Dienstakte extends StatelessWidget {
  const _Dienstakte({required this.meta});

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
    return MBlatt(
      klammer: true,
      neigung: 0.004,
      samen: 71,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MBlattKopf(zeile: l.profile_record),
          LayoutBuilder(
            builder: (context, box) {
              final skala = MediaQuery.textScalerOf(context).scale(1);
              final spalten = (box.maxWidth / (115 * skala.clamp(1.0, 3.0))).floor().clamp(1, 3);
              final breite = box.maxWidth / spalten;
              return Wrap(
                children: [
                  for (var i = 0; i < items.length; i++)
                    SizedBox(
                      width: breite,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          border: Border(
                            left: i % spalten == 0 ? BorderSide.none : BorderSide(color: MRoh.tinte.withValues(alpha: 0.18)),
                            top: i < spalten ? BorderSide.none : BorderSide(color: MRoh.tinte.withValues(alpha: 0.18)),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(10, 10, 6, 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(items[i].$3, size: 15, color: MRoh.tinteLeise),
                                  const SizedBox(width: MMass.s4),
                                  Expanded(child: GanzeWorte(items[i].$1, style: MPapierSchrift.maschine.copyWith(fontSize: 12, height: 1.3, color: MRoh.tinteLeise))),
                                ],
                              ),
                              Text('${items[i].$2}', style: MPapierSchrift.titel.copyWith(fontSize: 30)),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Eine Klasse im Profil als Karteikarte: Tippen wählt sie als Ermittlerklasse des
/// Geräts. Gesperrte Klassen sind nicht wählbar und nennen den nötigen Rang.
class _ClassRow extends StatelessWidget {
  const _ClassRow({required this.cls, required this.rank, required this.selected, required this.nr, required this.onTap});

  final DetectiveClass cls;
  final int rank;
  final bool selected;
  final int nr;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final locked = rank < cls.unlockRank;
    final name = l.className(cls.id);
    return Semantics(
      button: true,
      selected: selected,
      enabled: !locked,
      label: locked ? l.abend_klasse_gesperrt(name, l.common_unlock_at(l.rankName(cls.unlockRank))) : name,
      // Was die Klasse am Abend auf der Karte tut; die alten class_*-Texte gelten nur der klassischen Engine.
      hint: '${l.klasseFaehigkeitName(cls.id)}: ${l.klasseFaehigkeit(cls.id)}',
      onTap: locked ? null : onTap,
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.only(bottom: MMass.s12),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            MBlatt(
              art: PapierArt.karteikarte,
              kopfLinie: 6,
              linien: false,
              hervorgehoben: selected,
              neigung: nr.isEven ? -0.003 : 0.003,
              samen: nr + 13,
              onTap: locked ? null : onTap,
              padding: const EdgeInsets.fromLTRB(12, 14, 14, 12),
              child: Opacity(
                opacity: locked ? 0.55 : 1,
                child: LayoutBuilder(
                  builder: (context, box) {
                    final medaille = _Medaille(icon: locked ? Icons.lock_rounded : GameIcons.cls(cls.id), matt: locked);
                    final kopf = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GanzeWorte(name, style: MPapierSchrift.ueberschrift.copyWith(fontSize: 17, height: 1.3)),
                        if (locked)
                          GanzeWorte(l.common_unlock_at(l.rankName(cls.unlockRank)), style: MPapierSchrift.maschine.copyWith(fontSize: 12, height: 1.3, color: MRoh.stempelRot)),
                      ],
                    );
                    final text = [
                      GanzeWorte('${l.klasseFaehigkeitName(cls.id)}: ${l.klasseFaehigkeit(cls.id)}', style: MPapierSchrift.text.copyWith(fontSize: 14, height: 1.4)),
                      const SizedBox(height: 2),
                      GanzeWorte(l.abend_klasse_fair, style: MPapierSchrift.text.copyWith(fontSize: 14, height: 1.4, color: MRoh.tinteLeise)),
                    ];
                    // Bei großer Schrift auf schmalem Handy wird die Spalte neben der
                    // Medaille zu eng: Dann steht die Medaille oben und Name und Text
                    // darunter in voller Breite.
                    if (_Medaille.schmal(context, box.maxWidth)) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Align(alignment: Alignment.centerLeft, child: medaille),
                          const SizedBox(height: MMass.s8),
                          kopf,
                          const SizedBox(height: MMass.s4),
                          ...text,
                        ],
                      );
                    }
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        medaille,
                        const SizedBox(width: MMass.s12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [kopf, const SizedBox(height: MMass.s4), ...text],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            if (selected)
              Positioned(
                top: -8,
                right: 12,
                child: IgnorePointer(child: MStempel(text: l.profil_klasse_gewaehlt, groesse: 12, winkel: 0.1, aufschlagen: true)),
              ),
          ],
        ),
      ),
    );
  }
}

/// Runde Messingmedaille mit Symbol; [matt] für Gesperrtes und noch nicht Errungenes.
class _Medaille extends StatelessWidget {
  const _Medaille({required this.icon, this.matt = false});

  final IconData icon;
  final bool matt;
  static const groesse = 40.0;

  /// Ist neben der Medaille in [breite] zu wenig Platz für den Text (große Schrift,
  /// schmales Handy)? Dann steht sie über dem Text.
  static bool schmal(BuildContext context, double breite) => breite - groesse - MMass.s12 < 120 * MediaQuery.textScalerOf(context).scale(1);

  @override
  Widget build(BuildContext context) => Container(
        width: groesse,
        height: groesse,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: matt
              ? null
              : const RadialGradient(center: Alignment(-0.35, -0.4), colors: [MRoh.messingHell, MRoh.messingMitte, MRoh.messingDunkel], stops: [0, 0.55, 1]),
          border: matt ? Border.all(color: MRoh.tinte.withValues(alpha: 0.45), width: 1.4) : null,
          boxShadow: matt ? null : const [BoxShadow(color: Color(0x66000000), blurRadius: 3, offset: Offset(0, 2))],
        ),
        child: Icon(icon, size: groesse * 0.5, color: matt ? MRoh.tinteLeise : const Color(0xFF3A2808)),
      );
}

/// Die Garderobe: Hüte als Fotoabzüge des eigenen Detektivs, Mäntel als
/// angeheftete Stoffmuster. Gesperrtes ist verblasst und nennt den Rang.
class _Garderobe extends StatelessWidget {
  const _Garderobe({required this.meta});

  final MetaStore meta;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return MBlatt(
      klebestreifen: true,
      neigung: -0.004,
      samen: 83,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MBlattKopf(zeile: l.profile_hats),
          Wrap(
            spacing: MMass.s12,
            runSpacing: MMass.s16,
            children: [
              for (var i = 0; i < detectiveHats.length; i++)
                _Hut(
                  look: detektivAussehen(meta, hut: detectiveHats[i]),
                  gesperrt: meta.rank < hatRank(detectiveHats[i]),
                  text: meta.rank < hatRank(detectiveHats[i]) ? l.common_unlock_at(l.rankName(hatRank(detectiveHats[i]))) : l.hatName(detectiveHats[i]),
                  neigung: i.isEven ? -0.03 : 0.025,
                ),
            ],
          ),
          const SizedBox(height: MMass.s24),
          MBlattKopf(zeile: l.profile_coats),
          Wrap(
            spacing: MMass.s16,
            runSpacing: MMass.s16,
            children: [
              for (var i = 0; i < detectiveCoats.length; i++)
                Tooltip(
                  message: meta.rank < coatRank(i) ? l.common_unlock_at(l.rankName(coatRank(i))) : l.coat_name(i + 1),
                  child: _Stoffmuster(farbe: coatColor(i), gesperrt: meta.rank < coatRank(i), neigung: i.isEven ? 0.05 : -0.04),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Hut extends StatelessWidget {
  const _Hut({required this.look, required this.gesperrt, required this.text, required this.neigung});

  final LookDef look;
  final bool gesperrt;
  final String text;
  final double neigung;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 82,
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                MFotoabzug(look: look, groesse: 58, neigung: neigung, gedaempft: gesperrt, akzent: MRoh.messingMitte),
                if (gesperrt) const Icon(Icons.lock_rounded, color: MRoh.stempelRot, size: 20),
              ],
            ),
            const SizedBox(height: MMass.s4),
            GanzeWorte(
              text,
              textAlign: TextAlign.center,
              style: gesperrt
                  ? MPapierSchrift.maschine.copyWith(fontSize: 12, height: 1.3, color: MRoh.tinteLeise)
                  : MPapierSchrift.hand.copyWith(fontSize: 17, height: 1.15),
            ),
          ],
        ),
      );
}

/// Ein Stoffmuster mit Webstruktur, oben mit einer Reißzwecke angeheftet.
class _Stoffmuster extends StatelessWidget {
  const _Stoffmuster({required this.farbe, required this.gesperrt, required this.neigung});

  final Color farbe;
  final bool gesperrt;
  final double neigung;

  @override
  Widget build(BuildContext context) => Transform.rotate(
        angle: neigung,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Opacity(
              opacity: gesperrt ? 0.35 : 1,
              child: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(boxShadow: [BoxShadow(color: Color(0x66000000), blurRadius: 4, offset: Offset(0, 2))]),
                child: CustomPaint(painter: _GewebeMaler(farbe)),
              ),
            ),
            if (gesperrt) const Icon(Icons.lock_rounded, size: 16, color: MRoh.tinte),
            const Positioned(top: -5, child: MReissnagel(groesse: 12)),
          ],
        ),
      );
}

class _GewebeMaler extends CustomPainter {
  _GewebeMaler(this.farbe);

  final Color farbe;

  @override
  void paint(Canvas canvas, Size size) {
    final r = Offset.zero & size;
    canvas.drawRect(r, Paint()..color = farbe);
    final hell = Paint()
      ..strokeWidth = 1
      ..color = Colors.white.withValues(alpha: 0.12);
    final dunkel = Paint()
      ..strokeWidth = 1
      ..color = Colors.black.withValues(alpha: 0.16);
    for (var x = 1.5; x < size.width; x += 3) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), hell);
    }
    for (var y = 1.5; y < size.height; y += 3) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), dunkel);
    }
    // Ausgefranster Rand: kleine Zacken unten.
    final zacken = Paint()..color = Colors.black.withValues(alpha: 0.18);
    for (var x = 0.0; x < size.width; x += 4) {
      canvas.drawRect(Rect.fromLTWH(x, size.height - 2, 2, 2), zacken);
    }
    canvas.drawRect(
      r.deflate(0.5),
      Paint()
        ..style = PaintingStyle.stroke
        ..color = Colors.black.withValues(alpha: math.min(0.4, 0.2 + farbe.computeLuminance() * 0.3)),
    );
  }

  @override
  bool shouldRepaint(covariant _GewebeMaler alt) => alt.farbe != farbe;
}

/// Die Erfolge als Urkundenblatt: errungene mit Messingmedaille, offene matt.
class _Erfolge extends StatelessWidget {
  const _Erfolge({required this.meta});

  final MetaStore meta;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final done = meta.achievements;
    return MBlatt(
      neigung: 0.003,
      samen: 97,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MBlattKopf(zeile: l.collection_achievements, unter: l.collection_achievements_count(done.length, achievementIds.length)),
          for (var i = 0; i < achievementIds.length; i++) ...[
            if (i > 0) Container(height: 1, margin: const EdgeInsets.symmetric(vertical: MMass.s8), color: MRoh.tinte.withValues(alpha: 0.12)),
            LayoutBuilder(
              builder: (context, box) {
                final errungen = done.contains(achievementIds[i]);
                final medaille = _Medaille(icon: errungen ? GameIcons.achievement(achievementIds[i]) : Icons.lock_rounded, matt: !errungen);
                final text = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GanzeWorte(
                      l.achievementName(achievementIds[i]),
                      style: MPapierSchrift.ueberschrift.copyWith(fontSize: 17, height: 1.3, color: errungen ? MRoh.tinte : MRoh.tinteLeise),
                    ),
                    GanzeWorte(l.achievementDesc(achievementIds[i]), style: MPapierSchrift.text.copyWith(fontSize: 14, height: 1.4, color: MRoh.tinteLeise)),
                  ],
                );
                if (_Medaille.schmal(context, box.maxWidth)) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [Align(alignment: Alignment.centerLeft, child: medaille), const SizedBox(height: MMass.s8), text],
                  );
                }
                return Row(children: [medaille, const SizedBox(width: MMass.s12), Expanded(child: text)]);
              },
            ),
          ],
        ],
      ),
    );
  }
}
