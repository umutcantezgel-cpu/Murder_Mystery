import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mordakte_core/mordakte_core.dart' show LookDef;
import 'package:mordakte_core/runden.dart' show KartenKatalog, Sitz;
import 'package:provider/provider.dart';

import '../../abend/einrichtung/klasse_zeile.dart';
import '../../l10n/lookup.dart';
import '../../meta/meta_store.dart';
import '../../party/daten.dart';
import '../../stil/mappe/assistent_formular.dart' show MAnkreuzWahl;
import '../../stil/mappe/online_bausteine.dart';
import '../../stil/stil.dart';
import 'ansicht.dart';
import 'online_teile.dart';

/// Schickt eine Raumnachricht der Lobby; Ablehnungen meldet der Aufrufer.
typedef LobbyBefehl = Future<void> Function(Map<String, Object?> nachricht);

/// Gästeliste der Akte (Langer Abend M5): Name → Figur, falls dieses Gerät eine
/// kennt; sonst leer. Die Lobby schlägt damit die Zuteilung vor. Solange M5
/// nicht verdrahtet ist, liefert der Haken nichts; die Verdrahtung setzt ihn auf
/// `context.read<MetaStore>().gaesteliste(akte).figurJeName`.
typedef GaesteVorschlag = Map<String, String> Function(BuildContext context, String akte);

/// Der Haken für die Gästeliste ([GaesteVorschlag]); ohne Gästeliste leer.
GaesteVorschlag gaesteVorschlag = (_, _) => const {};

/// Die Lobby aus der Ansicht des Raums (Langer Abend M3): Plätze mit Sitz,
/// zugeteilter Figur und Wunsch, die Rollenzahl im Raum und was dieses Gerät
/// darf. Rein lesend; Änderungen gehen als Nachrichten `sitz`, `besetzung`,
/// `zuteilen` und `wunsch` an den Raum.
class LobbyStand {
  LobbyStand({required this.spieler, required this.rollen, required this.daten, required this.ichId});

  /// Aus der Ansicht `zustandFuer` (Lobby) dieses Geräts [ichId].
  factory LobbyStand.aus(Map<String, Object?> ansicht, PartyDaten daten, String ichId) => LobbyStand(
        spieler: spielerAusAnsicht(ansicht),
        rollen: ansicht['rollen'] is int ? ansicht['rollen'] as int : null,
        daten: daten,
        ichId: ichId,
      );

  final List<SpielerInfo> spieler;

  /// Rollenzahl im Raum (`besetzung`), sonst `null`.
  final int? rollen;
  final PartyDaten daten;
  final String ichId;

  /// Rollenzahl, wenn noch niemand eine festgelegt hat.
  static const vorgabe = 7;

  int get minRollen => daten.texte.besetzung.minRollen;
  int get maxRollen => daten.texte.besetzung.maxRollen;

  /// Geräte ohne Sitz: Sie bekommen beim Start eine Figur, soweit die Rollen reichen.
  List<SpielerInfo> get ohneSitz => [for (final s in spieler) if (s.sitz == null) s];

  /// Mindestens so viele Rollen wie Geräte ohne Sitz, höchstens die Besetzung der Akte.
  int get min => math.max(minRollen, math.min(ohneSitz.length, maxRollen));
  int get max => maxRollen;

  /// Die Rollenzahl, mit der der Abend startet.
  int get anzahl => (rollen ?? vorgabe).clamp(min, max).toInt();

  /// Muss die Rollenzahl im Raum nachziehen (zu klein für die Gäste, noch keine)?
  bool get rollenNachziehen => rollen != anzahl;

  /// Die besetzten Figuren bei [anzahl] (feste Besetzungsreihenfolge).
  List<String> get besetzt => daten.texte.besetzung.besetzt(anzahl);

  SpielerInfo? get ich => _platz(ichId);
  SpielerInfo? get gastgeber => spieler.where((s) => s.istGastgeber).firstOrNull;
  SpielerInfo? get detektiv => spieler.where((s) => s.sitz == Sitz.detektiv).firstOrNull;
  SpielerInfo? get erzaehler => spieler.where((s) => s.sitz == Sitz.erzaehler).firstOrNull;

  SpielerInfo? _platz(String id) => spieler.where((s) => s.id == id).firstOrNull;

  /// Darf dieses Gerät Sitze vergeben? Nur der Gastgeber.
  bool get ichVergebeSitze => ich?.istGastgeber ?? false;

  /// Darf dieses Gerät Rollenzahl und Figuren festlegen? Gastgeber, Detektiv- und Erzähler-Sitz.
  bool get ichTeileZu => (ich?.istGastgeber ?? false) || ich?.sitz != null;

  /// Kennt die Akte einen Erzähler-Sitz?
  bool get erzaehlerMoeglich => daten.mitErzaehlerSitz;

  /// Ist die Lobby startklar? Es braucht einen Detektiv, und der Gastgeber sitzt.
  bool get sitzeKlar => detektiv != null && gastgeber?.sitz != null;

  /// Gerät, dem [figur] zugeteilt ist, sonst `null`.
  SpielerInfo? inhaberVon(String figur) => spieler.where((s) => s.figur == figur).firstOrNull;

  /// Geräte, die sich [figur] wünschen.
  List<SpielerInfo> wuenschenSich(String figur) => [for (final s in spieler) if (s.wunsch == figur) s];

  /// Zuteilungen aus der Gästeliste ([gaesteVorschlag]): Gast ohne Sitz und ohne
  /// Figur, dessen Name dort mit einer besetzten Figur steht, die noch frei ist.
  Map<String, String> vorschlagAus(Map<String, String> figurJeName) {
    final frei = {for (final f in besetzt) if (inhaberVon(f) == null) f};
    final namen = {for (final e in figurJeName.entries) e.key.trim().toLowerCase(): e.value};
    final ergebnis = <String, String>{};
    for (final s in ohneSitz) {
      final f = namen[s.name.trim().toLowerCase()];
      if (s.figur == null && f != null && frei.remove(f)) ergebnis[s.id] = f;
    }
    return ergebnis;
  }
}

/// Wie ein Platz in der Lobby heißt: Sitz, sonst zugeteilte Figur oder Zufall,
/// dazu der Wunsch; beim Gastgeber „Gastgeber“.
String lobbyUnterzeile(L l, LobbyStand stand, SpielerInfo s) {
  final teile = <String>[
    switch (s.sitz) {
      Sitz.detektiv => l.abend_platz_detektiv,
      Sitz.erzaehler => l.abend_platz_erzaehler,
      _ => s.figur != null ? figurName(stand.daten, s.figur!) : l.online_lobby_zufall,
    },
    if (s.sitz == null && s.wunsch != null && s.wunsch != s.figur) l.online_lobby_wunsch(figurName(stand.daten, s.wunsch!)),
    if (s.istGastgeber) l.online_lobby_gastgeber,
  ];
  return teile.join(' · ');
}

/// Name einer Figur der Akte, sonst die Kennung.
String figurName(PartyDaten daten, String id) {
  final n = daten.kanon.figur(id)?['name'];
  return n is String ? n : id;
}

/// Aussehen eines Platzes: die Figur des Detektivs auf dem Detektiv-Sitz, sonst
/// die zugeteilte Figur; Erzähler und Zufall bleiben Schattenriss.
LookDef? lobbyAussehen(LobbyStand stand, SpielerInfo s) => switch (s.sitz) {
      Sitz.detektiv => onlineAussehen(stand.daten, onlineDetektivId(stand.daten)),
      Sitz.erzaehler => null,
      _ => onlineAussehen(stand.daten, s.figur),
    };

/// Die Plätze der Lobby als Gästeregister. Wer zuteilen darf, tippt einen Platz
/// an und wählt Sitz und Figur ([zeigeLobbyWahl]).
class LobbyTisch extends StatelessWidget {
  const LobbyTisch({super.key, required this.stand, required this.befehl, this.fuss});

  final LobbyStand stand;
  final LobbyBefehl befehl;

  /// Unter dem Register (Wartezettel „alle bereit“ o. Ä.).
  final Widget? fuss;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final spieler = stand.spieler;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OnlineRegisterKopf('${l.online_tisch_titel} (${spieler.length})'),
        for (var i = 0; i < spieler.length; i++) LobbyPlatz(stand: stand, spieler: spieler[i], nr: i, befehl: befehl),
        const SizedBox(height: MMass.s4),
        ?fuss,
      ],
    );
  }
}

/// Ein Platz der Lobby: Fotoabzug (Detektiv, zugeteilte Figur, sonst
/// Schattenriss), Name, darunter Sitz oder Figur und Wunsch, rechts der
/// Zustand. Darf dieses Gerät zuteilen, ist die Karte eine Tippfläche.
class LobbyPlatz extends StatelessWidget {
  const LobbyPlatz({super.key, required this.stand, required this.spieler, required this.nr, required this.befehl});

  final LobbyStand stand;
  final SpielerInfo spieler;
  final int nr;
  final LobbyBefehl befehl;

  /// Darf dieses Gerät hier etwas ändern? Sitze nur der Gastgeber, Figuren
  /// zusätzlich Detektiv und Erzähler, und nur für Plätze ohne Sitz.
  bool get _antippbar => stand.ichVergebeSitze || (stand.ichTeileZu && spieler.sitz == null);

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final s = spieler;
    // Der Gastgeber startet den Abend; „bereit“ gibt es für ihn nicht (seine Zeile sagt „Gastgeber“).
    final Widget? zustand = !s.online
        ? MChip(l.online_getrennt, icon: Icons.wifi_off_rounded, farbe: onlineWarnTinte)
        : s.istGastgeber
            ? null
            : s.bereit
            ? onlineStempel(l.online_bereit)
            : MChip(l.online_nicht_bereit, icon: Icons.hourglass_empty_rounded, farbe: MRoh.tinteLeise);
    final karte = OnlinePlatzKarte(
      name: s.name,
      notiz: s.id == stand.ichId ? '(${l.common_you})' : null,
      unter: lobbyUnterzeile(l, stand, s),
      look: lobbyAussehen(stand, s),
      zustand: zustand,
      nr: nr,
    );
    if (!_antippbar) return KeyedSubtree(key: ValueKey('lobby-platz-${s.id}'), child: karte);
    return Semantics(
      button: true,
      hint: l.online_lobby_wahl_hinweis,
      child: GestureDetector(
        key: ValueKey('lobby-platz-${s.id}'),
        behavior: HitTestBehavior.opaque,
        onTap: () => zeigeLobbyWahl(context, stand: stand, spieler: s, befehl: befehl),
        child: karte,
      ),
    );
  }
}

/// Karteikarte „Platz und Figur“ für [spieler]: Der Gastgeber setzt den Sitz
/// (Detektiv, Erzähler oder eine Figur spielen); wer zuteilen darf, wählt die
/// Figur oder Zufall. Jede Wahl geht sofort an den Raum; die Karte schließt.
Future<void> zeigeLobbyWahl(BuildContext context, {required LobbyStand stand, required SpielerInfo spieler, required LobbyBefehl befehl}) {
  final l = L.of(context);
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.6),
    builder: (c) {
      void senden(Map<String, Object?> nachricht) {
        Navigator.of(c).pop();
        unawaited(befehl(nachricht));
      }

      return MKarteikartenDialog(
        titel: l.online_lobby_wahl_titel(spieler.name),
        inhalt: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (stand.ichVergebeSitze) ...[
              Text(l.online_lobby_platz.toUpperCase(), style: MPapierSchrift.marke),
              const SizedBox(height: MMass.s4),
              MAnkreuzWahl<Sitz?>(
                optionen: [
                  (Sitz.detektiv, l.abend_platz_detektiv),
                  if (stand.erzaehlerMoeglich) (Sitz.erzaehler, l.abend_platz_erzaehler),
                  // Der Gastgeber hält Salz und Pfad; eine Figur spielt er nie.
                  if (!spieler.istGastgeber) (null, l.online_lobby_figur_spielen),
                ],
                gewaehlt: spieler.sitz,
                onWahl: (sitz) {
                  if (sitz == spieler.sitz) return;
                  senden({'typ': 'sitz', 'spieler': spieler.id, 'sitz': sitz?.name});
                },
              ),
              const SizedBox(height: MMass.s16),
            ],
            if (spieler.sitz == null && stand.ichTeileZu) ...[
              Text(l.online_lobby_figur.toUpperCase(), style: MPapierSchrift.marke),
              const SizedBox(height: MMass.s8),
              FigurWahl(
                stand: stand,
                gewaehlt: spieler.figur,
                fuer: spieler.id,
                onWahl: (figur) => senden({'typ': 'zuteilen', 'spieler': spieler.id, 'rolle': figur}),
              ),
            ],
          ],
        ),
        aktionen: [MKnopf(text: l.common_close, art: MKnopfArt.zweit, onPressed: () => Navigator.of(c).pop())],
      );
    },
  );
}

/// Die besetzten Figuren als Fotoabzüge zur Wahl, dazu „Zufall“. Eine Figur, die
/// schon ein anderes Gerät hat, nennt dessen Namen (wer sie wählt, tauscht);
/// Wünsche stehen leise darunter. [onWahl] bekommt `null` für Zufall.
class FigurWahl extends StatelessWidget {
  const FigurWahl({super.key, required this.stand, required this.gewaehlt, required this.onWahl, this.fuer, this.zufallText});

  final LobbyStand stand;

  /// Die gewählte Figur, `null` für Zufall.
  final String? gewaehlt;

  /// Gerät, für das gewählt wird (seine eigene Figur gilt nicht als vergeben).
  final String? fuer;
  final ValueChanged<String?> onWahl;

  /// Beschriftung für „keine Figur“ (Vorgabe: „Zufall“).
  final String? zufallText;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return Wrap(
      spacing: MMass.s12,
      runSpacing: MMass.s12,
      children: [
        _FigurKachel(
          key: const ValueKey('figur-zufall'),
          name: zufallText ?? l.online_lobby_zufall,
          look: null,
          gewaehlt: gewaehlt == null,
          onTap: () => onWahl(null),
        ),
        for (final f in stand.besetzt)
          _FigurKachel(
            key: ValueKey('figur-$f'),
            name: figurName(stand.daten, f),
            look: onlineAussehen(stand.daten, f),
            gewaehlt: gewaehlt == f,
            vermerk: [
              if (stand.inhaberVon(f) case final i? when i.id != fuer) l.online_lobby_vergeben(i.name),
              for (final w in stand.wuenschenSich(f))
                if (w.id != fuer || stand.ichId != fuer) l.online_lobby_wunsch(w.name),
            ].join(' · '),
            onTap: () => onWahl(f),
          ),
      ],
    );
  }
}

/// Eine Figur zur Wahl: Fotoabzug (oder Schattenriss für Zufall), Name und ein
/// leiser Vermerk; die gewählte trägt einen roten Rahmen.
class _FigurKachel extends StatelessWidget {
  const _FigurKachel({super.key, required this.name, required this.look, required this.gewaehlt, required this.onTap, this.vermerk = ''});

  final String name;
  final LookDef? look;
  final bool gewaehlt;
  final String vermerk;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bild = look != null ? MFotoabzug(look: look!, groesse: 56) : MOnlineSilhouette(groesse: 56, samen: name.length);
    return Semantics(
      button: true,
      selected: gewaehlt,
      label: vermerk.isEmpty ? name : '$name, $vermerk',
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          width: 104,
          constraints: const BoxConstraints(minHeight: MMass.tippflaeche),
          padding: const EdgeInsets.all(MMass.s4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: gewaehlt ? MRoh.tinteBlau.withValues(alpha: 0.06) : Colors.transparent,
            border: Border.all(color: gewaehlt ? MRoh.stempelRot : MRoh.tinte.withValues(alpha: 0.2), width: gewaehlt ? 2 : 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              bild,
              const SizedBox(height: MMass.s4),
              MGanzeWorte(name, stil: MPapierSchrift.text.copyWith(fontSize: 14), minimum: 10),
              if (vermerk.isNotEmpty) Text(vermerk, textAlign: TextAlign.center, style: MPapierSchrift.leise.copyWith(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Zahl der Rollen als Besetzungsblatt: mindestens so viele wie Geräte ohne
/// Sitz, höchstens die Besetzung der Akte. Freie Rollen übernehmen Bots; je Bot
/// liegt ein gestempelter Schattenriss auf dem Blatt. Ohne [onAendern] nur zum
/// Lesen (Gäste ohne Sitz).
class LobbyRollenTafel extends StatelessWidget {
  const LobbyRollenTafel({super.key, required this.stand, this.onAendern});

  final LobbyStand stand;
  final ValueChanged<int>? onAendern;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final anzahl = stand.anzahl, min = stand.min, max = stand.max;
    final aendern = onAendern;
    final bots = (anzahl - stand.ohneSitz.length).clamp(0, anzahl).toInt();
    final gesperrt = MRoh.tinte.withValues(alpha: 0.28);
    return MBlatt(
      neigung: 0.004,
      samen: 29,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l.online_rollen_titel, style: MPapierSchrift.zwischentitel.copyWith(color: MRoh.stempelRot)),
          const SizedBox(height: 4),
          Container(height: 1, color: MRoh.tinte.withValues(alpha: 0.3)),
          const SizedBox(height: MMass.s12),
          Semantics(container: true, child: Text(l.online_rollen_anzahl(anzahl), textAlign: TextAlign.center, style: MPapierSchrift.titel)),
          if (aendern != null)
            Row(
              children: [
                IconButton(
                  tooltip: l.online_rollen_weniger,
                  onPressed: anzahl > min ? () => aendern(anzahl - 1) : null,
                  icon: const Icon(Icons.remove_circle_outline),
                  color: MRoh.tinte,
                  disabledColor: gesperrt,
                ),
                Expanded(
                  child: min >= max
                      ? const SizedBox.shrink()
                      : Slider(
                          value: anzahl.toDouble(),
                          min: min.toDouble(),
                          max: max.toDouble(),
                          divisions: max - min,
                          activeColor: MRoh.stempelRot,
                          inactiveColor: MRoh.tinte.withValues(alpha: 0.18),
                          thumbColor: MRoh.messingMitte,
                          semanticFormatterCallback: (v) => l.online_rollen_anzahl(v.round()),
                          onChanged: (v) => aendern(v.round()),
                        ),
                ),
                IconButton(
                  tooltip: l.online_rollen_mehr,
                  onPressed: anzahl < max ? () => aendern(anzahl + 1) : null,
                  icon: const Icon(Icons.add_circle_outline),
                  color: MRoh.tinte,
                  disabledColor: gesperrt,
                ),
              ],
            ),
          const SizedBox(height: MMass.s4),
          Text(l.online_rollen_bots(bots), style: MPapierSchrift.text),
          if (bots > 0) ...[
            const SizedBox(height: MMass.s16),
            OnlineBotReihe(bots: [for (var i = 0; i < bots; i++) (look: null, name: null, farbe: null)], stempel: l.online_bot_stempel),
          ],
          if (aendern != null) ...[
            const SizedBox(height: MMass.s16),
            Text(l.online_rollen_hinweis, style: MPapierSchrift.leise),
          ],
        ],
      ),
    );
  }
}

/// Die Klasse des Detektiv-Sitzes (M6.4): nur auf dem Gerät, das ermittelt. Die
/// Wahl liegt wie bisher im [MetaStore] dieses Geräts; weicht sie von der
/// Klasse im Raum ([klasseImRaum]) ab, geht sie mit `sitz` an den Raum (sie
/// reist mit dem Sitz). Ohne MetaStore (Tests) nichts.
class LobbyKlasse extends StatefulWidget {
  const LobbyKlasse({super.key, required this.ichId, required this.klasseImRaum, required this.befehl, this.karte = false, this.katalog});

  final String ichId;
  final String? klasseImRaum;
  final LobbyBefehl befehl;
  final bool karte;
  final KartenKatalog? katalog;

  @override
  State<LobbyKlasse> createState() => _LobbyKlasseState();
}

class _LobbyKlasseState extends State<LobbyKlasse> {
  /// Zuletzt gesendete Klasse (je Wert nur einmal, bis der Raum sie trägt).
  String? _gesendet;

  @override
  Widget build(BuildContext context) {
    final meta = context.watch<MetaStore?>();
    if (meta == null) return const SizedBox.shrink();
    final klasse = meta.loadout.cls;
    if (klasse != widget.klasseImRaum && klasse != _gesendet) {
      _gesendet = klasse;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) unawaited(widget.befehl({'typ': 'sitz', 'spieler': widget.ichId, 'sitz': Sitz.detektiv.name, 'klasse': klasse}));
      });
    }
    return KlasseZeile(karte: widget.karte, katalog: widget.katalog);
  }
}
