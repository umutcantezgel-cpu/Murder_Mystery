import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/app_state.dart';
import '../../app/router.dart';
import '../../app/theme.dart';
import '../../l10n/lookup.dart';
import '../../meta/meta_store.dart';
import '../../session/online_session.dart';
import '../../session/session_factory.dart';
import '../../session/server_configuration.dart';
import '../widgets/buttons.dart';
import '../widgets/noir_backdrop.dart';
import '../widgets/panels.dart';

/// Fehler-Schlüssel aus einer Exception der Online-Session ableiten.
String onlineErrorKey(Object e) {
  if (e is OnlineSessionException) return e.key;
  if (e is UnimplementedError) return 'unavailable';
  final s = e.toString();
  for (final k in const ['room_not_found', 'room_full', 'game_running', 'not_host', 'invalid']) {
    if (s.contains(k)) return k;
  }
  if (s.contains('Socket') || s.contains('Connection') || s.contains('WebSocket') || s.contains('connect')) {
    return 'connection';
  }
  return 'unknown';
}

class OnlineScreen extends StatefulWidget {
  const OnlineScreen({super.key});

  @override
  State<OnlineScreen> createState() => _OnlineScreenState();
}

class _OnlineScreenState extends State<OnlineScreen> {
  final _code = TextEditingController();
  late final TextEditingController _server = TextEditingController(
    text: context.read<MetaStore>().serverUrl ?? defaultServerUrl,
  );
  late final AppState _app;
  String? _busy; // 'create' | 'join'
  String? _error;

  @override
  void initState() {
    super.initState();
    _app = context.read<AppState>(); // in dispose() ist kein Context-Lookup mehr erlaubt
    // Nach einem Neuladen: zuletzt besuchten Raum vorschlagen.
    SessionFactory.storedOnlineRoom().then((code) {
      if (!mounted || code == null || _code.text.isNotEmpty) return;
      setState(() => _code.text = code);
    });
  }

  @override
  void dispose() {
    // Verbindungsaufbau läuft noch: abbrechen, sonst bleibt eine Session ohne Bildschirm im Raum.
    if (_busy != null) _app.cancelPendingStart();
    _code.dispose();
    _server.dispose();
    super.dispose();
  }

  Future<void> _go({String? code}) async {
    final app = context.read<AppState>();
    final l = L.of(context);
    final url = _server.text.trim();
    if (publicServerUri(url) == null) {
      setState(() => _error = url.isEmpty ? l.error_server_missing : l.error_server_invalid);
      return;
    }
    app.meta.serverUrl = url == defaultServerUrl ? null : url;
    setState(() {
      _busy = code == null ? 'create' : 'join';
      _error = null;
    });
    try {
      await app.startOnline(roomCode: code);
      if (mounted) context.go(Routes.lobby);
    } on SessionStartCancelled {
      if (mounted) setState(() => _busy = null);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = null;
        _error = l.errorText(onlineErrorKey(e));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final meta = context.watch<MetaStore>();
    final codeOk = _code.text.trim().length == 4;
    return Scaffold(
      body: NoirBackdrop(
        child: SafeArea(
          child: Column(
            children: [
              ContentWidth(
                child: NoirTopBar(
                  title: l.online_title,
                  subtitle: l.online_playing_as(meta.name ?? l.name_default),
                  onBack: () => context.go(Routes.hub),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
                  child: ContentWidth(
                    maxWidth: 480,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_server.text.trim().isEmpty) ...[
                          Text(l.error_server_missing, style: Noir.text(14, color: Noir.smoke)),
                          const SizedBox(height: 16),
                        ],
                        GlassPanel(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.add_home_work_rounded, color: Noir.brass),
                                  const SizedBox(width: 10),
                                  Expanded(child: Text(l.online_create, style: Noir.title(20))),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(l.online_create_sub, style: Noir.text(13.5, color: Noir.smoke)),
                              const SizedBox(height: 16),
                              NoirButton(
                                label: l.online_create,
                                icon: Icons.meeting_room_rounded,
                                busy: _busy == 'create',
                                onPressed: _busy == null ? () => _go() : null,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        GlassPanel(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.vpn_key_rounded, color: Noir.brass),
                                  const SizedBox(width: 10),
                                  Expanded(child: Text(l.online_join, style: Noir.title(20))),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(l.online_join_sub, style: Noir.text(13.5, color: Noir.smoke)),
                              const SizedBox(height: 16),
                              _CodeField(controller: _code, onChanged: () => setState(() {})),
                              const SizedBox(height: 16),
                              NoirButton(
                                label: l.online_join_button,
                                icon: Icons.login_rounded,
                                style: NoirButtonStyle.secondary,
                                busy: _busy == 'join',
                                onPressed: _busy == null && codeOk
                                    ? () => _go(code: _code.text.trim().toUpperCase())
                                    : null,
                              ),
                            ],
                          ),
                        ),
                        if (_error != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Noir.bloodWash,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Noir.bloodBright.withValues(alpha: 0.6)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline_rounded, color: Noir.bloodBright),
                                const SizedBox(width: 10),
                                Expanded(child: Text(_error!, style: Noir.text(14))),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 14),
                        Theme(
                          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                          child: ExpansionTile(
                            initiallyExpanded: publicServerUri(_server.text.trim()) == null,
                            tilePadding: const EdgeInsets.symmetric(horizontal: 4),
                            iconColor: Noir.smoke,
                            collapsedIconColor: Noir.smokeDim,
                            title: Text(l.online_advanced, style: Noir.label(13, color: Noir.smoke)),
                            children: [
                              TextField(
                                controller: _server,
                                keyboardType: TextInputType.url,
                                autocorrect: false,
                                enableSuggestions: false,
                                onChanged: (_) => setState(() {}),
                                style: Noir.text(14),
                                decoration: InputDecoration(
                                  labelText: l.online_server,
                                  labelStyle: Noir.text(13, color: Noir.smoke),
                                  suffixIcon: IconButton(
                                    tooltip: l.online_server_reset,
                                    icon: const Icon(Icons.restart_alt_rounded, color: Noir.smoke),
                                    onPressed: () => setState(() => _server.text = defaultServerUrl),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Eingabe des vierstelligen Raumcodes als Kästchen.
class _CodeField extends StatelessWidget {
  const _CodeField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final text = controller.text.toUpperCase();
    return Stack(
      alignment: Alignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < 4; i++)
              Expanded(child: Container(
                height: 66,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Noir.paper,
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(color: i == text.length ? Noir.brass : Colors.transparent, width: 2),
                  boxShadow: const [BoxShadow(color: Noir.shadow, blurRadius: 6, offset: Offset(0, 3))],
                ),
                child: FittedBox(child: Text(i < text.length ? text[i] : '', style: Noir.title(32, color: Noir.ink))),
              )),
          ],
        ),
        Positioned.fill(
          child: Opacity(
            opacity: 0.01,
            child: TextField(
              controller: controller,
              maxLength: 4,
              autocorrect: false,
              enableSuggestions: false,
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9]'))],
              onChanged: (_) => onChanged(),
              decoration: const InputDecoration(counterText: '', border: InputBorder.none, filled: false),
              style: const TextStyle(fontSize: 1),
              showCursor: false,
            ),
          ),
        ),
      ],
    );
  }
}
