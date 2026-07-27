import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexa_store/core/models/app_model.dart';
import 'package:nexa_store/core/services/download_service.dart';

// حالة التنزيل
enum DownloadStatus { idle, downloading, completed, failed }

class DownloadTask {
  final String appId;
  final String appName;
  final double progress;
  final DownloadStatus status;
  final String? error;

  DownloadTask({
    required this.appId,
    required this.appName,
    this.progress = 0.0,
    this.status = DownloadStatus.downloading,
    this.error,
  });

  DownloadTask copyWith(
      {double? progress, DownloadStatus? status, String? error}) {
    return DownloadTask(
      appId: appId,
      appName: appName,
      progress: progress ?? this.progress,
      status: status ?? this.status,
      error: error ?? this.error,
    );
  }
}

class DownloadManager extends StateNotifier<Map<String, DownloadTask>> {
  DownloadManager() : super({});

  final DownloadService _service = DownloadService();

  void startDownload(AppModel app) {
    if (app.appId == null ||
        app.downloadUrl == null ||
        app.sha256Checksum == null) {
      throw Exception('Missing download info for app ${app.name}');
    }

    final task = DownloadTask(appId: app.appId!, appName: app.name);
    state = {...state, app.appId!: task};

    _service
        .downloadAndInstall(
      url: app.downloadUrl!,
      expectedSha256: app.sha256Checksum!,
      appName: app.name,
      onProgress: (progress) {
        final updatedTask = state[app.appId]!.copyWith(progress: progress);
        state = {...state, app.appId!: updatedTask};
      },
    )
        .then((_) {
      final completedTask =
          state[app.appId]!.copyWith(status: DownloadStatus.completed);
      state = {...state, app.appId!: completedTask};
    }).catchError((error) {
      final failedTask = state[app.appId]!
          .copyWith(status: DownloadStatus.failed, error: error.toString());
      state = {...state, app.appId!: failedTask};
    });
  }

  void clearCompleted(String appId) {
    final task = state[appId];
    if (task?.status == DownloadStatus.completed) {
      final newState = Map<String, DownloadTask>.from(state);
      newState.remove(appId);
      state = newState;
    }
  }
}

final downloadManagerProvider =
    StateNotifierProvider<DownloadManager, Map<String, DownloadTask>>((ref) {
  return DownloadManager();
});
