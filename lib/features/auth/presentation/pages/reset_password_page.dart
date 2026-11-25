// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../data/providers/auth_providers.dart';
import '../widgets/step_indicator_widget.dart';

/// Step 3 of the password-reset flow: sets a new password using the OTP token.
///
/// Author: edgar.muhamyangabo
/// Date: 2026-11-25
/// Project: flutter_tutorial
class ResetPasswordPage extends HookConsumerWidget {
  const ResetPasswordPage({super.key, required this.otp});

  final String otp;

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
    final newPasswordController = useTextEditingController();
    final confirmPasswordController = useTextEditingController();
    final newPasswordVisible = useState(false);
    final confirmPasswordVisible = useState(false);
    final isLoading = useState(false);
    final errorMessage = useState<String?>(null);

    Future<void> onReset() async {
      errorMessage.value = null;
      isLoading.value = true;
      final result = await ref
          .read(confirmPasswordResetUseCaseProvider)
          .call(otp, newPasswordController.text, confirmPasswordController.text);
      isLoading.value = false;
      result.fold(
        (failure) => errorMessage.value = failure.message,
        (_) => context.go('/sign-in'),
      );
    }

    final cs = Theme.of(context).colorScheme;

    InputDecoration fieldDecoration(String label, {bool focused = false}) =>
        InputDecoration(
          labelText: label.toUpperCase(),
          labelStyle: TextStyle(
            fontSize: 11,
            letterSpacing: 0.5,
            color: focused ? cs.primary : const Color(0xFF49454F),
          ),
          floatingLabelStyle: TextStyle(
            fontSize: 11,
            letterSpacing: 0.5,
            color: cs.primary,
          ),
          filled: true,
          fillColor: const Color(0xFFF4EFF4),
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
            borderSide: BorderSide(color: cs.primary, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        );

    return Scaffold(
      backgroundColor: const Color(0xFFF7F5FF),
      body: SingleChildScrollView(
        child: Column(
          children: [
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
                          onTap: () => context.go('/forgot-password'),
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
                          'New Password',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Step 3 of 3 - Last step!',
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
            Transform.translate(
              offset: const Offset(0, -28),
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFFFFBFE),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const StepIndicatorWidget(currentStep: 4),
                      const SizedBox(height: 28),
                      const Text(
                        'Create your new password',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1C1B1F),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: newPasswordController,
                        obscureText: !newPasswordVisible.value,
                        textInputAction: TextInputAction.next,
                        style: const TextStyle(fontSize: 16),
                        decoration: fieldDecoration('New Password').copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(
                              newPasswordVisible.value
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: cs.primary,
                            ),
                            onPressed: () => newPasswordVisible.value =
                                !newPasswordVisible.value,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: confirmPasswordController,
                        obscureText: !confirmPasswordVisible.value,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => onReset(),
                        style: const TextStyle(fontSize: 16),
                        decoration: fieldDecoration('Confirm Password').copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(
                              confirmPasswordVisible.value
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: const Color(0xFF79747E),
                            ),
                            onPressed: () => confirmPasswordVisible.value =
                                !confirmPasswordVisible.value,
                          ),
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
                          onPressed: isLoading.value ? null : onReset,
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
                                  'Reset Password',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
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
