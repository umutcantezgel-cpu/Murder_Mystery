import 'package:flutter/widgets.dart';

/// Untergrund, auf dem ein Inhalt liegt: der dunkle Schreibtisch oder ein helles
/// Blatt Papier. Bausteine wie [MFarben.von] und [MSchrift.von] lesen ihn und
/// liefern auf Papier Tintenfarben, auf dem Schreibtisch helle Schrift.
enum MFlaecheArt { dunkel, papier }

/// Legt den Untergrund für alles darunter fest (siehe [MFlaecheArt]).
class MFlaeche extends InheritedWidget {
  const MFlaeche({super.key, required this.art, required super.child});

  /// Helles Papier für [child].
  const MFlaeche.papier({super.key, required super.child}) : art = MFlaecheArt.papier;

  /// Dunkler Schreibtisch für [child] (z. B. ein Messingschild auf einem Blatt).
  const MFlaeche.dunkel({super.key, required super.child}) : art = MFlaecheArt.dunkel;

  final MFlaecheArt art;

  /// Liegt [context] auf hellem Papier?
  static bool hellVon(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<MFlaeche>()?.art == MFlaecheArt.papier;

  @override
  bool updateShouldNotify(MFlaeche oldWidget) => oldWidget.art != art;
}
