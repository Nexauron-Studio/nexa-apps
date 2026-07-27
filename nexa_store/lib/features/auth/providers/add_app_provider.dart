import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class AddAppState {
  final bool isLoading;
  final double uploadProgress;
  final String? error;
  final bool isSuccess;

  AddAppState({
    this.isLoading = false,
    this.uploadProgress = 0.0,
    this.error,
    this.isSuccess = false,
  });

  AddAppState copyWith({
    bool? isLoading,
    double? uploadProgress,
    String? error,
    bool? isSuccess,
  }) {
    return AddAppState(
      isLoading: isLoading ?? this.isLoading,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      error: error ?? this.error,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

class AddAppNotifier extends StateNotifier<AddAppState> {
  AddAppNotifier() : super(AddAppState());

  final SupabaseClient _client = Supabase.instance.client;

  Future<void> uploadApp({
    required String name,
    required String version,
    required String description,
    required String category,
    required File iconFile,
    required File apkFile,
  }) async {
    state = state.copyWith(
        isLoading: true, uploadProgress: 0.0, error: null, isSuccess: false);

    try {
      // 1. رفع الأيقونة
      final iconExt = iconFile.path.split('.').last;
      final iconPath =
          'icons/${DateTime.now().millisecondsSinceEpoch}.$iconExt';
      await _client.storage.from('app_assets').upload(iconPath, iconFile);
      final iconUrl = _client.storage.from('app_assets').getPublicUrl(iconPath);

      // 2. رفع ملف APK (SDK يتعامل مع الملفات الكبيرة تلقائياً)
      final apkExt = apkFile.path.split('.').last;
      final apkPath = 'apks/${DateTime.now().millisecondsSinceEpoch}.$apkExt';
      await _client.storage.from('app_assets').upload(
            apkPath,
            apkFile,
            fileOptions: const FileOptions(
              contentType: 'application/vnd.android.package-archive',
            ),
          );
      final apkUrl = _client.storage.from('app_assets').getPublicUrl(apkPath);

      // 3. حساب SHA-256 للملف APK
      final bytes = await apkFile.readAsBytes();
      final digest = sha256.convert(bytes);
      final sha256Checksum = digest.toString();

      // 4. إدراج التطبيق في جدول apps
      // استبدل الجزء الخاص بإدراج التطبيق في جدول apps بهذا الكود:
      await _client.from('apps').insert({
        'name': name,
        'version': version,
        'description': description,
        'category': category,
        'icon_url': iconUrl,
        'download_url': apkUrl,
        'sha256': sha256Checksum,
        'package_name': 'com.nexa.${name.toLowerCase().replaceAll(' ', '_')}',
        'size': apkFile.lengthSync(),
      });

      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void reset() {
    state = AddAppState(); // <-- تم إزالة const هنا
  }
}

final addAppProvider =
    StateNotifierProvider<AddAppNotifier, AddAppState>((ref) {
  return AddAppNotifier();
});
