import 'package:flutter/foundation.dart';
import 'package:nexa_store/core/models/app_model.dart';
import 'package:nexa_store/core/services/download_service.dart';
import 'package:nexa_store/core/services/update_service.dart';

/// Prefers delta patch when available and app is installed; otherwise full APK.
class AppUpdateHelper {
  static Future<void> installOrUpdate(
    AppModel app, {
    required void Function(double progress) onProgress,
  }) async {
    final packageName = app.packageName;
    final patchUrl = app.patchUrl;
    final canUsePatch = patchUrl != null &&
        patchUrl.trim().isNotEmpty &&
        packageName != null &&
        packageName.trim().isNotEmpty;

    if (canUsePatch) {
      try {
        onProgress(0.1);
        await UpdateService.fetchAndApplyPatch(
          patchUrl: patchUrl!.trim(),
          packageName: packageName!.trim(),
          expectedNewApkSha256: app.sha256Checksum ?? '',
        );
        onProgress(1.0);
        return;
      } catch (e) {
        debugPrint('Delta update failed, falling back to full APK: $e');
      }
    }

    if (app.downloadUrl == null) {
      throw Exception('لا يوجد رابط تنزيل للتطبيق');
    }

    await DownloadService().downloadAndInstall(
      url: app.downloadUrl!,
      expectedSha256: app.sha256Checksum ?? '',
      appName: app.name,
      onProgress: onProgress,
    );
  }
}
