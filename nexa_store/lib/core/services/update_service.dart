import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nexa_store/core/services/download_service.dart';

class UpdateService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> checkForUpdates(BuildContext context) async {
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final String currentVersion = packageInfo.version;
      final String packageName = packageInfo.packageName;

      final response = await _supabase
          .from('apps')
          .select('version, download_url, sha256')
          .eq('package_name', packageName)
          .maybeSingle();

      if (response == null) return;

      final String latestVersion = response['version'] ?? '0.0.0';

      if (_isUpdateAvailable(currentVersion, latestVersion)) {
        final String downloadUrl = response['download_url'];
        final String sha256 = response['sha256'] ?? '';

        if (context.mounted) {
          _showUpdateDialog(
              context, downloadUrl, sha256, latestVersion, packageInfo.appName);
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

  void _showUpdateDialog(BuildContext context, String downloadUrl,
      String expectedSha256, String versionName, String appName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        bool isDownloading = false;
        double downloadProgress = 0.0;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('تحديث جديد متوفر'),
              content: isDownloading
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          value: downloadProgress > 0 ? downloadProgress : null,
                        ),
                        const SizedBox(height: 16),
                        Text('${(downloadProgress * 100).toStringAsFixed(1)}%'),
                      ],
                    )
                  : Text(
                      'الإصدار $versionName متاح الآن. يرجى التحديث للمتابعة.'),
              actions: [
                if (!isDownloading)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      elevation: 2,
                    ),
                    onPressed: () async {
                      setState(() {
                        isDownloading = true;
                      });

                      try {
                        await DownloadService().downloadAndInstall(
                          url: downloadUrl,
                          expectedSha256: expectedSha256,
                          appName: appName,
                          onProgress: (progress) {
                            setState(() {
                              downloadProgress = progress;
                            });
                          },
                        );
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('فشل التحديث: $e')),
                          );
                          setState(() {
                            isDownloading = false;
                          });
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
