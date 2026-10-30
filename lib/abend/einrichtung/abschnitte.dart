import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/mordakte_core.dart' as kern show abendMinutenCa;
import 'package:mordakte_core/runden.dart' show Sitz;

import '../../l10n/gen/app_localizations_de.dart';
import '../../l10n/lookup.dart';
import '../../meta/gaesteliste.dart';
import '../../party/sitzung.dart';
import '../../stil/mappe/assistent_formular.dart';
import '../../stil/stil.dart';

/// Texte der neuen Abschnitte: aus der Lokalisierung, sonst deutsch (der alte
/// Einrichtungsbildschirm `/party` läuft auch ohne Lokalisierung im Baum).
L _texte(BuildContext context) => Localizations.of<L>(context, L) ?? _de;
final _de = LDe();

/// Fall-Code: Zufall (Vorgabe) oder eigene Eingabe.
enum CodeWahl { zufall, eingabe }

/// Bildschirmspiel (Vorgabe) oder Druckfassung als PDF.
enum Spielart { bildschirm, druck }

/// Rundendauern zur Wahl, in Minuten, für Akten ohne den Zusatz
/// `langfassung` (unverändert seit vor M7b). Akten mit dem Zusatz bieten die
/// Dauern ihrer Fassung an ([Abendfassung.minutenOptionen]).
const einrichtungMinuten = [20, 30, 45, 60];

/// Alle Eingaben der Einrichtung eines Abends: Personen und Spielernamen,
/// Name des Detektivs, Rollen am Tisch (Erzähler bzw. eigener Platz online),
/// Detektiv oder Detektivin, Fall-Code, Bildschirm- oder
/// Druckspiel, Rundendauer, Erzählerstimme und Erzähltiefe. Der Assistent für neue Abende
/// und der alte Einrichtungsbildschirm teilen sich diese Werte und die
/// Abschnitte darunter; [starten] richtet den Abend ein.
///
/// Zwei Eigenschaften der Akte schränken die Wahl ein: Eine Druckfassung gibt es
/// nur für Akten mit Druckmappe ([druckbar]), und eine Akte mit fester Lösung
/// ([festeLoesung]) kennt keinen Fall-Code.
///
/// Akten mit dem Zusatz `langfassung` ([langfassung], M7b) bieten dazu den
/// kurzen oder langen Abend an ([fassung]), die Rundendauern der Fassung
/// ([minutenOptionen]) und die geschätzte Abendlänge ([abendMinutenCa]).
/// Alle anderen Akten bleiben, wie sie waren.
class EinrichtungsWerte extends ChangeNotifier {
  /// [druckbar]: Die Akte hat eine Druckmappe (`AkteInfo.druckbar`). Ohne Angabe
  /// gilt sie als druckbar (alter Einrichtungsbildschirm, Druckmappe).
  /// [gaeste]: Gästeliste der Akte (M5) für Personenzahl und Namen; ihr
  /// Detektiv-Eintrag füllt [detektivName] vor (reihum und online).
  EinrichtungsWerte(this.sitzung, {this.druckbar = true, GaesteListe gaeste = const GaesteListe()})
      : rollen = (gaeste.personen ?? 7).clamp(sitzung.minRollen, sitzung.maxRollen).toInt(),
        minuten = sitzung.daten.hat('langfassung') ? Abendfassung.kurz.standardMinuten : 30,
        _gaeste = gaeste.namenJeFigur,
        detektivName = TextEditingController(text: gaeste.namenJeFigur[Besetzung.detektiv]);

  final PartySitzung sitzung;

  /// Gibt es für diese Akte eine Druckfassung? Sonst bleibt es beim Bildschirmspiel.
  final bool druckbar;

  /// Akte mit fester Lösung (ein einziger Pfad): ein Fall-Code ändert den Täter nicht.
  bool get festeLoesung => sitzung.daten.kanon.festeLoesung;

  int rollen;
  String detektiv = 'w';
  CodeWahl codeWahl = CodeWahl.zufall;
  Spielart spielart = Spielart.bildschirm;

  /// Rundendauer in Minuten (eine der [minutenOptionen]).
  int minuten;
  bool stimme = false;

  /// Kurzer oder langer Abend; lang nur bei [langfassung] und nie im Druckspiel.
  Abendfassung fassung = Abendfassung.kurz;

  /// Gespräche mit Zeugen (M6); nur bei Akten, die welche haben.
  Erzaehltiefe erzaehltiefe = Erzaehltiefe.voll;
  bool _solo = false;

  /// Name des Detektivs (im Solo das Namensfeld).
  final TextEditingController detektivName;

  /// Früherer Name von [detektivName] (vor Langer Abend M3).
  @Deprecated('detektivName')
  TextEditingController get geburtstag => detektivName;

  /// Name des Erzählers beim Spiel an einem Gerät (optional; leer: kein Erzähler).
  final erzaehlerName = TextEditingController();

  /// Platz des Gastgebers am Online-Abend: Detektiv (Vorgabe) oder Erzähler.
  Sitz platz = Sitz.detektiv;
  final code = TextEditingController();

  /// Spielernamen je Rolle. Die Felder bleiben erhalten, wenn sich die Anzahl ändert.
  final Map<String, TextEditingController> _namen = {};

  /// Haken der Gästeliste (M5): Figur → Name. Erscheint eine Rolle zum ersten
  /// Mal in [PersonenAbschnitt], steht ihr Gast schon im Namensfeld.
  final Map<String, String> _gaeste;

  /// Solo mit Bots (kein Druckspiel, keine Spielernamen).
  bool get solo => _solo;

  set solo(bool wert) {
    _solo = wert;
    if (wert) spielart = Spielart.bildschirm;
    notifyListeners();
  }

  /// Startbereit: Zufall gilt immer (auch bei fester Lösung, dort gibt es keine
  /// Eingabe), eine Eingabe nur, wenn sie ein Fall-Code ist.
  bool get codeOk => festeLoesung || codeWahl == CodeWahl.zufall || FallCode.lesen(code.text) != null;

  /// Eingegeben, aber kein Fall-Code. Eine leere Eingabe ist noch keine Fehlermeldung.
  bool get codeFalsch =>
      !festeLoesung && codeWahl == CodeWahl.eingabe && code.text.trim().isNotEmpty && FallCode.lesen(code.text) == null;

  /// Der eingegebene Fall-Code oder `null` für Zufall (immer `null` bei fester Lösung).
  String? get codeEingabe => !festeLoesung && codeWahl == CodeWahl.eingabe ? code.text : null;

  /// Wird gedruckt? Nur reihum und nur, wenn die Akte eine Druckfassung hat.
  bool get druck => !_solo && druckbar && spielart == Spielart.druck;

  /// Gibt es Rollen am Tisch zu verteilen (Erzähler)? Nie im Solo und nur in
  /// Akten mit Erzähler-Sitz ([PartyDaten.mitErzaehlerSitz]).
  bool get mitErzaehler => !_solo && sitzung.daten.mitErzaehlerSitz;

  void setzePlatz(Sitz wert) {
    platz = wert == Sitz.erzaehler && mitErzaehler ? Sitz.erzaehler : Sitz.detektiv;
    notifyListeners();
  }

  /// Rolle, deren Porträt zum Tausch der Namen angetippt ist (reihum).
  String? get tauschWahl => _tausch;
  String? _tausch;

  /// Porträt angetippt: das erste merkt sich die Rolle, das zweite tauscht die
  /// Namen beider Rollen; noch einmal dasselbe hebt die Wahl auf.
  void tippePortraet(String rolle) {
    final erste = _tausch;
    if (erste == null) {
      _tausch = rolle;
    } else if (erste == rolle) {
      _tausch = null;
    } else {
      final a = namenFeld(erste), b = namenFeld(rolle);
      final zwischen = a.text;
      a.text = b.text;
      b.text = zwischen;
      _tausch = null;
    }
    notifyListeners();
  }

  TextEditingController namenFeld(String rolle) => _namen.putIfAbsent(rolle, () => TextEditingController(text: _gaeste[rolle]));

  /// Anzahl der Personen; die Grenzen kommen aus der Besetzung.
  void setzeRollen(int n) {
    rollen = n.clamp(sitzung.minRollen, sitzung.maxRollen).toInt();
    if (_tausch != null && !sitzung.rollenBei(rollen).contains(_tausch)) _tausch = null;
    notifyListeners();
  }

  /// Eine Eingabe hat sich geändert (z. B. der Fall-Code): Abschnitte neu zeichnen.
  void melde() => notifyListeners();

  void setzeDetektiv(String wert) {
    detektiv = wert;
    notifyListeners();
  }

  void setzeCodeWahl(CodeWahl wert) {
    codeWahl = wert;
    notifyListeners();
  }

  void setzeSpielart(Spielart wert) {
    spielart = druckbar ? wert : Spielart.bildschirm;
    // Die Druckfassung ist ein kurzer Abend auf Papier.
    if (druck) _fassungSetzen(Abendfassung.kurz);
    notifyListeners();
  }

  /// Bietet die Akte den langen Abend an (Zusatz `langfassung`)?
  bool get langfassung => sitzung.daten.hat('langfassung');

  /// Kurzer oder langer Abend. Passt die gewählte Rundendauer nicht zur neuen
  /// Fassung, gilt deren Vorgabe. Ohne [langfassung] und im Druckspiel bleibt
  /// es beim kurzen Abend.
  void setzeFassung(Abendfassung wert) {
    _fassungSetzen(langfassung && !druck ? wert : Abendfassung.kurz);
    notifyListeners();
  }

  void _fassungSetzen(Abendfassung wert) {
    fassung = wert;
    if (!minutenOptionen.contains(minuten)) minuten = wert.standardMinuten;
  }

  /// Rundendauern zur Wahl: die der Fassung bei [langfassung], sonst wie bisher.
  List<int> get minutenOptionen => langfassung ? fassung.minutenOptionen : einrichtungMinuten;

  /// Geschätzte Länge des ganzen Abends in Minuten („ca. X Min.“, K-18), nur
  /// bei [langfassung]; sonst `null` (Altakten zeigen keine Schätzung). Mit
  /// Einstimmung kommt ihre Dauer bei [rollen] Rollen dazu ([einstimmungRollen]).
  int? get abendMinutenCa => langfassung ? kern.abendMinutenCa(fassung, minuten, einstimmungRollen: einstimmungRollen) : null;

  // Einstimmung (A-063): Vorgeschichte und Vorstellung vor dem Auftakt.

  /// Hat die Akte eine Einstimmung (Zusatz `einstimmung`)?
  bool get hatEinstimmung => sitzung.daten.einstimmung != null;

  bool? _einstimmung;

  /// Schalter „Vorgeschichte und Vorstellung“: Vorgabe an, im Druckspiel aus,
  /// bis jemand ihn umlegt.
  bool get einstimmung => _einstimmung ?? !druck;

  /// Spielt der Abend die Einstimmung (Akte mit Einstimmung und Schalter an)?
  bool get einstimmungAn => hatEinstimmung && einstimmung;

  /// Rollenzahl für die Zeitschätzung der Einstimmung (`null`: ohne).
  int? get einstimmungRollen => einstimmungAn ? rollen : null;

  void setzeEinstimmung(bool wert) {
    _einstimmung = wert;
    notifyListeners();
  }

  void setzeMinuten(int wert) {
    minuten = wert;
    notifyListeners();
  }

  void setzeStimme(bool wert) {
    stimme = wert;
    notifyListeners();
  }

  void setzeErzaehltiefe(Erzaehltiefe wert) {
    erzaehltiefe = wert;
    notifyListeners();
  }

  /// Hat die Akte Gespräche mit Zeugen?
  bool get hatGespraeche => sitzung.daten.erzaehlung != null;

  // „Dein Moment“ (Finale §3): Standard an bei Akten mit Regeln, nie im Druckspiel.

  /// Kennt die Akte „Dein Moment“ (Zusatz `einfluss` mit Regeln)?
  bool get einflussMoeglich => sitzung.daten.einfluss != null;

  /// Gewünscht (Schalter); wirksam nur mit [einflussMoeglich] und ohne Druckspiel ([einflussAn]).
  late bool einfluss = einflussMoeglich;

  /// Spielt der Abend „Dein Moment“?
  bool get einflussAn => einflussMoeglich && einfluss && !druck;

  void setzeEinfluss(bool wert) {
    einfluss = wert;
    notifyListeners();
  }

  /// Richtet den Abend ein und setzt danach Erzählerstimme und Erzähltiefe.
  /// [druckErzwingen] stellt eine Druckfassung ein (Druckmappe einer Akte).
  void starten({bool druckErzwingen = false}) {
    final s = sitzung;
    final namen = <String, String>{};
    if (!_solo) {
      for (final r in s.rollenBei(rollen)) {
        final name = namenFeld(r).text.trim();
        if (name.isNotEmpty) namen[r] = name;
      }
    }
    s.einrichten(
      rollen: rollen,
      detektiv: detektiv,
      code: codeEingabe,
      druck: !_solo && (druckErzwingen || druck),
      solo: _solo,
      rundendauerMinuten: minuten,
      namen: namen,
      detektivName: detektivName.text.trim(),
      erzaehlerName: mitErzaehler ? erzaehlerName.text.trim() : '',
      fassung: langfassung && !druck && !druckErzwingen ? fassung : Abendfassung.kurz,
      einstimmung: einstimmungAn,
      einfluss: einflussAn && !druckErzwingen,
    );
    s.stimmeAn = stimme;
    s.erzaehltiefe = erzaehltiefe;
  }

  @override
  void dispose() {
    detektivName.dispose();
    erzaehlerName.dispose();
    code.dispose();
    for (final c in _namen.values) {
      c.dispose();
    }
    super.dispose();
  }
}

/// Ein Abschnitt des Formulars: Formularkopf in roter Schreibmaschine über einer
/// Tintenlinie, darunter die Felder.
///
/// Liegt die Tafel schon auf Papier (im Formular [EinrichtungsAbschnitte]), ist
/// sie ein Abschnitt dieses Blatts; allein liegt sie als eigenes Blatt auf dem
/// Schreibtisch. Ihr Inhalt steht in jedem Fall auf Papier und trägt Tinte.
class EinrichtungsTafel extends StatelessWidget {
  const EinrichtungsTafel({super.key, required this.ueberschrift, required this.kinder});

  final String ueberschrift;
  final List<Widget> kinder;

  @override
  Widget build(BuildContext context) {
    final abschnitt = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        MFormkopf(ueberschrift.toUpperCase()),
        const SizedBox(height: MMass.s4),
        Container(height: 1, color: MRoh.tinte.withValues(alpha: 0.3)),
        const SizedBox(height: MMass.s12),
        ...kinder,
      ],
    );
    if (MFlaeche.hellVon(context)) {
      return Padding(padding: const EdgeInsets.only(bottom: MMass.s24), child: abschnitt);
    }
    final samen = ueberschrift.codeUnits.fold(5, (a, b) => (a * 31 + b) & 0xffff);
    return Padding(
      padding: const EdgeInsets.only(bottom: MMass.s16),
      child: MBlatt(
        samen: samen,
        neigung: samen.isEven ? -0.003 : 0.003,
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
        child: abschnitt,
      ),
    );
  }
}

/// Basis der Abschnitte: hört auf die [werte] und baut bei jeder Änderung neu.
/// Der Inhalt liegt immer auf Papier ([EinrichtungsTafel]), darum stehen hier
/// nur Tintenstile ([MPapierSchrift]).
abstract class _Abschnitt extends StatelessWidget {
  const _Abschnitt({super.key, required this.werte});

  final EinrichtungsWerte werte;

  PartySitzung get s => werte.sitzung;

  Widget baue(BuildContext context);

  @override
  Widget build(BuildContext context) => ListenableBuilder(listenable: werte, builder: (context, _) => baue(context));
}

/// Alle Abschnitte in der festen Reihenfolge des Einrichtungsbildschirms, als ein
/// Formularblatt mit Büroklammer. Im Solo-Spiel entfallen Druckfassung und
/// Rundendauer. Im Online-Abend ([online]: jeder am eigenen Gerät) entfallen
/// Personenzahl und Spielnamen (die Lobby legt die Rollen fest) und die
/// Druckfassung. Die Druckfassung gibt es nur für druckbare Akten
/// ([EinrichtungsWerte.druckbar]). Bei einer Akte mit fester Lösung ersetzt ein
/// Hinweis den Fall-Code.
class EinrichtungsAbschnitte extends StatelessWidget {
  const EinrichtungsAbschnitte({super.key, required this.werte, this.online = false});

  final EinrichtungsWerte werte;
  final bool online;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: werte,
        builder: (context, _) => MBlatt(
          klammer: true,
          samen: 41,
          neigung: -0.002,
          padding: const EdgeInsets.fromLTRB(20, 30, 20, 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!online) PersonenAbschnitt(werte: werte),
              DetektivNameAbschnitt(werte: werte),
              if (werte.mitErzaehler) RollenAmTischAbschnitt(werte: werte, online: online),
              DetektivAbschnitt(werte: werte),
              FallAbschnitt(werte: werte, online: online),
              if (!werte.solo && !online && werte.druckbar) SpielartAbschnitt(werte: werte),
              // Kurzer oder langer Abend (M7b): nur Akten mit Langfassung, auch im Solo und online.
              if (werte.langfassung && !werte.druck) FassungAbschnitt(werte: werte),
              // Vorgeschichte und Vorstellung (A-063): nur Akten mit Einstimmung, auch im Solo und online.
              if (werte.hatEinstimmung) EinstimmungAbschnitt(werte: werte),
              // „Dein Moment“ (Finale §3): nur Akten mit Regeln, nie im Druckspiel.
              if (werte.einflussMoeglich && !werte.druck) MomentAbschnitt(werte: werte),
              if (!werte.solo) DauerAbschnitt(werte: werte),
              // Online richtet der Raum den Abend ein; dort gilt die Vorgabe.
              if (werte.hatGespraeche && !online) ErzaehltiefeAbschnitt(werte: werte),
              StimmeAbschnitt(werte: werte),
            ],
          ),
        ),
      );
}

/// Anzahl der Personen per Regler und die besetzten Rollen mit Fotoabzug und
/// Namensfeld.
class PersonenAbschnitt extends _Abschnitt {
  const PersonenAbschnitt({super.key, required super.werte});

  @override
  Widget baue(BuildContext context) {
    final solo = werte.solo;
    final n = werte.rollen;
    final rollen = s.rollenBei(n);
    return EinrichtungsTafel(
      ueberschrift: s.ui(solo ? 'ui.solo.rollen' : 'ui.einrichtung.personen'),
      kinder: [
        Text(
          s.ui(solo ? 'ui.solo.rollen_anzahl' : 'ui.einrichtung.anzahl', {'anzahl': '$n'}),
          style: MPapierSchrift.ueberschrift,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: MMass.s4),
        Row(
          children: [
            _Stellknopf(
              tooltip: s.ui('ui.einrichtung.weniger'),
              icon: Icons.remove_circle_outline,
              onPressed: n > s.minRollen ? () => werte.setzeRollen(n - 1) : null,
            ),
            Expanded(
              child: MPapierRegler(
                child: Slider(
                  value: n.toDouble(),
                  min: s.minRollen.toDouble(),
                  max: s.maxRollen.toDouble(),
                  divisions: s.maxRollen - s.minRollen,
                  onChanged: (v) => werte.setzeRollen(v.round()),
                ),
              ),
            ),
            _Stellknopf(
              tooltip: s.ui('ui.einrichtung.mehr'),
              icon: Icons.add_circle_outline,
              onPressed: n < s.maxRollen ? () => werte.setzeRollen(n + 1) : null,
            ),
          ],
        ),
        const SizedBox(height: MMass.s8),
        Text(s.ui(solo ? 'ui.solo.rollen_hinweis' : 'ui.einrichtung.namen_hinweis'), style: MPapierSchrift.leise),
        // Reihum: Wer welche Figur spielt, tauscht man über die Porträts.
        if (!solo) Text(_texte(context).abend_tausch_hinweis, key: const ValueKey('tausch-hinweis'), style: MPapierSchrift.leise),
        const SizedBox(height: MMass.s16),
        for (var i = 0; i < rollen.length; i++) _rollenZeile(rollen[i], i),
      ],
    );
  }

  /// Fotoabzug einer Rolle. Reihum ist er eine Tippfläche: Zwei Porträts
  /// nacheinander antippen tauscht die Namen beider Rollen
  /// ([EinrichtungsWerte.tippePortraet]); das erste liegt bis dahin rot umrandet.
  /// Im Solo bleibt das Bild für den Bildschirmleser stumm.
  Widget _portraet(BuildContext context, String rolle, int nr) {
    final foto = MFotoabzug(
      look: s.figurAussehen(rolle),
      groesse: _foto,
      neigung: nr.isEven ? -0.05 : 0.04,
      akzent: s.figurFarbe(rolle),
    );
    if (werte.solo) return ExcludeSemantics(child: foto);
    final gewaehlt = werte.tauschWahl == rolle;
    final l = _texte(context);
    return Semantics(
      button: true,
      selected: gewaehlt,
      label: l.abend_tausch_portraet(s.figurName(rolle)),
      excludeSemantics: true,
      onTap: () => werte.tippePortraet(rolle),
      child: GestureDetector(
        key: ValueKey('portraet-$rolle'),
        behavior: HitTestBehavior.opaque,
        onTap: () => werte.tippePortraet(rolle),
        child: Container(
          constraints: const BoxConstraints(minWidth: MMass.tippflaeche, minHeight: MMass.tippflaeche),
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: gewaehlt ? MRoh.stempelRot : Colors.transparent, width: 2),
          ),
          child: foto,
        ),
      ),
    );
  }

  /// Eine besetzte Rolle: Fotoabzug, Figur und Feld für den Spielernamen. Auf
  /// schmalen Bildschirmen und bei großer Schrift steht das Feld unter Figur und
  /// Titel; sonst bliebe dem Titel kaum Platz und Wörter bräche es mitten durch.
  Widget _rollenZeile(String rolle, int nr) => Padding(
        key: ValueKey('rolle-$rolle'),
        padding: const EdgeInsets.only(bottom: MMass.s12),
        child: LayoutBuilder(
          builder: (context, box) {
            final skala = MediaQuery.textScalerOf(context).scale(1);
            final untereinander = box.maxWidth < 400 * (skala < 1 ? 1 : skala);
            // Sehr schmal mit großer Schrift: der Titel der Figur steht unter Bild und Name.
            final eng = box.maxWidth < 200 * (skala < 1 ? 1 : skala);
            final titel = MWortfest(s.figurTitel(rolle), style: MPapierSchrift.leise);
            final feld = _Formularzeile(
              feldKey: ValueKey('name-$rolle'),
              controller: werte.namenFeld(rolle),
              platzhalter: s.ui('ui.einrichtung.name_feld'),
            );
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    _portraet(context, rolle, nr),
                    const SizedBox(width: MMass.s16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.figurName(rolle), style: MPapierSchrift.ueberschrift.copyWith(fontSize: 17, height: 1.3)),
                          if (!eng) titel,
                        ],
                      ),
                    ),
                    if (!werte.solo && !untereinander) ...[
                      const SizedBox(width: MMass.s12),
                      SizedBox(width: 160, child: feld),
                    ],
                  ],
                ),
                if (eng) Padding(padding: const EdgeInsets.only(top: MMass.s4), child: titel),
                if (!werte.solo && untereinander)
                  Padding(
                    // Unter dem Text der Figur: Breite des Fotoabzugs (Bild und Rand) plus Abstand.
                    padding: EdgeInsets.only(left: eng ? 0 : _foto + 16 + MMass.s16, top: MMass.s4),
                    child: feld,
                  ),
              ],
            );
          },
        ),
      );
}

/// Kantenlänge der Fotoabzüge in der Besetzung.
const _foto = 44.0;

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

/// Eingabezeile des Formulars: Schreibmaschine auf einer Tintenlinie.
class _Formularzeile extends StatelessWidget {
  const _Formularzeile({
    required this.feldKey,
    required this.controller,
    required this.platzhalter,
    this.code = false,
    this.onChanged,
  });

  final Key? feldKey;
  final TextEditingController controller;
  final String platzhalter;

  /// Fall-Code: groß, gesperrt gesetzt, nur Großbuchstaben.
  final bool code;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) => TextField(
        key: feldKey,
        controller: controller,
        textCapitalization: code ? TextCapitalization.characters : TextCapitalization.words,
        inputFormatters: code ? [const Grossbuchstaben(), LengthLimitingTextInputFormatter(FallCode.laenge)] : null,
        onChanged: onChanged,
        cursorColor: MRoh.tinteBlau,
        style: code ? MPapierSchrift.maschine.copyWith(fontSize: 22, letterSpacing: 4) : MPapierSchrift.maschine.copyWith(fontSize: 17),
        decoration: einrichtungFeld(context, platzhalter),
      );
}

/// Name des Detektivs. Die Überschrift kommt je Akte aus dem Baustein
/// `ui.einrichtung.geburtstag` (Schlosskeller „Name des Detektivs“, Noir „Der
/// Inspektor“); im Solo-Spiel ist es das Namensfeld des Detektivs.
class DetektivNameAbschnitt extends _Abschnitt {
  const DetektivNameAbschnitt({super.key, required super.werte});

  @override
  Widget baue(BuildContext context) {
    final solo = werte.solo;
    return EinrichtungsTafel(
      ueberschrift: s.ui(solo ? 'ui.solo.name' : 'ui.einrichtung.geburtstag'),
      kinder: [
        _Formularzeile(
          feldKey: const ValueKey('detektiv-name'),
          controller: werte.detektivName,
          platzhalter: s.ui(solo ? 'ui.solo.name_feld' : 'ui.einrichtung.geburtstag_feld'),
        ),
      ],
    );
  }
}

/// Früherer Name von [DetektivNameAbschnitt] (vor Langer Abend M3).
@Deprecated('DetektivNameAbschnitt')
typedef GeburtstagAbschnitt = DetektivNameAbschnitt;

/// Rollen am Tisch (Langer Abend M3, nie im Solo, nur Akten mit Erzähler-Sitz):
/// An einem Gerät der Name des Erzählers (optional; leer heißt ohne Erzähler).
/// Online ([online]) „Dein Platz“: Detektiv oder Erzähler; den anderen Sitz
/// vergibt die Lobby an einen Gast.
class RollenAmTischAbschnitt extends _Abschnitt {
  const RollenAmTischAbschnitt({super.key, required super.werte, this.online = false});

  final bool online;

  @override
  Widget baue(BuildContext context) {
    final l = _texte(context);
    return EinrichtungsTafel(
      ueberschrift: l.abend_rollen_titel,
      kinder: online
          ? [
              Text(l.abend_platz_titel, style: MPapierSchrift.leise),
              const SizedBox(height: MMass.s4),
              MAnkreuzWahl<Sitz>(
                optionen: [(Sitz.detektiv, l.abend_platz_detektiv), (Sitz.erzaehler, l.abend_platz_erzaehler)],
                gewaehlt: werte.platz,
                onWahl: werte.setzePlatz,
              ),
              const SizedBox(height: MMass.s8),
              Text(
                werte.platz == Sitz.erzaehler ? l.abend_platz_hinweis_erzaehler : l.abend_platz_hinweis_detektiv,
                key: const ValueKey('platz-hinweis'),
                style: MPapierSchrift.leise,
              ),
            ]
          : [
              _Formularzeile(feldKey: const ValueKey('erzaehler-name'), controller: werte.erzaehlerName, platzhalter: l.abend_erzaehler_feld),
              const SizedBox(height: MMass.s8),
              Text(l.abend_erzaehler_hinweis, style: MPapierSchrift.leise),
              Text(l.abend_erzaehler_leer, style: MPapierSchrift.leise),
            ],
    );
  }
}

/// Detektiv oder Detektivin.
class DetektivAbschnitt extends _Abschnitt {
  const DetektivAbschnitt({super.key, required super.werte});

  @override
  Widget baue(BuildContext context) => EinrichtungsTafel(
        ueberschrift: s.ui('ui.einrichtung.detektiv'),
        kinder: [
          MAnkreuzWahl<String>(
            optionen: [('m', s.ui('ui.einrichtung.detektiv_m')), ('w', s.ui('ui.einrichtung.detektiv_w'))],
            gewaehlt: werte.detektiv,
            onWahl: werte.setzeDetektiv,
          ),
        ],
      );
}

/// Fall-Code: Zufall oder eigene Eingabe. Bei einer Akte mit fester Lösung
/// stattdessen der Hinweis [FesteLoesungHinweis] ([online]: Gastgeber im Raum).
class FallAbschnitt extends _Abschnitt {
  const FallAbschnitt({super.key, required super.werte, this.online = false});

  final bool online;

  @override
  Widget baue(BuildContext context) {
    if (werte.festeLoesung) return FesteLoesungHinweis(solo: werte.solo, online: online);
    return EinrichtungsTafel(
      ueberschrift: s.ui('ui.einrichtung.fall'),
      kinder: [
        MAnkreuzWahl<CodeWahl>(
          optionen: [(CodeWahl.zufall, s.ui('ui.einrichtung.code_zufall')), (CodeWahl.eingabe, s.ui('ui.einrichtung.code_eingabe'))],
          gewaehlt: werte.codeWahl,
          onWahl: werte.setzeCodeWahl,
        ),
        if (werte.codeWahl == CodeWahl.eingabe) ...[
          const SizedBox(height: MMass.s8),
          _Formularzeile(
            feldKey: const ValueKey('code'),
            controller: werte.code,
            platzhalter: s.ui('ui.einrichtung.code_feld'),
            code: true,
            onChanged: (_) => werte.melde(),
          ),
          if (werte.codeFalsch) ...[
            const SizedBox(height: 10),
            EinrichtungsFehler(s.ui('ui.einrichtung.code_fehler')),
          ],
        ],
        const SizedBox(height: MMass.s12),
        Text(s.ui('ui.einrichtung.code_hinweis'), style: MPapierSchrift.leise),
      ],
    );
  }
}

/// Hinweis für Akten mit fester Lösung: Ein Fall-Code ändert dort den Täter nicht,
/// darum entfällt die Code-Wahl. Der Text hängt von der Spielweise ab.
class FesteLoesungHinweis extends StatelessWidget {
  const FesteLoesungHinweis({super.key, this.solo = false, this.online = false});

  final bool solo;
  final bool online;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return EinrichtungsTafel(
      ueberschrift: l.abend_feste_loesung_titel,
      kinder: [
        Text(
          online
              ? l.abend_feste_loesung_online
              : (solo ? l.abend_feste_loesung_solo : l.abend_feste_loesung_hinweis),
          key: const ValueKey('feste-loesung'),
          style: MPapierSchrift.text,
        ),
      ],
    );
  }
}

/// Bildschirmspiel oder Druckfassung (nur reihum, nicht im Solo-Spiel). Bei der
/// Druckfassung steht der Hinweis, dass es die PDFs auch ohne Abend gibt (Akte →
/// „PDFs zum Ausdrucken“); nur als Text, damit die Einstellungen bleiben.
class SpielartAbschnitt extends _Abschnitt {
  const SpielartAbschnitt({super.key, required super.werte});

  @override
  Widget baue(BuildContext context) => EinrichtungsTafel(
        ueberschrift: s.ui('ui.einrichtung.spiel'),
        kinder: [
          MAnkreuzWahl<Spielart>(
            optionen: [
              (Spielart.bildschirm, s.ui('ui.einrichtung.spiel_bildschirm')),
              (Spielart.druck, s.ui('ui.einrichtung.spiel_druck')),
            ],
            gewaehlt: werte.spielart,
            onWahl: werte.setzeSpielart,
          ),
          if (werte.spielart == Spielart.druck) ...[
            const SizedBox(height: MMass.s8),
            Text(s.ui('ui.einrichtung.druck_hinweis'), style: MPapierSchrift.leise),
            const SizedBox(height: MMass.s4),
            Text(_texte(context).abend_druck_nur_pdfs, key: const ValueKey('nur-pdfs-hinweis'), style: MPapierSchrift.leise),
          ],
        ],
      );
}

/// Kurzer oder langer Abend (Langer Abend M7b), nur in Akten mit dem Zusatz
/// `langfassung`, auch im Solo und online. Jede Wahl nennt die Länge des Abends
/// bei der Vorgabe ihrer Rundendauer (K-18); im Solo ohne Zahl, denn die
/// Schätzung gilt für den Abend am Tisch.
class FassungAbschnitt extends _Abschnitt {
  const FassungAbschnitt({super.key, required super.werte});

  @override
  Widget baue(BuildContext context) {
    final l = _texte(context);
    String name(Abendfassung f) => f.istLang ? l.abend_fassung_lang : l.abend_fassung_kurz;
    String beschriftung(Abendfassung f) =>
        werte.solo ? name(f) : l.abend_fassung_mit_dauer(name(f), kern.abendMinutenCa(f, f.standardMinuten, einstimmungRollen: werte.einstimmungRollen));
    return EinrichtungsTafel(
      ueberschrift: l.abend_fassung_titel,
      kinder: [
        MAnkreuzWahl<Abendfassung>(
          optionen: [for (final f in Abendfassung.values) (f, beschriftung(f))],
          gewaehlt: werte.fassung,
          onWahl: werte.setzeFassung,
        ),
        const SizedBox(height: MMass.s8),
        Text(
          werte.fassung.istLang ? l.abend_fassung_hinweis_lang : l.abend_fassung_hinweis_kurz,
          key: const ValueKey('fassung-hinweis'),
          style: MPapierSchrift.leise,
        ),
      ],
    );
  }
}

/// Rundendauer (nicht im Solo). In Akten mit Langfassung die Dauern der
/// Fassung und darunter die Länge des ganzen Abends („ca. X Min.“); sonst wie
/// bisher.
class DauerAbschnitt extends _Abschnitt {
  const DauerAbschnitt({super.key, required super.werte});

  @override
  Widget baue(BuildContext context) {
    final ca = werte.abendMinutenCa;
    return EinrichtungsTafel(
      ueberschrift: s.ui('ui.einrichtung.dauer'),
      kinder: [
        MAnkreuzWahl<int>(
          optionen: [for (final m in werte.minutenOptionen) (m, s.ui('ui.einrichtung.minuten', {'minuten': '$m'}))],
          gewaehlt: werte.minuten,
          onWahl: werte.setzeMinuten,
        ),
        if (ca != null) ...[
          const SizedBox(height: MMass.s8),
          Text(_texte(context).abend_dauer_ca(ca), key: const ValueKey('abend-ca'), style: MPapierSchrift.leise),
          if (werte.fassung.istLang) Text(_texte(context).abend_dauer_lang_hinweis, key: const ValueKey('dauer-lang-hinweis'), style: MPapierSchrift.leise),
        ],
      ],
    );
  }
}

/// Einstimmung (A-063): Schalter „Vorgeschichte und Vorstellung“, nur in Akten
/// mit Einstimmung. Darunter, wie lange sie bei der gewählten Personenzahl
/// dauert ([abendEinstimmungMinuten]); die Schätzung des ganzen Abends
/// ([DauerAbschnitt]) rechnet sie mit.
class EinstimmungAbschnitt extends _Abschnitt {
  const EinstimmungAbschnitt({super.key, required super.werte});

  @override
  Widget baue(BuildContext context) {
    final l = _texte(context);
    final titel = l.abend_einstimmung_schalter;
    void umschalten() => werte.setzeEinstimmung(!werte.einstimmung);
    return EinrichtungsTafel(
      ueberschrift: l.abend_einstimmung_titel,
      kinder: [
        Semantics(
          toggled: werte.einstimmung,
          label: titel,
          hint: l.abend_einstimmung_hinweis,
          onTap: umschalten,
          excludeSemantics: true,
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              key: const ValueKey('einstimmung-schalter'),
              onTap: umschalten,
              splashFactory: NoSplash.splashFactory,
              highlightColor: MRoh.tinte.withValues(alpha: 0.06),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: MMass.s4),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(titel, style: MPapierSchrift.text),
                          const SizedBox(height: 2),
                          Text(l.abend_einstimmung_hinweis, style: MPapierSchrift.leise),
                        ],
                      ),
                    ),
                    const SizedBox(width: MMass.s12),
                    MSchalter(wert: werte.einstimmung, onChanged: werte.setzeEinstimmung, symbolAn: Icons.auto_stories_outlined, symbolAus: Icons.close_rounded),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (werte.einstimmung) ...[
          const SizedBox(height: MMass.s8),
          Text(
            l.abend_einstimmung_dauer(abendEinstimmungMinuten(werte.rollen).round()),
            key: const ValueKey('einstimmung-dauer'),
            style: MPapierSchrift.leise,
          ),
        ],
      ],
    );
  }
}

/// Gespräche mit Zeugen: keine, kurz (eine Wahl) oder ausführlich (ganze
/// Gespräche mit Folgen). Nur bei Akten mit Gesprächen.
class ErzaehltiefeAbschnitt extends _Abschnitt {
  const ErzaehltiefeAbschnitt({super.key, required super.werte});

  @override
  Widget baue(BuildContext context) {
    final l = L.of(context);
    return EinrichtungsTafel(
      ueberschrift: l.erzaehltiefe_titel,
      kinder: [
        MAnkreuzWahl<Erzaehltiefe>(
          optionen: [
            (Erzaehltiefe.aus, l.erzaehltiefe_aus),
            (Erzaehltiefe.kurz, l.erzaehltiefe_kurz),
            (Erzaehltiefe.voll, l.erzaehltiefe_voll),
          ],
          gewaehlt: werte.erzaehltiefe,
          onWahl: werte.setzeErzaehltiefe,
        ),
        const SizedBox(height: MMass.s8),
        Text(l.erzaehltiefe_hinweis, style: MPapierSchrift.leise),
      ],
    );
  }
}

/// Erzählerstimme an oder aus: Formularzeile mit Messing-Kippschalter. Ein Tipp
/// auf die ganze Zeile schaltet um.
class StimmeAbschnitt extends _Abschnitt {
  const StimmeAbschnitt({super.key, required super.werte});

  @override
  Widget baue(BuildContext context) {
    final titel = s.ui('ui.einrichtung.stimme_schalter');
    final hinweis = s.ui('ui.einrichtung.stimme_hinweis');
    void umschalten() => werte.setzeStimme(!werte.stimme);
    return EinrichtungsTafel(
      ueberschrift: s.ui('ui.einrichtung.stimme'),
      kinder: [
        Semantics(
          toggled: werte.stimme,
          label: titel,
          hint: hinweis,
          onTap: umschalten,
          excludeSemantics: true,
          // Eigene durchsichtige Fläche: der Druckschatten liegt auf dem Papier, nicht unter ihm.
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: umschalten,
              splashFactory: NoSplash.splashFactory,
              highlightColor: MRoh.tinte.withValues(alpha: 0.06),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: MMass.s4),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(titel, style: MPapierSchrift.text),
                          const SizedBox(height: 2),
                          Text(hinweis, style: MPapierSchrift.leise),
                        ],
                      ),
                    ),
                    const SizedBox(width: MMass.s12),
                    MSchalter(wert: werte.stimme, onChanged: werte.setzeStimme, symbolAn: Icons.volume_up, symbolAus: Icons.volume_off),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// „Dein Moment“ an oder aus (Finale §3): Formularzeile mit Messing-Kippschalter
/// wie die Erzählerstimme; aus spielt der Tisch die Gruppenwahl wie bisher.
class MomentAbschnitt extends _Abschnitt {
  const MomentAbschnitt({super.key, required super.werte});

  @override
  Widget baue(BuildContext context) {
    final l = _texte(context);
    void umschalten() => werte.setzeEinfluss(!werte.einfluss);
    return EinrichtungsTafel(
      ueberschrift: l.abend_moment_titel,
      kinder: [
        Semantics(
          toggled: werte.einfluss,
          label: l.abend_moment_schalter,
          hint: l.abend_moment_hinweis,
          onTap: umschalten,
          excludeSemantics: true,
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              key: const ValueKey('moment-schalter'),
              onTap: umschalten,
              splashFactory: NoSplash.splashFactory,
              highlightColor: MRoh.tinte.withValues(alpha: 0.06),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: MMass.s4),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(l.abend_moment_schalter, style: MPapierSchrift.text),
                          const SizedBox(height: 2),
                          Text(l.abend_moment_hinweis, style: MPapierSchrift.leise),
                        ],
                      ),
                    ),
                    const SizedBox(width: MMass.s12),
                    MSchalter(wert: werte.einfluss, onChanged: werte.setzeEinfluss, symbolAn: Icons.auto_awesome_rounded, symbolAus: Icons.block_rounded),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Eingabefeld im Spielstil; der Platzhalter kommt aus den Bausteinen. Auf
/// Papier ([MFlaeche] hell) eine Formularzeile mit Tintenlinie, auf dem
/// Schreibtisch ein dunkles Feld mit Rahmen.
InputDecoration einrichtungFeld(BuildContext context, String platzhalter) {
  if (MFlaeche.hellVon(context)) return mPapierFeld(platzhalter);
  final f = MFarben.von(context);
  OutlineInputBorder rahmen(Color farbe) => OutlineInputBorder(borderRadius: BorderRadius.circular(MMass.r10), borderSide: BorderSide(color: farbe));
  return InputDecoration(
    hintText: platzhalter,
    hintStyle: MSchrift.von(context).leise,
    isDense: true,
    filled: true,
    fillColor: f.grund2,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    border: rahmen(f.linieStark),
    enabledBorder: rahmen(f.linieStark),
    focusedBorder: rahmen(f.akzent),
  );
}

/// Fall-Codes stehen in Großbuchstaben, die Eingabe wird beim Tippen groß.
class Grossbuchstaben extends TextInputFormatter {
  const Grossbuchstaben();

  @override
  TextEditingValue formatEditUpdate(TextEditingValue alt, TextEditingValue neu) {
    final gross = neu.text.toUpperCase();
    return neu.copyWith(text: gross, selection: TextSelection.collapsed(offset: gross.length));
  }
}

/// Fehlerzeile unter einem Feld: Warnzeichen und ein Baustein. Auf Papier in
/// Stempelrot und Tinte.
class EinrichtungsFehler extends StatelessWidget {
  const EinrichtungsFehler(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final f = MFarben.von(context);
    return Row(
      children: [
        Icon(Icons.error_outline, color: f.gefahr, size: 20),
        const SizedBox(width: MMass.s8),
        Expanded(child: Text(text, style: MSchrift.von(context).leise.copyWith(color: f.papier))),
      ],
    );
  }
}
