import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../l10n/gen/app_localizations.dart';
import '../meta/meta_store.dart';
import 'app_state.dart';
import 'router.dart';
import 'theme.dart';

class MordakteApp extends StatefulWidget {
  const MordakteApp({super.key, required this.app, this.initialLocation = Routes.start});

  final AppState app;
  final String initialLocation;

  @override
  State<MordakteApp> createState() => _MordakteAppState();
}

class _MordakteAppState extends State<MordakteApp> {
  late final GoRouter _router = buildRouter(widget.app, initialLocation: widget.initialLocation);
  final _theme = buildNoirTheme();

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppState>.value(value: widget.app),
        ChangeNotifierProvider<MetaStore>.value(value: widget.app.meta),
      ],
      child: MaterialApp.router(
        onGenerateTitle: (c) => L.of(c).appTitle,
        debugShowCheckedModeBanner: false,
        theme: _theme,
        darkTheme: _theme,
        themeMode: ThemeMode.dark,
        locale: const Locale('de'),
        supportedLocales: L.supportedLocales,
        localizationsDelegates: const [
          L.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        routerConfig: _router,
      ),
    );
  }
}
