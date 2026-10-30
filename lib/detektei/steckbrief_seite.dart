import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:mordakte_core/mordakte_core.dart' show Besetzung, Steckbriefe;
import 'package:mordakte_core/party_druck.dart';
import 'package:provider/provider.dart';

import '../app/router.dart';
import '../l10n/lookup.dart';
import '../meta/meta_store.dart';
import '../party/daten.dart';
import '../party/datei_knopf.dart';
import '../stil/mappe/assistent_formular.dart';
import '../stil/stil.dart';
import 'akte_bausteine.dart';
import 'akten.dart';
import 'schreibtisch.dart' show GanzeWorte;

/// Steckbriefe und Charakterübersicht einer Akte (Route `/akte/:id/steckbriefe`,
/// K3, A-059, M5): mit einem Tipp von der Akte-Seite, ohne Einrichtung und ohne
/// Fall-Code, für die Wochen vor dem Abend.
///
/// - „Wie viele seid ihr?“: offen (alle Figuren) oder eine Zahl; dann zeigt die
///   Übersicht genau die Figuren, die bei dieser Zahl dabei sind.
/// - „Zum Verschicken“: Charakterübersicht und eine Datei mit allen Steckbriefen.
/// - „Gästeliste“: Name → Figur im [MetaStore]; je Gast mit Figur ein Knopf, der
///   seinen Steckbrief sendet. Fällt eine gewählte Figur bei kleinerer Zahl weg,
///   steht das am Gast. Die Liste füllt reihum die Namen der Einrichtung vor.
///
/// Jede Datei entsteht erst beim Tipp ([DateiKnopf]) und geht an das Teilen des Systems.
class SteckbriefSeite extends StatefulWidget {
  const SteckbriefSeite({super.key, required this.akteId});

  final String akteId;

  @override
  State<SteckbriefSeite> createState() => _SteckbriefSeiteState();
}

/// Was die Seite zum Setzen braucht: Daten der Akte, ihre Steckbriefe, die Schriften.
class _Geladen {
  _Geladen(this.daten, this.steckbriefe, this.stil);
  final PartyDaten daten;
  final Steckbriefe steckbriefe;
  final DruckStil stil;
}

class _SteckbriefSeiteState extends State<SteckbriefSeite> {
  late final Future<List<AkteInfo>> _akten = AktenKatalog.laden().catchError((Object _) => const <AkteInfo>[]);
  _Geladen? _geladen;
  bool _fehler = false;
  String _detektiv = 'w';
  late GaesteListe _liste;
  final List<TextEditingController> _namen = [];

  /// Ein Kontext je Detektiv (m/w): Die Schriftgrößen merkt sich der Kontext.
  final Map<String, SteckbriefKontext> _kontexte = {};

  @override
  void initState() {
    super.initState();
    _liste = context.read<MetaStore>().gaesteliste(widget.akteId);
    for (final g in _liste.gaeste) {
      _namen.add(TextEditingController(text: g.name));
    }
    _laden();
  }

  @override
  void dispose() {
    for (final c in _namen) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _laden() async {
    if (_fehler) setState(() => _fehler = false);
    try {
      Future<Uint8List> schrift(String name) async => (await rootBundle.load('assets/fonts/$name')).buffer.asUint8List();
      final daten = await PartyDaten.laden(rootBundle, fall: widget.akteId);
      final roh = jsonDecode(await rootBundle.loadString('content/party/${widget.akteId}/steckbriefe.json')) as Map<String, Object?>;
      final stil = DruckStil(
        regular: await schrift('Inter-Regular.ttf'),
        fett: await schrift('Inter-Bold.ttf'),
        schreibmaschine: await schrift('SpecialElite-Regular.ttf'),
      );
      if (!mounted) return;
      setState(() => _geladen = _Geladen(daten, Steckbriefe.ausJson(roh), stil));
    } catch (e, st) {
      debugPrint('STECKBRIEFE laden fehler $e\n$st');
      if (mounted) setState(() => _fehler = true);
    }
  }

  SteckbriefKontext _k(_Geladen g) =>
      _kontexte[_detektiv] ??= SteckbriefKontext(g.daten.kanon, g.daten.texte, g.stil, steckbriefe: g.steckbriefe, detektiv: _detektiv);

  void _speichere(GaesteListe neu) {
    setState(() => _liste = neu);
    context.read<MetaStore>().setzeGaesteliste(widget.akteId, neu);
  }

  void _neuerGast() {
    _namen.add(TextEditingController());
    _speichere(_liste.plus(const Gast('')));
  }

  void _entferne(int i) {
    _namen.removeAt(i).dispose();
    _speichere(_liste.ohne(i));
  }

  /// Die fertige Datei für den [DateiKnopf].
  static Future<FertigeDatei> _fertig(Future<DruckDatei> d) async {
    final datei = await d;
    return (name: datei.name, bytes: datei.bytes);
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final g = _geladen;
    return AkteThema(
      akte: widget.akteId,
      child: Builder(
        builder: (context) => Scaffold(
          backgroundColor: MFarben.von(context).grund,
          body: MRahmen(
            aktionen: [
              MKnopf(
                text: l.common_back,
                art: MKnopfArt.zweit,
                icon: Icons.arrow_back_rounded,
                onPressed: () => context.go(Routes.akteVon(widget.akteId)),
              ),
            ],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: MMass.s8),
                FutureBuilder<List<AkteInfo>>(
                  future: _akten,
                  builder: (context, snap) => _Deckel(akteId: widget.akteId, akten: snap.data ?? const []),
                ),
                const SizedBox(height: MMass.s32),
                if (_fehler)
                  MBlatt(
                    art: PapierArt.notiz,
                    neigung: -0.006,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(l.abend_fehler, style: MPapierSchrift.text),
                        const SizedBox(height: MMass.s12),
                        Align(alignment: Alignment.centerLeft, child: MKnopf(text: l.abend_nochmal, art: MKnopfArt.zweit, onPressed: _laden)),
                      ],
                    ),
                  )
                else if (g == null)
                  Text(l.abend_laedt, style: MSchrift.von(context).leise)
                else ...[
                  _personen(context, g),
                  const SizedBox(height: MMass.s24),
                  _dateien(context, g),
                  const SizedBox(height: MMass.s24),
                  _gaeste(context, g),
                ],
                const SizedBox(height: MMass.s16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// „Wie viele seid ihr?“: offen oder eine Zahl in den Grenzen der Besetzung.
  Widget _personen(BuildContext context, _Geladen g) {
    final l = L.of(context);
    final b = g.daten.texte.besetzung;
    final n = _liste.personen;
    return MBlatt(
      klammer: true,
      samen: 71,
      neigung: -0.004,
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MBlattKopf(zeile: l.steckbrief_personen),
          MAnkreuzWahl<bool>(
            optionen: [(false, l.steckbrief_personen_offen), (true, l.steckbrief_personen_fest)],
            gewaehlt: n != null,
            onWahl: (fest) => _speichere(_liste.mitPersonen(fest ? (n ?? 7).clamp(b.minRollen, b.maxRollen) : null)),
          ),
          if (n != null) ...[
            const SizedBox(height: MMass.s12),
            GanzeWorte(l.steckbrief_personen_wert('$n'), style: MPapierSchrift.ueberschrift, textAlign: TextAlign.center),
            Row(
              children: [
                IconButton(
                  tooltip: g.daten.texte.baustein('ui.einrichtung.weniger'),
                  icon: const Icon(Icons.remove_circle_outline),
                  color: MRoh.tinte,
                  onPressed: n > b.minRollen ? () => _speichere(_liste.mitPersonen(n - 1)) : null,
                ),
                Expanded(
                  child: MPapierRegler(
                    child: Slider(
                      value: n.toDouble(),
                      min: b.minRollen.toDouble(),
                      max: b.maxRollen.toDouble(),
                      divisions: b.maxRollen - b.minRollen,
                      onChanged: (v) => _speichere(_liste.mitPersonen(v.round())),
                    ),
                  ),
                ),
                IconButton(
                  tooltip: g.daten.texte.baustein('ui.einrichtung.mehr'),
                  icon: const Icon(Icons.add_circle_outline),
                  color: MRoh.tinte,
                  onPressed: n < b.maxRollen ? () => _speichere(_liste.mitPersonen(n + 1)) : null,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// „Zum Verschicken“: Übersicht und alle Steckbriefe in einer Datei, dazu Detektiv oder Detektivin.
  Widget _dateien(BuildContext context, _Geladen g) {
    final l = L.of(context);
    String ui(String kennung) => g.daten.texte.baustein(kennung);
    final n = _liste.personen;
    return MBlatt(
      klebestreifen: true,
      samen: 72,
      neigung: 0.003,
      padding: const EdgeInsets.fromLTRB(20, 26, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MBlattKopf(zeile: l.steckbrief_dateien),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              DateiKnopf(
                key: ValueKey('uebersicht-$n'),
                text: ui('ui.druck.datei.uebersicht'),
                haupt: true,
                icon: Icons.groups_rounded,
                bauen: () => _fertig(uebersichtDatei(_k(g), rollen: n)),
              ),
              DateiKnopf(
                key: ValueKey('steckbriefe-$n-$_detektiv'),
                text: ui('ui.druck.datei.steckbriefe'),
                icon: Icons.picture_as_pdf_rounded,
                bauen: () => _fertig(steckbriefeGesamt(_k(g), rollen: n)),
              ),
            ],
          ),
          const SizedBox(height: MMass.s16),
          GanzeWorte(ui('ui.einrichtung.detektiv'), style: MPapierSchrift.maschine.copyWith(fontSize: 14, color: MRoh.tinteLeise)),
          const SizedBox(height: MMass.s4),
          MAnkreuzWahl<String>(
            optionen: [('m', ui('ui.einrichtung.detektiv_m')), ('w', ui('ui.einrichtung.detektiv_w'))],
            gewaehlt: _detektiv,
            onWahl: (wert) => setState(() => _detektiv = wert),
          ),
        ],
      ),
    );
  }

  /// Name der Figur für die Auswahl; der Detektiv in der neutralen Form der Übersicht.
  String _figurName(_Geladen g, String id) =>
      id == Besetzung.detektiv ? g.daten.texte.baustein('ui.druck.uebersicht.detektiv') : g.daten.kanon.figur(id)!['name'] as String;

  /// „Gästeliste“: Name → Figur, je Gast mit Figur ein Knopf für seinen Steckbrief.
  Widget _gaeste(BuildContext context, _Geladen g) {
    final l = L.of(context);
    final k = _k(g);
    final n = _liste.personen;
    final alle = uebersichtFiguren(k);
    final dabei = uebersichtFiguren(k, rollen: n).toSet();
    return MBlatt(
      klammer: true,
      samen: 73,
      neigung: -0.002,
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MBlattKopf(zeile: l.steckbrief_gaeste),
          Text(l.steckbrief_gaeste_hinweis, style: MPapierSchrift.leise),
          const SizedBox(height: MMass.s12),
          for (var i = 0; i < _liste.gaeste.length; i++)
            _GastZeile(
              key: ObjectKey(_namen[i]),
              gast: _liste.gaeste[i],
              namen: _namen[i],
              figuren: [for (final id in alle) (id, _figurName(g, id))],
              vergeben: {
                for (var j = 0; j < _liste.gaeste.length; j++)
                  if (j != i && _liste.gaeste[j].figur != null) _liste.gaeste[j].figur!,
              },
              nichtDabei: n != null && _liste.gaeste[i].figur != null && !dabei.contains(_liste.gaeste[i].figur) ? n : null,
              detektiv: _detektiv,
              onAenderung: (gast) => _speichere(_liste.mitGast(i, gast)),
              onEntfernen: () => _entferne(i),
              senden: (figur) => _fertig(steckbriefDatei(k, figur)),
            ),
          Align(
            alignment: Alignment.centerLeft,
            child: MKnopf(text: l.steckbrief_gast_neu, art: MKnopfArt.zweit, icon: Icons.person_add_alt_rounded, onPressed: _neuerGast),
          ),
        ],
      ),
    );
  }
}

/// Ein Gast: Name, Figur, Hinweis bei weggefallener Figur, Knopf für den Steckbrief.
class _GastZeile extends StatelessWidget {
  const _GastZeile({
    super.key,
    required this.gast,
    required this.namen,
    required this.figuren,
    required this.vergeben,
    required this.nichtDabei,
    required this.detektiv,
    required this.onAenderung,
    required this.onEntfernen,
    required this.senden,
  });

  final Gast gast;
  final TextEditingController namen;

  /// Wählbare Figuren (Kennung, Name) in der Reihenfolge der Übersicht.
  final List<(String, String)> figuren;

  /// Figuren anderer Gäste.
  final Set<String> vergeben;

  /// Personenzahl, bei der die gewählte Figur nicht dabei ist; sonst null.
  final int? nichtDabei;
  final String detektiv;
  final ValueChanged<Gast> onAenderung;
  final VoidCallback onEntfernen;
  final Future<FertigeDatei> Function(String figur) senden;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final figur = gast.figur;
    return Padding(
      padding: const EdgeInsets.only(bottom: MMass.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: namen,
                  textCapitalization: TextCapitalization.words,
                  cursorColor: MRoh.tinteBlau,
                  style: MPapierSchrift.maschine.copyWith(fontSize: 17),
                  decoration: mPapierFeld(l.steckbrief_gast_name),
                  onChanged: (t) => onAenderung(gast.mitName(t)),
                ),
              ),
              IconButton(
                tooltip: l.steckbrief_gast_entfernen,
                icon: const Icon(Icons.close_rounded),
                color: MRoh.tinte,
                onPressed: onEntfernen,
              ),
            ],
          ),
          const SizedBox(height: MMass.s4),
          DropdownButton<String?>(
            value: figur,
            isExpanded: true,
            hint: Text(l.steckbrief_gast_ohne, style: MPapierSchrift.leise),
            dropdownColor: MRoh.blatt,
            style: MPapierSchrift.text,
            items: [
              DropdownMenuItem<String?>(value: null, child: Text(l.steckbrief_gast_ohne, style: MPapierSchrift.leise)),
              for (final (id, name) in figuren)
                DropdownMenuItem<String?>(
                  value: id,
                  enabled: !vergeben.contains(id),
                  child: Text(name, style: MPapierSchrift.text.copyWith(color: vergeben.contains(id) ? MRoh.tinteLeise : null)),
                ),
            ],
            onChanged: (f) => onAenderung(gast.mitFigur(f)),
          ),
          if (nichtDabei != null) ...[
            const SizedBox(height: MMass.s4),
            Row(
              children: [
                const Icon(Icons.error_outline_rounded, color: MRoh.stempelRot, size: 20),
                const SizedBox(width: MMass.s8),
                Expanded(child: Text(l.steckbrief_gast_nicht_dabei('$nichtDabei'), style: MPapierSchrift.text.copyWith(color: MRoh.stempelRot))),
              ],
            ),
          ],
          if (figur != null) ...[
            const SizedBox(height: MMass.s8),
            Align(
              alignment: Alignment.centerLeft,
              child: DateiKnopf(
                key: ValueKey('steckbrief-$figur-$detektiv'),
                text: l.steckbrief_senden,
                // Nach dem Bauen „Herunterladen: Steckbrief Fatma“, nicht „Herunterladen: Steckbrief senden“.
                datei: l.steckbrief_von(figuren.where((f) => f.$1 == figur).firstOrNull?.$2 ?? figur),
                icon: Icons.send_rounded,
                bauen: () => senden(figur),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Die Mappe der Seite: Reiter mit der Aktennummer, Titel der Akte, „Steckbriefe &
/// Übersicht“ und der Hinweis, dass nichts davon ein Geheimnis verrät.
class _Deckel extends StatelessWidget {
  const _Deckel({required this.akteId, required this.akten});

  final String akteId;
  final List<AkteInfo> akten;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final index = akten.indexWhere((a) => a.id == akteId);
    final akte = index < 0 ? null : akten[index];
    return LayoutBuilder(
      builder: (context, aussen) => MAktenmappe(
        reiter: index < 0 ? l.steckbrief_titel : l.case_file_no(akteNummer(index)),
        farbe: AkteStil.fuer(akteId).akzent,
        siegel: akte == null ? null : akteSigel(akte),
        blaetter: mappenBlaetter(aussen.maxWidth),
        neigung: 0.003,
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 26),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (akte != null) ...[
              GanzeWorte(akte.titel, style: MPapierSchrift.zwischentitel.copyWith(color: MFarben.von(context).akzent)),
              const SizedBox(height: MMass.s4),
              Container(height: 1, color: MFarben.von(context).linieStark),
              const SizedBox(height: 10),
            ],
            Semantics(header: true, child: GanzeWorte(l.steckbrief_titel, style: MPapierSchrift.titel)),
            const SizedBox(height: MMass.s12),
            GanzeWorte(l.steckbrief_hinweis, style: MPapierSchrift.text),
          ],
        ),
      ),
    );
  }
}
