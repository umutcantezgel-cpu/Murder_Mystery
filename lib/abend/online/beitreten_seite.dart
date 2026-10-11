import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:mordakte_netz/mordakte_netz.dart' show AbendFehler, RaumCode;
import 'package:provider/provider.dart';

import '../einrichtung/abschnitte.dart' show einrichtungFeld;
import '../../app/router.dart';
import '../../l10n/lookup.dart';
import '../../meta/meta_store.dart';
import '../../stil/stil.dart';
import 'gast_dienst.dart';
import 'online_fehler.dart';
import 'online_halter.dart';

/// Einem Online-Abend beitreten (Route `/beitreten`, auch als Link
/// `#/beitreten?raum=ABC-DEF` aus dem QR-Code): Raumcode und Name eingeben,
/// „Beitreten“ tritt dem Raum bei und führt zur Gastseite (`/gast`).
class BeitretenSeite extends StatefulWidget {
  const BeitretenSeite({super.key, this.raum});

  /// Vorgegebener Raumcode (aus dem Link), in beliebiger Schreibweise.
  final String? raum;

  @override
  State<BeitretenSeite> createState() => _BeitretenSeiteState();
}

class _BeitretenSeiteState extends State<BeitretenSeite> {
  late final OnlineHalter _halter = context.read<OnlineHalter>();
  late final TextEditingController _code = TextEditingController(
    text: _schoen(widget.raum ?? ''),
  );
  late final TextEditingController _name = TextEditingController(
    text: context.read<MetaStore>().name ?? '',
  );
  bool _laeuft = false;
  String? _fehler;

  @override
  void dispose() {
    _code.dispose();
    _name.dispose();
    super.dispose();
  }

  Future<void> _beitreten() async {
    if (_laeuft) return;
    final l = L.of(context);
    final code = RaumCode.lesen(_code.text);
    // Der Gastgeber nimmt höchstens 40 Zeichen (Runen) als Namen an.
    final name = String.fromCharCodes(_name.text.trim().runes.take(40));
    if (code == null) {
      setState(() => _fehler = l.online_fehler_code);
      return;
    }
    if (name.isEmpty) {
      setState(() => _fehler = l.online_fehler_name);
      return;
    }
    setState(() {
      _laeuft = true;
      _fehler = null;
    });
    try {
      final g = await GastDienst.beitreten(code: code, name: name);
      _halter.uebernehmeGast(g);
      if (mounted) context.go(Routes.gast);
    } on AbendFehler catch (e) {
      if (mounted) setState(() => _fehler = beitrittsFehlerText(l, e.key));
    } catch (e) {
      debugPrint('ONLINE beitreten fehler $e');
      if (mounted) setState(() => _fehler = beitrittsFehlerText(l, 'relay'));
    } finally {
      if (mounted) setState(() => _laeuft = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final t = MSchrift.von(context);
    final f = MFarben.von(context);
    return Scaffold(
      backgroundColor: f.grund,
      body: MRahmen(
        marke: l.online_beitreten_marke,
        titel: l.online_beitreten_titel,
        untertitel: l.online_beitreten_untertitel,
        aktionen: [
          MKnopf(
            text: l.common_back,
            art: MKnopfArt.zweit,
            onPressed: _laeuft ? null : () => context.go(Routes.start),
          ),
          MKnopf(
            text: l.online_beitreten_los,
            icon: Icons.login_rounded,
            onPressed: _laeuft ? null : _beitreten,
          ),
        ],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MTafel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(l.online_code_feld.toUpperCase(), style: t.marke),
                  const SizedBox(height: MMass.s8),
                  Semantics(
                    label: l.online_code_feld,
                    child: TextField(
                      key: const ValueKey('beitreten-code'),
                      controller: _code,
                      enabled: !_laeuft,
                      autocorrect: false,
                      enableSuggestions: false,
                      textCapitalization: TextCapitalization.characters,
                      textInputAction: TextInputAction.next,
                      inputFormatters: const [_RaumCodeFormat()],
                      style: t.ueberschrift.copyWith(letterSpacing: 4),
                      decoration: einrichtungFeld(
                        context,
                        l.online_code_platzhalter,
                      ),
                    ),
                  ),
                  const SizedBox(height: MMass.s16),
                  Text(l.online_name_feld.toUpperCase(), style: t.marke),
                  const SizedBox(height: MMass.s8),
                  Semantics(
                    label: l.online_name_feld,
                    child: TextField(
                      key: const ValueKey('beitreten-name'),
                      controller: _name,
                      enabled: !_laeuft,
                      maxLength: 40,
                      maxLengthEnforcement: MaxLengthEnforcement.enforced,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _beitreten(),
                      style: t.text,
                      decoration: einrichtungFeld(
                        context,
                        l.online_name_platzhalter,
                      ).copyWith(counterText: ''),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: MMass.s16),
            if (_laeuft)
              Row(
                children: [
                  if (!MBewegung.ruhig(context)) ...[
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    ),
                    const SizedBox(width: MMass.s12),
                  ],
                  Expanded(
                    child: Text(
                      l.online_beitreten_laeuft,
                      key: const ValueKey('beitreten-laeuft'),
                      style: t.leise,
                    ),
                  ),
                ],
              ),
            if (_fehler != null)
              Semantics(
                liveRegion: true,
                child: Row(
                  key: const ValueKey('beitreten-fehler'),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.error_outline, color: f.gefahr, size: 20),
                    const SizedBox(width: MMass.s8),
                    Expanded(child: Text(_fehler!, style: t.text)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Raumcode so, wie er angezeigt wird (`ABC-DEF`); alles Ungültige fällt weg.
String _schoen(String eingabe) {
  final roh = eingabe.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
  final gekuerzt = roh.length > 6 ? roh.substring(0, 6) : roh;
  return gekuerzt.length > 3
      ? '${gekuerzt.substring(0, 3)}-${gekuerzt.substring(3)}'
      : gekuerzt;
}

/// Beim Tippen: Großbuchstaben, Trennstrich nach drei Zeichen, höchstens sechs Zeichen.
class _RaumCodeFormat extends TextInputFormatter {
  const _RaumCodeFormat();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue alt,
    TextEditingValue neu,
  ) {
    final text = _schoen(neu.text);
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
