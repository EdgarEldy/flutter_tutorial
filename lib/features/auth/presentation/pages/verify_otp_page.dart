// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_tutorial/app/theme/app_theme.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../data/providers/auth_providers.dart';
import '../widgets/auth_shell_widget.dart';
import '../widgets/otp_input_field.dart';
import '../widgets/step_indicator_widget.dart';

/// Step 2 of the password-reset flow.
///
/// Author: edgar.muhamyangabo
/// Date: 2026-11-28
/// Project: flutter_tutorial
class VerifyOtpPage extends HookConsumerWidget {
  const VerifyOtpPage({super.key, required this.email});

  final String email;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final otpValue = useState('');
    final isLoading = useState(false);
    final errorMessage = useState<String?>(null);

    Future<void> onVerify() async {
      if (otpValue.value.isEmpty) return;
      errorMessage.value = null;
      isLoading.value = true;
      final result = await ref
          .read(verifyPasswordResetOtpUseCaseProvider)
          .call(email, otpValue.value);
      isLoading.value = false;
      result.fold(
        (failure) => errorMessage.value = failure.message,
        (_) => context.go(
          '/reset-password?otp=${Uri.encodeComponent(otpValue.value)}',
        ),
      );
    }

    final colorScheme = AppTheme.lightTheme.colorScheme;

    return AuthShellWidget(
      title: 'Verification Code',
      subtitle: 'Step 2 of 3',
      showBackButton: true,
      onBack: () => context.go('/forgot-password'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const StepIndicatorWidget(currentStep: 2),
          const SizedBox(height: 28),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant,
              ),
              children: [
                const TextSpan(text: 'Code sent to '),
                TextSpan(
                  text: email,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          OtpInputField(onCompleted: (value) => otpValue.value = value),
          if (errorMessage.value != null) ...[
            const SizedBox(height: 12),
            Text(
              errorMessage.value!,
              style: const TextStyle(color: Color(0xFFEF4444), fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 28),
          SizedBox(
            height: 54,
            child: FilledButton(
              onPressed: isLoading.value ? null : onVerify,
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
                      'Verify Code',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Didn't receive it? ",
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Text(
                  'Resend code',
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
      ),
    );
  }
}
