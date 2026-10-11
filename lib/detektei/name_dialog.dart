import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/lookup.dart';
import '../meta/meta_store.dart';
import '../stil/stil.dart';

/// Fragt den Spielernamen ab (beim ersten Start Pflicht, [first]). Der Name
/// gehört zum Profil und steht in der Detektei.
Future<void> showNameDialog(BuildContext context, {bool first = false}) async {
  final meta = context.read<MetaStore>();
  final l = L.of(context);
  final ctrl = TextEditingController(text: meta.name ?? '');
  await showDialog<void>(
    context: context,
    barrierDismissible: !first,
    barrierColor: const Color(0xCC000000),
    builder: (c) {
      final f = MFarben.von(c);
      final tinte = TextStyle(fontFamily: MRohSchrift.anzeige, fontSize: 20, height: 1.45, letterSpacing: 0.2, color: f.tinte);
      void save() {
        final v = ctrl.text.trim();
        meta.name = v.isEmpty ? l.name_default : (v.length > 16 ? v.substring(0, 16) : v);
        Navigator.of(c).pop();
      }

      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(MMass.s24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: SingleChildScrollView(
            child: MPapier(
              padding: const EdgeInsets.fromLTRB(22, 26, 22, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(first ? l.name_prompt_title_du : l.name_edit, style: tinte.copyWith(fontSize: 22)),
                  const SizedBox(height: 6),
                  Text(l.name_prompt_text_du, style: tinte.copyWith(fontSize: 14, color: f.tinte.withValues(alpha: 0.75))),
                  const SizedBox(height: 18),
                  TextField(
                    controller: ctrl,
                    autofocus: true,
                    maxLength: 16,
                    textCapitalization: TextCapitalization.words,
                    style: tinte,
                    cursorColor: f.gefahr,
                    decoration: InputDecoration(
                      hintText: l.name_prompt_hint,
                      counterText: '',
                      filled: true,
                      fillColor: const Color(0x1A000000),
                      hintStyle: tinte.copyWith(color: f.tinte.withValues(alpha: 0.45)),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: f.tinte.withValues(alpha: 0.6))),
                      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: f.gefahr, width: 2)),
                    ),
                    onSubmitted: (_) => save(),
                  ),
                  const SizedBox(height: 20),
                  MKnopf(text: first ? l.name_prompt_confirm : l.common_save, icon: Icons.badge_rounded, onPressed: save),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
