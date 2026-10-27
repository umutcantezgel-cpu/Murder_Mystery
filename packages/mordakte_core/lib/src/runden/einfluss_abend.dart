// Die Einfluss-Schicht „Dein Moment“ in einer laufenden Partie (Finale §3.1–§3.10, §3.14): verbindet den
// reinen EinflussStand mit Ablauf (SpielZusatz) und Zugschicht. Den Pfad liest sie nur, wo die Kanon-Engine
// Fakten des Detektivs bestimmt (sichtbare Fakten); jede vor dem Finale sichtbare Wirkung hängt allein an
// Zügen, Salz-Strömen und den öffentlichen Daten der Optionen (Beweis: einfluss_pfadblind_test).
import '../party/ablauf.dart';
import '../party/entscheidungen.dart';
import '../party/gruppenwahl.dart' show Qualitaet;
import 'einfluss.dart';
import 'einfluss_ziele.dart';
import 'wuerfel.dart';
import 'zugschicht.dart';

/// Kosten und Grenzen der Zugschicht mit Einfluss-Schicht (Finale §3.4, §3.7).
ZugParameter einflussZugParameter(EinflussZahlen z) => ZugParameter(
      rundenzeit: z.rundenMinuten,
      modBoden: z.modBoden,
      modDeckel: z.modDeckel,
      umwegBonus: z.umwegBonus,
      uebertragHoechstens: z.uebertragHoechstens,
      minutenBoden: z.minutenBoden,
      zoegert: z.zoegertMinuten,
      mauert: z.mauertMinuten,
    );

/// Wie sich eine Befragung mit Tischwert verhält (Finale §3.4).
enum BefragungsLage { redselig, zoegert, mauert }

/// Was die Schicht an einem aufgedeckten Pflichtzug zeigt (Finale §3.4, §3.5): öffentlich am Zug.
class EinflussFund {
  /// Tischwert der Option, wie er als Abzeichen an ihr stand.
  final int tisch;

  /// Neu gezeigte Randnotizen (Zusatzfund, Redselig).
  final List<String> randnotizen;

  /// Öffentlich genannter Decker und wen er deckte (er selbst bei Selbst-Decken).
  final String? ertappt, ertapptZiel;

  /// Mindestens ein Pech („Die Spur verwischt“).
  final bool verwischt;

  /// Die Fakten kommen erst im Zwischenresümee (Umweg oder „mauert“).
  final bool verzoegert;
  final BefragungsLage? befragung;

  const EinflussFund({
    required this.tisch,
    this.randnotizen = const [],
    this.ertappt,
    this.ertapptZiel,
    this.verwischt = false,
    this.verzoegert = false,
    this.befragung,
  });

  Map<String, Object?> toJson() => {
        'tisch': tisch,
        'randnotizen': randnotizen,
        'ertappt': ?ertappt,
        'ertapptZiel': ?ertapptZiel,
        'verwischt': verwischt,
        'verzoegert': verzoegert,
        'befragung': ?befragung?.name,
      };

  /// Kennzeichen aus der Ansicht des Raums ([toJson]); [FormatException] bei falscher Form.
  factory EinflussFund.ausJson(Map<String, Object?> j) {
    final tisch = j['tisch'], notizen = j['randnotizen'] ?? const <Object?>[];
    final ertappt = j['ertappt'], ziel = j['ertapptZiel'], befragung = j['befragung'];
    if (tisch is! int || notizen is! List || notizen.any((n) => n is! String) || (ertappt != null && ertappt is! String) ||
        (ziel != null && ziel is! String) || (befragung != null && befragung is! String)) {
      throw const FormatException('EinflussFund: tisch, randnotizen, ertappt, ertapptZiel, befragung');
    }
    final lage = befragung == null ? null : BefragungsLage.values.where((l) => l.name == befragung).firstOrNull;
    if (befragung != null && lage == null) throw FormatException('EinflussFund: unbekannte Befragungslage $befragung');
    return EinflussFund(
      tisch: tisch,
      randnotizen: List.unmodifiable(notizen.cast<String>()),
      ertappt: ertappt as String?,
      ertapptZiel: ziel as String?,
      verwischt: j['verwischt'] == true,
      verzoegert: j['verzoegert'] == true,
      befragung: lage,
    );
  }
}

/// Wortlaut eines Fakts, wie ihn eine Fundkarte zeigt (Beobachtung oder was die Spur zeigt). Für Fakten aus
/// dem Auspacken (§3.6), die es in jeder Fassung des Falls gibt; so liest ein Gerät sie aus seiner Akte.
String faktWortlaut(Ermittlung erm, String faktId) {
  final f = erm.fakten[faktId] ?? (throw ArgumentError('unbekannter Fakt $faktId'));
  final quelle = f.beobachtung != null ? erm.beobachtungJson(f.beobachtung!) : erm.spurJson(f.spur!);
  final text = quelle?[f.beobachtung != null ? 'text' : 'zeigt'];
  return text is String ? text : throw ArgumentError('Fakt $faktId ohne Wortlaut');
}

/// Die Schicht eines Abends: Züge, Folgen, Tischwerte, Randnotizen, Verzögerungen, Ertappte, Nachfragen,
/// Ziele und Auszeichnungen. Als [SpielZusatz] am [Spiel] bestimmt sie die sichtbaren Fakten, hängt die
/// Folgen und das Ende an, ersetzt die Gruppenwahl durch das Flüstern und verschiebt das Ende.
class EinflussAbend implements SpielZusatz {
  EinflussAbend(this.regeln, this.spiel, {required this.salz, required List<int> Function() restJeRunde})
      : _restJeRunde = restJeRunde,
        stand = EinflussStand(regeln, besetzt: spiel.besetzt),
        ziele = EinflussZiele.aus(regeln) {
    if (salz.isEmpty) throw ArgumentError('Die Einfluss-Schicht braucht ein Salz.');
  }

  final EinflussRegeln regeln;
  final Spiel spiel;

  /// Salz des Abends: Ströme `einfluss:<salz>:<rolle>:<runde>` (Bots) und `ertappt:<salz>:<entscheidung>`.
  final String salz;
  final EinflussStand stand;
  final EinflussZiele ziele;
  final List<int> Function() _restJeRunde;

  /// Entscheidungen, deren Fakten bis zum Zwischenresümee ihrer Runde warten.
  final Set<String> _verzoegert = {};
  final Map<String, List<Aufdeckung>> _nachgereicht = {};
  final List<String> _randnotizen = [];
  final Map<String, EinflussFund> _funde = {};
  final List<({String option, String notiz})> _nachfragen = [];

  /// Ertappte in der Reihenfolge der Suchen.
  final List<({int runde, String rolle, String entscheidung})> _ertappt = [];

  /// Gezeigte Randnotizen in Reihenfolge (Auspacken, Zusatzfunde, Redselig, Nachfragen).
  List<String> get randnotizen => List.unmodifiable(_randnotizen);

  /// Kennzeichen je aufgedeckter Entscheidung.
  Map<String, EinflussFund> get funde => Map.unmodifiable(_funde);

  /// Gestellte Nachfragen in Reihenfolge.
  List<({String option, String notiz})> get nachfragen => List.unmodifiable(_nachfragen);

  Ermittlung get _erm => spiel.ermittlung;

  /// Funde verzögerter Entscheidungen von [runde], ab dem Zwischenresümee zu zeigen (vorher leer).
  Map<String, List<Aufdeckung>> nachgereicht(int runde) => {
        for (final e in _nachgereicht.entries)
          if (_erm.entscheidung(e.key).runde == runde && _freigegeben(runde)) e.key: List.unmodifiable(e.value),
      };

  bool _freigegeben(int runde) => spiel.runde > runde || spiel.phase.index >= PartyPhase.resuemee.index;

  @override
  bool nachgereichtIn(int runde) => _verzoegert.any((e) => _erm.entscheidung(e).runde == runde);

  // ------------------------------------------------------------- SpielZusatz

  @override
  Set<String> sichtbar(Spiel s, int bis) {
    final aus = <String>{};
    for (final e in s.gewaehlt.entries) {
      final runde = _erm.entscheidung(e.key).runde;
      if (runde > bis || (_verzoegert.contains(e.key) && !_freigegeben(runde))) continue;
      aus.addAll(_erm.faktenVon(e.value, s.pfad));
    }
    aus.addAll(geliefert(bis));
    return aus;
  }

  /// Fakten aus dem Auspacken bis Runde [bis], soweit es sie im Fall gibt (der Prüfer verlangt: in allen).
  @override
  Set<String> geliefert(int bis) => {
        for (final f in stand.folgen)
          if (f.runde <= bis)
            for (final fakt in f.fakten)
              if (_erm.gibtEs(fakt, spiel.pfad)) fakt,
      };

  @override
  List<String> nachWechsel(Spiel s, PartyPhase von) {
    if (von == PartyPhase.gespraeche && s.phase == PartyPhase.entscheidungen) return _folgen(s.runde);
    if (von == PartyPhase.finale && s.phase == PartyPhase.aufloesung) return _aufloesung();
    return const [];
  }

  @override
  int get tischbonus => stand.tischbonus;

  @override
  bool get ueberspringeGruppenwahl => true;

  @override
  Qualitaet? bonusQualitaet(int runde) {
    final f = stand.folgenVon(runde);
    if (f == null) return null;
    return switch (fluesternAus(regeln.zahlen, f.zusammenhaltZuwachs)) {
      Fluestern.wahr => Qualitaet.wahr,
      Fluestern.neutral => Qualitaet.neutral,
      Fluestern.still => null,
    };
  }

  // ------------------------------------------------------------- Moment und Folgen

  /// Zug einer besetzten Rolle im Moment der laufenden Runde (Finale §3.2): nur in den Gesprächen,
  /// änderbar bis zu den Folgen.
  void zugSetzen(EinflussZug zug) {
    if (spiel.phase != PartyPhase.gespraeche) throw StateError('Ein Zug geht nur in den Gesprächen.');
    stand.setze(spiel.runde, zug);
  }

  /// Öffentliches Bild für die Bots (§3.11): sichtbare Fakten und öffentliche Restmenge.
  BotLage botLage() {
    final rest = spiel.restmenge();
    return stand.botLage(sichtbar: spiel.sichtbareFakten(), verdaechtig: [for (final k in regeln.kern) if (rest.contains(k)) k]);
  }

  List<String> _folgen(int runde) {
    // Wer bis jetzt nicht zog, zieht als Bot; alle Bots sehen dasselbe Bild vor der Runde.
    final lage = botLage();
    for (final r in stand.besetzt) {
      if (stand.zug(runde, r) == null) stand.setze(runde, botZug(regeln, salz: salz, rolle: r, runde: runde, lage: lage));
    }
    final f = stand.auswerten(runde);
    for (final n in f.notizen) {
      if (!_randnotizen.contains(n)) _randnotizen.add(n);
    }
    return spiel.erzaehler.einflussFolgen(
      runde: runde,
      auspacken: [for (final a in f.auspacken) a.figur],
      ablenker: f.ablenker,
      geruechte: [for (final g in f.geruechte) (figur: g.figur, laut: g.laut)],
      zusammenhaltZuwachs: f.zusammenhaltZuwachs,
      spukZuwachs: f.spukZuwachs,
      ereignisse: [for (final e in f.ereignisse) e.id],
    );
  }

  // ------------------------------------------------------------- Ermittlung

  /// Tischwert der Option [optionId] in der laufenden Runde (0 vor den Folgen).
  int tisch(String optionId) => stand.tisch(spiel.runde, optionId);

  /// Tischwert, mit dem eine Wahl in die Zugschicht geht: Eine Suche ignoriert negatives T, solange ein
  /// Kerzenschein wartet (Finale §3.8). Ändert nichts.
  int tischFuerWahl(String optionId, {required bool suche}) {
    final t = tisch(optionId);
    return suche && stand.kerzenschein && t < 0 ? 0 : t;
  }

  /// Eine Suche wurde gewählt: Ein wartender Kerzenschein ist damit verbraucht.
  void sucheGewaehlt() => stand.kerzenscheinNehmen();

  /// Bis zu [anzahl] noch nicht gezeigte Randnotizen aus dem Vorrat von [optionId] (Finale §3.5).
  List<String> _ziehe(String optionId, int anzahl) {
    final aus = <String>[];
    for (final n in regeln.randnotizen[optionId] ?? const <String>[]) {
      if (aus.length >= anzahl) break;
      if (!_randnotizen.contains(n)) {
        _randnotizen.add(n);
        aus.add(n);
      }
    }
    return aus;
  }

  /// Wertet einen eben aufgedeckten Pflichtzug aus (Finale §3.4): Suche mit ihren [kennzeichen]
  /// (Zusatzfund, Ertappt, Verzögerung nach Umweg) oder Befragung nach dem Tischwert (redselig, zögert,
  /// mauert). [funde] sind die Funde der Kanon-Engine; verzögerte erscheinen erst im Zwischenresümee.
  EinflussFund aufdecken(String entscheidung, String optionId, {required bool suche, SuchKennzeichen? kennzeichen, required List<Aufdeckung> funde}) {
    final runde = spiel.runde;
    final t = tisch(optionId);
    final z = regeln.zahlen;
    EinflussFund fund;
    if (suche) {
      final k = kennzeichen ?? (throw StateError('Suche $entscheidung ohne Kennzeichen'));
      if (k.stufe == Stufe.erfolg) stand.erfolgMelden(runde, optionId);
      var notizen = const <String>[];
      String? ertappt, ziel;
      if (k.zusatzfund) {
        notizen = _ziehe(optionId, stand.folgenVon(runde)!.fledermaus ? 2 : 1);
        ertappt = ertapptAuswahl(salz: salz, entscheidung: entscheidung, decker: stand.decker(runde, optionId));
        if (ertappt != null) {
          stand.ertapptMelden(ertappt);
          ziel = stand.zug(runde, ertappt)!.ziel;
          _ertappt.add((runde: runde, rolle: ertappt, entscheidung: entscheidung));
        }
      }
      fund = EinflussFund(
        tisch: t,
        randnotizen: List.unmodifiable(notizen),
        ertappt: ertappt,
        ertapptZiel: ziel,
        verwischt: k.verwischt,
        verzoegert: k.verzoegert,
      );
    } else {
      final lage = t >= z.redseligAb
          ? BefragungsLage.redselig
          : t <= -2
              ? BefragungsLage.mauert
              : t == -1
                  ? BefragungsLage.zoegert
                  : null;
      fund = EinflussFund(
        tisch: t,
        randnotizen: List.unmodifiable(lage == BefragungsLage.redselig ? _ziehe(optionId, 1) : const <String>[]),
        verzoegert: lage == BefragungsLage.mauert,
        befragung: lage,
      );
    }
    if (fund.verzoegert) {
      _verzoegert.add(entscheidung);
      _nachgereicht[entscheidung] = List.unmodifiable(funde);
    }
    _funde[entscheidung] = fund;
    return fund;
  }

  // ------------------------------------------------------------- Nachfragen (§3.5)

  /// Restminuten am Ende von Runde 3, sobald sie feststehen.
  int? get restNachRunde3 {
    final r = _restJeRunde();
    return r.length >= 3 ? r[2] : null;
  }

  bool get _nachfrageZeit => spiel.phase == PartyPhase.anklage && spiel.angeklagt == null;

  /// Noch offene Nachfragen (nach Runde 3, vor der Anklage; sonst 0).
  int get nachfragenOffen {
    final rest = restNachRunde3;
    if (!_nachfrageZeit || rest == null) return 0;
    final n = stand.nachfragen(rest) - _nachfragen.length;
    return n < 0 ? 0 : n;
  }

  /// Gewählte Optionen (Kanon-Reihenfolge) mit noch nicht gezeigter Randnotiz, auch verlorene.
  List<String> get nachfrageOptionen => [
        for (final e in _erm.entscheidungen)
          if (spiel.gewaehlt[e.id] case final o? when (regeln.randnotizen[o] ?? const <String>[]).any((n) => !_randnotizen.contains(n))) o,
      ];

  /// Eine Nachfrage zu [optionId]: zeigt deren erste noch nicht gezeigte Randnotiz.
  String nachfrage(String optionId) {
    if (nachfragenOffen <= 0) throw StateError('Keine Nachfrage offen.');
    if (!nachfrageOptionen.contains(optionId)) throw ArgumentError('Zu $optionId gibt es nichts nachzufragen.');
    final n = _ziehe(optionId, 1).single;
    _nachfragen.add((option: optionId, notiz: n));
    return n;
  }

  // ------------------------------------------------------------- Ende

  /// Protokoll der Nacht: sichtbare Fakten, Anklage, Rest nach Runde 3 und, ab dem Finale, wen die
  /// Auflösung nennt.
  NachtProtokoll protokoll() => stand.protokoll(
        sichtbar: spiel.sichtbareFakten(),
        angeklagt: spiel.angeklagt,
        rest: restNachRunde3,
        aufloesung: spiel.phase.index >= PartyPhase.finale.index ? spiel.pfad : null,
      );

  /// Stand der zwei Sterne einer Rolle, privat jederzeit (§3.9).
  List<ZielStand> zielStand(String rolle) {
    final p = protokoll();
    return [for (final z in ziele.von(rolle)) ziele.stand(z, p)];
  }

  /// Live-Stand der zwei Sterne von [rolle] mit dem Ziel (Kennung, Nummer, Text-Schlüssel), privat
  /// jederzeit (§3.9): offen, erreicht oder verloren.
  List<({EinflussZiel ziel, ZielStand stand})> zielStaende(String rolle) {
    final p = protokoll();
    return [for (final z in ziele.von(rolle)) (ziel: z, stand: ziele.stand(z, p))];
  }

  // ------------------------------------------------------------- Privat und Blasen (§3.11, §3.12)

  /// Rollen, die in den Suchen von [runde] ertappt wurden, in der Reihenfolge der Suchen.
  List<String> ertapptIn(int runde) => [for (final e in _ertappt) if (e.runde == runde) e.rolle];

  /// Private Nachrichten an [rolle] in Reihenfolge (§3.12): je ausgewertete Runde zuerst die aus den Folgen
  /// („hält zu dir“, Lauschergebnis, „Dein Zug wirkte …“), danach „ertappt“ ([PrivatArt.ertappt]) für jede
  /// Suche dieser Runde, in der die Rolle öffentlich genannt wurde. Nur für diese Rolle bestimmt.
  List<({int runde, PrivatNachricht nachricht})> privatFuer(String rolle) => [
        for (final f in stand.folgen) ...[
          for (final n in f.privat[rolle] ?? const <PrivatNachricht>[]) (runde: f.runde, nachricht: n),
          for (final e in _ertappt)
            if (e.runde == f.runde && e.rolle == rolle) (runde: f.runde, nachricht: const PrivatNachricht(PrivatArt.ertappt)),
        ],
      ];

  /// Reaktionsblasen der Bots zu den Folgen von [runde] (§3.11, [botBlasen]); Anlass „ertappt“ aus den Suchen
  /// der Runde davor. Wer ein Bot ist, sagt der Aufrufer ([istBot]): an einem Gerät die Rollen ohne
  /// Spieler, online die Rollen, die beim Wechsel ohne Menschen waren.
  List<BotBlase> blasen(int runde, {required bool Function(String rolle) istBot}) {
    final f = stand.folgenVon(runde) ?? (throw StateError('Runde $runde ist nicht ausgewertet'));
    return botBlasen(regeln, f, salz: salz, istBot: istBot, ertappt: ertapptIn(runde - 1));
  }

  /// Erreichte Sterne je besetzter Rolle (nach der Anklage endgültig).
  Map<String, int> sterne() => ziele.alleSterne(protokoll());

  /// Auszeichnungen (§3.10); Spürnasen erst ab dem Finale.
  Auszeichnungen auszeichnungen() => auszeichnen(protokoll(), regeln, sterne: sterne());

  List<String> _aufloesung() {
    final sterne = this.sterne();
    final a = auszeichnen(protokoll(), regeln, sterne: sterne);
    return spiel.erzaehler.einflussAufloesung(
      epiloge: [for (final f in stand.besetzt) (figur: f, erreicht: (sterne[f] ?? 0) >= 1)],
      stern: a.stern,
      spuernasen: a.spuernasen,
      schlossgeist: a.schlossgeist,
      treueSeele: a.treueSeele,
      morgen: stand.morgen.name,
    );
  }
}
