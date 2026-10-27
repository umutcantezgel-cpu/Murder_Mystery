import '../../party/ablauf.dart';
import '../../party/erzaehler.dart' show einflussBaustein;
import '../einfluss.dart';
import '../partie.dart';
import '../runden_uhr.dart' show abendZeitFeld;
import '../schlosskeller_raum.dart' show PartyRaumFehler;

/// Frist des letzten Aufrufs im Moment (Finale §3.14): So viele Millisekunden
/// Abendzeit nach `letzterAufruf` darf es ohne die fehlenden Züge weitergehen.
const momentAufrufFrist = 60000;

/// „Dein Moment“ im Online-Abend (Finale §3.1, §3.2, §3.12, §3.14): die
/// Raumseite der Einfluss-Schicht. Die Partie ([RundenPartie.einfluss]) hält
/// Züge, Folgen und Wertung; hier liegt nur, was der Raum zusätzlich weiß: der
/// letzte Aufruf, welche Rollen je Runde als Bot zogen, die Reaktionsblasen und
/// die Ansichten. Keine Wanduhr: Die Abendzeit kommt vom Transport.
///
/// Nachrichten (der Raum prüft Schlüssel, Gerät und Rechte vorher):
/// - `zug {art, ziel?, tipp?}`: nur in den Gesprächen (`invalid_phase`), nur
///   von Geräten mit Figur (Detektiv, Erzähler, Assistenz: `invalid`), änderbar
///   bis zu den Folgen; ein unzulässiger Zug ist `invalid`. `abgewartet` ist
///   erlaubt (bewusst nichts tun).
/// - `letzterAufruf {}`: nur, wer leitet, nur in den Gesprächen; die Abendzeit
///   des ersten Aufrufs der Runde zählt.
/// - `nachfrage {option}`: nur der Detektiv-Sitz, nach Runde 3 vor der Anklage.
///
/// Weiter aus den Gesprächen geht erst, wenn alle Rollen mit Menschen gezogen
/// haben oder der letzte Aufruf [momentAufrufFrist] zurückliegt ([darfWeiter]);
/// wer dann fehlt, hat abgewartet. Rollen ohne Menschen (auch getrennte Plätze,
/// sobald der Transport sie nach seiner Frist aus dem Raum nimmt) zieht der Bot.
///
/// Sichtbarkeit (§3.12): öffentlich [oeffentlich] (nie wer was spielte, nie
/// Zählwerte oder Tipps), privat je Rolle [moment], beim Erzähler [tafel], ab
/// dem Finale [aufloesung]. Nichts davon kennt den Pfad.
class EinflussRaum {
  EinflussRaum(this.regeln);

  final EinflussRegeln regeln;

  int? _aufruf;
  final Map<int, Set<String>> _bots = {};
  final Map<int, List<BotBlase>> _blasen = {};

  /// Abendzeit (ms) des letzten Aufrufs in den laufenden Gesprächen, sonst `null`.
  int? get aufruf => _aufruf;

  /// Rollen, die in [runde] als Bot zogen (ab den Folgen der Runde).
  Set<String> botsIn(int runde) => Set.unmodifiable(_bots[runde] ?? const <String>{});

  /// Reaktionsblasen der Folgen von [runde] (§3.11).
  List<BotBlase> blasenIn(int runde) => _blasen[runde] ?? const [];

  // ------------------------------------------------------------- Nachrichten

  /// `zug {art, ziel?, tipp?}` des Geräts mit der Figur [rolle].
  void zug(RundenPartie p, String? rolle, Map<String, Object?> inhalt) {
    if (rolle == null) throw const PartyRaumFehler('invalid');
    if (p.phase != PartyPhase.gespraeche) throw const PartyRaumFehler('invalid_phase');
    final art = ZugArt.lesen(inhalt['art']);
    final ziel = inhalt['ziel'], tipp = inhalt['tipp'];
    if (art == null || (ziel != null && ziel is! String) || (tipp != null && tipp is! String)) {
      throw const PartyRaumFehler('invalid');
    }
    // Unzulässige Züge (Ziel, Einmal-Art, Tipp) werfen ArgumentError, der Raum übersetzt in `invalid`.
    p.zugSetzen(rolle, art, ziel: ziel as String?, tipp: tipp as String?);
  }

  /// `letzterAufruf {}` mit der Abendzeit des Transports.
  void letzterAufruf(RundenPartie p, Map<String, Object?> inhalt) {
    if (p.phase != PartyPhase.gespraeche) throw const PartyRaumFehler('invalid_phase');
    final zeit = inhalt[abendZeitFeld];
    if (zeit is! int) throw const PartyRaumFehler('invalid');
    _aufruf ??= zeit;
  }

  /// Haben alle Rollen, die ein Mensch spielt ([mensch]), in der laufenden Runde gezogen?
  bool alleGezogen(RundenPartie p, bool Function(String rolle) mensch) {
    final s = p.einfluss!.stand;
    return s.besetzt.every((r) => !mensch(r) || s.zug(p.runde, r) != null);
  }

  /// Darf es aus den Gesprächen weiter (außerhalb immer)? Alle Rollen mit Menschen haben gezogen, oder seit
  /// dem letzten Aufruf sind [momentAufrufFrist] ms Abendzeit vergangen ([zeit] der Nachricht `weiter`). Für
  /// die Ansicht ([ansicht]) genügt der Aufruf: Die Frist rechnet jedes Gerät aus `einfluss.aufruf`.
  bool darfWeiter(RundenPartie p, bool Function(String rolle) mensch, {int? zeit, bool ansicht = false}) {
    if (p.phase != PartyPhase.gespraeche || alleGezogen(p, mensch)) return true;
    final a = _aufruf;
    if (a == null) return false;
    return ansicht || (zeit != null && zeit - a >= momentAufrufFrist);
  }

  /// Vor dem Wechsel aus den Gesprächen: Wer als Mensch nicht gezogen hat, hat abgewartet; die übrigen
  /// Rollen ohne Zug ziehen in den Folgen als Bot ([RundenPartie.weiter]).
  void vorFolgen(RundenPartie p, bool Function(String rolle) mensch) {
    final s = p.einfluss!.stand;
    final r = p.runde;
    for (final rolle in s.besetzt) {
      if (mensch(rolle) && s.zug(r, rolle) == null) p.zugSetzen(rolle, ZugArt.abgewartet);
    }
    _bots[r] = {for (final rolle in s.besetzt) if (s.zug(r, rolle) == null) rolle};
  }

  /// Nach den Folgen von [runde]: Reaktionsblasen der Bots, der Aufruf ist verbraucht.
  void nachFolgen(RundenPartie p, int runde) {
    final bots = _bots[runde] ?? const <String>{};
    _blasen[runde] = p.einfluss!.blasen(runde, istBot: bots.contains);
    _aufruf = null;
  }

  /// `nachfrage {option}` des Detektiv-Sitzes (Finale §3.5).
  void nachfrage(RundenPartie p, Map<String, Object?> inhalt) {
    final option = inhalt['option'];
    if (option is! String || option.isEmpty) throw const PartyRaumFehler('invalid');
    // Keine Nachfrage offen: StateError (`invalid_phase`); nichts nachzufragen: ArgumentError (`invalid`).
    p.nachfrage(option);
  }

  // ------------------------------------------------------------- Ansichten

  /// Funde verzögerter Entscheidungen, sobald das Zwischenresümee sie zeigt (für das Notizbuch).
  Map<String, List<String>> nachgereicht(RundenPartie p) => {
        for (var r = 1; r <= p.runde; r++)
          for (final e in p.einfluss!.nachgereicht(r).entries) e.key: [for (final f in e.value) f.text],
      };

  /// Öffentlich `einfluss`, für alle Geräte gleich: Runde; in den Gesprächen, wer schon gezogen hat (nur
  /// Rollen, nie was), auf wen der Raum noch wartet (`offen`: Rollen mit Menschen nach [mensch] ohne Zug;
  /// ohne [mensch] alle besetzten) und den letzten Aufruf; Leisten und Ereignisse; je ausgewertete Runde die Folgen
  /// (Gerüchte als Bausteine, Geständnisse, Ablenker, Zuwachs, Minuten, Tischwerte, Blasen); die Tischwerte
  /// der laufenden Runde; die Kennzeichen jeder aufgedeckten Entscheidung (verwischt, verzögert, ertappt,
  /// Randnotizen, Befragung); gezeigte Randnotizen; Nachfragen. In der Lobby nur die Runde 0.
  Map<String, Object?> oeffentlich(RundenPartie? p, {bool Function(String rolle)? mensch}) {
    if (p == null) return const {'runde': 0};
    final e = p.einfluss!;
    final s = e.stand;
    final r = p.runde;
    final f = s.folgenVon(r);
    return {
      'runde': r,
      if (p.phase == PartyPhase.gespraeche) ...{
        'gezogen': [for (final b in s.besetzt) if (s.zug(r, b) != null) b],
        'offen': [for (final b in s.besetzt) if ((mensch?.call(b) ?? true) && s.zug(r, b) == null) b],
        'aufruf': ?_aufruf,
      },
      'leisten': {'zusammenhalt': s.zusammenhalt, 'spuk': s.spuk},
      'ereignisse': [for (final x in s.folgen) for (final ev in x.ereignisse) ev.id],
      'folgen': [for (final x in s.folgen) _folgen(x)],
      if (f != null) 'tisch': Map.of(f.tisch),
      'funde': {for (final x in e.funde.entries) x.key: x.value.toJson()},
      'randnotizen': e.randnotizen,
      if (s.kerzenschein) 'kerzenschein': true,
      if (p.phase == PartyPhase.anklage) 'nachfragen': {'offen': p.nachfragenOffen, 'optionen': p.nachfrageOptionen},
      if (e.nachfragen.isNotEmpty) 'nachgefragt': [for (final n in e.nachfragen) {'option': n.option, 'notiz': n.notiz}],
    };
  }

  Map<String, Object?> _folgen(EinflussFolgen f) => {
        'runde': f.runde,
        'geruechte': [for (final g in f.geruechte) einflussBaustein('einfluss.geruecht.${g.laut ? 'laut' : 'leise'}', figur: g.figur)],
        'gestanden': [for (final a in f.auspacken) a.toJson()],
        'ablenker': f.ablenker,
        'zuwachs': {'zusammenhalt': f.zusammenhaltZuwachs, 'spuk': f.spukZuwachs},
        'ereignisse': [for (final ev in f.ereignisse) ev.id],
        'minuten': f.minuten,
        'tisch': Map.of(f.tisch),
        'blasen': [for (final b in blasenIn(f.runde)) b.schluessel],
      };

  /// Privat `moment` der Rolle [rolle]: in den Gesprächen (`offen`) der eigene Zug, erlaubte Arten, Ziele je
  /// Art und in der Tipp-Runde die Tipps; immer die eigenen bisherigen Züge, der Live-Stand der zwei
  /// Sterne, die privaten Nachrichten und – nur beim Lauscher – das Lauschergebnis.
  Map<String, Object?> moment(RundenPartie p, String rolle) {
    final e = p.einfluss!;
    final s = e.stand;
    final r = p.runde;
    final offen = p.phase == PartyPhase.gespraeche && s.offeneRunde == r;
    final eigen = offen ? s.zug(r, rolle) : null;
    final arten = offen ? s.erlaubteArten(rolle) : const <ZugArt>[];
    final privat = e.privatFuer(rolle);
    Map<String, Object?> nachricht(({int runde, PrivatNachricht nachricht}) n) =>
        {'runde': n.runde, 'schluessel': n.nachricht.schluessel, ...n.nachricht.toJson()};
    final gelauscht = [for (final n in privat) if (n.nachricht.art == PrivatArt.gelauscht) nachricht(n)];
    return {
      'runde': r,
      'offen': offen,
      if (eigen != null) 'zug': _ohneRolle(eigen),
      if (offen) ...{
        'arten': [for (final a in arten) a.name],
        'ziele': {
          for (final a in arten)
            if (s.erlaubteZiele(rolle, a) case final z when z.isNotEmpty) a.name: z,
        },
        if (r == regeln.zahlen.tippRunde) 'tipps': regeln.tipps,
      },
      'zuege': [for (final f in s.folgen) {'runde': f.runde, ..._ohneRolle(f.zuege[rolle]!)}],
      'sterne': [
        for (final z in e.zielStaende(rolle)) {'nr': z.ziel.nr, 'id': z.ziel.id, 'schluessel': z.ziel.schluessel, 'stand': z.stand.name},
      ],
      'nachrichten': [for (final n in privat) if (n.nachricht.art != PrivatArt.gelauscht) nachricht(n)],
      if (gelauscht.isNotEmpty) 'gelauscht': gelauscht,
    };
  }

  static Map<String, Object?> _ohneRolle(EinflussZug z) => z.toJson()..remove('rolle');

  /// Privat `einflussTafel` des Erzählers: wer in der laufenden Runde was spielte (in den Gesprächen die
  /// schon gesetzten Züge, nach den Folgen alle, Bots markiert). Nie Tipps, Pfad oder Güte; ab dem Finale
  /// nicht mehr (dann zeigt die Auflösung das Protokoll der Nacht). Vor Runde 1 `null`.
  Map<String, Object?>? tafel(RundenPartie p) {
    final r = p.runde;
    if (r < 1 || p.phase.index >= PartyPhase.finale.index) return null;
    final s = p.einfluss!.stand;
    final f = s.folgenVon(r);
    final zeilen = f?.tafel ?? [for (final b in s.besetzt) if (s.zug(r, b) case final z?) ZugTafelZeile(b, z.art, z.ziel)];
    return {'runde': r, 'ausgewertet': f != null, 'zuege': [for (final t in zeilen) _zeile(r, t)]};
  }

  Map<String, Object?> _zeile(int runde, ZugTafelZeile t) => {...t.toJson(), if (botsIn(runde).contains(t.rolle)) 'bot': true};

  /// Zusätzliche Felder der Ansicht `zug` mit Schicht: Tischwert der Option, „Die Spur verwischt“, die
  /// Kennzeichen des Fundes und im Wurf die Zeile „Tisch“ der Chancenvorschau (`tischVorschau`).
  Map<String, Object?> zugFelder(RundenPartie p, RundenZug z) {
    final vorschau = z.phase == RundenZugPhase.wurf ? p.tischVorschau() : null;
    return {
      'tisch': ?z.tisch,
      'verwischt': z.verwischt,
      'einfluss': ?z.einfluss?.toJson(),
      if (vorschau != null) 'tischVorschau': {'tisch': vorschau.tisch, 'umweg': vorschau.umweg},
    };
  }

  /// `aufloesung.einfluss` ab dem Finale: Protokoll der Nacht (alle Züge, Bots markiert), Sterne und Stand
  /// je Ziel, Tipps, Auszeichnungen, Leisten, Tischbonus, Endwert, Morgen und Ertappte.
  Map<String, Object?> aufloesung(RundenPartie p) {
    final e = p.einfluss!;
    final s = e.stand;
    return {
      'protokoll': [
        for (final f in s.folgen) {'runde': f.runde, 'zuege': [for (final t in f.tafel) _zeile(f.runde, t)]},
      ],
      'sterne': e.sterne(),
      'ziele': {
        for (final b in s.besetzt) b: [for (final z in e.zielStaende(b)) {'nr': z.ziel.nr, 'id': z.ziel.id, 'stand': z.stand.name}],
      },
      'tipps': s.tipps,
      'auszeichnungen': e.auszeichnungen().toJson(),
      'leisten': {'zusammenhalt': s.zusammenhalt, 'spuk': s.spuk},
      'tischbonus': s.tischbonus,
      'endwert': p.spiel.endwert,
      'morgen': s.morgen.name,
      'ertappt': s.ertappt,
    };
  }
}
