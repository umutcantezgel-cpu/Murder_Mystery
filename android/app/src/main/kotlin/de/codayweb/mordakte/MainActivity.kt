package de.codayweb.mordakte

import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.Intent
import android.widget.Toast
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.IOException

// „Herunterladen“ in der Android-App (A-059, `lib/party/datei_speichern.dart`): Der Kanal
// `mordakte/datei` öffnet mit `speichern` den Speichern-Dialog des Systems
// (ACTION_CREATE_DOCUMENT); die Person wählt den Ort, meist „Downloads“. Die Bytes schreibt
// ein eigener Thread, die Antwort geht auf dem UI-Thread zurück: true gespeichert, false
// abgebrochen, ein Fehler, wenn das Schreiben scheitert. Der Satz nach dem Speichern kommt
// aus der App (ARB); hier steht kein Text für die Oberfläche.
class MainActivity : FlutterActivity() {
    // Die offene Anfrage. Wird die Activity neu erzeugt, verfällt sie still: Die neue kennt
    // sie nicht, und der nächste Tipp beginnt eine neue.
    private var offen: MethodChannel.Result? = null
    private var bytes: ByteArray? = null
    private var gespeichert: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, KANAL).setMethodCallHandler { call, result ->
            if (call.method == "speichern") speichern(call, result) else result.notImplemented()
        }
    }

    private fun speichern(call: MethodCall, result: MethodChannel.Result) {
        val name = call.argument<String>("name")
        val typ = call.argument<String>("typ")
        val daten = call.argument<ByteArray>("bytes")
        if (name == null || typ == null || daten == null) {
            result.error("argumente", "name, typ, bytes", null)
            return
        }
        // Ein Dialog zur Zeit; ein zweiter Tipp in derselben Sekunde öffnet keinen zweiten.
        if (offen != null) {
            result.error("belegt", null, null)
            return
        }
        val absicht = Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            type = typ
            putExtra(Intent.EXTRA_TITLE, name)
        }
        offen = result
        bytes = daten
        gespeichert = call.argument<String>("gespeichert")
        try {
            startActivityForResult(absicht, ANFRAGE)
        } catch (e: ActivityNotFoundException) {
            // Ohne Dokumenten-App gibt es keinen Dialog; „Teilen“ steht daneben.
            zuruecksetzen()
            result.error("kein_dialog", e.message, null)
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        // Erst die Plugins: FlutterActivity reicht das Ergebnis an sie weiter.
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != ANFRAGE) return
        val result = offen
        val daten = bytes
        val text = gespeichert
        zuruecksetzen()
        // Die Anfrage gehörte zu einer früheren Activity.
        if (result == null || daten == null) return
        val ziel = data?.data
        if (resultCode != Activity.RESULT_OK || ziel == null) {
            // Abgebrochen: kein Fehler, wie beim Teilen.
            result.success(false)
            return
        }
        Thread {
            val fehler = try {
                contentResolver.openOutputStream(ziel)?.use { it.write(daten) }
                    ?: throw IOException("kein Ausgabestrom für $ziel")
                null
            } catch (e: Exception) {
                e
            }
            runOnUiThread {
                if (fehler != null) {
                    result.error("schreiben", fehler.message, null)
                } else {
                    result.success(true)
                    if (!text.isNullOrEmpty()) Toast.makeText(applicationContext, text, Toast.LENGTH_LONG).show()
                }
            }
        }.start()
    }

    private fun zuruecksetzen() {
        offen = null
        bytes = null
        gespeichert = null
    }

    private companion object {
        const val KANAL = "mordakte/datei"

        // Eigene Nummer für den Speichern-Dialog, neben denen der Plugins.
        const val ANFRAGE = 0x4d44
    }
}
