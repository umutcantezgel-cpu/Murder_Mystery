/// Speicher pro Browser-Tab für Online-Plätze: Im Web teilen sich alle Tabs
/// derselben Seite `localStorage`; zwei Gäste in zwei Tabs würden dort denselben
/// Schlüssel und damit denselben Platz im Raum beanspruchen. `sessionStorage`
/// gehört dagegen genau einem Tab (und überlebt das Neuladen). Außerhalb des Webs
/// gibt es diesen Speicher nicht ([tabSpeicherDa] ist `false`).
library;

export 'ablage_tab_stub.dart' if (dart.library.js_interop) 'ablage_tab_web.dart';
