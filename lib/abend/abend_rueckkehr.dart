import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../app/router.dart';
import '../l10n/lookup.dart';
import '../meta/meta_store.dart';
import 'abend_halter.dart';
import 'abend_speicher.dart';
import 'online/rueckkehr.dart' show RueckkehrBanner;

/// Karteikarte der Detektei für einen abgelegten Abend (Solo oder reihum):
/// „Abend fortsetzen“ mit Akte und Runde, darunter „Abend verwerfen“. Ohne
/// abgelegten Abend bleibt das Feld leer. Fortsetzen baut die Sitzung aus dem
/// Stand auf, übergibt sie dem [AbendHalter] und öffnet den Abend; lässt sich
/// der Stand nicht mehr abspielen, ist er verworfen. Scheitert nur das Laden,
/// bleibt er liegen und ein Hinweis erscheint.
class AbendRueckkehr extends StatefulWidget {
  const AbendRueckkehr({super.key});

  @override
  State<AbendRueckkehr> createState() => _AbendRueckkehrState();
}

class _AbendRueckkehrState extends State<AbendRueckkehr> {
  Map<String, Object?>? _stand;
  bool _laeuft = false;

  @override
  void initState() {
    super.initState();
    AbendSpeicher.abgelegt.addListener(_neuLesen);
    _lesen();
  }

  @override
  void dispose() {
    AbendSpeicher.abgelegt.removeListener(_neuLesen);
    super.dispose();
  }

  void _lesen() => unawaited(AbendSpeicher.lesen().then((s) {
        if (mounted) setState(() => _stand = s);
      }));

  /// Die Ablage hat sich geändert (auch durch andere Karten): neu lesen.
  void _neuLesen() {
    if (AbendSpeicher.abgelegt.value == false) {
      if (_stand != null && mounted) setState(() => _stand = null);
    } else if (AbendSpeicher.abgelegt.value == true && _stand == null) {
      _lesen();
    }
  }

  Future<void> _fortsetzen() async {
    if (_laeuft) return;
    final halter = context.read<AbendHalter>();
    final router = GoRouter.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final fehler = L.of(context).abend_fortsetzen_fehler;
    setState(() => _laeuft = true);
    try {
      final s = await AbendSpeicher.fortsetzen(context.read<MetaStore>());
      if (!mounted) {
        // Die Detektei ist schon weg: nicht ungefragt in einen Abend springen.
        s?.dispose();
        return;
      }
      if (s == null) {
        setState(() {
          _laeuft = false;
          _stand = null;
        });
        return;
      }
      halter.uebernehmen(s);
      router.go(Routes.abend);
    } catch (e) {
      debugPrint('ABEND fortsetzen fehler $e');
      if (mounted) {
        setState(() => _laeuft = false);
        messenger.showSnackBar(SnackBar(content: Text(fehler)));
      }
    }
  }

  Future<void> _verwerfen() async {
    await AbendSpeicher.loeschen();
    if (mounted) setState(() => _stand = null);
  }

  @override
  Widget build(BuildContext context) {
    final stand = _stand;
    if (stand == null) return const SizedBox.shrink();
    final l = L.of(context);
    final akte = stand['titel'] as String? ?? '';
    final runde = stand['runde'] as int? ?? 0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: RueckkehrBanner(
        key: const ValueKey('abend-fortsetzen'),
        knopf: l.abend_fortsetzen,
        hinweis: runde > 0 ? l.abend_fortsetzen_runde(akte, runde) : l.abend_fortsetzen_hinweis(akte),
        verwerfen: l.abend_fortsetzen_verwerfen,
        onZurueck: _laeuft ? null : _fortsetzen,
        onVerwerfen: _laeuft ? null : _verwerfen,
      ),
    );
  }
}
