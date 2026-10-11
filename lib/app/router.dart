import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../abend/abend_halter.dart';
import '../abend/abend_seite.dart';
import '../abend/belohnung_seite.dart';
import '../abend/einrichtung/abend_neu_seite.dart';
import '../detektei/akte_seite.dart';
import '../detektei/detektei_seite.dart';
import '../detektei/druckmappe_seite.dart';
import '../detektei/sammlung_seite.dart';
import '../krimidinner/gewoelbe_seite.dart';
import '../karten/deck_seite.dart';
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

  /// Assistent für einen neuen Abend; `?akte=<id>` wählt die Akte vor.
  static const abendNeu = '/abend/neu';
  static String abendNeuMit(String id) => '/abend/neu?akte=$id';

  /// Der laufende Abend (Schlosskeller-Runden).
  static const abend = '/abend';

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

GoRouter buildRouter(AppState app, {String initialLocation = Routes.start, AbendHalter? abend}) => GoRouter(
  initialLocation: initialLocation,
  refreshListenable: app,
  redirect: (context, state) {
    final loc = state.matchedLocation;
    if ((loc == Routes.lobby || loc == Routes.game) && app.session == null) return Routes.start;
    // Ohne laufenden Abend gibt es keine Abendseite (z. B. nach dem Neuladen).
    if (loc == Routes.abend && abend != null && !abend.laeuft) return Routes.start;
    // Die Belohnung gibt es nur direkt nach einem beendeten Abend.
    if (loc == Routes.abendBelohnung && abend != null && abend.abschluss == null) return Routes.start;
    return null;
  },
  routes: [
    GoRoute(path: Routes.detektei, pageBuilder: (c, s) => _fade(c, s, const DetekteiSeite())),
    GoRoute(path: Routes.akte, pageBuilder: (c, s) => _fade(c, s, AkteSeite(akteId: s.pathParameters['id'] ?? ''))),
    GoRoute(path: Routes.druckmappe, pageBuilder: (c, s) => _fade(c, s, DruckmappeSeite(akteId: s.pathParameters['id'] ?? ''))),
    GoRoute(
      path: Routes.abendNeu,
      pageBuilder: (c, s) => _fade(c, s, AbendNeuSeite(akteId: s.uri.queryParameters['akte'])),
    ),
    GoRoute(path: Routes.abend, pageBuilder: (c, s) => _fade(c, s, const AbendSeite())),
    GoRoute(path: Routes.abendBelohnung, pageBuilder: (c, s) => _fade(c, s, const BelohnungSeite())),
    GoRoute(path: Routes.sammlung, pageBuilder: (c, s) => _fade(c, s, const SammlungSeite())),
    GoRoute(path: Routes.sammlungDeck, pageBuilder: (c, s) => _fade(c, s, const DeckSeite())),
    GoRoute(path: Routes.profile, pageBuilder: (c, s) => _fade(c, s, const ProfileScreen())),
    // Entwickler- und Altrouten (nicht im Menü).
    GoRoute(path: Routes.klassik, pageBuilder: (c, s) => _fade(c, s, const HubScreen())),
    GoRoute(path: Routes.cases, pageBuilder: (c, s) => _fade(c, s, const CasesScreen())),
    GoRoute(path: Routes.collection, pageBuilder: (c, s) => _fade(c, s, const CollectionScreen())),
    GoRoute(path: Routes.online, pageBuilder: (c, s) => _fade(c, s, const OnlineScreen())),
    GoRoute(path: Routes.lobby, pageBuilder: (c, s) => _fade(c, s, const LobbyScreen())),
    GoRoute(path: Routes.game, pageBuilder: (c, s) => _fade(c, s, const GameScreen())),
    GoRoute(path: Routes.party, pageBuilder: (c, s) => _fade(c, s, PartySeite(dev: PartyDev.ausUrl(_query)))),
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
