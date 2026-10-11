import base64
import importlib.util
import json
import os
from pathlib import Path
import tempfile
import unittest

CI = Path(__file__).resolve().parents[1]


def load(name):
    spec = importlib.util.spec_from_file_location(name, CI / f"{name}.py")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


signing = load("prepare_android_signing")
urls = load("check_server_url")


def unsigned_jwt(claims):
    """JWT ohne gültige Signatur: nur Aufbau und Nutzlast zählen für die Prüfung."""
    def part(data):
        return base64.urlsafe_b64encode(json.dumps(data).encode()).rstrip(b"=").decode()
    return f"{part({'alg': 'none', 'typ': 'JWT'})}.{part(claims)}.c2ln"


class ServerUrlTests(unittest.TestCase):
    def test_public_websocket_url(self):
        self.assertTrue(urls.valid_server_url("wss://mordakte.example.org/ws"))
        self.assertTrue(urls.valid_server_url("wss://mordakte.example.org:8443/ws"))

    def test_missing_insecure_local_or_credential_urls_are_rejected(self):
        for value in (
            "", "https://mordakte.example.org/ws", "ws://mordakte.example.org/ws",
            "wss://localhost/ws", "wss://localhost./ws", "wss://game.localhost/ws",
            "wss://127.0.0.1/ws", "wss://127.3.4.5/ws", "wss://0.0.0.0/ws",
            "wss://[::1]/ws", "wss://[::]/ws", "wss://[::ffff:127.0.0.1]/ws",
            "wss://name@example.org/ws", "wss://example.org/ws?auth=fixture",
            "wss://example.org/ws#fragment", "wss://example.org/wrong",
            "wss://example.org:0/ws", "wss://example.org:99999/ws",
            "wss://[broken/ws", "wss://exa mple.org/ws",
        ):
            with self.subTest(value=value):
                self.assertFalse(urls.valid_server_url(value))


class RelayTests(unittest.TestCase):
    PROJEKT = "https://abcdefghijklmnopqrst.supabase.co"

    def test_supabase_projektadresse_wird_akzeptiert(self):
        self.assertTrue(urls.valid_relay_url(self.PROJEKT))

    def test_relay_url_mit_fremdem_schema_pfad_oder_zugangsdaten_wird_abgelehnt(self):
        for value in (
            "", "abcdefghijklmnopqrst.supabase.co",
            "http://abcdefghijklmnopqrst.supabase.co",
            self.PROJEKT + "/",
            self.PROJEKT + "/rest/v1",
            self.PROJEKT + "?apikey=fixture",
            self.PROJEKT + "#fragment",
            "https://abcdefghijklmnopqrst.supabase.co:8443",
            "https://user@abcdefghijklmnopqrst.supabase.co",
            "https://a.b.supabase.co",
            "https://supabase.co",
            "https://x.supabase.com",
            "https://x.supabase.co.evil.com",
        ):
            with self.subTest(value=value):
                self.assertFalse(urls.valid_relay_url(value))

    def test_publishable_schluessel_wird_akzeptiert(self):
        self.assertTrue(urls.valid_relay_key("sb_publishable_AbC123"))

    def test_anon_jwt_wird_akzeptiert(self):
        self.assertTrue(urls.valid_relay_key(unsigned_jwt({"role": "anon", "iss": "supabase"})))

    def test_geheime_oder_leere_oder_fremde_schluessel_werden_abgelehnt(self):
        service = unsigned_jwt({"role": "service_role", "iss": "supabase"})
        for value in (
            "sb_secret_AbC123", service,
            "sb_publishable_", "", " sb_publishable_AbC123", "sb_publishable_Ab C123",
            "hallo welt", "beliebiger text",
        ):
            with self.subTest(value=value):
                self.assertFalse(urls.valid_relay_key(value))

    def test_geheimer_schluessel_wird_als_geheim_erkannt(self):
        self.assertTrue(urls.is_secret_relay_key("sb_secret_AbC123"))
        self.assertTrue(urls.is_secret_relay_key(unsigned_jwt({"role": "service_role"})))
        self.assertFalse(urls.is_secret_relay_key("sb_publishable_AbC123"))
        self.assertFalse(urls.is_secret_relay_key(unsigned_jwt({"role": "anon"})))


class SigningTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.path = Path(self.temp.name) / "release.jks"
        # Deliberately invalid keystore data, not a real signing key.
        self.env = {
            "ANDROID_KEYSTORE_BASE64": base64.b64encode(b"fixture, not a keystore").decode(),
            "ANDROID_KEYSTORE_PASSWORD": "fixture-store",
            "ANDROID_KEY_PASSWORD": "fixture-key",
            "ANDROID_KEY_ALIAS": "fixture-alias",
            "ANDROID_KEYSTORE_PATH": str(self.path),
            "RUNNER_TEMP": self.temp.name,
        }

    def test_no_secrets_uses_test_key_without_creating_file(self):
        self.assertEqual(signing.prepare_signing({}), "test")
        self.assertEqual(signing.prepare_signing({"ANDROID_KEYSTORE_PATH": str(self.path)}), "test")
        self.assertFalse(self.path.exists())

    def test_whitespace_only_secrets_are_missing(self):
        self.assertEqual(signing.prepare_signing({name: " " for name in signing.SIGNING_FIELDS}), "test")

    def test_missing_test_keystore_fails(self):
        fehlt = Path(self.temp.name) / "fehlt.p12"
        with self.assertRaisesRegex(ValueError, "Test-Schlüssel fehlt"):
            signing.prepare_signing({}, test_keystore=fehlt)

    def test_public_test_key_env_liefert_pfad_passwoerter_und_alias(self):
        env = signing.public_test_key_env()
        self.assertEqual(env, {
            "ANDROID_KEYSTORE_PATH": str(signing.TEST_KEYSTORE),
            "ANDROID_KEYSTORE_PASSWORD": "mordakte-test",
            "ANDROID_KEY_PASSWORD": "mordakte-test",
            "ANDROID_KEY_ALIAS": "mordakte-test",
        })
        eigener = Path(self.temp.name) / "eigen.p12"
        self.assertEqual(signing.public_test_key_env(eigener)["ANDROID_KEYSTORE_PATH"], str(eigener))

    def test_test_keystore_liegt_im_repo_als_pkcs12(self):
        self.assertTrue(signing.TEST_KEYSTORE.is_file())
        self.assertEqual(signing.TEST_KEYSTORE.parent.name, "signing")
        # PKCS#12 ist DER-Sequenz: erstes Byte 0x30.
        self.assertEqual(signing.TEST_KEYSTORE.read_bytes()[:1], b"\x30")
        self.assertEqual(signing.prepare_signing({}, test_keystore=signing.TEST_KEYSTORE), "test")

    def test_all_secrets_write_private_file(self):
        self.assertEqual(signing.prepare_signing(self.env), "release")
        self.assertEqual(self.path.read_bytes(), b"fixture, not a keystore")
        self.assertEqual(os.stat(self.path).st_mode & 0o777, 0o600)

    def test_partial_secrets_fail_instead_of_silent_debug_fallback(self):
        for name in signing.SIGNING_FIELDS:
            env = dict(self.env)
            del env[name]
            with self.subTest(name=name), self.assertRaisesRegex(ValueError, name):
                signing.prepare_signing(env)
        self.assertFalse(self.path.exists())

    def test_invalid_base64_fails(self):
        self.env["ANDROID_KEYSTORE_BASE64"] = "not valid base64!!"
        with self.assertRaisesRegex(ValueError, "Base64"):
            signing.prepare_signing(self.env)
        self.assertFalse(self.path.exists())

    def test_existing_file_is_never_overwritten(self):
        self.path.write_bytes(b"keep")
        with self.assertRaises(FileExistsError):
            signing.prepare_signing(self.env)
        self.assertEqual(self.path.read_bytes(), b"keep")

    def test_file_must_stay_inside_runner_temp(self):
        self.env["ANDROID_KEYSTORE_PATH"] = str(self.path.parent.parent / "outside.jks")
        with self.assertRaisesRegex(ValueError, "temporären"):
            signing.prepare_signing(self.env)


if __name__ == "__main__":
    unittest.main()
