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
    debugPrint('Could not load .env file: $e');
  }

  final supabaseUrl =
      dotenv.env['SUPABASE_URL'] ?? 'https://hwwtzwzwhoaomvylakwm.supabase.co';
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ??
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imh3d3R6d3p3aG9hb212eWxha3dtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODUwODcxMDcsImV4cCI6MjEwMDY2MzEwN30.PkhdMYC3unp_AHsAY9E1WtGujoWA4PKvYh8ufOwP6V8';

  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    throw Exception('Missing environment variables. Please create .env file.');
  }

  await Supabase.initialize(
    url: supabaseUrl,
    publishableKey: supabaseAnonKey,
  );

  runApp(const ProviderScope(child: NEXAApp()));
}
