#!/usr/bin/env python3
"""Wählt die Android-Signatur für CI-Builds. Niemals Secret-Werte loggen oder als Argument übergeben.

Modi (Ausgabe auf stdout, ein Wort):
  release  alle vier Secrets vorhanden: Keystore wird im temporären CI-Ordner abgelegt
  test     kein Secret vorhanden: öffentlicher Test-Schlüssel aus tool/ci/signing (nur Sideload-Tests)
Teilweise gesetzte Secrets sind ein Fehler, kein stiller Rückfall.

`--test-env` gibt die Umgebungsvariablen für den Test-Schlüssel als `export`-Zeilen aus. Gradle liest
sie genauso wie die Release-Werte (android/app/build.gradle.kts), dort ist keine Änderung nötig.
"""
import base64
import binascii
import os
from pathlib import Path
import shlex
import sys

SIGNING_FIELDS = (
    "ANDROID_KEYSTORE_BASE64", "ANDROID_KEYSTORE_PASSWORD",
    "ANDROID_KEY_PASSWORD", "ANDROID_KEY_ALIAS",
)

# Öffentlicher Test-Schlüssel, absichtlich im Repository (siehe tool/ci/signing/README.md).
TEST_KEYSTORE = Path(__file__).resolve().parent / "signing" / "mordakte-test.p12"
TEST_ALIAS = "mordakte-test"
TEST_PASSWORD = "mordakte-test"


def public_test_key_env(keystore=None):
    """Umgebungsvariablen, die build.gradle.kts für den öffentlichen Test-Schlüssel liest."""
    return {
        "ANDROID_KEYSTORE_PATH": str(keystore or TEST_KEYSTORE),
        "ANDROID_KEYSTORE_PASSWORD": TEST_PASSWORD,
        "ANDROID_KEY_PASSWORD": TEST_PASSWORD,
        "ANDROID_KEY_ALIAS": TEST_ALIAS,
    }


def prepare_signing(env, test_keystore=None):
    present = [name for name in SIGNING_FIELDS if env.get(name, "").strip()]
    if not present:
        keystore = Path(test_keystore or TEST_KEYSTORE)
        if not keystore.is_file():
            raise ValueError("Öffentlicher Test-Schlüssel fehlt: tool/ci/signing/mordakte-test.p12")
        return "test"
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
    if sys.argv[1:] == ["--test-env"]:
        # Nur öffentliche Werte des Test-Schlüssels, keine Secrets.
        for key, value in public_test_key_env().items():
            print(f"export {key}={shlex.quote(value)}")
        sys.exit(0)
    if sys.argv[1:]:
        print("Aufruf: prepare_android_signing.py [--test-env]", file=sys.stderr)
        sys.exit(2)
    try:
        print(prepare_signing(os.environ))
    except (ValueError, OSError) as error:
        # OSError includes only the destination path, never keystore/password contents.
        print(f"Android-Signatur konnte nicht vorbereitet werden: {error}", file=sys.stderr)
        sys.exit(1)
