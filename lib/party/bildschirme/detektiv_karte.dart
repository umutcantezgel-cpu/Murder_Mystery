import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../klang/klang.dart';
import '../../l10n/gen/app_localizations_de.dart';
import '../../l10n/lookup.dart';
import '../../meta/meta_store.dart';
import '../../stil/stil.dart';
import '../sitzung.dart';

/// Wie die übrigen Partybildschirme deutsch, auch ohne Lokalisierung im Baum.
final _de = LDe();

/// Die Karte des Detektivs (M6): wer du bist und dein Auftrag
/// (`detektiv.<m|w>.wer/.auftrag`), deine Regeln (`detektiv.regeln.*`), was
/// deine Klasse auf der Karte tut und wie Befragungen laufen. Die Texte der
/// Einweisung kommen aus dem Kanon der Akte, die übrigen aus der ARB; nichts
/// davon ist geheim oder pfadabhängig.
///
/// Sie liegt in der Rollenphase als eigener Eintrag aus ([DetektivKarteEintrag])
/// und ist im Abendmenü erreichbar ([zeigeDetektivKarte]). Online gehört sie
/// auf das Gerät mit dem Detektiv-Sitz; bis es Sitze gibt, ist das der Gastgeber.
class DetektivKarte extends StatelessWidget {
  const DetektivKarte({super.key, required this.sitzung, this.klasse});

  final PartySitzung sitzung;

  /// Gewählte Klasse dieses Geräts (`forensic`, …); `null` liest die
  /// Ausrüstung aus dem [MetaStore], falls es ihn gibt.
  final String? klasse;

  /// Die Regeln des Detektivbogens, in der Reihenfolge des Drucks.
  static const regeln = ['entscheidungen', 'hinweise', 'punkte', 'anklage'];

  @override
  Widget build(BuildContext context) {
    final l = _de;
    final s = sitzung;
    final g = s.eingerichtet ? s.einstellungen.detektiv : 'w';
    final id = klasse ?? context.read<MetaStore?>()?.loadout.cls;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _abschnitt(l.detektiv_karte_wer, [Text(s.text('detektiv.$g.wer'), style: MPapierSchrift.text)]),
        _abschnitt(l.detektiv_karte_auftrag, [Text(s.text('detektiv.$g.auftrag'), style: MPapierSchrift.text)]),
        _abschnitt(l.detektiv_karte_regeln, [
          for (final r in regeln)
            if (s.hatText('detektiv.regeln.$r')) _punkt(s.text('detektiv.regeln.$r')),
        ]),
        _abschnitt(l.detektiv_karte_klasse, [
          if (id != null) Text(l.className(id), style: MPapierSchrift.ueberschrift.copyWith(fontSize: 17)),
          if (id != null && s.daten.hat('klassen')) ...[
            Text('${l.klasseFaehigkeitName(id)}: ${l.klasseFaehigkeit(id)}', style: MPapierSchrift.text),
            Text(l.abend_klasse_fair, style: MPapierSchrift.leise),
          ],
          Text(l.abend_klasse_hinweis, style: MPapierSchrift.leise),
        ]),
        _abschnitt(l.detektiv_karte_befragungen, [
          _punkt(l.detektiv_karte_befragung_1),
          _punkt(l.detektiv_karte_befragung_2),
          _punkt(l.detektiv_karte_befragung_3),
        ]),
      ],
    );
  }

  /// Ein Abschnitt wie im Dossier: roter Formularkopf, Linie, Inhalt.
  static Widget _abschnitt(String titel, List<Widget> kinder) => Padding(
        padding: const EdgeInsets.only(bottom: MMass.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(titel, style: MPapierSchrift.zwischentitel.copyWith(color: MRoh.stempelRot, fontSize: 15)),
            const SizedBox(height: MMass.s4),
            Container(height: 1, color: MRoh.tinte.withValues(alpha: 0.3)),
            const SizedBox(height: MMass.s8),
            ...kinder,
          ],
        ),
      );

  /// Ein Stichpunkt mit Tintenpunkt.
  static Widget _punkt(String text) => Padding(
        padding: const EdgeInsets.only(bottom: MMass.s4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(padding: EdgeInsets.only(top: 8, right: 8), child: SizedBox(width: 5, height: 5, child: DecoratedBox(decoration: BoxDecoration(color: MRoh.tinte, shape: BoxShape.circle)))),
            Expanded(child: Text(text, style: MPapierSchrift.text)),
          ],
        ),
      );
}

/// Öffnet die Karte des Detektivs als Karteikarte über dem Abend.
Future<void> zeigeDetektivKarte(BuildContext context, PartySitzung sitzung) {
  Klang.instanz.spiele('blatt', laut: 0.7);
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.6),
    builder: (c) {
      final l = _de;
      return MKarteikartenDialog(
        titel: l.detektiv_karte_titel,
        inhalt: DetektivKarte(sitzung: sitzung),
        aktionen: [MKnopf(text: l.common_close, art: MKnopfArt.zweit, onPressed: () => Navigator.of(c).pop())],
      );
    },
  );
}

/// Eintrag in der Rollenphase: ein Notizzettel „Deine Detektivkarte“, der die
/// Karte öffnet. Sie ist nicht verdeckt; der ganze Tisch darf sie sehen.
class DetektivKarteEintrag extends StatelessWidget {
  const DetektivKarteEintrag({super.key, required this.sitzung});

  final PartySitzung sitzung;

  @override
  Widget build(BuildContext context) {
    final l = _de;
    return Semantics(
      button: true,
      label: l.detektiv_karte_titel,
      hint: l.detektiv_karte_hinweis,
      excludeSemantics: true,
      onTap: () => zeigeDetektivKarte(context, sitzung),
      child: MBlatt(
        art: PapierArt.notiz,
        klebestreifen: true,
        neigung: -0.004,
        samen: 29,
        onTap: () => zeigeDetektivKarte(context, sitzung),
        padding: const EdgeInsets.fromLTRB(40, 14, 16, 14),
        child: Row(
          children: [
            const Icon(Icons.badge_outlined, color: MRoh.tinteBlau),
            const SizedBox(width: MMass.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.detektiv_karte_titel, style: MPapierSchrift.ueberschrift.copyWith(fontSize: 18)),
                  Text(l.detektiv_karte_hinweis, style: MPapierSchrift.leise),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: MRoh.tinteLeise),
          ],
        ),
      ),
    );
  }
}
