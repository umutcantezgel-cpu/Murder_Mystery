/// Aufbauhilfe der Relais-Tests: lokale Attrappe, Gastgeber mit dem echten
/// Schlosskeller-Raum aus `content/party/schlosskeller` und Gäste. Je Test neu.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:mordakte_core/mordakte_core.dart'
    show Abendfassung, Einstimmung, Ermittlung, FallCode, Kanon, KanonLeser, Rng, Texte, Textsammlung;
import 'package:mordakte_core/runden.dart' show AbendRaum, EinflussRegeln, PartyRaumFehler, ProtokollRaum, SchlosskellerRaum, einflussKatalog;
import 'package:mordakte_netz/io.dart';
import 'package:mordakte_netz/mordakte_netz.dart';
import 'package:test/test.dart';

const salz = '00112233445566778899aabbccddeeff00112233445566778899aabbccddeeff';

/// Rollenzahl der Tests (Kanon: mindestens 4).
const rollen = 4;

Map<String, Object?> privat(Map<String, Object?> v) => (v['privat'] as Map).cast<String, Object?>();

Map<String, Object?> spieler(Map<String, Object?> v, String id) =>
    (v['spieler'] as List).cast<Map>().map((s) => s.cast<String, Object?>()).firstWhere((s) => s['id'] == id);

/// Text ohne äußere Anführungszeichen, so wie er im JSON-Klartext eines Pakets steht.
String roh(String t) {
  final j = jsonEncode(t);
  return j.substring(1, j.length - 1);
}

/// Alle Strings eines Baums aus Maps und Listen.
Set<String> texteIn(Object? v) {
  final out = <String>{};
  void sammle(Object? x) {
    if (x is String) {
      out.add(x);
    } else if (x is List) {
      x.forEach(sammle);
    } else if (x is Map) {
      x.values.forEach(sammle);
    }
  }

  sammle(v);
  return out;
}

Map<String, Object?> ohneVersion(Map<String, Object?> v) => Map<String, Object?>.of(v)..remove('version');

Future<void> warteBis(bool Function() bedingung) async {
  final ende = DateTime.now().add(const Duration(seconds: 15));
  while (!bedingung()) {
    if (DateTime.now().isAfter(ende)) fail('Zeitüberschreitung');
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
}

String _partyDir() {
  var d = Directory.current.absolute;
  for (var i = 0; i < 6; i++) {
    final c = Directory('${d.path}/content/party/schlosskeller');
    if (c.existsSync()) return c.path;
    d = d.parent;
  }
  throw StateError('content/party/schlosskeller nicht gefunden');
}

Map<String, Object?> _json(String pfad) => (jsonDecode(File(pfad).readAsStringSync()) as Map).cast<String, Object?>();

/// `content/party/zusatz/schlosskeller/einfluss.json` neben dem Akten-Ordner [dir].
Map<String, Object?> einflussJson(String dir) => _json('$dir/../zusatz/schlosskeller/einfluss.json');

/// Teile einer Probe-Vorgeschichte, solange die Akte selbst keine hat.
const _probeTeile = ['probe_eins', 'probe_zwei'];

/// Leser des Schlosskellers [dir] für Abende mit Einstimmung ([einstimmung]) und „Dein Moment“ ([einfluss]).
/// Solange die Akte selbst keine Vorgeschichte oder keine Texte dafür hat, ergänzt er Probe-Inhalt: Teile der
/// Vorgeschichte im Setting und je fehlender Kennung einen Probetext (die Kennung, kein Erzähltext). Hat die
/// Akte alles, liest er sie unverändert; ohne beides immer.
KanonLeser probeLeser(String dir, {bool einstimmung = false, bool einfluss = false}) {
  Map<String, Object?> echt(String p) => _json('$dir/$p');
  if (!einstimmung && !einfluss) return echt;
  final setting = echt('setting.json');
  final mitTeilen = einstimmung && setting['vorgeschichte'] == null ? {...setting, 'vorgeschichte': _probeTeile, 'vorstellung': true} : setting;
  Map<String, Object?> lies(String p) => p == 'setting.json' ? mitTeilen : echt(p);
  final kanon = Kanon.lade(lies);
  final e = Einstimmung.aus(kanon);
  final noetig = [
    if (einstimmung && e != null) ...[...e.katalog(), ...e.titel()],
    if (einfluss) ...einflussKatalog(EinflussRegeln.ausJson(einflussJson(dir), Ermittlung(kanon))),
  ];
  final vorhanden = Textsammlung.lade(echt).bausteine.keys.toSet();
  final fehlt = [for (final k in noetig) if (!vorhanden.contains(k)) k];
  if (fehlt.isEmpty) return lies;
  String bereich(String k) => k.startsWith('einfluss.') ? 'einfluss' : (k.startsWith('ui.') ? 'ui' : 'erzaehler');
  final dateien = {
    for (final b in {for (final k in fehlt) bereich(k)})
      'texte/probe-$b.json': <String, Object?>{
        'settingId': kanon.settingId,
        'bereich': b,
        'hinweis': 'Probe',
        'eintraege': [for (final k in fehlt) if (bereich(k) == b) {'id': k, 'text': 'Probe $k'}],
      },
  };
  final index = echt('texte/index.json');
  final mitProbe = {
    ...index,
    'dateien': [
      ...index['dateien'] as List,
      for (final d in dateien.entries) {'datei': d.key.substring('texte/'.length), 'bereich': d.value['bereich']},
    ],
  };
  return (p) => p == 'texte/index.json' ? mitProbe : (dateien[p] ?? lies(p));
}

/// Raum mit kleinerer Platzgrenze (Test „voll“). Alles andere geht an den
/// Schlosskeller-Raum, dessen Platzgrenze (25) hier nicht greift.
class BegrenzterRaum implements AbendRaum {
  BegrenzterRaum(this.innen, this.maxSpieler);

  final AbendRaum innen;

  @override
  final int maxSpieler;

  @override
  String get raumCode => innen.raumCode;
  @override
  int get version => innen.version;
  @override
  bool get vorStart => innen.vorStart;
  @override
  bool get beendet => innen.beendet;
  @override
  List<String> get spielerIds => innen.spielerIds;

  @override
  bool beitreten(String id, String name) {
    if (!spielerIds.contains(id) && spielerIds.length >= maxSpieler) return false;
    return innen.beitreten(id, name);
  }

  @override
  void verlassen(String id) => innen.verlassen(id);
  @override
  void verbunden(String id, bool ja) => innen.verbunden(id, ja);
  @override
  void nachricht(String id, Map<String, Object?> inhalt) => innen.nachricht(id, inhalt);
  @override
  Map<String, Object?> zustandFuer(String id) => innen.zustandFuer(id);
}

class Abend {
  Abend._(this.attrappe, this.relay, this.kanon, this.texte, this.host, this.fabrik);

  /// [offlineFrist], [umschlagFrist] und [maxSpieler] setzen Fristen und Platzgrenze
  /// für einzelne Tests; ohne Angabe gelten die Standardwerte des Pakets.
  ///
  /// [abendzeit] ersetzt die Uhr des Gastgebers (gemeinsame Rundenuhr, M4).
  /// [fassung] lang legt den langen Abend in die Meta wie das Gastgebergerät
  /// (M7b, nur dann der Schlüssel `fassung`); ohne Angabe kurz wie bisher.
  /// [einstimmung] und [einfluss] schalten Vorgeschichte und Vorstellung (A-063)
  /// bzw. „Dein Moment“ (Finale §3) über die Meta ein wie das Gastgebergerät
  /// (`einstimmung: true`, `einfluss: true`, nur dann die Schlüssel), mit
  /// Probe-Inhalt, solange die Akte keinen eigenen hat ([probeLeser]).
  static Future<Abend> starten({
    Duration? offlineFrist,
    Duration? umschlagFrist,
    int? maxSpieler,
    int Function()? abendzeit,
    Abendfassung fassung = Abendfassung.kurz,
    bool einstimmung = false,
    bool einfluss = false,
  }) async {
    final attrappe = await PhoenixAttrappe.starten();
    final relay = RelayParameter(url: attrappe.url, schluessel: attrappe.schluessel);
    final dir = _partyDir();
    final lesen = probeLeser(dir, einstimmung: einstimmung, einfluss: einfluss);
    final kanon = Kanon.lade(lesen);
    final texte = Texte(kanon, Textsammlung.lade(lesen));
    final vorgeschichte = einstimmung ? Einstimmung.aus(kanon) : null;
    final regeln = einfluss ? EinflussRegeln.ausJson(einflussJson(dir), Ermittlung(kanon)) : null;
    final fall = FallCode.zufall(Rng(4711));
    AbendRaum fabrik(String code, Map<String, Object?> meta) {
      final raum = SchlosskellerRaum(
        raumCode: code,
        kanon: kanon,
        texte: texte,
        fallCode: FallCode.lesen(meta['fallCode'] as String)!,
        salz: meta['salz'] as String,
        festerGastgeber: true,
        // Diashow wie im Schlosskeller: sechs Bilder in der Einleitung.
        diaAnzahl: 6,
        // Fassung aus der Meta wie beim Gastgebergerät (M7b).
        fassung: Abendfassung.lesen(meta['fassung']),
        // Einstimmung und „Dein Moment“ aus der Meta wie beim Gastgebergerät (Finale).
        einstimmung: meta['einstimmung'] == true ? vorgeschichte : null,
        einfluss: meta['einfluss'] == true ? regeln : null,
      );
      return maxSpieler == null ? raum : BegrenzterRaum(raum, maxSpieler);
    }

    final host = await RelayHost.neu(
      fabrik: fabrik,
      meta: {
        'salz': salz,
        'fallCode': fall.code,
        if (fassung.istLang) 'fassung': fassung.name,
        if (einstimmung) 'einstimmung': true,
        if (einfluss) 'einfluss': true,
      },
      relay: relay,
      akte: 'schlosskeller',
      inhalt: 'test',
      ablage: SpeicherAblage(),
      offlineFrist: offlineFrist ?? offlineFristStandard,
      umschlagFrist: umschlagFrist ?? umschlagFristStandard,
      abendzeit: abendzeit,
    );
    final a = Abend._(attrappe, relay, kanon, texte, host, fabrik);
    a.hostPlatz = host.lokaleVerbindung('host', 'Gastgeber');
    await host.starten();
    return a;
  }

  final PhoenixAttrappe attrappe;
  final RelayParameter relay;
  final Kanon kanon;
  final Texte texte;
  final RelayHost host;

  /// Fabrik des Raums (wie beim Gastgebergerät, Meta → Raum), für Wiederherstellungen im Test.
  final RaumFabrik fabrik;
  late final LokaleVerbindung hostPlatz;
  final List<RelayGast> gaeste = [];
  final List<SpeicherAblage> ablagen = [];
  final List<PhoenixSocket> _sockets = [];

  /// Der Täterpfad der Partie (nur nach dem Start bekannt).
  String get pfad => ((host.raum as ProtokollRaum).innen as SchlosskellerRaum).partieFuerGastgeber!.spiel.pfad;

  /// Dossier einer Rolle, so wie [SchlosskellerRaum.zustandFuer] es ausliefert.
  Map<String, Object?> dossier(String rolle) {
    final d = texte.dossier(rolle, pfad, rollen);
    return {
      'wer': d.wer,
      'ziel': d.ziel,
      'besetzung': d.besetzung,
      'weiss': [for (final z in d.weiss) z.text],
      'verbirgt': [for (final z in d.verbirgt) z.text],
      if (d.tarnung != null) 'tarnung': d.tarnung,
      if (d.tatwissen.isNotEmpty) 'tatwissen': [for (final z in d.tatwissen) z.text],
    };
  }

  /// Ein weiterer Socket zur Attrappe (wird beim Schließen mit geschlossen).
  Future<PhoenixSocket> socket() async {
    final s = PhoenixSocket(relay.socketUri);
    _sockets.add(s);
    await s.verbinde();
    return s;
  }

  /// Die letzte Ansicht ist beim Gast angekommen, so wie der Gastgeber sie berechnet.
  bool aktuell(RelayGast g) {
    final v = g.letzteAnsicht;
    if (v == null) return false;
    try {
      return jsonEncode(ohneVersion(v)) == jsonEncode(ohneVersion(host.raum.zustandFuer(g.spielerId!)));
    } on PartyRaumFehler {
      return false;
    }
  }

  Future<RelayGast> gast(int i, {Duration befehlWiederholung = const Duration(seconds: 2)}) async {
    final ablage = SpeicherAblage();
    ablagen.add(ablage);
    final g = await RelayGast.beitreten(
      code: host.raumCode,
      name: 'Gast${i + 1}',
      ablage: ablage,
      relay: relay,
      app: 'test',
      inhalt: 'test',
      befehlWiederholung: befehlWiederholung,
    );
    gaeste.add(g);
    return g;
  }

  /// Alle bereit, Start mit [rollen] Rollen; danach hat jeder Gast ohne Sitz seine Rolle.
  Future<void> startet() async {
    for (final g in gaeste) {
      await g.befehl({'typ': 'bereit', 'wert': true});
    }
    await hostPlatz.befehl({'typ': 'bereit', 'wert': true});
    await hostPlatz.befehl({'typ': 'start', 'rollen': rollen});
    // Ein Gast auf dem Detektiv- oder Erzähler-Sitz spielt keine Figur.
    await warteBis(() => gaeste.every((g) => aktuell(g) && (privat(g.letzteAnsicht!)['rolle'] != null || spieler(g.letzteAnsicht!, g.spielerId!)['sitz'] != 'rolle')));
  }

  Future<void> schliessen() async {
    for (final g in gaeste) {
      await g.trennen();
    }
    for (final s in _sockets) {
      await s.schliessen();
    }
    await host.schliessen(gaesteBenachrichtigen: false);
    await attrappe.schliessen();
  }
}
