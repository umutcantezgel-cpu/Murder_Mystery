import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:mordakte_core/party_druck.dart';
import 'package:provider/provider.dart';

import '../abend/einrichtung/abschnitte.dart' show EinrichtungsTafel;
import '../app/router.dart';
import '../l10n/lookup.dart';
import '../meta/meta_store.dart';
import '../party/kammer_laden.dart';
import '../party/kammer_tafel.dart';
import '../stil/mappe/assistent_formular.dart';
import '../stil/stil.dart';
import 'akte_bausteine.dart';
import 'akten.dart';
import 'schreibtisch.dart' show GanzeWorte;

/// Druckmappe einer Akte (Route `/akte/:id/druck`): das Kammerspiel zum
/// Ausdrucken (B1, B3). Es ersetzt hier das alte Druckspiel; der Fall ist fest
/// (U4YRK), darum gibt es keinen Fall-Code, keine Rundendauer und keine Wahl
/// von Fassung oder „Dein Moment“, nur Personen (6 bis 20: Rollen, Detektiv und
/// Erzähler, E6) und Detektiv oder Detektivin. „Druckmappe vorbereiten“ zeigt
/// die Dateien ([KammerTafel]). Eine Erzählerakte bietet die Druckmappe nicht an
/// (E16): Sie verriete dem Erzähler, der die Lösung nicht kennt, die Geheimnisse;
/// sie bleibt am Erzählerplatz eines Abends am Bildschirm. Es entsteht kein
/// Abend. Erreichbar über „PDFs zum Ausdrucken“ auf der Akte, ganz oben in der
/// Detektei und dort unter ihrer Mappe; eine Akte ohne Kammerspiel hat keine.
///
/// Inhalt und Schriften kommen aus dem Bündel ([kammerGrundlageLaden]), ohne
/// `dart:io`: Die Druckmappe läuft auch im Browser. Die Gästeliste der Akte
/// (Steckbrief-Seite, M5) gibt die Personenzahl vor ([kammerPersonenVorgabe])
/// und die Namen auf den Knöpfen „Senden an …“.
///
/// Oben liegt die Mappe der Druckfassung (Reiter mit der Aktennummer, Titel der
/// Akte, Anleitung), darunter die Einstellungen auf dem Schreibtisch.
class DruckmappeSeite extends StatefulWidget {
  const DruckmappeSeite({super.key, required this.akteId, this.zurueck});

  final String akteId;

  /// Wohin „Zurück“ führt: dorthin, woher man kam (Detektei oder Akte); ohne Angabe die Akte.
  final String? zurueck;

  @override
  State<DruckmappeSeite> createState() => _DruckmappeSeiteState();
}

class _DruckmappeSeiteState extends State<DruckmappeSeite> {
  KammerGrundlage? _grundlage;
  bool _fehler = false;
  bool _bereit = false;

  /// Personen am Tisch (Rollen, Detektiv und Erzähler); steht nach dem Laden fest.
  int? _personen;
  String _detektiv = 'w';

  /// Spielernamen der Gästeliste je Kanon-Figur, für „Senden an …“.
  Map<String, String> _spieler = const {};

  /// Der Kontext der aktuellen Einstellungen; ändern sie sich, entsteht er neu.
  KammerKontext? _kontext;

  /// Nur Akten mit Kammerspiel haben eine Druckmappe.
  late final bool _mitKammerspiel = hatKammerspiel(widget.akteId);

  /// Titel und Platz der Akte für die Mappe; ohne Kampagne bleibt die Mappe schlicht.
  late final Future<List<AkteInfo>> _akten = AktenKatalog.laden().catchError((Object _) => const <AkteInfo>[]);

  @override
  void initState() {
    super.initState();
    if (_mitKammerspiel) _laden();
  }

  Future<void> _laden() async {
    if (_fehler) setState(() => _fehler = false);
    try {
      final g = await kammerGrundlageLaden(rootBundle);
      if (!mounted) return;
      final gaeste = context.read<MetaStore>().gaesteliste(widget.akteId);
      setState(() {
        _grundlage = g;
        _personen = kammerPersonenVorgabe(g.inhalt.fall, gaeste.personen);
        _spieler = gaeste.namenJeFigur;
      });
    } catch (e, st) {
      debugPrint('DRUCKMAPPE laden fehler $e\n$st');
      if (mounted) setState(() => _fehler = true);
    }
  }

  /// Der Kontext für Personenzahl und Detektiv; `null`, solange der Inhalt lädt.
  KammerKontext? _kontextJetzt() {
    final g = _grundlage, n = _personen;
    if (g == null || n == null) return null;
    final k = _kontext;
    if (k != null && k.personen == n && k.detektiv == _detektiv) return k;
    return _kontext = KammerKontext(g.inhalt, personen: n, stil: g.stil, detektiv: _detektiv, spieler: _spieler);
  }

  void _setzePersonen(int n) {
    final f = _grundlage!.inhalt.fall;
    setState(() => _personen = n.clamp(f.personenMin, f.personenMax).toInt());
  }

  /// Die Dateien; nach „Druckmappe vorbereiten“ rollt die Seite zu ihnen.
  final _tafel = GlobalKey();

  void _vorbereiten() {
    setState(() => _bereit = true);
    // Am kleinen Handy füllt der Deckel mit den Schritten den Bildschirm: Ohne Rollen
    // sähe man keine Datei, obwohl Schritt 3 sie antippen lässt.
    final ruhig = MediaQuery.disableAnimationsOf(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tafel = _tafel.currentContext;
      if (!mounted || tafel == null) return;
      Scrollable.ensureVisible(tafel, duration: ruhig ? Duration.zero : const Duration(milliseconds: 300), curve: Curves.easeOut);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final k = _kontextJetzt();
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
                onPressed: () => context.go(widget.zurueck ?? Routes.akteVon(widget.akteId)),
              ),
              if (!_bereit && k != null)
                MKnopf(
                  text: l.detektei_druck_vorbereiten,
                  icon: Icons.print_rounded,
                  // Schritt 2 der Anleitung nennt ihn: auch am kleinen Handy mit großer Schrift ganz.
                  ganzeWorte: true,
                  onPressed: _vorbereiten,
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
                if (!_mitKammerspiel)
                  MBlatt(
                    art: PapierArt.notiz,
                    neigung: -0.006,
                    child: Text(l.detektei_druck_keine, style: MPapierSchrift.text),
                  )
                else if (_fehler)
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
                else if (k == null)
                  Text(l.abend_laedt, style: MSchrift.von(context).leise)
                else if (_bereit)
                  KammerTafel(key: _tafel, kontext: k)
                else ...[
                  _PersonenTafel(kontext: k, onPersonen: _setzePersonen),
                  _DetektivTafel(detektiv: _detektiv, onWahl: (w) => setState(() => _detektiv = w)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Personen am Tisch (6 bis 20) per Regler, darunter, was die Zahl bedeutet
/// („8 Rollen, Detektiv und Erzähler“, aus der Besetzung). Im Stil der
/// Einrichtung eines Abends; deren Personen-Abschnitt zählt Rollen der App mit
/// Namensfeldern und passt nicht zum Kammerspiel.
class _PersonenTafel extends StatelessWidget {
  const _PersonenTafel({required this.kontext, required this.onPersonen});

  final KammerKontext kontext;
  final ValueChanged<int> onPersonen;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final f = kontext.fall;
    final n = kontext.personen;
    return EinrichtungsTafel(
      ueberschrift: l.detektei_druck_personen,
      kinder: [
        GanzeWorte(l.detektei_druck_personen_anzahl('$n'), style: MPapierSchrift.ueberschrift, textAlign: TextAlign.center),
        const SizedBox(height: MMass.s4),
        Row(
          children: [
            _Stellknopf(
              tooltip: l.detektei_druck_personen_weniger,
              icon: Icons.remove_circle_outline,
              onPressed: n > f.personenMin ? () => onPersonen(n - 1) : null,
            ),
            Expanded(
              child: MPapierRegler(
                child: Slider(
                  value: n.toDouble(),
                  min: f.personenMin.toDouble(),
                  max: f.personenMax.toDouble(),
                  divisions: f.personenMax - f.personenMin,
                  onChanged: (v) => onPersonen(v.round()),
                ),
              ),
            ),
            _Stellknopf(
              tooltip: l.detektei_druck_personen_mehr,
              icon: Icons.add_circle_outline,
              onPressed: n < f.personenMax ? () => onPersonen(n + 1) : null,
            ),
          ],
        ),
        const SizedBox(height: MMass.s8),
        GanzeWorte(l.detektei_druck_personen_rollen('${kontext.besetzung.rollen}'), style: MPapierSchrift.leise, textAlign: TextAlign.center),
      ],
    );
  }
}

/// Detektiv oder Detektivin: Ankreuzfelder wie in der Einrichtung eines Abends.
class _DetektivTafel extends StatelessWidget {
  const _DetektivTafel({required this.detektiv, required this.onWahl});

  final String detektiv;
  final ValueChanged<String> onWahl;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return EinrichtungsTafel(
      ueberschrift: l.detektei_druck_detektiv,
      kinder: [
        MAnkreuzWahl<String>(
          optionen: [('m', l.detektei_druck_detektiv_m), ('w', l.detektei_druck_detektiv_w)],
          gewaehlt: detektiv,
          onWahl: onWahl,
        ),
      ],
    );
  }
}

/// Kleiner Stellknopf (eine Person weniger oder mehr) in Tinte.
class _Stellknopf extends StatelessWidget {
  const _Stellknopf({required this.tooltip, required this.icon, required this.onPressed});

  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: Icon(icon),
        iconSize: 28,
        color: MRoh.tinte,
        disabledColor: MRoh.tinte.withValues(alpha: 0.25),
        highlightColor: MRoh.tinte.withValues(alpha: 0.08),
      );
}

/// Die Mappe der Druckfassung: Reiter „Akte Nr. 0X“, Formularkopf mit dem Titel
/// der Akte, „Druckmappe“ in Playfair und die Anleitung in Tinte.
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
        reiter: index < 0 ? l.detektei_akte_druckmappe : l.case_file_no(akteNummer(index)),
        farbe: AkteStil.fuer(akteId).akzent,
        siegel: akte == null ? null : akteSigel(akte),
        // Höchstens zwei Blätter: weitere schöben sich auf breiten Mappen über den Reiter.
        blaetter: mappenBlaetter(aussen.maxWidth),
        neigung: -0.003,
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 26),
        child: LayoutBuilder(
          builder: (context, box) {
            // Der Drucker steht neben dem Text, solange daneben noch Platz für ganze Wörter bleibt.
            final skala = MediaQuery.textScalerOf(context).scale(1);
            final drucker = box.maxWidth - 42 >= 200 * skala;
            final text = Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (akte != null) ...[
                  // Formularkopf wie MBlattKopf, aber ohne Wortbruch bei großer Schrift.
                  GanzeWorte(akte.titel, style: MPapierSchrift.zwischentitel.copyWith(color: MFarben.von(context).akzent)),
                  const SizedBox(height: MMass.s4),
                  Container(height: 1, color: MFarben.von(context).linieStark),
                  const SizedBox(height: 10),
                ],
                Semantics(header: true, child: GanzeWorte(l.detektei_druck_titel, style: MPapierSchrift.titel)),
                const SizedBox(height: MMass.s12),
                GanzeWorte(l.detektei_druck_hinweis, style: MPapierSchrift.text),
              ],
            );
            if (!drucker) return text;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: text),
                const SizedBox(width: MMass.s12),
                const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Icon(Icons.print_rounded, size: 30, color: MRoh.tinteLeise),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
