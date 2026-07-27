package com.example.nexa_store

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import android.content.pm.PackageManager
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.nexa_store/install"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "installApk" -> {
                        val path = call.argument<String>("path") ?: ""
                        checkPermissionAndInstall(path, result)
                    }
                    // إضافة دالة الاستعلام عن التطبيقات المثبتة
                    "getAppVersion" -> {
                        val packageName = call.argument<String>("packageName") ?: ""
                        try {
                            val pInfo = context.packageManager.getPackageInfo(packageName, 0)
                            result.success(pInfo.versionName)
                        } catch (e: PackageManager.NameNotFoundException) {
                            result.success(null) // التطبيق غير مثبت
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun checkPermissionAndInstall(filePath: String, result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            if (!packageManager.canRequestPackageInstalls()) {
                val intent = Intent(Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES).apply {
                    data = Uri.parse("package:$packageName")
                }
                startActivity(intent)
                result.error("PERMISSION_REQUIRED", "Permission required", null)
                return
            }
        }
        installApk(filePath, result)
    }

    private fun installApk(filePath: String, result: MethodChannel.Result) {
        try {
            val file = File(filePath)
            if (!file.exists()) {
                result.error("FILE_NOT_FOUND", "File not found", null)
                return
            }

            val uri: Uri = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                FileProvider.getUriForFile(this, "$packageName.fileprovider", file)
            } else {
                Uri.fromFile(file)
            }

            val intent = Intent(Intent.ACTION_VIEW).apply {
                setDataAndType(uri, "application/vnd.android.package-archive")
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                    addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                }
            }
            startActivity(intent)
            result.success("Started")
        } catch (e: Exception) {
            result.error("INSTALL_ERROR", e.message, null)
        }
    }
}