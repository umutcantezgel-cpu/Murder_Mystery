// BOLLWERK · Torwerkzeug (Master-Prompt §7, A-5).
// Aufruf: dart run tool/bollwerk/bollwerk.dart <schnell|phase|nacht|ziel> [--vorlauf] [--ohne-belege] [--gruppe <k>]
// Endzeile genau „BOLLWERK GRÜN · <modus> · <sha>“ (Exit 0) oder „BOLLWERK ROT · <schichten>“ (Exit 1).
// Eine Schicht, deren Befehl noch fehlt, meldet „OFFEN <schicht>“ und ist rot.
// Belege schreibt nur dieses Werkzeug nach planung/bollwerk/belege/ (A-2 Nachtrag M6).
import 'dart:async';
import 'dart:convert';
import 'dart:io';

final String bw = File(Platform.script.toFilePath()).parent.parent.parent.path;

class Schicht {
  final String name;
  final Duration budget;
  final List<String> befehle;
  final String? fehlt; // Pfad, dessen Fehlen die Schicht OFFEN macht
  final String beleg;
  final Map<String, String> umgebung;
  const Schicht(this.name, this.budget, this.befehle, {this.fehlt, String? beleg, this.umgebung = const {}})
      : beleg = beleg ?? name;
}

class Ergebnis {
  final String name;
  final String status; // GRÜN, ROT, OFFEN
  final int exit;
  final Duration dauer;
  final String log;
  Ergebnis(this.name, this.status, this.exit, this.dauer, this.log);
}

Future<(int, String)> bash(String befehl, Duration timeout, {Map<String, String> umgebung = const {}}) async {
  final p = await Process.start('bash', ['-c', 'set -euo pipefail; $befehl'],
      workingDirectory: bw, environment: umgebung);
  final aus = StringBuffer();
  final f1 = p.stdout.transform(utf8.decoder).forEach(aus.write);
  final f2 = p.stderr.transform(utf8.decoder).forEach(aus.write);
  final code = await p.exitCode.timeout(timeout, onTimeout: () {
    p.kill(ProcessSignal.sigkill);
    aus.writeln('ZEITÜBERSCHREITUNG nach ${timeout.inSeconds} s');
    return 124;
  });
  await Future.wait([f1, f2]);
  return (code, aus.toString());
}

String _filter(String s) =>
    s.split('\n').where((z) => !RegExp(r'Woah|superuser|running flutter as root|📎|^  /$').hasMatch(z)).join('\n');

Future<String> git(String args) async => (await bash('git $args', const Duration(minutes: 1))).$2.trim();

/// Schreib-Erlaubnis vor B-02 (A-2 „Zusatz Erlaubnisprüfung“).
const erlaubtVorB02 = r'^(planung/bollwerk/|tool/bollwerk/|content/runden/|packages/mordakte_core/lib/src/runden/|'
    r'packages/mordakte_core/test/runden/|lib/runden/|assets/runden/|test/runden/|docs/bollwerk/)|'
    r'^packages/mordakte_core/test/web/kanon_eingebettet\.g\.dart$';
const geschuetzt = r'^planung/bollwerk/(MASTER-PROMPT\.md|STARTPAKET\.md|anhang/)';

List<Schicht> schichten(String modus, bool vorlauf) {
  final faelle = {'schnell': 500, 'phase': 2000, 'nacht': 10000, 'ziel': 10000}[modus]!;
  // Bänder (Z-05) und Fairness immer mit 10.000 Partien je Form × Besetzung (E-G2-02: Verschärfung gegenüber 200,
  // weil der Pech-Anteil seit Kern 1.1 nahe der 35-%-Grenze liegt und 200 Partien im Rauschen kippen).
  final seeds = {'schnell': 10000, 'phase': 10000, 'nacht': 10000, 'ziel': 10000}[modus]!;
  final l0 = [
    r'for d in . packages/mordakte_core packages/krimidinner_kanon server; do '
        r'if grep -q "sdk: flutter" $d/pubspec.yaml; then (cd $d && flutter pub get --offline >/dev/null); else (cd $d && dart pub get --offline >/dev/null); fi; done',
    '(cd packages/mordakte_core && dart analyze --fatal-infos lib/src/runden test/runden)',
    'dart analyze --fatal-infos tool/bollwerk',
    'bash tool/secret_scan.sh | tail -1 | grep -qx "Secret-Scan: sauber"',
    'dart run tool/bollwerk/bollwerk.dart --l0-erlaubnis${vorlauf ? ' --vorlauf' : ''}',
    'dart run tool/bollwerk/bollwerk.dart --l0-wuerfelquelle',
    'dart run tool/bollwerk/bollwerk.dart --l0-selbst',
    if (!vorlauf) 'dart run tool/bollwerk/bestand.dart --pruefe',
    if (!vorlauf) 'dart run tool/bollwerk/bollwerk.dart --l0-kanon',
  ];
  return [
    Schicht('L0', const Duration(minutes: 3), l0, fehlt: vorlauf ? null : 'tool/bollwerk/bestand.dart'),
    if (modus != 'schnell')
      Schicht('L1', const Duration(minutes: 12), ['bash tool/alle_tests.sh', 'bash tool/pruefen.sh alles']),
    Schicht('L2', Duration(minutes: modus == 'schnell' ? 2 : (modus == 'phase' ? 8 : 40)),
        ['(cd packages/mordakte_core && dart test test/runden/)'],
        umgebung: {'BOLLWERK_FAELLE': '$faelle'}),
    Schicht('L3', const Duration(minutes: 3), [
      'dart run tool/bollwerk/kanon_einbetten.dart --pruefe',
      '(cd packages/mordakte_core && dart test -p vm test/runden/determinismus_web_test.dart)',
      '(cd packages/mordakte_core && dart test -p node test/runden/determinismus_web_test.dart)',
    ], fehlt: 'packages/mordakte_core/test/runden/determinismus_web_test.dart'),
    Schicht('L4', Duration(minutes: modus == 'schnell' ? 3 : (modus == 'phase' ? 15 : 60)), [
      'dart run tool/bollwerk/runden_simulate.dart --modus erschoepfend',
      'dart run tool/bollwerk/runden_simulate.dart --modus wertung',
      'dart run tool/bollwerk/runden_simulate.dart --modus baender --seeds $seeds',
      if (!vorlauf || modus != 'schnell') 'dart run tool/bollwerk/runden_simulate.dart --modus fairness --seeds $seeds',
      if (!vorlauf || modus != 'schnell') 'dart run tool/bollwerk/runden_simulate.dart --modus dauer --seeds $seeds',
    ]),
    Schicht('L5', const Duration(minutes: 2), ['dart run tool/bollwerk/fuellstoff.dart'], fehlt: 'tool/bollwerk/fuellstoff.dart'),
    if (!vorlauf) Schicht('L6', const Duration(seconds: 60), ['(cd tool/bollwerk/look_anker && flutter test)'], fehlt: 'tool/bollwerk/look_anker'),
    if (modus != 'schnell') ...[
      Schicht('L7', const Duration(minutes: 25), ['node tool/bollwerk/e2e.mjs'], fehlt: 'tool/bollwerk/e2e.mjs'),
      Schicht('L8', const Duration(minutes: 15), ['dart run tool/bollwerk/leistung.dart'], fehlt: 'tool/bollwerk/leistung.dart'),
      Schicht('L9', const Duration(minutes: 40), ['bash tool/bollwerk/mutanten.sh $modus'], fehlt: 'tool/bollwerk/mutanten.sh'),
      Schicht('L10', const Duration(minutes: 1), ['dart run tool/bollwerk/bollwerk.dart --l10-gremien'], fehlt: 'tool/bollwerk/gremium.mjs'),
      Schicht('L12', const Duration(minutes: 60), [
        'dart run tool/bollwerk/design_mass.dart',
        'python3 -I tool/bollwerk/stil.py --alle',
        if (modus != 'phase') 'node tool/bollwerk/gremium.mjs d2',
        if (modus != 'phase') 'node tool/bollwerk/gremium.mjs d3',
      ], fehlt: 'tool/bollwerk/design_mass.dart'),
    ],
    if (modus == 'ziel') Schicht('L11', const Duration(minutes: 60), ['dart run tool/bollwerk/bollwerk.dart --l11-abnahme'], fehlt: 'tool/bollwerk/abnahme.tsv'),
  ];
}

// ---------- L0-Teilprüfungen (einzeln aufrufbar, Exit 0 = grün) ----------

Future<int> l0Erlaubnis(bool vorlauf) async {
  await bash('git fetch -q origin main', const Duration(minutes: 2));
  final b = await git('merge-base HEAD origin/main');
  final namen = (await git('diff --name-only $b HEAD')).split('\n').where((z) => z.isNotEmpty);
  final status = (await git('status --porcelain')).split('\n').where((z) => z.length > 3).map((z) => z.substring(3));
  var rot = 0;
  final b02 = (await bash(
          r'git show origin/bollwerk-leitstand:planung/bollwerk/leitstand/STEUERUNG.md | grep -E "(B-02 ERFÜLLT|FREIGABE BOLLWERK) · K=[0-9a-f]{40}" || test $? = 1',
          const Duration(minutes: 1)))
      .$2
      .trim()
      .isNotEmpty;
  for (final p in {...namen, ...status}) {
    if (RegExp(geschuetzt).hasMatch(p) && (await bash('git diff --quiet 2094a67525cd07526c5e80ab1897e53d3fddac02 HEAD -- "$p"', const Duration(minutes: 1))).$1 != 0) {
      stdout.writeln('L0.2 GESCHÜTZT GEÄNDERT: $p');
      rot++;
    }
    if (!b02 && !RegExp(erlaubtVorB02).hasMatch(p)) {
      // Blob gleich der zugelassenen Linie 1145cb9 ist erlaubt
      final ok = (await bash('test "\$(git rev-parse HEAD:"$p" 2>/dev/null)" = "\$(git rev-parse 1145cb9:"$p" 2>/dev/null)" && test -n "\$(git rev-parse HEAD:"$p" 2>/dev/null)"',
                  const Duration(minutes: 1)))
              .$1 ==
          0;
      if (!ok) {
        stdout.writeln('L0.2 AUSSERHALB DER SCHREIB-ERLAUBNIS: $p');
        rot++;
      }
    }
  }
  stdout.writeln('L0.2 Erlaubnis: ${rot == 0 ? 'grün' : 'rot ($rot)'} · Basis ${b.substring(0, 7)} · B-02 ${b02 ? 'erfüllt' : 'offen'}');
  return rot == 0 ? 0 : 1;
}

/// L0.4 Würfelquelle (WÜ-1, WÜ-6): verbotene Aufrufe im Würfel- und Rundencode.
/// Dateien, die BOLLWERK gegenüber origin/main neu angelegt oder geändert hat, ohne blobgleiche Dateien
/// aus dem Merge 1145cb9 (die gehören der Linie, Bestand).
Future<List<String>> bollwerkDateien(String muster) async {
  await bash('git fetch -q origin main', const Duration(minutes: 2));
  final basis = await git('merge-base HEAD origin/main');
  final namen = (await git('diff --name-only --diff-filter=AM $basis HEAD -- $muster')).split('\n').where((x) => x.isNotEmpty);
  final out = <String>[];
  for (final n in namen) {
    final h = await git('rev-parse -q --verify HEAD:$n');
    final k = await git('rev-parse -q --verify 1145cb9:$n');
    if (h.isNotEmpty && h != k) out.add(n);
  }
  return out;
}

Future<int> l0Wuerfelquelle() async {
  final verboten = RegExp(r"dart:math|DateTime\.now|Stopwatch|\.hashCode\b|identityHashCode|\bZufall\b|\bLcg\b|FallCode\.rng|Random\(");
  var treffer = 0;
  // Befund F-7: zusätzlich jede von BOLLWERK neu angelegte oder geänderte Dart-Datei unter lib/ und packages/
  // (Partycode des anderen Laufs bleibt Bestand und wird hier nicht geprüft, E-G2-07).
  final zusatz = await bollwerkDateien("'lib/*.dart' 'packages/*.dart'");
  for (final rel in zusatz) {
    if (rel.startsWith('packages/mordakte_core/lib/src/runden/') || rel.startsWith('lib/runden/')) continue;
    final f = File('$bw/$rel');
    if (!f.existsSync()) continue;
    final zeilen = f.readAsLinesSync();
    for (var i = 0; i < zeilen.length; i++) {
      final z = zeilen[i].replaceAll(RegExp(r'//.*$'), '');
      if (verboten.hasMatch(z)) {
        stdout.writeln('L0.4 $rel:${i + 1}: ${zeilen[i].trim()}');
        treffer++;
      }
    }
  }
  for (final wurzel in ['packages/mordakte_core/lib/src/runden', 'lib/runden']) {
    final d = Directory('$bw/$wurzel');
    if (!d.existsSync()) continue;
    for (final f in d.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'))) {
      final zeilen = f.readAsLinesSync();
      for (var i = 0; i < zeilen.length; i++) {
        final z = zeilen[i].replaceAll(RegExp(r'//.*$'), '');
        if (verboten.hasMatch(z)) {
          stdout.writeln('L0.4 ${f.path.substring(bw.length + 1)}:${i + 1}: ${zeilen[i].trim()}');
          treffer++;
        }
      }
    }
  }
  stdout.writeln('L0.4 Würfelquelle: $treffer verbotene Aufrufe');
  return treffer == 0 ? 0 : 1;
}

/// Selbstprüfung (MP §7): 0 Treffer für Oder-mit-true/echo um Prüfbefehle in den Torwerkzeugen.
Future<int> l0Selbst() async {
  var treffer = 0;
  for (final f in Directory('$bw/tool/bollwerk').listSync(recursive: true).whereType<File>()) {
    if (!RegExp(r'\.(sh|dart|mjs|py)$').hasMatch(f.path) || f.path.contains('/.dart_tool/')) continue;
    final zeilen = f.readAsLinesSync();
    for (var i = 0; i < zeilen.length; i++) {
      if (RegExp(r'\|\|\s*(true|echo|:)\b').hasMatch(zeilen[i])) {
        stdout.writeln('L0 Selbstprüfung: ${f.path.substring(bw.length + 1)}:${i + 1}');
        treffer++;
      }
    }
  }
  stdout.writeln('L0 Selbstprüfung: $treffer Treffer');
  return treffer == 0 ? 0 : 1;
}

// ---------- Ablauf ----------

Future<Ergebnis> fuehreAus(Schicht s, String logOrdner) async {
  final start = DateTime.now();
  final log = StringBuffer();
  if (s.fehlt != null && FileSystemEntity.typeSync('$bw/${s.fehlt}') == FileSystemEntityType.notFound) {
    log.writeln('OFFEN ${s.name}: ${s.fehlt} fehlt');
    return Ergebnis(s.name, 'OFFEN', 1, Duration.zero, log.toString());
  }
  var exit = 0;
  final budget = s.budget * 2; // Timeout je Schicht = 2 × Budget (A-5 Teil 2)
  for (final b in s.befehle) {
    final rest = budget - DateTime.now().difference(start);
    log.writeln('\$ $b');
    final (c, aus) = await bash(b, rest.isNegative ? Duration.zero : rest, umgebung: s.umgebung);
    log.writeln(_filter(aus).trimRight());
    log.writeln('→ Exit $c');
    if (c != 0) {
      exit = c;
      break;
    }
  }
  final dauer = DateTime.now().difference(start);
  if (dauer > s.budget) log.writeln('BUDGET ÜBERSCHRITTEN: ${dauer.inSeconds} s > ${s.budget.inSeconds} s (Befund, kein Rot)');
  File('$logOrdner/${s.name}.log').writeAsStringSync(log.toString());
  return Ergebnis(s.name, exit == 0 ? 'GRÜN' : 'ROT', exit, dauer, log.toString());
}

Future<String> berlinZeit() async => (await bash('TZ=Europe/Berlin date "+%Y-%m-%d %H:%M:%S %Z"', const Duration(seconds: 10))).$2.trim();

Future<void> main(List<String> args) async {
  if (args.contains('--l0-erlaubnis')) exit(await l0Erlaubnis(args.contains('--vorlauf')));
  if (args.contains('--l0-wuerfelquelle')) exit(await l0Wuerfelquelle());
  if (args.contains('--l0-selbst')) exit(await l0Selbst());
  if (args.isEmpty || !['schnell', 'phase', 'nacht', 'ziel'].contains(args.first)) {
    stdout.writeln('Aufruf: dart run tool/bollwerk/bollwerk.dart <schnell|phase|nacht|ziel> [--vorlauf] [--ohne-belege] [--gruppe <k>]');
    stdout.writeln('BOLLWERK ROT · Aufruf');
    exit(2);
  }
  final modus = args.first;
  final vorlauf = args.contains('--vorlauf');
  final ohneBelege = args.contains('--ohne-belege');
  final gi = args.indexOf('--gruppe');
  final gruppe = gi >= 0 ? int.parse(args[gi + 1]) : null;
  final sha = await git('rev-parse HEAD');
  final tree = await git('rev-parse HEAD^{tree}');
  final schmutz = await git("status --porcelain -- . ':!planung/bollwerk'");
  if (schmutz.isNotEmpty) {
    stdout.writeln('Baum nicht sauber:\n$schmutz');
    stdout.writeln('BOLLWERK ROT · sauberer-baum');
    exit(1);
  }
  final logOrdner = '/home/user/bw-logs/tor-$modus-${sha.substring(0, 7)}';
  Directory(logOrdner).createSync(recursive: true);
  var liste = schichten(modus, vorlauf);
  // Schichtgruppen < 100 min für lange Tore (Befund F-2): Gruppe k = k-te Teilfolge mit Budgetsumme ≤ 90 min
  final gruppen = <List<Schicht>>[[]];
  var summe = Duration.zero;
  for (final s in liste) {
    if (summe + s.budget > const Duration(minutes: 90) && gruppen.last.isNotEmpty) {
      gruppen.add([]);
      summe = Duration.zero;
    }
    gruppen.last.add(s);
    summe += s.budget;
  }
  if (gruppe != null) liste = gruppe <= gruppen.length ? gruppen[gruppe - 1] : [];
  stdout.writeln('BOLLWERK $modus${vorlauf ? ' --vorlauf' : ''} an ${sha.substring(0, 7)} · ${liste.map((s) => s.name).join(' ')}'
      '${gruppe != null ? ' · Gruppe $gruppe/${gruppen.length}' : ''}');
  final ergebnisse = <Ergebnis>[];
  for (final s in liste) {
    final e = await fuehreAus(s, logOrdner);
    ergebnisse.add(e);
    stdout.writeln('${e.name} ${e.status} · ${e.dauer.inSeconds} s${e.status == 'OFFEN' ? ' · ${e.log.trim()}' : ''}');
    if (e.status == 'ROT') stdout.writeln(e.log.split('\n').where((z) => z.trim().isNotEmpty).toList().reversed.take(12).toList().reversed.join('\n'));
  }
  // Der Baum muss nach dem Lauf unverändert sein (kein Prüfbefehl schreibt in den Code).
  final nachher = await git("status --porcelain -- . ':!planung/bollwerk'");
  if (nachher.isNotEmpty) ergebnisse.add(Ergebnis('baum-nachher', 'ROT', 1, Duration.zero, nachher));
  if (!ohneBelege) {
    final ordner = Directory('$bw/planung/bollwerk/belege')..createSync(recursive: true);
    final bw0 = (await bash("git log --diff-filter=A --reverse --format=%H -- planung/bollwerk/messbasis/kanon10.sha256 | head -1",
            const Duration(minutes: 1)))
        .$2
        .trim();
    final stat = bw0.isEmpty ? 'git diff --stat <BW0> HEAD -- tool/bollwerk: BW0 – (Vorlauf)' : await git('diff --stat $bw0 HEAD -- tool/bollwerk');
    final zeit = await berlinZeit();
    for (final e in ergebnisse) {
      final logDatei = File('$logOrdner/${e.name}.log');
      final logSha = logDatei.existsSync() ? (await bash('sha256sum "${logDatei.path}" | cut -d" " -f1', const Duration(seconds: 10))).$2.trim() : '';
      File('${ordner.path}/${e.name}.txt').writeAsStringSync(
          'HEAD $sha · tree $tree · $zeit · $modus${vorlauf ? ' --vorlauf' : ''} · Exit ${e.exit} · ${logSha.isEmpty ? '-' : logSha}\n$stat\n'
          'Status ${e.status} · Dauer ${e.dauer.inSeconds} s\n\n${e.log}');
    }
  }
  final rot = [for (final e in ergebnisse) if (e.status != 'GRÜN') e.name];
  final letzteGruppe = gruppe == null || gruppe >= gruppen.length;
  if (gruppe != null && letzteGruppe) {
    // Endzeile erst nach der letzten Gruppe: alle früheren Gruppen müssen am selben HEAD grün belegt sein.
    for (final s in gruppen.take(gruppen.length - 1).expand((g) => g)) {
      final f = File('$bw/planung/bollwerk/belege/${s.name}.txt');
      final kopf = f.existsSync() ? f.readAsLinesSync() : const <String>[];
      if (kopf.length < 3 || !kopf[0].startsWith('HEAD $sha ') || !kopf[2].startsWith('Status GRÜN')) rot.add('${s.name}(gruppe)');
    }
  }
  final endzeile = rot.isEmpty && letzteGruppe ? 'BOLLWERK GRÜN · $modus · $sha' : (rot.isEmpty ? '' : 'BOLLWERK ROT · ${rot.join(' ')}');
  if (!ohneBelege && endzeile.isNotEmpty) {
    // Tor-Beleg der Phase (2.3 Schritt 6): V im Vorlauf, sonst der Modus.
    File('$bw/planung/bollwerk/belege/tor-${vorlauf ? 'V' : modus}.txt').writeAsStringSync(
        'HEAD $sha · tree $tree · ${await berlinZeit()} · $modus${vorlauf ? ' --vorlauf' : ''} · Exit ${rot.isEmpty ? 0 : 1}\n'
        '${ergebnisse.map((e) => '${e.name} ${e.status} ${e.dauer.inSeconds} s').join(' · ')}\n$endzeile\n');
  }
  if (rot.isEmpty && letzteGruppe) {
    stdout.writeln('BOLLWERK GRÜN · $modus · $sha');
    exit(0);
  } else if (rot.isEmpty) {
    stdout.writeln('Gruppe $gruppe/${gruppen.length} grün · weiter mit --gruppe ${gruppe! + 1}');
    exit(0);
  }
  stdout.writeln('BOLLWERK ROT · ${rot.join(' ')}');
  exit(1);
}
