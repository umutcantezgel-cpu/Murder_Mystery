// Abgleich Bild ↔ Text für die Porträts des Schlosskellers (Druckpaket): Was der Zeichner
// aus dem Aussehen ableitet (Frisur, Brille, Bart, Schal, Krawatte, Kopfbedeckung), muss zu
// dem passen, was Kostümtipp, Alltag und Aussehen der Figur sagen. Spiel und Druck nutzen
// denselben Zeichner ([aussehenAus]); ein Widerspruch fiele also in beiden auf.
import 'package:mordakte/game/scene/figur_rig.dart';
import 'package:mordakte_core/mordakte_core.dart';

/// Der Detektiv als Detektivin (`w`) oder Detektiv (`m`): Aussehen aus dem Kanon, dazu das
/// Geschlecht für die Darstellung. `m` zeichnet genau die Figur des Spiels.
LookDef detektivLook(Map<String, Object?> detektiv, String g) => LookDef.fromJson({...renderLook(detektiv), 'gender': g});

/// Trägt die Büste eine Krawatte? (Wie [PortraitPainter]: Männer im Anzugschnitt, außer jede vierte Variante.)
bool krawatte(FigurAussehen a) => !a.kleid && !a.weiblich && a.variante % 4 != 1;

/// Merkmale einer Büste als lesbare Wörter, für Befunde.
Map<String, Object> merkmale(FigurAussehen a) => {
      'frisur': a.frisur.name,
      'brille': a.brille,
      'bart': a.bart,
      'schal': a.schal,
      'krawatte': krawatte(a),
      'kopf': a.hut,
    };

/// Befunde: Wo widerspricht die Büste [a] dem [text] (Kostümtipp, Alltag, Aussehen der Figur)?
/// Leer heißt: Bild und Text passen. Was der Text nicht erwähnt, darf das Bild nicht zeigen,
/// soweit es ein auffälliges Merkmal ist (Brille, Bart, Schal, Krawatte); Frisuren nur, wenn
/// der Text eine nennt.
List<String> widersprueche(FigurAussehen a, String text) {
  bool nennt(String muster) => RegExp(muster, caseSensitive: false, unicode: true).hasMatch(text);
  final b = <String>[];
  if (nennt(r'Brille') != a.brille) b.add(a.brille ? 'Bild mit Brille, Text ohne' : 'Text mit Brille, Bild ohne');
  if (nennt(r'\bBart') != (a.bart > 0)) b.add(a.bart > 0 ? 'Bild mit Bart, Text ohne' : 'Text mit Bart, Bild ohne');
  if (nennt(r'kurze[rn]? Bart') && a.bart != 2) b.add('Text: kurzer Bart, Bild: ${a.bart == 1 ? 'nur Schnurrbart' : 'kein Bart'}');
  if (nennt(r'Schal\b') != a.schal) b.add(a.schal ? 'Bild mit Schal, Text ohne' : 'Text mit Schal, Bild ohne');
  if (krawatte(a) && !nennt(r'Krawatte')) b.add('Bild mit Krawatte, Text ohne');
  if (nennt(r'Kopftuch') != (a.hut == 'kopftuch')) b.add('Kopftuch: Text und Bild uneins');
  if (nennt(r'Kappe|Mütze') != (a.hut == 'cap')) b.add('Kappe: Text und Bild uneins');
  if (nennt(r'Dutt') != (a.hut == 'bun')) b.add('Dutt: Text und Bild uneins');
  if (nennt(r'Hut\b') != (a.hut == 'fedora')) b.add('Hut: Text und Bild uneins');
  if (nennt(r'lockig|Locken') && a.frisur != Frisur.locken) b.add('Text: Locken, Bild: ${a.frisur.name}');
  if (nennt(r'lange[n]? (schwarze[n]? )?Haare') && a.frisur != Frisur.lang) b.add('Text: lange Haare, Bild: ${a.frisur.name}');
  if (nennt(r'Zopf') && a.frisur != Frisur.zopf) b.add('Text: Zopf, Bild: ${a.frisur.name}');
  if (a.frisur == Frisur.glatze && !nennt(r'Glatze')) b.add('Bild mit Glatze, Text ohne');
  return b;
}

/// Was über das Aussehen einer Figur geschrieben steht: Kostümtipp aus den Steckbriefen,
/// Alltag und das Aussehen im Kanon (`visualSpecs`, nur zum Abgleich, nie im Druck).
String aussehenText(Map<String, Object?> figur, String? kostuem) {
  final v = (figur['visualSpecs'] as Map?)?.cast<String, Object?>() ?? const {};
  return [
    kostuem ?? '',
    figur['alltag'] ?? '',
    v['silhouette'] ?? '',
    v['outfit'] ?? v['baseOutfit'] ?? '',
    v['distinguishingFeature'] ?? '',
    ...((v['accessories'] as List?) ?? const []),
  ].join(' · ');
}
