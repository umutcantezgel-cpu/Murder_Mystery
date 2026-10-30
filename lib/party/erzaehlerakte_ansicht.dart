import 'dart:math' as math;

import 'package:flutter/foundation.dart' show mapEquals;
import 'package:flutter/material.dart';
import 'package:mordakte_core/mordakte_core.dart';

import '../klang/klang.dart';
import '../l10n/gen/app_localizations_de.dart';
import '../stil/mappe/online_bausteine.dart' show MOnlineSilhouette;
import '../stil/stil.dart';
import 'daten.dart';
import 'datei_knopf.dart';
import 'erzaehlerakte_druck.dart';
import 'party_stil.dart';
import 'sitzung.dart';

/// Wie die übrigen Partybildschirme deutsch, auch ohne Lokalisierung im Baum.
final _de = LDe();

/// Erzählerakte (Finale Schlosskeller, A-063): Hintergründe aller Figuren und
/// ihr Beziehungsnetz, nur für die Person, die erzählt. Pfadgleich; die Akte
/// kommt lokal aus der Akte des Geräts ([PartyDaten.erzaehlerakteFuer]), online
/// garantiert die Inhaltskennung dieselbe Fassung. Nie übertragen.
///
/// Sichtbar nur dem Erzähler-Platz: reihum über die Rollenphase
/// ([ErzaehlerakteEintrag], „Gib das Gerät an …“) und das offene Erzählerpult,
/// am Erzähler-Handy und online auf dem Erzähler-Sitz. Nie im Solo, nie dem
/// Detektiv, einer Rolle oder der Assistenz, nie ab dem Finale
/// ([PartySitzung.erzaehlerakteSichtbar]). Nur in der offenen Akte
/// ([ErzaehlerakteSeite]) gibt es sie auch „Als PDF“, in derselben Fassung.
///
/// Zwei Reiter:
/// - „Figuren“: erst die besetzten, dann die ohne Spieler, danach Herr
///   Schneider und der Detektiv. Je Figur aufklappbar Hintergrund, Bindungen
///   (öffentlich und heimlich als Chips), Verhältnis zu Herrn Schneider, Motiv,
///   Geheimnis, Nebendelikt, Loyalität, Ziele und Stimme.
/// - „Netz“: ein Ring mit Herrn Schneider in der Mitte; öffentliche Kanten
///   durchgezogen, heimliche gestrichelt. Ein Tipp auf eine Figur hebt ihre
///   Bindungen hervor.
class ErzaehlerakteAnsicht extends StatefulWidget {
  const ErzaehlerakteAnsicht({super.key, required this.daten, required this.besetzt, required this.einfluss, this.spieler, this.reiter = 0});

  final PartyDaten daten;

  /// Spielt der Abend „Dein Moment“? Dann stehen die Sterne als Ziele, sonst die
  /// Ziele des Kanons ([PartyDaten.erzaehlerakteFuer]).
  final bool einfluss;

  /// Besetzte Figuren des Abends in Besetzungsreihenfolge.
  final List<String> besetzt;

  /// Name dessen, der eine Figur spielt (`null` oder leer: keiner bekannt).
  final String? Function(String figur)? spieler;

  /// Reiter zu Beginn: 0 Figuren, 1 Netz.
  final int reiter;

  @override
  State<ErzaehlerakteAnsicht> createState() => _ErzaehlerakteAnsichtState();
}

class _ErzaehlerakteAnsichtState extends State<ErzaehlerakteAnsicht> {
  late int _reiter = widget.reiter;

  @override
  Widget build(BuildContext context) {
    final akte = widget.daten.erzaehlerakteFuer(einfluss: widget.einfluss);
    if (akte == null) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MReiterleiste(
          key: const ValueKey('erzaehlerakte-reiter'),
          reiter: [_de.erzaehlerakte_reiter_figuren, _de.erzaehlerakte_reiter_netz],
          gewaehlt: _reiter,
          onWahl: (i) => setState(() => _reiter = i),
        ),
        Expanded(
          child: ColoredBox(
            color: MRoh.blatt,
            child: _reiter == 0
                ? _FigurenReiter(key: const ValueKey('erzaehlerakte-figuren'), daten: widget.daten, akte: akte, besetzt: widget.besetzt, spieler: widget.spieler)
                : _NetzReiter(key: const ValueKey('erzaehlerakte-netz'), daten: widget.daten, akte: akte, besetzt: widget.besetzt),
          ),
        ),
      ],
    );
  }
}

/// Text der Oberfläche aus den Bausteinen der Akte (`ui.druck.akte.*`, wie im Druck).
String _ui(PartyDaten d, String kennung, [Map<String, String> werte = const {}]) {
  var t = d.texte.baustein(kennung);
  for (final e in werte.entries) {
    t = t.replaceAll('{${e.key}}', e.value);
  }
  return t;
}

/// Anzeigename eines Knotens im Netz (Figur oder Herr Schneider).
String _knotenName(PartyDaten d, Erzaehlerakte akte, String id) =>
    id == akte.schneider.person ? (akte.schneider.name ?? id) : (d.kanon.figur(id)?['name'] as String? ?? id);

Color? _farbe(PartyDaten d, String id) {
  final code = d.kanon.figur(id)?['colorCode'];
  if (code is String && RegExp(r'^#[0-9a-fA-F]{6}$').hasMatch(code)) return Color(int.parse(code.substring(1), radix: 16) | 0xFF000000);
  return null;
}

LookDef? _look(PartyDaten d, String id) {
  try {
    final f = d.kanon.figur(id);
    return f == null ? null : LookDef.fromJson(renderLook(f));
  } catch (_) {
    return null;
  }
}

// ------------------------------------------------------------------- Figuren

class _FigurenReiter extends StatefulWidget {
  const _FigurenReiter({super.key, required this.daten, required this.akte, required this.besetzt, this.spieler});

  final PartyDaten daten;
  final Erzaehlerakte akte;
  final List<String> besetzt;
  final String? Function(String figur)? spieler;

  @override
  State<_FigurenReiter> createState() => _FigurenReiterState();
}

class _FigurenReiterState extends State<_FigurenReiter> {
  final Set<String> _offen = {};

  void _umschalten(String id) => setState(() => _offen.contains(id) ? _offen.remove(id) : _offen.add(id));

  @override
  Widget build(BuildContext context) {
    final d = widget.daten;
    final akte = widget.akte;
    final besetzt = widget.besetzt.toSet();
    final reihe = d.texte.besetzung.reihenfolge;
    final figuren = [...akte.figuren]..sort((a, b) => reihe.indexOf(a.figur).compareTo(reihe.indexOf(b.figur)));
    final mit = [for (final f in figuren) if (besetzt.contains(f.figur)) f];
    final ohne = [for (final f in figuren) if (!besetzt.contains(f.figur)) f];
    Widget figur(ErzaehlerakteFigur f) => _FigurKarte(
          key: ValueKey('akte-figur-${f.figur}'),
          daten: d,
          akte: akte,
          figur: f,
          nr: reihe.indexOf(f.figur) + 1,
          spieler: widget.spieler?.call(f.figur),
          offen: _offen.contains(f.figur),
          onTap: () => _umschalten(f.figur),
        );
    return ListView(
      padding: const EdgeInsets.fromLTRB(MMass.s16, MMass.s16, MMass.s16, MMass.s24),
      children: [
        if (akte.einleitung.isNotEmpty) ...[
          MBlatt(
            art: PapierArt.notiz,
            neigung: 0.003,
            samen: 91,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Text(akte.einleitung, style: MPapierSchrift.text),
          ),
          const SizedBox(height: MMass.s16),
        ],
        if (mit.isNotEmpty) ...[
          _Kopf(_ui(d, 'ui.druck.akte.besetzt'), key: const ValueKey('akte-besetzt')),
          for (final f in mit) figur(f),
        ],
        if (ohne.isNotEmpty) ...[
          _Kopf(_ui(d, 'ui.druck.akte.ohne'), key: const ValueKey('akte-ohne')),
          for (final f in ohne) figur(f),
        ],
        _Kopf(akte.schneider.name ?? ''),
        _BlattKarte(daten: d, akte: akte, blatt: akte.schneider, titel: akte.schneider.rolle),
        _Kopf(_ui(d, 'ui.druck.akte.detektiv')),
        _BlattKarte(daten: d, akte: akte, blatt: akte.detektiv),
      ],
    );
  }
}

/// Zwischenkopf in Schreibmaschine über einer Tintenlinie.
class _Kopf extends StatelessWidget {
  const _Kopf(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: MMass.s8, bottom: MMass.s8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(text.toUpperCase(), style: MPapierSchrift.zwischentitel.copyWith(color: MRoh.stempelRot)),
            const SizedBox(height: MMass.s4),
            Container(height: 1, color: MRoh.tinte.withValues(alpha: 0.3)),
          ],
        ),
      );
}

/// Eine Figur der Akte als aufklappbare Karteikarte: oben Porträt, Nummer,
/// Name, Rolle und wer sie spielt; offen alle Abschnitte.
class _FigurKarte extends StatelessWidget {
  const _FigurKarte({
    super.key,
    required this.daten,
    required this.akte,
    required this.figur,
    required this.nr,
    required this.spieler,
    required this.offen,
    required this.onTap,
  });

  final PartyDaten daten;
  final Erzaehlerakte akte;
  final ErzaehlerakteFigur figur;
  final int nr;
  final String? spieler;
  final bool offen;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final f = figur;
    final d = daten;
    final look = _look(d, f.figur);
    final wer = spieler?.trim() ?? '';
    final kopf = Row(
      children: [
        ExcludeSemantics(
          child: look == null
              ? MOnlineSilhouette(groesse: 48, samen: nr)
              : MFotoabzug(look: look, groesse: 48, neigung: nr.isEven ? -0.05 : 0.04, akzent: _farbe(d, f.figur)),
        ),
        const SizedBox(width: MMass.s12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              MGanzeWorte('$nr · ${f.name}', stil: MPapierSchrift.ueberschrift.copyWith(fontSize: 18), minimum: 14),
              if (f.rolle.isNotEmpty) Text(f.rolle, style: MPapierSchrift.leise),
              if (wer.isNotEmpty && wer != f.name) Text(_de.einstimmung_gespielt_von(wer), style: MPapierSchrift.hand.copyWith(fontSize: 18)),
            ],
          ),
        ),
        Icon(offen ? Icons.expand_less_rounded : Icons.expand_more_rounded, color: MRoh.tinte),
      ],
    );
    final loyalitaet = f.loyalitaet;
    return Padding(
      padding: const EdgeInsets.only(bottom: MMass.s12),
      child: Semantics(
        button: true,
        expanded: offen,
        child: MBlatt(
          art: PapierArt.karteikarte,
          kopfLinie: 7,
          linien: false,
          randFarbe: _farbe(d, f.figur),
          neigung: nr.isEven ? -0.003 : 0.003,
          samen: 200 + nr,
          onTap: onTap,
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              kopf,
              if (offen) ...[
                if (f.alltag.isNotEmpty) _abschnitt(_ui(d, 'ui.druck.akte.alltag'), [_text(f.alltag)]),
                _abschnitt(_ui(d, 'ui.druck.akte.hintergrund'), [_text(f.hintergrund)]),
                _abschnitt(_ui(d, 'ui.druck.akte.bindungen'), [_Bindungen(daten: d, akte: akte, figur: f.figur)]),
                if (f.zuSchneider.isNotEmpty) _abschnitt(_ui(d, 'ui.druck.akte.zu_schneider'), [_text(f.zuSchneider)]),
                if (f.motiv case final m? when m.isNotEmpty) _abschnitt(_ui(d, 'ui.druck.akte.motiv'), [_text(m)]),
                if (f.geheimnis case final g? when g.isNotEmpty) _abschnitt(_ui(d, 'ui.druck.akte.geheimnis'), [_text(g)]),
                if (f.nebendelikt case final n? when n.isNotEmpty) _abschnitt(_ui(d, 'ui.druck.akte.nebendelikt'), [_text(n)]),
                if (loyalitaet != null)
                  _abschnitt(_ui(d, 'ui.druck.akte.loyalitaet'), [
                    Text(_ui(d, 'ui.druck.akte.loyalitaet.zu', {'name': _knotenName(d, akte, loyalitaet.zu)}), style: MPapierSchrift.ueberschrift.copyWith(fontSize: 16)),
                    if (loyalitaet.grund.isNotEmpty) _text(loyalitaet.grund),
                  ]),
                if (f.ziele.isNotEmpty) _abschnitt(_ui(d, 'ui.druck.akte.ziele'), [for (final z in f.ziele) _punkt(z.text)]),
                if (f.stimme.isNotEmpty) _abschnitt(_ui(d, 'ui.druck.akte.stimme'), [for (final p in f.stimme) _punkt(p)]),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Herr Schneider oder der Detektiv: Hintergrund und Stimme.
class _BlattKarte extends StatelessWidget {
  const _BlattKarte({required this.daten, required this.akte, required this.blatt, this.titel});

  final PartyDaten daten;
  final Erzaehlerakte akte;
  final ErzaehlerakteBlatt blatt;
  final String? titel;

  @override
  Widget build(BuildContext context) {
    final d = daten;
    final titel = this.titel;
    final kanten = akte.kantenVon(blatt.person);
    return Padding(
      padding: const EdgeInsets.only(bottom: MMass.s12),
      child: MBlatt(
        key: ValueKey('akte-blatt-${blatt.person}'),
        art: PapierArt.karteikarte,
        kopfLinie: 7,
        linien: false,
        neigung: -0.002,
        samen: blatt.person.length * 13,
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (titel != null && titel.isNotEmpty) Text(titel, style: MPapierSchrift.leise),
            _abschnitt(_ui(d, 'ui.druck.akte.hintergrund'), [_text(blatt.hintergrund)]),
            if (kanten.isNotEmpty) _abschnitt(_ui(d, 'ui.druck.akte.bindungen'), [_Bindungen(daten: d, akte: akte, figur: blatt.person)]),
            if (blatt.stimme.isNotEmpty) _abschnitt(_ui(d, 'ui.druck.akte.stimme'), [for (final p in blatt.stimme) _punkt(p)]),
          ],
        ),
      ),
    );
  }
}

Widget _abschnitt(String titel, List<Widget> kinder) => Padding(
      padding: const EdgeInsets.only(top: MMass.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(titel, style: MPapierSchrift.zwischentitel.copyWith(color: MRoh.stempelRot, fontSize: 15)),
          const SizedBox(height: 4),
          Container(height: 1, color: MRoh.tinte.withValues(alpha: 0.3)),
          const SizedBox(height: MMass.s8),
          ...kinder,
        ],
      ),
    );

Widget _text(String t) => Text(t, style: MPapierSchrift.text);

Widget _punkt(String text) => Padding(
      padding: const EdgeInsets.only(bottom: MMass.s4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10, right: 10),
            child: Container(width: 6, height: 6, decoration: BoxDecoration(color: MRoh.stempelRot.withValues(alpha: 0.8), shape: BoxShape.circle)),
          ),
          Expanded(child: Text(text, style: MPapierSchrift.text)),
        ],
      ),
    );

/// Die Bindungen eines Knotens als Chips: öffentlich in Tinte, heimlich in
/// Stempelrot mit Schloss; der Text der Kante steht im Tooltip und darunter.
class _Bindungen extends StatelessWidget {
  const _Bindungen({required this.daten, required this.akte, required this.figur});

  final PartyDaten daten;
  final Erzaehlerakte akte;
  final String figur;

  @override
  Widget build(BuildContext context) {
    final d = daten;
    final kanten = akte.kantenVon(figur);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final k in kanten)
          Padding(
            padding: const EdgeInsets.only(bottom: MMass.s8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Tooltip(
                  message: k.oeffentlich ? _ui(d, 'ui.druck.akte.netz.oeffentlich') : _ui(d, 'ui.druck.akte.netz.heimlich'),
                  child: MChip(
                    _ui(d, 'ui.druck.akte.legende.mitte', {'name': _knotenName(d, akte, k.anderer(figur)), 'art': _ui(d, 'ui.druck.akte.art.${k.art}')}),
                    key: ValueKey('bindung-$figur-${k.anderer(figur)}-${k.sichtbar}'),
                    icon: k.oeffentlich ? Icons.people_outline_rounded : Icons.lock_outline_rounded,
                    farbe: k.oeffentlich ? MRoh.tinteBlau : MRoh.stempelRot,
                    gefuellt: !k.oeffentlich,
                  ),
                ),
                if (k.text.isNotEmpty)
                  Padding(padding: const EdgeInsets.only(top: 2, left: 4), child: Text(k.text, style: MPapierSchrift.leise)),
              ],
            ),
          ),
        _Legende(daten: d),
      ],
    );
  }
}

// ---------------------------------------------------------------------- Netz

class _NetzReiter extends StatefulWidget {
  const _NetzReiter({super.key, required this.daten, required this.akte, required this.besetzt});

  final PartyDaten daten;
  final Erzaehlerakte akte;
  final List<String> besetzt;

  @override
  State<_NetzReiter> createState() => _NetzReiterState();
}

class _NetzReiterState extends State<_NetzReiter> {
  String? _wahl;

  void _waehle(String? id) => setState(() => _wahl = id == _wahl ? null : id);

  @override
  Widget build(BuildContext context) {
    final d = widget.daten;
    final akte = widget.akte;
    final reihe = [for (final r in d.texte.besetzung.reihenfolge) if (akte.figur(r) != null) r];
    final besetzt = widget.besetzt.toSet();
    final mitte = akte.schneider.person;
    final wahl = _wahl;
    final kanten = wahl == null ? const <NetzKante>[] : akte.kantenVon(wahl);
    return ListView(
      padding: const EdgeInsets.fromLTRB(MMass.s16, MMass.s16, MMass.s16, MMass.s24),
      children: [
        Text(_ui(d, 'ui.druck.akte.netz.hinweis', {'opfer': akte.schneider.name ?? ''}), style: MPapierSchrift.leise),
        const SizedBox(height: MMass.s12),
        LayoutBuilder(
          builder: (context, box) {
            final seite = math.min(box.maxWidth, 560.0);
            final knoten = seite >= 420 ? 40.0 : 32.0;
            final radius = seite / 2 - knoten / 2 - 4;
            final zentrum = Offset(seite / 2, seite / 2);
            final orte = <String, Offset>{
              mitte: zentrum,
              for (final (i, id) in reihe.indexed) id: zentrum + Offset.fromDirection(-math.pi / 2 + 2 * math.pi * i / reihe.length, radius),
            };
            return Center(
              child: SizedBox(
                key: const ValueKey('netz-ring'),
                width: seite,
                height: seite,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(painter: NetzMaler(kanten: akte.netz, orte: orte, wahl: wahl)),
                    ),
                    for (final MapEntry(key: id, value: o) in orte.entries)
                      Positioned(
                        left: o.dx - (id == mitte ? knoten * 0.75 : knoten / 2),
                        top: o.dy - (id == mitte ? knoten * 0.75 : knoten / 2),
                        width: id == mitte ? knoten * 1.5 : knoten,
                        height: id == mitte ? knoten * 1.5 : knoten,
                        child: _Knoten(
                          key: ValueKey('netz-knoten-$id'),
                          text: id == mitte ? '' : '${reihe.indexOf(id) + 1}',
                          semantik: _de.erzaehlerakte_figur_semantik(_knotenName(d, akte, id), akte.kantenVon(id).length),
                          farbe: id == mitte ? MRoh.tinte : (_farbe(d, id) ?? MRoh.tinteBlau),
                          besetzt: id == mitte || besetzt.contains(id),
                          gewaehlt: id == wahl,
                          onTap: () => _waehle(id),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: MMass.s8),
        _Legende(daten: d),
        const SizedBox(height: MMass.s12),
        Text(_de.erzaehlerakte_netz_tipp, style: MPapierSchrift.leise),
        const SizedBox(height: MMass.s8),
        if (wahl != null) ...[
          Row(
            children: [
              Expanded(child: MGanzeWorte(_knotenName(d, akte, wahl), stil: MPapierSchrift.ueberschrift.copyWith(fontSize: 18), minimum: 14)),
              MKnopf(key: const ValueKey('netz-alle'), text: _de.erzaehlerakte_netz_alle, art: MKnopfArt.leise, onPressed: () => _waehle(null)),
            ],
          ),
          const SizedBox(height: MMass.s8),
          if (kanten.isNotEmpty) _Bindungen(daten: d, akte: akte, figur: wahl),
          const SizedBox(height: MMass.s16),
        ],
        // Die Nummern des Rings: je Figur eine Zeile, antippbar wie der Ring.
        for (final (i, id) in reihe.indexed)
          InkWell(
            key: ValueKey('netz-zeile-$id'),
            onTap: () => _waehle(id),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: MMass.tippflaeche),
              child: Row(
                children: [
                  SizedBox(width: 32, child: Text('${i + 1}', style: MPapierSchrift.maschine.copyWith(fontSize: 15))),
                  Expanded(
                    child: Text(
                      _knotenName(d, akte, id),
                      style: (besetzt.contains(id) ? MPapierSchrift.text : MPapierSchrift.leise).copyWith(fontWeight: id == wahl ? FontWeight.w700 : null),
                    ),
                  ),
                  Text('${akte.kantenVon(id).length}', style: MPapierSchrift.leise),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Ein Knoten im Ring: Kreis in der Farbe der Figur mit ihrer Nummer;
/// besetzte gefüllt, unbesetzte nur umrandet. Herr Schneider in der Mitte.
class _Knoten extends StatelessWidget {
  const _Knoten({super.key, required this.text, required this.semantik, required this.farbe, required this.besetzt, required this.gewaehlt, required this.onTap});

  final String text, semantik;
  final Color farbe;
  final bool besetzt, gewaehlt;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        selected: gewaehlt,
        label: semantik,
        excludeSemantics: true,
        onTap: onTap,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: besetzt ? farbe : MRoh.blatt,
              border: Border.all(color: gewaehlt ? MRoh.stempelRot : farbe, width: gewaehlt ? 3.5 : 2),
              boxShadow: const [BoxShadow(color: Color(0x40000000), blurRadius: 3, offset: Offset(0, 1))],
            ),
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: text.isEmpty
                      ? const Icon(Icons.person_rounded, color: MRoh.blatt)
                      : Text(text, style: MPapierSchrift.maschine.copyWith(fontSize: 14, color: besetzt && farbe.computeLuminance() < 0.5 ? MRoh.blatt : MRoh.tinte)),
                ),
              ),
            ),
          ),
        ),
      );
}

/// Legende unter dem Ring: durchgezogen am Tisch bekannt, gestrichelt nur dem Erzähler.
class _Legende extends StatelessWidget {
  const _Legende({required this.daten});

  final PartyDaten daten;

  @override
  Widget build(BuildContext context) {
    Widget zeile(bool oeffentlich, String text) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 36,
              height: 12,
              child: CustomPaint(painter: _LinienProbe(oeffentlich: oeffentlich)),
            ),
            const SizedBox(width: MMass.s8),
            Flexible(child: Text(text, style: MPapierSchrift.leise)),
          ],
        );
    return Wrap(
      spacing: MMass.s16,
      runSpacing: MMass.s4,
      children: [
        zeile(true, _ui(daten, 'ui.druck.akte.netz.oeffentlich')),
        zeile(false, _ui(daten, 'ui.druck.akte.netz.heimlich')),
      ],
    );
  }
}

class _LinienProbe extends CustomPainter {
  const _LinienProbe({required this.oeffentlich});

  final bool oeffentlich;

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height / 2;
    NetzMaler.linie(canvas, Offset(0, y), Offset(size.width, y), NetzMaler.stift(oeffentlich, 1), gestrichelt: !oeffentlich);
  }

  @override
  bool shouldRepaint(covariant _LinienProbe alt) => alt.oeffentlich != oeffentlich;
}

/// Die Kanten des Netzes zwischen den Orten der Knoten: öffentlich
/// durchgezogen in Tinte, heimlich gestrichelt in Stempelrot. Mit [wahl] treten
/// die Kanten dieses Knotens hervor, die übrigen verblassen.
class NetzMaler extends CustomPainter {
  const NetzMaler({required this.kanten, required this.orte, this.wahl});

  final List<NetzKante> kanten;
  final Map<String, Offset> orte;
  final String? wahl;

  /// Stift einer Kante: Farbe nach Sichtbarkeit, [deckkraft] für verblasste.
  static Paint stift(bool oeffentlich, double deckkraft) => Paint()
    ..color = (oeffentlich ? MRoh.tinteBlau : MRoh.stempelRot).withValues(alpha: deckkraft)
    ..strokeWidth = oeffentlich ? 1.6 : 1.8
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

  /// Eine Linie, auf Wunsch gestrichelt (6 Punkte Strich, 5 Lücke).
  static void linie(Canvas canvas, Offset a, Offset b, Paint stift, {bool gestrichelt = false}) {
    if (!gestrichelt) {
      canvas.drawLine(a, b, stift);
      return;
    }
    final laenge = (b - a).distance;
    if (laenge == 0) return;
    final richtung = (b - a) / laenge;
    for (var t = 0.0; t < laenge; t += 11) {
      canvas.drawLine(a + richtung * t, a + richtung * math.min(t + 6, laenge), stift);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = wahl;
    void zeichne(NetzKante k, double deckkraft, {double dicker = 0}) {
      final a = orte[k.a], b = orte[k.b];
      if (a == null || b == null) return;
      final s = stift(k.oeffentlich, deckkraft)..strokeWidth += dicker;
      linie(canvas, a, b, s, gestrichelt: !k.oeffentlich);
    }

    if (w == null) {
      for (final k in kanten) {
        zeichne(k, 0.55);
      }
      return;
    }
    // Erst die verblassten, dann die Kanten der gewählten Figur obenauf.
    for (final k in kanten) {
      if (!k.beruehrt(w)) zeichne(k, 0.12);
    }
    for (final k in kanten) {
      if (k.beruehrt(w)) zeichne(k, 0.95, dicker: 1.2);
    }
  }

  @override
  bool shouldRepaint(covariant NetzMaler alt) => alt.wahl != wahl || !identical(alt.kanten, kanten) || !mapEquals(alt.orte, orte);
}

// ------------------------------------------------------------------ Zugang

/// Öffnet die Erzählerakte als ganze Seite über dem Abend. [wache] und
/// [erlaubt]: Ändert sich der Abend so, dass sie nicht mehr gilt (Finale, Sitz
/// gewechselt), schließt sie sich selbst. [einfluss]: Spielt der Abend „Dein
/// Moment“ (Sterne als Ziele)? [rollen]: Personenzahl des Abends für „Als PDF“.
Future<void> zeigeErzaehlerakte(
  BuildContext context, {
  required PartyDaten daten,
  required List<String> besetzt,
  required bool einfluss,
  int? rollen,
  String? Function(String figur)? spieler,
  Listenable? wache,
  bool Function()? erlaubt,
}) {
  Klang.instanz.spiele('blatt', laut: 0.7);
  return Navigator.of(context).push<void>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => ErzaehlerakteSeite(daten: daten, besetzt: besetzt, einfluss: einfluss, rollen: rollen, spieler: spieler, wache: wache, erlaubt: erlaubt),
    ),
  );
}

/// Die Erzählerakte als eigene Seite mit „Schließen“. Mit der Personenzahl
/// [rollen] liegt daneben „Als PDF“: dieselbe Fassung wie angezeigt
/// ([einfluss]), für diese Personenzahl, ohne Fall-Code. Die Seite ist nur dem
/// Erzähler-Platz zugänglich ([erlaubt]); so auch die Datei.
class ErzaehlerakteSeite extends StatefulWidget {
  const ErzaehlerakteSeite({
    super.key,
    required this.daten,
    required this.besetzt,
    required this.einfluss,
    this.rollen,
    this.spieler,
    this.wache,
    this.erlaubt,
  });

  final PartyDaten daten;
  final List<String> besetzt;
  final bool einfluss;

  /// Personenzahl des Abends für „Als PDF“; ohne Angabe (oder außerhalb der
  /// Besetzung) gibt es den Knopf nicht.
  final int? rollen;
  final String? Function(String figur)? spieler;
  final Listenable? wache;
  final bool Function()? erlaubt;

  @override
  State<ErzaehlerakteSeite> createState() => _ErzaehlerakteSeiteState();
}

class _ErzaehlerakteSeiteState extends State<ErzaehlerakteSeite> {
  bool _zu = false;

  @override
  void initState() {
    super.initState();
    widget.wache?.addListener(_pruefe);
  }

  @override
  void dispose() {
    widget.wache?.removeListener(_pruefe);
    super.dispose();
  }

  void _pruefe() {
    if (_zu || !mounted || (widget.erlaubt?.call() ?? true)) return;
    _zu = true;
    Navigator.of(context).maybePop();
  }

  /// Personenzahl für „Als PDF“, wenn es die Akte gibt und die Zahl zur Besetzung passt.
  int? get _pdfRollen {
    final n = widget.rollen;
    final b = widget.daten.texte.besetzung;
    if (n == null || n < b.minRollen || n > b.maxRollen) return null;
    return widget.daten.erzaehlerakteFuer(einfluss: widget.einfluss) == null ? null : n;
  }

  /// Die Akte wie angezeigt als PDF; nur, solange die Seite gilt.
  Future<FertigeDatei> _pdf(int rollen) async {
    if (!(widget.erlaubt?.call() ?? true)) throw StateError('Die Erzählerakte gilt hier nicht mehr.');
    final k = await erzaehlerakteKontext(widget.daten, einfluss: widget.einfluss, rollen: rollen);
    return erzaehlerakteDatei(k ?? (throw StateError('Diese Akte hat keine Erzählerakte.')));
  }

  @override
  Widget build(BuildContext context) {
    final rollen = _pdfRollen;
    return Scaffold(
      key: const ValueKey('erzaehlerakte-seite'),
      backgroundColor: MFarben.von(context).grund,
      body: MRahmen(
        marke: _ui(widget.daten, 'ui.druck.akte.nur'),
        titel: _de.erzaehlerakte_titel,
        scroll: false,
        aktionen: [
          MKnopf(
            key: const ValueKey('erzaehlerakte-schliessen'),
            text: _de.common_close,
            art: MKnopfArt.zweit,
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          // Dieselbe Fassung als Datei, nur hier in der offenen Akte. Im Browser und in
          // der Android-App im engen Fuß nur „Herunterladen“/„Teilen“, damit die
          // Figurenliste bei 320 px bleibt.
          if (rollen != null)
            DateiKnopf(
              key: ValueKey('erzaehlerakte-pdf-${widget.einfluss}-$rollen'),
              text: _de.erzaehlerakte_pdf,
              datei: _ui(widget.daten, 'ui.druck.akte.titel'),
              kurz: true,
              icon: Icons.picture_as_pdf_rounded,
              bauen: () => _pdf(rollen),
            ),
        ],
        child: ErzaehlerakteAnsicht(daten: widget.daten, besetzt: widget.besetzt, einfluss: widget.einfluss, spieler: widget.spieler),
      ),
    );
  }
}

/// Knopf „Erzählerakte“ für den Erzähler-Platz eines Abends an diesem Gerät
/// ([PartySitzung.erzaehlerakteSichtbar]); sonst nichts.
class ErzaehlerakteKnopf extends StatelessWidget {
  const ErzaehlerakteKnopf({super.key, required this.sitzung, this.art = MKnopfArt.zweit});

  final PartySitzung sitzung;
  final MKnopfArt art;

  @override
  Widget build(BuildContext context) {
    final s = sitzung;
    if (!s.erzaehlerakteSichtbar) return const SizedBox.shrink();
    return MKnopf(
      key: const ValueKey('erzaehlerakte-knopf'),
      text: _de.erzaehlerakte_titel,
      art: art,
      icon: Icons.folder_shared_outlined,
      onPressed: () => erzaehlerakteZeigen(context, s),
    );
  }
}

/// Öffnet die Erzählerakte des Abends [s]: besetzte Figuren und Namen am Tisch
/// aus der Sitzung; sie schließt sich, sobald sie nicht mehr gilt.
Future<void> erzaehlerakteZeigen(BuildContext context, PartySitzung s) => zeigeErzaehlerakte(
      context,
      daten: s.daten,
      besetzt: s.besetzt,
      einfluss: s.einfluss,
      rollen: s.einstellungen.rollen,
      spieler: (f) => s.solo ? null : s.namen[f],
      wache: s,
      erlaubt: () => s.erzaehlerakteSichtbar,
    );

/// Eintrag der Erzählerakte in der Rollenphase, wenn reihum ein Erzähler mit am
/// Tisch sitzt: wie bei den Dossiers erst „Gib das Gerät an …“, dann öffnet
/// „Ich bin …, zeig her“ die Akte. Danach ist der Bildschirm wieder neutral.
class ErzaehlerakteEintrag extends StatefulWidget {
  const ErzaehlerakteEintrag({super.key, required this.sitzung});

  final PartySitzung sitzung;

  @override
  State<ErzaehlerakteEintrag> createState() => _ErzaehlerakteEintragState();
}

class _ErzaehlerakteEintragState extends State<ErzaehlerakteEintrag> {
  bool _vorbereitet = false;

  PartySitzung get s => widget.sitzung;

  Future<void> _zeigen() async {
    Klang.instanz.spiele('siegel');
    setState(() => _vorbereitet = false);
    await erzaehlerakteZeigen(context, s);
  }

  @override
  Widget build(BuildContext context) {
    if (!s.erzaehlerakteSichtbar) return const SizedBox.shrink();
    final name = s.erzaehlerName;
    if (_vorbereitet) {
      return MBlatt(
        key: const ValueKey('erzaehlerakte-zwischenstufe'),
        art: PapierArt.telegramm,
        padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
        neigung: -0.006,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(child: MSiegel(kuerzel: AkteStil.fuer(s.daten.fall).sigel, farbe: context.farben.gefahr, groesse: 54)),
            const SizedBox(height: 16),
            Text(s.ui('ui.verdeckt.weitergeben', {'name': name}), style: MPapierSchrift.ueberschrift, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            MKnopf(key: const ValueKey('erzaehlerakte-zeigen'), text: s.ui('ui.verdeckt.frage', {'name': name}), onPressed: _zeigen),
            const SizedBox(height: 10),
            MKnopf(text: s.ui('ui.allgemein.zurueck'), art: MKnopfArt.zweit, onPressed: () => setState(() => _vorbereitet = false)),
          ],
        ),
      );
    }
    return Semantics(
      button: true,
      label: _de.erzaehlerakte_titel,
      hint: _de.erzaehlerakte_fuer(name),
      excludeSemantics: true,
      onTap: () => setState(() => _vorbereitet = true),
      child: MBlatt(
        key: const ValueKey('erzaehlerakte-eintrag'),
        art: PapierArt.notiz,
        klebestreifen: true,
        neigung: 0.004,
        samen: 31,
        onTap: () => setState(() => _vorbereitet = true),
        padding: const EdgeInsets.fromLTRB(40, 14, 16, 14),
        child: Row(
          children: [
            const Icon(Icons.folder_shared_outlined, color: MRoh.tinteBlau),
            const SizedBox(width: MMass.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_de.erzaehlerakte_titel, style: MPapierSchrift.ueberschrift.copyWith(fontSize: 18)),
                  Text(_de.erzaehlerakte_fuer(name), style: MPapierSchrift.leise),
                  Text(_de.erzaehlerakte_eintrag, style: MPapierSchrift.leise),
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
