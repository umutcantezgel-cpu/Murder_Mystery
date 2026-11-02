/// Inhalt des Kammerspiels „Spuk im Schlosskeller“ als typisierte Daten
/// (`content/kammerspiel/schlosskeller/`, Schema in `SCHEMA.md` dort).
///
/// [KammerInhalt.ausJson] lädt ohne `dart:io` (App über `rootBundle`, CLI und
/// Tests über `package:mordakte_core/kammer_io.dart`) und prüft streng: Jede
/// Datei aus [kammerInhaltDateien] muss da sein, jedes Feld des Schemas auch,
/// kein Feld darf unbekannt sein. Fehler sind [FormatException] mit Datei und
/// Pfad. Texte werden auf Platzhalter und Auszeichnung geprüft
/// (`platzhalter.dart`); Texte mit `OFFEN:` sammelt [KammerInhalt.offeneFelder].
library;

import 'dart:convert';

import 'platzhalter.dart';

/// Ordner des Inhalts, vom Repo aus (auch der Asset-Pfad der App).
const String kammerInhaltOrdner = 'content/kammerspiel/schlosskeller';

/// Die Rollendateien, ordner-relativ, in Platzreihenfolge.
const List<String> kammerRollenDateien = [
  'rollen/01-ahmet.json',
  'rollen/02-fatma.json',
  'rollen/03-olli.json',
  'rollen/04-can.json',
  'rollen/05-lejla.json',
  'rollen/06-emine.json',
  'rollen/07-tim.json',
  'rollen/08-joanna.json',
  'rollen/09-marek.json',
  'rollen/10-zeynep.json',
  'rollen/11-sibel.json',
  'rollen/12-damir.json',
  'rollen/13-hana.json',
  'rollen/14-serkan.json',
  'rollen/15-azra.json',
  'rollen/16-wojtek.json',
  'rollen/17-aylin.json',
  'rollen/18-tugba.json',
];

/// Die Teile des Drucks, je mit einer Datei `ui/<teil>.json`.
const List<String> kammerTeile = ['00', '01', '02', '10', '11', '12', '20', '90'];

/// Alle Inhaltsdateien, ordner-relativ (Schlüssel für [KammerInhalt.ausJson]).
const List<String> kammerInhaltDateien = [
  'fall.json',
  'gemeinsam.json',
  'erzaehlerheft.json',
  'detektiv.json',
  'tisch.json',
  'abwesenheit.json',
  'indizkarten.json',
  'aufloesung.json',
  'ui/gemeinsam.json',
  'ui/00.json',
  'ui/01.json',
  'ui/02.json',
  'ui/10.json',
  'ui/11.json',
  'ui/12.json',
  'ui/20.json',
  'ui/90.json',
  ...kammerRollenDateien,
];

/// Stellung einer Rolle (Platz 1–4, 5–10, 11–18).
enum KammerArt { verdaechtig, zeuge, zusatz }

/// Art einer Indizkarte.
enum KammerKartenArt { ortstermin, spur }

/// Ab wann eine Zeile in „Was du weißt“ frei ist.
enum KammerFrei { offen, karte, runde3 }

/// Klasse einer Aktionskarte (MECH 4.5).
enum KammerKlasse { schutz, frage, untersuchung, beleg }

/// Gemeinsamer Zustand beim Laden: Rollen-IDs für die Platzhalterprüfung und
/// die gesammelten OFFEN-Felder.
class _Lader {
  Set<String> rollen = const {};
  final List<String> offen = [];

  String text(Object? v, String datei, String pfad, Set<String>? werte) {
    if (v is! String) throw FormatException('$datei: $pfad: Text erwartet');
    if (istKammerOffen(v)) offen.add('$datei: $pfad');
    try {
      pruefeKammerText(v, rollen: rollen, werte: werte);
    } on FormatException catch (e) {
      throw FormatException('$datei: $pfad: ${e.message}');
    }
    return v;
  }
}

/// Ein JSON-Objekt mit Datei und Pfad. Merkt sich die gelesenen Felder;
/// [_fertig] meldet jedes übrige als unbekannt.
class _Knoten {
  _Knoten(this._l, this.datei, this.pfad, this._werte);

  final _Lader _l;
  final String datei;
  final String pfad;
  final Map<String, Object?> _werte;
  final Set<String> _gelesen = {};

  String _p(String feld) => pfad.isEmpty ? feld : '$pfad.$feld';

  Object? _roh(String feld) {
    if (!_werte.containsKey(feld)) throw FormatException('$datei: ${_p(feld)}: Feld fehlt');
    _gelesen.add(feld);
    return _werte[feld];
  }

  void _fertig() {
    for (final k in _werte.keys) {
      if (!_gelesen.contains(k)) throw FormatException('$datei: ${_p(k)}: unbekanntes Feld');
    }
  }

  String _kennung(Object? v, String pfad) {
    if (v is! String || v.isEmpty || v.contains(RegExp(r'[{}\s]'))) throw FormatException('$datei: $pfad: Kennung erwartet');
    return v;
  }

  String kennung(String feld) => _kennung(_roh(feld), _p(feld));

  String? kennungOderNull(String feld) {
    final v = _roh(feld);
    return v == null ? null : _kennung(v, _p(feld));
  }

  String text(String feld, {Set<String>? werte = const {}}) => _l.text(_roh(feld), datei, _p(feld), werte);

  String? textOderNull(String feld, {Set<String>? werte = const {}}) {
    final v = _roh(feld);
    return v == null ? null : _l.text(v, datei, _p(feld), werte);
  }

  int zahl(String feld) {
    final v = _roh(feld);
    if (v is! int) throw FormatException('$datei: ${_p(feld)}: ganze Zahl erwartet');
    return v;
  }

  int? zahlOderNull(String feld) {
    final v = _roh(feld);
    if (v != null && v is! int) throw FormatException('$datei: ${_p(feld)}: ganze Zahl oder null erwartet');
    return v as int?;
  }

  double kommazahl(String feld) {
    final v = _roh(feld);
    if (v is! num) throw FormatException('$datei: ${_p(feld)}: Zahl erwartet');
    return v.toDouble();
  }

  bool wahr(String feld) {
    final v = _roh(feld);
    if (v is! bool) throw FormatException('$datei: ${_p(feld)}: true oder false erwartet');
    return v;
  }

  T _wert<T>(String feld, List<T> werte) {
    final v = _roh(feld);
    for (final w in werte) {
      if (w is Enum && w.name == v) return w;
    }
    throw FormatException('$datei: ${_p(feld)}: einer von ${werte.map((w) => (w as Enum).name).join(', ')} erwartet');
  }

  List<Object?> _liste(String feld) {
    final v = _roh(feld);
    if (v is! List) throw FormatException('$datei: ${_p(feld)}: Liste erwartet');
    return v;
  }

  T objekt<T>(String feld, T Function(_Knoten k) lese) => _objekt(_roh(feld), _p(feld), lese);

  T? objektOderNull<T>(String feld, T Function(_Knoten k) lese) {
    final v = _roh(feld);
    return v == null ? null : _objekt(v, _p(feld), lese);
  }

  T _objekt<T>(Object? v, String pfad, T Function(_Knoten k) lese) {
    if (v is! Map<String, Object?>) throw FormatException('$datei: $pfad: Objekt erwartet');
    final k = _Knoten(_l, datei, pfad, v);
    final aus = lese(k);
    k._fertig();
    return aus;
  }

  List<T> liste<T>(String feld, T Function(_Knoten k) lese) {
    final l = _liste(feld);
    return [for (var i = 0; i < l.length; i++) _objekt(l[i], '${_p(feld)}[$i]', lese)];
  }

  List<String> texte(String feld, {Set<String>? werte = const {}}) {
    final l = _liste(feld);
    return [for (var i = 0; i < l.length; i++) _l.text(l[i], datei, '${_p(feld)}[$i]', werte)];
  }

  List<String> kennungen(String feld) {
    final l = _liste(feld);
    return [for (var i = 0; i < l.length; i++) _kennung(l[i], '${_p(feld)}[$i]')];
  }

  List<int> zahlen(String feld) {
    final l = _liste(feld);
    return [
      for (var i = 0; i < l.length; i++)
        if (l[i] is int) l[i] as int else throw FormatException('$datei: ${_p(feld)}[$i]: ganze Zahl erwartet'),
    ];
  }

  /// Liste aus genau zwei ganzen Zahlen (Bereich, Zelle).
  (int, int) paar(String feld) {
    final z = zahlen(feld);
    if (z.length != 2) throw FormatException('$datei: ${_p(feld)}: genau zwei Zahlen erwartet');
    return (z[0], z[1]);
  }

  List<(int, int)> paare(String feld) {
    final l = _liste(feld);
    return [
      for (var i = 0; i < l.length; i++)
        if (l[i] case [final int a, final int b]) (a, b) else throw FormatException('$datei: ${_p(feld)}[$i]: genau zwei Zahlen erwartet'),
    ];
  }

  /// Wert-Bedingung für [feld]; sonst [FormatException] mit Pfad.
  void pruefe(bool ok, String feld) {
    if (!ok) throw FormatException('$datei: ${_p(feld)}: ungültiger Wert');
  }
}

T _datei<T>(_Lader l, Map<String, Object?> json, String datei, T Function(_Knoten k) lese) {
  final k = _Knoten(l, datei, '', json);
  final aus = lese(k);
  k._fertig();
  return aus;
}

// ---------------------------------------------------------------- fall.json

/// Ein Platz 1–18 (fall.json `plaetze`).
class KammerPlatz {
  const KammerPlatz({
    required this.platz,
    required this.id,
    required this.kanonFigur,
    required this.name,
    required this.bezeichnung,
    required this.art,
    required this.tandem,
    required this.datei,
  });

  final int platz;

  /// Rollen-ID im Inhalt (Platzhalter, Dateiname), etwa `lejla`.
  final String id;

  /// Figuren-ID im Kanon (`content/party/schlosskeller/figuren.json`), etwa `leyla`.
  final String kanonFigur;

  /// Name, wie er gedruckt wird.
  final String name;

  /// Rollenbezeichnung mit Artikel, klein, etwa „die Apothekerin“ (Kanon
  /// `roleTitle`; MECH 9.4 Vorstellungsrunde, MECH 5.3 Etikett, ZR-22).
  final String bezeichnung;
  final KammerArt art;

  /// Tandem 1–4 bei Zusatzrollen, sonst null.
  final int? tandem;

  /// Rollendatei, ordner-relativ.
  final String datei;

  static KammerPlatz _aus(_Knoten k) => KammerPlatz(
        platz: k.zahl('platz'),
        id: k.kennung('id'),
        kanonFigur: k.kennung('kanonFigur'),
        name: k.text('name'),
        bezeichnung: k.text('bezeichnung'),
        art: k._wert('art', KammerArt.values),
        tandem: k.zahlOderNull('tandem'),
        datei: k.kennung('datei'),
      );
}

class KammerTandem {
  const KammerTandem(this.nr, this.plaetze, this.thema);
  final int nr;

  /// Die zwei Plätze, der kleinere zuerst; der kleinere spielt allein, wenn der
  /// größere fehlt (E6).
  final List<int> plaetze;
  final String thema;

  static KammerTandem _aus(_Knoten k) => KammerTandem(k.zahl('nr'), k.zahlen('plaetze'), k.text('thema'));
}

class KammerRunde {
  const KammerRunde(this.nr, this.name, this.uhr);
  final int nr;
  final String name;

  /// Uhrzeit im Spiel, zu der die Runde beginnt.
  final String uhr;

  static KammerRunde _aus(_Knoten k) => KammerRunde(k.zahl('nr'), k.text('name'), k.text('uhr'));
}

/// Personenschwellen, an denen sich der Ablauf ändert (MECH 1.3, 9.13, 8.4).
class KammerSchwellen {
  const KammerSchwellen({
    required this.verhoerLeiseAb,
    required this.gegenueberstellungAb,
    required this.gegenueberstellungLangAb,
    required this.rollenAmTischSelbstAb,
    required this.tippWertungZweiSeitenAb,
    required this.abschnittBKurzBis,
    required this.dankeskarteAb,
  });

  final int verhoerLeiseAb;
  final int gegenueberstellungAb;
  final int gegenueberstellungLangAb;
  final int rollenAmTischSelbstAb;
  final int tippWertungZweiSeitenAb;
  final int abschnittBKurzBis;
  final int dankeskarteAb;

  static KammerSchwellen _aus(_Knoten k) => KammerSchwellen(
        verhoerLeiseAb: k.zahl('verhoerLeiseAb'),
        gegenueberstellungAb: k.zahl('gegenueberstellungAb'),
        gegenueberstellungLangAb: k.zahl('gegenueberstellungLangAb'),
        rollenAmTischSelbstAb: k.zahl('rollenAmTischSelbstAb'),
        tippWertungZweiSeitenAb: k.zahl('tippWertungZweiSeitenAb'),
        abschnittBKurzBis: k.zahl('abschnittBKurzBis'),
        dankeskarteAb: k.zahl('dankeskarteAb'),
      );
}

class KammerZone {
  const KammerZone(this.nr, this.name, this.felder);
  final String nr;
  final String name;
  final List<String> felder;

  static KammerZone _aus(_Knoten k) => KammerZone(k.kennung('nr'), k.text('name'), k.kennungen('felder'));
}

/// Ein Feld des Lageplans (Markerfeld, Teilfeld oder Randfeld W).
class KammerFeld {
  const KammerFeld(this.id, this.zone, this.name);
  final String id;
  final String zone;
  final String name;

  static KammerFeld _aus(_Knoten k) => KammerFeld(k.kennung('id'), k.kennung('zone'), k.text('name'));
}

class KammerMeilenstein {
  const KammerMeilenstein(this.nr, this.zeile, this.spalte, this.punkte);
  final String nr;

  /// Zeile des Ermittlungsbogens: `alibi`, `heimlichtuerei`, `fundort`, `schluesselbeweis`.
  final String zeile;

  /// Rollen-ID der Spalte, null beim Fundort.
  final String? spalte;
  final int punkte;

  static KammerMeilenstein _aus(_Knoten k) =>
      KammerMeilenstein(k.kennung('nr'), k.kennung('zeile'), k.kennungOderNull('spalte'), k.zahl('punkte'));
}

class KammerPunkte {
  const KammerPunkte({
    required this.detektivMax,
    required this.tippTaeter,
    required this.tippVersteck,
    required this.tippBonus,
    required this.taeterSonder,
    required this.jePersonMax,
  });

  final int detektivMax;
  final int tippTaeter;
  final int tippVersteck;
  final int tippBonus;

  /// Punkte für den Täter, wenn der Detektiv nicht ihn anklagt (M-22).
  final int taeterSonder;
  final int jePersonMax;

  static KammerPunkte _aus(_Knoten k) {
    final (t, v, b) = k.objekt('tipp', (t) => (t.zahl('taeter'), t.zahl('versteck'), t.zahl('bonus')));
    return KammerPunkte(
      detektivMax: k.zahl('detektivMax'),
      tippTaeter: t,
      tippVersteck: v,
      tippBonus: b,
      taeterSonder: k.zahl('taeterSonder'),
      jePersonMax: k.zahl('jePersonMax'),
    );
  }
}

/// Ein Ende: Anklage (`taeter` oder `andere`) und Punktebereich, beide Grenzen eingeschlossen.
class KammerEnde {
  const KammerEnde(this.nr, this.anklage, this.von, this.bis);
  final int nr;
  final String anklage;
  final int von;
  final int bis;

  bool passt({required bool taeterAngeklagt, required int punkte}) =>
      (anklage == 'taeter') == taeterAngeklagt && punkte >= von && punkte <= bis;

  static KammerEnde _aus(_Knoten k) => KammerEnde(k.zahl('nr'), k.kennung('anklage'), k.zahl('von'), k.zahl('bis'));
}

class KammerFall {
  const KammerFall({
    required this.kennung,
    required this.fallCode,
    required this.taeter,
    required this.personenMin,
    required this.personenMax,
    required this.personenVorgabe,
    required this.ohneRolle,
    required this.plaetze,
    required this.tandems,
    required this.runden,
    required this.untersuchungenJeRunde,
    required this.schwellen,
    required this.zonen,
    required this.felder,
    required this.zeitpunkte,
    required this.uhrzeiten,
    required this.raumnamen,
    required this.meilensteine,
    required this.punkte,
    required this.enden,
    required this.fassungsCodes,
    required this.indizCodes,
    required this.teile,
  });

  final String kennung;
  final String fallCode;

  /// Rollen-ID des Täters.
  final String taeter;
  final int personenMin;
  final int personenMax;
  final int personenVorgabe;

  /// Personen ohne Rolle (Erzähler, Detektiv): Personen = Rollen + diese.
  final List<String> ohneRolle;
  final List<KammerPlatz> plaetze;
  final List<KammerTandem> tandems;
  final List<KammerRunde> runden;
  final int untersuchungenJeRunde;
  final KammerSchwellen schwellen;
  final List<KammerZone> zonen;
  final List<KammerFeld> felder;

  /// Kennungen der zwei Marker-Zeitpunkte (`z2357`, `scheppern`).
  final List<String> zeitpunkte;

  /// Erlaubte Uhrzeiten H:MM in Spielertexten (WELT 0.2).
  final List<String> uhrzeiten;
  final List<String> raumnamen;
  final List<KammerMeilenstein> meilensteine;
  final KammerPunkte punkte;
  final List<KammerEnde> enden;
  final List<String> fassungsCodes;
  final List<String> indizCodes;

  /// Teile des Drucks in Reihenfolge.
  final List<String> teile;

  KammerFeld feld(String id) => felder.firstWhere((f) => f.id == id, orElse: () => throw ArgumentError.value(id, 'feld'));

  static KammerFall _aus(_Knoten k) {
    final (min, max, vorgabe, ohne) = k.objekt(
      'personen',
      (p) => (p.zahl('min'), p.zahl('max'), p.zahl('vorgabe'), p.kennungen('ohneRolle')),
    );
    final (fassungen, indiz) = k.objekt('codes', (c) => (c.kennungen('fassungen'), c.kennungen('indizkarten')));
    return KammerFall(
      kennung: k.kennung('kennung'),
      fallCode: k.kennung('fallCode'),
      taeter: k.kennung('taeter'),
      personenMin: min,
      personenMax: max,
      personenVorgabe: vorgabe,
      ohneRolle: ohne,
      plaetze: k.liste('plaetze', KammerPlatz._aus),
      tandems: k.liste('tandems', KammerTandem._aus),
      runden: k.liste('runden', KammerRunde._aus),
      untersuchungenJeRunde: k.zahl('untersuchungenJeRunde'),
      schwellen: k.objekt('schwellen', KammerSchwellen._aus),
      zonen: k.liste('zonen', KammerZone._aus),
      felder: k.liste('felder', KammerFeld._aus),
      zeitpunkte: k.kennungen('zeitpunkte'),
      uhrzeiten: k.kennungen('uhrzeiten'),
      raumnamen: k.texte('raumnamen'),
      meilensteine: k.liste('meilensteine', KammerMeilenstein._aus),
      punkte: k.objekt('punkte', KammerPunkte._aus),
      enden: k.liste('enden', KammerEnde._aus),
      fassungsCodes: fassungen,
      indizCodes: indiz,
      teile: k.kennungen('teile'),
    );
  }
}

// ---------------------------------------------------------------- gemeinsam.json

class KammerRegel {
  const KammerRegel(this.nr, this.name, this.text);
  final String nr;
  final String name;
  final String text;

  static KammerRegel _aus(_Knoten k) => KammerRegel(k.kennung('nr'), k.text('name'), k.text('text'));
}

/// Spieltexte, die in mehreren Teilen gleich lauten.
class KammerGemeinsam {
  const KammerGemeinsam(this.wasAlleWissen, this.soSpieltIhr, this.tischregeln, this.licht);

  /// „Was alle wissen“ (MECH 1.5): Teile 00, 01, 10, 12.
  final List<String> wasAlleWissen;

  /// Kurzform der Tischregeln (MECH 1.4): Teile 01, 10, 12.
  final String soSpieltIhr;

  /// Tischregeln R-01 bis R-14 (MECH 1.4): Teil 00 ganz.
  final List<KammerRegel> tischregeln;

  /// „Licht im Keller nach dem Knall“ (MECH 9.11 B): Teile 00 und 01.
  final String licht;

  static KammerGemeinsam _aus(_Knoten k) => KammerGemeinsam(
        k.texte('wasAlleWissen'),
        k.text('soSpieltIhr'),
        k.liste('tischregeln', KammerRegel._aus),
        k.text('licht'),
      );
}

// ---------------------------------------------------------------- erzaehlerheft.json (Teil 00)

class KammerTaetigkeit {
  const KammerTaetigkeit(this.teil, this.text, this.minuten);
  final String teil;
  final String text;
  final int? minuten;

  static KammerTaetigkeit _aus(_Knoten k) => KammerTaetigkeit(k.kennung('teil'), k.text('text'), k.zahlOderNull('minuten'));
}

class KammerAblaufSchritt {
  const KammerAblaufSchritt(this.schritt, this.name, this.minuten, this.uhr);
  final int schritt;
  final String name;

  /// Minuten an den Stützstellen 6, 12 und 20 Personen (MECH 1.1).
  final Map<int, int> minuten;
  final String? uhr;

  /// Minuten bei [personen]: zwischen den Stützstellen linear, gerundet.
  int minutenBei(int personen) {
    final stellen = minuten.keys.toList()..sort();
    if (personen <= stellen.first) return minuten[stellen.first]!;
    for (var i = 1; i < stellen.length; i++) {
      final a = stellen[i - 1];
      final b = stellen[i];
      if (personen <= b) {
        final t = (personen - a) / (b - a);
        return (minuten[a]! + t * (minuten[b]! - minuten[a]!)).round();
      }
    }
    return minuten[stellen.last]!;
  }

  static KammerAblaufSchritt _aus(_Knoten k) => KammerAblaufSchritt(
        k.zahl('schritt'),
        k.text('name'),
        k.objekt('minuten', (m) => {6: m.zahl('6'), 12: m.zahl('12'), 20: m.zahl('20')}),
        k.textOderNull('uhr'),
      );
}

class KammerRundenabschnitt {
  const KammerRundenabschnitt(this.abschnitt, this.name, this.minuten, this.text);
  final String abschnitt;
  final String name;
  final int minuten;
  final String text;

  static KammerRundenabschnitt _aus(_Knoten k) =>
      KammerRundenabschnitt(k.kennung('abschnitt'), k.text('name'), k.zahl('minuten'), k.text('text'));
}

/// Text zu einem Schlüssel: Rollen-ID (Lacher fehlender Rollen, Tipps), Zeugen-ID
/// (Umschreibungen) oder Feld-ID (Legende des Lageplans).
class KammerEintrag {
  const KammerEintrag(this.schluessel, this.text);
  final String schluessel;
  final String text;

  static KammerEintrag Function(_Knoten) _aus(String feld) => (k) => KammerEintrag(k.kennung(feld), k.text('text'));
}

class KammerVorstellung {
  const KammerVorstellung(this.anleitung, this.start, this.frageDetektiv, this.lacherFehlend, this.abschluss);
  final String anleitung;
  final String start;
  final String frageDetektiv;

  /// Wörtliche Sätze, wenn diese Rolle heute fehlt (MECH 9.4).
  final List<KammerEintrag> lacherFehlend;
  final String abschluss;

  static KammerVorstellung _aus(_Knoten k) => KammerVorstellung(
        k.text('anleitung'),
        k.text('start'),
        k.text('frageDetektiv'),
        k.liste('lacherFehlend', KammerEintrag._aus('rolle')),
        k.text('abschluss'),
      );
}

class KammerFuehrungsSchritt {
  const KammerFuehrungsSchritt(this.vorlesen, this.text, this.nurMitStreifen);

  /// true: Vorlesetext, false: Anleitung.
  final bool vorlesen;
  final String text;

  /// Nur drucken, wenn heute Zeugenstreifen ausliegen.
  final bool nurMitStreifen;

  static KammerFuehrungsSchritt _aus(_Knoten k) {
    final art = k.kennung('art');
    k.pruefe(art == 'vorlesen' || art == 'anleitung', 'art');
    return KammerFuehrungsSchritt(art == 'vorlesen', k.text('text'), k.wahr('nurMitStreifen'));
  }
}

class KammerImpuls {
  const KammerImpuls(this.id, this.titel, this.text, this.hinweis);
  final String id;
  final String titel;
  final String text;
  final String? hinweis;

  static KammerImpuls _aus(_Knoten k) =>
      KammerImpuls(k.kennung('id'), k.text('titel'), k.text('text'), k.textOderNull('hinweis'));
}

class KammerRundeTexte {
  const KammerRundeTexte(this.nr, this.start, this.schluss, this.impulse);
  final int nr;
  final String start;

  /// Rundenschluss; in Runde 3 null (dort folgt die Tipp-Runde).
  final String? schluss;
  final List<KammerImpuls> impulse;

  static KammerRundeTexte _aus(_Knoten k) =>
      KammerRundeTexte(k.zahl('nr'), k.text('start'), k.textOderNull('schluss'), k.liste('impulse', KammerImpuls._aus));
}

class KammerVorlesenAnleitung {
  const KammerVorlesenAnleitung(this.vorlesen, this.anleitung);
  final String vorlesen;
  final String anleitung;

  static KammerVorlesenAnleitung _aus(_Knoten k) => KammerVorlesenAnleitung(k.text('vorlesen'), k.text('anleitung'));
}

class KammerFrageAntwort {
  const KammerFrageAntwort(this.frage, this.antwort);
  final String frage;
  final String antwort;

  static KammerFrageAntwort _aus(_Knoten k) => KammerFrageAntwort(k.text('frage'), k.text('antwort'));
}

class KammerMass {
  const KammerMass(this.von, this.nach, this.abstand, this.dunkel);
  final String von;
  final String nach;
  final String abstand;
  final String dunkel;

  static KammerMass _aus(_Knoten k) => KammerMass(k.text('von'), k.text('nach'), k.text('abstand'), k.text('dunkel'));
}

/// Hinweis der Skalierungsanleitung für einen Personenbereich (beide Grenzen eingeschlossen).
class KammerSkalierungsHinweis {
  const KammerSkalierungsHinweis(this.von, this.bis, this.text);
  final int von;
  final int bis;
  final String text;

  static KammerSkalierungsHinweis _aus(_Knoten k) => KammerSkalierungsHinweis(k.zahl('von'), k.zahl('bis'), k.text('text'));
}

class KammerErzaehlerheft {
  const KammerErzaehlerheft({
    required this.vorbereitungHinweis,
    required this.vorbereitungTaetigkeiten,
    required this.vorbereitungAnWen,
    required this.ablauf,
    required this.rundenaufbau,
    required this.runde3Reihenfolge,
    required this.gegenueberstellungRegel,
    required this.kleineRunden,
    required this.soLaeuftDerAbend,
    required this.vorgeschichte,
    required this.vorstellung,
    required this.tatMoment,
    required this.auftrag,
    required this.fassungenOeffnen,
    required this.lageplanFuehrung,
    required this.impulsRegeln,
    required this.ausweichsatz,
    required this.dominoWann,
    required this.dominoNenntPerson,
    required this.dominoSonst,
    required this.dominoFehlt,
    required this.gegenueberstellungWann,
    required this.gegenueberstellung,
    required this.runden,
    required this.bonusZiel,
    required this.tippRunde,
    required this.anklage,
    required this.herrSchneiderAntwortet,
    required this.masstabelle,
    required this.taschenkontrolle,
    required this.skalierungsHinweise,
    required this.kartenUnterStreifenAnleitung,
    required this.kartenUnterStreifenMuster,
    required this.umschreibungen,
    required this.kartenUnterStreifenHinweis,
  });

  final String vorbereitungHinweis;
  final List<KammerTaetigkeit> vorbereitungTaetigkeiten;
  final String vorbereitungAnWen;
  final List<KammerAblaufSchritt> ablauf;
  final List<KammerRundenabschnitt> rundenaufbau;
  final String runde3Reihenfolge;
  final String gegenueberstellungRegel;
  final String kleineRunden;
  final String soLaeuftDerAbend;
  final String vorgeschichte;
  final KammerVorstellung vorstellung;
  final String tatMoment;
  final String auftrag;
  /// Anleitung MECH 9.6; nennt die Seite mit „Was alle wissen“ (MECH 9.1: Seite 7).
  /// Wert-Platzhalter `{seite}` erlaubt, falls der Satz die Seite nicht fest nennt.
  final String fassungenOeffnen;
  final List<KammerFuehrungsSchritt> lageplanFuehrung;
  final String impulsRegeln;
  final String ausweichsatz;
  final String dominoWann;
  final String dominoNenntPerson;
  final String dominoSonst;
  final String dominoFehlt;
  final String gegenueberstellungWann;
  final String gegenueberstellung;
  final List<KammerRundeTexte> runden;
  final String bonusZiel;
  final KammerVorlesenAnleitung tippRunde;
  final KammerVorlesenAnleitung anklage;
  final List<KammerFrageAntwort> herrSchneiderAntwortet;
  final List<KammerMass> masstabelle;
  final String taschenkontrolle;
  final List<KammerSkalierungsHinweis> skalierungsHinweise;
  final String kartenUnterStreifenAnleitung;

  /// Vorlage mit den Werten `{name}`, `{codes}`, `{runde}` (MECH 9.14).
  final String kartenUnterStreifenMuster;

  /// Wie die Hefte einen fehlenden Zeugen umschreiben (für den „Zeitstempel“).
  final List<KammerEintrag> umschreibungen;
  final String kartenUnterStreifenHinweis;

  /// Alle Impulse aller Runden.
  Iterable<KammerImpuls> get impulse => runden.expand((r) => r.impulse);

  /// Hinweis der Skalierungsanleitung für [personen], falls es einen gibt.
  String? skalierungsHinweis(int personen) {
    for (final h in skalierungsHinweise) {
      if (personen >= h.von && personen <= h.bis) return h.text;
    }
    return null;
  }

  static KammerErzaehlerheft _aus(_Knoten k) {
    final (vh, vt, va) = k.objekt(
      'vorbereitung',
      (v) => (v.text('hinweis'), v.liste('taetigkeiten', KammerTaetigkeit._aus), v.text('anWen')),
    );
    final (dw, dn, ds, df) = k.objekt(
      'dominoFrage',
      (d) => (d.text('wann'), d.text('nenntPerson'), d.text('sonst'), d.text('fehlt')),
    );
    final (gw, gt) = k.objekt('gegenueberstellung', (g) => (g.text('wann'), g.text('text')));
    final skal = k.objekt('skalierung', (s) => s.liste('hinweise', KammerSkalierungsHinweis._aus));
    final (ka, km, ku, kh) = k.objekt(
      'kartenUnterStreifen',
      (s) => (
        s.text('anleitung'),
        s.text('muster', werte: const {'name', 'codes', 'runde'}),
        s.liste('umschreibungen', KammerEintrag._aus('zeuge')),
        s.text('hinweis'),
      ),
    );
    return KammerErzaehlerheft(
      vorbereitungHinweis: vh,
      vorbereitungTaetigkeiten: vt,
      vorbereitungAnWen: va,
      ablauf: k.liste('ablauf', KammerAblaufSchritt._aus),
      rundenaufbau: k.liste('rundenaufbau', KammerRundenabschnitt._aus),
      runde3Reihenfolge: k.text('runde3Reihenfolge'),
      gegenueberstellungRegel: k.text('gegenueberstellungRegel'),
      kleineRunden: k.text('kleineRunden'),
      soLaeuftDerAbend: k.text('soLaeuftDerAbend'),
      vorgeschichte: k.text('vorgeschichte'),
      vorstellung: k.objekt('vorstellung', KammerVorstellung._aus),
      tatMoment: k.text('tatMoment'),
      auftrag: k.text('auftrag'),
      fassungenOeffnen: k.text('fassungenOeffnen', werte: const {'seite'}),
      lageplanFuehrung: k.liste('lageplanFuehrung', KammerFuehrungsSchritt._aus),
      impulsRegeln: k.text('impulsRegeln'),
      ausweichsatz: k.text('ausweichsatz'),
      dominoWann: dw,
      dominoNenntPerson: dn,
      dominoSonst: ds,
      dominoFehlt: df,
      gegenueberstellungWann: gw,
      gegenueberstellung: gt,
      runden: k.liste('runden', KammerRundeTexte._aus),
      bonusZiel: k.text('bonusZiel'),
      tippRunde: k.objekt('tippRunde', KammerVorlesenAnleitung._aus),
      anklage: k.objekt('anklage', KammerVorlesenAnleitung._aus),
      herrSchneiderAntwortet: k.liste('herrSchneiderAntwortet', KammerFrageAntwort._aus),
      masstabelle: k.liste('masstabelle', KammerMass._aus),
      taschenkontrolle: k.text('taschenkontrolle'),
      skalierungsHinweise: skal,
      kartenUnterStreifenAnleitung: ka,
      kartenUnterStreifenMuster: km,
      umschreibungen: ku,
      kartenUnterStreifenHinweis: kh,
    );
  }
}

// ---------------------------------------------------------------- detektiv.json (Teil 01)

class KammerLeitfadenFrage {
  const KammerLeitfadenFrage(this.nr, this.text);
  final String? nr;
  final String text;

  static KammerLeitfadenFrage _aus(_Knoten k) => KammerLeitfadenFrage(k.kennungOderNull('nr'), k.text('text'));
}

class KammerLeitfadenGruppe {
  const KammerLeitfadenGruppe(this.titel, this.fragen);
  final String titel;
  final List<KammerLeitfadenFrage> fragen;

  static KammerLeitfadenGruppe _aus(_Knoten k) =>
      KammerLeitfadenGruppe(k.text('titel'), k.liste('fragen', KammerLeitfadenFrage._aus));
}

class KammerAufgabenRunde {
  const KammerAufgabenRunde(this.runde, this.zeilen);
  final int runde;
  final List<String> zeilen;

  static KammerAufgabenRunde _aus(_Knoten k) => KammerAufgabenRunde(k.zahl('runde'), k.texte('zeilen'));
}

class KammerBogenZeile {
  const KammerBogenZeile(this.id, this.titel, this.zusatz);

  /// `ort2357`, `alibi`, `heimlichtuerei`, `ausgeschieden`.
  final String id;
  final String titel;
  final String? zusatz;

  static KammerBogenZeile _aus(_Knoten k) => KammerBogenZeile(k.kennung('id'), k.text('titel'), k.textOderNull('zusatz'));
}

class KammerBogen {
  const KammerBogen({
    required this.hinweis,
    required this.zeilen,
    required this.spalten,
    required this.unterRaster,
    required this.entlastungsregel,
    required this.ueberfuehrungsregel,
    required this.fuehren,
  });

  final String hinweis;
  final List<KammerBogenZeile> zeilen;

  /// Rollen-IDs der vier Spalten.
  final List<String> spalten;
  final List<String> unterRaster;
  final String entlastungsregel;
  final String ueberfuehrungsregel;
  final String fuehren;

  static KammerBogen _aus(_Knoten k) => KammerBogen(
        hinweis: k.text('hinweis'),
        zeilen: k.liste('zeilen', KammerBogenZeile._aus),
        spalten: k.kennungen('spalten'),
        unterRaster: k.texte('unterRaster'),
        entlastungsregel: k.text('entlastungsregel'),
        ueberfuehrungsregel: k.text('ueberfuehrungsregel'),
        fuehren: k.text('fuehren'),
      );
}

class KammerDetektiv {
  const KammerDetektiv({
    required this.auftritt,
    required this.wasDuSelbstWeisst,
    required this.fragenLeitfaden,
    required this.untersuchungen,
    required this.aufgabenJeRunde,
    required this.bogen,
    required this.vermerkeZeilen,
    required this.anklageFeld,
    required this.anklageHilfe,
    required this.aktionskartenTipps,
    required this.gegenKarten,
    required this.wennRollenFehlen,
  });

  final String auftritt;
  final List<String> wasDuSelbstWeisst;
  final List<KammerLeitfadenGruppe> fragenLeitfaden;
  final List<String> untersuchungen;
  final List<KammerAufgabenRunde> aufgabenJeRunde;
  final KammerBogen bogen;
  final int vermerkeZeilen;
  final List<String> anklageFeld;
  final String anklageHilfe;

  /// Tipps zu den Aktionskarten fehlender Zeugen, je Zeugen-ID (RK 6.8).
  final List<KammerEintrag> aktionskartenTipps;
  final String gegenKarten;

  /// „Wenn Rollen fehlen“ (RK 6.12): Hinweise je Personenbereich; die
  /// Bereiche dürfen sich überschneiden (6–11 und 6, 12–20 und 15–20).
  final List<KammerSkalierungsHinweis> wennRollenFehlen;

  /// Alle Hinweise aus [wennRollenFehlen], die bei [personen] gelten, in
  /// Dateireihenfolge.
  List<String> wennRollenFehlenBei(int personen) =>
      [for (final h in wennRollenFehlen) if (personen >= h.von && personen <= h.bis) h.text];

  static KammerDetektiv _aus(_Knoten k) {
    final (feld, hilfe) = k.objekt('anklage', (a) => (a.texte('feld'), a.text('hilfe')));
    return KammerDetektiv(
      auftritt: k.text('auftritt'),
      wasDuSelbstWeisst: k.texte('wasDuSelbstWeisst'),
      fragenLeitfaden: k.liste('fragenLeitfaden', KammerLeitfadenGruppe._aus),
      untersuchungen: k.texte('untersuchungen'),
      aufgabenJeRunde: k.liste('aufgabenJeRunde', KammerAufgabenRunde._aus),
      bogen: k.objekt('bogen', KammerBogen._aus),
      vermerkeZeilen: k.zahl('vermerkeZeilen'),
      anklageFeld: feld,
      anklageHilfe: hilfe,
      aktionskartenTipps: k.liste('aktionskartenTipps', KammerEintrag._aus('rolle')),
      gegenKarten: k.text('gegenKarten'),
      wennRollenFehlen: k.liste('wennRollenFehlen', KammerSkalierungsHinweis._aus),
    );
  }
}

// ---------------------------------------------------------------- tisch.json (Teil 02)

/// Kachelbereich im Raster (WELT 2.3): Kachel k reicht von k bis k+1, beide Grenzen eingeschlossen.
class KammerBereich {
  const KammerBereich(this.x0, this.x1, this.y0, this.y1);
  final int x0;
  final int x1;
  final int y0;
  final int y1;

  /// Ob der Punkt (Meter) in einer Kachel dieses Bereichs liegt.
  bool enthaelt(double x, double y) => x >= x0 && x < x1 + 1 && y >= y0 && y < y1 + 1;

  static KammerBereich _aus(_Knoten k) {
    final (x0, x1) = k.paar('x');
    final (y0, y1) = k.paar('y');
    k.pruefe(x0 <= x1 && y0 <= y1, 'x');
    return KammerBereich(x0, x1, y0, y1);
  }
}

class KammerFlaeche {
  const KammerFlaeche(this.id, this.name, this.kacheln);
  final String id;

  /// Beschriftung; bei Feldflächen null (der Name steht in fall.json).
  final String? name;
  final List<KammerBereich> kacheln;

  bool enthaelt(double x, double y) => kacheln.any((b) => b.enthaelt(x, y));

  static KammerFlaeche _mitName(_Knoten k) =>
      KammerFlaeche(k.kennung('id'), k.text('name'), k.liste('kacheln', KammerBereich._aus));

  static KammerFlaeche _feld(_Knoten k) => KammerFlaeche(k.kennung('feld'), null, k.liste('kacheln', KammerBereich._aus));
}

class KammerPunkt {
  const KammerPunkt(this.id, this.name, this.x, this.y, this.zusatz);
  final String id;
  final String name;
  final double x;
  final double y;

  /// Tür: Zustand (`offen`, `angelehnt`, `zu`, `verschlossen`); Gegenstand: Feld-ID.
  final String zusatz;

  static KammerPunkt Function(_Knoten) _aus(String feld) =>
      (k) => KammerPunkt(k.kennung('id'), k.text('name'), k.kommazahl('x'), k.kommazahl('y'), k.kennung(feld));
}

class KammerLageplan {
  const KammerLageplan({
    required this.x0,
    required this.y0,
    required this.breite,
    required this.hoehe,
    required this.mmJeMeter,
    required this.raeume,
    required this.felder,
    required this.tueren,
    required this.moebel,
    required this.gegenstaende,
    required this.legende,
    required this.hinweise,
  });

  /// Erste Kachel und Größe des Rasters in Metern (WELT 2.3).
  final int x0;
  final int y0;
  final int breite;
  final int hoehe;
  final double mmJeMeter;
  final List<KammerFlaeche> raeume;

  /// Flächen der Markerfelder (ID wie in fall.json `felder`).
  final List<KammerFlaeche> felder;

  /// Türen; [KammerPunkt.zusatz] ist der Zustand.
  final List<KammerPunkt> tueren;
  final List<KammerFlaeche> moebel;

  /// Gegenstände mit Symbol; [KammerPunkt.zusatz] ist das Feld.
  final List<KammerPunkt> gegenstaende;

  /// Legende je Feld (Feld-ID → Text).
  final List<KammerEintrag> legende;
  final List<String> hinweise;

  static KammerLageplan _aus(_Knoten k) {
    final (x0, y0, b, h, mm) = k.objekt(
      'raster',
      (r) => (r.zahl('x0'), r.zahl('y0'), r.zahl('breite'), r.zahl('hoehe'), r.kommazahl('mmJeMeter')),
    );
    return KammerLageplan(
      x0: x0,
      y0: y0,
      breite: b,
      hoehe: h,
      mmJeMeter: mm,
      raeume: k.liste('raeume', KammerFlaeche._mitName),
      felder: k.liste('felder', KammerFlaeche._feld),
      tueren: k.liste('tueren', KammerPunkt._aus('zustand')),
      moebel: k.liste('moebel', KammerFlaeche._mitName),
      gegenstaende: k.liste('gegenstaende', KammerPunkt._aus('feld')),
      legende: k.liste('legende', KammerEintrag._aus('feld')),
      hinweise: k.texte('hinweise'),
    );
  }
}

class KammerMarkerfeld {
  const KammerMarkerfeld(this.feld, this.zellen, this.plaettchen);
  final String feld;

  /// Zellen (Spalte, Reihe) auf Blatt B.
  final List<(int, int)> zellen;

  /// Platz für so viele Plättchen.
  final int plaettchen;

  static KammerMarkerfeld _aus(_Knoten k) => KammerMarkerfeld(k.kennung('feld'), k.paare('zellen'), k.zahl('plaettchen'));
}

class KammerMarkerfelder {
  const KammerMarkerfelder(this.spalten, this.reihen, this.zelleBreiteMm, this.zelleHoeheMm, this.belegung);
  final int spalten;
  final int reihen;
  final int zelleBreiteMm;
  final int zelleHoeheMm;
  final List<KammerMarkerfeld> belegung;

  static KammerMarkerfelder _aus(_Knoten k) => KammerMarkerfelder(
        k.zahl('spalten'),
        k.zahl('reihen'),
        k.zahl('zelleBreiteMm'),
        k.zahl('zelleHoeheMm'),
        k.liste('belegung', KammerMarkerfeld._aus),
      );
}

/// Fester Marker ohne Rolle: Detektiv oder Herr Schneider (Feld je Zeitpunkt).
class KammerFesterMarker {
  const KammerFesterMarker(this.wer, this.z2357, this.scheppern);
  final String wer;
  final String z2357;
  final String scheppern;

  static KammerFesterMarker _aus(_Knoten k) =>
      KammerFesterMarker(k.kennung('wer'), k.kennung('z2357'), k.kennung('scheppern'));
}

class KammerMarkerVorgabe {
  const KammerMarkerVorgabe(this.breiteMm, this.hoeheMm, this.jeRolle, this.max, this.feste);
  final int breiteMm;
  final int hoeheMm;
  final int jeRolle;
  final int max;
  final List<KammerFesterMarker> feste;

  static KammerMarkerVorgabe _aus(_Knoten k) => KammerMarkerVorgabe(
        k.zahl('breiteMm'),
        k.zahl('hoeheMm'),
        k.zahl('jeRolle'),
        k.zahl('max'),
        k.liste('feste', KammerFesterMarker._aus),
      );
}

class KammerTippFrage {
  const KammerTippFrage(this.nr, this.art, this.text, this.punkte);
  final int nr;

  /// `taeter`, `versteck`, `bonus`.
  final String art;
  final String text;
  final int punkte;

  static KammerTippFrage _aus(_Knoten k) =>
      KammerTippFrage(k.zahl('nr'), k.kennung('art'), k.text('text'), k.zahl('punkte'));
}

class KammerTippZettel {
  const KammerTippZettel(this.titel, this.name, this.fragen, this.fuss, this.jeBlatt);
  final String titel;
  final String name;
  final List<KammerTippFrage> fragen;
  final String fuss;
  final int jeBlatt;

  static KammerTippZettel _aus(_Knoten k) => KammerTippZettel(
        k.text('titel'),
        k.text('name'),
        k.liste('fragen', KammerTippFrage._aus),
        k.text('fuss'),
        k.zahl('jeBlatt'),
      );
}

/// Maße des Abwesenheitsblatts (MECH 5.2).
class KammerAbwesenheitsblatt {
  const KammerAbwesenheitsblatt({
    required this.spalten,
    required this.reihen,
    required this.randMm,
    required this.streifenBreiteMm,
    required this.streifenHoeheMm,
    required this.etikettHoeheMm,
    required this.schriftPt,
    required this.notizPt,
  });

  final int spalten;
  final int reihen;
  final int randMm;
  final int streifenBreiteMm;
  final int streifenHoeheMm;
  final int etikettHoeheMm;
  final int schriftPt;
  final int notizPt;

  static KammerAbwesenheitsblatt _aus(_Knoten k) => KammerAbwesenheitsblatt(
        spalten: k.zahl('spalten'),
        reihen: k.zahl('reihen'),
        randMm: k.zahl('randMm'),
        streifenBreiteMm: k.zahl('streifenBreiteMm'),
        streifenHoeheMm: k.zahl('streifenHoeheMm'),
        etikettHoeheMm: k.zahl('etikettHoeheMm'),
        schriftPt: k.zahl('schriftPt'),
        notizPt: k.zahl('notizPt'),
      );
}

class KammerTisch {
  const KammerTisch(this.lageplan, this.markerfelder, this.marker, this.tippZettel, this.abwesenheitsblatt);
  final KammerLageplan lageplan;
  final KammerMarkerfelder markerfelder;
  final KammerMarkerVorgabe marker;
  final KammerTippZettel tippZettel;
  final KammerAbwesenheitsblatt abwesenheitsblatt;

  static KammerTisch _aus(_Knoten k) => KammerTisch(
        k.objekt('lageplan', KammerLageplan._aus),
        k.objekt('markerfelder', KammerMarkerfelder._aus),
        k.objekt('marker', KammerMarkerVorgabe._aus),
        k.objekt('tippZettel', KammerTippZettel._aus),
        k.objekt('abwesenheitsblatt', KammerAbwesenheitsblatt._aus),
      );
}

// ---------------------------------------------------------------- abwesenheit.json

/// Zeugenstreifen eines fehlenden Zeugen 5–10 (MECH 5.3).
class KammerStreifen {
  const KammerStreifen({
    required this.zeuge,
    required this.feld,
    required this.oeffnen,
    required this.etikett,
    required this.protokoll,
    required this.mitNotiz,
    required this.vermerk,
  });

  final String zeuge;

  /// Markerfeld, neben dem der Streifen liegt.
  final String feld;

  /// Codes der Ortstermine, die den Streifen umdrehen (dazu der „Zeitstempel“).
  final List<String> oeffnen;
  final String etikett;
  final String protokoll;

  /// Joannas Notiz (Rolle `notiz`) zweispaltig unter das Protokoll setzen.
  final bool mitNotiz;
  final String vermerk;

  static KammerStreifen _aus(_Knoten k) => KammerStreifen(
        zeuge: k.kennung('zeuge'),
        feld: k.kennung('feld'),
        oeffnen: k.kennungen('oeffnen'),
        etikett: k.text('etikett'),
        protokoll: k.text('protokoll'),
        mitNotiz: k.wahr('mitNotiz'),
        vermerk: k.text('vermerk'),
      );
}

// ---------------------------------------------------------------- indizkarten.json

class KammerIndizkarte {
  const KammerIndizkarte({
    required this.code,
    required this.abRunde,
    required this.art,
    required this.titel,
    required this.felder,
    required this.wasDuFindest,
    required this.ortstermin,
    required this.vermerke,
    required this.zeugen,
    required this.meilensteine,
  });

  final String code;
  final int abRunde;
  final KammerKartenArt art;
  final String titel;

  /// Felder des Lageplans, die die Karte zeigt (leer bei Personen-Karten).
  final List<String> felder;
  final String wasDuFindest;

  /// Frage des Ortstermins; null bei Spurkarten.
  final String? ortstermin;

  /// Vermerke; bei Ortsterminen leer (dort gilt `ortsterminVermerk`).
  final List<String> vermerke;

  /// Zeugen 5–10, deren Streifen der Ortstermin umdreht.
  final List<String> zeugen;

  /// Meilensteine, zu denen die Karte beiträgt (MECH 3.2).
  final List<String> meilensteine;

  static KammerIndizkarte _aus(_Knoten k) {
    final art = k._wert('art', KammerKartenArt.values);
    final ort = k.textOderNull('ortstermin');
    k.pruefe((ort != null) == (art == KammerKartenArt.ortstermin), 'ortstermin');
    return KammerIndizkarte(
      code: k.kennung('code'),
      abRunde: k.zahl('abRunde'),
      art: art,
      titel: k.text('titel'),
      felder: k.kennungen('felder'),
      wasDuFindest: k.text('wasDuFindest'),
      ortstermin: ort,
      vermerke: k.texte('vermerke'),
      zeugen: k.kennungen('zeugen'),
      meilensteine: k.kennungen('meilensteine'),
    );
  }
}

class KammerIndizkarten {
  const KammerIndizkarten(this.ortsterminSchlussEinzahl, this.ortsterminSchlussMehrzahl, this.ortsterminVermerk, this.karten);
  final String ortsterminSchlussEinzahl;
  final String ortsterminSchlussMehrzahl;
  final String ortsterminVermerk;

  /// Die 19 Karten, nach Code sortiert.
  final List<KammerIndizkarte> karten;

  static KammerIndizkarten _aus(_Knoten k) {
    final (e, m) = k.objekt('ortsterminSchluss', (s) => (s.text('einzahl'), s.text('mehrzahl')));
    return KammerIndizkarten(e, m, k.text('ortsterminVermerk'), k.liste('karten', KammerIndizkarte._aus));
  }
}

// ---------------------------------------------------------------- aufloesung.json (Teil 90)

class KammerMeilensteinText {
  const KammerMeilensteinText(this.nr, this.feld, this.kernfakt, this.stichwort);
  final String nr;
  final String feld;
  final String kernfakt;
  final String stichwort;

  static KammerMeilensteinText _aus(_Knoten k) =>
      KammerMeilensteinText(k.kennung('nr'), k.text('feld'), k.text('kernfakt'), k.text('stichwort'));
}

class KammerEndeText {
  const KammerEndeText(this.nr, this.name, this.text);
  final int nr;
  final String name;

  /// Text mit dem Wert-Platzhalter `{bund}` an der Stelle des Bund-Satzes.
  final String text;

  static KammerEndeText _aus(_Knoten k) =>
      KammerEndeText(k.zahl('nr'), k.text('name'), k.text('text', werte: const {'bund'}));
}

/// Die vier Fassungen des Bund-Satzes (MECH 8.2 M-24).
class KammerBundSaetze {
  const KammerBundSaetze(this.taeterOhnePp9, this.taeterMitPp9, this.andereOhnePp9, this.andereMitPp9);
  final String taeterOhnePp9;
  final String taeterMitPp9;
  final String andereOhnePp9;
  final String andereMitPp9;

  static KammerBundSaetze _aus(_Knoten k) => KammerBundSaetze(
        k.text('taeterOhnePp9'),
        k.text('taeterMitPp9'),
        k.text('andereOhnePp9'),
        k.text('andereMitPp9'),
      );
}

class KammerZeitzeile {
  const KammerZeitzeile(this.zeit, this.text);
  final String zeit;
  final String text;

  static KammerZeitzeile _aus(_Knoten k) => KammerZeitzeile(k.text('zeit'), k.text('text'));
}

class KammerTippWertungFrage {
  const KammerTippWertungFrage(this.nr, this.punkte, this.loesung);
  final int nr;
  final int punkte;
  final String loesung;

  static KammerTippWertungFrage _aus(_Knoten k) =>
      KammerTippWertungFrage(k.zahl('nr'), k.zahl('punkte'), k.text('loesung'));
}

class KammerAufloesung {
  const KammerAufloesung({
    required this.wasWirklichWar,
    required this.meilensteine,
    required this.meilensteinRegel,
    required this.pruefung,
    required this.enden,
    required this.bundSaetze,
    required this.rueckblende,
    required this.zeitleiste,
    required this.tippFragen,
    required this.sonderregel,
    required this.spuernase,
    required this.erzaehlerBonus,
  });

  final String wasWirklichWar;
  final List<KammerMeilensteinText> meilensteine;
  final String meilensteinRegel;
  final String pruefung;
  final List<KammerEndeText> enden;
  final KammerBundSaetze bundSaetze;

  /// Rückblende, ein Eintrag je Abschnitt 1–8 (MECH 8.3).
  final List<String> rueckblende;
  final List<KammerZeitzeile> zeitleiste;
  final List<KammerTippWertungFrage> tippFragen;
  final String sonderregel;
  final String spuernase;
  final String erzaehlerBonus;

  static KammerAufloesung _aus(_Knoten k) {
    final (fragen, sonder, nase) = k.objekt(
      'tippWertung',
      (t) => (t.liste('fragen', KammerTippWertungFrage._aus), t.text('sonderregel'), t.text('spuernase')),
    );
    return KammerAufloesung(
      wasWirklichWar: k.text('wasWirklichWar'),
      meilensteine: k.liste('meilensteine', KammerMeilensteinText._aus),
      meilensteinRegel: k.text('meilensteinRegel'),
      pruefung: k.text('pruefung'),
      enden: k.liste('enden', KammerEndeText._aus),
      bundSaetze: k.objekt('bundSaetze', KammerBundSaetze._aus),
      rueckblende: k.texte('rueckblende'),
      zeitleiste: k.liste('zeitleiste', KammerZeitzeile._aus),
      tippFragen: fragen,
      sonderregel: sonder,
      spuernase: nase,
      erzaehlerBonus: k.text('erzaehlerBonus'),
    );
  }
}

// ---------------------------------------------------------------- rollen/NN-<id>.json

class KammerMarkerAngabe {
  const KammerMarkerAngabe(this.zeile, this.behauptet2357, this.behauptetScheppern, this.wahr2357, this.wahrScheppern);

  /// Markerzeile im Heft (wörtlich).
  final String zeile;

  /// Felder, auf die die Rolle ihre Marker zu Beginn setzt (Stufe 1, WELT 4.2).
  final String behauptet2357;
  final String behauptetScheppern;

  /// Wahre Felder (WELT 4.1).
  final String wahr2357;
  final String wahrScheppern;

  static KammerMarkerAngabe _aus(_Knoten k) {
    final (b1, b2) = k.objekt('behauptet', (b) => (b.kennung('z2357'), b.kennung('scheppern')));
    final (w1, w2) = k.objekt('wahr', (w) => (w.kennung('z2357'), w.kennung('scheppern')));
    return KammerMarkerAngabe(k.text('zeile'), b1, b2, w1, w2);
  }
}

class KammerWissenZeile {
  const KammerWissenZeile(this.zeit, this.text, this.frei, this.zusatz);
  final String zeit;
  final String text;
  final KammerFrei frei;

  /// Eigener Zusatz statt des Standardzusatzes zu [frei]; sonst null.
  final String? zusatz;

  static KammerWissenZeile _aus(_Knoten k) => KammerWissenZeile(
        k.text('zeit'),
        k.text('text'),
        k._wert('frei', KammerFrei.values),
        k.textOderNull('zusatz'),
      );
}

/// „Was du weißt“ (ZG x.4, ZR x.5): die Tabelle „Sicher“ ohne die Spalte Quelle
/// (ZG 0.6). „Vermutet“ und „Weiß nicht“ der Bibel sind Arbeitshilfe und werden
/// nicht gedruckt.
class KammerWissen {
  const KammerWissen(this.zeilen);
  final List<KammerWissenZeile> zeilen;

  static KammerWissen _aus(_Knoten k) => KammerWissen(k.liste('zeilen', KammerWissenZeile._aus));
}

/// Joannas Notiz von 23:57 (ZG 4.5): Kasten im Heft und unter ihrem Streifen.
class KammerNotiz {
  const KammerNotiz(this.zeilen, this.hinweis);
  final List<String> zeilen;
  final String hinweis;

  static KammerNotiz _aus(_Knoten k) => KammerNotiz(k.texte('zeilen'), k.text('hinweis'));
}

class KammerStufe1 {
  const KammerStufe1({
    required this.kernsaetze,
    required this.regie,
    required this.sagstDuJedem,
    required this.ausweichsaetze,
    required this.verboten,
    required this.markersatz,
  });

  /// Verdächtige: zwei Kernsätze (Rede); sonst leer.
  final List<String> kernsaetze;
  final String? regie;

  /// Zeugen und Zusatzrollen: „Das sagst du jedem“ (Rede); bei Verdächtigen leer.
  final List<String> sagstDuJedem;

  /// Verdächtige: „Wenn jemand fragt / sagst du“; sonst „Das behältst du für dich“.
  final List<KammerFrageAntwort> ausweichsaetze;
  final List<String> verboten;
  final String? markersatz;

  static KammerStufe1 _aus(_Knoten k) => KammerStufe1(
        kernsaetze: k.texte('kernsaetze'),
        regie: k.textOderNull('regie'),
        sagstDuJedem: k.texte('sagstDuJedem'),
        ausweichsaetze: k.liste('ausweichsaetze', KammerFrageAntwort._aus),
        verboten: k.texte('verboten'),
        markersatz: k.textOderNull('markersatz'),
      );
}

class KammerImpulsAntwort {
  const KammerImpulsAntwort(this.impuls, this.antwort);
  final String impuls;
  final String antwort;

  static KammerImpulsAntwort _aus(_Knoten k) => KammerImpulsAntwort(k.kennung('impuls'), k.text('antwort'));
}

class KammerStufe2 {
  const KammerStufe2({
    required this.wasDuVerbirgst,
    required this.ausloeser,
    required this.wasDuDannSagst,
    required this.marker,
    required this.abDann,
    required this.nachDemUmdrehenEinleitung,
    required this.nachDemUmdrehen,
  });

  final String? wasDuVerbirgst;

  /// Sobald-Sätze ohne Nummer; der Generator nummeriert (Verdächtige (a)–(c),
  /// sonst 1., 2. …). Einträge, die leer aufgelöst werden, fallen weg.
  final List<String> ausloeser;
  final String? wasDuDannSagst;
  final String? marker;
  final String? abDann;
  final String? nachDemUmdrehenEinleitung;
  final List<String> nachDemUmdrehen;

  static KammerStufe2 _aus(_Knoten k) {
    final (einleitung, saetze) =
        k.objekt('nachDemUmdrehen', (n) => (n.textOderNull('einleitung'), n.texte('saetze')));
    return KammerStufe2(
      wasDuVerbirgst: k.textOderNull('wasDuVerbirgst'),
      ausloeser: k.texte('ausloeser'),
      wasDuDannSagst: k.textOderNull('wasDuDannSagst'),
      marker: k.textOderNull('marker'),
      abDann: k.textOderNull('abDann'),
      nachDemUmdrehenEinleitung: einleitung,
      nachDemUmdrehen: saetze,
    );
  }
}

/// „Was du über andere sagen darfst“ (RK 8.1), nur Verdächtige.
class KammerFreigabe {
  const KammerFreigabe(this.sofort, this.nachDemMarker, this.nachDerKarte);
  final List<String> sofort;
  final List<String> nachDemMarker;
  final List<String> nachDerKarte;

  static KammerFreigabe _aus(_Knoten k) =>
      KammerFreigabe(k.texte('sofort'), k.texte('nachDemMarker'), k.texte('nachDerKarte'));
}

/// Ein Nachbohr-Ziel (RK 1.2, ZG x.7/x.8, ZR x.8).
class KammerAuftrag {
  const KammerAuftrag(this.runde, this.nr, this.ziel, this.frage, this.nachschlag, this.ausweich);
  final int runde;
  final int nr;

  /// Rollen-ID der Zielrolle.
  final String ziel;
  final String frage;
  final String? nachschlag;

  /// Wird statt [frage] und [nachschlag] gedruckt, wenn [ziel] heute fehlt.
  final String? ausweich;

  static KammerAuftrag _aus(_Knoten k) => KammerAuftrag(
        k.zahl('runde'),
        k.zahl('nr'),
        k.kennung('ziel'),
        k.text('frage'),
        k.textOderNull('nachschlag'),
        k.textOderNull('ausweich'),
      );
}

class KammerTraegst {
  const KammerTraegst(this.text, this.hinweis, this.indizkarte);
  final String text;
  final String? hinweis;

  /// Indizkarte, die bei der Taschenkontrolle offen kommt (FN3, JT3, NN3), sonst null.
  final String? indizkarte;

  static KammerTraegst _aus(_Knoten k) =>
      KammerTraegst(k.text('text'), k.textOderNull('hinweis'), k.kennungOderNull('indizkarte'));
}

class KammerAktionskarte {
  const KammerAktionskarte(this.name, this.abRunde, this.klasse, this.wirkung, this.grenzen, this.tipp);
  final String name;
  final int abRunde;
  final KammerKlasse klasse;
  final String wirkung;
  final String grenzen;

  /// Tipp im Heft (nicht auf der Karte).
  final String tipp;

  static KammerAktionskarte _aus(_Knoten k) => KammerAktionskarte(
        k.text('name'),
        k.zahl('abRunde'),
        k._wert('klasse', KammerKlasse.values),
        k.text('wirkung'),
        k.text('grenzen'),
        k.text('tipp'),
      );
}

class KammerBonusZiel {
  const KammerBonusZiel(this.text, this.hinweis);
  final String text;
  final String? hinweis;

  static KammerBonusZiel _aus(_Knoten k) => KammerBonusZiel(k.text('text'), k.textOderNull('hinweis'));
}

class KammerGeheimniskarte {
  const KammerGeheimniskarte(this.sperre, this.pflichtCodes, this.wasIchZugebe, this.vermerke, this.undNochEtwas);

  /// Rundensperre: frühestens in dieser Runde (1 = keine Sperre).
  final int sperre;

  /// Indizkarten, deren Offenliegen die Karte zum Umdrehen zwingt; bei fehlenden
  /// Zeugen 5–10 die Codes der Tabelle „Karten unter den Streifen“ (MECH 9.14).
  final List<String> pflichtCodes;
  final String wasIchZugebe;
  final List<String> vermerke;
  final String undNochEtwas;

  static KammerGeheimniskarte _aus(_Knoten k) => KammerGeheimniskarte(
        k.zahl('sperre'),
        k.kennungen('pflichtCodes'),
        k.text('wasIchZugebe'),
        k.texte('vermerke'),
        k.text('undNochEtwas'),
      );
}

/// Versiegelte Fassung einer Verdächtigen (Teil 11, RK 7).
class KammerFassung {
  const KammerFassung({
    required this.code,
    required this.ziel,
    required this.zeitleiste,
    required this.wasNurDuWeisst,
    required this.heftUndWahrheit,
    required this.wennEsEngWird,
    required this.stufe3,
  });

  final String code;
  final String ziel;
  final List<KammerZeitzeile> zeitleiste;
  final List<String> wasNurDuWeisst;
  final String heftUndWahrheit;
  final List<String> wennEsEngWird;
  final String stufe3;

  static KammerFassung _aus(_Knoten k) => KammerFassung(
        code: k.kennung('code'),
        ziel: k.text('ziel'),
        zeitleiste: k.liste('zeitleiste', KammerZeitzeile._aus),
        wasNurDuWeisst: k.texte('wasNurDuWeisst'),
        heftUndWahrheit: k.text('heftUndWahrheit'),
        wennEsEngWird: k.texte('wennEsEngWird'),
        stufe3: k.text('stufe3'),
      );
}

/// Eine Rolle mit allem, was gedruckt wird (Teile 00, 10/12, 11, 20, 90).
class KammerRolle {
  const KammerRolle({
    required this.platz,
    required this.id,
    required this.frage,
    required this.auftritt,
    required this.werDuBist,
    required this.haltung,
    required this.tandemKasten,
    required this.marker,
    required this.wasDuWeisst,
    required this.notiz,
    required this.stufe1,
    required this.wennDerErzaehlerFragt,
    required this.stufe2,
    required this.freigabe,
    required this.gespraechsauftraege,
    required this.wasDuBeiDirTraegst,
    required this.aktionskarte,
    required this.bonusZiel,
    required this.geheimniskarte,
    required this.solo,
    required this.teil90,
    required this.fassung,
  });

  final int platz;
  final String id;

  /// Frage des Erzählers in der Vorstellungsrunde (Teil 00).
  final String frage;

  /// „Dein Auftritt bei der Vorstellung“ (Heft).
  final String auftritt;
  final String werDuBist;
  final String? haltung;
  final String? tandemKasten;
  final KammerMarkerAngabe marker;
  final KammerWissen? wasDuWeisst;
  final KammerNotiz? notiz;
  final KammerStufe1 stufe1;
  final List<KammerImpulsAntwort> wennDerErzaehlerFragt;
  final KammerStufe2 stufe2;
  final KammerFreigabe? freigabe;
  final List<KammerAuftrag> gespraechsauftraege;
  final KammerTraegst wasDuBeiDirTraegst;
  final KammerAktionskarte aktionskarte;
  final KammerBonusZiel bonusZiel;
  final KammerGeheimniskarte geheimniskarte;

  /// Solo-Abschnitt (nur der kleinere Platz eines Tandems).
  final String? solo;

  /// Absatz „Die Rollen am Tisch“ in Teil 90.
  final String teil90;
  final KammerFassung? fassung;

  static KammerRolle _aus(_Knoten k) {
    final (frage, auftritt) = k.objekt('vorstellung', (v) => (v.text('frage'), v.text('auftritt')));
    return KammerRolle(
      platz: k.zahl('platz'),
      id: k.kennung('id'),
      frage: frage,
      auftritt: auftritt,
      werDuBist: k.text('werDuBist'),
      haltung: k.textOderNull('haltung'),
      tandemKasten: k.textOderNull('tandemKasten'),
      marker: k.objekt('marker', KammerMarkerAngabe._aus),
      wasDuWeisst: k.objektOderNull('wasDuWeisst', KammerWissen._aus),
      notiz: k.objektOderNull('notiz', KammerNotiz._aus),
      stufe1: k.objekt('stufe1', KammerStufe1._aus),
      wennDerErzaehlerFragt: k.liste('wennDerErzaehlerFragt', KammerImpulsAntwort._aus),
      stufe2: k.objekt('stufe2', KammerStufe2._aus),
      freigabe: k.objektOderNull('freigabe', KammerFreigabe._aus),
      gespraechsauftraege: k.liste('gespraechsauftraege', KammerAuftrag._aus),
      wasDuBeiDirTraegst: k.objekt('wasDuBeiDirTraegst', KammerTraegst._aus),
      aktionskarte: k.objekt('aktionskarte', KammerAktionskarte._aus),
      bonusZiel: k.objekt('bonusZiel', KammerBonusZiel._aus),
      geheimniskarte: k.objekt('geheimniskarte', KammerGeheimniskarte._aus),
      solo: k.textOderNull('solo'),
      teil90: k.text('teil90'),
      fassung: k.objektOderNull('fassung', KammerFassung._aus),
    );
  }
}

// ---------------------------------------------------------------- Gesamtinhalt

/// Der ganze Kammerspiel-Inhalt.
class KammerInhalt {
  KammerInhalt._({
    required this.fall,
    required this.gemeinsam,
    required this.ui,
    required this.erzaehlerheft,
    required this.detektiv,
    required this.tisch,
    required this.streifen,
    required this.indizkarten,
    required this.aufloesung,
    required this.rollen,
    required this.offeneFelder,
  });

  final KammerFall fall;
  final KammerGemeinsam gemeinsam;

  /// Beschriftungen je Teil: `gemeinsam`, `00` … `90` → Schlüssel → Text.
  final Map<String, Map<String, String>> ui;
  final KammerErzaehlerheft erzaehlerheft;
  final KammerDetektiv detektiv;
  final KammerTisch tisch;

  /// Die sechs Zeugenstreifen in Platzreihenfolge (abwesenheit.json).
  final List<KammerStreifen> streifen;
  final KammerIndizkarten indizkarten;
  final KammerAufloesung aufloesung;

  /// Die 18 Rollen in Platzreihenfolge.
  final List<KammerRolle> rollen;

  /// „datei: pfad“ jedes Texts, der noch mit `OFFEN:` beginnt.
  final List<String> offeneFelder;

  KammerPlatz platz(int nr) => fall.plaetze[nr - 1];

  KammerPlatz platzVon(String id) =>
      fall.plaetze.firstWhere((p) => p.id == id, orElse: () => throw ArgumentError.value(id, 'id'));

  KammerRolle rolle(String id) => rollen[platzVon(id).platz - 1];

  KammerIndizkarte karte(String code) => indizkarten.karten
      .firstWhere((k) => k.code == code, orElse: () => throw ArgumentError.value(code, 'code'));

  KammerStreifen streifenVon(String zeuge) =>
      streifen.firstWhere((s) => s.zeuge == zeuge, orElse: () => throw ArgumentError.value(zeuge, 'zeuge'));

  /// Beschriftung `ui/<teil>.json` → [schluessel], roh (Platzhalter noch drin).
  String uiText(String teil, String schluessel) {
    final t = ui[teil]?[schluessel];
    if (t == null) throw ArgumentError('ui/$teil.json: Schlüssel „$schluessel“ fehlt');
    return t;
  }

  /// Lädt den Inhalt aus [dateien]: Schlüssel ordner-relativ (`fall.json`,
  /// `rollen/03-olli.json`) oder repo-relativ (mit [kammerInhaltOrdner] davor),
  /// Wert das JSON-Objekt oder sein Text. Wirft [FormatException] mit Datei und
  /// Pfad, wenn eine Datei oder ein Feld fehlt, unbekannt oder falsch ist.
  factory KammerInhalt.ausJson(Map<String, Object?> dateien) {
    final json = <String, Map<String, Object?>>{};
    for (final e in dateien.entries) {
      final name = e.key.startsWith('$kammerInhaltOrdner/') ? e.key.substring(kammerInhaltOrdner.length + 1) : e.key;
      if (!kammerInhaltDateien.contains(name)) throw FormatException('$name: unbekannte Inhaltsdatei');
      var v = e.value;
      if (v is String) {
        try {
          v = jsonDecode(v);
        } on FormatException catch (f) {
          throw FormatException('$name: kein gültiges JSON (${f.message})');
        }
      }
      if (v is! Map<String, Object?>) throw FormatException('$name: JSON-Objekt erwartet');
      json[name] = v;
    }
    for (final d in kammerInhaltDateien) {
      if (!json.containsKey(d)) throw FormatException('$d: Datei fehlt');
    }
    final l = _Lader();
    final fall = _datei(l, json['fall.json']!, 'fall.json', KammerFall._aus);
    _pruefeFall(fall);
    l.rollen = {for (final p in fall.plaetze) p.id};
    final ui = {
      for (final teil in ['gemeinsam', ...kammerTeile]) teil: _ui(l, json['ui/$teil.json']!, 'ui/$teil.json'),
    };
    final inhalt = KammerInhalt._(
      fall: fall,
      gemeinsam: _datei(l, json['gemeinsam.json']!, 'gemeinsam.json', KammerGemeinsam._aus),
      ui: ui,
      erzaehlerheft: _datei(l, json['erzaehlerheft.json']!, 'erzaehlerheft.json', KammerErzaehlerheft._aus),
      detektiv: _datei(l, json['detektiv.json']!, 'detektiv.json', KammerDetektiv._aus),
      tisch: _datei(l, json['tisch.json']!, 'tisch.json', KammerTisch._aus),
      streifen: _datei(l, json['abwesenheit.json']!, 'abwesenheit.json', (k) => k.liste('streifen', KammerStreifen._aus)),
      indizkarten: _datei(l, json['indizkarten.json']!, 'indizkarten.json', KammerIndizkarten._aus),
      aufloesung: _datei(l, json['aufloesung.json']!, 'aufloesung.json', KammerAufloesung._aus),
      rollen: [for (final p in fall.plaetze) _datei(l, json[p.datei]!, p.datei, KammerRolle._aus)],
      offeneFelder: List.unmodifiable(l.offen),
    );
    _pruefeVerweise(inhalt);
    return inhalt;
  }
}

Map<String, String> _ui(_Lader l, Map<String, Object?> json, String datei) {
  final aus = <String, String>{};
  for (final e in json.entries) {
    if (!RegExp(r'^[a-zA-Z0-9]+(\.[a-zA-Z0-9]+)*$').hasMatch(e.key)) throw FormatException('$datei: ${e.key}: ungültiger Schlüssel');
    aus[e.key] = l.text(e.value, datei, e.key, null);
  }
  final pflicht = datei == 'ui/gemeinsam.json' ? const ['datei.alles'] : const ['datei', 'titel'];
  for (final p in pflicht) {
    if (!aus.containsKey(p)) throw FormatException('$datei: $p: Feld fehlt');
  }
  return Map.unmodifiable(aus);
}

void _pruefeFall(KammerFall f) {
  const d = 'fall.json';
  if (f.plaetze.length != kammerRollenDateien.length) throw FormatException('$d: plaetze: ${kammerRollenDateien.length} Plätze erwartet');
  final ids = <String>{};
  for (var i = 0; i < f.plaetze.length; i++) {
    final p = f.plaetze[i];
    final pfad = '$d: plaetze[$i]';
    if (p.platz != i + 1) throw FormatException('$pfad.platz: ${i + 1} erwartet');
    if (!ids.add(p.id)) throw FormatException('$pfad.id: doppelt');
    if (p.datei != kammerRollenDateien[i]) throw FormatException('$pfad.datei: ${kammerRollenDateien[i]} erwartet');
    if (!p.datei.endsWith('-${p.id}.json')) throw FormatException('$pfad.datei: passt nicht zur id');
    final art = p.platz <= 4 ? KammerArt.verdaechtig : (p.platz <= 10 ? KammerArt.zeuge : KammerArt.zusatz);
    if (p.art != art) throw FormatException('$pfad.art: ${art.name} erwartet');
    if ((p.tandem != null) != (art == KammerArt.zusatz)) throw FormatException('$pfad.tandem: nur Zusatzrollen haben ein Tandem');
  }
  for (final t in f.tandems) {
    if (t.plaetze.length != 2 || t.plaetze[0] >= t.plaetze[1]) throw FormatException('$d: tandems ${t.nr}: zwei Plätze, der kleinere zuerst');
    for (final p in t.plaetze) {
      if (p < 1 || p > f.plaetze.length || f.plaetze[p - 1].tandem != t.nr) throw FormatException('$d: tandems ${t.nr}: Platz $p gehört nicht dazu');
    }
  }
  if (!ids.contains(f.taeter)) throw FormatException('$d: taeter: unbekannte Rolle');
  if (f.personenMin - f.ohneRolle.length < 4 || f.personenMax - f.ohneRolle.length != f.plaetze.length) throw FormatException('$d: personen: passt nicht zu den Plätzen');
  final felder = {for (final x in f.felder) x.id};
  final zonen = {for (final z in f.zonen) z.nr};
  for (final x in f.felder) {
    if (!zonen.contains(x.zone)) throw FormatException('$d: felder ${x.id}: unbekannte Zone');
  }
  for (final z in f.zonen) {
    for (final x in z.felder) {
      if (!felder.contains(x)) throw FormatException('$d: zonen ${z.nr}: unbekanntes Feld $x');
    }
  }
  final codes = [...f.fassungsCodes, ...f.indizCodes];
  final paare = <String>{};
  for (final c in codes) {
    if (!RegExp(r'^[A-Z]{2}[3479]$').hasMatch(c)) throw FormatException('$d: codes: ungültiger Code $c');
    if (!paare.add(c.substring(0, 2))) throw FormatException('$d: codes: Buchstabenpaar von $c doppelt');
  }
  for (final m in f.meilensteine) {
    if (m.spalte != null && !ids.contains(m.spalte)) throw FormatException('$d: meilensteine ${m.nr}: unbekannte Spalte');
  }
}

/// Querverweise zwischen den Dateien (Rollen, Felder, Codes, Impulse). Der
/// Fehler nennt Datei und Pfad als `datei#pfad`.
void _pruefeVerweise(KammerInhalt i) {
  final f = i.fall;
  final felder = {for (final x in f.felder) x.id};
  final codes = f.indizCodes.toSet();
  final ids = {for (final p in f.plaetze) p.id};
  final zeugen = [for (final p in f.plaetze) if (p.art == KammerArt.zeuge) p.id];
  final verdaechtige = {for (final p in f.plaetze) if (p.art == KammerArt.verdaechtig) p.id};
  final impulse = {for (final x in i.erzaehlerheft.impulse) x.id};
  final meilensteine = {for (final m in f.meilensteine) m.nr};
  final runden = [for (final r in f.runden) r.nr];
  bool runde(int r) => r >= 1 && r <= runden.length;

  void ja(bool ok, String wo) {
    if (!ok) throw FormatException('$wo: Verweis passt nicht');
  }

  // Indizkarten: Codes wie fall.json codes.indizkarten (sortiert); Ortstermine
  // ohne eigene Vermerke, mit Zeugen; Spurkarten ohne Zeugen.
  ja(_gleich([for (final k in i.indizkarten.karten) k.code], f.indizCodes), 'indizkarten.json#karten');
  for (final k in i.indizkarten.karten) {
    final wo = 'indizkarten.json#karten.${k.code}';
    ja(runde(k.abRunde), '$wo.abRunde');
    ja(k.felder.every(felder.contains), '$wo.felder');
    ja(k.zeugen.every(zeugen.contains), '$wo.zeugen');
    ja(k.meilensteine.every(meilensteine.contains), '$wo.meilensteine');
    ja(k.art == KammerKartenArt.ortstermin ? k.vermerke.isEmpty && k.zeugen.isNotEmpty : k.zeugen.isEmpty, '$wo.art');
  }
  // Streifen: Zeugen 5–10 in Platzreihenfolge.
  ja(_gleich([for (final s in i.streifen) s.zeuge], zeugen), 'abwesenheit.json#streifen');
  for (final s in i.streifen) {
    ja(felder.contains(s.feld) && s.oeffnen.every(codes.contains), 'abwesenheit.json#streifen.${s.zeuge}');
    ja(!s.mitNotiz || i.rolle(s.zeuge).notiz != null, 'abwesenheit.json#streifen.${s.zeuge}.mitNotiz');
  }
  // Erzählerheft und Detektiv.
  ja(_gleich([for (final r in i.erzaehlerheft.runden) r.nr], runden), 'erzaehlerheft.json#runden');
  ja(impulse.length == i.erzaehlerheft.impulse.length, 'erzaehlerheft.json#runden.impulse');
  ja(i.erzaehlerheft.vorstellung.lacherFehlend.every((l) => ids.contains(l.schluessel)), 'erzaehlerheft.json#vorstellung.lacherFehlend');
  ja(_gleich([for (final u in i.erzaehlerheft.umschreibungen) u.schluessel], zeugen), 'erzaehlerheft.json#kartenUnterStreifen.umschreibungen');
  ja(i.detektiv.aktionskartenTipps.every((t) => zeugen.contains(t.schluessel)), 'detektiv.json#aktionskartenTipps');
  ja(_gleich(i.detektiv.bogen.spalten.toSet().toList(), i.detektiv.bogen.spalten) && i.detektiv.bogen.spalten.toSet().containsAll(verdaechtige) && verdaechtige.containsAll(i.detektiv.bogen.spalten), 'detektiv.json#bogen.spalten');
  ja(_gleich([for (final a in i.detektiv.aufgabenJeRunde) a.runde], runden), 'detektiv.json#aufgabenJeRunde');
  bool bereich(KammerSkalierungsHinweis h) => f.personenMin <= h.von && h.von <= h.bis && h.bis <= f.personenMax;
  ja(i.erzaehlerheft.skalierungsHinweise.every(bereich), 'erzaehlerheft.json#skalierung.hinweise');
  ja(i.detektiv.wennRollenFehlen.every(bereich), 'detektiv.json#wennRollenFehlen');
  // Tisch: Felder wie fall.json, jedes Markerfeld einmal auf Blatt B.
  final plan = i.tisch.lageplan;
  ja(_gleich([for (final x in plan.felder) x.id], [for (final x in f.felder) x.id]), 'tisch.json#lageplan.felder');
  ja(plan.gegenstaende.every((g) => felder.contains(g.zusatz)), 'tisch.json#lageplan.gegenstaende');
  ja(plan.legende.every((l) => felder.contains(l.schluessel)), 'tisch.json#lageplan.legende');
  ja(_gleich([for (final b in i.tisch.markerfelder.belegung) b.feld]..sort(), [for (final x in f.felder) x.id]..sort()), 'tisch.json#markerfelder.belegung');
  for (final m in i.tisch.marker.feste) {
    ja(felder.contains(m.z2357) && felder.contains(m.scheppern), 'tisch.json#marker.feste.${m.wer}');
  }
  final tipp = [f.punkte.tippTaeter, f.punkte.tippVersteck, f.punkte.tippBonus];
  ja(_gleich([for (final q in i.tisch.tippZettel.fragen) q.punkte], tipp), 'tisch.json#tippZettel.fragen');
  // Auflösung: Meilensteine und Enden wie fall.json.
  ja(_gleich([for (final m in i.aufloesung.meilensteine) m.nr], [for (final m in f.meilensteine) m.nr]), 'aufloesung.json#meilensteine');
  ja(_gleich([for (final e in i.aufloesung.enden) e.nr], [for (final e in f.enden) e.nr]), 'aufloesung.json#enden');
  // Rollen: Felder je Art (Fassung und Freigabe nur Verdächtige; Wissen und
  // Haltung nicht bei Verdächtigen; Tandem-Kasten nur Zusatzrollen; Solo nur
  // beim kleineren Platz eines Tandems), je Runde zwei Aufträge.
  for (final p in f.plaetze) {
    final r = i.rollen[p.platz - 1];
    final wo = '${p.datei}#';
    final verd = p.art == KammerArt.verdaechtig;
    ja(r.platz == p.platz && r.id == p.id, '${wo}platz');
    for (final x in [r.marker.behauptet2357, r.marker.behauptetScheppern, r.marker.wahr2357, r.marker.wahrScheppern]) {
      ja(felder.contains(x), '${wo}marker');
    }
    ja((r.fassung != null) == verd, '${wo}fassung');
    ja((r.freigabe != null) == verd, '${wo}freigabe');
    ja((r.wasDuWeisst == null) == verd, '${wo}wasDuWeisst');
    ja((r.haltung == null) == verd, '${wo}haltung');
    ja((r.tandemKasten != null) == (p.art == KammerArt.zusatz), '${wo}tandemKasten');
    final tandem = p.tandem == null ? null : f.tandems.firstWhere((t) => t.nr == p.tandem);
    ja((r.solo != null) == (tandem != null && tandem.plaetze.first == p.platz), '${wo}solo');
    if (r.fassung != null) ja(f.fassungsCodes.contains(r.fassung!.code), '${wo}fassung.code');
    final g = r.geheimniskarte;
    ja(runde(g.sperre) && g.pflichtCodes.every(codes.contains), '${wo}geheimniskarte');
    ja(runde(r.aktionskarte.abRunde), '${wo}aktionskarte.abRunde');
    final ziele = <String>{};
    for (final z in r.gespraechsauftraege) {
      final ok = ids.contains(z.ziel) && z.ziel != r.id && runde(z.runde) && (z.nr == 1 || z.nr == 2);
      ja(ok && ziele.add('${z.runde}/${z.nr}'), '${wo}gespraechsauftraege.${z.runde}.${z.nr}');
    }
    ja(ziele.length == 2 * runden.length, '${wo}gespraechsauftraege');
    ja(r.wennDerErzaehlerFragt.every((e) => impulse.contains(e.impuls)), '${wo}wennDerErzaehlerFragt');
    final karte = r.wasDuBeiDirTraegst.indizkarte;
    ja(karte == null || codes.contains(karte), '${wo}wasDuBeiDirTraegst.indizkarte');
  }
  ja(_gleich([for (final r in i.rollen) if (r.fassung != null) r.fassung!.code], f.fassungsCodes), 'rollen#fassung.code');
}

bool _gleich<T>(List<T> a, List<T> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
