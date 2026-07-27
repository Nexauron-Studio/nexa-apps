import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexa_store/features/auth/providers/auth_provider.dart';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _secretKeyController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    _secretKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      // إضافة SafeArea لحماية المحتوى من حواف الشاشة (مثل النتوءات)
      body: SafeArea(
        child: SingleChildScrollView(
          // <-- هذا هو الحل السحري للخطأ
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Create NEXA Account',
                    style:
                        TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 40),
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(labelText: 'Username'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password'),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _secretKeyController,
                  decoration: const InputDecoration(
                    labelText: 'Admin Secret Key (Optional)',
                    hintText: 'Enter key if you are an admin',
                  ),
                ),
                const SizedBox(height: 24),
                if (authState.errorMessage != null)
                  Text(authState.errorMessage!,
                      style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            await ref.read(authProvider.notifier).signUp(
                                  email: _emailController.text.trim(),
                                  password: _passwordController.text.trim(),
                                  username: _usernameController.text.trim(),
                                  secretKey: _secretKeyController.text
                                          .trim()
                                          .isNotEmpty
                                      ? _secretKeyController.text.trim()
                                      : null,
                                );
                          },
                    child: isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Sign Up'),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: const Text('Already have an account? Login'),
                ),
                // إضافة مساحة إضافية في الأسفل لضمان عدم تغطية لوحة المفاتيح للزر
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
