// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../data/providers/auth_providers.dart';
import '../widgets/otp_input_field.dart';

/// Account activation screen. Email is pre-filled from the route query param.
/// Calls [ActivateAccountUseCase] and navigates to sign-in on success.
///
/// Author: edgar.muhamyangabo
/// Date: 2026-11-25
/// Project: flutter_tutorial
class ActivateAccountPage extends HookConsumerWidget {
  const ActivateAccountPage({super.key, required this.email});

  final String email;

  static const _heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    transform: GradientRotation(2.792),
    colors: [
      Color(0xFF7C3AED),
      Color(0xFF6750A4),
      Color(0xFF4A3580),
    ],
    stops: [0.0, 0.55, 1.0],
  );

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

    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero (200dp)
            SizedBox(
              height: 200,
              child: Container(
                decoration: const BoxDecoration(gradient: _heroGradient),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () => context.go('/register'),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0x26FFFFFF),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0x33FFFFFF),
                              ),
                            ),
                            child: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                        const Spacer(),
                        const Text(
                          'Activate Account',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Check your inbox',
                          style: TextStyle(
                            color: Color(0xA6FFFFFF),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // White card
            Transform.translate(
              offset: const Offset(0, -28),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Email envelope icon
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
                          color: cs.primary,
                          size: 36,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Check your email',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: cs.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 14,
                            color: cs.onSurfaceVariant,
                          ),
                          children: [
                            const TextSpan(text: 'Code sent to '),
                            TextSpan(
                              text: email,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: cs.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      OtpInputField(
                        onCompleted: (value) => otpValue.value = value,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Enter the 6-digit activation code',
                        style: TextStyle(
                          fontSize: 12,
                          color: cs.onSurfaceVariant,
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
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {},
                            child: Text(
                              'Resend',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: cs.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
