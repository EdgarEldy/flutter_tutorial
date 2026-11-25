// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';

/// Filled input field following Material 3 auth design spec.
/// Label is displayed uppercase with letter spacing.
class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.suffixIcon,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final TextInputType keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
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
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 1.5,
          ),
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
