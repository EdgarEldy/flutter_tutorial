// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_tutorial/app/theme/app_theme.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../data/providers/auth_providers.dart';
import '../widgets/auth_shell_widget.dart';
import '../widgets/step_indicator_widget.dart';

/// Step 1 of the password-reset flow.
///
/// Author: edgar.muhamyangabo
/// Date: 2026-11-28
/// Project: flutter_tutorial
class ForgotPasswordPage extends HookConsumerWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = useTextEditingController();
    final isLoading = useState(false);
    final errorMessage = useState<String?>(null);

    Future<void> onSend() async {
      errorMessage.value = null;
      isLoading.value = true;
      final result = await ref
          .read(sendPasswordResetOtpUseCaseProvider)
          .call(emailController.text.trim());
      isLoading.value = false;
      result.fold(
        (failure) => errorMessage.value = failure.message,
        (_) => context.go(
          '/verify-otp?email=${Uri.encodeComponent(emailController.text.trim())}',
        ),
      );
    }

    final colorScheme = AppTheme.lightTheme.colorScheme;

    return AuthShellWidget(
      title: 'Forgot Password',
      subtitle: 'Reset in 3 steps',
      showBackButton: true,
      onBack: () => context.go('/sign-in'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const StepIndicatorWidget(currentStep: 1),
          const SizedBox(height: 28),
          Text(
            'Your email address',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter your email to receive a verification code.',
            style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => onSend(),
            style: const TextStyle(fontSize: 16),
            decoration: InputDecoration(
              labelText: 'EMAIL',
              labelStyle: TextStyle(
                fontSize: 11,
                letterSpacing: 0.5,
                color: colorScheme.onSurfaceVariant,
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
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
          if (errorMessage.value != null) ...[
            const SizedBox(height: 12),
            Text(
              errorMessage.value!,
              style: const TextStyle(color: Color(0xFFEF4444), fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            height: 54,
            child: FilledButton(
              onPressed: isLoading.value ? null : onSend,
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
                      'Send Code',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () => context.go('/sign-in'),
              child: Text(
                'Back to sign in',
                style: TextStyle(color: colorScheme.primary, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
