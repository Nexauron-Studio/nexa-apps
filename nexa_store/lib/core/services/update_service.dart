import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

/// Android native bridge for Archive Patcher (must match [MainActivity.kt]).
class UpdateService {
  static const MethodChannel _channel =
      MethodChannel('com.example.nexa_store/install');

  /// Downloads a patch, merges it with the installed APK for [packageName], then installs.
  static Future<void> fetchAndApplyPatch({
    required String patchUrl,
    required String packageName,
    String expectedNewApkSha256 = '',
  }) async {
    final directory = await getTemporaryDirectory();
    final patchPath = '${directory.path}/update_${packageName.hashCode}.patch';
    final newApkPath = '${directory.path}/new_${packageName.hashCode}.apk';

    final response = await http.get(Uri.parse(patchUrl));
    if (response.statusCode != 200) {
      throw Exception('فشل تنزيل ملف التحديث: ${response.statusCode}');
    }
    await File(patchPath).writeAsBytes(response.bodyBytes);

    final String? oldApkPath = await _channel.invokeMethod<String>(
      'getInstalledApkPath',
      {'packageName': packageName},
    );
    if (oldApkPath == null || oldApkPath.isEmpty) {
      throw Exception('التطبيق غير مثبت — استخدم تنزيل APK كامل');
    }

    final String? resultPath = await _channel.invokeMethod<String>('applyPatch', {
      'oldApkPath': oldApkPath,
      'patchPath': patchPath,
      'newApkPath': newApkPath,
    });

    if (resultPath == null || !File(resultPath).existsSync()) {
      throw Exception('فشل دمج ملف التحديث');
    }

    if (expectedNewApkSha256.trim().isNotEmpty) {
      final bytes = await File(resultPath).readAsBytes();
      final digest = sha256.convert(bytes).toString();
      if (digest != expectedNewApkSha256.trim()) {
        throw Exception('فشل التحقق من سلامة APK بعد الدمج');
      }
    }

    await _channel.invokeMethod('installApk', {'path': resultPath});
  }

  /// Backward-compatible entry (store self-update when [packageName] is omitted).
  static Future<void> fetchAndApplyUpdate(
    String patchUrl, {
    String? packageName,
    String expectedNewApkSha256 = '',
  }) {
    return fetchAndApplyPatch(
      patchUrl: patchUrl,
      packageName: packageName ?? 'com.example.nexa_store',
      expectedNewApkSha256: expectedNewApkSha256,
    );
  }
}
