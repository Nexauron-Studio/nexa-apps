import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexa_store/app.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print('⚠️ Could not load .env file: $e');
    // إذا فشل التحميل، يمكنك استخدام القيم المباشرة للتطوير (ليس للإنتاج)
    // لكن الأفضل أن تطلب من المستخدم إنشاء الملف.
  }

  // داخل main.dart، بعد تحميل dotenv
  final supabaseUrl =
      dotenv.env['SUPABASE_URL'] ?? 'https://hwwtzwzwhoaomvylakwm.supabase.co';
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ??
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imh3d3R6d3p3aG9hb212eWxha3dtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODUwODcxMDcsImV4cCI6MjEwMDY2MzEwN30.PkhdMYC3unp_AHsAY9E1WtGujoWA4PKvYh8ufOwP6V8';

  if (supabaseUrl == null || supabaseAnonKey == null) {
    print('❌ Error: Missing SUPABASE_URL or SUPABASE_ANON_KEY in .env');
    // للتطوير فقط، يمكنك وضع القيم هنا مؤقتاً:
    // final url = 'https://hwwtzwzwhoaomvylakwm.supabase.co';
    // final anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
    // await Supabase.initialize(url: url, publishableKey: anonKey);
    // لكن لا ترسل هذا الكود للإنتاج.
    throw Exception('Missing environment variables. Please create .env file.');
  }

  await Supabase.initialize(
    url: supabaseUrl,
    publishableKey: supabaseAnonKey,
  );

  runApp(const ProviderScope(child: NEXAApp()));
}
