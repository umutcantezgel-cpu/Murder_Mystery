# Erzählregeln für Gespräche mit Wahl (M6)

Gespräche mit Wahl bringen Mehrfachauswahl-Dialoge, Ereignisketten und Epiloge in den Abend. Sie dürfen das Rätsel nie verraten oder verzerren. Diese Regeln gelten für den Kern `packages/mordakte_core/lib/src/erzaehlung/`, die Inhalte `content/erzaehlung/<akte>/` und die Darstellung in der App. Ein Prüfer und Architekturtests setzen sie durch.

## Fairness

- **R1 · Pfadfrei.**
  - Ob ein Dialog verfügbar ist, welche Knoten er hat und wie seine Texte lauten, hängt nur von der `ErzaehlUmwelt` ab.
  - Die `ErzaehlUmwelt` enthält Akte, Runde, Erzähltiefe, gesammelte Hinweise und die eigenen Flags des Abends.
  - Sie enthält keinen Täterpfad, keinen Fall-Code und keine Wertung.
  - Der Prüfer spielt jeden Dialog für alle Pfade einer Akte durch und verlangt gleiche Graphen.
- **R2 · Kein Verrat.**
  - Dialoge nennen nur Tatsachen, die im Kanon für alle Pfade gleich sind: Alibi-Rahmen, Orte, Zeiten, Beziehungen und öffentliche Gerüchte.
  - Pfadabhängige Wahrheiten (wer, warum, womit) kommen nur in Epilogen nach dem Finale vor.
- **R3 · Gleiche Gestalt.**
  - Jede befragbare Figur hat einen Dialog gleicher Bauart: dieselbe Zahl an Haltungen und dieselbe Tiefe innerhalb fester Grenzen.
  - Kein Dialog ist auffällig länger, kürzer oder seltsamer. Auch die Täterfigur fällt nicht auf.
- **R4 · Keine Wertung.**
  - Dialoge, Ereignisse und Flags schreiben nie in die Wertung, in die Würfel oder in die Ergebnisse der Entscheidungen.
  - Sie entscheiden nicht, wer gewinnt.

## Zeit und Zufall

- **R5 · Keine Nachtminuten.** Dialog, Ereignis und Folgeentscheidung kosten keine Spielzeit; die Rundenuhr läuft wie heute.
- **R6 · Kein Zufall.**
  - Dialoge würfeln nicht und nutzen keine Zufallsquelle.
  - Die Architekturprüfung verbietet in `erzaehlung/**` jeden Zugriff auf Würfelquelle, Modifikator und Nachtminuten.
- **R7 · Vertrauen und Druck wirken nur auf die Knotenwahl.** Die Haltungen *freundlich*, *drängen*, *bluffen* und *vorlegen* verschieben Vertrauen und Druck einer Figur. Diese Werte entscheiden nur, welcher Folgeknoten kommt.
- **R8 · Vorlegen braucht ein Indiz.** *Vorlegen* ist nur mit einem Hinweis möglich, den die Gruppe wirklich gefunden hat. Dieser Hinweis ist in jedem Pfad derselbe.

## Bau

- **R9 · Flags sind lokal.**
  - Flags gelten nur für den laufenden Abend und tragen sprechende Namen, zum Beispiel `getroestet_marta`.
  - Ereignisse lösen nur erzählende Folgen aus: eine Zeile, eine Geste, eine Szene auf der Karte, einen Satz im Epilog.
- **R10 · Mehrere Enden.**
  - Epiloge hängen ab vom Ergebnis der Anklage (richtig/falsch), vom Täterpfad (erst nach dem Finale) und von den Flags.
  - Jede Akte hat mindestens drei unterscheidbare Enden.
- **R11 · Erzähltiefe.**
  - *Aus* entspricht dem heutigen Abend.
  - *Kurz* gibt eine Wahl je Gespräch.
  - *Voll* gibt Dialogbäume und Ereignisketten.
  - Die Erzähltiefe ändert nie das Rätsel.
- **R12 · Texte.**
  - Alle Texte stehen in `content/erzaehlung/<akte>/` und sind deutsch.
  - Es gelten die Tonregeln des Kanons: kein Blut, keine Wunden, kein Alkohol, kein Rauchen.
  - Der Text-Wächter bleibt streng; die App enthält keine Dialogtexte im Code.

## Prüfungen

- **Prüfer:** erreichbare Knoten, keine Sackgassen, keine verwaisten Flags, Grenzen der Gestalt (R3) und Tonregeln.
- **Pfadgleichheit:** alle Pfade, gleiche Graphen (R1).
- **Architektur:** keine Würfel, keine Nachtminuten, keine Wertung in `erzaehlung/**` (R4–R6).
- **Spoiler:** In Dialogen erscheint keine pfadabhängige Kanonstelle (R2).
