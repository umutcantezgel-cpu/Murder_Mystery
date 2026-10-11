#!/usr/bin/env python3
"""Liest Kandidaten für JWTs (ein Token je Zeile) von stdin und meldet service_role-Schlüssel.

Ein öffentlicher Supabase-Schlüssel (anon/publishable) darf im Repository stehen, ein
service_role-Schlüssel nie. Das Token wird nur dekodiert, nicht geprüft; ausgegeben wird nie
das Token selbst, nur die Anzahl. Exit 1 bei mindestens einem Treffer.
"""
import base64
import binascii
import json
import sys


def jwt_role(token):
    """Rolle (Claim „role“) aus der Nutzlast eines JWT oder None, wenn es keins ist."""
    parts = token.strip().split(".")
    if len(parts) != 3:
        return None
    payload = parts[1]
    try:
        raw = base64.urlsafe_b64decode(payload + "=" * (-len(payload) % 4))
        claims = json.loads(raw)
    except (ValueError, binascii.Error):
        return None
    if not isinstance(claims, dict):
        return None
    role = claims.get("role")
    return role if isinstance(role, str) else None


def main():
    treffer = sum(1 for zeile in sys.stdin if jwt_role(zeile) == "service_role")
    if treffer:
        print(f"service_role-JWT gefunden ({treffer} Fundstelle(n)), Token nicht ausgegeben")
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
