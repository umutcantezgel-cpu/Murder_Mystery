import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/runden.dart' show EinflussRegeln, EinflussZielQuelle;

import '../detektei/akten.dart';

/// Alles, was ein Partyabend aus dem Kanon braucht: Kanon, Textsammlung,
/// Karte und das Renderer-Szenario. Wird einmal geladen und nie verändert.
class PartyDaten {
  final String fall;
  final Kanon kanon;
  final Texte texte;
  final PartyKarte karte;
  final ScenarioDef szenario;

  /// Renderer-Kennung je Kanon-Person (Opfer und Rollen).
  final Map<String, String> npcKennung;

  /// Kanon-Person je Renderer-Kennung.
  final Map<String, String> kanonKennung;

  /// Gespräche mit Wahl und Nachspiel (`content/erzaehlung/<fall>/`); `null`
  /// bei Akten ohne Gespräche.
  final Erzaehlung? erzaehlung;

  /// Eintrag der Akte in `content/party/akten.json` (Zusätze je Akte); `null`,
  /// wenn er nicht gelesen wurde (Tests): dann gilt der Grundabend.
  final AkteInfo? akte;

  /// Gerüchte der Klassenfähigkeit (`content/welt/<fall>/geruechte.json`, in
  /// `welt.json` unter `geruechte` genannt); `null` bei Akten ohne Gerüchte.
  final Geruechte? geruechte;

  /// Diashow zur Einleitung (`content/welt/<fall>/diashow.json`, M4), nur bei
  /// Akten mit dem Zusatz `diashow`; `null`: Die Einleitung bleibt wie bisher.
  final Diashow? diashow;

  /// Vorspiel und Morgen des langen Abends (`content/welt/<fall>/vorspiel_morgen.json`,
  /// M7b), nur bei Akten mit dem Zusatz `langfassung`, wenn `welt.json` die
  /// Datei unter `vorspielMorgen` nennt; `null`: kein Rundgang (kurze Akten,
  /// Tests ohne Datei). Gespielt wird er nur im langen Abend.
  final VorspielMorgen? vorspielMorgen;

  /// Regeln von „Dein Moment“ (Finale §3, `content/party/zusatz/<fall>/einfluss.json`), nur bei Akten
  /// mit dem Zusatz `einfluss`; `null`: Die Akte kennt die Schicht nicht, jeder Abend bleibt wie bisher.
  final EinflussRegeln? einfluss;

  /// Erzählerakte (A-063, `erzaehlerakte.json`), nur bei Akten mit dem Zusatz
  /// `erzaehlerakte`; `null` sonst. Sichtbar nur dem Erzähler-Platz
  /// (`erzaehlerakte_ansicht.dart`), nie Teil des Spielzustands.
  final Erzaehlerakte? erzaehlerakte;

  /// Steckbriefe der Akte (`steckbriefe.json`), nur geladen, wenn die
  /// Einstimmung sie für die Vorstellungskarten braucht; sonst `null`.
  final Steckbriefe? steckbriefe;

  PartyDaten._(this.fall, this.kanon, this.texte, this.karte, this.szenario, this.npcKennung, this.erzaehlung, this.akte, this.geruechte, this.diashow,
      this.vorspielMorgen, this.einfluss, {this.erzaehlerakte, this.steckbriefe})
      : kanonKennung = {for (final e in npcKennung.entries) e.value: e.key};

  /// Einstimmung der Akte (Vorgeschichte und Vorstellung, A-063), nur mit dem
  /// Zusatz `einstimmung`; `null` sonst. Ob ein Abend sie spielt, legt die
  /// Einrichtung fest (`PartySitzung.einrichten(einstimmung:)`).
  late final Einstimmung? einstimmung = (akte?.mitEinstimmung ?? false) ? Einstimmung.aus(kanon) : null;

  /// Hat die Akte den Zusatz [faehigkeit] (`AkteInfo.hat`)?
  bool hat(String faehigkeit) => akte?.hat(faehigkeit) ?? false;

  /// Kennt die Akte einen Erzähler-Sitz (Langer Abend M3)? Wie beim Raum
  /// (`SchlosskellerRaum.vorleserSitz`) die Akten im Gesprächsmodell befragung,
  /// heute nur der Schlosskeller. Die übrigen Akten bieten keinen Erzähler an und
  /// zeigen ihre Texte wie bisher (Besitzerentscheidung 1).
  bool get mitErzaehlerSitz => texte.besetzung.befragungsmodell;

  /// Aus einem synchronen Leser (Tests) und der Szenario-Vorlage. Für Akten
  /// außer dem Schlosskeller ergänzt [basis] fehlende Oberflächentexte aus
  /// der eingefrorenen Basis `content/party/basis-ui` (A-061).
  factory PartyDaten.aus(
    KanonLeser lies,
    Map<String, dynamic> vorlage, {
    String fall = 'schlosskeller',
    KanonLeser? basis,
    Map<String, Object?>? welt,
    Map<String, Object?>? erzaehlung,
    AkteInfo? akte,
    Map<String, Object?>? geruechte,
    Map<String, Object?>? diashow,
    Map<String, Object?>? vorspielMorgen,
    Map<String, Object?>? einfluss,
    Map<String, Object?>? erzaehlerakte,
    Map<String, Object?>? erzaehlerZiele,
    Map<String, Object?>? steckbriefe,
  }) {
    final kanon = Kanon.lade(lies);
    final sammlung = Textsammlung.lade(lies);
    if (basis != null) sammlung.ergaenzeUi(Textsammlung.lade(basis));
    final texte = Texte(kanon, sammlung);
    final karte = PartyKarte(kanon);
    final szenario = ScenarioDef.fromJson(partySzenarioJson(kanon, vorlage, id: 'party_$fall', welt: welt));
    final regeln = einfluss == null ? null : EinflussRegeln.ausJson(einfluss, karte.ermittlung);
    return PartyDaten._(
      fall,
      kanon,
      texte,
      karte,
      szenario,
      partyNpcKennungen(kanon, vorlage),
      erzaehlung == null ? null : Erzaehlung.ausJson(erzaehlung),
      akte,
      geruechte == null ? null : Geruechte.ausJson(geruechte),
      diashow == null ? null : Diashow.ausJson(diashow),
      vorspielMorgen == null ? null : VorspielMorgen.ausJson(vorspielMorgen),
      regeln,
      erzaehlerakte: _erzaehlerakte(erzaehlerakte, regeln ?? (erzaehlerZiele == null ? null : EinflussRegeln.ausJson(erzaehlerZiele, karte.ermittlung)), kanon, texte),
      steckbriefe: steckbriefe == null ? null : Steckbriefe.ausJson(steckbriefe),
    );
  }

  /// Die Erzählerakte aus Datei und Kanon. Mit [regeln] (`einfluss.json` der
  /// Akte; in Tests auch ohne die Schicht über `erzaehlerZiele`) zeigt sie die
  /// Sterne der Einfluss-Schicht, sonst die Ziele des Kanons.
  static Erzaehlerakte? _erzaehlerakte(Map<String, Object?>? json, EinflussRegeln? regeln, Kanon kanon, Texte texte) {
    if (json == null) return null;
    return Erzaehlerakte.ausJson(json, kanon, ziele: regeln == null ? null : EinflussZielQuelle(regeln, texte));
  }

  /// Lädt alle Dateien einer Akte aus den Assets (`content/party/<fall>/`).
  static Future<PartyDaten> laden(AssetBundle bundle, {String fall = 'schlosskeller'}) async {
    final eigen = await _ordner(bundle, 'content/party/$fall');
    // Andere Akten ergänzen ui-Texte aus der eingefrorenen Basis (A-061), nie aus dem Schlosskeller.
    final basis = fall == 'schlosskeller' ? null : await _ordner(bundle, 'content/party/basis-ui', nurTexte: true);
    final vorlagePfad = eigen.vorlage ?? 'content/scenarios/ravensmoor.json';
    final vorlage = jsonDecode(await bundle.loadString(vorlagePfad)) as Map<String, dynamic>;
    // Darstellungsschicht der Akte (Außenräume, Wetter); ohne Datei wie bisher.
    Map<String, Object?>? welt;
    try {
      welt = jsonDecode(await bundle.loadString('content/welt/$fall/welt.json')) as Map<String, Object?>;
    } catch (_) {
      welt = null;
    }
    // Gespräche mit Wahl (M6) nur für Akten aus dem Verzeichnis; alle anderen
    // spielen wie bisher.
    final verzeichnis = jsonDecode(await bundle.loadString('content/erzaehlung/index.json')) as Map<String, Object?>;
    final erzaehlung = (verzeichnis['akten'] as List).contains(fall)
        ? jsonDecode(await bundle.loadString('content/erzaehlung/$fall/gespraeche.json')) as Map<String, Object?>
        : null;
    // Zusätze der Akte (Klassen, Druck …) und die Gerüchte der Klassenfähigkeit; ohne Datei wie bisher.
    AkteInfo? akte;
    try {
      akte = (await AktenKatalog.laden(bundle)).where((a) => a.id == fall).firstOrNull;
    } catch (_) {
      akte = null;
    }
    // Gerüchte nur, wenn welt.json sie nennt (nie eine fehlende Datei anfragen).
    final geruechte = welt?['geruechte'] is String
        ? jsonDecode(await bundle.loadString('content/welt/$fall/${welt!['geruechte']}')) as Map<String, Object?>
        : null;
    // Die Diashow nur, wenn die Akte den Zusatz hat (akte_pruefen hält Datei und Zusatz zusammen).
    Map<String, Object?>? diashow;
    if (akte?.hat('diashow') ?? false) {
      try {
        diashow = jsonDecode(await bundle.loadString('content/welt/$fall/diashow.json')) as Map<String, Object?>;
      } catch (_) {
        diashow = null;
      }
    }
    // Vorspiel und Morgen (M7b) nur mit dem Zusatz langfassung und nur, wenn welt.json die Datei nennt.
    Map<String, Object?>? vorspielMorgen;
    if ((akte?.hat('langfassung') ?? false) && welt?['vorspielMorgen'] is String) {
      try {
        vorspielMorgen = jsonDecode(await bundle.loadString('content/welt/$fall/${welt!['vorspielMorgen']}')) as Map<String, Object?>;
      } catch (_) {
        vorspielMorgen = null;
      }
    }
    // „Dein Moment“ (Finale §3) nur mit dem Zusatz einfluss; die Datei liegt neben den Abstechern.
    // Ihre Sterne sind zugleich die Ziele der Erzählerakte.
    final einfluss = (akte?.hat('einfluss') ?? false)
        ? jsonDecode(await bundle.loadString('content/party/zusatz/$fall/einfluss.json')) as Map<String, Object?>
        : null;
    final erzaehlteil = await _erzaehlteil(bundle, fall, akte);
    return PartyDaten.aus(eigen.lies, vorlage,
        fall: fall,
        basis: basis?.lies,
        welt: welt,
        erzaehlung: erzaehlung,
        akte: akte,
        geruechte: geruechte,
        diashow: diashow,
        vorspielMorgen: vorspielMorgen,
        einfluss: einfluss,
        erzaehlerakte: erzaehlteil.akte,
        steckbriefe: erzaehlteil.steckbriefe);
  }

  /// Erzählteil der Akte (A-063): die Erzählerakte nur mit dem Zusatz
  /// `erzaehlerakte` (ihre Ziele mit dem Zusatz `einfluss` aus den Sternen der
  /// Regeln, die [laden] ohnehin liest), die Steckbriefe nur für die
  /// Vorstellungskarten der Einstimmung. Fehlt eine Datei, bleibt ihr Teil leer.
  static Future<({Map<String, Object?>? akte, Map<String, Object?>? steckbriefe})> _erzaehlteil(
      AssetBundle bundle, String fall, AkteInfo? akte) async {
    Future<Map<String, Object?>?> json(String pfad) async {
      try {
        return jsonDecode(await bundle.loadString(pfad)) as Map<String, Object?>;
      } catch (_) {
        return null;
      }
    }

    final mitAkte = akte?.mitErzaehlerakte ?? false;
    return (
      akte: mitAkte ? await json('content/party/$fall/erzaehlerakte.json') : null,
      steckbriefe: (akte?.mitEinstimmung ?? false) && (akte?.hat('steckbriefe') ?? false) ? await json('content/party/$fall/steckbriefe.json') : null,
    );
  }

  static Future<_Ordner> _ordner(AssetBundle bundle, String basis, {bool nurTexte = false}) async {
    Future<Map<String, Object?>> json(String pfad) async => jsonDecode(await bundle.loadString('$basis/$pfad')) as Map<String, Object?>;
    final dateien = <String, Map<String, Object?>>{};
    Future<void> lade(Iterable<String> pfade) async {
      final liste = pfade.where((p) => !dateien.containsKey(p)).toList();
      final inhalte = await Future.wait(liste.map(json));
      for (var i = 0; i < liste.length; i++) {
        dateien[liste[i]] = inhalte[i];
      }
    }

    await lade([if (!nurTexte) ...Kanon.grunddateien, 'texte/index.json']);
    final index = dateien['texte/index.json']!;
    await lade([
      if (!nurTexte) ...Kanon.simulationsdateien(dateien['fall.json']!),
      for (final d in index['dateien'] as List)
        if (!nurTexte || (d as Map)['datei'].toString().startsWith('ui')) 'texte/${(d as Map)['datei']}',
    ]);
    if (nurTexte) {
      // Nur die Oberflächendateien; der Index wird darauf gekürzt.
      dateien['texte/index.json'] = {
        ...index,
        'dateien': [for (final d in index['dateien'] as List) if ((d as Map)['datei'].toString().startsWith('ui')) d],
      };
    }
    final darstellung = (dateien['setting.json']?['darstellung'] as Map?) ?? const {};
    return _Ordner((p) => dateien[p] ?? (throw StateError('Datei fehlt: $basis/$p')), darstellung['vorlage'] as String?);
  }
}

class _Ordner {
  final KanonLeser lies;
  final String? vorlage;
  const _Ordner(this.lies, this.vorlage);
}
