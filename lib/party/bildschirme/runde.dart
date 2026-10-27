import 'package:flutter/material.dart';
import 'package:mordakte_core/mordakte_core.dart';

import '../../stil/mappe/abend1_bausteine.dart';
import '../../stil/stil.dart';
import '../erzaehler_ausgabe.dart';
import '../party_stil.dart';
import '../runden_uhr.dart';
import '../sitzung.dart';
import '../stand/befragung_stand.dart';
import 'befragung.dart';
import 'einfluss_teile.dart';
import 'moment.dart';
import 'spickzettel.dart';

/// Rundenzentrale (F4-BAUMEISTER-03, Master 7.6 Schritt 5): Erzählertext zum
/// Rundenstart, die Uhr der Runde und die Pflichtgespräche aller besetzten
/// Rollen. Die Uhr schaltet nichts weiter; das tut allein der Weiter-Knopf.
///
/// Die Uhr ist die gemeinsame Rundenuhr der Sitzung ([PartySitzung.uhr], M4):
/// an einem Gerät hier gestellt, online im Raum, für alle gleich. Start, Pause
/// und plus fünf Minuten hat nur das Gerät, das leitet ([SitzungsUhr]).
///
/// Im Modell befragung (A-051) stehen statt der Pflichtgespräche die
/// Befragungen des Detektivs (wen, Thema, Fragen, nie eine Antwort), die
/// Paarungen am Tisch (nur wer mit wem worüber) und reihum je Person ein
/// verdeckter Spickzettel für die laufende Runde. Tippt der Detektiv reihum
/// eine Frage an eine Person, geht das Gerät kurz verdeckt zu ihr; sie sieht
/// ihre Antwort-Stichpunkte, und mit dem Zudecken ist die Befragung beantwortet.
///
/// Die Uhr ist eine Taschenuhr aus Messing, die Restzeit steht im Fenster des
/// Zifferblatts. Die Gespräche stehen als Vernehmungsplan auf Karteikarten:
/// je Rolle ein Fotoabzug, je Gespräch der Abzug der Gesprächsperson.
class RundeBildschirm extends StatefulWidget {
  const RundeBildschirm({super.key, required this.sitzung});

  final PartySitzung sitzung;

  @override
  State<RundeBildschirm> createState() => _RundeBildschirmState();
}

class _RundeBildschirmState extends State<RundeBildschirm> {
  PartySitzung get s => widget.sitzung;

  /// Reihum: Rolle, deren Zwischenstufe („Gib das Gerät an …“) gerade offen ist.
  String? _vorbereitet;

  /// Reihum: Befragung, die den verdeckten Blick ausgelöst hat. Nach dem Zudecken ist sie beantwortet.
  String? _befragt;

  @override
  Widget build(BuildContext context) {
    // „Dein Moment“ (Finale §3): Die verdeckte Ansicht einer Person geht vor.
    if (s.momentAnsicht case final r?) return MomentBildschirm(sitzung: s, rolle: r);
    if (s.befragungsmodell) {
      final v = s.verdeckt;
      if (v != null) return _spickzettel(v);
      final vorbereitet = _vorbereitet;
      if (vorbereitet != null) return _zwischenstufe(vorbereitet);
    }
    return _zentrale();
  }

  Widget _zentrale() => PartyRahmen(
        marke: s.ui('ui.allgemein.runde', {'nr': '${s.runde}'}),
        titel: s.rundenName,
        untertitel: s.ui('ui.allgemein.uhrzeit', {'uhrzeit': s.rundenUhrzeit}),
        aktionen: [PartyKnopf(text: s.ui('ui.runde.weiter'), onPressed: s.kannWeiter ? s.weiter : null)],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          // Die Uhr steht oben: Sie läuft die ganze Runde und bleibt sichtbar, auch wenn
          // der Erzähler zum Rundenstart länger spricht (Gästewissen, E-038).
          children: [
            SitzungsUhr(sitzung: s),
            const SizedBox(height: 24),
            ErzaehlerFeld(sitzung: s, kennungen: s.erzaehler),
            const SizedBox(height: 28),
            // „Dein Moment“: reihum die Liste, online wer leitet den letzten Aufruf.
            if (s.einfluss) ...[s.online ? MomentAufruf(sitzung: s) : MomentListe(sitzung: s), const SizedBox(height: 28)],
            if (s.befragungsmodell) ..._befragungsmodell() else _gespraeche(),
          ],
        ),
      );

  // Modell befragung ------------------------------------------------------------

  /// Befragungen des Detektivs, Paarungen am Tisch und reihum die Spickzettel.
  List<Widget> _befragungsmodell() => [
        _kopfblatt(s.ui('ui.befragung.titel'), s.ui(s.befragungAufPapier ? 'ui.befragung.hinweis_druck' : 'ui.befragung.hinweis_tisch')),
        const SizedBox(height: 14),
        // Im Druckspiel stehen die Befragungen auf dem Bogen; hier nur zum Lesen.
        BefragungsListe(sitzung: s, onFrage: s.befragungAufPapier ? null : _frage, aktionen: _aktionen),
        if (!s.befragungenFertig) ...[
          const SizedBox(height: 4),
          Text(s.ui('ui.befragung.offen'), style: Keller.text),
        ],
        const SizedBox(height: 28),
        _kopfblatt(s.ui('ui.befragung.tisch_titel'), s.ui('ui.befragung.tisch_hinweis')),
        const SizedBox(height: 14),
        MBlatt(
          art: PapierArt.karteikarte,
          kopfLinie: 7,
          linien: false,
          neigung: 0.003,
          samen: 23 + s.runde,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [for (final t in s.tisch(s.runde)) TischZeile(sitzung: s, paarung: t)],
          ),
        ),
        // Online hat jede Person ihr eigenes Gerät; reihum geht es verdeckt herum.
        if (!s.online) ...[
          const SizedBox(height: 28),
          _kopfblatt(s.ui('ui.befragung.spickzettel'), s.ui('ui.befragung.spickzettel_hinweis')),
          const SizedBox(height: 14),
          for (var i = 0; i < s.besetzt.length; i++) ...[_person(i, s.besetzt[i]), const SizedBox(height: 10)],
        ],
      ];

  /// Der Detektiv stellt eine Frage. Reihum antwortet die Person aus ihrem Spickzettel: Das Gerät geht kurz zu ihr.
  void _frage(String id, int frage) {
    s.befragen(id, frage);
    if (s.online) return;
    final k = s.befragungen.firstWhere((k) => k.id == id);
    if (k.mensch && !k.erledigt) {
      setState(() {
        _vorbereitet = k.rolle;
        _befragt = id;
      });
    }
  }

  /// Knöpfe einer gestellten, noch offenen Befragung einer Person am Tisch.
  List<Widget> _aktionen(BefragungKarte k) => [
        if (k.gefragt && k.mensch && !k.erledigt) ...[
          if (!s.online)
            MKnopf(
              text: s.ui('ui.befragung.antwort_zeigen'),
              art: MKnopfArt.zweit,
              onPressed: () => setState(() {
                _vorbereitet = k.rolle;
                _befragt = k.id;
              }),
            ),
          Semantics(
            container: true,
            identifier: 'befragung-beantwortet-${k.id}',
            child: MKnopf(text: s.ui('ui.befragung.beantwortet'), onPressed: () => s.befragungErledigt(k.id)),
          ),
        ],
      ];

  /// Eine Person am Tisch: Tipp öffnet die Zwischenstufe zu ihrem Spickzettel.
  Widget _person(int i, String rolle) => Semantics(
        button: true,
        child: MBlatt(
          art: PapierArt.karteikarte,
          kopfLinie: 7,
          linien: false,
          randFarbe: s.figurFarbe(rolle),
          neigung: i.isEven ? -0.003 : 0.003,
          samen: 70 + i,
          padding: const EdgeInsets.fromLTRB(12, 10, 14, 10),
          onTap: () => setState(() {
            _vorbereitet = rolle;
            _befragt = null;
          }),
          child: Row(
            children: [
              MFotoabzug(look: s.figurAussehen(rolle), groesse: 40, neigung: i.isEven ? -0.05 : 0.04, akzent: s.figurFarbe(rolle)),
              const SizedBox(width: 14),
              Expanded(child: MGanzeWorte(s.spielerName(rolle), stil: MPapierSchrift.ueberschrift.copyWith(fontSize: 18))),
              const Icon(Icons.visibility_off_rounded, size: 20, color: MRoh.tinteLeise),
            ],
          ),
        ),
      );

  /// Zwischenstufe: Das Gerät geht an diese Person; erst ihr Knopf öffnet den Zettel.
  Widget _zwischenstufe(String rolle) {
    final name = s.spielerName(rolle);
    return PartyRahmen(
      marke: s.ui('ui.allgemein.runde', {'nr': '${s.runde}'}),
      titel: s.rundenName,
      child: MBlatt(
        art: PapierArt.telegramm,
        padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
        neigung: -0.006,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(child: MSiegel(kuerzel: AkteStil.fuer(s.daten.fall).sigel, farbe: context.farben.gefahr, groesse: 54)),
            const SizedBox(height: 16),
            Text(s.ui(_befragt != null ? 'ui.befragung.geraet' : 'ui.verdeckt.weitergeben', {'name': name}),
                style: MPapierSchrift.ueberschrift, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            PartyKnopf(
              text: s.ui('ui.verdeckt.frage', {'name': name}),
              onPressed: () {
                setState(() => _vorbereitet = null);
                s.zeigeVerdeckt(rolle);
              },
            ),
            const SizedBox(height: 10),
            PartyKnopf(
              text: s.ui('ui.allgemein.zurueck'),
              haupt: false,
              onPressed: () => setState(() {
                _vorbereitet = null;
                _befragt = null;
              }),
            ),
          ],
        ),
      ),
    );
  }

  /// Der verdeckte Spickzettel der laufenden Runde; nach einer Frage steht die Befragung oben.
  Widget _spickzettel(String rolle) => PartyRahmen(
        marke: s.ui('ui.befragung.spickzettel'),
        titel: s.figurName(rolle),
        untertitel: s.ui('ui.allgemein.runde', {'nr': '${s.runde}'}),
        aktionen: [PartyKnopf(text: s.ui('ui.verdeckt.schliessen'), onPressed: () => _zudecken(rolle))],
        child: MBlatt(
          art: PapierArt.karteikarte,
          kopfLinie: 7,
          linien: false,
          randFarbe: s.figurFarbe(rolle),
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 20),
          child: SpickzettelInhalt(sitzung: s, rolle: rolle, runde: s.runde, befragungZuerst: _befragt != null),
        ),
      );

  /// Zudecken; kam der Blick von einer Befragung, ist sie damit beantwortet.
  void _zudecken(String rolle) {
    final id = _befragt;
    setState(() => _befragt = null);
    s.verdecken();
    if (id != null && s.befragungVon(rolle)?.id == id) s.befragungErledigt(id);
  }

  /// Kopfblatt eines Abschnitts mit Klammer: Überschrift und Hinweis.
  Widget _kopfblatt(String titel, String hinweis) => MBlatt(
        klammer: true,
        samen: 17 + s.runde + titel.length,
        neigung: -0.004,
        padding: const EdgeInsets.fromLTRB(20, 30, 20, 8),
        child: LayoutBuilder(
          builder: (context, box) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(titel, style: MPapierSchrift.ueberschrift.copyWith(fontSize: ganzeWorteGroesse(context, titel, MPapierSchrift.ueberschrift, box.maxWidth))),
              const SizedBox(height: 4),
              Text(hinweis, style: MPapierSchrift.leise),
              const SizedBox(height: 12),
            ],
          ),
        ),
      );

  /// Die Pflichtgespräche der Runde: ein Kopfblatt, dann je Rolle eine Karteikarte.
  Widget _gespraeche() {
    final liste = s.gespraeche(s.runde);
    final rollen = [
      for (final r in s.besetzt)
        if (liste.any((z) => z.gespraech.rolle == r)) r,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MBlatt(
          klammer: true,
          samen: 17 + s.runde,
          neigung: -0.004,
          padding: const EdgeInsets.fromLTRB(20, 30, 20, 8),
          child: LayoutBuilder(
            builder: (context, box) {
              final titel = s.ui('ui.runde.gespraeche');
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(titel, style: MPapierSchrift.ueberschrift.copyWith(fontSize: ganzeWorteGroesse(context, titel, MPapierSchrift.ueberschrift, box.maxWidth))),
                  const SizedBox(height: 4),
                  Text(s.ui('ui.runde.hinweis'), style: MPapierSchrift.leise),
                  const SizedBox(height: 12),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 14),
        for (var i = 0; i < rollen.length; i++) ...[
          _rollenKarte(i, rollen[i], [
            for (final z in liste)
              if (z.gespraech.rolle == rollen[i]) z,
          ]),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  /// Karteikarte einer Rolle: Fotoabzug, Name am Tisch und Figur, darunter die
  /// Gespräche. Der Farbcode der Figur läuft als Registerstreifen am Rand.
  Widget _rollenKarte(int i, String rolle, List<({Gespraech gespraech, String partner})> zeilen) {
    // Ohne eingetragenen Spielernamen ist der Name schon der Figurenname: dann nur der Titel.
    final name = s.spielerName(rolle) == s.figurName(rolle) ? '' : s.figurName(rolle);
    final figur = [name, s.figurTitel(rolle)].where((t) => t.isNotEmpty).join(' · ');
    return MBlatt(
      art: PapierArt.karteikarte,
      kopfLinie: 7,
      linien: false,
      randFarbe: s.figurFarbe(rolle),
      neigung: i.isEven ? -0.003 : 0.003,
      samen: i + 5,
      padding: const EdgeInsets.fromLTRB(12, 12, 14, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          LayoutBuilder(
            builder: (context, box) {
              final foto = MFotoabzug(look: s.figurAussehen(rolle), groesse: 52, neigung: i.isEven ? -0.05 : 0.04, akzent: s.figurFarbe(rolle));
              final namen = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  MGanzeWorte(s.spielerName(rolle), stil: MPapierSchrift.ueberschrift.copyWith(fontSize: 20)),
                  if (figur.isNotEmpty) MGanzeWorte(figur, stil: MPapierSchrift.leise),
                ],
              );
              // Schmal oder mit großer Schrift steht der Name unter dem Abzug.
              if (_schmal(context, box.maxWidth)) {
                return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [foto, const SizedBox(height: 8), namen]);
              }
              return Row(children: [foto, const SizedBox(width: 14), Expanded(child: namen)]);
            },
          ),
          const SizedBox(height: 8),
          for (var j = 0; j < zeilen.length; j++) ...[
            Container(height: 1, color: MRoh.tinte.withValues(alpha: j == 0 ? 0.3 : 0.14)),
            _zeile(zeilen[j].gespraech, zeilen[j].partner, j),
          ],
        ],
      ),
    );
  }

  /// Ein Gespräch: Abzug der Gesprächsperson, Sprecher und Partner, darunter
  /// das Thema in Schreibmaschine. Ziel und Eröffnungssatz stehen nur im
  /// eigenen Dossier.
  Widget _zeile(Gespraech g, String partner, int j) {
    final foto = s.kanon.figur(partner) == null
        ? null
        : MFotoabzug(look: s.figurAussehen(partner), groesse: 34, neigung: j.isEven ? 0.04 : -0.035, akzent: s.figurFarbe(partner));
    final paarung = s.ui('ui.runde.paarung', {'sprecher': s.spielerName(g.rolle), 'partner': s.personAmTisch(partner)});
    final stil = MPapierSchrift.ueberschrift.copyWith(fontSize: 17, height: 1.3);
    return Padding(
      key: ValueKey(g.id),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: LayoutBuilder(
        builder: (context, box) {
          final schmal = _schmal(context, box.maxWidth);
          final texte = LayoutBuilder(
            builder: (context, innen) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(paarung, style: stil.copyWith(fontSize: ganzeWorteGroesse(context, paarung, stil, innen.maxWidth, minimum: 13))),
                const SizedBox(height: 4),
                MGanzeWorte(g.thema, stil: MPapierSchrift.maschine.copyWith(fontSize: 14)),
              ],
            ),
          );
          // Schmal oder mit großer Schrift liegt der Abzug über den Zeilen.
          if (schmal) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (foto != null) ...[Align(alignment: Alignment.centerLeft, child: foto), const SizedBox(height: 8)],
                texte,
              ],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 50, child: foto == null ? null : Center(child: foto)),
              const SizedBox(width: 12),
              Expanded(child: texte),
            ],
          );
        },
      ),
    );
  }

  /// Schmal im Verhältnis zur Schriftgröße: Abzüge stehen dann über dem Text.
  bool _schmal(BuildContext context, double breite) => schmalFuerSchrift(context, breite);
}
