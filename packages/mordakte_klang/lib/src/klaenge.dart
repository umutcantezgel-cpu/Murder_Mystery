import 'dart:math' as math;
import 'dart:typed_data';

import 'synth.dart';

/// Kurze Klänge (Dateiname ohne Endung → Erzeuger). Varianten tragen eine
/// Ziffer (`tippen1`, `tippen2` …), damit Wiederholungen nicht mechanisch
/// klingen.
final Map<String, Float64List Function()> klangKatalog = {
  'knopf': knopf,
  'blatt': blatt,
  'stempel': stempel,
  for (var v = 1; v <= 3; v++) 'tippen$v': () => tippen(v),
  'glocke': glocke,
  for (var v = 1; v <= 2; v++) 'schritt_stein$v': () => schrittStein(v),
  for (var v = 1; v <= 2; v++) 'schritt_kies$v': () => schrittKies(v),
  for (var v = 1; v <= 2; v++) 'schritt_schnee$v': () => schrittSchnee(v),
  for (var v = 1; v <= 2; v++) 'schritt_holz$v': () => schrittHolz(v),
  'tuer': tuer,
  'wuerfel': wuerfel,
  'siegel': siegel,
  'erfolg': erfolg,
  'pech': pech,
  'donner': donner,
};

/// Atmosphären je Akte: nahtlose Schleifen von acht Sekunden.
final Map<String, Float64List Function()> atmosphaerenKatalog = {
  'atmo_keller': atmoKeller,
  'atmo_wind': atmoWind,
  'atmo_regen': atmoRegen,
  'atmo_zug': atmoZug,
  'atmo_neon': atmoNeon,
};

// --- Bedienung ---------------------------------------------------------------

/// Messingschild: kurzer, warmer Klick mit Nachklang.
Float64List knopf() {
  final s = Spur(0.09);
  final z = KlangZufall(11);
  final bp = Biquad.bandpass(3400, q: 2.2);
  s.mische(0, s.laenge, (i, t) {
    final klick = bp.schritt(z.rauschen()) * abkling(t, 0.004) * 1.4;
    final ring = math.sin(2 * math.pi * 1780 * t) * abkling(t, 0.012) * 0.45;
    final dumpf = math.sin(2 * math.pi * 170 * t) * abkling(t, 0.018) * 0.35;
    return klick + ring + dumpf;
  });
  return s.fertig(ziel: 0.8);
}

/// Ein Blatt wird umgeschlagen: Rascheln mit Knistern.
Float64List blatt() {
  final s = Spur(0.32);
  final z = KlangZufall(23);
  final bp = Biquad.bandpass(3200, q: 0.7);
  final hp = Biquad.hochpass(900);
  var knister = 0.0;
  s.mische(0, s.laenge, (i, t) {
    final schwung = math.sin(math.pi * math.min(1.0, t / 0.3));
    if (z.naechste() < 0.012) knister = 1;
    knister *= 0.93;
    final r = bp.schritt(z.rauschen());
    return hp.schritt(r * (0.35 * schwung + knister * 0.9));
  });
  return s.fertig(ziel: 0.7);
}

/// Gummistempel: dumpfer Schlag mit kurzem Holzklopfen.
Float64List stempel() {
  final s = Spur(0.24);
  final z = KlangZufall(31);
  final tp = Biquad.tiefpass(1200);
  final holz = Biquad.bandpass(620, q: 4);
  var phase = 0.0;
  s.mische(0, s.laenge, (i, t) {
    final f = 60 + 40 * abkling(t, 0.03);
    phase += 2 * math.pi * f / klangRate;
    final schlag = math.sin(phase) * abkling(t, 0.07);
    final klick = tp.schritt(z.rauschen()) * abkling(t, 0.006) * 0.8;
    final klopf = holz.schritt(z.rauschen()) * abkling(t, 0.02) * 1.6;
    return schlag + klick + klopf;
  });
  s.hall(mix: 0.12, raum: 0.6);
  return s.fertig();
}

/// Schreibmaschinentaste: harter Anschlag, metallischer Typenhebel.
Float64List tippen(int v) {
  final s = Spur(0.08);
  final z = KlangZufall(40 + v);
  final hp = Biquad.hochpass(2200);
  final thock = Biquad.bandpass(850 + v * 70, q: 3);
  final f1 = 2350.0 + v * 180, f2 = 3720.0 - v * 140;
  s.mische(0, s.laenge, (i, t) {
    final an = hp.schritt(z.rauschen()) * abkling(t, 0.0018) * 1.2;
    final ring = (math.sin(2 * math.pi * f1 * t) + 0.6 * math.sin(2 * math.pi * f2 * t)) * abkling(t, 0.02) * 0.25;
    final tief = thock.schritt(z.rauschen()) * abkling(t, 0.012) * 1.4;
    return an + ring + tief;
  });
  return s.fertig(ziel: 0.75);
}

/// Glocke der Schreibmaschine am Zeilenende: für Enthüllungen.
Float64List glocke() {
  final s = Spur(1.3);
  const grund = 2093.0;
  const teile = [(1.0, 1.0, 0.9), (2.0, 0.5, 0.55), (2.76, 0.35, 0.4), (5.4, 0.15, 0.2)];
  s.mische(0, s.laenge, (i, t) {
    var v = 0.0;
    for (final (r, a, tau) in teile) {
      v += math.sin(2 * math.pi * grund * r * t) * a * abkling(t, tau);
    }
    return v * huelle(t, 0.002, 2);
  });
  s.hall(mix: 0.2);
  return s.fertig(ziel: 0.6);
}

// --- Welt ----------------------------------------------------------------------

Float64List schrittStein(int v) {
  final s = Spur(0.14);
  final z = KlangZufall(60 + v);
  final tp = Biquad.tiefpass(420 + v * 60);
  final hp = Biquad.hochpass(2500);
  s.mische(0, s.laenge, (i, t) {
    final ferse = tp.schritt(z.rauschen()) * abkling(t, 0.025) * 2.2;
    final klick = hp.schritt(z.rauschen()) * abkling(t, 0.003) * 0.5;
    final ballen = t > 0.045 ? tp.schritt(z.rauschen()) * abkling(t - 0.045, 0.02) * 1.0 : 0.0;
    return ferse + klick + ballen;
  });
  s.hall(mix: 0.18, raum: 0.7);
  return s.fertig(ziel: 0.7);
}

Float64List schrittKies(int v) {
  final s = Spur(0.18);
  final z = KlangZufall(70 + v);
  final bp = Biquad.bandpass(2400 + v * 300, q: 0.9);
  var korn = 0.0;
  s.mische(0, s.laenge, (i, t) {
    final dichte = 0.08 * huelle(t, 0.02, 0.06);
    if (z.naechste() < dichte) korn = 0.6 + z.naechste() * 0.4;
    korn *= 0.88;
    return bp.schritt(z.rauschen()) * korn * 1.8;
  });
  return s.fertig(ziel: 0.65);
}

Float64List schrittSchnee(int v) {
  final s = Spur(0.2);
  final z = KlangZufall(80 + v);
  final tp = Biquad.tiefpass(1500 + v * 200);
  var korn = 0.0;
  s.mische(0, s.laenge, (i, t) {
    final dichte = 0.12 * huelle(t, 0.04, 0.07);
    if (z.naechste() < dichte) korn = 0.5 + z.naechste() * 0.5;
    korn *= 0.9;
    final knirschen = tp.schritt(z.rauschen()) * korn * 1.4;
    final quietschen = math.sin(2 * math.pi * (900 + v * 60) * t) * 0.06 * huelle(t, 0.05, 0.04);
    return knirschen + quietschen;
  });
  return s.fertig(ziel: 0.55);
}

Float64List schrittHolz(int v) {
  final s = Spur(0.16);
  final z = KlangZufall(90 + v);
  final hohl = Biquad.bandpass(260 + v * 40, q: 5);
  final hp = Biquad.hochpass(1800);
  s.mische(0, s.laenge, (i, t) {
    final klopf = hohl.schritt(z.rauschen()) * abkling(t, 0.04) * 3.2;
    final klick = hp.schritt(z.rauschen()) * abkling(t, 0.004) * 0.4;
    return klopf + klick;
  });
  s.hall(mix: 0.15, raum: 0.65);
  return s.fertig(ziel: 0.7);
}

/// Tür schwingt auf: knarrende Angel (Haftgleiten) und ein leises Ausschwingen.
Float64List tuer() {
  final s = Spur(0.75);
  final z = KlangZufall(101);
  final bp = Biquad.bandpass(780, q: 3);
  var phase = 0.0, ruck = 0.0;
  s.mische(0, s.laenge, (i, t) {
    final f = 170 + 70 * math.sin(t * 5.3) + 40 * math.sin(t * 13.1);
    phase += 2 * math.pi * f / klangRate;
    if (z.naechste() < 0.004) ruck = 1;
    ruck *= 0.995;
    final saege = ((phase / (2 * math.pi)) % 1) * 2 - 1;
    final knarren = bp.schritt(saege * (0.5 + 0.5 * ruck)) * math.sin(math.pi * math.min(1.0, t / 0.7));
    return knarren * 1.5;
  });
  s.hall(mix: 0.18, raum: 0.7);
  return s.fertig(ziel: 0.5);
}

/// Würfel auf dem Brett: mehrere Aufschläge mit kürzer werdenden Abständen.
Float64List wuerfel() {
  final s = Spur(0.8);
  final z = KlangZufall(111);
  var zeit = 0.0, abstand = 0.12, staerke = 1.0;
  // Höchstens zehn Aufschläge; die Abstände werden kürzer, bis er liegt.
  for (var n = 0; n < 10 && zeit < 0.62 && abstand > 0.012; n++) {
    final ab = (zeit * klangRate).round();
    final bp = Biquad.bandpass(2600 + z.naechste() * 1400, q: 2.5);
    final holz = Biquad.bandpass(700 + z.naechste() * 300, q: 4);
    final f = 2900 + z.naechste() * 900;
    final st = staerke;
    s.mische(ab, (0.06 * klangRate).round(), (i, t) {
      final klack = bp.schritt(z.rauschen()) * abkling(t, 0.004) * 1.4;
      final ring = math.sin(2 * math.pi * f * t) * abkling(t, 0.01) * 0.3;
      final brett = holz.schritt(z.rauschen()) * abkling(t, 0.015) * 0.9;
      return (klack + ring + brett) * st;
    });
    zeit += abstand * (0.7 + z.naechste() * 0.6);
    abstand *= 0.78;
    staerke *= 0.82;
  }
  s.hall(mix: 0.1, raum: 0.6);
  return s.fertig(ziel: 0.75);
}

/// Siegel bricht, Umschlag wird geöffnet: Knacken und Reißen.
Float64List siegel() {
  final s = Spur(0.5);
  final z = KlangZufall(121);
  final hp = Biquad.hochpass(1500);
  final bp = Biquad.bandpass(2600, q: 0.8);
  var riss = 0.0;
  s.mische(0, s.laenge, (i, t) {
    final knack = hp.schritt(z.rauschen()) * abkling(t, 0.006) * 1.5;
    if (t > 0.08 && z.naechste() < 0.03) riss = 0.4 + z.naechste() * 0.6;
    riss *= 0.96;
    final reissen = t > 0.08 ? bp.schritt(z.rauschen()) * (riss * 0.8 + 0.15) * math.sin(math.pi * math.min(1.0, (t - 0.08) / 0.4)) : 0.0;
    return knack + reissen;
  });
  return s.fertig(ziel: 0.7);
}

double _ton(double f, double t) => math.sin(2 * math.pi * f * t) + 0.35 * math.sin(4 * math.pi * f * t) + 0.12 * math.sin(6 * math.pi * f * t);

/// Warmer Akkord (Cmaj7), der anschwillt: geschafft.
Float64List erfolg() {
  final s = Spur(1.6);
  const noten = [261.63, 329.63, 392.0, 493.88];
  s.mische(0, s.laenge, (i, t) {
    var v = 0.0;
    for (var k = 0; k < noten.length; k++) {
      final ein = t - k * 0.06;
      if (ein < 0) continue;
      v += _ton(noten[k] * (1 + 0.002 * math.sin(ein * 5)), ein) * huelle(ein, 0.25, 0.55);
    }
    return v * 0.25;
  });
  s.hall(mix: 0.3);
  return s.fertig(ziel: 0.6);
}

/// Absteigende kleine Terz, leise und dunkel: Pech gehabt.
Float64List pech() {
  final s = Spur(1.3);
  s.mische(0, s.laenge, (i, t) {
    final zittern = 1 + 0.08 * math.sin(2 * math.pi * 6 * t);
    // Die erste Note klingt aus, während die zweite einsetzt (kein Knacken).
    final erste = _ton(196.0, t) * huelle(t, 0.04, 0.25);
    final zweite = t < 0.32 ? 0.0 : _ton(155.56, t - 0.32) * huelle(t - 0.32, 0.04, 0.45);
    return (erste + zweite) * zittern * 0.4;
  });
  s.hall(mix: 0.25);
  return s.fertig(ziel: 0.55);
}

/// Donner: Krachen, dann langes Grollen mit Schwellen.
Float64List donner() {
  final s = Spur(3.6);
  final z = KlangZufall(131);
  final braun = BraunRauschen(z);
  final tp = Biquad.tiefpass(180);
  final tp2 = Biquad.tiefpass(90);
  final hp = Biquad.hochpass(700);
  s.mische(0, s.laenge, (i, t) {
    final krach = hp.schritt(z.rauschen()) * abkling(t, 0.06) * 0.8;
    final schwellen = 0.6 + 0.4 * math.sin(t * 3.1) * math.sin(t * 1.7 + 1);
    final grollen = tp2.schritt(tp.schritt(braun.schritt())) * huelle(t, 0.15, 1.1) * schwellen * 3.5;
    return krach + grollen;
  });
  return s.fertig(ziel: 0.85);
}

// --- Atmosphären -----------------------------------------------------------------

const double _schleife = 8.0;
const double _blende = 0.6;

/// Kellergewölbe: Raumton, fernes Brummen, Wassertropfen mit Echo.
Float64List atmoKeller() {
  final s = Spur(_schleife + _blende);
  final z = KlangZufall(201);
  final tp = Biquad.tiefpass(260);
  s.mische(0, s.laenge, (i, t) {
    final raum = tp.schritt(z.rauschen()) * 0.5;
    final brumm = (math.sin(2 * math.pi * 50 * t) + 0.5 * math.sin(2 * math.pi * 100 * t)) * 0.04;
    return raum + brumm;
  });
  var zeit = 0.4;
  while (zeit < _schleife + _blende) {
    final ab = (zeit * klangRate).round();
    final f = 1300 + z.naechste() * 900;
    final a = 0.2 + z.naechste() * 0.25;
    for (final (verz, k) in [(0.0, 1.0), (0.13, 0.35), (0.26, 0.12)]) {
      s.mische(ab + (verz * klangRate).round(), (0.12 * klangRate).round(), (i, t) {
        final fp = f * (1 + 0.6 * abkling(t, 0.01));
        return math.sin(2 * math.pi * fp * t) * abkling(t, 0.035) * a * k;
      });
    }
    zeit += 0.9 + z.naechste() * 1.8;
  }
  return s.schleife(_schleife, blende: _blende, ziel: 0.5);
}

/// Wind über dem Burgfels: wandernder Bandpass, Böen, leises Pfeifen.
Float64List atmoWind() {
  final s = Spur(_schleife + _blende);
  final z = KlangZufall(211);
  final braun = BraunRauschen(z);
  // Der Bandpass wird alle 64 Proben neu gestimmt (langsames Wandern).
  var bp = Biquad.bandpass(500, q: 1.4);
  final tp = Biquad.tiefpass(2500);
  s.mische(0, s.laenge, (i, t) {
    if (i % 64 == 0) {
      final f = 420 + 260 * math.sin(2 * math.pi * t / _schleife) + 140 * math.sin(2 * math.pi * 3 * t / _schleife + 1);
      bp = Biquad.bandpass(f, q: 1.4);
    }
    final boe = 0.55 + 0.45 * math.sin(2 * math.pi * 2 * t / _schleife + 0.5) * math.sin(2 * math.pi * 5 * t / _schleife);
    final rausch = 0.6 * braun.schritt() + 0.4 * z.rauschen();
    final pfeifen = math.sin(2 * math.pi * (1050 + 40 * math.sin(t * 4)) * t) * 0.025 * math.max(0.0, boe - 0.6);
    return tp.schritt(bp.schritt(rausch)) * boe * 2.2 + pfeifen;
  });
  return s.schleife(_schleife, blende: _blende, ziel: 0.55);
}

/// Gewitterregen am Herrenhaus: dichtes Rauschen, Tropfen, fernes Grollen.
Float64List atmoRegen() {
  final s = Spur(_schleife + _blende);
  final z = KlangZufall(221);
  final braun = BraunRauschen(z);
  final hp = Biquad.hochpass(450);
  final tp = Biquad.tiefpass(6500);
  final tief = Biquad.tiefpass(140);
  final tropfen = Biquad.bandpass(4200, q: 2);
  var tropf = 0.0;
  s.mische(0, s.laenge, (i, t) {
    final regen = tp.schritt(hp.schritt(z.rauschen())) * 0.5;
    if (z.naechste() < 0.0025) tropf = 0.5 + z.naechste() * 0.5;
    tropf *= 0.93;
    final tr = tropfen.schritt(z.rauschen()) * tropf * 1.2;
    final grollen = tief.schritt(braun.schritt()) * (0.5 + 0.5 * math.sin(2 * math.pi * t / _schleife)) * 0.8;
    return regen + tr + grollen;
  });
  return s.schleife(_schleife, blende: _blende, ziel: 0.5);
}

/// Nachtzug am Bahnsteig: Brummen des Wagens, Lüftung, ein Bremsseufzer.
Float64List atmoZug() {
  final s = Spur(_schleife + _blende);
  final z = KlangZufall(231);
  final tp = Biquad.tiefpass(320);
  final hp = Biquad.hochpass(3000);
  final seufzer = Biquad.bandpass(1800, q: 0.8);
  s.mische(0, s.laenge, (i, t) {
    final brumm = (math.sin(2 * math.pi * 42 * t) * 0.5 + math.sin(2 * math.pi * 84 * t) * 0.3 + math.sin(2 * math.pi * 126 * t) * 0.12) *
        (0.85 + 0.15 * math.sin(2 * math.pi * 0.5 * t));
    final luft = hp.schritt(z.rauschen()) * 0.06 + tp.schritt(z.rauschen()) * 0.3;
    final seufz = (t > 3.5 && t < 5.2) ? seufzer.schritt(z.rauschen()) * math.sin(math.pi * (t - 3.5) / 1.7) * 0.35 : 0.0;
    return brumm * 0.25 + luft + seufz;
  });
  return s.schleife(_schleife, blende: _blende, ziel: 0.5);
}

/// Motel am Highway: Neonbrummen, feiner Regen, vorbeirauschende Autos.
Float64List atmoNeon() {
  final s = Spur(_schleife + _blende);
  final z = KlangZufall(241);
  final hp = Biquad.hochpass(600);
  final tp = Biquad.tiefpass(5000);
  final auto = Biquad.bandpass(700, q: 0.6);
  s.mische(0, s.laenge, (i, t) {
    final flackern = 0.8 + 0.2 * math.sin(2 * math.pi * 0.7 * t) * math.sin(2 * math.pi * 2.9 * t);
    var summen = 0.0;
    for (var k = 1; k <= 6; k++) {
      summen += math.sin(2 * math.pi * 120 * k * t) / (k * k);
    }
    final regen = tp.schritt(hp.schritt(z.rauschen())) * 0.22;
    // Zwei Autos je Schleife: anschwellen und abklingen.
    double vorbei(double mitte) => math.exp(-math.pow((t - mitte) / 0.7, 2).toDouble());
    final verkehr = auto.schritt(z.rauschen()) * (vorbei(2.2) + 0.7 * vorbei(6.1)) * 0.9;
    return summen * 0.06 * flackern + regen + verkehr;
  });
  return s.schleife(_schleife, blende: _blende, ziel: 0.5);
}
