package com.example.sajadah

import android.app.Activity
import android.content.Intent
import android.database.Cursor
import android.net.Uri
import android.provider.OpenableColumns
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream
import java.io.InputStream

class MainActivity : FlutterActivity() {
	private val channelName = "sajadah/document_picker"
	private val requestPickDocument = 9001
	private var pendingResult: MethodChannel.Result? = null

	override fun configureFlutterEngine(
		flutterEngine: io.flutter.embedding.engine.FlutterEngine,
	) {
		super.configureFlutterEngine(flutterEngine)

		MethodChannel(
			flutterEngine.dartExecutor.binaryMessenger,
			channelName,
		).setMethodCallHandler { call, result ->
			when (call.method) {
				"pickDocument" -> {
					if (pendingResult != null) {
						result.error(
							"busy",
							"Document picker is already open",
							null,
						)
						return@setMethodCallHandler
					}

					pendingResult = result
					val intent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
						addCategory(Intent.CATEGORY_OPENABLE)
						type = "*/*"
						putExtra(
							Intent.EXTRA_MIME_TYPES,
							arrayOf(
								"application/pdf",
								"application/msword",
								"application/vnd.openxmlformats-officedocument.wordprocessingml.document",
								"application/vnd.ms-excel",
								"application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
							),
						)
					}
					startActivityForResult(intent, requestPickDocument)
				}

				else -> result.notImplemented()
			}
		}
	}

	override fun onActivityResult(
		requestCode: Int,
		resultCode: Int,
		data: Intent?,
	) {
		super.onActivityResult(requestCode, resultCode, data)

		if (requestCode != requestPickDocument) return

		val result = pendingResult
		pendingResult = null

		if (result == null) return

		if (resultCode != Activity.RESULT_OK) {
			result.success(null)
			return
		}

		val uri = data?.data
		if (uri == null) {
			result.success(null)
			return
		}

		try {
			val displayName = queryDisplayName(uri) ?: "document"
			val outputFile = copyUriToCache(uri, displayName)
			result.success(
				mapOf(
					"path" to outputFile.absolutePath,
					"name" to outputFile.name,
				),
			)
		} catch (e: Exception) {
			result.error("document_picker_error", e.message, null)
		}
	}

	private fun queryDisplayName(uri: Uri): String? {
		val cursor: Cursor? = contentResolver.query(
			uri,
			arrayOf(OpenableColumns.DISPLAY_NAME),
			null,
			null,
			null,
		)

		cursor?.use {
			val nameIndex = it.getColumnIndex(OpenableColumns.DISPLAY_NAME)
			if (it.moveToFirst() && nameIndex >= 0) {
				return it.getString(nameIndex)
			}
		}

		return null
	}

	private fun copyUriToCache(uri: Uri, displayName: String): File {
		val safeName = displayName.replace(Regex("[^A-Za-z0-9._-]"), "_")
		val outputFile = File(cacheDir, "lp_${System.currentTimeMillis()}_$safeName")

		contentResolver.openInputStream(uri).use { inputStream ->
			FileOutputStream(outputFile).use { outputStream ->
				inputStream?.copyTo(outputStream)
			}
		}

		return outputFile
	}
}
