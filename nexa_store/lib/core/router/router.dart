import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// مسارات الصفحات
import 'package:nexa_store/features/auth/home/presentation/pages/login_page.dart';
import 'package:nexa_store/features/auth/home/presentation/pages/signup_page.dart';
import 'package:nexa_store/features/auth/providers/auth_provider.dart';

import 'package:nexa_store/features/auth/home/presentation/pages/home_page.dart';
import 'package:nexa_store/features/auth/home/presentation/pages/app_detail_page.dart';
import 'package:nexa_store/features/auth/home/presentation/pages/downloads_page.dart';
import 'package:nexa_store/features/auth/home/presentation/pages/add_app_page.dart';

class AdminPanel extends StatelessWidget {
  const AdminPanel({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Admin Panel Coming Soon')));
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    stream.listen((_) => notifyListeners());
  }
}

final goRouterProvider = Provider<GoRouter>((ref) {
  final authNotifier = ref.watch(authProvider.notifier);
  final authState = ref.watch(authProvider);

  final refreshNotifier = GoRouterRefreshStream(authNotifier.stream);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: refreshNotifier,
    routes: [
      // صفحات خارج شريط التنقل (المصادقة وصفحات المسؤول وتفاصيل التطبيق)
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignupPage(),
      ),
      GoRoute(
        path: '/add-app',
        name: 'addApp',
        builder: (context, state) => const AddAppPage(),
      ),
      GoRoute(
        path: '/app/:appId',
        name: 'appDetails',
        builder: (context, state) {
          final appId = state.pathParameters['appId']!;
          return AppDetailPage(appId: appId);
        },
      ),

      // ShellRoute: الصفحات الرئيسية مع شريط التنقل السفلي
      ShellRoute(
        builder: (context, state, child) {
          return ScaffoldWithBottomNavBar(child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            name: 'home',
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: '/downloads',
            name: 'downloads',
            builder: (context, state) => const DownloadsPage(),
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      final user = authState.user;
      final isLoggedIn = user != null;
      final isAdmin = user?.role == 'admin';

      if (isLoggedIn) {
        if (isAdmin) {
          if (state.matchedLocation == '/login' ||
              state.matchedLocation == '/signup') {
            return '/home';
          }
        } else {
          if (state.matchedLocation == '/admin-panel' ||
              state.matchedLocation == '/add-app') {
            return '/home';
          }
          if (state.matchedLocation == '/login' ||
              state.matchedLocation == '/signup') {
            return '/home';
          }
        }
      } else {
        if (state.matchedLocation != '/login' &&
            state.matchedLocation != '/signup') {
          return '/login';
        }
      }
      return null;
    },
  );
});

// ويدجت شريط التنقل السفلي
// ويدجت شريط التنقل السفلي المُحسّن
class ScaffoldWithBottomNavBar extends StatelessWidget {
  final Widget child;
  const ScaffoldWithBottomNavBar({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();

    // استخدام ألوان الثيم لضمان التناسق
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        // 🟢 الحل الجمالي هنا
        backgroundColor:
            const Color(0xFF0F172A), // خلفية داكنة أنيقة (نفس لون الثيم)
        selectedItemColor: Colors.white, // الأيقونة المختارة تكون بيضاء لامعة
        unselectedItemColor: Colors.grey, // الأيقونة غير المختارة تكون رمادية
        selectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        type: BottomNavigationBarType.fixed, // يثبت الأيقونات ولا يحركها
        currentIndex: _calculateIndex(location),
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/home');
              break;
            case 1:
              // context.go('/search'); // لاحقاً
              break;
            case 2:
              context.go('/downloads');
              break;
            case 3:
              // context.go('/profile'); // لاحقاً
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(
              icon: Icon(Icons.download), label: 'Downloads'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  int _calculateIndex(String location) {
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/downloads')) return 2;
    return 0;
  }
}
