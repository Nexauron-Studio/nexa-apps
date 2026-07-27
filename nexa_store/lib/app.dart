import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexa_store/core/router/router.dart';
import 'package:nexa_store/core/theme.dart';

class NEXAApp extends ConsumerWidget {
  const NEXAApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'NEXA Store',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme, // استخدام الثيم الداكن مثلاً
      routerConfig: router,
    );
  }
}
