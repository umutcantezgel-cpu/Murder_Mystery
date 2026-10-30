"""Release-Workflow: Job erzaehlerakte und die beiden PDFs am Release.

Liest .github/workflows/release.yml als Text (nur Standardbibliothek, kein YAML-Paket).
Die Erzählerakte am Release ist die Fassung ohne Besetzung, ohne Fall-Code und ohne
Pfad; sie ist optional wie IPA und Web-ZIP und hält APK und Release nie auf.
"""
from pathlib import Path
import re
import unittest

WURZEL = Path(__file__).resolve().parents[3]
WORKFLOW = WURZEL / ".github" / "workflows" / "release.yml"
PARTY_DRUCK = WURZEL / "packages" / "mordakte_core" / "bin" / "party_druck.dart"

# Warnung von party_druck.dart, wenn Porträts fehlen (Exit 0); im Job ist sie ein Fehler.
WARNUNG = "Achtung: Porträts fehlen"
PDFS = ("erzaehlerakte.pdf", "erzaehlerakte-dein-moment.pdf")


def job(text, name):
    """Block des Jobs [name]: von seiner Kopfzeile bis zum nächsten Job."""
    jobs = text.index("\njobs:\n")
    kopf = re.compile(r"^  ([A-Za-z0-9_-]+):\s*$", re.M)
    treffer = [m for m in kopf.finditer(text, jobs)]
    for i, m in enumerate(treffer):
        if m.group(1) == name:
            ende = treffer[i + 1].start() if i + 1 < len(treffer) else len(text)
            return text[m.start():ende]
    raise AssertionError(f"Job {name} fehlt in {WORKFLOW}")


def schritte(block):
    """Die Schritte eines Jobs, je als Text ab „      - “."""
    teile = re.split(r"(?m)^      - ", block)
    return teile[1:]


def zeile(block, schluessel):
    """Wert der ersten Zeile „<schluessel>: …“ auf Job-Ebene (vier Leerzeichen)."""
    m = re.search(rf"(?m)^    {re.escape(schluessel)}: (.+)$", block)
    if m is None:
        raise AssertionError(f"{schluessel} fehlt")
    return m.group(1).strip()


class ErzaehlerakteJobTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.text = WORKFLOW.read_text(encoding="utf-8")
        cls.block = job(cls.text, "erzaehlerakte")
        cls.gate = job(cls.text, "gate")

    def test_haengt_am_gate_und_laeuft_nicht_im_zeitplan(self):
        self.assertEqual(zeile(self.block, "needs"), "gate")
        self.assertEqual(zeile(self.block, "if"), "${{ github.event_name != 'schedule' }}")
        self.assertEqual(zeile(self.block, "runs-on"), zeile(self.gate, "runs-on"))
        self.assertEqual(zeile(self.block, "timeout-minutes"), "20")
        self.assertIn("persist-credentials: false", self.block)

    def test_caches_wie_im_gate(self):
        def schluessel(block, art):
            return re.findall(rf"(?m)^\s+key: ({art}-.+)$", block)
        self.assertEqual(schluessel(self.block, "flutter"), schluessel(self.gate, "flutter"))
        self.assertEqual(len(schluessel(self.block, "flutter")), 1)
        self.assertEqual(schluessel(self.block, "pub"), schluessel(self.gate, "pub"))
        self.assertIn("source tool/flutter_env.sh", self.block)
        self.assertIn('>> "$GITHUB_PATH"', self.block)
        self.assertIn("poppler-utils", self.block)

    def test_portraets_zuerst_und_mindestens_22(self):
        portraets = self.block.index("flutter test tool/bild/druck_portraets_test.dart")
        self.assertIn("-lt 22", self.block)
        self.assertLess(portraets, self.block.index("bin/party_druck.dart"))

    def test_zwei_akten_ohne_besetzung_eine_mit_dein_moment(self):
        # Fortsetzungszeilen („\“ am Zeilenende) zu einer Zeile zusammenziehen.
        verbunden = re.sub(r"\\\n\s*", " ", self.block)
        aufrufe = re.findall(r"dart run bin/party_druck\.dart[^\n]*", verbunden)
        self.assertEqual(len(aufrufe), 2, aufrufe)
        for a in aufrufe:
            self.assertIn("--erzaehlerakte", a)
            self.assertIn("--ohne-besetzung", a)
            self.assertIn("--aus", a)
        self.assertEqual(sum("--dein-moment" in a for a in aufrufe), 1)
        ordner = [re.search(r'--aus "?([^"\s]+)', a).group(1) for a in aufrufe]
        self.assertEqual(len(set(ordner)), 2, "eigener --aus-Ordner für „Dein Moment“")
        self.assertIn("erzaehlerakte-dein-moment.pdf", self.block)
        # Die Warnung über fehlende Porträts steht auf stderr: Nur mit „2>&1“ landet sie im
        # Log, das grep danach liest. Ohne würde der Job still Akten ohne Bilder ausliefern.
        for a in aufrufe:
            name = "dein-moment" if "--dein-moment" in a else "druckspiel"
            self.assertRegex(a, rf'--aus "\$aus/{name}" 2>&1 \| tee "\$aus/{name}\.log"$', a)

    def test_dateien_nicht_vertauscht(self):
        # Druckspiel nach erzaehlerakte.pdf, „Dein Moment“ nach erzaehlerakte-dein-moment.pdf;
        # der Job prüft nur, dass beide verschieden sind, nicht welche welche ist.
        self.assertIn('cp "$aus/druckspiel/erzaehlerakte.pdf" "$GITHUB_WORKSPACE/out/erzaehlerakte.pdf"', self.block)
        self.assertIn('cp "$aus/dein-moment/erzaehlerakte.pdf" "$GITHUB_WORKSPACE/out/erzaehlerakte-dein-moment.pdf"', self.block)
        self.assertEqual(self.block.count("\n          cp "), 2)

    def test_nie_fall_code_pfad_oder_paket(self):
        for verboten in ("--code", "--paket", "--pfad", "--personen", "--n "):
            self.assertNotIn(verboten, self.block, verboten)

    def test_abbruch_bei_fehlenden_portraets_wenig_seiten_und_gleichen_dateien(self):
        self.assertIn(WARNUNG, self.block)
        # Ein Treffer bricht ab: kein „|| true“, kein „!“, beide Logs.
        self.assertIn(f"if grep -F '{WARNUNG}' \"$aus/druckspiel.log\" \"$aus/dein-moment.log\"; then", self.block)
        # Derselbe Text steht in party_druck.dart: Ändert sich die Warnung, fällt dieser Test.
        self.assertIn(f"'{WARNUNG} (", PARTY_DRUCK.read_text(encoding="utf-8"))
        self.assertIn("pdfinfo", self.block)
        # Deckblatt, Personen, Netz mit Legende (zwei Seiten) und 20 Figuren: 24 Seiten.
        self.assertIn('if [ "${seiten:-0}" -lt 24 ]; then', self.block)
        self.assertIn("if cmp -s erzaehlerakte.pdf erzaehlerakte-dein-moment.pdf; then", self.block)
        self.assertNotRegex(self.block, r"!\s*cmp", "kein „! cmp“ unter set -e")

    def test_artefakt_erzaehlerakte_mit_beiden_dateien(self):
        hochladen = [s for s in schritte(self.block) if "actions/upload-artifact" in s]
        self.assertEqual(len(hochladen), 1)
        s = hochladen[0]
        self.assertRegex(s, r"(?m)^\s+name: erzaehlerakte\s*$")
        self.assertRegex(s, r"(?m)^\s+if-no-files-found: error\s*$")
        for pdf in PDFS:
            self.assertIn(f"out/{pdf}", s)


class ReleaseJobTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.text = WORKFLOW.read_text(encoding="utf-8")
        cls.block = job(cls.text, "release")

    def test_wartet_auf_die_akte_ohne_von_ihr_abzuhaengen(self):
        needs = zeile(self.block, "needs")
        self.assertIn("erzaehlerakte", needs)
        for j in ("android", "ios", "web"):
            self.assertIn(j, needs)
        bedingung = zeile(self.block, "if")
        self.assertNotIn("erzaehlerakte", bedingung)
        self.assertIn("always()", bedingung)
        self.assertIn("needs.android.result == 'success'", bedingung)

    def test_artefakt_optional_laden(self):
        laden = [s for s in schritte(self.block) if "actions/download-artifact" in s and re.search(r"(?m)^\s+name: erzaehlerakte\s*$", s)]
        self.assertEqual(len(laden), 1)
        self.assertIn("continue-on-error: true", laden[0])
        self.assertIn("path: artifacts/erzaehlerakte", laden[0])

    def test_kopieren_nur_wenn_vorhanden(self):
        for pdf in PDFS:
            self.assertIn(f"artifacts/erzaehlerakte/{pdf}", self.block)
        self.assertIn('if [ -f "$datei" ]; then cp "$datei" release/; fi', self.block)

    def test_beide_pdfs_in_sha256sums(self):
        m = re.search(r"(?m)^\s+for f in ([^;]+); do\n\s+if \[ -f \"\$f\" \]; then files\+=", self.block)
        self.assertIsNotNone(m, "Schleife über die Dateien für SHA256SUMS.txt")
        dateien = m.group(1).split()
        for pdf in PDFS:
            self.assertIn(pdf, dateien)
        self.assertIn("mordakte.apk", dateien)

    def test_beide_pdfs_in_assets_nur_wenn_vorhanden(self):
        for pdf in PDFS:
            self.assertIn(f"if [ -f release/{pdf} ]; then assets+=(release/{pdf}); fi", self.block)

    def test_notizen_je_datei_und_ersatzzeile(self):
        for pdf in PDFS:
            zeilen = [z for z in self.block.splitlines() if f"`{pdf}`" in z and "printf" in z]
            self.assertEqual(len(zeilen), 1, pdf)
            self.assertIn("Nur für die Person, die erzählt", zeilen[0])
            self.assertIn("nennt nie den Täter", zeilen[0])
            self.assertIn("für jede Personenzahl", zeilen[0])
        self.assertIn("Spuk im Schlosskeller", self.block)
        self.assertIn("Ziele wie im Druckspiel", self.block)
        self.assertIn("„Dein Moment“", self.block)
        self.assertEqual(self.block.count("in diesem Lauf keine PDF"), 2)
        self.assertIn("PDFs zum Ausdrucken (Rollenhefte, Erzählerheft, Auflösung) erstellt die App: Detektei → PDFs zum Ausdrucken.", self.block)

    def test_kopfkommentar_nennt_den_job(self):
        kopf = self.text[: self.text.index("\non:\n")]
        self.assertRegex(kopf, r"(?m)^#\s+erzaehlerakte\s")


if __name__ == "__main__":
    unittest.main()
