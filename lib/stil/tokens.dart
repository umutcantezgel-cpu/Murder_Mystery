import 'package:flutter/material.dart';

import 'flaeche.dart';
import 'schriften.dart';

export 'flaeche.dart';
export 'schriften.dart';

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

  // Materialien der Ermittlungsmappe: Papier, Aktendeckel, Tinte, Stempel, Kork, Messing.
  /// Gealtertes Aktenpapier (hell, warm).
  static const blatt = Color(0xFFF2EBDD);

  /// Schattenseite des Papiers (Ränder, Knicke).
  static const blattSchatten = Color(0xFFD9CDB5);

  /// Karteikarte (etwas kühler als Aktenpapier).
  static const karteikarte = Color(0xFFF7F3EA);

  /// Aktendeckel aus Manilakarton.
  static const manila = Color(0xFFD9B979);
  static const manilaDunkel = Color(0xFFB08A4A);

  /// Leiser Text auf Papier.
  static const tinteLeise = Color(0xFF6B5C4C);

  /// Füllertinte (Unterstreichungen, Randnotizen).
  static const tinteBlau = Color(0xFF233F7A);

  /// Stempelfarbe.
  static const stempelRot = Color(0xFFA3242F);

  /// Karteikarten-Linien.
  static const linieBlau = Color(0x55557BB8);
  static const linieRot = Color(0x88C2414B);

  /// Korkwand.
  static const kork = Color(0xFF9C6B3E);
  static const korkDunkel = Color(0xFF6E4524);

  /// Gebürstetes Messing (Schilder, Knöpfe).
  static const messingHell = Color(0xFFF3D58C);
  static const messingMitte = Color(0xFFC99A3E);
  static const messingDunkel = Color(0xFF7A5414);

  /// Schreibtischleder unter den Mappen.
  static const leder = Color(0xFF2B1A17);
  static const lederHell = Color(0xFF3D2620);
}

/// Rohwerte der Schriften der Ermittlungsmappe: Playfair Display für Titel, Lora
/// für Lesetext, Special Elite für Schreibmaschinenzeilen, Inter für kleine Bedientexte.
/// Die Schriftnamen stehen in `schriften.dart` ([MSchriftFamilie]).
abstract final class MRohSchrift {
  /// Titelschrift (Playfair Display).
  static const anzeige = MSchriftFamilie.titel;

  /// Lesetext (Lora).
  static const lesen = MSchriftFamilie.lesen;

  /// Schreibmaschine (Special Elite).
  static const maschine = MSchriftFamilie.maschine;

  /// Bedientext (Inter).
  static const text = MSchriftFamilie.ui;

  static const titel = TextStyle(
    fontFamily: anzeige,
    fontSize: 30,
    height: 1.2,
    fontWeight: FontWeight.w700,
    fontVariations: [FontVariation('wght', 700)],
    color: MRoh.akzentHell,
  );
  static const ueberschrift = TextStyle(
    fontFamily: anzeige,
    fontSize: 22,
    height: 1.27,
    fontWeight: FontWeight.w700,
    fontVariations: [FontVariation('wght', 700)],
    color: MRoh.papier,
  );
  static const fliesstext = TextStyle(
    fontFamily: lesen,
    fontSize: 17,
    height: 1.55,
    fontWeight: FontWeight.w400,
    fontVariations: [FontVariation('wght', 400)],
    color: MRoh.papier,
  );
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
  static const erzaehler = TextStyle(
    fontFamily: lesen,
    fontSize: 20,
    height: 1.6,
    fontWeight: FontWeight.w400,
    fontVariations: [FontVariation('wght', 400)],
    color: MRoh.papier,
  );

  /// Schlagzeile, Aktendeckel, Urteil.
  static const aufmacher = TextStyle(
    fontFamily: anzeige,
    fontSize: 40,
    height: 1.1,
    fontWeight: FontWeight.w800,
    fontVariations: [FontVariation('wght', 800)],
    letterSpacing: -0.3,
    color: MRoh.papier,
  );

  /// Abschnitts- und Formularköpfe in Schreibmaschine („Was ich weiß“).
  static const zwischentitel = TextStyle(fontFamily: maschine, fontSize: 15, height: 1.33, letterSpacing: 0.6, color: MRoh.papier);

  /// Aussagen und Zitate (echte Kursive).
  static const kursiv = TextStyle(
    fontFamily: lesen,
    fontSize: 17,
    height: 1.55,
    fontStyle: FontStyle.italic,
    fontWeight: FontWeight.w400,
    fontVariations: [FontVariation('wght', 400)],
    color: MRoh.papier,
  );

  /// Etiketten, Aktenzeichen, Einträge.
  static const schreibmaschine = TextStyle(fontFamily: maschine, fontSize: 15, height: 1.45, letterSpacing: 0.2, color: MRoh.papier);

  /// Telegramm und „Klare Schrift“.
  static const telegramm = TextStyle(fontFamily: MSchriftFamilie.telegramm, fontSize: 15, height: 1.45, letterSpacing: 0.4, color: MRoh.papier);

  /// Randnotiz des Detektivs (Füller).
  static const handschrift = TextStyle(
    fontFamily: MSchriftFamilie.hand,
    fontSize: 21,
    height: 1.24,
    fontWeight: FontWeight.w600,
    fontVariations: [FontVariation('wght', 600)],
    color: MRoh.tinteBlau,
  );

  /// Beschriftung der Messingschilder.
  static const knopf = TextStyle(
    fontFamily: anzeige,
    fontSize: 17,
    height: 1.18,
    fontWeight: FontWeight.w700,
    fontVariations: [FontVariation('wght', 700)],
    letterSpacing: 0.4,
  );
}

/// Die Schriftrollen in Tinte für Inhalte auf Papier, als Konstanten. Bildschirme
/// setzen sie in [MBlatt], [MAktenmappe] und Karteikarten, wo der äußere `context`
/// noch über dem Papier liegt.
abstract final class MPapierSchrift {
  static final titel = MRohSchrift.titel.copyWith(color: MRoh.tinte);
  static final ueberschrift = MRohSchrift.ueberschrift.copyWith(color: MRoh.tinte);
  static final text = MRohSchrift.fliesstext.copyWith(color: MRoh.tinte);
  static final leise = MRohSchrift.leise.copyWith(color: MRoh.tinteLeise);
  static final marke = MRohSchrift.marke.copyWith(color: MRoh.stempelRot);
  static final erzaehler = MRohSchrift.erzaehler.copyWith(color: MRoh.tinte);
  static final aufmacher = MRohSchrift.aufmacher.copyWith(color: MRoh.tinte);
  static final zwischentitel = MRohSchrift.zwischentitel.copyWith(color: MRoh.tinteLeise);
  static final kursiv = MRohSchrift.kursiv.copyWith(color: MRoh.tinte);
  static final maschine = MRohSchrift.schreibmaschine.copyWith(color: MRoh.tinte);
  static final telegramm = MRohSchrift.telegramm.copyWith(color: MRoh.tinte);
  static final hand = MRohSchrift.handschrift;
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

  /// Farben des nächsten [Theme]; ohne Erweiterung der Grundton. Auf Papier
  /// ([MFlaeche] hell) die Tintenfarben ([aufPapier]).
  static MFarben von(BuildContext context) {
    final f = Theme.of(context).extension<MFarben>() ?? mordakte;
    return MFlaeche.hellVon(context) ? f.aufPapier() : f;
  }

  /// Dieselben Rollen auf hellem Papier: Text wird Tinte, Akzente werden zur
  /// dunklen Akzenttinte, Flächen werden Papiertöne. So lesen Bildschirme, die
  /// `papier` als Schriftfarbe nehmen, auf einem Blatt automatisch richtig.
  MFarben aufPapier() {
    final tinteAkzent = Color.lerp(akzent, MRoh.tinte, 0.5)!;
    return copyWith(
      grund: MRoh.karteikarte,
      grund2: MRoh.blatt,
      flaeche: Color.lerp(MRoh.blatt, MRoh.blattSchatten, 0.45),
      flaecheHoch: Color.lerp(MRoh.blatt, MRoh.blattSchatten, 0.75),
      linie: MRoh.tinte.withValues(alpha: 0.18),
      linieStark: MRoh.tinte.withValues(alpha: 0.38),
      papier: MRoh.tinte,
      papierLeise: MRoh.tinteLeise,
      tinte: MRoh.tinte,
      akzent: tinteAkzent,
      akzentHell: tinteAkzent,
      akzentSchwach: akzent.withValues(alpha: 0.22),
      akzent2: Color.lerp(akzent2, MRoh.tinte, 0.45),
      gefahr: MRoh.stempelRot,
      erfolg: const Color(0xFF2F6B37),
      warnung: const Color(0xFF9A5B12),
      geist: const Color(0xFF2F6F76),
    );
  }

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

/// Schriften des Spiels als ThemeExtension: Playfair Display für Titel, Lora für
/// Lesetext, Special Elite für Schreibmaschine, Caveat für Handschrift, Inter für
/// kleine Bedientexte. Auf Papier ([MFlaeche] hell) in Tintenfarben.
@immutable
class MSchrift extends ThemeExtension<MSchrift> {
  const MSchrift({
    this.titel = MRohSchrift.titel,
    this.ueberschrift = MRohSchrift.ueberschrift,
    this.text = MRohSchrift.fliesstext,
    this.leise = MRohSchrift.leise,
    this.marke = MRohSchrift.marke,
    this.erzaehler = MRohSchrift.erzaehler,
    this.aufmacher = MRohSchrift.aufmacher,
    this.zwischentitel = MRohSchrift.zwischentitel,
    this.kursiv = MRohSchrift.kursiv,
    this.maschine = MRohSchrift.schreibmaschine,
    this.telegramm = MRohSchrift.telegramm,
    this.hand = MRohSchrift.handschrift,
    this.knopf = MRohSchrift.knopf,
  });

  static const standard = MSchrift();

  /// Schriften mit den Farben von [f] (eine Akte färbt Titel und Marke um).
  factory MSchrift.fuer(MFarben f) => MSchrift(
        titel: MRohSchrift.titel.copyWith(color: f.akzentHell),
        ueberschrift: MRohSchrift.ueberschrift.copyWith(color: f.papier),
        text: MRohSchrift.fliesstext.copyWith(color: f.papier),
        leise: MRohSchrift.leise.copyWith(color: f.papierLeise),
        marke: MRohSchrift.marke.copyWith(color: f.akzent),
        erzaehler: MRohSchrift.erzaehler.copyWith(color: f.papier),
        aufmacher: MRohSchrift.aufmacher.copyWith(color: f.papier),
        zwischentitel: MRohSchrift.zwischentitel.copyWith(color: f.papier),
        kursiv: MRohSchrift.kursiv.copyWith(color: f.papier),
        maschine: MRohSchrift.schreibmaschine.copyWith(color: f.papier),
        telegramm: MRohSchrift.telegramm.copyWith(color: f.papier),
        hand: MRohSchrift.handschrift.copyWith(color: f.papier == MRoh.tinte ? MRoh.tinteBlau : MRoh.akzentHell),
        knopf: MRohSchrift.knopf,
      );

  /// Titel: Playfair Display 30, fett.
  final TextStyle titel;

  /// Überschrift: Playfair Display 22, fett.
  final TextStyle ueberschrift;

  /// Fließtext: Lora 17.
  final TextStyle text;

  /// Leiser Text: Inter 14.
  final TextStyle leise;

  /// Marke (Kapitälchen-Zeile): Inter 12 halbfett, Zeichenabstand 1,2.
  final TextStyle marke;

  /// Erzählertext: Lora 20, Zeilenhöhe 1,6.
  final TextStyle erzaehler;

  /// Schlagzeile, Aktendeckel, Urteil: Playfair Display 40.
  final TextStyle aufmacher;

  /// Abschnitts- und Formularköpfe: Special Elite 15.
  final TextStyle zwischentitel;

  /// Aussagen und Zitate: Lora kursiv 17.
  final TextStyle kursiv;

  /// Etiketten, Aktenzeichen: Special Elite 15.
  final TextStyle maschine;

  /// Telegramm: Courier Prime 15.
  final TextStyle telegramm;

  /// Randnotiz des Detektivs: Caveat 21.
  final TextStyle hand;

  /// Beschriftung der Messingschilder: Playfair Display 17.
  final TextStyle knopf;

  /// Schriften des nächsten [Theme]; auf Papier in Tintenfarben.
  static MSchrift von(BuildContext context) {
    if (MFlaeche.hellVon(context)) return MSchrift.fuer(MFarben.von(context));
    return Theme.of(context).extension<MSchrift>() ?? standard;
  }

  @override
  MSchrift copyWith({
    TextStyle? titel,
    TextStyle? ueberschrift,
    TextStyle? text,
    TextStyle? leise,
    TextStyle? marke,
    TextStyle? erzaehler,
    TextStyle? aufmacher,
    TextStyle? zwischentitel,
    TextStyle? kursiv,
    TextStyle? maschine,
    TextStyle? telegramm,
    TextStyle? hand,
    TextStyle? knopf,
  }) =>
      MSchrift(
        titel: titel ?? this.titel,
        ueberschrift: ueberschrift ?? this.ueberschrift,
        text: text ?? this.text,
        leise: leise ?? this.leise,
        marke: marke ?? this.marke,
        erzaehler: erzaehler ?? this.erzaehler,
        aufmacher: aufmacher ?? this.aufmacher,
        zwischentitel: zwischentitel ?? this.zwischentitel,
        kursiv: kursiv ?? this.kursiv,
        maschine: maschine ?? this.maschine,
        telegramm: telegramm ?? this.telegramm,
        hand: hand ?? this.hand,
        knopf: knopf ?? this.knopf,
      );

  @override
  MSchrift lerp(ThemeExtension<MSchrift>? other, double t) {
    if (other is! MSchrift) return this;
    TextStyle l(TextStyle a, TextStyle b) => TextStyle.lerp(a, b, t)!;
    return MSchrift(
      titel: l(titel, other.titel),
      ueberschrift: l(ueberschrift, other.ueberschrift),
      text: l(text, other.text),
      leise: l(leise, other.leise),
      marke: l(marke, other.marke),
      erzaehler: l(erzaehler, other.erzaehler),
      aufmacher: l(aufmacher, other.aufmacher),
      zwischentitel: l(zwischentitel, other.zwischentitel),
      kursiv: l(kursiv, other.kursiv),
      maschine: l(maschine, other.maschine),
      telegramm: l(telegramm, other.telegramm),
      hand: l(hand, other.hand),
      knopf: l(knopf, other.knopf),
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
