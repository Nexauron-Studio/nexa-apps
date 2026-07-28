import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexa_store/core/models/app_model.dart';
import 'package:nexa_store/core/services/app_service.dart'; // مسار ملف الفحص
import 'package:nexa_store/features/auth/providers/auth_provider.dart';
import 'package:nexa_store/core/services/update_checker.dart';

final appsProvider = FutureProvider<List<AppModel>>((ref) async {
  return await AppService().fetchApps();
});

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      UpdateChecker().checkForUpdates(context); // استخدام الفئة المصححة
    });
  }

  @override
  Widget build(BuildContext context) {
    final appsAsync = ref.watch(appsProvider);
    final authState = ref.watch(authProvider);
    final isAdmin = authState.user?.role == 'admin';

    debugPrint('User Role: ${authState.user?.role}');
    debugPrint('Is Admin: $isAdmin');

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('NEXA Store'),
            Text(
              'Role: ${authState.user?.role ?? 'unknown'}',
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.add_box_outlined),
              tooltip: 'Add New App',
              onPressed: () {
                context.go('/add-app');
              },
            ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: appsAsync.when(
        data: (apps) {
          if (apps.isEmpty) {
            return const Center(child: Text('No apps available yet.'));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: apps.length,
            itemBuilder: (context, index) {
              final app = apps[index];
              return _buildAppCard(context, app);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildAppCard(BuildContext context, AppModel app) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          if (app.appId != null) {
            context.push('/app/${app.appId}');
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Center(
                  child: app.iconUrl != null && app.iconUrl!.isNotEmpty
                      ? Image.network(
                          app.iconUrl!,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.apps, size: 48);
                          },
                        )
                      : const Icon(Icons.apps, size: 64),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    app.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    app.version,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.download, size: 14, color: Colors.grey[400]),
                      const SizedBox(width: 4),
                      Text(
                        '${app.downloadsCount ?? 0}',
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      ),
                      const Spacer(),
                      if (app.rating != null)
                        Row(
                          children: [
                            const Icon(Icons.star,
                                size: 14, color: Colors.amber),
                            const SizedBox(width: 2),
                            Text(
                              app.rating!.toStringAsFixed(1),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
