import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexa_store/features/auth/providers/download_manager.dart';

class DownloadsPage extends ConsumerWidget {
  const DownloadsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(downloadManagerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Download Manager')),
      body: tasks.isEmpty
          ? const Center(child: Text('No active downloads'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks.values.elementAt(index);
                return _buildTaskTile(task, ref);
              },
            ),
    );
  }

  Widget _buildTaskTile(DownloadTask task, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(Icons.android, size: 40),
        title: Text(task.appName),
        subtitle: task.status == DownloadStatus.downloading
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LinearProgressIndicator(value: task.progress),
                  const SizedBox(height: 4),
                  Text('${(task.progress * 100).toStringAsFixed(0)}%'),
                ],
              )
            : Text(task.status == DownloadStatus.completed
                ? 'Installed successfully'
                : task.error ?? 'Failed'),
        trailing: task.status == DownloadStatus.downloading
            ? const Icon(Icons.download, color: Colors.blue)
            : IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  if (task.status == DownloadStatus.completed) {
                    ref
                        .read(downloadManagerProvider.notifier)
                        .clearCompleted(task.appId);
                  }
                },
              ),
      ),
    );
  }
}
