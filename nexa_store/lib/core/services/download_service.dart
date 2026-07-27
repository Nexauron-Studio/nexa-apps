import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class DownloadService {
  final Dio _dio = Dio();
  static const MethodChannel _channel =
      MethodChannel('com.example.nexa_store/install');

  Future<void> downloadAndInstall({
    required String url,
    required String expectedSha256,
    required String appName,
    required void Function(double progress) onProgress,
  }) async {
    final dir = await getExternalStorageDirectory();
    if (dir == null) throw Exception('Could not access external storage');

    final fileName = '$appName.apk';
    final filePath = '${dir.path}/$fileName';
    final file = File(filePath);

    if (await file.exists()) await file.delete();

    await _dio.download(
      url,
      filePath,
      onReceiveProgress: (received, total) {
        if (total != -1) onProgress(received / total);
      },
    );

    final bytes = await file.readAsBytes();
    final digest = sha256.convert(bytes);
    final calculatedSha256 = digest.toString();

    // تخطي التحقق من التطابق إذا كانت القيمة المتوقعة فارغة
    if (expectedSha256.trim().isNotEmpty &&
        calculatedSha256 != expectedSha256) {
      throw Exception('SHA-256 mismatch! File might be corrupted.');
    }

    try {
      await _channel.invokeMethod('installApk', {
        'path': filePath,
      });
    } catch (e) {
      throw Exception('Installation failed: $e');
    }
  }
}
