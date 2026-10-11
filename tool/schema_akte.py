#!/usr/bin/env python3
"""Leitet die gelockerten Akten-Schemas aus den Schlosskeller-Schemas ab.

Eingabe:  content/party/schema/*.schema.json  (streng, vier feste Pfade ahmet/fatma/olli/can)
Ausgabe:  content/party/schema-akte/*.schema.json (für jede Akte: Gewölbe, Schlosskeller, Klassiker)

Was gelockert wird (alles andere bleibt unverändert streng):
  * Die festen Pfadlisten (ahmet, fatma, olli, can) werden zu einer beliebigen Kennung.
  * Pflichtschlüssel je Pfad (richtig, begruendung, versteckJePfad) werden zu additionalProperties.
  * Feste Anzahlen: Pfade (mindestens 1), Besetzung (4 bis 20 Rollen, Stufen, Bilanz), Figuren (4 bis 20),
    Gruppenwahl (12 bis 60), Bonus-Hinweise (9 bis 36, also ein bis vier Pfade).
  * Der Opfer-Kennung `schneider` wird jede Kennung.
Was dazukommt (optional, für Akten ohne Simulation):
  * fall: simulation, pruefprofil, zug
  * setting: darstellung
  * Spuren: Bedingung {"pfade": [...]}
  * jede Datei: "generiert" (Marke des Konverters)

Aufruf (Repo-Wurzel):  python3 tool/schema_akte.py [--pruefen]
Die Ausgabe ist deterministisch (gleiche Eingabe, gleiche Bytes). Mit --pruefen wird nichts geschrieben;
das Skript endet mit Status 1, wenn die vorhandenen Dateien nicht der Ableitung entsprechen.
"""
import copy
import json
import os
import sys

WURZEL = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
QUELLE = os.path.join(WURZEL, 'content', 'party', 'schema')
ZIEL = os.path.join(WURZEL, 'content', 'party', 'schema-akte')

PFADE = ['ahmet', 'fatma', 'olli', 'can']
ID_SCHEMA = {'type': 'string', 'pattern': '^[a-z][a-z0-9_]*$'}


def ist_pfadliste(werte):
    return isinstance(werte, list) and sorted(werte) in (sorted(PFADE), sorted(PFADE + ['basis']))


def ersetze_pfadenums(knoten):
    """Jedes Schema mit enum = vier Pfade (optional plus basis) wird zur Kennung."""
    if isinstance(knoten, dict):
        if ist_pfadliste(knoten.get('enum')):
            return copy.deepcopy(ID_SCHEMA)
        return {k: ersetze_pfadenums(v) for k, v in knoten.items()}
    if isinstance(knoten, list):
        return [ersetze_pfadenums(v) for v in knoten]
    return knoten


def pfadschluessel_zu_zusatz(knoten):
    """Objekte, die je Pfad einen eigenen Schlüssel verlangen, werden zu additionalProperties."""
    if isinstance(knoten, dict):
        neu = {k: pfadschluessel_zu_zusatz(v) for k, v in knoten.items()}
        props = neu.get('properties')
        if isinstance(props, dict) and set(PFADE) <= set(props):
            formen = [json.dumps(props[p], sort_keys=True) for p in PFADE]
            assert len(set(formen)) == 1, 'Pfad-Schemas weichen voneinander ab'
            gemeinsam = props[PFADE[0]]
            uebrig = {k: v for k, v in props.items() if k not in PFADE}
            if 'alle' in uebrig:
                assert json.dumps(uebrig['alle'], sort_keys=True) == formen[0], '„alle“ weicht von den Pfaden ab'
                uebrig.pop('alle')
            assert not uebrig, f'unerwartete Schlüssel {list(uebrig)}'
            neu.pop('properties')
            neu.pop('required', None)
            neu['additionalProperties'] = gemeinsam
        return neu
    if isinstance(knoten, list):
        return [pfadschluessel_zu_zusatz(v) for v in knoten]
    return knoten


def marke_generiert(schema):
    schema['properties']['generiert'] = {'type': 'string', 'minLength': 1}


def lockere(name, s):
    s = ersetze_pfadenums(s)
    s = pfadschluessel_zu_zusatz(s)
    p = s['properties']

    if name == 'fall':
        p['pfade']['minItems'] = 1
        p['simulation'] = {'type': 'boolean'}
        p['pruefprofil'] = {
            'type': 'object',
            'additionalProperties': False,
            'properties': {
                'restNachRunde2': {'type': ['integer', 'null'], 'minimum': 1},
                'lageNachRunde1': {'type': ['object', 'null'], 'additionalProperties': {'type': 'integer', 'minimum': 0}},
                'nebendeliktJeKern': {'type': 'boolean'},
                'alleinNur': {'type': 'array', 'minItems': 1, 'items': {'type': 'string'}},
                'mindestRestVorRunde3': {'type': 'integer', 'minimum': 1},
            },
        }
        p['zug'] = {'type': 'object', 'additionalProperties': {'type': 'integer', 'minimum': 0}}

    elif name == 'setting':
        p['darstellung'] = {
            'type': 'object',
            'additionalProperties': False,
            'required': ['palette', 'ratsraum'],
            'properties': {
                'palette': {'type': 'object', 'additionalProperties': {'$ref': '#/$defs/hex'}},
                'wetter': {'enum': ['rain', 'snow', 'neon', 'dust', 'none']},
                'blitze': {'type': 'boolean'},
                'tagLicht': {'type': 'number', 'minimum': 0, 'maximum': 1},
                'nachtLicht': {'type': 'number', 'minimum': 0, 'maximum': 1},
                'ratsraum': {'$ref': '#/$defs/id'},
                'vorlage': {'type': 'string', 'pattern': '^content/scenarios/[a-z0-9_]+\\.json$'},
            },
        }

    elif name == 'besetzung':
        p['minRollen'] = {'type': 'integer', 'minimum': 4, 'maximum': 20}
        p['maxRollen'] = {'type': 'integer', 'minimum': 4, 'maximum': 20}
        p['reihenfolge'].pop('maxItems', None)
        p['reihenfolge']['minItems'] = 4
        p['reihenfolge']['maxItems'] = 20
        p['stufen'].pop('minItems', None)
        p['stufen']['minItems'] = 1
        p['stufen']['maxItems'] = 5
        p['geschlechterBilanz']['minItems'] = 1
        p['geschlechterBilanz']['maxItems'] = 17

    elif name == 'figuren':
        p['opfer']['properties']['id'] = copy.deepcopy(ID_SCHEMA)
        p['figuren']['minItems'] = 4
        p['figuren']['maxItems'] = 20

    elif name == 'gegenstaende':
        sp = p['gegenstaende']['items']['properties']['spuren']['items']['properties']
        sp['entstehtWenn']['anyOf'].append({
            'type': 'object',
            'required': ['pfade'],
            'properties': {'pfade': {'type': 'array', 'minItems': 1, 'uniqueItems': True, 'items': {'$ref': '#/$defs/id'}}},
            'additionalProperties': False,
        })

    elif name == 'gruppenwahl':
        p['wahlen']['minItems'] = 12
        p['wahlen']['maxItems'] = 60

    elif name == 'bonus':
        p['hinweise']['minItems'] = 9
        p['hinweise']['maxItems'] = 36

    marke_generiert(s)
    return s


def serialisiere(s):
    return json.dumps(s, ensure_ascii=False, indent=2) + '\n'


README = """# Gelockerte Kanon-Schemas für Akten

Diese Schemas leitet `tool/schema_akte.py` aus `content/party/schema/` ab. Sie gelten für jede Akte unter
`content/party/<akte>/`, auch für den Schlosskeller, und werden mit dem eigenen Prüfer `SchemaPruefer`
(`packages/mordakte_core/lib/src/party/kanon/schema.dart`) von `packages/mordakte_core/bin/akte_pruefen.dart` angewendet.

Datei von Hand ändern gilt nicht: `python3 tool/schema_akte.py` schreibt alles neu, `--pruefen` prüft die Ableitung.

Gelockert: feste Pfadlisten (ahmet, fatma, olli, can), Pflichtschlüssel je Pfad, feste Anzahlen (Pfade, Besetzung,
Figuren, Gruppenwahl, Bonus-Hinweise). Neu und optional: `fall.simulation`, `fall.pruefprofil`, `fall.zug`,
`setting.darstellung`, Spurbedingung `{"pfade": [...]}` und die Marke `generiert` in jeder Datei.
Alles andere bleibt so streng wie im Schlosskeller.
"""


def main():
    nur_pruefen = '--pruefen' in sys.argv
    namen = sorted(f for f in os.listdir(QUELLE) if f.endswith('.schema.json'))
    ausgabe = {}
    for f in namen:
        with open(os.path.join(QUELLE, f), encoding='utf-8') as h:
            roh = json.load(h)
        ausgabe[f] = serialisiere(lockere(f[: -len('.schema.json')], roh))
    ausgabe['README.md'] = README
    abweichend = []
    if not nur_pruefen:
        os.makedirs(ZIEL, exist_ok=True)
    for f, inhalt in ausgabe.items():
        pfad = os.path.join(ZIEL, f)
        if nur_pruefen:
            try:
                with open(pfad, encoding='utf-8') as h:
                    if h.read() != inhalt:
                        abweichend.append(f)
            except FileNotFoundError:
                abweichend.append(f)
        else:
            with open(pfad, 'w', encoding='utf-8', newline='\n') as h:
                h.write(inhalt)
    if nur_pruefen:
        if abweichend:
            print('Abweichend von der Ableitung:', ', '.join(abweichend))
            sys.exit(1)
        print(f'schema-akte: {len(ausgabe)} Dateien entsprechen der Ableitung')
    else:
        print(f'schema-akte: {len(ausgabe)} Dateien geschrieben nach {os.path.relpath(ZIEL, WURZEL)}')


if __name__ == '__main__':
    main()
