import base64
import importlib.util
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

    def test_no_secrets_uses_debug_without_creating_file(self):
        self.assertEqual(signing.prepare_signing({}), "debug")
        self.assertEqual(signing.prepare_signing({"ANDROID_KEYSTORE_PATH": str(self.path)}), "debug")
        self.assertFalse(self.path.exists())

    def test_whitespace_only_secrets_are_missing(self):
        self.assertEqual(signing.prepare_signing({name: " " for name in signing.SIGNING_FIELDS}), "debug")

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
