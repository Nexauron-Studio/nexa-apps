import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nexa_store/core/constants.dart';

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.sharedPrefsTokenKey);

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    // إضافة توكن Supabase إذا لزم الأمر (عادة Supabase يستخدم التوكن في الـ header)
    // لكن بما أن Supabase SDK يتعامل مع هذا آلياً، قد لا نحتاج لاعتراضية يدوية إذا استخدمنا SDK مباشرة.
    // لكننا سنحتفظ بها للاستخدام مع Dio في حالات خاصة.
    handler.next(options);
  }
}
