#!/usr/bin/env python3
"""Schreibt je Akte die Inhaltskennung nach content/party/akten.json (Feld "inhalt").

Die App hasht akten.json als Inhaltskennung (lib/abend/online/ansicht.dart). Damit
Host und Gast mit verschiedenen Inhalten sich abweisen, steht hier je Akte eine
Prüfsumme über alle Dateien, die der Abend liest:
  content/party/<id>/, content/party/zusatz/<id>/, content/welt/<id>/,
  content/erzaehlung/<id>/, content/karten/<id>.json und content/party/basis-ui/.

Aufruf (Repo-Wurzel): python3 tool/inhalt_kennung.py [--pruefen]
Mit --pruefen wird nichts geschrieben; Exit 1, wenn eine Kennung veraltet ist.
"""
import hashlib
import json
import os
import sys

WURZEL = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
AKTEN = os.path.join(WURZEL, 'content', 'party', 'akten.json')


def dateien(akte):
    orte = [
        f'content/party/{akte}', f'content/party/zusatz/{akte}', f'content/welt/{akte}',
        f'content/erzaehlung/{akte}', 'content/party/basis-ui',
    ]
    pfade = []
    for ort in orte:
        voll = os.path.join(WURZEL, ort)
        for wurzel, _, namen in os.walk(voll):
            for n in namen:
                pfade.append(os.path.relpath(os.path.join(wurzel, n), WURZEL))
    karte = f'content/karten/{akte}.json'
    if os.path.exists(os.path.join(WURZEL, karte)):
        pfade.append(karte)
    return sorted(p.replace(os.sep, '/') for p in pfade)


def kennung(akte):
    h = hashlib.sha256()
    for p in dateien(akte):
        with open(os.path.join(WURZEL, p), 'rb') as f:
            h.update(p.encode() + b'\0' + hashlib.sha256(f.read()).digest())
    return h.hexdigest()[:16]


def main():
    pruefen = '--pruefen' in sys.argv
    roh = open(AKTEN, encoding='utf-8').read()
    daten = json.loads(roh)
    veraltet = []
    for a in daten['akten']:
        soll = kennung(a['id'])
        if a.get('inhalt') != soll:
            veraltet.append(a['id'])
            a['inhalt'] = soll
    if pruefen:
        if veraltet:
            print('Inhaltskennung veraltet für: ' + ', '.join(veraltet) + '. Neu: python3 tool/inhalt_kennung.py', file=sys.stderr)
            sys.exit(1)
        print('Inhaltskennungen aktuell')
        return
    with open(AKTEN, 'w', encoding='utf-8') as f:
        f.write(json.dumps(daten, ensure_ascii=False, indent=2) + '\n')
    print('geschrieben: ' + (', '.join(veraltet) if veraltet else 'nichts geändert'))


if __name__ == '__main__':
    main()
