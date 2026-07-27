import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  static Future<SharedPreferences> get prefs async =>
      await SharedPreferences.getInstance();

  // حفظ توكن المصادقة
  Future<void> setAuthToken(String token) async {
    final prefs = await LocalStorageService.prefs;
    await prefs.setString('auth_token', token);
  }

  String? getAuthToken() {
    // لا يمكن استخدام async هنا، لذا سنستخدم getSync أو نعدل إلى Future
    // لكن سنعتمد على Future للحصول على التوكن عند الحاجة
    // سنقوم بتغيير الطريقة لاحقًا
    return null;
  }

  // يمكنك إضافة دوال أخرى حسب الحاجة
}
