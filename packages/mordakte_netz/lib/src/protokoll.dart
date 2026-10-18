/// Themen und Konstanten des Relais-Protokolls (Version 1).
///
/// ```text
/// Lobby-Thema  mordakte:v1:<CODE>           Gastgeber-Presence-Schlüssel "h"
///   klopf  Gast -> Gastgeber  {cid, pub, proto, app, inhalt}        (Klartext)
///   turm   Gastgeber -> alle  {hpub, epoch, proto, akte, inhalt, offen, plaetze}  (Klartext)
/// Sitz-Thema   mordakte:v1:<CODE>:<cid>     nur Gastgeber und dieser Gast, Ereignis "m"
///   Nachrichten ausschließlich als Umschlag (siehe umschlag.dart)
///   Gast -> Gastgeber  hallo{name,proto,app,r,inhalt}  befehl{q,c}  sync{v}  ping{v}  tschuess{}
///   Gastgeber -> Gast  willkommen{spieler,raum,epoch,r}  abend{…zustandFuer…}
///                      ok{q}  fehler{q,key}  nein{key}  zu{grund[,r]}  pong{v}
/// ```
library;

/// Protokollversion, im `klopf`, `turm` und `hallo` geprüft. Version 2 (A-051):
/// Befragungen im Schlosskeller (`befragen`, `erledigt`, Ansichten `befragungen`
/// und `tisch`); ein Gerät mit Version 1 kennt sie nicht und wird abgewiesen.
const protokollVersion = 2;

/// Presence-Schlüssel des Gastgebers auf allen seinen Themen.
const hostPresenceKey = 'h';

/// Lobby-Thema eines Raums (ohne `realtime:`-Präfix).
String lobbyThema(String code) => 'mordakte:v1:$code';

/// Sitz-Thema eines Gastes im Raum.
String sitzThema(String code, String cid) => 'mordakte:v1:$code:$cid';

/// Spieler-ID eines Gastes im Raum.
String spielerIdVon(String cid) => 'g_$cid';

/// Wie lange ein Gast offline sein darf, bevor der Gastgeber ihn aus dem Raum nimmt.
const offlineFristStandard = Duration(seconds: 120);

/// Wie lange ein angemeldeter Gast ohne beglaubigten Umschlag bleiben darf, bevor
/// der Gastgeber ihn trotz Presence als offline führt (Pings kommen alle 20 s).
const umschlagFristStandard = Duration(seconds: 50);

/// Ereignisname auf den Sitz-Themen.
const sitzEreignis = 'm';
