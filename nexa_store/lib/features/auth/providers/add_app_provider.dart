import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:crypto/crypto.dart';

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
  static const MethodChannel _installChannel =
      MethodChannel('com.example.nexa_store/install');

  Future<String?> _readApkPackageName(File apkFile) async {
    if (!Platform.isAndroid) return null;
    try {
      return await _installChannel.invokeMethod<String>(
        'getApkPackageName',
        {'path': apkFile.path},
      );
    } catch (_) {
      return null;
    }
  }

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
      final packageName = await _readApkPackageName(apkFile);
      if (packageName == null || packageName.isEmpty) {
        throw Exception(
            'تعذر قراءة package name من APK. ارفع من جهاز أندroid أو تحقق من الملف.');
      }

      final iconExt = iconFile.path.split('.').last;
      final iconPath =
          'icons/${DateTime.now().millisecondsSinceEpoch}.$iconExt';
      await _client.storage.from('app_assets').upload(iconPath, iconFile);
      final iconUrl = _client.storage.from('app_assets').getPublicUrl(iconPath);

      state = state.copyWith(uploadProgress: 0.35);

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

      state = state.copyWith(uploadProgress: 0.85);

      final bytes = await apkFile.readAsBytes();
      final sha256Checksum = sha256.convert(bytes).toString();

      final row = {
        'name': name,
        'version': version,
        'description': description,
        'category': category,
        'icon_url': iconUrl,
        'download_url': apkUrl,
        'sha256': sha256Checksum,
        'package_name': packageName,
        'size': apkFile.lengthSync(),
        'patch_url': null,
        'patch_sha256': null,
      };

      final existing = await _client
          .from('apps')
          .select('id')
          .eq('package_name', packageName)
          .maybeSingle();

      if (existing != null) {
        await _client.from('apps').update(row).eq('id', existing['id']);
      } else {
        await _client.from('apps').insert(row);
      }

      state = state.copyWith(isLoading: false, isSuccess: true, uploadProgress: 1);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void reset() {
    state = AddAppState();
  }
}

final addAppProvider =
    StateNotifierProvider<AddAppNotifier, AddAppState>((ref) {
  return AddAppNotifier();
});
