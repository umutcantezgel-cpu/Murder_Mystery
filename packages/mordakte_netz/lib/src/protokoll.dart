/// Themen und Konstanten des Relais-Protokolls (Version 1).
///
/// ```text
/// Lobby-Thema  mordakte:v1:<CODE>           Gastgeber-Presence-Schlüssel "h"
///   klopf  Gast -> Gastgeber  {cid, pub, proto, app, inhalt}        (Klartext)
///   turm   Gastgeber -> alle  {hpub, epoch, proto, akte, inhalt, offen, plaetze}  (Klartext)
/// Sitz-Thema   mordakte:v1:<CODE>:<cid>     nur Gastgeber und dieser Gast, Ereignis "m"
///   Nachrichten ausschließlich als Umschlag (siehe umschlag.dart)
///   Gast -> Gastgeber  hallo{name,proto,app,r}  befehl{q,c}  sync{v}  ping{v}  tschuess{}
///   Gastgeber -> Gast  willkommen{spieler,raum,epoch,r}  abend{…zustandFuer…}
///                      ok{q}  fehler{q,key}  nein{key}  zu{grund}  pong{v}
/// ```
library;

/// Protokollversion, im `klopf`, `turm` und `hallo` geprüft.
const protokollVersion = 1;

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

/// Ereignisname auf den Sitz-Themen.
const sitzEreignis = 'm';
