#!/usr/bin/env python3
"""Materialize an optional CI keystore. Never log or pass secret values as arguments."""
import base64
import binascii
import os
from pathlib import Path
import sys

SIGNING_FIELDS = (
    "ANDROID_KEYSTORE_BASE64", "ANDROID_KEYSTORE_PASSWORD",
    "ANDROID_KEY_PASSWORD", "ANDROID_KEY_ALIAS",
)


def prepare_signing(env):
    present = [name for name in SIGNING_FIELDS if env.get(name, "").strip()]
    if not present:
        return "debug"
    if len(present) != len(SIGNING_FIELDS):
        missing = ", ".join(name for name in SIGNING_FIELDS if name not in present)
        raise ValueError(f"Signatur unvollständig; fehlende Secret-Namen: {missing}")
    try:
        data = base64.b64decode("".join(env[SIGNING_FIELDS[0]].split()), validate=True)
    except (ValueError, binascii.Error):
        raise ValueError("Keystore ist nicht gültig Base64-kodiert.") from None
    if not data:
        raise ValueError("Keystore ist leer.")
    target = env.get("ANDROID_KEYSTORE_PATH")
    temporary = env.get("RUNNER_TEMP")
    if not target or not temporary:
        raise ValueError("Keystore-Pfad und temporärer CI-Ordner fehlen.")
    path = Path(target).resolve()
    if not path.is_relative_to(Path(temporary).resolve()):
        raise ValueError("Keystore darf nur im temporären CI-Ordner liegen.")
    path.parent.mkdir(parents=True, exist_ok=True)
    # O_EXCL prevents overwriting any existing file; 0600 keeps it private.
    descriptor = os.open(path, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600)
    with os.fdopen(descriptor, "wb") as output:
        output.write(data)
    return "release"


if __name__ == "__main__":
    try:
        print(prepare_signing(os.environ))
    except (ValueError, OSError) as error:
        # OSError includes only the destination path, never keystore/password contents.
        print(f"Android-Signatur konnte nicht vorbereitet werden: {error}", file=sys.stderr)
        sys.exit(1)
