// „Dein Moment“ – die Einfluss-Schicht (Finale §3): Regeln, Daten und reiner Zustand der Züge.
//
// Eingaben sind nur die Züge der besetzten Rollen, die statischen, öffentlichen Daten der Optionen
// (`content/party/zusatz/<akte>/einfluss.json`) und Salz-Ströme. Nichts hier kennt die Lösung des
// Falls, seine Kennung oder die Güte eines Hinweises (Architekturwächter in einfluss_regeln_test).
// Ohne Schicht wird nichts davon geladen; die übrigen Teile des Kerns bleiben unverändert.
import '../party/entscheidungen.dart';
import '../util/rng.dart';

/// Formatkennung von `einfluss.json`.
const einflussFormat = 'einfluss/1';

/// Kein Tipp („Keine Ahnung“) in Runde 3.
const tippKeiner = 'keiner';

/// Zugarten des Moments (§3.2). [abgewartet] gilt, wer bis zur Frist nicht zieht: ohne Wirkung, nie gezeigt.
enum ZugArt {
  zeigen,
  decken,
  helfen,
  auspacken,
  ablenken,
  lauschen,
  abgewartet;

  /// Art aus ihrem Namen, sonst `null`.
  static ZugArt? lesen(Object? name) => values.where((a) => a.name == name).firstOrNull;

  /// Die sechs wählbaren Arten (ohne [abgewartet]).
  static List<ZugArt> get waehlbar => [for (final a in values) if (a != abgewartet) a];
}

/// Wen ein Zug treffen darf.
enum ZielRegel {
  /// Kein Ziel (helfen, auspacken, ablenken).
  keins,

  /// Eine andere besetzte Figur (zeigen, lauschen).
  andere,

  /// Jede besetzte Figur, auch die eigene (decken).
  jede,
}

/// Die beiden Leisten (§3.8), je 0 bis [EinflussZahlen.leisteHoechstens].
enum Leiste { zusammenhalt, spuk }

/// Besondere Wirkung eines Ereignisses neben Minuten und Nachfragen.
enum EreignisWirkung {
  /// Die nächste Suche ignoriert negatives T.
  kerzenschein,

  /// Diese Runde zählt negatives T doppelt (Deckel).
  fledermaus,
}

/// Was im Bonus-Abschnitt geflüstert wird (§3.8): je nach Zuwachs des Zusammenhalts.
enum Fluestern { wahr, neutral, still }

/// Fassung des Morgens nach dem Abend (§3.10).
enum MorgenVariante { warm, chaotisch, gemischt }

/// Private Nachricht an eine Rolle (§3.12).
enum PrivatArt {
  haeltZuDir('haelt_zu_dir'),
  mehrereHalten('mehrere_halten'),
  gelauscht('gelauscht'),
  wirkte('wirkte'),
  ohneFolgen('ohne_folgen'),
  ertappt('ertappt');

  /// Teil des Text-Schlüssels `einfluss.privat.<schluessel>`.
  final String schluessel;
  const PrivatArt(this.schluessel);
}

/// Lauschergebnis ohne Ziel und bei abgewartet („Änderungen“ 1): `einfluss.privat.gelauscht.<variante>`.
const lauschOhneZiel = 'ohne_ziel', lauschAbgewartet = 'abgewartet';

/// Anlässe der Reaktionsblasen der Bots (`einfluss.bot.<figur>.<anlass>`, §3.11).
const botAnlaesse = ['ertappt', 'geruecht', 'freund_gestanden', 'ablenken'];

/// Ein Zug einer Rolle in einer Runde; [tipp] nur in der Tipp-Runde (Kernfigur oder [tippKeiner]).
class EinflussZug {
  final String rolle;
  final ZugArt art;
  final String? ziel;
  final String? tipp;
  const EinflussZug(this.rolle, this.art, {this.ziel, this.tipp});

  /// Abwarten ohne Wirkung.
  const EinflussZug.abgewartet(this.rolle)
      : art = ZugArt.abgewartet,
        ziel = null,
        tipp = null;

  factory EinflussZug.ausJson(Map<String, Object?> j) {
    final art = ZugArt.lesen(j['art']) ?? (throw FormatException('unbekannte Zugart ${j['art']}'));
    final rolle = j['rolle'], ziel = j['ziel'], tipp = j['tipp'];
    if (rolle is! String || (ziel != null && ziel is! String) || (tipp != null && tipp is! String)) {
      throw const FormatException('Zug: rolle, ziel und tipp sind Zeichenketten');
    }
    return EinflussZug(rolle, art, ziel: ziel as String?, tipp: tipp as String?);
  }

  Map<String, Object?> toJson() => {'rolle': rolle, 'art': art.name, 'ziel': ?ziel, 'tipp': ?tipp};

  @override
  bool operator ==(Object other) => other is EinflussZug && other.rolle == rolle && other.art == art && other.ziel == ziel && other.tipp == tipp;

  @override
  int get hashCode => Object.hash(rolle, art, ziel, tipp);

  @override
  String toString() => 'EinflussZug${toJson()}';
}

/// Regel einer Zugart aus `arten` (§3.2): Ziel, Tischstimme, Nachtminuten, Leistengewichte.
class ZugArtRegel {
  final ZugArt art;
  final ZielRegel ziel;

  /// Tischstimme auf Optionen mit dem Ziel im Bezug (zeigen +1, decken −1).
  final int tisch;

  /// Nachtminuten je Zug (helfen +3, ablenken −4); gedeckelt je Runde.
  final int minuten;

  /// Gewicht in K (Zusammenhalt) und L (Spuk), §3.8.
  final int zusammenhalt, spuk;

  /// Nur einmal am Abend (auspacken).
  final bool einmal;

  const ZugArtRegel(this.art, {required this.ziel, this.tisch = 0, this.minuten = 0, this.zusammenhalt = 0, this.spuk = 0, this.einmal = false});
}

/// Schwelle des Leistenzuwachses: [zuwachs], wenn faktor · Summe ≥ gegen · n_eff.
class LeistenSchwelle {
  final int zuwachs, faktor, gegen;
  const LeistenSchwelle(this.zuwachs, this.faktor, this.gegen);
}

/// Ein Ereignis einer Leiste (§3.8): einmal am Abend, sobald die Leiste [stufe] erreicht.
class EinflussEreignis {
  final String id;
  final Leiste leiste;
  final int stufe;

  /// Nachtminuten in dieser Runde (Boden gilt).
  final int minuten;

  /// Zusätzliche Nachfragen nach Runde 3.
  final int nachfragen;
  final EreignisWirkung? wirkung;

  /// Erzwingt die Fassung des Morgens.
  final MorgenVariante? morgen;

  const EinflussEreignis({required this.id, required this.leiste, required this.stufe, this.minuten = 0, this.nachfragen = 0, this.wirkung, this.morgen});
}

/// Persönlichkeit eines Bots (§3.11): Gewichte in Prozent und feste Ziele.
class BotPersona {
  /// Gewichte je Zugart, Summe 100 (auspacken nur, wo die Daten es nennen).
  final Map<ZugArt, int> gewichte;

  /// Ziel von decken (`ich` oder eine Figur), lauschen und zeigen; ohne Angabe gezogen.
  final String? decken, lauschen, zeigen;

  /// Auspacken in einer festen Runde mit [chance] Prozent.
  final ({int runde, int chance})? auspacken;

  const BotPersona({required this.gewichte, this.decken, this.lauschen, this.zeigen, this.auspacken});

  /// Freund: wen der Bot deckt, wenn es nicht er selbst ist.
  String? get freund => decken == null || decken == 'ich' ? null : decken;
}

/// Was eine Figur beim Auspacken liefert (§3.6): ein Fakt, eine Randnotiz oder beides.
class AuspackenQuelle {
  final String? fakt, notiz;
  const AuspackenQuelle({this.fakt, this.notiz});
}

/// Zahlen der Schicht (§3.3–§3.10) aus `einfluss.json` → `zahlen`.
class EinflussZahlen {
  /// m(n) = ⌈n / tischTeiler⌉; |T| ≤ tischDeckel.
  final int tischTeiler, tischDeckel;

  /// Grenzen des Suchmodifikators und Bonus im Anlauf nach einem Umweg (§3.4).
  final int modBoden, modDeckel, umwegBonus;

  /// Befragung: ab diesem T „Redselig“; Minuten bei „Zögert“ und „Mauert“.
  final int redseligAb, zoegertMinuten, mauertMinuten;

  /// Nachtminuten (§3.7): Grundbudget, Übertrag höchstens, Boden, Deckel für helfen und ablenken je Runde.
  final int rundenMinuten, uebertragHoechstens, minutenBoden, helfenHoechstens, ablenkenHoechstens;

  /// Leisten (§3.8): Höchststand und kleinstes n_eff.
  final int leisteHoechstens, nMindestens;
  final List<LeistenSchwelle> zusammenhaltSchwellen, spukSchwellen;

  /// Nachfragen nach Runde 3 (§3.5): je volle [nachfrageJeMinuten] Restminuten eine, höchstens [nachfragenHoechstens].
  final int nachfrageJeMinuten, nachfragenHoechstens;

  /// Ende (§3.10): Endwert höchstens; Tischbonus ab diesem Leistenstand.
  final int endwertHoechstens, tischbonusAb;

  /// Flüstern (§3.8): Zuwachs des Zusammenhalts für wahr und neutral.
  final int fluesternWahrAb, fluesternNeutralAb;

  /// Runde mit Tipp „Wer war's?“.
  final int tippRunde;

  const EinflussZahlen({
    required this.tischTeiler,
    required this.tischDeckel,
    required this.modBoden,
    required this.modDeckel,
    required this.umwegBonus,
    required this.redseligAb,
    required this.zoegertMinuten,
    required this.mauertMinuten,
    required this.rundenMinuten,
    required this.uebertragHoechstens,
    required this.minutenBoden,
    required this.helfenHoechstens,
    required this.ablenkenHoechstens,
    required this.leisteHoechstens,
    required this.nMindestens,
    required this.zusammenhaltSchwellen,
    required this.spukSchwellen,
    required this.nachfrageJeMinuten,
    required this.nachfragenHoechstens,
    required this.endwertHoechstens,
    required this.tischbonusAb,
    required this.fluesternWahrAb,
    required this.fluesternNeutralAb,
    required this.tippRunde,
  });

  /// m(n) = ⌈n / Teiler⌉ (§3.3).
  int tischMass(int n) => (n + tischTeiler - 1) ~/ tischTeiler;

  /// T(o) = sign(v) · min(Deckel, ⌊|v| / m(n)⌋) (§3.3).
  int tischwert(int v, int n) {
    final betrag = v.abs() ~/ tischMass(n);
    final t = betrag < tischDeckel ? betrag : tischDeckel;
    return v < 0 ? -t : t;
  }

  /// Zuwachs einer Leiste aus ihrer Summe (K oder L) bei [n] Rollen (§3.8).
  int zuwachs(Leiste l, int summe, int n) {
    final nEff = n < nMindestens ? nMindestens : n;
    for (final s in l == Leiste.zusammenhalt ? zusammenhaltSchwellen : spukSchwellen) {
      if (s.faktor * summe >= s.gegen * nEff) return s.zuwachs;
    }
    return 0;
  }

  /// Budget einer Runde (§3.7): Grund + Übertrag (ab Runde 2, gedeckelt) + Änderungen, nie unter dem Boden.
  int rundenBudget({required int runde, required int restVorher, required int aenderung}) {
    final uebertrag = runde < 2 || restVorher <= 0 ? 0 : (restVorher < uebertragHoechstens ? restVorher : uebertragHoechstens);
    final b = rundenMinuten + uebertrag + aenderung;
    return b < minutenBoden ? minutenBoden : b;
  }

  /// Suchmodifikator mit Tischwert (§3.4): ohne Tisch und Umweg genau [basis].
  int suchModifikator(int basis, {int tisch = 0, int umweg = 0}) {
    if (tisch == 0 && umweg == 0) return basis;
    final m = basis + tisch + umweg;
    return m < modBoden ? modBoden : (m > modDeckel ? modDeckel : m);
  }
}

/// Die Regeln und Daten der Schicht einer Akte (`einfluss.json`, §3.13), geprüft gegen die Ermittlung.
class EinflussRegeln {
  final Map<String, Object?> json;
  final String akte;
  final EinflussZahlen zahlen;
  final Map<ZugArt, ZugArtRegel> arten;

  /// Bezug je Option (§3.3): statische Figurenmenge.
  final Map<String, List<String>> bezug;

  /// Vorrat an Randnotizen je Option (§3.5), Beobachtungs-Kennungen.
  final Map<String, List<String>> randnotizen;
  final Map<String, AuspackenQuelle> auspacken;

  /// Fakten, die das eigene Geheimnis einer Figur öffentlich machen (§3.11 „Geheimnis bekannt“): der
  /// Auspack-Fakt und jeder Nebendelikt-Fakt der Figur. Statisch aus dem Kanon, in allen Fassungen gleich.
  final Map<String, Set<String>> geheimFakten;
  final List<EinflussEreignis> ereignisse;
  final Map<String, BotPersona> bots;

  /// Ziele je Figur, roh (§3.9); gelesen von `einfluss_ziele.dart`.
  final Map<String, List<({String id, Object? bedingung})>> ziele;

  /// Alle Figuren in Besetzungsreihenfolge und die Kernfiguren.
  final List<String> figuren, kern;

  /// Optionen je Runde (Kanon-Reihenfolge) und die Entscheidung jeder Option.
  final Map<int, List<String>> optionenJeRunde;
  final Map<String, String> entscheidungVon;

  /// Fakten und Beobachtungen, die es im Kanon gibt (für Ziele und Prüfer).
  final Set<String> faktIds, beobachtungIds;

  EinflussRegeln._({
    required this.json,
    required this.akte,
    required this.zahlen,
    required this.arten,
    required this.bezug,
    required this.randnotizen,
    required this.auspacken,
    required this.geheimFakten,
    required this.ereignisse,
    required this.bots,
    required this.ziele,
    required this.figuren,
    required this.kern,
    required this.optionenJeRunde,
    required this.entscheidungVon,
    required this.faktIds,
    required this.beobachtungIds,
  });

  /// Liest `einfluss.json` und prüft Format, Zahlen, Arten, Bezug-Optionen und alle Verweise
  /// gegen [erm]; Fehler als [FormatException]. Inhaltliche Prüfungen (Ausgewogenheit, Gleichheit der
  /// Quellen über alle Fassungen des Falls, Ziele, Texte) macht `pruefeEinfluss`.
  factory EinflussRegeln.ausJson(Map<String, Object?> j, Ermittlung erm) {
    if (j['format'] != einflussFormat) throw FormatException('format ${j['format']} statt $einflussFormat');
    final akte = _text(j, 'akte', 'einfluss');
    final figuren = [for (final r in erm.kanon.besetzungJson['reihenfolge'] as List) r as String];
    final figurSet = figuren.toSet();
    final kern = [...erm.kern];
    final optionenJeRunde = <int, List<String>>{};
    final entscheidungVon = <String, String>{};
    for (final e in erm.entscheidungen) {
      for (final o in e.optionen) {
        (optionenJeRunde[e.runde] ??= []).add(o.id);
        entscheidungVon[o.id] = e.id;
      }
    }
    final beobachtungIds = {for (final b in erm.kanon.beobachtungen) b['id'] as String};

    String figur(Object? f, String wo, {bool ichErlaubt = false}) {
      if (f is String && (figurSet.contains(f) || (ichErlaubt && f == 'ich'))) return f;
      throw FormatException('$wo: unbekannte Figur $f');
    }

    // Zahlen.
    final z = _map(j, 'zahlen', 'einfluss');
    final tisch = _map(z, 'tisch', 'zahlen');
    final wuerfel = _map(z, 'wuerfel', 'zahlen');
    final befragung = _map(z, 'befragung', 'zahlen');
    final minuten = _map(z, 'minuten', 'zahlen');
    final leisten = _map(z, 'leisten', 'zahlen');
    final nachfragen = _map(z, 'nachfragen', 'zahlen');
    final ende = _map(z, 'ende', 'zahlen');
    final fluestern = _map(z, 'fluestern', 'zahlen');
    List<LeistenSchwelle> schwellen(String name) {
      final l = leisten[name];
      if (l is! List || l.isEmpty) throw FormatException('zahlen.leisten.$name: Liste von Schwellen');
      final aus = [
        for (final (i, s) in l.indexed)
          LeistenSchwelle(
            _int(_alsMap(s, 'zahlen.leisten.$name[$i]'), 'zuwachs', 'zahlen.leisten.$name[$i]', min: 1),
            _int(_alsMap(s, 'zahlen.leisten.$name[$i]'), 'faktor', 'zahlen.leisten.$name[$i]', min: 1),
            _int(_alsMap(s, 'zahlen.leisten.$name[$i]'), 'gegen', 'zahlen.leisten.$name[$i]', min: 1),
          ),
      ];
      for (var i = 1; i < aus.length; i++) {
        if (aus[i].zuwachs >= aus[i - 1].zuwachs) throw FormatException('zahlen.leisten.$name: Zuwachs muss fallen');
      }
      return aus;
    }

    final zahlen = EinflussZahlen(
      tischTeiler: _int(tisch, 'teiler', 'zahlen.tisch', min: 1),
      tischDeckel: _int(tisch, 'deckel', 'zahlen.tisch', min: 1),
      modBoden: _int(wuerfel, 'modBoden', 'zahlen.wuerfel', max: 0),
      modDeckel: _int(wuerfel, 'modDeckel', 'zahlen.wuerfel', min: 0),
      umwegBonus: _int(wuerfel, 'umwegBonus', 'zahlen.wuerfel', min: 0),
      redseligAb: _int(befragung, 'redseligAb', 'zahlen.befragung', min: 1),
      zoegertMinuten: _int(befragung, 'zoegertMinuten', 'zahlen.befragung', min: 0),
      mauertMinuten: _int(befragung, 'mauertMinuten', 'zahlen.befragung', min: 0),
      rundenMinuten: _int(minuten, 'runde', 'zahlen.minuten', min: 1),
      uebertragHoechstens: _int(minuten, 'uebertragHoechstens', 'zahlen.minuten', min: 0),
      minutenBoden: _int(minuten, 'boden', 'zahlen.minuten', min: 0),
      helfenHoechstens: _int(minuten, 'helfenHoechstens', 'zahlen.minuten', min: 0),
      ablenkenHoechstens: _int(minuten, 'ablenkenHoechstens', 'zahlen.minuten', min: 0),
      leisteHoechstens: _int(leisten, 'hoechstens', 'zahlen.leisten', min: 1),
      nMindestens: _int(leisten, 'nMindestens', 'zahlen.leisten', min: 1),
      zusammenhaltSchwellen: schwellen('zusammenhalt'),
      spukSchwellen: schwellen('spuk'),
      nachfrageJeMinuten: _int(nachfragen, 'jeMinuten', 'zahlen.nachfragen', min: 1),
      nachfragenHoechstens: _int(nachfragen, 'hoechstens', 'zahlen.nachfragen', min: 0),
      endwertHoechstens: _int(ende, 'endwertHoechstens', 'zahlen.ende', min: 1),
      tischbonusAb: _int(ende, 'tischbonusAb', 'zahlen.ende', min: 1),
      fluesternWahrAb: _int(fluestern, 'wahrAb', 'zahlen.fluestern', min: 1),
      fluesternNeutralAb: _int(fluestern, 'neutralAb', 'zahlen.fluestern', min: 1),
      tippRunde: _int(z, 'tippRunde', 'zahlen', min: 1, max: 3),
    );
    if (zahlen.minutenBoden > zahlen.rundenMinuten) throw const FormatException('zahlen.minuten: Boden über dem Grundbudget');
    if (zahlen.fluesternNeutralAb > zahlen.fluesternWahrAb) throw const FormatException('zahlen.fluestern: neutral über wahr');
    if (zahlen.tischbonusAb > zahlen.leisteHoechstens) throw const FormatException('zahlen.ende: Tischbonus über dem Höchststand');

    // Arten: genau die sechs wählbaren Zugarten.
    final arten = <ZugArt, ZugArtRegel>{};
    final artenJson = j['arten'];
    if (artenJson is! List) throw const FormatException('arten: Liste');
    for (final (i, roh) in artenJson.indexed) {
      final a = _alsMap(roh, 'arten[$i]');
      final art = ZugArt.lesen(a['id']);
      if (art == null || art == ZugArt.abgewartet) throw FormatException('arten[$i]: unbekannte Zugart ${a['id']}');
      if (arten.containsKey(art)) throw FormatException('arten: ${art.name} doppelt');
      final ziel = ZielRegel.values.where((r) => r.name == a['ziel']).firstOrNull ?? (throw FormatException('arten.${art.name}: ziel keins|andere|jede'));
      arten[art] = ZugArtRegel(
        art,
        ziel: ziel,
        tisch: _int(a, 'tisch', 'arten.${art.name}', sonst: 0),
        minuten: _int(a, 'minuten', 'arten.${art.name}', sonst: 0),
        zusammenhalt: _int(a, 'zusammenhalt', 'arten.${art.name}', sonst: 0),
        spuk: _int(a, 'spuk', 'arten.${art.name}', min: 0, sonst: 0),
        einmal: a['einmal'] == true,
      );
      if (ziel == ZielRegel.keins && arten[art]!.tisch != 0) throw FormatException('arten.${art.name}: Tischstimme ohne Ziel');
    }
    if (arten.length != ZugArt.waehlbar.length) throw FormatException('arten: ${arten.length} statt ${ZugArt.waehlbar.length} Zugarten');

    // Bezug und Randnotizen: jede Option des Kanons genau einmal.
    Map<String, List<String>> jeOption(String name, String Function(Object?, String) eintrag, {int mindestens = 1, int? hoechstens}) {
      final roh = _map(j, name, 'einfluss');
      final aus = <String, List<String>>{};
      for (final e in roh.entries) {
        if (!entscheidungVon.containsKey(e.key)) throw FormatException('$name: unbekannte Option ${e.key}');
        final l = e.value;
        if (l is! List || l.length < mindestens || (hoechstens != null && l.length > hoechstens)) {
          throw FormatException('$name.${e.key}: $mindestens bis ${hoechstens ?? '…'} Einträge');
        }
        final werte = [for (final x in l) eintrag(x, '$name.${e.key}')];
        if (werte.toSet().length != werte.length) throw FormatException('$name.${e.key}: doppelter Eintrag');
        aus[e.key] = List.unmodifiable(werte);
      }
      for (final o in entscheidungVon.keys) {
        if (!aus.containsKey(o)) throw FormatException('$name: Option $o fehlt');
      }
      return Map.unmodifiable(aus);
    }

    String beobachtung(Object? b, String wo) {
      if (b is String && beobachtungIds.contains(b)) return b;
      throw FormatException('$wo: unbekannte Beobachtung $b');
    }

    final bezug = jeOption('bezug', figur);
    final randnotizen = jeOption('randnotizen', beobachtung, hoechstens: 2);

    // Auspacken: Figur → Fakt und/oder Randnotiz.
    final auspacken = <String, AuspackenQuelle>{};
    for (final e in _map(j, 'auspacken', 'einfluss').entries) {
      figur(e.key, 'auspacken');
      final a = _alsMap(e.value, 'auspacken.${e.key}');
      final fakt = a['fakt'], notiz = a['notiz'];
      if (fakt == null && notiz == null) throw FormatException('auspacken.${e.key}: fakt oder notiz');
      if (fakt != null && (fakt is! String || !erm.fakten.containsKey(fakt))) throw FormatException('auspacken.${e.key}: unbekannter Fakt $fakt');
      if (notiz != null) beobachtung(notiz, 'auspacken.${e.key}');
      auspacken[e.key] = AuspackenQuelle(fakt: fakt as String?, notiz: notiz as String?);
    }

    // Ereignisse.
    final ereignisse = <EinflussEreignis>[];
    final ereignisJson = j['ereignisse'];
    if (ereignisJson is! List) throw const FormatException('ereignisse: Liste');
    for (final (i, roh) in ereignisJson.indexed) {
      final e = _alsMap(roh, 'ereignisse[$i]');
      final id = _text(e, 'id', 'ereignisse[$i]');
      final leiste = Leiste.values.where((l) => l.name == e['leiste']).firstOrNull ?? (throw FormatException('ereignisse.$id: leiste'));
      final wirkung = e['wirkung'];
      final morgen = e['morgen'];
      final ev = EinflussEreignis(
        id: id,
        leiste: leiste,
        stufe: _int(e, 'stufe', 'ereignisse.$id', min: 1, max: zahlen.leisteHoechstens),
        minuten: _int(e, 'minuten', 'ereignisse.$id', sonst: 0),
        nachfragen: _int(e, 'nachfragen', 'ereignisse.$id', min: 0, sonst: 0),
        wirkung: wirkung == null ? null : (EreignisWirkung.values.where((w) => w.name == wirkung).firstOrNull ?? (throw FormatException('ereignisse.$id: wirkung $wirkung'))),
        morgen: morgen == null ? null : (MorgenVariante.values.where((m) => m.name == morgen).firstOrNull ?? (throw FormatException('ereignisse.$id: morgen $morgen'))),
      );
      if (ereignisse.any((x) => x.id == id || (x.leiste == ev.leiste && x.stufe == ev.stufe))) throw FormatException('ereignisse.$id: doppelt');
      ereignisse.add(ev);
    }

    // Bots.
    final bots = <String, BotPersona>{};
    for (final e in _map(j, 'bots', 'einfluss').entries) {
      figur(e.key, 'bots');
      final b = _alsMap(e.value, 'bots.${e.key}');
      final g = _alsMap(b['gewichte'], 'bots.${e.key}.gewichte');
      final gewichte = <ZugArt, int>{};
      for (final x in g.entries) {
        final art = ZugArt.lesen(x.key);
        if (art == null || art == ZugArt.abgewartet) throw FormatException('bots.${e.key}.gewichte: unbekannte Zugart ${x.key}');
        gewichte[art] = _int(g, x.key, 'bots.${e.key}.gewichte', min: 0, max: 100);
      }
      if (gewichte.values.fold(0, (a, b) => a + b) != 100) throw FormatException('bots.${e.key}.gewichte: Summe nicht 100');
      final ap = b['auspacken'];
      ({int runde, int chance})? auspackRegel;
      if (ap != null) {
        final m = _alsMap(ap, 'bots.${e.key}.auspacken');
        auspackRegel = (runde: _int(m, 'runde', 'bots.${e.key}.auspacken', min: 1, max: 3), chance: _int(m, 'chance', 'bots.${e.key}.auspacken', min: 1, max: 100));
      }
      String? ziel(String name, {bool ichErlaubt = false}) => b[name] == null ? null : figur(b[name], 'bots.${e.key}.$name', ichErlaubt: ichErlaubt);
      bots[e.key] = BotPersona(
        gewichte: Map.unmodifiable(gewichte),
        decken: ziel('decken', ichErlaubt: true),
        lauschen: ziel('lauschen'),
        zeigen: ziel('zeigen'),
        auspacken: auspackRegel,
      );
    }

    // Ziele: je Figur genau zwei, Kennung und Bedingung (Auswertung in einfluss_ziele.dart).
    final ziele = <String, List<({String id, Object? bedingung})>>{};
    for (final e in _map(j, 'ziele', 'einfluss').entries) {
      figur(e.key, 'ziele');
      final l = e.value;
      if (l is! List || l.length != 2) throw FormatException('ziele.${e.key}: genau zwei Sterne');
      ziele[e.key] = [
        for (final (i, x) in l.indexed)
          (id: _text(_alsMap(x, 'ziele.${e.key}[$i]'), 'id', 'ziele.${e.key}[$i]'), bedingung: _alsMap(x, 'ziele.${e.key}[$i]')['bedingung']),
      ];
    }

    return EinflussRegeln._(
      json: j,
      akte: akte,
      zahlen: zahlen,
      arten: Map.unmodifiable(arten),
      bezug: bezug,
      randnotizen: randnotizen,
      auspacken: Map.unmodifiable(auspacken),
      geheimFakten: Map.unmodifiable({
        for (final f in figuren)
          f: Set<String>.unmodifiable({
            ?auspacken[f]?.fakt,
            for (final x in erm.fakten.values)
              if (x.typ == 'nebendelikt' && x.personen.contains(f)) x.id,
          }),
      }),
      ereignisse: List.unmodifiable(ereignisse),
      bots: Map.unmodifiable(bots),
      ziele: Map.unmodifiable(ziele),
      figuren: List.unmodifiable(figuren),
      kern: List.unmodifiable(kern),
      optionenJeRunde: Map.unmodifiable({for (final e in optionenJeRunde.entries) e.key: List<String>.unmodifiable(e.value)}),
      entscheidungVon: Map.unmodifiable(entscheidungVon),
      faktIds: Set.unmodifiable(erm.fakten.keys),
      beobachtungIds: Set.unmodifiable(beobachtungIds),
    );
  }

  /// Optionen der Runde [runde].
  List<String> optionen(int runde) => optionenJeRunde[runde] ?? const [];

  /// Zulässige Tipps (§3.2): Kernfiguren und [tippKeiner].
  List<String> get tipps => [...kern, tippKeiner];
}

/// Ein Gerücht über eine Figur (§3.2): anonym, leise bei einem Zeigen, laut ab zweien.
class Geruecht {
  final String figur;
  final bool laut;
  const Geruecht(this.figur, {required this.laut});

  /// Gewicht für „meistberedet“ (leise 1, laut 2).
  int get gewicht => laut ? 2 : 1;

  Map<String, Object?> toJson() => {'figur': figur, 'laut': laut};
}

/// Eine private Nachricht an eine Rolle; [figur], [zug] und [ziel] nur beim Lauschen.
class PrivatNachricht {
  final PrivatArt art;
  final String? figur;
  final ZugArt? zug;
  final String? ziel;
  const PrivatNachricht(this.art, {this.figur, this.zug, this.ziel});

  /// Text-Schlüssel (§3.13, „Änderungen“ 1): Lauschen bei einem Zug ohne Ziel `….gelauscht.ohne_ziel`
  /// (`@figur`, `@zug`), bei abgewartet `….gelauscht.abgewartet` (`@figur`), sonst `einfluss.privat.<art>`.
  String get schluessel => switch (art) {
        PrivatArt.gelauscht when zug == ZugArt.abgewartet => 'einfluss.privat.gelauscht.$lauschAbgewartet',
        PrivatArt.gelauscht when ziel == null => 'einfluss.privat.gelauscht.$lauschOhneZiel',
        _ => 'einfluss.privat.${art.schluessel}',
      };

  Map<String, Object?> toJson() => {'art': art.schluessel, 'figur': ?figur, 'zug': ?zug?.name, 'ziel': ?ziel};
}

/// Eine Lieferung beim Auspacken (§3.6): öffentlich mit Namen.
class AuspackenLieferung {
  final String figur;
  final String? fakt, notiz;
  const AuspackenLieferung(this.figur, {this.fakt, this.notiz});

  Map<String, Object?> toJson() => {'figur': figur, 'fakt': ?fakt, 'notiz': ?notiz};
}

/// Zeile der Zugtafel des Erzählers (§3.12): wer was spielte, ohne Tipp.
class ZugTafelZeile {
  final String rolle;
  final ZugArt art;
  final String? ziel;
  const ZugTafelZeile(this.rolle, this.art, this.ziel);

  Map<String, Object?> toJson() => {'rolle': rolle, 'art': art.name, 'ziel': ?ziel};
}

/// Die Folgen einer Runde (§3.1, §3.8): was nach dem Moment bekannt wird, was sich ändert, wer was erfährt.
class EinflussFolgen {
  final int runde;

  /// Züge aller besetzten Rollen; wer nicht zog, hat abgewartet.
  final Map<String, EinflussZug> zuege;
  final List<Geruecht> geruechte;

  /// Tischwert je Option der Runde (wirksam, mit Fledermaus).
  final Map<String, int> tisch;
  final List<AuspackenLieferung> auspacken;

  /// Wer abgelenkt hat (öffentlich mit Namen), in Besetzungsreihenfolge.
  final List<String> ablenker;

  /// Nachtminuten durch helfen (≤ Deckel), ablenken (≥ −Deckel) und Ereignisse.
  final int minutenHelfen, minutenAblenken, minutenEreignisse;

  /// Summen K und L dieser Runde (§3.8).
  final int summeZusammenhalt, summeSpuk;
  final int zusammenhaltVorher, spukVorher, zusammenhaltZuwachs, spukZuwachs;

  /// In dieser Runde ausgelöste Ereignisse.
  final List<EinflussEreignis> ereignisse;
  final Map<String, List<PrivatNachricht>> privat;
  final List<ZugTafelZeile> tafel;

  const EinflussFolgen({
    required this.runde,
    required this.zuege,
    required this.geruechte,
    required this.tisch,
    required this.auspacken,
    required this.ablenker,
    required this.minutenHelfen,
    required this.minutenAblenken,
    required this.minutenEreignisse,
    required this.summeZusammenhalt,
    required this.summeSpuk,
    required this.zusammenhaltVorher,
    required this.spukVorher,
    required this.zusammenhaltZuwachs,
    required this.spukZuwachs,
    required this.ereignisse,
    required this.privat,
    required this.tafel,
  });

  /// Änderung des Budgets dieser Runde in Nachtminuten (vor dem Boden).
  int get minuten => minutenHelfen + minutenAblenken + minutenEreignisse;

  int get zusammenhalt => zusammenhaltVorher + zusammenhaltZuwachs;
  int get spuk => spukVorher + spukZuwachs;

  /// Fakten, die das Auspacken in die Funde legt.
  Set<String> get fakten => {for (final a in auspacken) ?a.fakt};

  /// Randnotizen, die das Auspacken zeigt.
  List<String> get notizen => [for (final a in auspacken) ?a.notiz];

  bool get fledermaus => ereignisse.any((e) => e.wirkung == EreignisWirkung.fledermaus);
  bool get kerzenschein => ereignisse.any((e) => e.wirkung == EreignisWirkung.kerzenschein);

  Map<String, Object?> toJson() => {
        'runde': runde,
        'zuege': {for (final e in zuege.entries) e.key: e.value.toJson()},
        'geruechte': [for (final g in geruechte) g.toJson()],
        'tisch': tisch,
        'auspacken': [for (final a in auspacken) a.toJson()],
        'ablenker': ablenker,
        'minuten': {'helfen': minutenHelfen, 'ablenken': minutenAblenken, 'ereignisse': minutenEreignisse},
        'leisten': {
          'summeZusammenhalt': summeZusammenhalt, 'summeSpuk': summeSpuk,
          'zusammenhalt': zusammenhalt, 'spuk': spuk, 'zuwachsZusammenhalt': zusammenhaltZuwachs, 'zuwachsSpuk': spukZuwachs,
        },
        'ereignisse': [for (final e in ereignisse) e.id],
        'privat': {for (final e in privat.entries) e.key: [for (final n in e.value) n.toJson()]},
        'tafel': [for (final t in tafel) t.toJson()],
      };
}

/// Öffentliches Bild der Nacht, das ein Bot sieht (§3.11): Gerüchte, Ertappte, Ausgepackte, sichtbare
/// Fakten und die öffentliche Restmenge. Nie Dossier, Fall oder Lösung.
class BotLage {
  final List<String> besetzt;

  /// Gerüchte je abgeschlossener Runde (Index 0 = Runde 1).
  final List<List<Geruecht>> geruechte;
  final Set<String> ertappt, gestanden, sichtbar;

  /// Noch verdächtige Kernfiguren (öffentliche Restmenge).
  final List<String> verdaechtig;

  const BotLage({
    required this.besetzt,
    this.geruechte = const [],
    this.ertappt = const {},
    this.gestanden = const {},
    this.sichtbar = const {},
    this.verdaechtig = const [],
  });

  /// Gerüchte der letzten abgeschlossenen Runde.
  List<Geruecht> get zuletzt => geruechte.isEmpty ? const [] : geruechte.last;

  /// Meistberedete Figur über alle bisherigen Runden ohne [ohne]; Gleichstand nach Besetzungsreihenfolge.
  String? meistberedet({Set<String> ohne = const {}}) {
    final gewicht = <String, int>{};
    for (final runde in geruechte) {
      for (final g in runde) {
        gewicht[g.figur] = (gewicht[g.figur] ?? 0) + g.gewicht;
      }
    }
    String? beste;
    for (final f in besetzt) {
      final w = gewicht[f] ?? 0;
      if (w > 0 && !ohne.contains(f) && (beste == null || w > gewicht[beste]!)) beste = f;
    }
    return beste;
  }
}

/// Protokoll der Nacht (§3.9, §3.10): Grundlage für Ziele, Auszeichnungen und die Auflösung.
/// Vor der Anklage ist es ein Zwischenstand; [angeklagt], [rest] und [aufloesung] fehlen dann.
class NachtProtokoll {
  /// Besetzte Rollen in Besetzungsreihenfolge.
  final List<String> besetzt;

  /// Züge je ausgewerteter Runde (nur abgeschlossene Runden).
  final Map<int, Map<String, EinflussZug>> zuege;
  final Map<String, int> ertappt;

  /// Optionen mit Erfolg je Runde (für „gestützte Erfolge“).
  final Map<int, List<String>> erfolge;
  final int zusammenhalt, spuk;

  /// Bei der Anklage sichtbare Fakten (vorher: bisher sichtbare).
  final Set<String> sichtbar;
  final String? angeklagt;

  /// Nachtminuten am Ende von Runde 3, sobald bekannt.
  final int? rest;

  /// Wen die Auflösung nennt; erst nach dem Finale.
  final String? aufloesung;

  const NachtProtokoll({
    required this.besetzt,
    required this.zuege,
    this.ertappt = const {},
    this.erfolge = const {},
    this.zusammenhalt = 0,
    this.spuk = 0,
    this.sichtbar = const {},
    this.angeklagt,
    this.rest,
    this.aufloesung,
  });

  /// Abgeschlossene Runden.
  int get rundenFertig => zuege.length;

  /// Nach der Anklage steht alles fest.
  bool get fertig => angeklagt != null;

  /// Zug von [rolle] in [runde] (abgewartet, wenn die Runde ausgewertet ist und er fehlt).
  EinflussZug? zug(int runde, String rolle) {
    final r = zuege[runde];
    if (r == null) return null;
    return r[rolle] ?? EinflussZug.abgewartet(rolle);
  }

  /// Runde, in der [rolle] ausgepackt hat, sonst `null`.
  int? auspackRunde(String rolle) {
    for (final r in (zuege.keys.toList()..sort())) {
      if (zuege[r]![rolle]?.art == ZugArt.auspacken) return r;
    }
    return null;
  }

  /// Gerüchte einer Runde: je Figur, auf die gezeigt wurde.
  List<Geruecht> geruechte(int runde) => geruechteAus(zuege[runde]?.values ?? const [], besetzt);

  /// Tipps der Tipp-Runde.
  Map<String, String> tipps(int tippRunde) => {
        for (final z in zuege[tippRunde]?.values ?? const <EinflussZug>[])
          if (z.tipp != null) z.rolle: z.tipp!,
      };
}

/// Gerüchte aus den Zügen einer Runde, in Besetzungsreihenfolge.
List<Geruecht> geruechteAus(Iterable<EinflussZug> zuege, List<String> besetzt) {
  final n = <String, int>{};
  for (final z in zuege) {
    if (z.art == ZugArt.zeigen && z.ziel != null) n[z.ziel!] = (n[z.ziel!] ?? 0) + 1;
  }
  return [for (final f in besetzt) if ((n[f] ?? 0) > 0) Geruecht(f, laut: n[f]! >= 2)];
}

/// Der reine Zustand der Schicht über den Abend: Züge, Leisten, Ereignisse, Ertappte und Erfolge.
///
/// Rein: keine Uhr, kein Transport, keine Fall-Daten. Wer zieht, bestimmt der Aufrufer ([besetzt]);
/// Bots ziehen über [botZug]. Runden werden der Reihe nach ausgewertet ([auswerten]); danach sind
/// ihre Züge fest.
class EinflussStand {
  EinflussStand(this.regeln, {required List<String> besetzt}) : besetzt = List.unmodifiable(besetzt) {
    if (this.besetzt.isEmpty || this.besetzt.toSet().length != this.besetzt.length) throw ArgumentError('besetzt: leer oder doppelt');
    for (final b in this.besetzt) {
      if (!regeln.figuren.contains(b)) throw ArgumentError('unbekannte Rolle $b');
    }
  }

  final EinflussRegeln regeln;

  /// Besetzte Rollen in Besetzungsreihenfolge (Mensch oder Bot).
  final List<String> besetzt;

  final Map<int, Map<String, EinflussZug>> _zuege = {};
  final List<EinflussFolgen> _folgen = [];
  final Set<String> _ausgeloest = {};
  final Map<String, int> _gestanden = {};

  /// Zugarten, die eine Rolle nur einmal am Abend spielen darf und schon gespielt hat.
  final Map<String, Set<ZugArt>> _einmal = {};
  final Map<String, int> _ertappt = {};
  final Map<int, List<String>> _erfolge = {};
  int _zusammenhalt = 0, _spuk = 0, _nachfragenBonus = 0;
  bool _kerzenschein = false;

  int get n => besetzt.length;
  int get zusammenhalt => _zusammenhalt;
  int get spuk => _spuk;

  /// Ausgewertete Runden in Reihenfolge.
  List<EinflussFolgen> get folgen => List.unmodifiable(_folgen);

  /// Nächste Runde, deren Züge noch offen sind (4: alle ausgewertet).
  int get offeneRunde => _folgen.length + 1;

  /// Rolle → Runde, in der sie ausgepackt hat.
  Map<String, int> get gestanden => Map.unmodifiable(_gestanden);
  Map<String, int> get ertappt => Map.unmodifiable(_ertappt);

  /// Ausgelöste Ereignisse (Kennungen).
  Set<String> get ausgeloest => Set.unmodifiable(_ausgeloest);

  /// Wartet ein Kerzenschein auf die nächste Suche?
  bool get kerzenschein => _kerzenschein;

  /// Setzt oder ändert den Zug einer Rolle in der offenen Runde (bis zu den Folgen änderbar).
  /// [StateError] für eine falsche Runde, [ArgumentError] für einen unzulässigen Zug.
  void setze(int runde, EinflussZug zug) {
    if (runde != offeneRunde || runde > 3) throw StateError('Runde $runde ist nicht offen');
    pruefeZug(runde, zug);
    (_zuege[runde] ??= {})[zug.rolle] = zug;
  }

  /// Wirft [ArgumentError], wenn [zug] in [runde] nicht erlaubt ist (ohne Zustand zu ändern).
  void pruefeZug(int runde, EinflussZug zug) {
    if (!besetzt.contains(zug.rolle)) throw ArgumentError('Rolle ${zug.rolle} ist nicht besetzt');
    if (zug.tipp != null) {
      if (runde != regeln.zahlen.tippRunde) throw ArgumentError('Tipp nur in Runde ${regeln.zahlen.tippRunde}');
      if (!regeln.tipps.contains(zug.tipp)) throw ArgumentError('unbekannter Tipp ${zug.tipp}');
    }
    if (zug.art == ZugArt.abgewartet) {
      if (zug.ziel != null) throw ArgumentError('Abwarten hat kein Ziel');
      return;
    }
    final r = regeln.arten[zug.art]!;
    final ziel = zug.ziel;
    switch (r.ziel) {
      case ZielRegel.keins:
        if (ziel != null) throw ArgumentError('${zug.art.name} hat kein Ziel');
      case ZielRegel.andere || ZielRegel.jede:
        if (ziel == null || !besetzt.contains(ziel)) throw ArgumentError('${zug.art.name} braucht eine besetzte Figur');
        if (r.ziel == ZielRegel.andere && ziel == zug.rolle) throw ArgumentError('${zug.art.name} nie auf sich selbst');
    }
    if (r.einmal && (_einmal[zug.rolle]?.contains(zug.art) ?? false)) throw ArgumentError('${zug.art.name} nur einmal am Abend');
    if (zug.art == ZugArt.auspacken && !regeln.auspacken.containsKey(zug.rolle)) throw ArgumentError('${zug.rolle} hat nichts zum Auspacken');
  }

  /// Gesetzter Zug von [rolle] in [runde], sonst `null`.
  EinflussZug? zug(int runde, String rolle) => _zuege[runde]?[rolle];

  /// Zugarten, die [rolle] im Moment wählen darf (§3.2, ohne abgewartet): ohne schon gespielte
  /// Einmal-Arten und ohne Auspacken, wenn sie nichts auszupacken hat. Gleiche Prüfung wie [pruefeZug].
  List<ZugArt> erlaubteArten(String rolle) {
    if (!besetzt.contains(rolle)) throw ArgumentError('Rolle $rolle ist nicht besetzt');
    return [
      for (final a in ZugArt.waehlbar)
        if (!(regeln.arten[a]!.einmal && (_einmal[rolle]?.contains(a) ?? false)) &&
            (a != ZugArt.auspacken || regeln.auspacken.containsKey(rolle)) &&
            (regeln.arten[a]!.ziel == ZielRegel.keins || erlaubteZiele(rolle, a).isNotEmpty))
          a,
    ];
  }

  /// Ziele, die [rolle] mit [art] treffen darf, in Besetzungsreihenfolge; leer für Arten ohne Ziel.
  List<String> erlaubteZiele(String rolle, ZugArt art) => switch (regeln.arten[art]?.ziel) {
        ZielRegel.andere => [for (final b in besetzt) if (b != rolle) b],
        ZielRegel.jede => [...besetzt],
        _ => const [],
      };

  /// Haben alle besetzten Rollen in [runde] gezogen (auch ausdrücklich abgewartet)?
  bool vollstaendig(int runde) => besetzt.every((r) => _zuege[runde]?.containsKey(r) ?? false);

  /// Folgen von [runde], solange sie ausgewertet ist, sonst `null`.
  EinflussFolgen? folgenVon(int runde) => runde >= 1 && runde <= _folgen.length ? _folgen[runde - 1] : null;

  /// Tischwert T der Option [optionId] in [runde] (0, solange die Runde nicht ausgewertet ist).
  int tisch(int runde, String optionId) => folgenVon(runde)?.tisch[optionId] ?? 0;

  /// Rollen, die in [runde] eine Figur im Bezug von [optionId] gedeckt haben, in Besetzungsreihenfolge.
  List<String> decker(int runde, String optionId) {
    final b = regeln.bezug[optionId] ?? const [];
    final z = folgenVon(runde)?.zuege ?? const <String, EinflussZug>{};
    return [for (final r in besetzt) if (z[r] case final x? when x.art == ZugArt.decken && b.contains(x.ziel)) r];
  }

  /// Eine Rolle wurde ertappt (§3.4).
  void ertapptMelden(String rolle) {
    if (!besetzt.contains(rolle)) throw ArgumentError('Rolle $rolle ist nicht besetzt');
    _ertappt[rolle] = (_ertappt[rolle] ?? 0) + 1;
  }

  /// Eine Suche auf [optionId] gelang mit Erfolg (für „gestützte Erfolge“, §3.10).
  void erfolgMelden(int runde, String optionId) {
    if (regeln.entscheidungVon[optionId] == null) throw ArgumentError('unbekannte Option $optionId');
    (_erfolge[runde] ??= []).add(optionId);
  }

  /// Verbraucht einen wartenden Kerzenschein für die nächste Suche (§3.8).
  bool kerzenscheinNehmen() {
    final k = _kerzenschein;
    _kerzenschein = false;
    return k;
  }

  /// Nachfragen nach Runde 3 bei [restMinuten] (§3.5), mit Ereignis-Bonus.
  int nachfragen(int restMinuten) {
    final z = regeln.zahlen;
    final grund = restMinuten <= 0 ? 0 : restMinuten ~/ z.nachfrageJeMinuten;
    return (grund < z.nachfragenHoechstens ? grund : z.nachfragenHoechstens) + _nachfragenBonus;
  }

  /// Tischbonus aus den Leisten (§3.10).
  int get tischbonus => tischbonusAus(regeln.zahlen, zusammenhalt: _zusammenhalt, spuk: _spuk);

  /// Fassung des Morgens (§3.10).
  MorgenVariante get morgen => morgenAus(regeln.zahlen, zusammenhalt: _zusammenhalt, spuk: _spuk, erzwungen: [
        for (final e in regeln.ereignisse)
          if (_ausgeloest.contains(e.id)) ?e.morgen,
      ]);

  /// Tipps der Tipp-Runde (verdeckt bis zur Auflösung).
  Map<String, String> get tipps => {
        for (final z in _zuege[regeln.zahlen.tippRunde]?.values ?? const <EinflussZug>[])
          if (z.tipp != null && regeln.zahlen.tippRunde <= _folgen.length) z.rolle: z.tipp!,
      };

  /// Wertet die Züge von [runde] aus (§3.2–§3.8). Wer fehlt, hat abgewartet. Danach sind die Züge fest.
  EinflussFolgen auswerten(int runde) {
    if (runde != offeneRunde || runde > 3) throw StateError('Runde $runde kann nicht ausgewertet werden');
    final z = regeln.zahlen;
    final zuege = {for (final r in besetzt) r: _zuege[runde]?[r] ?? EinflussZug.abgewartet(r)};
    _zuege[runde] = Map.of(zuege);
    final liste = [for (final r in besetzt) zuege[r]!];
    ZugArtRegel? regel(EinflussZug x) => regeln.arten[x.art];

    // Leisten (§3.8): K = Σ Zusammenhalt-Gewichte (mindestens 0), L = Σ Spuk-Gewichte.
    var k = 0, l = 0;
    for (final x in liste) {
      k += regel(x)?.zusammenhalt ?? 0;
      l += regel(x)?.spuk ?? 0;
    }
    if (k < 0) k = 0;
    final zVorher = _zusammenhalt, sVorher = _spuk;
    var zZuwachs = z.zuwachs(Leiste.zusammenhalt, k, n), sZuwachs = z.zuwachs(Leiste.spuk, l, n);
    if (zVorher + zZuwachs > z.leisteHoechstens) zZuwachs = z.leisteHoechstens - zVorher;
    if (sVorher + sZuwachs > z.leisteHoechstens) sZuwachs = z.leisteHoechstens - sVorher;
    _zusammenhalt = zVorher + zZuwachs;
    _spuk = sVorher + sZuwachs;

    // Ereignisse: jedes einmal am Abend, sobald seine Stufe erreicht ist.
    final neu = <EinflussEreignis>[];
    for (final leiste in Leiste.values) {
      final stand = leiste == Leiste.zusammenhalt ? _zusammenhalt : _spuk;
      for (final e in [...regeln.ereignisse.where((e) => e.leiste == leiste)]..sort((a, b) => a.stufe.compareTo(b.stufe))) {
        if (stand >= e.stufe && _ausgeloest.add(e.id)) neu.add(e);
      }
    }
    var minutenEreignisse = 0;
    for (final e in neu) {
      minutenEreignisse += e.minuten;
      _nachfragenBonus += e.nachfragen;
      if (e.wirkung == EreignisWirkung.kerzenschein) _kerzenschein = true;
    }
    final fledermaus = neu.any((e) => e.wirkung == EreignisWirkung.fledermaus);

    // Tischwerte (§3.3): v(o) aus den Tischstimmen auf Figuren im Bezug.
    final tisch = <String, int>{};
    for (final o in regeln.optionen(runde)) {
      final b = regeln.bezug[o]!;
      var v = 0;
      for (final x in liste) {
        if (x.ziel != null && b.contains(x.ziel)) v += regel(x)?.tisch ?? 0;
      }
      var t = z.tischwert(v, n);
      if (fledermaus && t < 0) t = 2 * t < -z.tischDeckel ? -z.tischDeckel : 2 * t;
      tisch[o] = t;
    }

    // Nachtminuten (§3.7): helfen und ablenken je Runde gedeckelt.
    var plus = 0, minus = 0;
    for (final x in liste) {
      final m = regel(x)?.minuten ?? 0;
      if (m > 0) plus += m;
      if (m < 0) minus += m;
    }
    if (plus > z.helfenHoechstens) plus = z.helfenHoechstens;
    if (minus < -z.ablenkenHoechstens) minus = -z.ablenkenHoechstens;

    // Auspacken (§3.6) und Ablenken: öffentlich mit Namen.
    final auspacken = <AuspackenLieferung>[];
    final ablenker = <String>[];
    for (final x in liste) {
      if (regel(x)?.einmal ?? false) (_einmal[x.rolle] ??= {}).add(x.art);
      if (x.art == ZugArt.auspacken) {
        final q = regeln.auspacken[x.rolle]!;
        _gestanden[x.rolle] = runde;
        auspacken.add(AuspackenLieferung(x.rolle, fakt: q.fakt, notiz: q.notiz));
      }
      if (x.art == ZugArt.ablenken) ablenker.add(x.rolle);
    }

    // Private Nachrichten (§3.12).
    final privat = <String, List<PrivatNachricht>>{};
    void sende(String an, PrivatNachricht m) => (privat[an] ??= []).add(m);
    final deckerJe = <String, int>{};
    for (final x in liste) {
      if (x.art == ZugArt.decken && x.ziel != x.rolle) deckerJe[x.ziel!] = (deckerJe[x.ziel!] ?? 0) + 1;
    }
    for (final r in besetzt) {
      final c = deckerJe[r] ?? 0;
      if (c > 0) sende(r, PrivatNachricht(c == 1 ? PrivatArt.haeltZuDir : PrivatArt.mehrereHalten));
    }
    for (final x in liste) {
      switch (x.art) {
        case ZugArt.lauschen:
          final y = zuege[x.ziel]!;
          sende(x.rolle, PrivatNachricht(PrivatArt.gelauscht, figur: y.rolle, zug: y.art, ziel: y.ziel));
        case ZugArt.zeigen || ZugArt.decken:
          final richtung = regel(x)!.tisch.sign;
          final wirkte = regeln.optionen(runde).any((o) => regeln.bezug[o]!.contains(x.ziel) && tisch[o]!.sign == richtung && richtung != 0);
          sende(x.rolle, PrivatNachricht(wirkte ? PrivatArt.wirkte : PrivatArt.ohneFolgen));
        case ZugArt.helfen || ZugArt.auspacken || ZugArt.ablenken:
          sende(x.rolle, const PrivatNachricht(PrivatArt.wirkte));
        case ZugArt.abgewartet:
          break;
      }
    }

    final f = EinflussFolgen(
      runde: runde,
      zuege: Map.unmodifiable(zuege),
      geruechte: List.unmodifiable(geruechteAus(liste, besetzt)),
      tisch: Map.unmodifiable(tisch),
      auspacken: List.unmodifiable(auspacken),
      ablenker: List.unmodifiable(ablenker),
      minutenHelfen: plus,
      minutenAblenken: minus,
      minutenEreignisse: minutenEreignisse,
      summeZusammenhalt: k,
      summeSpuk: l,
      zusammenhaltVorher: zVorher,
      spukVorher: sVorher,
      zusammenhaltZuwachs: zZuwachs,
      spukZuwachs: sZuwachs,
      ereignisse: List.unmodifiable(neu),
      privat: Map.unmodifiable({for (final e in privat.entries) e.key: List<PrivatNachricht>.unmodifiable(e.value)}),
      tafel: List.unmodifiable([for (final x in liste) ZugTafelZeile(x.rolle, x.art, x.ziel)]),
    );
    _folgen.add(f);
    return f;
  }

  /// Öffentliches Bild für die Bots der nächsten Runde (§3.11).
  BotLage botLage({Set<String> sichtbar = const {}, List<String> verdaechtig = const []}) => BotLage(
        besetzt: besetzt,
        geruechte: [for (final f in _folgen) f.geruechte],
        ertappt: {for (final e in _ertappt.entries) if (e.value > 0) e.key},
        gestanden: _gestanden.keys.toSet(),
        sichtbar: sichtbar,
        verdaechtig: verdaechtig,
      );

  /// Protokoll der Nacht für Ziele und Auszeichnungen; Anklage, Rest und Auflösung gibt der Aufrufer.
  NachtProtokoll protokoll({Set<String> sichtbar = const {}, String? angeklagt, int? rest, String? aufloesung}) => NachtProtokoll(
        besetzt: besetzt,
        zuege: {for (final f in _folgen) f.runde: f.zuege},
        ertappt: Map.of(_ertappt),
        erfolge: {for (final e in _erfolge.entries) e.key: List.of(e.value)},
        zusammenhalt: _zusammenhalt,
        spuk: _spuk,
        sichtbar: sichtbar,
        angeklagt: angeklagt,
        rest: rest,
        aufloesung: aufloesung,
      );
}

/// Wen das Ertappt einer gelungenen Suche nennt (§3.4): gezogen aus den [decker]n in
/// Besetzungsreihenfolge über `ertappt:<salz>:<entscheidung>`; ohne Decker niemand.
String? ertapptAuswahl({required String salz, required String entscheidung, required List<String> decker}) {
  if (decker.isEmpty) return null;
  return decker[Rng(Rng.hashString('ertappt:$salz:$entscheidung')).nextInt(decker.length)];
}

/// Was im Bonus-Abschnitt geflüstert wird (§3.8): nach dem Zuwachs des Zusammenhalts dieser Runde.
Fluestern fluesternAus(EinflussZahlen z, int zusammenhaltZuwachs) => zusammenhaltZuwachs >= z.fluesternWahrAb
    ? Fluestern.wahr
    : zusammenhaltZuwachs >= z.fluesternNeutralAb
        ? Fluestern.neutral
        : Fluestern.still;

/// Tischbonus (§3.10): +1 bei hohem Zusammenhalt, −1 bei hohem Spuk, beides zusammen 0.
int tischbonusAus(EinflussZahlen z, {required int zusammenhalt, required int spuk}) {
  final plus = zusammenhalt >= z.tischbonusAb, minus = spuk >= z.tischbonusAb;
  return plus == minus ? 0 : (plus ? 1 : -1);
}

/// Endwert (§3.10): Punkte plus Tischbonus, begrenzt auf 0 bis zum Höchstwert.
int endwertAus(EinflussZahlen z, {required int punkte, required int tischbonus}) {
  final e = punkte + tischbonus;
  return e < 0 ? 0 : (e > z.endwertHoechstens ? z.endwertHoechstens : e);
}

/// Fassung des Morgens (§3.10); ein Ereignis kann sie erzwingen ([erzwungen], das erste gilt).
MorgenVariante morgenAus(EinflussZahlen z, {required int zusammenhalt, required int spuk, List<MorgenVariante> erzwungen = const []}) {
  if (erzwungen.isNotEmpty) return erzwungen.first;
  final warm = zusammenhalt >= z.tischbonusAb, wild = spuk >= z.tischbonusAb;
  if (warm && !wild) return MorgenVariante.warm;
  if (wild && !warm) return MorgenVariante.chaotisch;
  return MorgenVariante.gemischt;
}

/// Auszeichnungen der Auflösung (§3.10).
class Auszeichnungen {
  /// Stern des Abends (immer vergeben, sobald jemand besetzt ist).
  final String? stern;

  /// Wer richtig getippt hat, in Besetzungsreihenfolge, ohne die Rolle der Auflösung (sie kennt ihre Tat).
  final List<String> spuernasen;

  /// Meiste Spuk-Gewichte bzw. meiste Deckungen für andere; ohne solche Züge niemand.
  final String? schlossgeist, treueSeele;

  /// Wertung des Sterns je Rolle (3·Sterne + 2·Spürnase + gestützte Erfolge ≤ 2 + ausgepackt).
  final Map<String, int> wertung;

  const Auszeichnungen({required this.stern, required this.spuernasen, required this.schlossgeist, required this.treueSeele, required this.wertung});

  Map<String, Object?> toJson() => {'stern': stern, 'spuernasen': spuernasen, 'schlossgeist': schlossgeist, 'treueSeele': treueSeele, 'wertung': wertung};
}

/// Gestützte Erfolge von [rolle]: Erfolge auf Optionen, auf deren Bezug sie in derselben Runde zeigte.
int gestuetzteErfolge(NachtProtokoll p, EinflussRegeln r, String rolle) {
  var n = 0;
  for (final e in p.erfolge.entries) {
    final z = p.zug(e.key, rolle);
    if (z == null || z.art != ZugArt.zeigen) continue;
    for (final o in e.value) {
      if (r.bezug[o]?.contains(z.ziel) ?? false) n++;
    }
  }
  return n;
}

/// Auszeichnungen als reine Funktion über das Protokoll (§3.10). [sterne] sind die erreichten Sterne je
/// Rolle (`einfluss_ziele.dart`); Spürnasen gibt es erst mit der Auflösung im Protokoll.
Auszeichnungen auszeichnen(NachtProtokoll p, EinflussRegeln r, {required Map<String, int> sterne}) {
  final tipps = p.tipps(r.zahlen.tippRunde);
  // Die Rolle der Auflösung kennt ihre Tat: Ihr Tipp auf sich selbst macht sie nicht zur Spürnase (Änderung 35).
  final spuernasen = [
    for (final rolle in p.besetzt)
      if (p.aufloesung != null && rolle != p.aufloesung && tipps[rolle] == p.aufloesung) rolle,
  ];
  final wertung = <String, int>{};
  for (final rolle in p.besetzt) {
    final gestuetzt = gestuetzteErfolge(p, r, rolle);
    wertung[rolle] = 3 * (sterne[rolle] ?? 0) +
        2 * (spuernasen.contains(rolle) ? 1 : 0) +
        (gestuetzt < 2 ? gestuetzt : 2) +
        (p.auspackRunde(rolle) != null ? 1 : 0);
  }
  String? stern;
  for (final rolle in p.besetzt) {
    if (stern == null) {
      stern = rolle;
      continue;
    }
    final w = wertung[rolle]!, b = wertung[stern]!;
    // Gleichstand: weniger Ertappt, dann Besetzungsreihenfolge (die frühere bleibt).
    if (w > b || (w == b && (p.ertappt[rolle] ?? 0) < (p.ertappt[stern] ?? 0))) stern = rolle;
  }
  String? meiste(int Function(EinflussZug z) gewicht) {
    String? beste;
    var hoechst = 0;
    for (final rolle in p.besetzt) {
      var s = 0;
      for (final runde in p.zuege.keys) {
        s += gewicht(p.zug(runde, rolle)!);
      }
      if (s > hoechst) {
        hoechst = s;
        beste = rolle;
      }
    }
    return beste;
  }

  return Auszeichnungen(
    stern: stern,
    spuernasen: List.unmodifiable(spuernasen),
    schlossgeist: meiste((z) => r.arten[z.art]?.spuk ?? 0),
    treueSeele: meiste((z) => z.art == ZugArt.decken && z.ziel != z.rolle ? 1 : 0),
    wertung: Map.unmodifiable(wertung),
  );
}

/// Reaktionsblase eines Bots nach den Folgen (§3.11): Text `einfluss.bot.<figur>.<anlass>`.
class BotBlase {
  final String figur;

  /// Einer der [botAnlaesse].
  final String anlass;
  const BotBlase(this.figur, this.anlass);

  /// Text-Schlüssel der Blase (Karte, höchstens acht Wörter).
  String get schluessel => 'einfluss.bot.$figur.$anlass';

  Map<String, Object?> toJson() => {'figur': figur, 'anlass': anlass};

  @override
  bool operator ==(Object other) => other is BotBlase && other.figur == figur && other.anlass == anlass;

  @override
  int get hashCode => Object.hash(figur, anlass);

  @override
  String toString() => 'BotBlase($schluessel)';
}

/// Höchstens so viele Reaktionsblasen je Folgen (§3.11).
const botBlasenHoechstens = 3;

/// Reaktionsblasen der Bots zu den Folgen [f] (§3.11). Anlässe nur aus Öffentlichem, je Figur der erste in
/// der Reihenfolge von [botAnlaesse]: seit den letzten Folgen ertappt ([ertappt]), ein Gerücht über sie,
/// ihr Freund (aus den Bot-Daten) hat ausgepackt, sie hat abgelenkt. Nur Rollen, für die [istBot] gilt.
/// Sind es mehr als [botBlasenHoechstens], entscheidet der Strom `blasen:<salz>:<runde>`; die Ausgabe
/// steht in Besetzungsreihenfolge. Gleiche Eingaben, gleiche Blasen.
List<BotBlase> botBlasen(
  EinflussRegeln r,
  EinflussFolgen f, {
  required String salz,
  required bool Function(String rolle) istBot,
  Iterable<String> ertappt = const [],
}) {
  final gefasst = ertappt.toSet();
  final gestanden = {for (final a in f.auspacken) a.figur};
  final alle = <BotBlase>[];
  for (final rolle in r.figuren) {
    if (!f.zuege.containsKey(rolle) || !istBot(rolle)) continue;
    final freund = r.bots[rolle]?.freund;
    final anlass = <String, bool>{
      'ertappt': gefasst.contains(rolle),
      'geruecht': f.geruechte.any((g) => g.figur == rolle),
      'freund_gestanden': freund != null && freund != rolle && gestanden.contains(freund),
      'ablenken': f.ablenker.contains(rolle),
    };
    for (final a in botAnlaesse) {
      if (anlass[a] ?? false) {
        alle.add(BotBlase(rolle, a));
        break;
      }
    }
  }
  if (alle.length <= botBlasenHoechstens) return List.unmodifiable(alle);
  final gezogen = [...alle];
  Rng(Rng.hashString('blasen:$salz:${f.runde}')).shuffle(gezogen);
  final wahl = gezogen.take(botBlasenHoechstens).toSet();
  return List.unmodifiable([for (final b in alle) if (wahl.contains(b)) b]);
}

/// Seed-Text des Bot-Stroms (§3.11), getrennt vom Stimmen- und Würfelstrom.
String botStromText(String salz, String rolle, int runde) => 'einfluss:$salz:$rolle:$runde';

/// Zug eines Bots (§3.11): Persönlichkeit aus den Daten, gezogen aus dem eigenen Strom
/// `einfluss:<salz>:<rolle>:<runde>`, nur aus dem öffentlichen Bild [lage]. Gleiche Eingaben, gleicher Zug.
EinflussZug botZug(EinflussRegeln r, {required String salz, required String rolle, required int runde, required BotLage lage}) {
  if (salz.isEmpty || runde < 1 || runde > 3 || !lage.besetzt.contains(rolle)) throw ArgumentError('ungültige Bot-Eingabe');
  final rng = Rng(Rng.hashString(botStromText(salz, rolle, runde)));
  // Feste Ziehungsfolge, gleich welcher Zweig greift.
  final dAuspacken = rng.nextInt(100), dArt = rng.nextInt(100), dUeber = rng.nextInt(100);
  final dZiel = rng.nextUint32(), dErsatz = rng.nextUint32(), dTipp = rng.nextUint32();
  final p = r.bots[rolle] ?? const BotPersona(gewichte: {ZugArt.helfen: 100});
  final gestanden = lage.gestanden.contains(rolle);
  final andere = [for (final b in lage.besetzt) if (b != rolle) b];
  String? gezogen(List<String> aus, int d) => aus.isEmpty ? null : aus[d % aus.length];

  // Grundart: feste Auspack-Runde, sonst nach Gewichten.
  var art = ZugArt.helfen;
  if (p.auspacken case final a? when a.runde == runde && !gestanden && dAuspacken < a.chance) {
    art = ZugArt.auspacken;
  } else {
    var summe = 0;
    for (final a in const [ZugArt.helfen, ZugArt.decken, ZugArt.zeigen, ZugArt.ablenken, ZugArt.lauschen, ZugArt.auspacken]) {
      summe += p.gewichte[a] ?? 0;
      if (dArt < summe) {
        art = a;
        break;
      }
    }
  }
  if (art == ZugArt.auspacken && (gestanden || !r.auspacken.containsKey(rolle))) art = ZugArt.helfen;

  final freund = p.freund == null || !lage.besetzt.contains(p.freund) ? null : p.freund;
  final ohne = {rolle, ?freund};
  String? zeigeZiel() {
    final fest = p.zeigen;
    if (fest != null) return lage.besetzt.contains(fest) && fest != rolle ? fest : gezogen(andere, dErsatz);
    return lage.meistberedet(ohne: ohne) ?? gezogen([for (final k in r.kern) if (lage.besetzt.contains(k) && !ohne.contains(k)) k], dZiel) ?? gezogen(andere, dErsatz);
  }

  String? ziel;
  switch (art) {
    case ZugArt.decken:
      final fest = p.decken == null || p.decken == 'ich' ? rolle : p.decken!;
      ziel = lage.besetzt.contains(fest) ? fest : (gezogen(andere, dErsatz) ?? rolle);
    case ZugArt.lauschen:
      final fest = p.lauschen;
      ziel = fest != null && fest != rolle && lage.besetzt.contains(fest) ? fest : gezogen(andere, fest == null ? dZiel : dErsatz);
    case ZugArt.zeigen:
      ziel = zeigeZiel();
    default:
      break;
  }
  if ((art == ZugArt.lauschen || art == ZugArt.zeigen) && ziel == null) art = ZugArt.helfen;

  // Übersteuerungen (§3.11, „Änderungen“ 17) in dieser Reihenfolge, die spätere Regel gewinnt: Freund
  // beredet → decken; „Mehrere tuscheln über mich“ → halb zeigen; eigenes Geheimnis bekannt → kein
  // Selbst-Decken; nach Ertappt kein Decken. Ersatz ist jeweils helfen.
  if (art != ZugArt.auspacken) {
    if (freund != null && lage.zuletzt.any((g) => g.figur == freund)) {
      art = ZugArt.decken;
      ziel = freund;
    }
    if (lage.zuletzt.any((g) => g.figur == rolle && g.laut) && dUeber < 50) {
      final x = lage.meistberedet(ohne: ohne);
      if (x != null) {
        art = ZugArt.zeigen;
        ziel = x;
      }
    }
    final geheim = r.geheimFakten[rolle] ?? const <String>{};
    if (art == ZugArt.decken && ziel == rolle && (gestanden || geheim.any(lage.sichtbar.contains))) art = ZugArt.helfen;
    if (art == ZugArt.decken && lage.ertappt.contains(rolle)) art = ZugArt.helfen;
  }
  if (art == ZugArt.helfen || art == ZugArt.auspacken || art == ZugArt.ablenken) ziel = null;

  String? tipp;
  if (runde == r.zahlen.tippRunde) {
    final noch = [for (final k in r.kern) if (lage.verdaechtig.contains(k)) k];
    tipp = gezogen(noch, dTipp) ?? tippKeiner;
  }
  return EinflussZug(rolle, art, ziel: ziel, tipp: tipp);
}

/// Alle Text-Schlüssel des Bereichs `einfluss` (§3.13 und „Änderungen“), die eine Akte mit Schicht braucht.
List<String> einflussKatalog(EinflussRegeln r) {
  const zielArten = [ZugArt.zeigen, ZugArt.decken, ZugArt.lauschen];
  return [
    for (final a in ZugArt.waehlbar) ...[
      for (final t in const ['titel', 'p1', 'p2', 'p3']) 'einfluss.zug.${a.name}.$t',
      if (zielArten.contains(a)) 'einfluss.zug.${a.name}.wahl',
    ],
    'einfluss.tipp.titel',
    'einfluss.tipp.p1',
    'einfluss.tipp.wahl',
    for (var i = 1; i <= 3; i++) 'einfluss.folgen.start.$i',
    for (final f in r.figuren) 'einfluss.auspacken.$f',
    for (final f in r.figuren) 'einfluss.ablenken.$f',
    'einfluss.ablenken.schluss',
    'einfluss.geruecht.leise',
    'einfluss.geruecht.laut',
    'einfluss.leiste.zusammenhalt.1',
    'einfluss.leiste.zusammenhalt.2',
    'einfluss.leiste.spuk.1',
    'einfluss.leiste.spuk.2',
    'einfluss.leiste.ruhig',
    for (final e in r.ereignisse) ...['einfluss.ereignis.${e.id}', 'einfluss.ereignis.${e.id}.karte', 'einfluss.ereignis.${e.id}.titel'],
    'einfluss.wieder',
    'einfluss.fluestern.still',
    for (final a in const ['plus1', 'plus2', 'minus1', 'minus2']) 'einfluss.abzeichen.$a',
    for (final b in const ['redselig', 'zoegert', 'mauert']) 'einfluss.befragung.$b',
    'einfluss.ertappt',
    'einfluss.ertappt.selbst',
    'einfluss.verwischt',
    'einfluss.tischruf.nochmal',
    'einfluss.tischruf.umweg',
    'einfluss.nachfrage.titel',
    'einfluss.nachfrage.p1',
    for (final p in PrivatArt.values) 'einfluss.privat.${p.schluessel}',
    for (final v in const [lauschOhneZiel, lauschAbgewartet]) 'einfluss.privat.gelauscht.$v',
    for (final f in r.figuren) ...['einfluss.ziel.$f.1', 'einfluss.ziel.$f.2'],
    for (final f in r.figuren) ...['einfluss.epilog.$f.erreicht', 'einfluss.epilog.$f.verfehlt'],
    'einfluss.tischbonus.plus',
    'einfluss.tischbonus.minus',
    for (final p in const ['stern', 'spuernase', 'spuernasen', 'schlossgeist', 'treue_seele']) 'einfluss.preis.$p',
    for (final m in MorgenVariante.values) 'einfluss.morgen.${m.name}',
    for (final f in r.figuren)
      for (final a in botAnlaesse) 'einfluss.bot.$f.$a',
  ];
}

// ---------------------------------------------------------------- JSON-Hilfen

Map<String, Object?> _alsMap(Object? v, String wo) {
  if (v is! Map) throw FormatException('$wo: Objekt erwartet');
  return v.cast<String, Object?>();
}

Map<String, Object?> _map(Map<String, Object?> j, String name, String wo) => _alsMap(j[name], '$wo.$name');

String _text(Map<String, Object?> j, String name, String wo) {
  final v = j[name];
  if (v is! String || v.isEmpty) throw FormatException('$wo.$name: Text erwartet');
  return v;
}

int _int(Map<String, Object?> j, String name, String wo, {int? min, int? max, int? sonst}) {
  final v = j.containsKey(name) ? j[name] : sonst;
  if (v is! int) throw FormatException('$wo.$name: ganze Zahl erwartet');
  if ((min != null && v < min) || (max != null && v > max)) throw FormatException('$wo.$name: $v außerhalb ${min ?? '…'}..${max ?? '…'}');
  return v;
}
