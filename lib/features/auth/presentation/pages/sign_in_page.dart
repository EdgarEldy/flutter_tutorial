// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../domain/entities/auth_state.dart';
import '../providers/auth_notifier.dart';
import '../widgets/auth_shell_widget.dart';
import '../widgets/auth_text_field.dart';

/// Sign-in screen. Delegates all actions to [AuthNotifier].
///
/// Author: edgar.muhamyangabo
/// Date: 2026-11-28
/// Project: flutter_tutorial
class SignInPage extends HookConsumerWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final passwordVisible = useState(false);
    final isLoading = authState is AuthStateLoading;
    final errorMessage = switch (authState) {
      AuthStateError(:final message) => message,
      _ => null,
    };

    return AuthShellWidget(
      heroHeight: 300,
      showLogo: true,
      title: 'TutorialShop',
      subtitle: 'Your favourite store, always with you',
      child: Builder(
        builder: (context) {
          final colorScheme = Theme.of(context).colorScheme;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Sign In',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 24),
              AuthTextField(
                controller: emailController,
                label: 'Email',
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              AuthTextField(
                controller: passwordController,
                label: 'Password',
                obscureText: !passwordVisible.value,
                textInputAction: TextInputAction.done,
                suffixIcon: IconButton(
                  icon: Icon(
                    passwordVisible.value
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  onPressed: () =>
                      passwordVisible.value = !passwordVisible.value,
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.go('/forgot-password'),
                  child: const Text(
                    'Forgot password?',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              if (errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  errorMessage,
                  style: const TextStyle(
                    color: Color(0xFFEF4444),
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                height: 54,
                child: FilledButton(
                  onPressed: isLoading
                      ? null
                      : () => ref
                            .read(authProvider.notifier)
                            .signIn(
                              emailController.text.trim(),
                              passwordController.text,
                            ),
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Sign In',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account? ",
                    style: TextStyle(fontSize: 14),
                  ),
                  GestureDetector(
                    onTap: () => context.go('/register'),
                    child: Text(
                      'Create account',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
