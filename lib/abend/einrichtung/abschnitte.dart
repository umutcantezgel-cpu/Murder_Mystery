import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mordakte_core/mordakte_core.dart';

import '../../l10n/lookup.dart';
import '../../party/party_stil.dart' show FarbPunkt;
import '../../party/sitzung.dart';
import '../../stil/stil.dart';

/// Fall-Code: Zufall (Vorgabe) oder eigene Eingabe.
enum CodeWahl { zufall, eingabe }

/// Bildschirmspiel (Vorgabe) oder Druckfassung als PDF.
enum Spielart { bildschirm, druck }

/// Rundendauern zur Wahl, in Minuten.
const einrichtungMinuten = [20, 30, 45, 60];

/// Alle Eingaben der Einrichtung eines Abends: Personen und Spielernamen,
/// Geburtstagskind, Detektiv oder Detektivin, Fall-Code, Bildschirm- oder
/// Druckspiel, Rundendauer und Erzählerstimme. Der Assistent für neue Abende
/// und der alte Einrichtungsbildschirm teilen sich diese Werte und die
/// Abschnitte darunter; [starten] richtet den Abend ein.
///
/// Zwei Eigenschaften der Akte schränken die Wahl ein: Eine Druckfassung gibt es
/// nur für Akten mit Druckmappe ([druckbar]), und eine Akte mit fester Lösung
/// ([festeLoesung]) kennt keinen Fall-Code.
class EinrichtungsWerte extends ChangeNotifier {
  /// [druckbar]: Die Akte hat eine Druckmappe (`AkteInfo.druckbar`). Ohne Angabe
  /// gilt sie als druckbar (alter Einrichtungsbildschirm, Druckmappe).
  EinrichtungsWerte(this.sitzung, {this.druckbar = true}) : rollen = 7.clamp(sitzung.minRollen, sitzung.maxRollen).toInt();

  final PartySitzung sitzung;

  /// Gibt es für diese Akte eine Druckfassung? Sonst bleibt es beim Bildschirmspiel.
  final bool druckbar;

  /// Akte mit fester Lösung (ein einziger Pfad): ein Fall-Code ändert den Täter nicht.
  bool get festeLoesung => sitzung.daten.kanon.festeLoesung;

  int rollen;
  String detektiv = 'w';
  CodeWahl codeWahl = CodeWahl.zufall;
  Spielart spielart = Spielart.bildschirm;
  int minuten = 30;
  bool stimme = false;
  bool _solo = false;
  final geburtstag = TextEditingController();
  final code = TextEditingController();

  /// Spielernamen je Rolle. Die Felder bleiben erhalten, wenn sich die Anzahl ändert.
  final Map<String, TextEditingController> _namen = {};

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

  TextEditingController namenFeld(String rolle) => _namen.putIfAbsent(rolle, () => TextEditingController());

  /// Anzahl der Personen; die Grenzen kommen aus der Besetzung.
  void setzeRollen(int n) {
    rollen = n.clamp(sitzung.minRollen, sitzung.maxRollen).toInt();
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

  /// Richtet den Abend ein und setzt danach die Erzählerstimme.
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
      geburtstagskind: geburtstag.text.trim(),
    );
    s.stimmeAn = stimme;
  }

  @override
  void dispose() {
    geburtstag.dispose();
    code.dispose();
    for (final c in _namen.values) {
      c.dispose();
    }
    super.dispose();
  }
}

/// Ein Abschnitt in einer Tafel: Überschrift in Kapitälchen, darunter die Felder.
class EinrichtungsTafel extends StatelessWidget {
  const EinrichtungsTafel({super.key, required this.ueberschrift, required this.kinder});

  final String ueberschrift;
  final List<Widget> kinder;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: MMass.s16),
        child: MTafel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(ueberschrift.toUpperCase(), style: MSchrift.von(context).marke),
              const SizedBox(height: MMass.s12),
              ...kinder,
            ],
          ),
        ),
      );
}

/// Basis der Abschnitte: hört auf die [werte] und baut bei jeder Änderung neu.
abstract class _Abschnitt extends StatelessWidget {
  const _Abschnitt({super.key, required this.werte});

  final EinrichtungsWerte werte;

  PartySitzung get s => werte.sitzung;

  Widget baue(BuildContext context, MFarben f, MSchrift t);

  @override
  Widget build(BuildContext context) {
    final f = MFarben.von(context);
    final t = MSchrift.von(context);
    return ListenableBuilder(listenable: werte, builder: (context, _) => baue(context, f, t));
  }
}

/// Alle Abschnitte in der festen Reihenfolge des Einrichtungsbildschirms. Im
/// Solo-Spiel entfallen Druckfassung und Rundendauer. Im Online-Abend
/// ([online]: jeder am eigenen Gerät) entfallen Personenzahl und Spielnamen
/// (die Lobby legt die Rollen fest) und die Druckfassung. Die Druckfassung gibt
/// es nur für druckbare Akten ([EinrichtungsWerte.druckbar]). Bei einer Akte mit
/// fester Lösung ersetzt ein Hinweis den Fall-Code.
class EinrichtungsAbschnitte extends StatelessWidget {
  const EinrichtungsAbschnitte({super.key, required this.werte, this.online = false});

  final EinrichtungsWerte werte;
  final bool online;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: werte,
        builder: (context, _) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!online) PersonenAbschnitt(werte: werte),
            GeburtstagAbschnitt(werte: werte),
            DetektivAbschnitt(werte: werte),
            FallAbschnitt(werte: werte, online: online),
            if (!werte.solo && !online && werte.druckbar) SpielartAbschnitt(werte: werte),
            if (!werte.solo) DauerAbschnitt(werte: werte),
            StimmeAbschnitt(werte: werte),
          ],
        ),
      );
}

/// Anzahl der Personen per Regler und die besetzten Rollen mit Namensfeldern.
class PersonenAbschnitt extends _Abschnitt {
  const PersonenAbschnitt({super.key, required super.werte});

  @override
  Widget baue(BuildContext context, MFarben f, MSchrift t) {
    final solo = werte.solo;
    final n = werte.rollen;
    return EinrichtungsTafel(
      ueberschrift: s.ui(solo ? 'ui.solo.rollen' : 'ui.einrichtung.personen'),
      kinder: [
        Text(
          s.ui(solo ? 'ui.solo.rollen_anzahl' : 'ui.einrichtung.anzahl', {'anzahl': '$n'}),
          style: t.ueberschrift,
          textAlign: TextAlign.center,
        ),
        Row(
          children: [
            IconButton(
              tooltip: s.ui('ui.einrichtung.weniger'),
              onPressed: n > s.minRollen ? () => werte.setzeRollen(n - 1) : null,
              icon: const Icon(Icons.remove_circle_outline),
              color: f.papier,
            ),
            Expanded(
              child: Slider(
                value: n.toDouble(),
                min: s.minRollen.toDouble(),
                max: s.maxRollen.toDouble(),
                divisions: s.maxRollen - s.minRollen,
                activeColor: f.akzent,
                inactiveColor: f.flaecheHoch,
                onChanged: (v) => werte.setzeRollen(v.round()),
              ),
            ),
            IconButton(
              tooltip: s.ui('ui.einrichtung.mehr'),
              onPressed: n < s.maxRollen ? () => werte.setzeRollen(n + 1) : null,
              icon: const Icon(Icons.add_circle_outline),
              color: f.papier,
            ),
          ],
        ),
        const SizedBox(height: MMass.s8),
        Text(s.ui(solo ? 'ui.solo.rollen_hinweis' : 'ui.einrichtung.namen_hinweis'), style: t.leise),
        const SizedBox(height: MMass.s12),
        for (final r in s.rollenBei(n)) _rollenZeile(context, r, t),
      ],
    );
  }

  /// Eine besetzte Rolle: Farbpunkt, Figur und Feld für den Spielernamen. Auf
  /// schmalen Bildschirmen und bei großer Schrift steht das Feld unter Figur und
  /// Titel; sonst bliebe dem Titel kaum Platz und Wörter bräche es mitten durch.
  Widget _rollenZeile(BuildContext context, String rolle, MSchrift t) => Padding(
        key: ValueKey('rolle-$rolle'),
        padding: const EdgeInsets.only(bottom: 10),
        child: LayoutBuilder(
          builder: (context, box) {
            final skala = MediaQuery.textScalerOf(context).scale(1);
            final untereinander = box.maxWidth < 400 * (skala < 1 ? 1 : skala);
            final feld = TextField(
              key: ValueKey('name-$rolle'),
              controller: werte.namenFeld(rolle),
              textCapitalization: TextCapitalization.words,
              style: t.text,
              decoration: einrichtungFeld(context, s.ui('ui.einrichtung.name_feld')),
            );
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    FarbPunkt(s.figurFarbe(rolle), groesse: 16),
                    const SizedBox(width: MMass.s12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.figurName(rolle), style: t.text),
                          Text(s.figurTitel(rolle), style: t.leise),
                        ],
                      ),
                    ),
                    if (!werte.solo && !untereinander) ...[
                      const SizedBox(width: MMass.s12),
                      SizedBox(width: 150, child: feld),
                    ],
                  ],
                ),
                if (!werte.solo && untereinander)
                  Padding(
                    // Unter dem Text der Figur: Breite des Farbpunkts plus Abstand.
                    padding: const EdgeInsets.only(left: 16 + MMass.s12, top: MMass.s8),
                    child: feld,
                  ),
              ],
            );
          },
        ),
      );
}

/// Name des Geburtstagskinds (Detektiv); im Solo-Spiel der Name des Detektivs.
class GeburtstagAbschnitt extends _Abschnitt {
  const GeburtstagAbschnitt({super.key, required super.werte});

  @override
  Widget baue(BuildContext context, MFarben f, MSchrift t) {
    final solo = werte.solo;
    return EinrichtungsTafel(
      ueberschrift: s.ui(solo ? 'ui.solo.name' : 'ui.einrichtung.geburtstag'),
      kinder: [
        TextField(
          controller: werte.geburtstag,
          textCapitalization: TextCapitalization.words,
          style: t.text,
          decoration: einrichtungFeld(context, s.ui(solo ? 'ui.solo.name_feld' : 'ui.einrichtung.geburtstag_feld')),
        ),
      ],
    );
  }
}

/// Detektiv oder Detektivin.
class DetektivAbschnitt extends _Abschnitt {
  const DetektivAbschnitt({super.key, required super.werte});

  @override
  Widget baue(BuildContext context, MFarben f, MSchrift t) => EinrichtungsTafel(
        ueberschrift: s.ui('ui.einrichtung.detektiv'),
        kinder: [
          SegmentedButton<String>(
            style: einrichtungAuswahlStil(f),
            showSelectedIcon: false,
            segments: [
              ButtonSegment(value: 'm', label: Text(s.ui('ui.einrichtung.detektiv_m'))),
              ButtonSegment(value: 'w', label: Text(s.ui('ui.einrichtung.detektiv_w'))),
            ],
            selected: {werte.detektiv},
            onSelectionChanged: (w) => werte.setzeDetektiv(w.first),
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
  Widget baue(BuildContext context, MFarben f, MSchrift t) {
    if (werte.festeLoesung) return FesteLoesungHinweis(solo: werte.solo, online: online);
    return _codeTafel(context, f, t);
  }

  Widget _codeTafel(BuildContext context, MFarben f, MSchrift t) => EinrichtungsTafel(
        ueberschrift: s.ui('ui.einrichtung.fall'),
        kinder: [
          SegmentedButton<CodeWahl>(
            style: einrichtungAuswahlStil(f),
            showSelectedIcon: false,
            segments: [
              ButtonSegment(value: CodeWahl.zufall, label: Text(s.ui('ui.einrichtung.code_zufall'))),
              ButtonSegment(value: CodeWahl.eingabe, label: Text(s.ui('ui.einrichtung.code_eingabe'))),
            ],
            selected: {werte.codeWahl},
            onSelectionChanged: (w) => werte.setzeCodeWahl(w.first),
          ),
          if (werte.codeWahl == CodeWahl.eingabe) ...[
            const SizedBox(height: MMass.s12),
            TextField(
              key: const ValueKey('code'),
              controller: werte.code,
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [const Grossbuchstaben(), LengthLimitingTextInputFormatter(FallCode.laenge)],
              onChanged: (_) => werte.melde(),
              style: t.ueberschrift,
              decoration: einrichtungFeld(context, s.ui('ui.einrichtung.code_feld')),
            ),
            if (werte.codeFalsch) ...[
              const SizedBox(height: 10),
              EinrichtungsFehler(s.ui('ui.einrichtung.code_fehler')),
            ],
          ],
          const SizedBox(height: MMass.s12),
          Text(s.ui('ui.einrichtung.code_hinweis'), style: t.leise),
        ],
      );
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
          style: MSchrift.von(context).text,
        ),
      ],
    );
  }
}

/// Bildschirmspiel oder Druckfassung (nur reihum, nicht im Solo-Spiel).
class SpielartAbschnitt extends _Abschnitt {
  const SpielartAbschnitt({super.key, required super.werte});

  @override
  Widget baue(BuildContext context, MFarben f, MSchrift t) => EinrichtungsTafel(
        ueberschrift: s.ui('ui.einrichtung.spiel'),
        kinder: [
          SegmentedButton<Spielart>(
            style: einrichtungAuswahlStil(f),
            showSelectedIcon: false,
            segments: [
              ButtonSegment(value: Spielart.bildschirm, label: Text(s.ui('ui.einrichtung.spiel_bildschirm'))),
              ButtonSegment(value: Spielart.druck, label: Text(s.ui('ui.einrichtung.spiel_druck'))),
            ],
            selected: {werte.spielart},
            onSelectionChanged: (w) => werte.setzeSpielart(w.first),
          ),
          if (werte.spielart == Spielart.druck) ...[
            const SizedBox(height: MMass.s12),
            Text(s.ui('ui.einrichtung.druck_hinweis'), style: t.leise),
          ],
        ],
      );
}

/// Rundendauer (nur reihum).
class DauerAbschnitt extends _Abschnitt {
  const DauerAbschnitt({super.key, required super.werte});

  @override
  Widget baue(BuildContext context, MFarben f, MSchrift t) => EinrichtungsTafel(
        ueberschrift: s.ui('ui.einrichtung.dauer'),
        kinder: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final m in einrichtungMinuten)
                MKnopf(
                  text: s.ui('ui.einrichtung.minuten', {'minuten': '$m'}),
                  art: m == werte.minuten ? MKnopfArt.haupt : MKnopfArt.zweit,
                  onPressed: () => werte.setzeMinuten(m),
                ),
            ],
          ),
        ],
      );
}

/// Erzählerstimme an oder aus.
class StimmeAbschnitt extends _Abschnitt {
  const StimmeAbschnitt({super.key, required super.werte});

  @override
  Widget baue(BuildContext context, MFarben f, MSchrift t) => EinrichtungsTafel(
        ueberschrift: s.ui('ui.einrichtung.stimme'),
        kinder: [
          // Eigene Material-Fläche ohne Farbe: Der Schalter malt auf sie, nicht auf die Tafel.
          Material(
            type: MaterialType.transparency,
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              activeThumbColor: f.akzent,
              activeTrackColor: f.akzentSchwach,
              title: Text(s.ui('ui.einrichtung.stimme_schalter'), style: t.text),
              subtitle: Text(s.ui('ui.einrichtung.stimme_hinweis'), style: t.leise),
              value: werte.stimme,
              onChanged: werte.setzeStimme,
            ),
          ),
        ],
      );
}

/// Eingabefeld im Spielstil; der Platzhalter kommt aus den Bausteinen.
InputDecoration einrichtungFeld(BuildContext context, String platzhalter) {
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

/// Auswahl im Spielstil: die gewählte Seite leuchtet warm.
ButtonStyle einrichtungAuswahlStil(MFarben f) => SegmentedButton.styleFrom(
      backgroundColor: f.flaeche,
      foregroundColor: f.papier,
      selectedBackgroundColor: f.akzent,
      selectedForegroundColor: f.akzentAuf,
      side: BorderSide(color: f.linieStark),
      minimumSize: const Size(MMass.tippflaeche, MMass.tippflaeche),
      textStyle: const TextStyle(fontFamily: MRohSchrift.text, fontSize: 15, fontWeight: FontWeight.w600),
    );

/// Fall-Codes stehen in Großbuchstaben, die Eingabe wird beim Tippen groß.
class Grossbuchstaben extends TextInputFormatter {
  const Grossbuchstaben();

  @override
  TextEditingValue formatEditUpdate(TextEditingValue alt, TextEditingValue neu) {
    final gross = neu.text.toUpperCase();
    return neu.copyWith(text: gross, selection: TextSelection.collapsed(offset: gross.length));
  }
}

/// Fehlerzeile unter einem Feld: Warnzeichen und ein Baustein.
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
