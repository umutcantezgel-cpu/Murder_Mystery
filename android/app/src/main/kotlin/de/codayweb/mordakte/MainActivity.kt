package de.codayweb.mordakte

import android.app.Activity
import android.content.Intent
import android.database.Cursor
import android.net.Uri
import android.provider.DocumentsContract
import android.provider.OpenableColumns
import android.widget.Toast
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.FileNotFoundException
import java.io.IOException
import java.io.OutputStream

// „Herunterladen“ in der Android-App (A-059, `lib/party/datei_speichern.dart`): Der Kanal
// `mordakte/datei` öffnet mit `speichern` den Speichern-Dialog des Systems
// (ACTION_CREATE_DOCUMENT); die Person wählt den Ort, meist „Downloads“. Die Bytes schreibt
// ein eigener Thread, die Antwort geht auf dem UI-Thread zurück: true gespeichert, false
// abgebrochen, ein Fehler, wenn das Schreiben scheitert. Der Satz nach dem Speichern kommt
// aus der App (ARB); hier steht kein Text für die Oberfläche.
class MainActivity : FlutterActivity() {
    // Die offene Anfrage. Wird die Activity neu erzeugt, verfällt sie: Die neue kennt sie
    // nicht, entfernt nur die leere Datei, die der Dialog schon angelegt hat, und der nächste
    // Tipp beginnt eine neue.
    private var offen: MethodChannel.Result? = null
    private var bytes: ByteArray? = null
    private var vorschlag: String? = null
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
        vorschlag = name
        gespeichert = call.argument<String>("gespeichert")
        try {
            startActivityForResult(absicht, ANFRAGE)
        } catch (e: Exception) {
            // Ohne Dokumenten-App (oder gesperrt, etwa im Arbeitsprofil) gibt es keinen Dialog;
            // „Teilen“ steht daneben. Die Anfrage gilt dann nicht mehr als offen.
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
        val name = vorschlag
        val text = gespeichert
        zuruecksetzen()
        val ziel = data?.data
        if (result == null || daten == null || name == null) {
            // Die Anfrage gehörte zu einer früheren Activity: Der Dialog hat die Datei schon leer
            // angelegt. Nur eine leere entfernen; eine vorhandene, zum Überschreiben gewählte bleibt.
            if (resultCode == Activity.RESULT_OK && ziel != null) {
                Thread { if (groesse(ziel) == 0L) entfernen(ziel) }.start()
            }
            return
        }
        if (resultCode != Activity.RESULT_OK || ziel == null) {
            // Abgebrochen: kein Fehler, wie beim Teilen.
            result.success(false)
            return
        }
        Thread {
            // Leer heißt: vom Dialog neu angelegt, nicht eine vorhandene Datei zum Überschreiben.
            val neu = groesse(ziel) == 0L
            val fehler = try {
                ausgabe(ziel).use { it.write(daten) }
                null
            } catch (e: Exception) {
                e
            }
            // Nach einem Fehler bleibt keine leere oder halbe neue Datei im gewählten Ordner.
            if (fehler != null && neu) entfernen(ziel)
            // Android benennt bei gleichem Namen um („… (1).pdf“), die Person vielleicht auch:
            // Der Satz nennt den Namen, unter dem die Datei wirklich liegt.
            val satz = if (fehler == null && !text.isNullOrEmpty()) text.replace(name, anzeigeName(ziel) ?: name) else null
            runOnUiThread {
                if (fehler != null) {
                    result.error("schreiben", fehler.message, null)
                } else {
                    result.success(true)
                    if (satz != null) Toast.makeText(applicationContext, satz, Toast.LENGTH_LONG).show()
                }
            }
        }.start()
    }

    // Öffnet das Ziel zum Schreiben und kürzt es dabei („wt“): Wählt die Person eine vorhandene,
    // längere Datei, bliebe mit „w“ je nach Anbieter ihr alter Rest stehen und die PDF wäre
    // kaputt. Kennt ein Anbieter „wt“ nicht, gilt „w“ (eine neue Datei ist ohnehin leer).
    private fun ausgabe(ziel: Uri): OutputStream {
        val gekuerzt = try {
            contentResolver.openOutputStream(ziel, "wt")
        } catch (e: FileNotFoundException) {
            null
        } catch (e: IllegalArgumentException) {
            null
        } catch (e: UnsupportedOperationException) {
            null
        }
        return gekuerzt ?: contentResolver.openOutputStream(ziel, "w") ?: throw IOException("kein Ausgabestrom für $ziel")
    }

    // Größe der Datei in Bytes; null, wenn der Anbieter sie nicht nennt.
    private fun groesse(ziel: Uri): Long? = spalte(ziel, OpenableColumns.SIZE) { c -> c.getLong(0) }

    // Name, unter dem die Datei liegt; null, wenn der Anbieter ihn nicht nennt.
    private fun anzeigeName(ziel: Uri): String? = spalte(ziel, OpenableColumns.DISPLAY_NAME) { c -> c.getString(0) }

    private fun <T> spalte(ziel: Uri, name: String, lesen: (Cursor) -> T): T? = try {
        contentResolver.query(ziel, arrayOf(name), null, null, null)?.use { c ->
            if (c.moveToFirst() && !c.isNull(0)) lesen(c) else null
        }
    } catch (e: Exception) {
        null
    }

    private fun entfernen(ziel: Uri) {
        try {
            DocumentsContract.deleteDocument(contentResolver, ziel)
        } catch (e: Exception) {
            // Kann der Anbieter nicht löschen, bleibt die Datei liegen.
        }
    }

    private fun zuruecksetzen() {
        offen = null
        bytes = null
        vorschlag = null
        gespeichert = null
    }

    private companion object {
        const val KANAL = "mordakte/datei"

        // Eigene Nummer für den Speichern-Dialog, neben denen der Plugins.
        const val ANFRAGE = 0x4d44
    }
}
