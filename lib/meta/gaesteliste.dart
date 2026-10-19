import 'package:flutter/foundation.dart';

/// Ein Gast der Gästeliste: Name und gewählte Figur (Kennung aus dem Kanon,
/// `detective` für den Detektiv, `null` ohne Wahl).
@immutable
class Gast {
  const Gast(this.name, [this.figur]);

  final String name;
  final String? figur;

  Gast mitName(String name) => Gast(name, figur);
  Gast mitFigur(String? figur) => Gast(name, figur);

  Map<String, Object?> toJson() => {'name': name, if (figur != null) 'figur': figur};

  static Gast? ausJson(Object? j) {
    if (j is! Map) return null;
    final name = j['name'];
    final figur = j['figur'];
    return name is String ? Gast(name, figur is String ? figur : null) : null;
  }

  @override
  bool operator ==(Object other) => other is Gast && other.name == name && other.figur == figur;

  @override
  int get hashCode => Object.hash(name, figur);
}

/// Gästeliste einer Akte (M5, im [MetaStore] je Gerät): wer welche Figur spielt
/// und, falls schon bekannt, wie viele Personen am Tisch sitzen. Sie entsteht
/// Wochen vor dem Abend auf der Steckbrief-Seite, füllt reihum die Namen in der
/// Einrichtung vor ([namenJeFigur]) und kann online die Zuteilung vorschlagen
/// (Wunsch je Gast, M3). Eine Figur gehört höchstens einem Gast.
@immutable
class GaesteListe {
  const GaesteListe({this.personen, this.gaeste = const []});

  /// Personen am Tisch ohne den Detektiv; `null`, solange die Zahl offen ist.
  final int? personen;
  final List<Gast> gaeste;

  bool get leer => personen == null && gaeste.every((g) => g.name.trim().isEmpty && g.figur == null);

  /// Figur → Name für alle Gäste mit Figur und Namen.
  Map<String, String> get namenJeFigur => {
        for (final g in gaeste)
          if (g.figur != null && g.name.trim().isNotEmpty) g.figur!: g.name.trim(),
      };

  /// Name → Figur für alle Gäste mit Namen und Figur (Wunsch in der Online-Lobby).
  Map<String, String> get figurJeName => {for (final e in namenJeFigur.entries) e.value: e.key};

  GaesteListe mitPersonen(int? n) => GaesteListe(personen: n, gaeste: gaeste);

  /// Setzt Gast [i]; wählt er eine Figur, die schon ein anderer Gast hat, verliert jener sie.
  GaesteListe mitGast(int i, Gast gast) => GaesteListe(personen: personen, gaeste: [
        for (var j = 0; j < gaeste.length; j++)
          if (j == i) gast else if (gast.figur != null && gaeste[j].figur == gast.figur) gaeste[j].mitFigur(null) else gaeste[j],
      ]);

  GaesteListe plus(Gast gast) => GaesteListe(personen: personen, gaeste: [...gaeste, gast]);

  GaesteListe ohne(int i) => GaesteListe(personen: personen, gaeste: [
        for (var j = 0; j < gaeste.length; j++)
          if (j != i) gaeste[j],
      ]);

  Map<String, Object?> toJson() => {
        if (personen != null) 'personen': personen,
        'gaeste': [for (final g in gaeste) g.toJson()],
      };

  static GaesteListe ausJson(Object? j) {
    if (j is! Map) return const GaesteListe();
    final n = j['personen'];
    return GaesteListe(
      personen: n is num ? n.toInt() : null,
      gaeste: List.unmodifiable([
        for (final g in (j['gaeste'] as List? ?? const [])) ?Gast.ausJson(g),
      ]),
    );
  }

  @override
  bool operator ==(Object other) => other is GaesteListe && other.personen == personen && listEquals(other.gaeste, gaeste);

  @override
  int get hashCode => Object.hash(personen, Object.hashAll(gaeste));
}
