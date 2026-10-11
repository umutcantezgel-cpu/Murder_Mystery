import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:mordakte_core/mordakte_core.dart' show Besetzung, FallCode, Kanon, Rng, Texte, Textsammlung;
import 'package:mordakte_core/runden.dart' show PartyRaumFehler, ProtokollRaum, SchlosskellerRaum;
import 'package:mordakte_netz/io.dart';
import 'package:mordakte_netz/mordakte_netz.dart';
import 'package:test/test.dart';

const _salz = '00112233445566778899aabbccddeeff00112233445566778899aabbccddeeff';

late PhoenixAttrappe attrappe;
late RelayParameter relay;
late Kanon kanon;
late Texte texte;
late RelayHost host;
late LokaleVerbindung hostPlatz;
final List<RelayGast> gaeste = [];
final List<SpeicherAblage> ablagen = [];
final List<PhoenixSocket> _sockets = [];

String _partyDir() {
  var d = Directory.current.absolute;
  for (var i = 0; i < 6; i++) {
    final c = Directory('${d.path}/content/party/schlosskeller');
    if (c.existsSync()) return c.path;
    d = d.parent;
  }
  throw StateError('content/party/schlosskeller nicht gefunden');
}

Map<String, Object?> _privat(Map<String, Object?> v) => (v['privat'] as Map).cast<String, Object?>();

Map<String, Object?> _spieler(Map<String, Object?> v, String id) =>
    (v['spieler'] as List).cast<Map>().map((s) => s.cast<String, Object?>()).firstWhere((s) => s['id'] == id);

Map<String, Object?> _ohneVersion(Map<String, Object?> v) => Map<String, Object?>.of(v)..remove('version');

/// Die Ansicht ist beim Gast angekommen, wie der Gastgeber sie für ihn berechnet.
bool _aktuell(RelayGast g) {
  final v = g.letzteAnsicht;
  if (v == null) return false;
  try {
    return jsonEncode(_ohneVersion(v)) == jsonEncode(_ohneVersion(host.raum.zustandFuer(g.spielerId!)));
  } on PartyRaumFehler {
    return false;
  }
}

String _roh(String t) {
  final j = jsonEncode(t);
  return j.substring(1, j.length - 1);
}

Set<String> _texteIn(Object? v) {
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

/// Wie [SchlosskellerRaum.zustandFuer] das Dossier einer Rolle baut.
Map<String, Object?> _dossierJson(String rolle, String pfad, int rollen) {
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

String _pfad() => ((host.raum as ProtokollRaum).innen as SchlosskellerRaum).partieFuerGastgeber!.spiel.pfad;

Future<void> warteBis(bool Function() bedingung) async {
  final ende = DateTime.now().add(const Duration(seconds: 15));
  while (!bedingung()) {
    if (DateTime.now().isAfter(ende)) fail('Zeitüberschreitung');
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
}

Future<RelayGast> gastBeitreten(int i, {SpeicherAblage? ablage, Duration befehlWiederholung = const Duration(seconds: 2)}) async {
  final ab = ablage ?? SpeicherAblage();
  ablagen.add(ab);
  final g = await RelayGast.beitreten(
    code: host.raumCode,
    name: 'Gast${i + 1}',
    ablage: ab,
    relay: relay,
    app: 'test',
    inhalt: 'test',
    befehlWiederholung: befehlWiederholung,
  );
  gaeste.add(g);
  return g;
}

/// Alle bereit, Start mit vier Rollen; danach hat jeder Gast seine Rolle.
Future<void> startet() async {
  for (final g in gaeste) {
    await g.befehl({'typ': 'bereit', 'wert': true});
  }
  await hostPlatz.befehl({'typ': 'bereit', 'wert': true});
  await hostPlatz.befehl({'typ': 'start', 'rollen': 4});
  await warteBis(() => gaeste.every((g) => _aktuell(g) && _privat(g.letzteAnsicht!)['rolle'] != null));
}

void main() {
  setUp(() async {
    attrappe = await PhoenixAttrappe.starten();
    relay = RelayParameter(url: attrappe.url, schluessel: attrappe.schluessel);
    final dir = _partyDir();
    Map<String, Object?> lesen(String p) => (jsonDecode(File('$dir/$p').readAsStringSync()) as Map).cast<String, Object?>();
    kanon = Kanon.lade(lesen);
    texte = Texte(kanon, Textsammlung.lade(lesen));
    final fall = FallCode.zufall(Rng(4711));
    host = await RelayHost.neu(
      fabrik: (code, meta) => SchlosskellerRaum(
        raumCode: code,
        kanon: kanon,
        texte: texte,
        fallCode: FallCode.lesen(meta['fallCode'] as String)!,
        salz: meta['salz'] as String,
        festerGastgeber: true,
      ),
      meta: {'salz': _salz, 'fallCode': fall.code},
      relay: relay,
      akte: 'schlosskeller',
      inhalt: 'test',
      ablage: SpeicherAblage(),
    );
    hostPlatz = host.lokaleVerbindung('host', 'Gastgeber');
    await host.starten();
  });

  tearDown(() async {
    for (final g in gaeste) {
      await g.trennen();
    }
    gaeste.clear();
    ablagen.clear();
    for (final s in _sockets) {
      await s.schliessen();
    }
    _sockets.clear();
    await host.schliessen(gaesteBenachrichtigen: false);
    await attrappe.schliessen();
  });

  test('jeder Platz bekommt Ansichten; alle Spieler erscheinen', () async {
    for (var i = 0; i < 3; i++) {
      await gastBeitreten(i);
    }
    for (final g in gaeste) {
      expect(g.turm?.epoch, 1, reason: 'Turm des Gastgebers übernommen');
      expect(g.letzteAnsicht!['raum'], host.raumCode);
      expect(_privat(g.letzteAnsicht!)['spieler'], g.spielerId);
      expect(_privat(g.letzteAnsicht!)['dossier'], isNull, reason: 'vor dem Start kein Dossier');
    }
    await warteBis(() => gaeste.every((g) => (g.letzteAnsicht!['spieler'] as List).length == 4));
    expect(hostPlatz.letzteAnsicht, isNotNull);
  });

  test('nach dem Start sieht jeder Gast nur sein eigenes Dossier', () async {
    for (var i = 0; i < 3; i++) {
      await gastBeitreten(i);
    }
    await startet();
    final rollen = Besetzung(kanon).besetzt(4);
    final dossiers = {for (final r in rollen) r: _dossierJson(r, _pfad(), 4)};
    final rollenDerGaeste = <String>{};
    for (final g in gaeste) {
      final privat = _privat(g.letzteAnsicht!);
      final rolle = privat['rolle'] as String;
      rollenDerGaeste.add(rolle);
      expect(privat['spieler'], g.spielerId);
      expect(jsonEncode(privat['dossier']), jsonEncode(dossiers[rolle]), reason: 'eigenes Dossier von ${g.spielerId}');
      final eigene = _texteIn(dossiers[rolle]);
      final fremde = {for (final e in dossiers.entries) if (e.key != rolle) ..._texteIn(e.value)}..removeAll(eigene);
      final text = jsonEncode(privat);
      // Kontrollen: Der Vergleich hat Texte, und der eigene Text ist im Klartext sichtbar.
      expect(fremde.where((t) => t.length >= 24), isNotEmpty);
      expect(text.contains(_roh(eigene.firstWhere((t) => t.length >= 24))), isTrue);
      for (final t in fremde.where((t) => t.length >= 24)) {
        expect(text.contains(_roh(t)), isFalse, reason: 'fremder Dossiertext im privaten Teil von ${g.spielerId}');
      }
    }
    expect(rollenDerGaeste, hasLength(3), reason: 'drei verschiedene Rollen');
    expect(_privat(hostPlatz.letzteAnsicht!)['dossier'], isNull, reason: 'der Gastgeber hat kein Dossier');
    expect(_privat(hostPlatz.letzteAnsicht!)['detektiv'], isTrue, reason: 'der Gastgeber führt den Abend');
  });

  test('ein Mithörer im Relais sieht nie Dossier-Klartext', () async {
    for (var i = 0; i < 3; i++) {
      await gastBeitreten(i);
    }
    final mit = StringBuffer();
    final lausch = PhoenixSocket(relay.socketUri);
    _sockets.add(lausch);
    await lausch.verbinde();
    final lobby = lausch.kanal(lobbyThema(host.raumCode), presence: false);
    lobby.nachrichten.listen((m) => mit.writeln('L ${m.ereignis} ${jsonEncode(m.payload)}'));
    await lobby.beitreten();
    for (final g in gaeste) {
      final k = lausch.kanal(sitzThema(host.raumCode, g.cid), presence: false);
      k.nachrichten.listen((m) => mit.writeln('S ${m.ereignis} ${jsonEncode(m.payload)}'));
      await k.beitreten();
    }
    await startet();
    await warteBis(() => gaeste.every(_aktuell));

    final text = mit.toString();
    expect(RegExp(r'^S m ', multiLine: true).allMatches(text).length, greaterThanOrEqualTo(6), reason: 'der Mithörer sah den Verkehr');
    final dossierTexte = [for (final r in Besetzung(kanon).besetzt(4)) ..._texteIn(_dossierJson(r, _pfad(), 4))].where((t) => t.length >= 12);
    // Kontrolle: Der Gast sieht seinen Dossiertext, der Mithörer nicht.
    expect(dossierTexte.any((t) => jsonEncode(gaeste[0].letzteAnsicht).contains(_roh(t))), isTrue);
    for (final t in dossierTexte) {
      expect(text.contains(_roh(t)), isFalse, reason: 'Dossier-Klartext im Mitschnitt');
    }
    for (final verboten in ['"dossier"', '"privat"', '"weiss"', '"aufloesung"', '"hatGestimmt"', _salz, 'Gast1', 'Gastgeber']) {
      expect(text.contains(verboten), isFalse, reason: 'Klartext "$verboten" im Mitschnitt');
    }
    for (final z in text.split('\n').where((z) => z.startsWith('L '))) {
      expect(z.startsWith('L klopf ') || z.startsWith('L turm '), isTrue, reason: 'unerwartetes Lobby-Ereignis');
    }
  });

  test('ein gefälschter Turm mit fremdem Schlüssel wird von den Gästen verworfen', () async {
    final fremd = await Schluesselpaar.erzeugen();
    final st = PhoenixSocket(relay.socketUri);
    _sockets.add(st);
    await st.verbinde();
    final lobby = st.kanal(lobbyThema(host.raumCode), presence: false);
    await lobby.beitreten();
    final spam = Timer.periodic(const Duration(milliseconds: 30), (_) {
      lobby.sende('turm', {
        'hpub': b64(fremd.oeffentlich),
        'epoch': 99,
        'proto': protokollVersion,
        'akte': 'schlosskeller',
        'inhalt': 'test',
        'offen': true,
        'plaetze': 9,
      });
    });
    for (var i = 0; i < 3; i++) {
      await gastBeitreten(i);
    }
    spam.cancel();
    for (final g in gaeste) {
      expect(g.verworfen, greaterThan(0), reason: 'der Gast hat den gefälschten Turm gehört und verworfen');
      expect(g.turm?.epoch, 1, reason: 'Epoche 99 des Fälschers wurde nicht übernommen');
    }
    await startet();
    expect(_privat(gaeste[0].letzteAnsicht!)['rolle'], isNotNull, reason: 'die Sitzung läuft mit dem echten Gastgeber');
  });

  test('ein Gast mit derselben Ablage kehrt mit gleicher Spieler-ID und Rolle zurück', () async {
    for (var i = 0; i < 3; i++) {
      await gastBeitreten(i);
    }
    await startet();
    final alt = gaeste[0];
    final id = alt.spielerId!;
    final vorher = _privat(alt.letzteAnsicht!);
    await alt.trennen();
    await warteBis(() => _spieler(hostPlatz.letzteAnsicht!, id)['online'] == false);

    final neu = await RelayGast.beitreten(code: host.raumCode, name: 'Gast1', ablage: ablagen[0], relay: relay, app: 'test', inhalt: 'test');
    gaeste[0] = neu;
    expect(neu.spielerId, id, reason: 'gleicher Schlüssel, gleiche Spieler-ID');
    await warteBis(() => _aktuell(neu));
    final nachher = _privat(neu.letzteAnsicht!);
    expect(nachher['rolle'], vorher['rolle']);
    expect(jsonEncode(nachher['dossier']), jsonEncode(vorher['dossier']));
    await warteBis(() => _spieler(hostPlatz.letzteAnsicht!, id)['online'] == true);
    await expectLater(
      neu.befehl({'typ': 'bereit', 'wert': true}),
      throwsA(isA<AbendFehler>().having((e) => e.key, 'key', 'game_running')),
    );
  });

  test('ein Befehl, der nach Verlust erneut gesendet wird, wird genau einmal ausgeführt', () async {
    final g = await gastBeitreten(0, befehlWiederholung: const Duration(milliseconds: 300));
    final vorAus = host.statistik.befehleAusgefuehrt;
    final vorWdh = host.statistik.befehleWiederholt;
    // Jede Zustellung braucht 350 ms, die Antwort kommt also erst nach der ersten
    // Wiederholung (300 ms) an: Der Gastgeber sieht dieselbe Nummer q zweimal.
    attrappe.stoerung.verzoegerungMin = const Duration(milliseconds: 350);
    attrappe.stoerung.verzoegerungMax = const Duration(milliseconds: 350);
    await g.befehl({'typ': 'bereit', 'wert': true});
    attrappe.stoerung.verzoegerungMin = Duration.zero;
    attrappe.stoerung.verzoegerungMax = Duration.zero;
    await warteBis(() => host.statistik.befehleWiederholt > vorWdh);
    expect(host.statistik.befehleAusgefuehrt - vorAus, 1, reason: 'genau eine Ausführung');
    expect(_spieler(hostPlatz.letzteAnsicht!, g.spielerId!)['bereit'], isTrue);
  });
}
