import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mordakte_core/mordakte_core.dart';

import '../party_stil.dart';
import '../sitzung.dart';

/// Einrichtung des Abends (F4-BAUMEISTER-01, Master 7.6, Schritt 2): Personen
/// und Spielernamen, Geburtstagskind, Detektiv oder Detektivin, Fall-Code oder
/// Zufall, Bildschirm- oder Druckspiel, Rundendauer und Erzählerstimme. Der
/// Startknopf richtet den Abend ein; das Geburtstagskind schaut dabei weg.
class EinrichtungBildschirm extends StatefulWidget {
  const EinrichtungBildschirm({super.key, required this.sitzung});

  final PartySitzung sitzung;

  @override
  State<EinrichtungBildschirm> createState() => _EinrichtungBildschirmState();
}

/// Fall-Code: Zufall (Vorgabe) oder eigene Eingabe.
enum _CodeWahl { zufall, eingabe }

/// Bildschirmspiel (Vorgabe) oder Druckfassung als PDF.
enum _Spielart { bildschirm, druck }

/// Rundendauern zur Wahl, in Minuten.
const _minutenWahl = [20, 30, 45, 60];

class _EinrichtungBildschirmState extends State<EinrichtungBildschirm> {
  int _rollen = 7;
  String _detektiv = 'w';
  _CodeWahl _codeWahl = _CodeWahl.zufall;
  _Spielart _spielart = _Spielart.bildschirm;
  int _minuten = 30;
  bool _stimme = false;
  bool _solo = false;
  final _geburtstag = TextEditingController();
  final _code = TextEditingController();

  /// Spielernamen je Rolle. Die Felder bleiben erhalten, wenn sich die Anzahl ändert.
  final Map<String, TextEditingController> _namen = {};

  PartySitzung get s => widget.sitzung;

  /// Startbereit: Zufall gilt immer, eine Eingabe nur, wenn sie ein Fall-Code ist.
  bool get _codeOk => _codeWahl == _CodeWahl.zufall || FallCode.lesen(_code.text) != null;

  /// Eingegeben, aber kein Fall-Code. Eine leere Eingabe ist noch keine Fehlermeldung.
  bool get _codeFalsch => _codeWahl == _CodeWahl.eingabe && _code.text.trim().isNotEmpty && FallCode.lesen(_code.text) == null;

  @override
  void dispose() {
    _geburtstag.dispose();
    _code.dispose();
    for (final c in _namen.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _namenFeld(String rolle) => _namen.putIfAbsent(rolle, () => TextEditingController());

  /// Anzahl der Personen; die Grenzen kommen aus der Besetzung.
  void _setzeRollen(int n) => setState(() => _rollen = n.clamp(s.minRollen, s.maxRollen).toInt());

  /// Startknopf: den Abend einrichten und danach die Erzählerstimme setzen.
  void _starten() {
    final namen = <String, String>{};
    if (!_solo) {
      for (final r in s.rollenBei(_rollen)) {
        final name = _namenFeld(r).text.trim();
        if (name.isNotEmpty) namen[r] = name;
      }
    }
    s.einrichten(
      rollen: _rollen,
      detektiv: _detektiv,
      code: _codeWahl == _CodeWahl.eingabe ? _code.text : null,
      druck: !_solo && _spielart == _Spielart.druck,
      solo: _solo,
      rundendauerMinuten: _minuten,
      namen: namen,
      geburtstagskind: _geburtstag.text.trim(),
    );
    s.stimmeAn = _stimme;
  }

  @override
  Widget build(BuildContext context) => PartyRahmen(
        marke: s.ui('ui.einrichtung.marke'),
        titel: s.ui('ui.einrichtung.titel'),
        untertitel: s.ui(_solo ? 'ui.solo.einrichtung' : 'ui.einrichtung.hinweis'),
        aktionen: [PartyKnopf(text: s.ui('ui.einrichtung.start'), onPressed: _codeOk ? _starten : null)],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _formAbschnitt(),
            _personenAbschnitt(),
            _geburtstagAbschnitt(),
            _detektivAbschnitt(),
            _fallAbschnitt(),
            if (!_solo) _spielartAbschnitt(),
            if (!_solo) _dauerAbschnitt(),
            _stimmeAbschnitt(),
          ],
        ),
      );

  /// Ein Abschnitt in einer Tafel: Überschrift im Kellerstil, darunter die Felder.
  Widget _abschnitt(String ueberschrift, List<Widget> kinder) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: PartyTafel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(ueberschrift.toUpperCase(), style: Keller.marke),
              const SizedBox(height: 12),
              ...kinder,
            ],
          ),
        ),
      );

  Widget _formAbschnitt() => _abschnitt(s.ui('ui.solo.spielweise'), [
        Wrap(spacing: 10, runSpacing: 10, children: [
          PartyKnopf(text: s.ui('ui.solo.party'), haupt: !_solo, onPressed: () => setState(() => _solo = false)),
          PartyKnopf(text: s.ui('ui.solo.solo'), haupt: _solo, onPressed: () => setState(() {
            _solo = true;
            _spielart = _Spielart.bildschirm;
          })),
        ]),
      ]);

  Widget _personenAbschnitt() => _abschnitt(s.ui(_solo ? 'ui.solo.rollen' : 'ui.einrichtung.personen'), [
        Text(s.ui(_solo ? 'ui.solo.rollen_anzahl' : 'ui.einrichtung.anzahl', {'anzahl': '$_rollen'}), style: Keller.ueberschrift, textAlign: TextAlign.center),
        Row(
          children: [
            IconButton(
              tooltip: s.ui('ui.einrichtung.weniger'),
              onPressed: _rollen > s.minRollen ? () => _setzeRollen(_rollen - 1) : null,
              icon: const Icon(Icons.remove_circle_outline),
              color: Keller.papier,
            ),
            Expanded(
              child: Slider(
                value: _rollen.toDouble(),
                min: s.minRollen.toDouble(),
                max: s.maxRollen.toDouble(),
                divisions: s.maxRollen - s.minRollen,
                activeColor: Keller.kerze,
                inactiveColor: Keller.steinHell,
                onChanged: (v) => _setzeRollen(v.round()),
              ),
            ),
            IconButton(
              tooltip: s.ui('ui.einrichtung.mehr'),
              onPressed: _rollen < s.maxRollen ? () => _setzeRollen(_rollen + 1) : null,
              icon: const Icon(Icons.add_circle_outline),
              color: Keller.papier,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(s.ui(_solo ? 'ui.solo.rollen_hinweis' : 'ui.einrichtung.namen_hinweis'), style: Keller.leise),
        const SizedBox(height: 12),
        for (final r in s.rollenBei(_rollen)) _rollenZeile(r),
      ]);

  /// Eine besetzte Rolle: Farbpunkt, Figur und Feld für den Spielernamen.
  Widget _rollenZeile(String rolle) => Padding(
        key: ValueKey('rolle-$rolle'),
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            FarbPunkt(s.figurFarbe(rolle), groesse: 16),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.figurName(rolle), style: Keller.text),
                  Text(s.figurTitel(rolle), style: Keller.leise),
                ],
              ),
            ),
            if (!_solo) const SizedBox(width: 12),
            if (!_solo) SizedBox(
              width: 150,
              child: TextField(
                key: ValueKey('name-$rolle'),
                controller: _namenFeld(rolle),
                textCapitalization: TextCapitalization.words,
                style: Keller.text,
                decoration: _feld(s.ui('ui.einrichtung.name_feld')),
              ),
            ),
          ],
        ),
      );

  Widget _geburtstagAbschnitt() => _abschnitt(s.ui(_solo ? 'ui.solo.name' : 'ui.einrichtung.geburtstag'), [
        TextField(
          controller: _geburtstag,
          textCapitalization: TextCapitalization.words,
          style: Keller.text,
          decoration: _feld(s.ui(_solo ? 'ui.solo.name_feld' : 'ui.einrichtung.geburtstag_feld')),
        ),
      ]);

  Widget _detektivAbschnitt() => _abschnitt(s.ui('ui.einrichtung.detektiv'), [
        SegmentedButton<String>(
          style: _auswahlStil,
          showSelectedIcon: false,
          segments: [
            ButtonSegment(value: 'm', label: Text(s.ui('ui.einrichtung.detektiv_m'))),
            ButtonSegment(value: 'w', label: Text(s.ui('ui.einrichtung.detektiv_w'))),
          ],
          selected: {_detektiv},
          onSelectionChanged: (w) => setState(() => _detektiv = w.first),
        ),
      ]);

  Widget _fallAbschnitt() => _abschnitt(s.ui('ui.einrichtung.fall'), [
        SegmentedButton<_CodeWahl>(
          style: _auswahlStil,
          showSelectedIcon: false,
          segments: [
            ButtonSegment(value: _CodeWahl.zufall, label: Text(s.ui('ui.einrichtung.code_zufall'))),
            ButtonSegment(value: _CodeWahl.eingabe, label: Text(s.ui('ui.einrichtung.code_eingabe'))),
          ],
          selected: {_codeWahl},
          onSelectionChanged: (w) => setState(() => _codeWahl = w.first),
        ),
        if (_codeWahl == _CodeWahl.eingabe) ...[
          const SizedBox(height: 12),
          TextField(
            key: const ValueKey('code'),
            controller: _code,
            textCapitalization: TextCapitalization.characters,
            inputFormatters: [const _Grossbuchstaben(), LengthLimitingTextInputFormatter(FallCode.laenge)],
            onChanged: (_) => setState(() {}),
            style: Keller.ueberschrift,
            decoration: _feld(s.ui('ui.einrichtung.code_feld')),
          ),
          if (_codeFalsch) ...[
            const SizedBox(height: 10),
            _Fehlerzeile(s.ui('ui.einrichtung.code_fehler')),
          ],
        ],
        const SizedBox(height: 12),
        Text(s.ui('ui.einrichtung.code_hinweis'), style: Keller.leise),
      ]);

  Widget _spielartAbschnitt() => _abschnitt(s.ui('ui.einrichtung.spiel'), [
        SegmentedButton<_Spielart>(
          style: _auswahlStil,
          showSelectedIcon: false,
          segments: [
            ButtonSegment(value: _Spielart.bildschirm, label: Text(s.ui('ui.einrichtung.spiel_bildschirm'))),
            ButtonSegment(value: _Spielart.druck, label: Text(s.ui('ui.einrichtung.spiel_druck'))),
          ],
          selected: {_spielart},
          onSelectionChanged: (w) => setState(() => _spielart = w.first),
        ),
        if (_spielart == _Spielart.druck) ...[
          const SizedBox(height: 12),
          Text(s.ui('ui.einrichtung.druck_hinweis'), style: Keller.leise),
        ],
      ]);

  Widget _dauerAbschnitt() => _abschnitt(s.ui('ui.einrichtung.dauer'), [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final m in _minutenWahl)
              PartyKnopf(
                text: s.ui('ui.einrichtung.minuten', {'minuten': '$m'}),
                haupt: m == _minuten,
                onPressed: () => setState(() => _minuten = m),
              ),
          ],
        ),
      ]);

  Widget _stimmeAbschnitt() => _abschnitt(s.ui('ui.einrichtung.stimme'), [
        // Eigene Material-Fläche ohne Farbe: Der Schalter malt auf sie, nicht auf die Tafel.
        Material(
          type: MaterialType.transparency,
          child: SwitchListTile(
            contentPadding: EdgeInsets.zero,
            activeThumbColor: Keller.kerze,
            activeTrackColor: Keller.kerzeSchwach,
            title: Text(s.ui('ui.einrichtung.stimme_schalter'), style: Keller.text),
            subtitle: Text(s.ui('ui.einrichtung.stimme_hinweis'), style: Keller.leise),
            value: _stimme,
            onChanged: (v) => setState(() => _stimme = v),
          ),
        ),
      ]);
}

/// Eingabefeld im Kellerstil; der Platzhalter kommt aus den Bausteinen.
InputDecoration _feld(String platzhalter) => InputDecoration(
      hintText: platzhalter,
      hintStyle: Keller.leise,
      isDense: true,
      filled: true,
      fillColor: Keller.nacht2,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: _rahmen(Keller.linieStark),
      enabledBorder: _rahmen(Keller.linieStark),
      focusedBorder: _rahmen(Keller.kerze),
    );

OutlineInputBorder _rahmen(Color farbe) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: farbe),
    );

/// Auswahl im Kellerstil: die gewählte Seite leuchtet warm.
final _auswahlStil = SegmentedButton.styleFrom(
  backgroundColor: Keller.stein,
  foregroundColor: Keller.papier,
  selectedBackgroundColor: Keller.kerze,
  selectedForegroundColor: const Color(0xFF1A1006),
  side: const BorderSide(color: Keller.linieStark),
  textStyle: const TextStyle(fontFamily: Keller.schrift, fontSize: 15, fontWeight: FontWeight.w600),
);

/// Fall-Codes stehen in Großbuchstaben, die Eingabe wird beim Tippen groß.
class _Grossbuchstaben extends TextInputFormatter {
  const _Grossbuchstaben();

  @override
  TextEditingValue formatEditUpdate(TextEditingValue alt, TextEditingValue neu) {
    final gross = neu.text.toUpperCase();
    return neu.copyWith(text: gross, selection: TextSelection.collapsed(offset: gross.length));
  }
}

/// Fehlerzeile unter einem Feld: Warnzeichen und ein Baustein.
class _Fehlerzeile extends StatelessWidget {
  const _Fehlerzeile(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          const Icon(Icons.error_outline, color: Keller.gefahr, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: Keller.leise.copyWith(color: Keller.papier))),
        ],
      );
}
