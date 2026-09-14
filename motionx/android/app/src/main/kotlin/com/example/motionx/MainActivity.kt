package com.example.motionx

import android.app.Activity
import android.content.Intent
import android.media.MediaMetadataRetriever
import android.net.Uri
import android.provider.OpenableColumns
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream

class MainActivity: FlutterActivity() {
    private val CHANNEL = "mx/media"
    private val REQ_PICK = 1001
    private var pendingResult: MethodChannel.Result? = null
    private var isPickingPhoto = false

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "reqPerm" -> result.success(true)
                "pick" -> {
                    isPickingPhoto = call.argument<Boolean>("isPhoto") ?: false
                    pendingResult = result
                    val intent = Intent(Intent.ACTION_GET_CONTENT).apply {
                        type = if (isPickingPhoto) "image/*" else "video/*"
                    }
                    startActivityForResult(intent, REQ_PICK)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == REQ_PICK) {
            if (resultCode == Activity.RESULT_OK && data?.data != null) {
                val uri = data.data!!
                val fileName = getFileName(uri) ?: (if (isPickingPhoto) "photo.png" else "video.mp4")
                val localFile = File(cacheDir, fileName)
                try {
                    contentResolver.openInputStream(uri)?.use { input ->
                        FileOutputStream(localFile).use { output ->
                            input.copyTo(output)
                        }
                    }
                    var durationMs = 5000.0
                    if (!isPickingPhoto) {
                        val retriever = MediaMetadataRetriever()
                        try {
                            retriever.setDataSource(this, uri)
                            val time = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION)
                            if (time != null) {
                                durationMs = time.toDouble()
                            }
                        } catch (e: Exception) {
                            try {
                                retriever.setDataSource(localFile.absolutePath)
                                val time = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION)
                                if (time != null) durationMs = time.toDouble()
                            } catch (e2: Exception) {}
                        } finally {
                            try { retriever.release() } catch (e: Exception) {}
                        }
                    }
                    pendingResult?.success(mapOf(
                        "path" to localFile.absolutePath,
                        "name" to fileName,
                        "isPhoto" to isPickingPhoto,
                        "durMs" to durationMs
                    ))
                } catch (e: Exception) {
                    pendingResult?.error("ERR", e.message, null)
                }
            } else {
                pendingResult?.success(null)
            }
            pendingResult = null
        }
    }

    private fun getFileName(uri: Uri): String? {
        var name: String? = null
        if (uri.scheme == "content") {
            val cursor = contentResolver.query(uri, null, null, null, null)
            cursor?.use {
                if (it.moveToFirst()) {
                    val idx = it.getColumnIndex(OpenableColumns.DISPLAY_NAME)
                    if (idx >= 0) name = it.getString(idx)
                }
            }
        }
        return name ?: uri.lastPathSegment
    }
}
