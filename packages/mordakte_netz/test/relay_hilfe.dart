/// Aufbauhilfe der Relais-Tests: lokale Attrappe, Gastgeber mit dem echten
/// Schlosskeller-Raum aus `content/party/schlosskeller` und Gäste. Je Test neu.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:mordakte_core/mordakte_core.dart' show FallCode, Kanon, Rng, Texte, Textsammlung;
import 'package:mordakte_core/runden.dart' show PartyRaumFehler, ProtokollRaum, SchlosskellerRaum;
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

class Abend {
  Abend._(this.attrappe, this.relay, this.kanon, this.texte, this.host);

  static Future<Abend> starten() async {
    final attrappe = await PhoenixAttrappe.starten();
    final relay = RelayParameter(url: attrappe.url, schluessel: attrappe.schluessel);
    final dir = _partyDir();
    Map<String, Object?> lesen(String p) => (jsonDecode(File('$dir/$p').readAsStringSync()) as Map).cast<String, Object?>();
    final kanon = Kanon.lade(lesen);
    final texte = Texte(kanon, Textsammlung.lade(lesen));
    final fall = FallCode.zufall(Rng(4711));
    final host = await RelayHost.neu(
      fabrik: (code, meta) => SchlosskellerRaum(
        raumCode: code,
        kanon: kanon,
        texte: texte,
        fallCode: FallCode.lesen(meta['fallCode'] as String)!,
        salz: meta['salz'] as String,
        festerGastgeber: true,
      ),
      meta: {'salz': salz, 'fallCode': fall.code},
      relay: relay,
      akte: 'schlosskeller',
      inhalt: 'test',
      ablage: SpeicherAblage(),
    );
    final a = Abend._(attrappe, relay, kanon, texte, host);
    a.hostPlatz = host.lokaleVerbindung('host', 'Gastgeber');
    await host.starten();
    return a;
  }

  final PhoenixAttrappe attrappe;
  final RelayParameter relay;
  final Kanon kanon;
  final Texte texte;
  final RelayHost host;
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

  /// Alle bereit, Start mit [rollen] Rollen; danach hat jeder Gast seine Rolle.
  Future<void> startet() async {
    for (final g in gaeste) {
      await g.befehl({'typ': 'bereit', 'wert': true});
    }
    await hostPlatz.befehl({'typ': 'bereit', 'wert': true});
    await hostPlatz.befehl({'typ': 'start', 'rollen': rollen});
    await warteBis(() => gaeste.every((g) => aktuell(g) && privat(g.letzteAnsicht!)['rolle'] != null));
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
