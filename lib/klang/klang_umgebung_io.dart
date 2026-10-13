import 'dart:io';

/// Läuft der Code unter `flutter test`? Dann bleibt der Ton aus.
bool get laeuftImTest => Platform.environment.containsKey('FLUTTER_TEST');
