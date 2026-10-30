import 'dart:io' show Platform;
import 'dart:typed_data';
import 'dart:ui' show Rect;

import 'package:flutter/foundation.dart' show visibleForTesting;

import '../l10n/gen/app_localizations_de.dart';
import 'datei_speichern.dart';
import 'datei_teilen.dart';

final _de = LDe();

/// Läuft die App auf Android? Nur dort gibt es neben dem Teilen einen Download,
/// den Speichern-Dialog des Systems (`datei_speichern.dart`). Bewusst über
/// `dart:io`, nicht über `defaultTargetPlatform`: Das ist in Widget-Tests immer
/// Android und stellte jeden App-Test auf zwei Tipps um. Tests spielen Android
/// hier nach.
@visibleForTesting
bool aufAndroid = Platform.isAndroid;

/// In der App: Mit [teilen] geht die Datei an das Teilen des Systems. Ohne
/// [teilen] öffnet Android den Speichern-Dialog („Herunterladen“); iOS und der
/// Rechner haben keinen Download und teilen auch dann (auf iOS bietet das
/// Teilen-Fenster „In Dateien sichern“ und „Drucken“).
Future<bool> dateiAnbieten(String name, Uint8List bytes, {String typ = 'application/pdf', Rect? ursprung, bool teilen = true}) =>
    !teilen && aufAndroid
        ? dateiSpeichern(name, bytes, typ: typ, gespeichert: _de.druck_datei_gespeichert(name))
        : dateiTeilen(name, bytes, typ: typ, ursprung: ursprung);

/// Auf Android wartet die fertige Datei auf einen eigenen Tipp: „Herunterladen“
/// oder „Teilen“. Sonst geht sie gleich an das Teilen des Systems.
bool get zweiterTipp => aufAndroid;

/// Einen Download gibt es in der App nur auf Android.
bool get kannHerunterladen => aufAndroid;

/// Auf Android öffnet „Herunterladen“ erst einen Dialog: Ort wählen, dann speichern.
bool get herunterladenMitDialog => aufAndroid;

bool dateiTeilbar(String name, String typ) => true;
