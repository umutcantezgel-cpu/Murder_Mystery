import '../../l10n/lookup.dart';

/// Warum ein Beitritt scheitert (Schlüssel des Netzpakets) als lesbarer Satz.
String beitrittsFehlerText(L l, String key) => switch (key) {
      'code' => l.online_fehler_code,
      'relay' => l.online_fehler_relay,
      'kein_raum' => l.online_fehler_kein_raum,
      'zeitueberschreitung' => l.online_fehler_zeit,
      'voll' => l.online_fehler_voll,
      'gestartet' => l.online_fehler_gestartet,
      'proto' => l.online_fehler_proto,
      'inhalt' => l.online_fehler_inhalt,
      _ => l.online_fehler_allgemein,
    };

/// Warum der Raum eine Nachricht ablehnt (feste Schlüssel des Raums und des
/// Transports) als lesbarer Satz.
String befehlsFehlerText(L l, String key) => switch (key) {
      'not_ready' => l.online_fehler_nicht_bereit,
      'not_dice_player' => l.online_fehler_nicht_dran,
      'invalid_phase' || 'game_running' || 'not_started' || 'stale' => l.online_fehler_phase,
      'already_voted' => l.online_fehler_schon_gewaehlt,
      // Sitze (Langer Abend M3): Start ohne Detektiv, Ermittlung nur vom Detektiv-Sitz, Weiter nur, wer leitet.
      'seats' => l.online_fehler_sitze,
      'not_detective' => l.online_fehler_nur_detektiv,
      'not_host' => l.online_fehler_nicht_leitung,
      'zeitueberschreitung' || 'getrennt' || 'geschlossen' => l.online_fehler_keine_antwort,
      _ => l.online_fehler_allgemein,
    };
