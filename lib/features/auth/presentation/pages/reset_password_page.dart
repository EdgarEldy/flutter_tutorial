// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_tutorial/app/theme/app_theme.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../data/providers/auth_providers.dart';
import '../widgets/auth_shell_widget.dart';
import '../widgets/step_indicator_widget.dart';

/// Step 3 of the password-reset flow.
///
/// Author: edgar.muhamyangabo
/// Date: 2026-11-28
/// Project: flutter_tutorial
class ResetPasswordPage extends HookConsumerWidget {
  const ResetPasswordPage({super.key, required this.otp});

  final String otp;

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
          .call(
            otp,
            newPasswordController.text,
            confirmPasswordController.text,
          );
      isLoading.value = false;
      result.fold(
        (failure) => errorMessage.value = failure.message,
        (_) => context.go('/sign-in'),
      );
    }

    final colorScheme = AppTheme.lightTheme.colorScheme;

    return AuthShellWidget(
      title: 'New Password',
      subtitle: 'Step 3 of 3 - Last step!',
      showBackButton: true,
      onBack: () => context.go('/forgot-password'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const StepIndicatorWidget(currentStep: 3),
          const SizedBox(height: 28),
          Text(
            'Create your new password',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: newPasswordController,
            obscureText: !newPasswordVisible.value,
            textInputAction: TextInputAction.next,
            style: const TextStyle(fontSize: 16),
            decoration: _fieldDecoration(colorScheme, 'New Password').copyWith(
              suffixIcon: IconButton(
                icon: Icon(
                  newPasswordVisible.value
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: colorScheme.primary,
                ),
                onPressed: () =>
                    newPasswordVisible.value = !newPasswordVisible.value,
              ),
            ),
          ),
          PasswordStrengthBar(controller: newPasswordController),
          const SizedBox(height: 16),
          TextField(
            controller: confirmPasswordController,
            obscureText: !confirmPasswordVisible.value,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => onReset(),
            style: const TextStyle(fontSize: 16),
            decoration: _fieldDecoration(colorScheme, 'Confirm Password')
                .copyWith(
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
    );
  }

  InputDecoration _fieldDecoration(ColorScheme colorScheme, String label) {
    return InputDecoration(
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}

class PasswordStrengthBar extends StatefulWidget {
  const PasswordStrengthBar({super.key, required this.controller});

  final TextEditingController controller;

  @override
  State<PasswordStrengthBar> createState() => _PasswordStrengthBarState();
}

class _PasswordStrengthBarState extends State<PasswordStrengthBar> {
  int _strength = 0;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_update);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_update);
    super.dispose();
  }

  void _update() {
    final password = widget.controller.text;
    var strength = 0;
    if (password.length >= 8) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[^A-Za-z0-9]'))) strength++;
    setState(() => _strength = strength);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.controller.text.isEmpty) return const SizedBox.shrink();

    const colors = [
      Color(0xFFEF4444),
      Color(0xFFCA8A04),
      Color(0xFF6750A4),
      Color(0xFF16A34A),
    ];
    const labels = ['Weak', 'Fair', 'Good', 'Strong'];
    final index = (_strength - 1).clamp(0, 3);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          children: List.generate(4, (i) {
            return Expanded(
              child: Container(
                margin: EdgeInsets.only(right: i < 3 ? 3 : 0),
                height: 4,
                decoration: BoxDecoration(
                  color: i < _strength
                      ? colors[index]
                      : const Color(0xFFE7E0EC),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 4),
        Text(
          labels[index],
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: colors[index],
          ),
        ),
      ],
    );
  }
}
