import 'ablauf.dart';
import 'besetzung.dart';
import 'gruppenwahl.dart';
import 'kanon/kanon.dart';

/// Bausteinwahl des Erzählers (Master 7.12). Der Spielzustand wählt feste
/// Kennungen; die Texte stehen in der Textsammlung des Kanons (F3).
///
/// Vor dem Finale hängt jede Wahl nur am Wissen des Detektivs (S-1): an
/// aufgedeckten Fakten und der Restmenge. Einzige
/// Ausnahme ist der Bonus-Hinweis selbst, der als wahrer, neutraler oder
/// falscher Satz im selben Rahmen kommt; seine Qualität bleibt verborgen.
class Erzaehler {
  final Kanon kanon;
  Erzaehler(this.kanon);

  static const belastend = {'spaetankunft', 'motiv', 'zusatzindiz', 'fundort', 'schluesselbeweis'};

  List<String> intro(Spiel s) {
    final lacher = [for (final l in (kanon.json['setting.json']!['lacher'] as List? ?? const [])) (l as Map).cast<String, Object?>()];
    return [
      'intro.start',
      for (final l in lacher) 'intro.lacher.${l['id']}.${s.besetzung.istBesetzt(l['wer'] as String, s.einstellungen.rollen) ? 'besetzt' : 'npc'}',
      'intro.auftrag.${s.einstellungen.detektiv}',
    ];
  }

  /// Rundenstart; dazu das Wissen unbesetzter Gäste, das eine Runde braucht ([npcWissen]).
  List<String> rundenStart(int runde, {required bool Function(String figur) besetzt}) => [
        'runde.$runde.start',
        ...npcWissen(runde, besetzt: besetzt),
      ];

  /// Wissen unbesetzter Gäste (W1, F-09): Beobachtungen aus Pflichtgesprächen,
  /// die eine Begründungskette braucht und die keine Indizkarte liefert,
  /// spricht der Erzähler zu Beginn der Runde, in der sie zuerst gebraucht
  /// werden – aber nur, wenn die Figur nicht besetzt ist. Die Auswahl hängt
  /// an Runde und Besetzung, nie am Pfad (S-1): Die Ketten aller Pfade zählen.
  /// Im Modell befragung zählen auch Figuren, die Ziel einer Option sind
  /// (E-044): Ihre Fundkarte zeigt nur die Fakten der Option, nicht ihr Wissen.
  List<String> npcWissen(int runde, {required bool Function(String figur) besetzt}) => [
        for (final f in npcPlan[runde]?.keys ?? const <String>[])
          if (!besetzt(f)) 'npc.$f.$runde',
      ];

  /// Runde → Figur → Beobachtungen, die der Erzähler bei unbesetzter Figur spricht.
  late final Map<int, Map<String, List<String>>> npcPlan = _npcPlan();

  Map<int, Map<String, List<String>>> _npcPlan() {
    final beob = {
      for (final b in kanon.json['beobachtungen.json']!['beobachtungen'] as List) (b as Map)['id'] as String: b.cast<String, Object?>(),
    };
    final kern = kanon.kernverdaechtige.toSet();
    // Modell legacy: Ziel-Figuren sprechen auf ihrer Karte selbst (E-035). Modell befragung: Der Erzähler
    // spricht auch ihr Wissen, mit Namen, weil die Optionen sie ohnehin nennen (E-044).
    final mitZielen = Besetzung(kanon).befragungsmodell;
    final es = [for (final e in kanon.entscheidungenJson['entscheidungen'] as List) (e as Map).cast<String, Object?>()]
      ..sort((a, b) => ((a['runde'] as int) * 10 + (a['nr'] as int)).compareTo((b['runde'] as int) * 10 + (b['nr'] as int)));
    final ziele = <String>{};
    final gebraucht = <String, int>{};
    for (final e in es) {
      for (final o in e['optionen'] as List) {
        if (((o as Map)['ziel'] as Map?)?['person'] case final String p) ziele.add(p);
      }
      for (final b in (e['begruendung'] as Map).values) {
        for (final k in (b as Map)['kette'] as List) {
          final teile = (k as String).split(':');
          if (teile[0] != 'beobachtung') continue;
          final x = beob[teile[1]];
          if (x == null || x['kanal'] != 'pflichtgespraech') continue;
          final wer = x['wer'] as String;
          if (kern.contains(wer) || (!mitZielen && ziele.contains(wer))) continue;
          gebraucht.putIfAbsent(teile[1], () => e['runde'] as int);
        }
      }
    }
    final plan = <int, Map<String, List<String>>>{};
    for (final f in kanon.figuren.map((f) => f['id'] as String)) {
      for (final b in gebraucht.entries) {
        if (beob[b.key]!['wer'] == f) ((plan[b.value] ??= {})[f] ??= []).add(b.key);
      }
    }
    return plan;
  }

  List<String> bonus(Spiel s) {
    final q = s.qualitaeten[s.runde]!;
    final h = s.gruppe.hinweis(s.pfad, s.runde, q);
    return ['bonus.rahmen', 'hinweis.${h['id']}'];
  }

  /// Drei Fächer: Gruppenergebnis, Stand der Restverdächtigen, Lage. Das
  /// Gruppenergebnis nennt nur, dass die Runde etwas zugeflüstert hat; Qualität
  /// und Stimmenzahl bleiben bis zur Auflösung verborgen (E-025).
  List<String> resuemee(Spiel s) {
    final fakten = s.bekannteFakten(s.runde);
    return [
      'resuemee.gruppe.${s.runde}',
      restSchluessel(s.ermittlung.restmenge(fakten)),
      'resuemee.lage.${s.runde}.${lageStufe(s, fakten)}',
    ];
  }

  /// Schlüssel für die Restmenge; bei nur einer Person ohne Namen (S-1).
  String restSchluessel(Set<String> rest) {
    final kern = kanon.kernverdaechtige;
    if (rest.length == kern.length) return 'resuemee.rest.alle';
    if (rest.length == 1) return 'resuemee.rest.eins';
    return 'resuemee.rest.${[for (final p in kern) if (rest.contains(p)) p].join('_')}';
  }

  String lageStufe(Spiel s, Set<String> fakten) {
    final typen = {for (final f in fakten) s.ermittlung.fakten[f]!.typ};
    if (typen.contains('schluesselbeweis')) return 'klar';
    if (typen.any(belastend.contains)) return 'spur';
    return 'offen';
  }

  List<String> anklage() => ['anklage.start'];

  List<String> finale(Spiel s) => ['finale.${s.pfad}.${s.ende.id}', 'rueckblende.${s.pfad}'];

  /// Auflösung: erst jetzt, wie oft die Gruppe zusammengehalten hat, dann je Rolle.
  List<String> aufloesung(Spiel s) => [
        'aufloesung.gruppe.${[for (var r = 1; r <= 3; r++) if (Gruppenwahl.zusammengehalten(s.qualitaeten[r]!)) r].length}',
        for (final r in s.besetzt) aufloesungRolle(r, s.pfad),
      ];

  /// Auflösungsbaustein einer Rolle: Kernrollen als Täter- oder Unschuldsfassung,
  /// bei eigenem Pfadverhalten in der Pfadfassung (E-039).
  String aufloesungRolle(String r, String pfad) {
    if (!kanon.kernverdaechtige.contains(r)) return 'aufloesung.$r';
    if (r == pfad) return 'aufloesung.$r.taeter';
    return kanon.eigenesVerhalten(r, pfad) ? 'aufloesung.$r.unschuldig.$pfad' : 'aufloesung.$r.unschuldig';
  }

  /// Alle Kennungen, die der Erzähler je wählen kann (Katalog für F3).
  List<String> katalog() {
    final kern = kanon.kernverdaechtige;
    final lacher = [for (final l in (kanon.json['setting.json']!['lacher'] as List? ?? const [])) (l as Map)['id'] as String];
    final paare = <String>[];
    for (var a = 0; a < kern.length; a++) {
      for (var b = a + 1; b < kern.length; b++) {
        paare.add('resuemee.rest.${kern[a]}_${kern[b]}');
      }
    }
    final dreier = [
      for (final weg in kern) 'resuemee.rest.${[for (final p in kern) if (p != weg) p].join('_')}',
    ];
    final enden = [for (final e in ((kanon.fall['enden'] as Map)['matrix'] as List)) (e as Map)['id'] as String];
    return [
      'intro.start',
      for (final l in lacher) ...['intro.lacher.$l.besetzt', 'intro.lacher.$l.npc'],
      'intro.auftrag.m',
      'intro.auftrag.w',
      for (var r = 1; r <= 3; r++) 'runde.$r.start',
      for (final r in npcPlan.entries)
        for (final f in r.value.keys) 'npc.$f.${r.key}',
      'bonus.rahmen',
      for (var r = 1; r <= 3; r++) 'resuemee.gruppe.$r',
      'resuemee.rest.alle',
      ...dreier,
      ...paare,
      'resuemee.rest.eins',
      for (var r = 1; r <= 3; r++) for (final st in ['offen', 'spur', 'klar']) 'resuemee.lage.$r.$st',
      'anklage.start',
      for (final p in kanon.pfade) ...[for (final e in enden) 'finale.$p.$e', 'rueckblende.$p'],
      for (var n = 0; n <= 3; n++) 'aufloesung.gruppe.$n',
      for (final r in kanon.figuren.map((f) => f['id'] as String))
        if (kern.contains(r)) ...[
          if (kanon.pfade.contains(r)) 'aufloesung.$r.taeter',
          if (kanon.pfade.any((p) => p != r)) 'aufloesung.$r.unschuldig',
          for (final p in kanon.pfade)
            if (kanon.eigenesVerhalten(r, p)) 'aufloesung.$r.unschuldig.$p',
        ] else
          'aufloesung.$r',
    ];
  }
}
