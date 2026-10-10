#!/usr/bin/env python3
"""Validate the public build configuration without printing configuration values."""
import ipaddress
import os
import sys
from urllib.parse import urlsplit


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


def main():
    value = os.environ.get("MORDAKTE_SERVER", "").strip()
    if not value:
        print("Kein öffentlicher Server konfiguriert: Offline-Spiel bleibt verfügbar; Online zeigt einen Einrichtungshinweis.")
        return 0
    if not valid_server_url(value):
        print("MORDAKTE_SERVER muss eine öffentliche wss-Adresse mit Pfad /ws sein, ohne Zugangsdaten, Query oder Fragment.", file=sys.stderr)
        return 1
    print("Öffentliche Server-Konfiguration gültig (Erreichbarkeit separat prüfen).")
    return 0


if __name__ == "__main__":
    sys.exit(main())
