package com.smartgallery.app

import android.content.Intent
import android.net.Uri
import android.provider.MediaStore
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.smartgallery/gallery"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "openInGallery" -> {
                        val path = call.argument<String>("path")
                        val assetId = call.argument<String>("id")

                        if (path != null) {
                            val success = openInGallery(path, assetId)
                            result.success(success)
                        } else {
                            result.error("INVALID_ARGS", "Path is required", null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun openInGallery(path: String, assetId: String?): Boolean {
        return try {
            // Try to open using content URI (preferred method)
            val file = File(path)
            val uri = FileProvider.getUriForFile(
                this,
                "${applicationContext.packageName}.fileprovider",
                file
            )

            val intent = Intent(Intent.ACTION_VIEW).apply {
                setDataAndType(uri, "image/*")
                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }

            startActivity(Intent.createChooser(intent, "Open with"))
            true
        } catch (e: Exception) {
            try {
                // Fallback: try with file URI directly
                val intent = Intent(Intent.ACTION_VIEW).apply {
                    setDataAndType(Uri.parse("file://$path"), "image/*")
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
                startActivity(intent)
                true
            } catch (e2: Exception) {
                false
            }
        }
    }
}
