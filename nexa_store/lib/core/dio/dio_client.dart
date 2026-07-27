import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DioClient {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: dotenv
          .env['SUPABASE_URL']!, // سيصبح: https://hwwtzwzwhoaomvylakwm.supabase.co
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'apikey': dotenv.env['SUPABASE_ANON_KEY']!, // سيصبح: المفتاح العام
        'Content-Type': 'application/json',
      },
    ),
  );

  static Dio get instance => _dio;

  static void addInterceptor(Interceptor interceptor) {
    _dio.interceptors.add(interceptor);
  }
}
