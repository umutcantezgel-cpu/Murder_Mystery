import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../abend/abend_halter.dart';
import '../abend/abend_seite.dart';
import '../abend/belohnung_seite.dart';
import '../abend/einrichtung/abend_neu_seite.dart';
import '../abend/online/beitreten_seite.dart';
import '../abend/online/gast_seite.dart';
import '../abend/online/gastgeber_lobby.dart';
import '../abend/online/online_halter.dart';
import '../detektei/akte_seite.dart';
import '../detektei/detektei_seite.dart';
import '../detektei/druckmappe_seite.dart';
import '../detektei/sammlung_seite.dart';
import '../detektei/steckbrief_seite.dart';
import '../krimidinner/gewoelbe_seite.dart';
import '../karten/deck_seite.dart';
import '../party/ebenen_vorschau.dart';
import '../party/party_seite.dart';
import '../party/skript.dart';
import '../stil/tokens.dart';
import '../ui/screens/cases_screen.dart';
import '../ui/screens/collection_screen.dart';
import '../ui/screens/game_screen.dart';
import '../ui/screens/hub_screen.dart';
import '../ui/screens/lobby_screen.dart';
import '../ui/screens/online_screen.dart';
import '../ui/screens/profile_screen.dart';
import 'app_state.dart';

/// Routen des Spiels.
///
/// Das Spiel ist ein Spiel: Start ist die Detektei (`/`), von dort führen
/// Akten, der Assistent für neue Abende, die Sammlung und das Profil weiter.
/// Die übrigen Routen (klassische Fälle, Online, Gewölbe-Begleiter, alter
/// Partystart `/party`) gehören nicht zur Navigation des Spiels; sie bleiben
/// für Entwickler und die Browserprüfungen über URL-Parameter erreichbar.
abstract final class Routes {
  /// Die Detektei: Start des Spiels.
  static const detektei = '/';

  /// Einstieg der App ohne Parameter.
  static const start = detektei;

  /// Rücksprung der klassischen Bildschirme: ebenfalls die Detektei.
  static const hub = detektei;

  /// Alter Hub der klassischen Fälle (nur `?screen=hub`).
  static const klassik = '/hub';

  static const akte = '/akte/:id';
  static String akteVon(String id) => '/akte/$id';
  static const druckmappe = '/akte/:id/druck';
  static String druckmappeVon(String id) => '/akte/$id/druck';

  /// Steckbriefe und Charakterübersicht einer Akte (M5), ohne Einrichtung und Fall-Code.
  static const steckbriefe = '/akte/:id/steckbriefe';
  static String steckbriefeVon(String id) => '/akte/$id/steckbriefe';

  /// Assistent für einen neuen Abend; `?akte=<id>` wählt die Akte vor.
  static const abendNeu = '/abend/neu';
  static String abendNeuMit(String id) => '/abend/neu?akte=$id';

  /// Der laufende Abend (Schlosskeller-Runden).
  static const abend = '/abend';

  /// Lobby des Gastgebers eines Online-Abends („Jeder am eigenen Gerät“): Raumcode,
  /// QR-Code, Gäste, Rollen. Ohne geöffneten Raum führt sie in die Detektei zurück.
  static const abendLobby = '/abend/lobby';

  /// Einem Online-Abend beitreten; `?raum=<CODE>` füllt den Raumcode vor (QR-Code).
  static const beitreten = '/beitreten';
  static String beitretenMit(String code) => '/beitreten?raum=$code';

  /// Der Abend auf dem Gerät eines Gastes (nur mit bestehender Verbindung).
  static const gast = '/gast';

  /// Belohnung nach dem Abend: Karten, Erfahrung, Rang (nur nach einem beendeten Abend).
  static const abendBelohnung = '/abend/belohnung';
  static const sammlung = '/sammlung';

  /// Deck-Bau der Sammlung (drei Plätze).
  static const sammlungDeck = '/sammlung/deck';
  static const profile = '/profile';

  // Entwickler- und Altrouten.
  static const cases = '/cases';
  static const collection = '/collection';
  static const online = '/online';
  static const lobby = '/lobby';
  static const game = '/game';
  static const party = '/party';
  static const ebenen = '/ebenen';
  static const gewoelbe = '/gewoelbe';
}

CustomTransitionPage<void> _fade(BuildContext context, GoRouterState state, Widget child) {
  final ruhig = MBewegung.ruhig(context);
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: ruhig ? Duration.zero : const Duration(milliseconds: 380),
    reverseTransitionDuration: ruhig ? Duration.zero : const Duration(milliseconds: 260),
    transitionsBuilder: (context, animation, secondary, child) {
      if (ruhig) return child;
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween(begin: const Offset(0, 0.03), end: Offset.zero).animate(curved),
          child: child,
        ),
      );
    },
  );
}

/// Hält die System-Zurück-Taste (Android) in der App: Die Seiten der obersten
/// Ebene liegen allein im Navigator (der Wechsel läuft über `go`), die Taste
/// würde sonst die App schließen. Sie führt stattdessen nach [ziel]; liegt unter
/// der Seite eine andere (Deck-Bau per `push`), schließt sie nur die Seite.
Widget _zurueckNach(String ziel, Widget seite) => Builder(
  builder: (context) => PopScope(
    canPop: false,
    onPopInvokedWithResult: (didPop, _) {
      if (didPop) return;
      if (context.canPop()) {
        context.pop();
      } else {
        context.go(ziel);
      }
    },
    child: seite,
  ),
);

GoRouter buildRouter(AppState app, {String initialLocation = Routes.start, AbendHalter? abend, OnlineHalter? online}) => GoRouter(
  initialLocation: initialLocation,
  refreshListenable: app,
  redirect: (context, state) {
    final loc = state.matchedLocation;
    if ((loc == Routes.lobby || loc == Routes.game) && app.session == null) return Routes.start;
    // Ohne laufenden Abend gibt es keine Abendseite (z. B. nach dem Neuladen).
    if (loc == Routes.abend && abend != null && !abend.laeuft) return Routes.start;
    // Die Belohnung gibt es nur direkt nach einem beendeten Abend.
    if (loc == Routes.abendBelohnung && abend != null && abend.abschluss == null) return Routes.start;
    // Lobby und Gastseite gibt es nur mit einer bestehenden Online-Verbindung.
    if (loc == Routes.abendLobby && online != null && online.dienst == null) return Routes.start;
    if (loc == Routes.gast && online != null && online.gast == null) return Routes.start;
    return null;
  },
  routes: [
    GoRoute(path: Routes.detektei, pageBuilder: (c, s) => _fade(c, s, const DetekteiSeite())),
    GoRoute(
      path: Routes.akte,
      pageBuilder: (c, s) => _fade(c, s, _zurueckNach(Routes.start, AkteSeite(akteId: s.pathParameters['id'] ?? ''))),
    ),
    GoRoute(
      path: Routes.druckmappe,
      pageBuilder: (c, s) {
        final id = s.pathParameters['id'] ?? '';
        return _fade(c, s, _zurueckNach(Routes.akteVon(id), DruckmappeSeite(akteId: id)));
      },
    ),
    GoRoute(
      path: Routes.steckbriefe,
      pageBuilder: (c, s) {
        final id = s.pathParameters['id'] ?? '';
        return _fade(c, s, _zurueckNach(Routes.akteVon(id), SteckbriefSeite(akteId: id)));
      },
    ),
    GoRoute(
      path: Routes.abendNeu,
      pageBuilder: (c, s) => _fade(c, s, AbendNeuSeite(akteId: s.uri.queryParameters['akte'])),
    ),
    GoRoute(
      path: Routes.abend,
      pageBuilder: (c, s) => _fade(c, s, const AbendSeite()),
      // Solo und reihum fragt das Verlassen nach (auch die Browser-Zurück-Taste); die Belohnung ist ausgenommen.
      onExit: (c, s) => abend == null ? true : abendVerlassen(c, abend),
    ),
    GoRoute(path: Routes.abendLobby, pageBuilder: (c, s) => _fade(c, s, const GastgeberLobbySeite())),
    GoRoute(
      path: Routes.beitreten,
      pageBuilder: (c, s) => _fade(c, s, _zurueckNach(Routes.start, BeitretenSeite(raum: s.uri.queryParameters['raum']))),
    ),
    GoRoute(path: Routes.gast, pageBuilder: (c, s) => _fade(c, s, const GastSeite())),
    GoRoute(path: Routes.abendBelohnung, pageBuilder: (c, s) => _fade(c, s, const BelohnungSeite())),
    GoRoute(path: Routes.sammlung, pageBuilder: (c, s) => _fade(c, s, _zurueckNach(Routes.start, const SammlungSeite()))),
    GoRoute(path: Routes.sammlungDeck, pageBuilder: (c, s) => _fade(c, s, _zurueckNach(Routes.sammlung, const DeckSeite()))),
    GoRoute(path: Routes.profile, pageBuilder: (c, s) => _fade(c, s, _zurueckNach(Routes.start, const ProfileScreen()))),
    // Entwickler- und Altrouten (nicht im Menü).
    GoRoute(path: Routes.klassik, pageBuilder: (c, s) => _fade(c, s, const HubScreen())),
    GoRoute(path: Routes.cases, pageBuilder: (c, s) => _fade(c, s, const CasesScreen())),
    GoRoute(path: Routes.collection, pageBuilder: (c, s) => _fade(c, s, const CollectionScreen())),
    GoRoute(path: Routes.online, pageBuilder: (c, s) => _fade(c, s, const OnlineScreen())),
    GoRoute(path: Routes.lobby, pageBuilder: (c, s) => _fade(c, s, const LobbyScreen())),
    GoRoute(path: Routes.game, pageBuilder: (c, s) => _fade(c, s, const GameScreen())),
    GoRoute(path: Routes.party, pageBuilder: (c, s) => _fade(c, s, PartySeite(dev: PartyDev.ausUrl(_query)))),
    GoRoute(path: Routes.ebenen, pageBuilder: (c, s) => _fade(c, s, EbenenVorschauSeite.ausUrl(_query))),
    GoRoute(path: Routes.gewoelbe, pageBuilder: (c, s) => _fade(c, s, GewoelbeSeite.ausUrl(_query))),
  ],
);

Map<String, String> get _query {
  try {
    return Uri.base.queryParameters;
  } catch (_) {
    return const {};
  }
}
