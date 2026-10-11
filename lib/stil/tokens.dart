import 'package:flutter/material.dart';

/// Rohwerte des Mordakte-Stils als Konstanten. Die ThemeExtensions unten und
/// die Schreibweisen der alten Stile (`Keller`) zeigen auf dieselben Werte,
/// damit es nur eine Quelle für Farben und Schriften gibt.
abstract final class MRoh {
  // Grundrampe: Tinten-Violett bei Nacht, Papier und Kerzenmessing.
  static const grund = Color(0xFF0D0C11);
  static const grund2 = Color(0xFF16141C);
  static const flaeche = Color(0xFF221E27);
  static const flaecheHoch = Color(0xFF2E2833);
  static const linie = Color(0x33F1E4CC);
  static const linieStark = Color(0x66F1E4CC);
  static const papier = Color(0xFFF1EDE4);
  static const papierLeise = Color(0xFFB9AEA0);
  static const tinte = Color(0xFF2A211B);

  /// Kerzenmessing: der Grundakzent des Spiels.
  static const akzent = Color(0xFFE8A33D);
  static const akzentHell = Color(0xFFF6C77E);
  static const akzentSchwach = Color(0x33E8A33D);

  /// Schriftfarbe auf einer Akzentfläche.
  static const akzentAuf = Color(0xFF1A1006);

  static const gefahr = Color(0xFFB3263A);
  static const erfolg = Color(0xFF3F7D45);
  static const warnung = Color(0xFFE0A050);
  static const geist = Color(0xFFA9D6D9);

  // Seltenheiten der Karten.
  static const zinn = Color(0xFF9AA0A8);
  static const messing = Color(0xFFC9A227);
  static const blutgold = Color(0xFFB8862B);

  /// Obere Tönung des Nachthintergrunds (Tinten-Violett).
  static const nachtOben = Color(0xFF1D1727);

  /// Dunkler Rückfall für Schatten und Vignette.
  static const schwarz = Color(0xFF07060A);
}

/// Rohwerte der Schriften: Schreibmaschine (SpecialElite) für Titel, Inter für Text.
abstract final class MRohSchrift {
  static const anzeige = 'SpecialElite';
  static const text = 'Inter';

  static const titel = TextStyle(fontFamily: anzeige, fontSize: 30, height: 1.2, color: MRoh.akzentHell, letterSpacing: 0.5);
  static const ueberschrift = TextStyle(fontFamily: anzeige, fontSize: 21, height: 1.25, color: MRoh.papier);
  static const fliesstext = TextStyle(fontFamily: text, fontSize: 17, height: 1.5, color: MRoh.papier);
  static const leise = TextStyle(fontFamily: text, fontSize: 14, height: 1.45, color: MRoh.papierLeise);
  static const marke = TextStyle(
    fontFamily: text,
    fontSize: 12,
    height: 1.3,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.2,
    color: MRoh.akzent,
  );

  /// Erzählertext: groß und ruhig lesbar, auch für Vorlesende.
  static const erzaehler = TextStyle(fontFamily: text, fontSize: 20, height: 1.6, color: MRoh.papier);
}

/// Farben des Spiels als ThemeExtension. Eine Akte überschreibt nur Akzent und
/// Hintergrundton (siehe `AkteStil`), die übrigen Farben bleiben gleich.
@immutable
class MFarben extends ThemeExtension<MFarben> {
  const MFarben({
    this.grund = MRoh.grund,
    this.grund2 = MRoh.grund2,
    this.flaeche = MRoh.flaeche,
    this.flaecheHoch = MRoh.flaecheHoch,
    this.linie = MRoh.linie,
    this.linieStark = MRoh.linieStark,
    this.papier = MRoh.papier,
    this.papierLeise = MRoh.papierLeise,
    this.tinte = MRoh.tinte,
    this.akzent = MRoh.akzent,
    this.akzentHell = MRoh.akzentHell,
    this.akzentSchwach = MRoh.akzentSchwach,
    this.akzentAuf = MRoh.akzentAuf,
    this.akzent2 = MRoh.akzentHell,
    this.gefahr = MRoh.gefahr,
    this.erfolg = MRoh.erfolg,
    this.warnung = MRoh.warnung,
    this.geist = MRoh.geist,
    this.zinn = MRoh.zinn,
    this.messing = MRoh.messing,
    this.blutgold = MRoh.blutgold,
    this.nachtOben = MRoh.nachtOben,
    this.schein = MRoh.akzent,
  });

  /// Grundton von Mordakte (Kerzenmessing auf Tinten-Violett).
  static const mordakte = MFarben();

  final Color grund;
  final Color grund2;
  final Color flaeche;
  final Color flaecheHoch;
  final Color linie;
  final Color linieStark;
  final Color papier;
  final Color papierLeise;

  /// Tintenfarbe auf Papier.
  final Color tinte;
  final Color akzent;
  final Color akzentHell;
  final Color akzentSchwach;

  /// Schrift auf einer Akzentfläche.
  final Color akzentAuf;

  /// Zweiter Akzent einer Akte (z. B. das Neon-Rosa von Blue Palm).
  final Color akzent2;
  final Color gefahr;
  final Color erfolg;
  final Color warnung;
  final Color geist;
  final Color zinn;
  final Color messing;
  final Color blutgold;

  /// Obere Tönung des Hintergrunds.
  final Color nachtOben;

  /// Farbe des warmen Scheins am oberen Rand.
  final Color schein;

  /// Farben des nächsten [Theme]; ohne Erweiterung der Grundton.
  static MFarben von(BuildContext context) => Theme.of(context).extension<MFarben>() ?? mordakte;

  /// Farbe einer Seltenheit (zinn, messing, blutgold).
  Color seltenheit(int stufe) => switch (stufe) {
        0 => zinn,
        1 => messing,
        _ => blutgold,
      };

  @override
  MFarben copyWith({
    Color? grund,
    Color? grund2,
    Color? flaeche,
    Color? flaecheHoch,
    Color? linie,
    Color? linieStark,
    Color? papier,
    Color? papierLeise,
    Color? tinte,
    Color? akzent,
    Color? akzentHell,
    Color? akzentSchwach,
    Color? akzentAuf,
    Color? akzent2,
    Color? gefahr,
    Color? erfolg,
    Color? warnung,
    Color? geist,
    Color? zinn,
    Color? messing,
    Color? blutgold,
    Color? nachtOben,
    Color? schein,
  }) =>
      MFarben(
        grund: grund ?? this.grund,
        grund2: grund2 ?? this.grund2,
        flaeche: flaeche ?? this.flaeche,
        flaecheHoch: flaecheHoch ?? this.flaecheHoch,
        linie: linie ?? this.linie,
        linieStark: linieStark ?? this.linieStark,
        papier: papier ?? this.papier,
        papierLeise: papierLeise ?? this.papierLeise,
        tinte: tinte ?? this.tinte,
        akzent: akzent ?? this.akzent,
        akzentHell: akzentHell ?? this.akzentHell,
        akzentSchwach: akzentSchwach ?? this.akzentSchwach,
        akzentAuf: akzentAuf ?? this.akzentAuf,
        akzent2: akzent2 ?? this.akzent2,
        gefahr: gefahr ?? this.gefahr,
        erfolg: erfolg ?? this.erfolg,
        warnung: warnung ?? this.warnung,
        geist: geist ?? this.geist,
        zinn: zinn ?? this.zinn,
        messing: messing ?? this.messing,
        blutgold: blutgold ?? this.blutgold,
        nachtOben: nachtOben ?? this.nachtOben,
        schein: schein ?? this.schein,
      );

  @override
  MFarben lerp(ThemeExtension<MFarben>? other, double t) {
    if (other is! MFarben) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return MFarben(
      grund: l(grund, other.grund),
      grund2: l(grund2, other.grund2),
      flaeche: l(flaeche, other.flaeche),
      flaecheHoch: l(flaecheHoch, other.flaecheHoch),
      linie: l(linie, other.linie),
      linieStark: l(linieStark, other.linieStark),
      papier: l(papier, other.papier),
      papierLeise: l(papierLeise, other.papierLeise),
      tinte: l(tinte, other.tinte),
      akzent: l(akzent, other.akzent),
      akzentHell: l(akzentHell, other.akzentHell),
      akzentSchwach: l(akzentSchwach, other.akzentSchwach),
      akzentAuf: l(akzentAuf, other.akzentAuf),
      akzent2: l(akzent2, other.akzent2),
      gefahr: l(gefahr, other.gefahr),
      erfolg: l(erfolg, other.erfolg),
      warnung: l(warnung, other.warnung),
      geist: l(geist, other.geist),
      zinn: l(zinn, other.zinn),
      messing: l(messing, other.messing),
      blutgold: l(blutgold, other.blutgold),
      nachtOben: l(nachtOben, other.nachtOben),
      schein: l(schein, other.schein),
    );
  }
}

/// Schriften des Spiels als ThemeExtension: Schreibmaschine für Titel, Inter für Text.
@immutable
class MSchrift extends ThemeExtension<MSchrift> {
  const MSchrift({
    this.titel = MRohSchrift.titel,
    this.ueberschrift = MRohSchrift.ueberschrift,
    this.text = MRohSchrift.fliesstext,
    this.leise = MRohSchrift.leise,
    this.marke = MRohSchrift.marke,
    this.erzaehler = MRohSchrift.erzaehler,
  });

  static const standard = MSchrift();

  /// Schriften mit den Akzentfarben von [f] (eine Akte färbt Titel und Marke um).
  factory MSchrift.fuer(MFarben f) => MSchrift(
        titel: MRohSchrift.titel.copyWith(color: f.akzentHell),
        ueberschrift: MRohSchrift.ueberschrift.copyWith(color: f.papier),
        text: MRohSchrift.fliesstext.copyWith(color: f.papier),
        leise: MRohSchrift.leise.copyWith(color: f.papierLeise),
        marke: MRohSchrift.marke.copyWith(color: f.akzent),
        erzaehler: MRohSchrift.erzaehler.copyWith(color: f.papier),
      );

  /// Titel: Schreibmaschine 30.
  final TextStyle titel;

  /// Überschrift: Schreibmaschine 21.
  final TextStyle ueberschrift;

  /// Fließtext: Inter 17, Zeilenhöhe 1,5.
  final TextStyle text;

  /// Leiser Text: Inter 14.
  final TextStyle leise;

  /// Marke (Kapitälchen-Zeile): Inter 12 halbfett, Zeichenabstand 1,2.
  final TextStyle marke;

  /// Erzählertext: Inter 20, Zeilenhöhe 1,6.
  final TextStyle erzaehler;

  static MSchrift von(BuildContext context) => Theme.of(context).extension<MSchrift>() ?? standard;

  @override
  MSchrift copyWith({
    TextStyle? titel,
    TextStyle? ueberschrift,
    TextStyle? text,
    TextStyle? leise,
    TextStyle? marke,
    TextStyle? erzaehler,
  }) =>
      MSchrift(
        titel: titel ?? this.titel,
        ueberschrift: ueberschrift ?? this.ueberschrift,
        text: text ?? this.text,
        leise: leise ?? this.leise,
        marke: marke ?? this.marke,
        erzaehler: erzaehler ?? this.erzaehler,
      );

  @override
  MSchrift lerp(ThemeExtension<MSchrift>? other, double t) {
    if (other is! MSchrift) return this;
    return MSchrift(
      titel: TextStyle.lerp(titel, other.titel, t)!,
      ueberschrift: TextStyle.lerp(ueberschrift, other.ueberschrift, t)!,
      text: TextStyle.lerp(text, other.text, t)!,
      leise: TextStyle.lerp(leise, other.leise, t)!,
      marke: TextStyle.lerp(marke, other.marke, t)!,
      erzaehler: TextStyle.lerp(erzaehler, other.erzaehler, t)!,
    );
  }
}

/// Maße des Spiels: Abstände 4/8/12/16/20/24/32, Radien 6/10/14/20, Inhaltsbreite
/// 760 und das Seitenverhältnis einer Spielkarte (63:88).
@immutable
class MMass extends ThemeExtension<MMass> {
  const MMass({this.inhaltsBreite = breite, this.kartenVerhaeltnis = kartenSeiten});

  static const standard = MMass();

  // Abstände.
  static const s4 = 4.0;
  static const s8 = 8.0;
  static const s12 = 12.0;
  static const s16 = 16.0;
  static const s20 = 20.0;
  static const s24 = 24.0;
  static const s32 = 32.0;

  // Radien.
  static const r6 = 6.0;
  static const r10 = 10.0;
  static const r14 = 14.0;
  static const r20 = 20.0;

  /// Größte Inhaltsbreite auf großen Bildschirmen.
  static const breite = 760.0;

  /// Breite zu Höhe einer Spielkarte (63 × 88 mm).
  static const kartenSeiten = 63 / 88;

  /// Mindestgröße einer Tippfläche.
  static const tippflaeche = 48.0;

  final double inhaltsBreite;
  final double kartenVerhaeltnis;

  static MMass von(BuildContext context) => Theme.of(context).extension<MMass>() ?? standard;

  @override
  MMass copyWith({double? inhaltsBreite, double? kartenVerhaeltnis}) =>
      MMass(inhaltsBreite: inhaltsBreite ?? this.inhaltsBreite, kartenVerhaeltnis: kartenVerhaeltnis ?? this.kartenVerhaeltnis);

  @override
  MMass lerp(ThemeExtension<MMass>? other, double t) => other is MMass ? other : this;
}

/// Bewegung des Spiels: 150 / 280 / 450 ms. Mit „Bewegung reduzieren“
/// ([ruhig]) sind alle Dauern null; kein Schimmern, kein Flackern.
@immutable
class MBewegung extends ThemeExtension<MBewegung> {
  const MBewegung({
    this.dauerSchnell = const Duration(milliseconds: 150),
    this.dauerNormal = const Duration(milliseconds: 280),
    this.dauerLangsam = const Duration(milliseconds: 450),
    this.kurve = Curves.easeOutCubic,
  });

  static const standard = MBewegung();

  final Duration dauerSchnell;
  final Duration dauerNormal;
  final Duration dauerLangsam;
  final Curve kurve;

  static MBewegung von(BuildContext context) => Theme.of(context).extension<MBewegung>() ?? standard;

  /// Soll sich nichts bewegen? Gilt, wenn das System „Bewegung reduzieren“ meldet.
  static bool ruhig(BuildContext context) => MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  /// 150 ms, ruhig: 0.
  static Duration schnell(BuildContext context) => ruhig(context) ? Duration.zero : von(context).dauerSchnell;

  /// 280 ms, ruhig: 0.
  static Duration normal(BuildContext context) => ruhig(context) ? Duration.zero : von(context).dauerNormal;

  /// 450 ms, ruhig: 0.
  static Duration langsam(BuildContext context) => ruhig(context) ? Duration.zero : von(context).dauerLangsam;

  @override
  MBewegung copyWith({Duration? dauerSchnell, Duration? dauerNormal, Duration? dauerLangsam, Curve? kurve}) => MBewegung(
        dauerSchnell: dauerSchnell ?? this.dauerSchnell,
        dauerNormal: dauerNormal ?? this.dauerNormal,
        dauerLangsam: dauerLangsam ?? this.dauerLangsam,
        kurve: kurve ?? this.kurve,
      );

  @override
  MBewegung lerp(ThemeExtension<MBewegung>? other, double t) => other is MBewegung ? other : this;
}
