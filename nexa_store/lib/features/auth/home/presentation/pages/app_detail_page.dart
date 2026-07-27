import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexa_store/core/models/app_model.dart';
import 'package:nexa_store/core/services/app_service.dart';
import 'package:nexa_store/features/auth/providers/download_manager.dart';
// يجب التأكد من صحة مسار الاستدعاء أدناه بناءً على هيكلية مشروعك
import 'package:nexa_store/core/services/app_manager_service.dart';

final appDetailProvider =
    FutureProvider.family<AppModel?, String>((ref, appId) async {
  return await AppService().fetchAppById(appId);
});

// تحويل الكلاس إلى ConsumerStatefulWidget لإدارة الحالة
class AppDetailPage extends ConsumerStatefulWidget {
  final String appId;
  const AppDetailPage({super.key, required this.appId});

  @override
  ConsumerState<AppDetailPage> createState() => _AppDetailPageState();
}

class _AppDetailPageState extends ConsumerState<AppDetailPage> {
  AppStatus? _currentStatus;
  String? _checkedAppId;

  // دالة للتحقق من حالة التطبيق
  Future<void> _checkAppStatus(AppModel app) async {
    // منع التكرار اللانهائي للاستدعاء
    if (_checkedAppId == app.appId) return;
    _checkedAppId = app.appId;

    // تتطلب هذه الخطوة وجود packageName في نموذج AppModel
    if (app.packageName == null) return;
    final status =
        await AppManagerService.checkAppStatus(app.packageName!, app.version);

    if (mounted) {
      setState(() {
        _currentStatus = status;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appAsync = ref.watch(appDetailProvider(widget.appId));

    return Scaffold(
      appBar: AppBar(title: const Text('App Details')),
      body: appAsync.when(
        data: (app) {
          if (app == null) return const Center(child: Text('App not found'));

          // استدعاء الفحص بعد اكتمال بناء الواجهة الأولي
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _checkAppStatus(app);
          });

          // استبدال WillPopScope بـ PopScope
          return PopScope(
            canPop: true,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: app.iconUrl != null && app.iconUrl!.isNotEmpty
                          ? Image.network(
                              app.iconUrl!,
                              height: 150,
                              width: 150,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.apps, size: 100),
                            )
                          : const Icon(Icons.apps, size: 100),
                    ),
                    const SizedBox(height: 24),
                    Text(app.name,
                        style: const TextStyle(
                            fontSize: 26, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text('Version: ${app.version}',
                            style: TextStyle(color: Colors.grey[600])),
                        if (app.size != null) ...[
                          const SizedBox(width: 16),
                          Text(
                              'Size: ${(app.size! / 1048576).toStringAsFixed(1)} MB',
                              style: TextStyle(color: Colors.grey[600])),
                        ],
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text('Description',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(app.description ?? 'No description available.',
                        style: TextStyle(color: Colors.grey[700], height: 1.5)),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: _buildActionButton(app), // فصل الزر برمجياً
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  // دالة بناء الزر استناداً إلى حالة التطبيق في النظام
  Widget _buildActionButton(AppModel app) {
    if (_currentStatus == null) {
      return const ElevatedButton(
        onPressed: null,
        child: CircularProgressIndicator(),
      );
    }

    switch (_currentStatus!) {
      case AppStatus.notInstalled:
        return ElevatedButton.icon(
          onPressed: () => _startDownload(app),
          icon: const Icon(Icons.download),
          label: const Text('تنزيل', style: TextStyle(fontSize: 18)),
          style: ElevatedButton.styleFrom(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        );
      case AppStatus.updateAvailable:
        return ElevatedButton.icon(
          onPressed: () => _startDownload(app),
          icon: const Icon(Icons.system_update),
          label: const Text('تحديث', style: TextStyle(fontSize: 18)),
          style: ElevatedButton.styleFrom(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        );
      case AppStatus.upToDate:
        return ElevatedButton.icon(
          onPressed: () {
            // توجيه المستخدم لفتح التطبيق أو طباعة رسالة
          },
          icon: const Icon(Icons.open_in_new),
          label: const Text('فتح', style: TextStyle(fontSize: 18)),
          style: ElevatedButton.styleFrom(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        );
    }
  }

  void _startDownload(AppModel app) {
    if (app.downloadUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Missing download info!')),
      );
      return;
    }

    ref.read(downloadManagerProvider.notifier).startDownload(app);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Download started! Check Download Manager.')),
    );
  }
}
