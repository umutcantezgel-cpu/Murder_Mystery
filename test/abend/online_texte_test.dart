// Nachschliff M3: eigene Fehlertexte für die Sitz-Codes des Raums und die
// Texte des Erzähler-Begleiters (echter Knopfname, Fehler am eigenen Gerät).
import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte/abend/online/online_fehler.dart';
import 'package:mordakte/l10n/gen/app_localizations_de.dart';

void main() {
  final l = LDe();

  test('Sitz-Codes des Raums haben eigene Texte, nicht den allgemeinen', () {
    expect(befehlsFehlerText(l, 'seats'), l.online_fehler_sitze);
    expect(befehlsFehlerText(l, 'not_detective'), l.online_fehler_nur_detektiv);
    expect(befehlsFehlerText(l, 'not_host'), l.online_fehler_nicht_leitung);
    for (final code in ['seats', 'not_detective', 'not_host']) {
      expect(befehlsFehlerText(l, code), isNot(l.online_fehler_allgemein), reason: code);
    }
    expect(befehlsFehlerText(l, 'unbekannt'), l.online_fehler_allgemein);
  });

  test('Begleiter: Die Anleitung nennt den Knopf der Detektei, der Fehler das eigene Gerät', () {
    expect(l.begleiter_anleitung('Mia'), contains('„${l.detektei_beitreten}“'));
    expect(l.begleiter_fehler, isNot(contains('Handy')));
    expect(l.begleiter_fehler, contains('Gerät'));
  });
}
