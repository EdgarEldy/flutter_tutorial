// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../data/providers/auth_providers.dart';
import '../widgets/auth_shell_widget.dart';

/// Registration screen. Calls [RegisterUseCase] and navigates to activation.
///
/// Author: edgar.muhamyangabo
/// Date: 2026-11-28
/// Project: flutter_tutorial
class RegisterPage extends HookConsumerWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firstNameController = useTextEditingController();
    final lastNameController = useTextEditingController();
    final usernameController = useTextEditingController();
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final confirmPasswordController = useTextEditingController();
    final passwordVisible = useState(false);
    final confirmPasswordVisible = useState(false);
    final isLoading = useState(false);
    final errorMessage = useState<String?>(null);

    Future<void> onRegister() async {
      errorMessage.value = null;
      isLoading.value = true;
      final result = await ref
          .read(registerUseCaseProvider)
          .call(
            firstName: firstNameController.text.trim(),
            lastName: lastNameController.text.trim(),
            username: usernameController.text.trim(),
            email: emailController.text.trim(),
            password: passwordController.text,
            confirmPassword: confirmPasswordController.text,
          );
      isLoading.value = false;
      result.fold(
        (failure) => errorMessage.value = failure.message,
        (_) => context.go(
          '/activate-account?email=${Uri.encodeComponent(emailController.text.trim())}',
        ),
      );
    }

    return AuthShellWidget(
      title: 'Create Account',
      subtitle: 'Join TutorialShop today',
      showBackButton: true,
      onBack: () => context.go('/sign-in'),
      child: Builder(
        builder: (context) {
          final colorScheme = Theme.of(context).colorScheme;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildField(
                      controller: firstNameController,
                      label: 'First Name',
                      colorScheme: colorScheme,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildField(
                      controller: lastNameController,
                      label: 'Last Name',
                      colorScheme: colorScheme,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildField(
                controller: usernameController,
                label: 'Username',
                colorScheme: colorScheme,
              ),
              const SizedBox(height: 16),
              _buildField(
                controller: emailController,
                label: 'Email',
                keyboardType: TextInputType.emailAddress,
                colorScheme: colorScheme,
              ),
              const SizedBox(height: 16),
              _buildField(
                controller: passwordController,
                label: 'Password',
                obscureText: !passwordVisible.value,
                colorScheme: colorScheme,
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
              const SizedBox(height: 16),
              _buildField(
                controller: confirmPasswordController,
                label: 'Confirm Password',
                obscureText: !confirmPasswordVisible.value,
                colorScheme: colorScheme,
                suffixIcon: IconButton(
                  icon: Icon(
                    confirmPasswordVisible.value
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  onPressed: () => confirmPasswordVisible.value =
                      !confirmPasswordVisible.value,
                ),
              ),
              if (errorMessage.value != null) ...[
                const SizedBox(height: 12),
                Text(
                  errorMessage.value!,
                  style: const TextStyle(
                    color: Color(0xFFEF4444),
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                height: 54,
                child: FilledButton(
                  onPressed: isLoading.value ? null : onRegister,
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: isLoading.value
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Create Account',
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
                    'Already have an account? ',
                    style: TextStyle(fontSize: 14),
                  ),
                  GestureDetector(
                    onTap: () => context.go('/sign-in'),
                    child: Text(
                      'Sign in',
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

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required ColorScheme colorScheme,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      textInputAction: TextInputAction.next,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        labelText: label.toUpperCase(),
        labelStyle: TextStyle(
          fontSize: 11,
          letterSpacing: 0.5,
          color: colorScheme.onSurfaceVariant,
        ),
        floatingLabelStyle: TextStyle(
          fontSize: 11,
          letterSpacing: 0.5,
          color: colorScheme.primary,
        ),
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }
}
