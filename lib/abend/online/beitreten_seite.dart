import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:mordakte_netz/mordakte_netz.dart' show AbendFehler, RaumCode;
import 'package:provider/provider.dart';

import '../../app/router.dart';
import '../../l10n/lookup.dart';
import '../../meta/meta_store.dart';
import '../../stil/stil.dart';
import 'gast_dienst.dart';
import 'online_fehler.dart';
import 'online_halter.dart';
import 'online_teile.dart';

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
    final f = MFarben.von(context);
    final codeStil = MPapierSchrift.maschine.copyWith(fontSize: 30, height: 1.2, letterSpacing: 6);
    final nameStil = MPapierSchrift.telegramm.copyWith(fontSize: 20, height: 1.3);
    final fehler = _fehler;
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
            // Das Formular als Telegramm: Raumcode und Name werden eingetippt.
            Padding(
              padding: const EdgeInsets.only(top: MMass.s12),
              child: MBlatt(
                art: PapierArt.telegramm,
                klebestreifen: true,
                neigung: -0.005,
                samen: 21,
                padding: const EdgeInsets.fromLTRB(22, 26, 22, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Doppelte Kopflinie eines Telegrammformulars.
                    Container(height: 2.4, color: MRoh.tinte.withValues(alpha: 0.7)),
                    const SizedBox(height: 2),
                    Container(height: 0.8, color: MRoh.tinte.withValues(alpha: 0.55)),
                    const SizedBox(height: MMass.s16),
                    Text(l.online_code_feld, style: MPapierSchrift.zwischentitel.copyWith(color: MRoh.stempelRot)),
                    const SizedBox(height: 6),
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
                        style: codeStil,
                        cursorColor: MRoh.tinte,
                        decoration: _telegrammFeld(l.online_code_platzhalter, codeStil),
                      ),
                    ),
                    const SizedBox(height: MMass.s24),
                    Text(l.online_name_feld, style: MPapierSchrift.zwischentitel.copyWith(color: MRoh.stempelRot)),
                    const SizedBox(height: 6),
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
                        style: nameStil,
                        cursorColor: MRoh.tinte,
                        decoration: _telegrammFeld(l.online_name_platzhalter, nameStil).copyWith(counterText: ''),
                      ),
                    ),
                    const SizedBox(height: MMass.s24),
                    Container(height: 0.8, color: MRoh.tinte.withValues(alpha: 0.55)),
                    const SizedBox(height: 2),
                    Container(height: 2.4, color: MRoh.tinte.withValues(alpha: 0.7)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: MMass.s24),
            if (_laeuft)
              OnlineWarteNotiz(
                text: l.online_beitreten_laeuft,
                textKey: const ValueKey('beitreten-laeuft'),
              ),
            if (fehler != null)
              Semantics(
                liveRegion: true,
                child: OnlineHinweisKarte(
                  key: const ValueKey('beitreten-fehler'),
                  icon: Icons.error_outline,
                  text: fehler,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Eingabezeile auf dem Telegrammformular: getippte Schrift auf einer
/// Tintenlinie, der Platzhalter blass in derselben Schrift.
InputDecoration _telegrammFeld(String platzhalter, TextStyle stil) {
  UnderlineInputBorder linie(Color farbe, double breite) => UnderlineInputBorder(borderSide: BorderSide(color: farbe, width: breite));
  return InputDecoration(
    hintText: platzhalter,
    hintStyle: stil.copyWith(color: MRoh.tinteLeise.withValues(alpha: 0.55)),
    isDense: true,
    filled: true,
    fillColor: MRoh.tinte.withValues(alpha: 0.04),
    contentPadding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
    border: linie(MRoh.tinte.withValues(alpha: 0.5), 1.2),
    enabledBorder: linie(MRoh.tinte.withValues(alpha: 0.5), 1.2),
    disabledBorder: linie(MRoh.tinte.withValues(alpha: 0.25), 1),
    focusedBorder: linie(MRoh.tinteBlau, 2),
  );
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
