import 'package:flutter/material.dart';
import 'package:mordakte_core/mordakte_core.dart';

/// Farbpalette und Schriften des Noir-Stils.
///
/// Nur noch für die klassische Echtzeit-Oberfläche (Fälle, Lobby, Spiel). Das
/// Spiel „Mordakte“ verwendet das Designsystem `lib/stil/`.
abstract final class Noir {
  static const night = Color(0xFF0D0F1D);
  static const night2 = Color(0xFF14172A);
  static const night3 = Color(0xFF1D2138);
  static const night4 = Color(0xFF272C47);
  static const line = Color(0x33E8E0D0);

  static const paper = Color(0xFFE8E0D0);
  static const paperDark = Color(0xFFD5C8AE);
  static const paperShade = Color(0xFFBFAF90);
  static const ink = Color(0xFF2A211B);
  static const inkSoft = Color(0xFF5B4E42);

  static const blood = Color(0xFF8B0000);
  static const bloodBright = Color(0xFFC0322B);
  static const brass = Color(0xFFC9A227);
  static const brassLight = Color(0xFFE6C766);
  static const brassDim = Color(0xFF7E6A2E);

  static const smoke = Color(0xFF9EA3B8);
  static const smokeDim = Color(0xFF6A6F87);
  static const cream = Color(0xFFF3EBDD);

  static const buff = Color(0xFF6BBF6E);
  static const debuff = Color(0xFFE0554D);
  static const cork = Color(0xFF6B4A2E);
  static const corkDark = Color(0xFF4A321F);

  // --- Semantische Tokens (Linien, Flächen, Schatten) ----------------------
  static const clear = Color(0x00000000);
  static const lineFaint = Color(0x14E8E0D0);
  static const lineSoft = Color(0x22E8E0D0);
  static const lineStrong = Color(0x55E8E0D0);
  static const shadeFaint = Color(0x1A000000);
  static const shade = Color(0x33000000);
  static const shadow = Color(0x88000000);
  static const shadowStrong = Color(0x99000000);
  static const scrim = Color(0xCC000000);

  /// HUD-Glas (halbtransparentes Nachtblau).
  static const glassFaint = Color(0x880E101C);
  static const glass = Color(0xCC0E101C);
  static const glassStrong = Color(0xEE0E101C);
  static const panelFaint = Color(0x44151829);
  static const panel = Color(0x99151829);
  static const panelStrong = Color(0xCC151829);

  /// Untere Aktionsleisten.
  static const bar = Color(0xF00B0D18);
  static const brassWash = Color(0x22C9A227);
  static const leather = Color(0xFF221812);
  static const leatherLight = Color(0xFF3A271C);
  static const leatherMid = Color(0xFF2A1C15);
  static const corkLight = Color(0xFF6E4B2F);
  static const corkDeep = Color(0xFF2E1F14);

  // --- Semantische Zustandsfarben ------------------------------------------
  static const warning = Color(0xFFE0A050);
  static const success = Color(0xFF3F7D45);
  static const moon = Color(0xFF8FA8FF);
  static const moonLight = Color(0xFFBFD0FF);
  static const nightBand = Color(0xE6060814);
  static const nightBandClear = Color(0x00060814);
  static const lab = Color(0xFF7FB2E5);
  static const inkBlue = Color(0xFF2D5A8A);
  static const ghost = Color(0xFFA9C8E8);
  static const ghostLight = Color(0xFFD5E6F5);
  static const ghostDim = Color(0xFFB8C8D8);
  static const bot = Color(0xFF6FA8DC);
  static const dawn = Color(0xFFF0B070);
  static const flame = Color(0xFFF0A040);
  static const trace = Color(0xFF9A8CC8);
  static const whiteSoft = Color(0xCCFFFFFF);

  // --- Weitere Flächen/Details ---------------------------------------------
  static const scrimSoft = Color(0xB3000000);
  static const night1 = Color(0xFF0E101C);
  static const night3Glass = Color(0xEE1D2138);
  static const dangerGlass = Color(0xEE3A0E10);
  static const paperGlass = Color(0xEEE8E0D0);
  static const barSoft = Color(0xCC07080F);
  static const deep = Color(0xFF0B0C16);
  static const deepest = Color(0xFF05060B);
  static const dusk = Color(0xFF262B4A);
  static const nightEdge = Color(0x55050818);
  static const nightEdgeDeep = Color(0xCC02030A);
  static const bloodVeil = Color(0x998B0000);
  static const bloodDeep = Color(0xEE300000);
  static const bloodWash = Color(0x338B0000);
  static const bloodLight = Color(0xFFA51C1C);
  static const bloodDark = Color(0xFF5A0000);
  static const ghostGlass = Color(0xCC1A2030);
  static const ghostLine = Color(0x88A9C8E8);
  static const ghostGlow = Color(0x5590B8E0);
  static const mapWall = Color(0xFF3A3F5C);
  static const mapFloor = Color(0xFF1C2034);
  static const mapLit = Color(0xFF3A3220);
  static const mapOutdoor = Color(0xFF16261C);
  static const mapDoor = Color(0xFF7A6A44);
  static const mapNpc = Color(0xFFB5B0A6);
  static const sheetTop = Color(0xF2131626);
  static const sheetBottom = Color(0xFA0A0B14);
  static const ruleBlue = Color(0x262D5A8A);
  static const ruleRed = Color(0x66B23A3A);
  static const inkBlueWash = Color(0x1A2D5A8A);
  static const inkBlueLine = Color(0x662D5A8A);
  static const paperYellow = Color(0xFFE9E2C2);
  static const paperLight = Color(0xFFF1EBDF);
  static const paperFaded = Color(0x99E8E0D0);
  static const creamShade = Color(0xFFCFC4AE);
  static const brassLine = Color(0x99C9A227);
  static const pin = Color(0xFFE55A50);
  static const pinLight = Color(0xFFFF8A80);
  static const secretBg = Color(0xFF1A1508);
  static const botLine = Color(0x446FA8DC);
  static const botDim = Color(0xAA6FA8DC);
  static const flameWash = Color(0x33D9822B);
  static const flameLine = Color(0xAAD9822B);
  static const tape = Color(0x99E9DFB8);
  static const tapeEdge = Color(0x33FFFFFF);
  static const steel = Color(0xFFB8BCC6);
  static const bronze = Color(0xFFB08D57);

  static const display = 'SpecialElite';
  static const body = 'Inter';

  static TextStyle title(double size, {Color color = cream, double spacing = 1.5}) =>
      TextStyle(fontFamily: display, fontSize: size, color: color, letterSpacing: spacing, height: 1.15);

  static TextStyle label(
    double size, {
    Color color = smoke,
    FontWeight weight = FontWeight.w600,
    double spacing = 1.2,
  }) => TextStyle(fontFamily: body, fontSize: size, color: color, fontWeight: weight, letterSpacing: spacing);

  static TextStyle text(double size, {Color color = cream, FontWeight weight = FontWeight.w400, double height = 1.4}) =>
      TextStyle(fontFamily: body, fontSize: size, color: color, fontWeight: weight, height: height);

  static TextStyle typed(double size, {Color color = ink, double height = 1.45}) =>
      TextStyle(fontFamily: display, fontSize: size, color: color, height: height, letterSpacing: 0.2);
}

/// Hex `#rrggbb` → Farbe.
Color hexColor(String hex, {Color fallback = Noir.smoke}) {
  final h = hex.replaceFirst('#', '');
  final v = int.tryParse(h.length == 6 ? 'ff$h' : h, radix: 16);
  return v == null ? fallback : Color(v);
}

/// Akzentfarbe eines Szenarios (Messing, wenn unbekannt).
Color accentOf(ScenarioDef? s) => s == null ? Noir.brass : Color(s.theme.color('accent'));

Color coatColor(int index) => hexColor(detectiveCoats[index.clamp(0, detectiveCoats.length - 1)]);

/// Thema der klassischen Oberfläche und der Vorschauen; die App nutzt `buildMordakteTheme`.
ThemeData buildNoirTheme() {
  const scheme = ColorScheme.dark(
    primary: Noir.brass,
    onPrimary: Noir.night,
    secondary: Noir.bloodBright,
    onSecondary: Noir.cream,
    surface: Noir.night2,
    onSurface: Noir.cream,
    error: Noir.debuff,
  );
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: scheme,
    fontFamily: Noir.body,
    scaffoldBackgroundColor: Noir.night,
    canvasColor: Noir.night,
    splashFactory: InkSparkle.splashFactory,
  );
  return base.copyWith(
    textTheme: base.textTheme.apply(fontFamily: Noir.body, bodyColor: Noir.cream, displayColor: Noir.cream),
    dialogTheme: const DialogThemeData(
      backgroundColor: Noir.night2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(6))),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: Noir.night3,
      contentTextStyle: TextStyle(fontFamily: Noir.body, color: Noir.cream),
      behavior: SnackBarBehavior.floating,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Noir.night3,
      hintStyle: Noir.text(15, color: Noir.smokeDim),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: Noir.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: Noir.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: Noir.brass),
      ),
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: Noir.night3,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Noir.line),
      ),
      textStyle: Noir.text(13),
    ),
  );
}
