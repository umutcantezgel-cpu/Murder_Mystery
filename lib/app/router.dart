import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../krimidinner/gewoelbe_seite.dart';
import '../party/party_seite.dart';
import '../party/skript.dart';
import '../ui/screens/cases_screen.dart';
import '../ui/screens/collection_screen.dart';
import '../ui/screens/game_screen.dart';
import '../ui/screens/hub_screen.dart';
import '../ui/screens/lobby_screen.dart';
import '../ui/screens/online_screen.dart';
import '../ui/screens/profile_screen.dart';
import 'app_state.dart';

abstract final class Routes {
  static const hub = '/';
  static const cases = '/cases';
  static const collection = '/collection';
  static const profile = '/profile';
  static const online = '/online';
  static const lobby = '/lobby';
  static const game = '/game';
  static const party = '/party';
  static const gewoelbe = '/gewoelbe';
  static const start = party;
}

CustomTransitionPage<void> _fade(GoRouterState state, Widget child) => CustomTransitionPage<void>(
  key: state.pageKey,
  child: child,
  transitionDuration: const Duration(milliseconds: 380),
  reverseTransitionDuration: const Duration(milliseconds: 260),
  transitionsBuilder: (context, animation, secondary, child) {
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

GoRouter buildRouter(AppState app, {String initialLocation = Routes.start}) => GoRouter(
  initialLocation: initialLocation,
  refreshListenable: app,
  redirect: (context, state) {
    final loc = state.matchedLocation;
    if ((loc == Routes.lobby || loc == Routes.game) && app.session == null) return Routes.hub;
    return null;
  },
  routes: [
    GoRoute(path: Routes.hub, pageBuilder: (c, s) => _fade(s, const HubScreen())),
    GoRoute(path: Routes.cases, pageBuilder: (c, s) => _fade(s, const CasesScreen())),
    GoRoute(path: Routes.collection, pageBuilder: (c, s) => _fade(s, const CollectionScreen())),
    GoRoute(path: Routes.profile, pageBuilder: (c, s) => _fade(s, const ProfileScreen())),
    GoRoute(path: Routes.online, pageBuilder: (c, s) => _fade(s, const OnlineScreen())),
    GoRoute(path: Routes.lobby, pageBuilder: (c, s) => _fade(s, const LobbyScreen())),
    GoRoute(path: Routes.game, pageBuilder: (c, s) => _fade(s, const GameScreen())),
    GoRoute(path: Routes.party, pageBuilder: (c, s) => _fade(s, PartySeite(dev: PartyDev.ausUrl(_query)))),
    GoRoute(path: Routes.gewoelbe, pageBuilder: (c, s) => _fade(s, GewoelbeSeite.ausUrl(_query))),
  ],
);

Map<String, String> get _query {
  try {
    return Uri.base.queryParameters;
  } catch (_) {
    return const {};
  }
}
