import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nexa_store/core/models/user_model.dart';
import 'package:nexa_store/core/dio/dio_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? errorMessage;

  AuthState({this.user, this.isLoading = false, this.errorMessage});

  AuthState copyWith({UserModel? user, bool? isLoading, String? errorMessage}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState(isLoading: true)) {
    _checkCurrentUser();
  }

  Future<void> _checkCurrentUser() async {
    try {
      final session = Supabase.instance.client.auth.currentSession;
      if (session != null) {
        final user = session.user;
        await _fetchUserProfile(user.id);
      } else {
        state = state.copyWith(user: null, isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(
          user: null, isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user != null) {
        await _fetchUserProfile(response.user!.id);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  // التسجيل باستخدام REST API (يعمل في أي إصدار)
  // التسجيل باستخدام REST API (يعمل في أي إصدار)
  Future<void> signUp({
    required String email,
    required String password,
    required String username,
    String? secretKey,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      // تجهيز البيانات
      final url = '${dotenv.env['SUPABASE_URL']}/auth/v1/signup';
      final anonKey = dotenv.env['SUPABASE_ANON_KEY']!;

      final Map<String, dynamic> body = {
        'email': email,
        'password': password,
        'options': {
          'data': {
            'username': username,
            'secret_key': secretKey ?? '',
          },
        },
      };

      // 1. إرسال طلب التسجيل
      final response = await DioClient.instance.post(
        url,
        data: body,
        options: Options(headers: {
          'apikey': anonKey,
          'Content-Type': 'application/json',
        }),
      );

      if (response.statusCode == 200) {
        // 2. الحساب تم إنشاؤه. الآن نقوم بتسجيل الدخول مباشرة للحصول على الـ Session
        final loginResponse =
            await Supabase.instance.client.auth.signInWithPassword(
          email: email,
          password: password,
        );

        if (loginResponse.user != null) {
          // 3. نجح تسجيل الدخول، الآن نحاول جلب البروفايل (إذا فشل، لن يمنع ذلك التطبيق)
          try {
            final profileResponse = await Supabase.instance.client
                .from('profiles')
                .select()
                .eq('id', loginResponse.user!.id)
                .single();
            final userModel =
                UserModel.fromJson(Map<String, dynamic>.from(profileResponse));
            state = state.copyWith(user: userModel, isLoading: false);
          } catch (e) {
            // في حال فشل جلب البروفايل (لأن Trigger فشل)، نضعه فارغاً مؤقتاً
            // لكننا نعتبر أن المستخدم مسجل دخول بنجاح
            state = state.copyWith(
              isLoading: false,
              user: UserModel(
                  userId: loginResponse.user!.id,
                  email: email,
                  username: username,
                  role: 'user'),
            );
          }
        } else {
          state = state.copyWith(
              isLoading: false, errorMessage: 'Login failed after signup.');
        }
      } else {
        state = state.copyWith(
            isLoading: false,
            errorMessage:
                'Failed to create account. Status: ${response.statusCode}');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> _fetchUserProfile(String userId) async {
    try {
      final response = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      final userModel = UserModel.fromJson(Map<String, dynamic>.from(response));
      state = state.copyWith(user: userModel, isLoading: false);
    } catch (e) {
      // إذا فشل جلب البروفايل، نعتبر أن المستخدم مسجل لكننا لا نملك بيانات إضافية
      state = state.copyWith(
          isLoading: false,
          errorMessage: 'Account created but profile not loaded');
    }
  }

  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
    state = state.copyWith(user: null);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
