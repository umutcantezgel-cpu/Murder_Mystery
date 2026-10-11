#!/usr/bin/env python3
"""Validate the public build configuration without printing configuration values."""
import base64
import binascii
import ipaddress
import json
import os
import re
import sys
from urllib.parse import urlsplit

PUBLISHABLE_PREFIX = "sb_publishable_"
SECRET_PREFIX = "sb_secret_"
KEY_CHARS = re.compile(r"[A-Za-z0-9_-]+")
SUBDOMAIN = re.compile(r"[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")


def valid_server_url(value):
    if not value or any(char.isspace() for char in value):
        return False
    try:
        url = urlsplit(value)
        host = (url.hostname or "").lower()
        port = url.port
    except ValueError:
        return False
    if (url.scheme != "wss" or not host or url.path != "/ws"
            or url.username is not None or url.password is not None
            or "?" in value or "#" in value or port == 0):
        return False
    if host.rstrip(".") == "localhost" or host.rstrip(".").endswith(".localhost"):
        return False
    try:
        address = ipaddress.ip_address(host)
    except ValueError:
        return True
    if isinstance(address, ipaddress.IPv6Address) and address.ipv4_mapped:
        address = address.ipv4_mapped
    return not (address.is_loopback or address.is_unspecified)


def valid_relay_url(value):
    """Supabase-Projektadresse: https://<projekt>.supabase.co, ohne Pfad, Query, Port, Zugangsdaten."""
    if not value or any(char.isspace() for char in value):
        return False
    if "?" in value or "#" in value or "@" in value:
        return False
    try:
        url = urlsplit(value)
        host = url.hostname or ""
        port = url.port
    except ValueError:
        return False
    if url.scheme != "https" or url.path or port is not None or url.username is not None:
        return False
    if value.lower() != f"https://{host}":
        return False
    sub, dot, rest = host.partition(".")
    return bool(dot) and rest == "supabase.co" and bool(SUBDOMAIN.fullmatch(sub))


def jwt_role(token):
    """Claim „role“ aus der Nutzlast eines JWT (ohne Signaturprüfung) oder None."""
    parts = token.split(".")
    if len(parts) != 3 or not all(KEY_CHARS.fullmatch(part) for part in parts[:2]):
        return None
    payload = parts[1]
    try:
        claims = json.loads(base64.urlsafe_b64decode(payload + "=" * (-len(payload) % 4)))
    except (ValueError, binascii.Error):
        return None
    role = claims.get("role") if isinstance(claims, dict) else None
    return role if isinstance(role, str) else None


def is_secret_relay_key(value):
    """Geheime Supabase-Schlüssel (sb_secret_…, service_role-JWT) dürfen nie in einen Build."""
    return value.startswith(SECRET_PREFIX) or jwt_role(value) == "service_role"


def valid_relay_key(value):
    """Öffentlicher Schlüssel: sb_publishable_… oder JWT mit Rolle anon. Alles andere ist ungültig."""
    if not value or any(char.isspace() for char in value) or is_secret_relay_key(value):
        return False
    if value.startswith(PUBLISHABLE_PREFIX):
        rest = value[len(PUBLISHABLE_PREFIX):]
        return bool(KEY_CHARS.fullmatch(rest))
    return jwt_role(value) == "anon"


def main():
    ok = True
    value = os.environ.get("MORDAKTE_SERVER", "").strip()
    if not value:
        print("Kein öffentlicher Server konfiguriert: Offline-Spiel bleibt verfügbar; Online zeigt einen Einrichtungshinweis.")
    elif not valid_server_url(value):
        print("MORDAKTE_SERVER muss eine öffentliche wss-Adresse mit Pfad /ws sein, ohne Zugangsdaten, Query oder Fragment.", file=sys.stderr)
        ok = False
    else:
        print("Öffentliche Server-Konfiguration gültig (Erreichbarkeit separat prüfen).")

    relay_url = os.environ.get("MORDAKTE_RELAY_URL", "").strip()
    if not relay_url:
        print("Keine Relay-Adresse konfiguriert (leer ist erlaubt; es gilt die Vorgabe der App).")
    elif not valid_relay_url(relay_url):
        print("MORDAKTE_RELAY_URL muss https://<projekt>.supabase.co sein, ohne Pfad, Query, Fragment, Port oder Zugangsdaten.", file=sys.stderr)
        ok = False
    else:
        print("Relay-Adresse gültig (Erreichbarkeit separat prüfen).")

    relay_key = os.environ.get("MORDAKTE_RELAY_KEY", "").strip()
    if not relay_key:
        print("Kein Relay-Schlüssel konfiguriert (leer ist erlaubt; es gilt die Vorgabe der App).")
    elif is_secret_relay_key(relay_key):
        print("MORDAKTE_RELAY_KEY ist ein geheimer Schlüssel (sb_secret_ oder service_role) und darf nie in einen Build.", file=sys.stderr)
        ok = False
    elif not valid_relay_key(relay_key):
        print("MORDAKTE_RELAY_KEY muss ein öffentlicher Schlüssel sein: sb_publishable_… oder ein JWT mit Rolle anon.", file=sys.stderr)
        ok = False
    else:
        print("Relay-Schlüssel ist öffentlich (publishable/anon).")
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
