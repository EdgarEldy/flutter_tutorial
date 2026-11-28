// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_tutorial/app/theme/app_theme.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../data/providers/auth_providers.dart';
import '../widgets/auth_shell_widget.dart';
import '../widgets/otp_input_field.dart';

/// Account activation screen.
///
/// Author: edgar.muhamyangabo
/// Date: 2026-11-28
/// Project: flutter_tutorial
class ActivateAccountPage extends HookConsumerWidget {
  const ActivateAccountPage({super.key, required this.email});

  final String email;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final otpValue = useState('');
    final isLoading = useState(false);
    final errorMessage = useState<String?>(null);

    Future<void> onActivate() async {
      if (otpValue.value.length != 6) return;
      errorMessage.value = null;
      isLoading.value = true;
      final result = await ref
          .read(activateAccountUseCaseProvider)
          .call(email, otpValue.value);
      isLoading.value = false;
      result.fold(
        (failure) => errorMessage.value = failure.message,
        (_) => context.go('/sign-in'),
      );
    }

    final colorScheme = AppTheme.lightTheme.colorScheme;

    return AuthShellWidget(
      title: 'Activate Account',
      subtitle: 'Check your inbox',
      showBackButton: true,
      onBack: () => context.go('/register'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFEADDFF), Color(0xFFD8B4FE)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Icon(
              Icons.email_outlined,
              color: colorScheme.primary,
              size: 36,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Check your email',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
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
          const SizedBox(height: 28),
          OtpInputField(onCompleted: (value) => otpValue.value = value),
          const SizedBox(height: 8),
          Text(
            'Enter the 6-digit activation code',
            style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
          ),
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
            width: double.infinity,
            height: 54,
            child: FilledButton(
              onPressed: isLoading.value ? null : onActivate,
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
                      'Activate Account',
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
                "Didn't receive the code? ",
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Text(
                  'Resend',
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
