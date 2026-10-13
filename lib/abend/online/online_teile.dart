import 'package:flutter/material.dart';
import 'package:mordakte_core/mordakte_core.dart' show LookDef, renderLook;

import '../../party/daten.dart';
import '../../stil/mappe/online_bausteine.dart';
import '../../stil/stil.dart';

/// Gemeinsame Teile der Online-Bildschirme in der Ermittlungsmappe: Karteikarte
/// eines Platzes am Tisch, Wartezettel mit Taschenuhr, Hinweiskarte und der
/// Kopf eines Registers auf dem Schreibtisch.

/// Warnfarbe als Tinte auf Papier (getrennt, pausiert); hell genug ist sie nur
/// auf dem Schreibtisch.
const onlineWarnTinte = Color(0xFF9A5B12);

final _aussehen = Expando<Map<String, LookDef?>>();

/// Aussehen einer Figur der Akte für Fotoabzüge; `null`, wenn Akte oder Figur
/// fehlen (dann zeigt die Karte einen Schattenriss).
LookDef? onlineAussehen(PartyDaten? daten, String? id) {
  if (daten == null || id == null || id.isEmpty) return null;
  final cache = _aussehen[daten] ??= {};
  return cache.putIfAbsent(id, () {
    try {
      final f = daten.kanon.figur(id);
      return f == null ? null : LookDef.fromJson(renderLook(f));
    } catch (_) {
      return null;
    }
  });
}

/// Kennung der Detektivfigur der Akte (die Spielleitung spielt sie).
String? onlineDetektivId(PartyDaten? daten) {
  final d = daten?.kanon.figurenJson['detektiv'];
  return d is Map && d['id'] is String ? d['id'] as String : null;
}

/// Stempel für einen erledigten Zustand („Bereit“, „Gelesen“, „Abgestimmt“).
Widget onlineStempel(String text, {Color farbe = mOnlineStempelGruen}) =>
    MStempel(text: text, farbe: farbe, groesse: 13, winkel: -0.1, aufschlagen: true);

/// Kopf eines Registers: Schreibmaschinenzeile über einer Messinglinie. Auf
/// dem Schreibtisch hell, auf Papier in Tinte.
class OnlineRegisterKopf extends StatelessWidget {
  const OnlineRegisterKopf(this.titel, {super.key});

  final String titel;

  @override
  Widget build(BuildContext context) {
    final f = MFarben.von(context);
    final s = MSchrift.von(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: MMass.s12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(titel, style: s.zwischentitel.copyWith(color: f.akzentHell)),
          const SizedBox(height: 6),
          Container(
            height: 1.2,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [MRoh.messingMitte.withValues(alpha: 0.85), MRoh.messingMitte.withValues(alpha: 0)]),
            ),
          ),
        ],
      ),
    );
  }
}

/// Karteikarte eines Platzes am Tisch: Fotoabzug der Figur (oder ein
/// Schattenriss, solange die Rolle unbekannt ist), Name in Playfair, darunter
/// die Figur, rechts der Zustand als Stempel oder Etikett. Die Farbe der Figur
/// läuft als Registerstreifen am linken Rand.
class OnlinePlatzKarte extends StatelessWidget {
  const OnlinePlatzKarte({super.key, required this.name, this.notiz, this.unter, this.look, this.farbe, this.zustand, this.nr = 0});

  final String name;

  /// Randnotiz hinter dem Namen in Füllertinte (z. B. „(Du)“); der Text bleibt
  /// „Name · Notiz“ wie zuvor.
  final String? notiz;
  final String? unter;
  final LookDef? look;
  final Color? farbe;
  final Widget? zustand;

  /// Platz in der Liste: wechselnde Neigung und Papiermuster.
  final int nr;

  @override
  Widget build(BuildContext context) {
    final bild = look != null
        ? MFotoabzug(look: look!, groesse: 52, neigung: nr.isEven ? -0.05 : 0.04, akzent: farbe)
        : MOnlineSilhouette(groesse: 52, neigung: nr.isEven ? -0.05 : 0.04, samen: nr + 1);
    final unterzeile = unter;
    final rand = notiz;
    final namensStil = MPapierSchrift.ueberschrift.copyWith(fontSize: 20);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: MBlatt(
        art: PapierArt.karteikarte,
        kopfLinie: 7,
        linien: false,
        randFarbe: farbe,
        neigung: nr.isEven ? -0.003 : 0.003,
        samen: nr + 3,
        padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
        child: MOnlineBildZeile(
          bild: bild,
          text: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (rand == null)
                Text(name, maxLines: 4, overflow: TextOverflow.ellipsis, style: namensStil)
              else
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: name),
                      const TextSpan(text: ' · '),
                      TextSpan(text: rand, style: MPapierSchrift.hand.copyWith(fontSize: 22, height: 1)),
                    ],
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: namensStil,
                ),
              if (unterzeile != null && unterzeile.isNotEmpty) Text(unterzeile, style: MPapierSchrift.leise),
            ],
          ),
          rechts: zustand,
        ),
      ),
    );
  }
}

/// Reihe von Bots: Fotoabzüge (oder Schattenrisse) mit Stempel, nebeneinander
/// und umbrechend.
class OnlineBotReihe extends StatelessWidget {
  const OnlineBotReihe({super.key, required this.bots, required this.stempel});

  /// Aussehen, Name und Farbe je Bot; ohne Aussehen ein Schattenriss.
  final List<({LookDef? look, String? name, Color? farbe})> bots;
  final String stempel;

  @override
  Widget build(BuildContext context) => Wrap(
        spacing: 14,
        runSpacing: 16,
        children: [
          for (var i = 0; i < bots.length; i++)
            if (bots[i].look case final look?)
              // Der Stempel sitzt schräg über der unteren Ecke, das Gesicht bleibt frei.
              Stack(
                clipBehavior: Clip.none,
                children: [
                  MFotoabzug(
                    look: look,
                    groesse: 60,
                    beschriftung: bots[i].name,
                    akzent: bots[i].farbe,
                    neigung: i.isEven ? -0.04 : 0.035,
                    semantik: [?bots[i].name, stempel].join(', '),
                  ),
                  Positioned(
                    right: -12,
                    bottom: 22,
                    child: ExcludeSemantics(child: MStempel(text: stempel, groesse: 12, winkel: -0.22, aufschlagen: true)),
                  ),
                ],
              )
            else
              MOnlineSilhouette(groesse: 44, stempel: stempel, samen: i + 4, neigung: i.isEven ? -0.04 : 0.035),
        ],
      );
}

/// Getippter Wartezettel mit Taschenuhr: „Warten auf die Spielleitung …“.
/// Mit [stempel] liegt darunter ein grüner Stempel (z. B. „Abgestimmt“).
class OnlineWarteNotiz extends StatelessWidget {
  const OnlineWarteNotiz({
    super.key,
    required this.text,
    this.textKey,
    this.titel,
    this.stempel,
    this.gross = false,
    this.uhr = true,
    this.samen = 11,
  });

  final String text;

  /// Schlüssel des Textes (Tests und Bildschirmleser finden ihn so).
  final Key? textKey;

  /// Formularkopf über dem Text (Schreibmaschine, stempelrot).
  final String? titel;
  final String? stempel;

  /// Text in Playfair statt in Schreibmaschine (Zustand statt Hinweis).
  final bool gross;

  /// Taschenuhr neben dem Text (aus, wenn nichts mehr zu warten ist).
  final bool uhr;
  final int samen;

  @override
  Widget build(BuildContext context) {
    final stil = gross ? MPapierSchrift.ueberschrift.copyWith(fontSize: 20) : MPapierSchrift.maschine.copyWith(fontSize: 17, height: 1.5);
    final kopf = titel;
    final marke = stempel;
    return MBlatt(
      art: PapierArt.notiz,
      neigung: samen.isEven ? 0.004 : -0.004,
      samen: samen,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (kopf != null) ...[
            Text(kopf, style: MPapierSchrift.zwischentitel.copyWith(color: MRoh.stempelRot)),
            const SizedBox(height: 10),
          ],
          Row(
            children: [
              if (uhr) ...[const MOnlineTaschenuhr(groesse: 40), const SizedBox(width: 14)],
              Expanded(child: Text(text, key: textKey, style: stil)),
            ],
          ),
          if (marke != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Align(alignment: Alignment.centerRight, child: MStempel(text: marke, farbe: mOnlineStempelGruen, groesse: 15, aufschlagen: true)),
            ),
        ],
      ),
    );
  }
}

/// Hinweis als Karteikarte: Symbol in Stempelfarbe, Satz in Tinte, darunter
/// optional ein Knopf (Fehler, Verbindungszustand, Rückkehr).
class OnlineHinweisKarte extends StatelessWidget {
  const OnlineHinweisKarte({
    super.key,
    required this.icon,
    required this.text,
    this.farbe = MRoh.stempelRot,
    this.aktion,
    this.art = PapierArt.karteikarte,
    this.neigung = -0.004,
  });

  final IconData icon;
  final String text;
  final Color farbe;
  final Widget? aktion;
  final PapierArt art;
  final double neigung;

  @override
  Widget build(BuildContext context) {
    final knopf = aktion;
    return MBlatt(
      art: art,
      kopfLinie: 7,
      linien: false,
      neigung: neigung,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(padding: const EdgeInsets.only(top: 2), child: Icon(icon, color: farbe, size: 22)),
              const SizedBox(width: MMass.s12),
              Expanded(child: Text(text, style: MPapierSchrift.text)),
            ],
          ),
          if (knopf != null) ...[
            const SizedBox(height: MMass.s12),
            Align(alignment: Alignment.centerLeft, child: knopf),
          ],
        ],
      ),
    );
  }
}

/// Rückfrage als Karteikarte ([MKarteikartenDialog], wie [frageKarteikarte]),
/// deren Text bei wenig Höhe oder großer Schrift rollt, statt überzulaufen.
/// Liefert `true` für [ja], sonst `false` (auch beim Wegtippen).
Future<bool> onlineRueckfrage(
  BuildContext context, {
  required String titel,
  required String text,
  required String ja,
  required String nein,
  bool gefaehrlich = false,
}) async {
  final antwort = await showDialog<bool>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.6),
    builder: (context) => MKarteikartenDialog(
      titel: titel,
      // Der Text rollt in der Karteikarte, die Knöpfe stehen fest darunter.
      text: text,
      aktionen: [
        MKnopf(text: nein, art: MKnopfArt.zweit, onPressed: () => Navigator.of(context).pop(false)),
        MKnopf(text: ja, art: gefaehrlich ? MKnopfArt.gefahr : MKnopfArt.haupt, onPressed: () => Navigator.of(context).pop(true)),
      ],
    ),
  );
  return antwort ?? false;
}

