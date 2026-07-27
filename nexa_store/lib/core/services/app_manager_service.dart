import 'package:flutter/services.dart';

enum AppStatus { notInstalled, updateAvailable, upToDate }

class AppManagerService {
  static const MethodChannel _channel =
      MethodChannel('com.example.nexa_store/install');

  // جلب إصدار التطبيق من نظام أندرويد
  static Future<String?> getInstalledVersion(String packageName) async {
    try {
      final String? version = await _channel.invokeMethod('getAppVersion', {
        'packageName': packageName,
      });
      return version;
    } catch (e) {
      return null;
    }
  }

  // مقارنة الإصدار المثبت بإصدار قاعدة البيانات
  static Future<AppStatus> checkAppStatus(
      String packageName, String storeVersion) async {
    final installedVersion = await getInstalledVersion(packageName);

    if (installedVersion == null) {
      return AppStatus.notInstalled;
    }

    if (_isVersionGreater(storeVersion, installedVersion)) {
      return AppStatus.updateAvailable;
    }

    return AppStatus.upToDate;
  }

  // خوارزمية تحليل أرقام الإصدارات
  static bool _isVersionGreater(String storeVer, String installedVer) {
    final storeParts =
        storeVer.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final installedParts =
        installedVer.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    for (int i = 0; i < storeParts.length; i++) {
      int installedPart = i < installedParts.length ? installedParts[i] : 0;
      if (storeParts[i] > installedPart) return true;
      if (storeParts[i] < installedPart) return false;
    }
    return false;
  }
}
