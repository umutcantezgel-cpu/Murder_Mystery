import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mordakte_core/mordakte_core.dart';

import '../../l10n/lookup.dart';
import '../../meta/gaesteliste.dart';
import '../../party/sitzung.dart';
import '../../stil/mappe/assistent_formular.dart';
import '../../stil/stil.dart';

/// Fall-Code: Zufall (Vorgabe) oder eigene Eingabe.
enum CodeWahl { zufall, eingabe }

/// Bildschirmspiel (Vorgabe) oder Druckfassung als PDF.
enum Spielart { bildschirm, druck }

/// Rundendauern zur Wahl, in Minuten.
const einrichtungMinuten = [20, 30, 45, 60];

/// Alle Eingaben der Einrichtung eines Abends: Personen und Spielernamen,
/// Geburtstagskind, Detektiv oder Detektivin, Fall-Code, Bildschirm- oder
/// Druckspiel, Rundendauer, Erzählerstimme und Erzähltiefe. Der Assistent für neue Abende
/// und der alte Einrichtungsbildschirm teilen sich diese Werte und die
/// Abschnitte darunter; [starten] richtet den Abend ein.
///
/// Zwei Eigenschaften der Akte schränken die Wahl ein: Eine Druckfassung gibt es
/// nur für Akten mit Druckmappe ([druckbar]), und eine Akte mit fester Lösung
/// ([festeLoesung]) kennt keinen Fall-Code.
class EinrichtungsWerte extends ChangeNotifier {
  /// [druckbar]: Die Akte hat eine Druckmappe (`AkteInfo.druckbar`). Ohne Angabe
  /// gilt sie als druckbar (alter Einrichtungsbildschirm, Druckmappe).
  /// [gaeste]: Gästeliste der Akte (M5) für Personenzahl und Namen.
  EinrichtungsWerte(this.sitzung, {this.druckbar = true, GaesteListe gaeste = const GaesteListe()})
      : rollen = (gaeste.personen ?? 7).clamp(sitzung.minRollen, sitzung.maxRollen).toInt(),
        _gaeste = gaeste.namenJeFigur;

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

  /// Gespräche mit Zeugen (M6); nur bei Akten, die welche haben.
  Erzaehltiefe erzaehltiefe = Erzaehltiefe.voll;
  bool _solo = false;
  final geburtstag = TextEditingController();
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

  TextEditingController namenFeld(String rolle) => _namen.putIfAbsent(rolle, () => TextEditingController(text: _gaeste[rolle]));

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

  void setzeErzaehltiefe(Erzaehltiefe wert) {
    erzaehltiefe = wert;
    notifyListeners();
  }

  /// Hat die Akte Gespräche mit Zeugen?
  bool get hatGespraeche => sitzung.daten.erzaehlung != null;

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
      geburtstagskind: geburtstag.text.trim(),
    );
    s.stimmeAn = stimme;
    s.erzaehltiefe = erzaehltiefe;
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
              GeburtstagAbschnitt(werte: werte),
              DetektivAbschnitt(werte: werte),
              FallAbschnitt(werte: werte, online: online),
              if (!werte.solo && !online && werte.druckbar) SpielartAbschnitt(werte: werte),
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
        const SizedBox(height: MMass.s16),
        for (var i = 0; i < rollen.length; i++) _rollenZeile(rollen[i], i),
      ],
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
                    // Der Name steht daneben; das Bild bleibt für den Bildschirmleser stumm.
                    ExcludeSemantics(
                      child: MFotoabzug(
                        look: s.figurAussehen(rolle),
                        groesse: _foto,
                        neigung: nr.isEven ? -0.05 : 0.04,
                        akzent: s.figurFarbe(rolle),
                      ),
                    ),
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

/// Name des Geburtstagskinds (Detektiv); im Solo-Spiel der Name des Detektivs.
class GeburtstagAbschnitt extends _Abschnitt {
  const GeburtstagAbschnitt({super.key, required super.werte});

  @override
  Widget baue(BuildContext context) {
    final solo = werte.solo;
    return EinrichtungsTafel(
      ueberschrift: s.ui(solo ? 'ui.solo.name' : 'ui.einrichtung.geburtstag'),
      kinder: [
        _Formularzeile(
          feldKey: null,
          controller: werte.geburtstag,
          platzhalter: s.ui(solo ? 'ui.solo.name_feld' : 'ui.einrichtung.geburtstag_feld'),
        ),
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

/// Bildschirmspiel oder Druckfassung (nur reihum, nicht im Solo-Spiel).
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
          ],
        ],
      );
}

/// Rundendauer (nur reihum).
class DauerAbschnitt extends _Abschnitt {
  const DauerAbschnitt({super.key, required super.werte});

  @override
  Widget baue(BuildContext context) => EinrichtungsTafel(
        ueberschrift: s.ui('ui.einrichtung.dauer'),
        kinder: [
          MAnkreuzWahl<int>(
            optionen: [for (final m in einrichtungMinuten) (m, s.ui('ui.einrichtung.minuten', {'minuten': '$m'}))],
            gewaehlt: werte.minuten,
            onWahl: werte.setzeMinuten,
          ),
        ],
      );
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
