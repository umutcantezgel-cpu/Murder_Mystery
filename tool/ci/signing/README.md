# Öffentlicher Test-Schlüssel für Android

`mordakte-test.p12` ist ein **öffentlicher Test-Schlüssel**. Er liegt absichtlich im Repository,
sein Passwort steht hier und ist damit **öffentlich**.

- Datei: `mordakte-test.p12` (PKCS12), Alias `mordakte-test`, Store- und Schlüsselpasswort `mordakte-test`.
- Zweck: Alle Test-APKs aus den automatischen Builds sind immer mit demselben Zertifikat signiert.
  Ein neuer Build lässt sich deshalb ohne Deinstallieren über den vorigen installieren
  (Android verlangt für Updates dasselbe Signaturzertifikat; ein wechselnder Debug-Schlüssel scheitert daran).
- Verwendung nur für **Sideload-Testbuilds**, **niemals für einen Store** und nie für Daten, die
  geschützt werden müssen. Jeder kann mit diesem Schlüssel eine APK signieren, die Android als
  Update dieser Test-App akzeptiert.
- Echte Secrets haben Vorrang: Sind `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`,
  `ANDROID_KEY_PASSWORD` und `ANDROID_KEY_ALIAS` alle gesetzt, wird ausschließlich dieser Release-Schlüssel
  verwendet (Modus `release`). Fehlt jedes der vier, gilt dieser Test-Schlüssel (Modus `test`).
  Nur ein Teil gesetzt bricht den Build ab.
- Beim Wechsel von einer Test-APK auf eine Release-APK (oder zurück) ändert sich das Zertifikat:
  die alte App zuerst deinstallieren.

`tool/ci/prepare_android_signing.py` wählt den Modus, `tool/ci/build_apk.sh` hält ihn in
`build/release/signatur.txt` für die Release-Notizen fest und gibt, falls `apksigner` verfügbar
ist, den SHA-256-Fingerabdruck des Zertifikats aus.

Neu erzeugen (ändert das Zertifikat, alle Testgeräte müssen dann neu installieren):

```sh
keytool -genkeypair -keystore tool/ci/signing/mordakte-test.p12 -storetype PKCS12 \
  -alias mordakte-test -keyalg RSA -keysize 3072 -validity 36500 \
  -storepass mordakte-test -keypass mordakte-test \
  -dname "CN=Mordakte Test,O=Mordakte,C=DE"
```
