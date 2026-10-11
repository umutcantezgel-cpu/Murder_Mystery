import 'package:flutter/material.dart';

import 'tokens.dart';

/// Das Material-Thema des Spiels (dunkel, Material 3) aus den Tokens.
/// Schriften: SpecialElite (Titel) und Inter (Text).
ThemeData buildMordakteTheme({AkteStil? akte}) {
  final f = akte?.farben(MFarben.mordakte) ?? MFarben.mordakte;
  final schrift = MSchrift.fuer(f);
  final scheme = ColorScheme.dark(
    primary: f.akzent,
    onPrimary: f.akzentAuf,
    secondary: f.gefahr,
    onSecondary: f.papier,
    tertiary: f.geist,
    onTertiary: f.grund,
    error: f.gefahr,
    onError: f.papier,
    surface: f.grund2,
    onSurface: f.papier,
    onSurfaceVariant: f.papierLeise,
    surfaceContainerLowest: f.grund,
    surfaceContainerLow: f.grund2,
    surfaceContainer: f.flaeche,
    surfaceContainerHigh: f.flaecheHoch,
    surfaceContainerHighest: f.flaecheHoch,
    outline: f.linieStark,
    outlineVariant: f.linie,
  );
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: scheme,
    fontFamily: MRohSchrift.text,
    scaffoldBackgroundColor: f.grund,
    canvasColor: f.grund,
    splashFactory: InkSparkle.splashFactory,
  );
  final knopfForm = RoundedRectangleBorder(borderRadius: BorderRadius.circular(MMass.r10));
  const mindest = Size(MMass.tippflaeche, MMass.tippflaeche);
  return base.copyWith(
    extensions: <ThemeExtension<dynamic>>[f, schrift, const MMass(), const MBewegung()],
    textTheme: base.textTheme.apply(fontFamily: MRohSchrift.text, bodyColor: f.papier, displayColor: f.papier),
    dividerTheme: DividerThemeData(color: f.linie, space: 1, thickness: 1),
    dialogTheme: DialogThemeData(
      backgroundColor: f.flaeche,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(MMass.r14), side: BorderSide(color: f.linie)),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: f.flaecheHoch,
      contentTextStyle: TextStyle(fontFamily: MRohSchrift.text, color: f.papier),
      behavior: SnackBarBehavior.floating,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: f.grund2,
      hintStyle: schrift.leise,
      border: _feldRand(f.linieStark),
      enabledBorder: _feldRand(f.linieStark),
      focusedBorder: _feldRand(f.akzent, breite: 1.6),
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: f.flaecheHoch,
        borderRadius: BorderRadius.circular(MMass.r6),
        border: Border.all(color: f.linie),
      ),
      textStyle: TextStyle(fontFamily: MRohSchrift.text, fontSize: 13, color: f.papier),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: f.akzent,
        foregroundColor: f.akzentAuf,
        disabledBackgroundColor: f.flaecheHoch,
        disabledForegroundColor: f.papierLeise,
        minimumSize: mindest,
        shape: knopfForm,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: f.papier,
        side: BorderSide(color: f.linieStark),
        minimumSize: mindest,
        shape: knopfForm,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: f.akzentHell, minimumSize: mindest, shape: knopfForm),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: f.akzent,
      inactiveTrackColor: f.flaecheHoch,
      thumbColor: f.akzent,
      overlayColor: f.akzentSchwach,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? f.akzent : f.papierLeise),
      trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? f.akzentSchwach : f.flaecheHoch),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: f.akzent),
  );
}

OutlineInputBorder _feldRand(Color farbe, {double breite = 1}) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(MMass.r10),
      borderSide: BorderSide(color: farbe, width: breite),
    );

/// Was eine Akte am Grundton ändert: nur Akzent und Hintergrundton.
/// Alle übrigen Farben, Schriften und Maße bleiben die von Mordakte.
@immutable
class AkteStil {
  const AkteStil({
    required this.id,
    required this.akzent,
    required this.akzentHell,
    required this.hintergrund,
    this.akzent2,
    this.sigel = '',
  });

  /// Kennung der Akte (`schlosskeller`, `gewoelbe`, …).
  final String id;
  final Color akzent;
  final Color akzentHell;

  /// Obere Tönung des Hintergrunds (Nachtverlauf).
  final Color hintergrund;

  /// Zweiter Akzent (z. B. das Rosa von Blue Palm); sonst der helle Akzent.
  final Color? akzent2;

  /// Kürzel für das Siegel der Akte (zwei Buchstaben, kein Satz).
  final String sigel;

  Color get akzentSchwach => akzent.withValues(alpha: 0.2);

  /// Der Grundton Kerzenmessing, wenn keine Akte bekannt ist.
  static const kerzenmessing = AkteStil(
    id: '',
    akzent: MRoh.akzent,
    akzentHell: MRoh.akzentHell,
    hintergrund: MRoh.nachtOben,
    sigel: 'M',
  );

  /// Schlosskeller: Kerzenorange.
  static const schlosskeller = AkteStil(
    id: 'schlosskeller',
    akzent: Color(0xFFFF9329),
    akzentHell: Color(0xFFFFC27A),
    hintergrund: Color(0xFF231620),
    sigel: 'SK',
  );

  /// Gewölbe: Spukcyan über Moos.
  static const gewoelbe = AkteStil(
    id: 'gewoelbe',
    akzent: Color(0xFF6FC3C8),
    akzentHell: Color(0xFFA9E3E6),
    hintergrund: Color(0xFF141D18),
    akzent2: Color(0xFF7C9A5B),
    sigel: 'GW',
  );

  /// Ravensmoor: Mondblau.
  static const ravensmoor = AkteStil(
    id: 'ravensmoor',
    akzent: Color(0xFF7FA7D9),
    akzentHell: Color(0xFFB6CFEE),
    hintergrund: Color(0xFF141A2A),
    sigel: 'RM',
  );

  /// Nachtexpress: Messing und Stahl.
  static const nachtexpress = AkteStil(
    id: 'nachtexpress',
    akzent: Color(0xFFC9A66B),
    akzentHell: Color(0xFFE5CE9F),
    hintergrund: Color(0xFF181B21),
    akzent2: Color(0xFF9FB1C2),
    sigel: 'NE',
  );

  /// Blue Palm: Neon in Türkis und Rosa.
  static const blauePalme = AkteStil(
    id: 'blue_palm',
    akzent: Color(0xFF3FD1C9),
    akzentHell: Color(0xFF8FE6E1),
    hintergrund: Color(0xFF0F1E26),
    akzent2: Color(0xFFFF5FA2),
    sigel: 'BP',
  );

  /// Stil einer Akte nach Kennung; unbekannte Akten bekommen Kerzenmessing.
  static AkteStil fuer(String akteId) => switch (akteId) {
        'schlosskeller' => schlosskeller,
        'gewoelbe' => gewoelbe,
        'ravensmoor' => ravensmoor,
        'nachtexpress' => nachtexpress,
        'blue_palm' => blauePalme,
        _ => kerzenmessing,
      };

  /// [basis] mit dem Akzent und dem Hintergrundton dieser Akte.
  MFarben farben(MFarben basis) => basis.copyWith(
        akzent: akzent,
        akzentHell: akzentHell,
        akzentSchwach: akzentSchwach,
        akzent2: akzent2 ?? akzentHell,
        nachtOben: hintergrund,
        schein: akzent2 ?? akzent,
      );

  /// [thema] mit dem Akzent dieser Akte (Material-Farben und Tokens).
  ThemeData anwenden(ThemeData thema) {
    final f = farben(thema.extension<MFarben>() ?? MFarben.mordakte);
    return thema.copyWith(
      colorScheme: thema.colorScheme.copyWith(primary: akzent),
      extensions: <ThemeExtension<dynamic>>[
        f,
        MSchrift.fuer(f),
        thema.extension<MMass>() ?? MMass.standard,
        thema.extension<MBewegung>() ?? MBewegung.standard,
      ],
      filledButtonTheme: FilledButtonThemeData(
        style: (thema.filledButtonTheme.style ?? const ButtonStyle()).merge(
          FilledButton.styleFrom(
            backgroundColor: f.akzent,
            foregroundColor: f.akzentAuf,
            disabledBackgroundColor: f.flaecheHoch,
            disabledForegroundColor: f.papierLeise,
          ),
        ),
      ),
      sliderTheme: thema.sliderTheme.copyWith(activeTrackColor: f.akzent, thumbColor: f.akzent, overlayColor: f.akzentSchwach),
    );
  }
}

/// Färbt alles darunter im Stil einer Akte (Akzent, Hintergrundton).
/// Das abgeleitete Thema bleibt erhalten, solange Akte und Grundthema gleich sind;
/// so bauen sich die Bildschirme darunter nicht bei jedem Neuzeichnen um.
class AkteThema extends StatefulWidget {
  const AkteThema({super.key, required this.akte, required this.child});

  /// Kennung der Akte.
  final String akte;
  final Widget child;

  @override
  State<AkteThema> createState() => _AkteThemaState();
}

class _AkteThemaState extends State<AkteThema> {
  ThemeData? _basis;
  String? _akte;
  late ThemeData _thema;

  @override
  Widget build(BuildContext context) {
    final basis = Theme.of(context);
    if (!identical(basis, _basis) || _akte != widget.akte) {
      _basis = basis;
      _akte = widget.akte;
      _thema = AkteStil.fuer(widget.akte).anwenden(basis);
    }
    return Theme(data: _thema, child: widget.child);
  }
}
