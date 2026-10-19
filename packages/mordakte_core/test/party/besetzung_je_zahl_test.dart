// F5-TEST-01 (F-09 je Zahl, Besetzung 4 bis 20): je Zahl n prüft ein Test, dass jede besetzte Rolle je Runde so viele
// Gespräche hat, wie ihr Gesprächsmodell verlangt (legacy drei mit den Nummern 1 bis 3, befragung eines; A-051), jeder
// Partner besetzt oder im Modell legacy der Detektiv ist, kein Gesprächs- oder Befragungstext eine unbesetzte Figur
// nennt, das beste Spiel in jedem Pfad als ende_meister endet und jede Quelle einer Begründungskette, die bei n Rollen
// unbesetzt ist, den Detektiv erreicht (Indizkarte, Fakt oder Erzähler, E-035). Der Schlosskeller läuft im Modell
// befragung, das Gewölbe hält die Altfälle des Modells legacy für 4 bis 20 Rollen. Rot-Proben laufen an Kopien im Test,
// keine Kanon-Datei wird verändert.
import 'package:mordakte_core/mordakte_core.dart';
import 'package:test/test.dart';

import 'kanon_hilfe.dart';

String _datei(String rel) => '$repoWurzel/content/party/schlosskeller/$rel';

Texte? _texte;
Texte get texte => _texte ??= Texte(kanon, Textsammlung.lade((p) => leseJson(_datei(p))));

Ermittlung? _ermittlung;
Ermittlung get ermittlung => _ermittlung ??= Ermittlung(kanon);

Erzaehler? _erzaehler;
Erzaehler get erzaehler => _erzaehler ??= Erzaehler(kanon);

PartyKarte? _karte;
PartyKarte get karte => _karte ??= PartyKarte(kanon, ermittlung: ermittlung);

/// Eine Pflichtgesprächszeile, wie der Dossier-Text sie zeigt: Rolle, Runde, Nummer, Partner und Gespräch.
typedef Zeile = ({String rolle, int runde, int nr, String partner, Gespraech gespraech});

/// Kurze Fehlermeldung: Anzahl und die ersten Fälle.
String befund(List<String> f) => f.isEmpty ? 'keine Verstöße' : '${f.length} Verstöße, z. B.:\n${f.take(10).join('\n')}';

/// Alle Zeilen der besetzten Rollen bei [n] Rollen im Pfad [pfad], so wie die Dossiers sie liefern.
List<Zeile> zeilen(int n, String pfad) {
  final out = <Zeile>[];
  for (final r in texte.besetzung.besetzt(n)) {
    final d = texte.dossier(r, pfad, n);
    for (final runde in d.gespraeche.keys) {
      for (final (g, partner) in d.gespraeche[runde]!) {
        out.add((rolle: r, runde: runde, nr: g.nr, partner: partner, gespraech: g));
      }
    }
  }
  return out;
}

/// (a) Jede besetzte Rolle hat in den Runden 1 bis 3 genau [je] Gespräche mit den Nummern 1 bis [je]
/// (Modell legacy 3, Modell befragung 1).
List<String> anzahlFehler(Iterable<String> besetzt, List<Zeile> z, {int je = 3}) {
  final soll = [for (var i = 1; i <= je; i++) i].join(',');
  final f = <String>[];
  for (final r in besetzt) {
    for (var runde = 1; runde <= 3; runde++) {
      final nrs = [for (final x in z) if (x.rolle == r && x.runde == runde) x.nr]..sort();
      if (nrs.join(',') != soll) f.add('$r, Runde $runde: Gespräche mit Nummern $nrs statt $soll');
    }
  }
  return f;
}

/// (b) Jeder Partner ist besetzt oder (nur im Modell legacy) der Detektiv, nie der Sprecher selbst.
List<String> partnerFehler(Besetzung b, int n, List<Zeile> z) => [
      for (final x in z)
        if (!b.istBesetzt(x.partner, n))
          '${x.rolle}, Runde ${x.runde}, Nr ${x.nr}: Partner ${x.partner} ist bei $n Rollen nicht besetzt'
        else if (x.partner == x.rolle)
          '${x.rolle}, Runde ${x.runde}, Nr ${x.nr}: Partner ist der Sprecher selbst'
        else if (b.befragungsmodell && x.partner == Besetzung.detektiv)
          '${x.rolle}, Runde ${x.runde}, Nr ${x.nr}: der Detektiv sitzt im Modell befragung nicht am Tisch',
    ];

/// Name [name] als ganzes Wort in [text]: Buchstaben und Umlaute zählen zum Wort.
bool nennt(String name, String text) => RegExp('(?<!\\p{L})${RegExp.escape(name)}(?!\\p{L})', unicode: true).hasMatch(text);

/// (c) Kein Gesprächstext (Thema, Ziel, Text, Stichpunkte) nennt den Namen einer unbesetzten Figur.
List<String> namenFehler(Kanon k, Iterable<String> unbesetzt, List<Zeile> z) {
  final namen = {for (final id in unbesetzt) id: k.figur(id)!['name'] as String};
  final f = <String>[];
  for (final x in z) {
    final g = x.gespraech;
    final felder = {'Thema': g.thema, 'Ziel': g.ziel, 'Text': g.text, 'Stichpunkte': g.stichpunkte.join(' / ')};
    for (final feld in felder.entries) {
      for (final e in namen.entries) {
        if (nennt(e.value, feld.value)) {
          f.add('${x.rolle}, Gespräch ${g.id}, ${feld.key}: nennt unbesetzte Figur ${e.key} (${e.value})');
        }
      }
    }
  }
  return f;
}

/// (c2) Keine Befragung einer besetzten Rolle (Thema, Fragen, Stichpunkte) nennt eine unbesetzte Figur (I-B6).
List<String> befragungNamenFehler(Kanon k, Texte t, int n) {
  final namen = {for (final id in t.besetzung.npc(n)) id: k.figur(id)!['name'] as String};
  return [
    for (final b in t.sammlung.befragungen.values)
      if (t.besetzung.besetzt(n).contains(b.rolle))
        for (final e in namen.entries)
          for (final feld in [b.thema, ...b.fragen, ...b.stichpunkte])
            if (nennt(e.value, feld)) 'Befragung ${b.id}: nennt unbesetzte Figur ${e.key} (${e.value})',
  ];
}

/// Spielt bis zur Anklage: je Entscheidung die richtige Option ([beste]) oder die erste falsche,
/// Gruppenwahl mit n - 1 kooperativen Stimmen.
Spiel bisAnklage(int n, String pfad, {required bool beste}) {
  final s = Spiel(kanon, ermittlung: ermittlung)
    ..einrichten(Einstellungen(rollen: n, detektiv: 'm', code: FallCode.fuerPfad(pfad, kanon.pfade)));
  while (s.phase != PartyPhase.anklage) {
    if (s.phase == PartyPhase.entscheidungen) {
      for (final x in ermittlung.runde(s.runde)) {
        final richtig = x.richtig[pfad]!;
        s.waehle(x.id, beste ? richtig : x.optionen.firstWhere((o) => o.id != richtig).id);
      }
    }
    if (s.phase == PartyPhase.gruppenwahl) s.abstimmen(kooperativ: n - 1, taeterSabotiert: false);
    s.weiter();
  }
  return s;
}

/// (d) Mit bestem Spiel bleibt im Pfad [pfad] genau die Täterperson, und die Anklage endet als ende_meister.
List<String> loeseFehler(int n, String pfad) {
  final s = bisAnklage(n, pfad, beste: true);
  final f = <String>[];
  final rest = s.restmenge();
  if (rest.length != 1 || !rest.contains(pfad)) f.add('$pfad: Restmenge $rest statt {$pfad}');
  s.anklagen(pfad);
  if (s.ende.id != 'ende_meister') f.add('$pfad: Ende ${s.ende.id} statt ende_meister');
  return f;
}

/// Entscheidungen bis einschließlich [x] in Spielreihenfolge.
Iterable<Entscheidung> bisEinschliesslich(Entscheidung x) =>
    ermittlung.entscheidungen.where((y) => y.runde < x.runde || (y.runde == x.runde && y.nr <= x.nr));

/// (3) Jede Quelle einer Begründungskette (`beobachtung:<id>`), deren Figur bei [n] Rollen unbesetzt ist, erreicht
/// den Detektiv bis zu den Entscheidungen [bis]: über den Erzähler oder als Fakt einer Option, der im Pfad [pfad]
/// entsteht. Ziel einer Option zu sein reicht im Modell befragung nicht (E-044): Die Fundkarte zeigt nur die Fakten.
List<String> erreichFehler(String wo, String pfad, int n, Iterable<Entscheidung> bis, Iterable<String> kette, {int runde = 0}) {
  final optionen = [for (final y in bis) ...y.optionen];
  final ziele = {
    for (final o in optionen)
      if (karte.ziele[o.id]?.person != null) karte.ziele[o.id]!.person!,
  };
  final fakten = {for (final o in optionen) ...o.fakten};
  final f = <String>[];
  for (final k in kette) {
    if (!k.startsWith('beobachtung:')) continue;
    final id = k.substring('beobachtung:'.length);
    final b = ermittlung.beobachtungJson(id);
    if (b == null) {
      f.add('$wo: $k ist unbekannt');
      continue;
    }
    final wer = b['wer'] as String;
    if (texte.besetzung.istBesetzt(wer, n)) continue;
    final alsZiel = !texte.besetzung.befragungsmodell && ziele.contains(wer);
    final alsFakt = fakten.any((fid) => ermittlung.fakten[fid]!.beobachtung == id && ermittlung.gibtEs(fid, pfad));
    // Erzähler (W1, E-035): zum Rundenstart einer Runde bis zur Entscheidung, bei unbesetzter Figur.
    final alsErzaehler = [
      for (var r = 1; r <= runde; r++) ...erzaehler.npcWissen(r, besetzt: (x) => texte.besetzung.istBesetzt(x, n)),
    ].any((b) => b.startsWith('npc.$wer.') && (erzaehler.npcPlan[int.parse(b.split('.').last)]![wer] ?? const []).contains(id));
    if (!alsZiel && !alsFakt && !alsErzaehler) f.add('$wo: $k stammt von $wer, bei $n Rollen unbesetzt, und erreicht den Detektiv nicht');
  }
  return f;
}

void main() {
  for (var n = 4; n <= 20; n++) {
    test('Besetzung $n: Gespräche, Partner, Namen, Lösbarkeit und Quellen stimmen', () {
      final f = <String>[];
      final b = texte.besetzung;
      final besetzt = b.besetzt(n);
      final unbesetzt = b.npc(n);
      expect(b.modell, GespraechsModell.befragung);
      f.addAll(befragungNamenFehler(kanon, texte, n));
      for (final p in kanon.pfade) {
        final z = zeilen(n, p);
        f.addAll([for (final x in anzahlFehler(besetzt, z, je: b.tischJeRolle)) '$p: $x']);
        f.addAll([for (final x in partnerFehler(b, n, z)) '$p: $x']);
        f.addAll([for (final x in namenFehler(kanon, unbesetzt, z)) '$p: $x']);
        f.addAll(loeseFehler(n, p));
        for (final x in ermittlung.entscheidungen) {
          f.addAll(erreichFehler('$p, ${x.id}', p, n, bisEinschliesslich(x), x.begruendungFuer(p)!.kette, runde: x.runde));
        }
      }
      expect(f, isEmpty, reason: befund(f));
    });
  }

  // Altfälle des Modells legacy (drei Gespräche je Rolle, Detektiv als Ersatzpartner) für 4 bis 20 Rollen.
  test('Gewölbe (Modell legacy), 4 bis 20 Rollen: drei Gespräche je Runde, Partner besetzt, keine unbesetzten Namen', () {
    final k = ladeKanon('gewoelbe');
    final t = Texte(k, Textsammlung.lade((p) => leseJson('$repoWurzel/content/party/gewoelbe/$p')));
    final b = t.besetzung;
    expect(b.modell, GespraechsModell.legacy);
    final f = <String>[];
    for (var n = b.minRollen; n <= b.maxRollen; n++) {
      for (final p in k.pfade) {
        final z = <Zeile>[
          for (final r in b.besetzt(n))
            for (final e in t.dossier(r, p, n).gespraeche.entries)
              for (final (g, partner) in e.value) (rolle: r, runde: e.key, nr: g.nr, partner: partner, gespraech: g),
        ];
        f.addAll([for (final x in anzahlFehler(b.besetzt(n), z)) '$n Rollen, $p: $x']);
        f.addAll([for (final x in partnerFehler(b, n, z)) '$n Rollen, $p: $x']);
        f.addAll([for (final x in namenFehler(k, b.npc(n), z)) '$n Rollen, $p: $x']);
      }
    }
    expect(f, isEmpty, reason: befund(f));
    expect(t.lastVerstoesse(), isEmpty);
  });

  test('Die Last jeder Person bleibt in den Grenzen: texte.lastVerstoesse() ist leer', () {
    final f = texte.lastVerstoesse();
    expect(f, isEmpty, reason: befund(f));
  });

  test('Namensprüfung trifft nur ganze Wörter: „Can“ nennt sich in „Cancan“ nicht, wohl aber als eigenes Wort', () {
    expect(nennt('Can', 'Cancan war da.'), isFalse);
    expect(nennt('Can', 'Can, komm her.'), isTrue);
    expect(nennt('Can', 'Sag das Can.'), isTrue);
  });

  test('Rot-Probe: fehlt eine Gesprächszeile, meldet die Anzahlprüfung die Rolle', () {
    final besetzt = texte.besetzung.besetzt(4);
    final r = besetzt.first;
    final z = zeilen(4, 'ahmet');
    final kopie = <Zeile>[for (final x in z) if (!(x.rolle == r && x.runde == 1 && x.nr == 1)) x];
    expect(kopie, hasLength(z.length - 1), reason: 'Probe muss genau eine Zeile entfernen');
    final f = anzahlFehler(besetzt, kopie, je: texte.besetzung.tischJeRolle);
    expect(f.any((x) => x.startsWith('$r, Runde 1')), isTrue, reason: befund(f));
    expect(anzahlFehler(besetzt, z, je: texte.besetzung.tischJeRolle), isEmpty);
  });

  test('Rot-Probe: der Detektiv als Tischpartner wird im Modell befragung gemeldet', () {
    final z = zeilen(4, 'ahmet');
    final x = z.first;
    final kopie = <Zeile>[(rolle: x.rolle, runde: x.runde, nr: x.nr, partner: Besetzung.detektiv, gespraech: x.gespraech), ...z.skip(1)];
    expect(partnerFehler(texte.besetzung, 4, kopie).single, contains('der Detektiv sitzt im Modell befragung nicht am Tisch'));
  });

  test('Rot-Probe: eine Befragung mit dem Namen einer unbesetzten Figur wird gemeldet', () {
    final t = Texte(kanon, Textsammlung.lade((p) => leseJson(_datei(p))));
    final b = t.sammlung.befragungen['bf_ahmet_1']!;
    t.sammlung.befragungen['bf_ahmet_1'] = BefragungText({'id': b.id, 'rolle': b.rolle, 'runde': b.runde, 'thema': 'Tugba und du', 'fragen': b.fragen, 'stichpunkte': b.stichpunkte, 'preisgabe': b.preisgabe});
    expect(befragungNamenFehler(kanon, t, 4), ['Befragung bf_ahmet_1: nennt unbesetzte Figur tugba (Tugba)']);
    expect(befragungNamenFehler(kanon, t, 20), isEmpty);
  });

  test('Rot-Probe: Gesprächsplan mit einem unbesetzten Partner wird gemeldet', () {
    final r = texte.besetzung.besetzt(4).first;
    final ohne = texte.besetzung.npc(4).first;
    final z = zeilen(4, 'ahmet');
    final kopie = <Zeile>[
      for (final x in z)
        if (x.rolle == r && x.runde == 1 && x.nr == 1) (rolle: x.rolle, runde: x.runde, nr: x.nr, partner: ohne, gespraech: x.gespraech) else x,
    ];
    final f = partnerFehler(texte.besetzung, 4, kopie);
    expect(f.any((x) => x.contains('Partner $ohne ist bei 4 Rollen nicht besetzt')), isTrue, reason: befund(f));
  });

  test('Rot-Probe: Gesprächstext mit dem Namen einer unbesetzten Figur wird gemeldet', () {
    final ohne = texte.besetzung.npc(4).first;
    final name = kanon.figur(ohne)!['name'] as String;
    final g = Gespraech({
      'id': 'probe',
      'rolle': 'ahmet',
      'runde': 1,
      'nr': 1,
      'partner': 'fatma',
      'thema': 'Probe',
      'ziel': 'Probe',
      'text': 'Du hast $name gesehen.',
      'preisgabe': <String>[],
    });
    final z = <Zeile>[...zeilen(4, 'ahmet'), (rolle: 'ahmet', runde: 1, nr: 1, partner: 'fatma', gespraech: g)];
    final f = namenFehler(kanon, texte.besetzung.npc(4), z);
    expect(f.any((x) => x.contains('nennt unbesetzte Figur $ohne')), isTrue, reason: befund(f));
  });

  test('Rot-Probe: Quelle einer Begründung, die bei keinem Weg zum Detektiv führt, wird gemeldet', () {
    final unbesetzt = texte.besetzung.npc(4);
    final probe = kanon.beobachtungen.firstWhere((b) => unbesetzt.contains(b['wer']));
    final f = erreichFehler('Probe', 'ahmet', 4, const <Entscheidung>[], ['beobachtung:${probe['id']}']);
    expect(f, hasLength(1), reason: befund(f));
  });

  test('Rot-Probe: falsche Antworten führen in keinem Pfad zu ende_meister', () {
    for (final p in kanon.pfade) {
      final s = bisAnklage(4, p, beste: false);
      s.anklagen(p);
      expect(s.ende.id, isNot('ende_meister'), reason: p);
    }
  });
}
