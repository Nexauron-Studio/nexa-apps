import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nexa_store/core/services/download_service.dart';
import 'package:nexa_store/core/services/update_service.dart';

class UpdateChecker {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> checkForUpdates(BuildContext context) async {
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final String currentVersion = packageInfo.version;
      final String packageName = packageInfo.packageName;

      final response = await _supabase
          .from('apps')
          .select('version, download_url, sha256, patch_url, patch_sha256')
          .eq('package_name', packageName)
          .maybeSingle();

      if (response == null) return;

      final String latestVersion = response['version'] ?? '0.0.0';

      if (_isUpdateAvailable(currentVersion, latestVersion)) {
        final String? patchUrl = response['patch_url'] as String?;
        final String downloadUrl = response['download_url'] ?? '';
        final String sha256 = response['sha256'] ?? '';

        if (context.mounted) {
          _showUpdateDialog(
            context,
            packageName: packageName,
            patchUrl: patchUrl,
            fullApkUrl: downloadUrl,
            sha256: sha256,
            versionName: latestVersion,
          );
        }
      }
    } catch (e) {
      debugPrint('Update check failed: $e');
    }
  }

  bool _isUpdateAvailable(String current, String latest) {
    final currParts =
        current.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final latestParts =
        latest.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    for (int i = 0; i < latestParts.length; i++) {
      int c = i < currParts.length ? currParts[i] : 0;
      if (latestParts[i] > c) return true;
      if (latestParts[i] < c) return false;
    }
    return false;
  }

  void _showUpdateDialog(
    BuildContext context, {
    required String packageName,
    required String? patchUrl,
    required String fullApkUrl,
    required String sha256,
    required String versionName,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        bool isDownloading = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('تحديث جديد متوفر'),
              content: isDownloading
                  ? const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('جاري معالجة وتثبيت التحديث...'),
                      ],
                    )
                  : Text(
                      'الإصدار $versionName متاح الآن. سيتم استخدام التحديث الجزئي إن وُجد.'),
              actions: [
                if (!isDownloading)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      elevation: 2,
                    ),
                    onPressed: () async {
                      setState(() => isDownloading = true);

                      try {
                        final url = patchUrl;
                        if (url != null && url.trim().isNotEmpty) {
                          await UpdateService.fetchAndApplyPatch(
                            patchUrl: url.trim(),
                            packageName: packageName,
                            expectedNewApkSha256: sha256,
                          );
                        } else if (fullApkUrl.isNotEmpty) {
                          await DownloadService().downloadAndInstall(
                            url: fullApkUrl,
                            expectedSha256: sha256,
                            appName: 'nexa_store_update',
                            onProgress: (_) {},
                          );
                        } else {
                          throw Exception('لا يوجد رابط تحديث');
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('فشل التحديث: $e')),
                          );
                          setState(() => isDownloading = false);
                        }
                      }
                    },
                    child: const Text(
                      'تحديث الآن',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}
