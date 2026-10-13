import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/lookup.dart';
import '../meta/meta_store.dart';
import '../stil/stil.dart';

/// Fragt den Spielernamen ab (beim ersten Start Pflicht, [first]). Der Name
/// gehört zum Profil und steht auf dem Dienstausweis in der Detektei.
///
/// Die Frage liegt als Karteikarte auf dem Schreibtisch: Titel über der roten
/// Kopflinie, der Name wird mit Füller auf die Karte geschrieben.
Future<void> showNameDialog(BuildContext context, {bool first = false}) async {
  final meta = context.read<MetaStore>();
  final l = L.of(context);
  final ctrl = TextEditingController(text: meta.name ?? '');
  await showDialog<void>(
    context: context,
    barrierDismissible: !first,
    barrierColor: const Color(0xCC000000),
    builder: (c) {
      void save() {
        final v = ctrl.text.trim();
        meta.name = v.isEmpty ? l.name_default : (v.length > 16 ? v.substring(0, 16) : v);
        Navigator.of(c).pop();
      }

      return _NamensKarte(
        titel: first ? l.name_prompt_title_du : l.name_edit,
        text: l.name_prompt_text_du,
        hinweis: l.name_prompt_hint,
        knopf: first ? l.name_prompt_confirm : l.common_save,
        ctrl: ctrl,
        speichern: save,
      );
    },
  );
}

/// Die Karteikarte des Namensdialogs. Die Kopflinie richtet sich nach der Höhe
/// des Titels, damit er auch bei großer Schrift darüber steht.
class _NamensKarte extends StatelessWidget {
  const _NamensKarte({
    required this.titel,
    required this.text,
    required this.hinweis,
    required this.knopf,
    required this.ctrl,
    required this.speichern,
  });

  final String titel;
  final String text;
  final String hinweis;
  final String knopf;
  final TextEditingController ctrl;
  final VoidCallback speichern;

  static const _rand = EdgeInsets.fromLTRB(22, 12, 22, 20);

  @override
  Widget build(BuildContext context) {
    final breite = MediaQuery.sizeOf(context).width;
    final titelStil = MPapierSchrift.ueberschrift.copyWith(fontSize: 22, height: 1.25);
    final feder = MPapierSchrift.hand.copyWith(fontSize: 30, height: 1.25, color: MRoh.tinteBlau);
    return Semantics(
      scopesRoute: true,
      namesRoute: true,
      explicitChildNodes: true,
      label: titel,
      child: Dialog(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        // Ohne Rahmen des Themas: die Karteikarte ist selbst die Form.
        shape: const RoundedRectangleBorder(),
        elevation: 0,
        insetPadding: EdgeInsets.symmetric(horizontal: breite < 400 ? 14 : 40, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: SingleChildScrollView(
            child: LayoutBuilder(
              builder: (context, box) {
                final tp = TextPainter(
                  text: TextSpan(text: titel, style: titelStil),
                  textDirection: TextDirection.ltr,
                  textScaler: MediaQuery.textScalerOf(context),
                )..layout(maxWidth: box.maxWidth - _rand.horizontal);
                final kopf = _rand.top + tp.height + 8;
                tp.dispose();
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: MBlatt(
                    art: PapierArt.karteikarte,
                    kopfLinie: kopf,
                    neigung: -0.006,
                    samen: 59,
                    padding: _rand,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(titel, style: titelStil),
                        const SizedBox(height: MMass.s20),
                        Text(text, style: MPapierSchrift.text.copyWith(fontSize: 15, height: 1.45, color: MRoh.tinteLeise)),
                        const SizedBox(height: MMass.s16),
                        TextField(
                          controller: ctrl,
                          autofocus: true,
                          maxLength: 16,
                          textCapitalization: TextCapitalization.words,
                          style: feder,
                          cursorColor: MRoh.tinteBlau,
                          decoration: InputDecoration(
                            hintText: hinweis,
                            counterText: '',
                            filled: true,
                            fillColor: MRoh.tinte.withValues(alpha: 0.04),
                            isDense: true,
                            contentPadding: const EdgeInsets.fromLTRB(4, 6, 4, 4),
                            hintStyle: feder.copyWith(color: MRoh.tinte.withValues(alpha: 0.3)),
                            border: UnderlineInputBorder(borderSide: BorderSide(color: MRoh.tinte.withValues(alpha: 0.6))),
                            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: MRoh.tinte.withValues(alpha: 0.6))),
                            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: MRoh.tinteBlau, width: 2)),
                          ),
                          onSubmitted: (_) => speichern(),
                        ),
                        const SizedBox(height: MMass.s24),
                        Align(
                          alignment: Alignment.centerRight,
                          child: MKnopf(text: knopf, icon: Icons.badge_rounded, onPressed: speichern),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
