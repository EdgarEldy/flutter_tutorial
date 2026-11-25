// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';

/// 3-step progress indicator used across the password-reset flow screens.
/// Completed steps show a checkmark; the active step shows the step number.
///
/// Author: edgar.muhamyangabo
/// Date: 2026-11-25
/// Project: flutter_tutorial
class StepIndicatorWidget extends StatelessWidget {
  const StepIndicatorWidget({
    super.key,
    required this.currentStep,
    this.labels = const ['Email', 'OTP Code', 'New'],
  });

  /// 1-based index of the currently active step.
  final int currentStep;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    const totalSteps = 3;

    return Row(
      children: List.generate(totalSteps * 2 - 1, (index) {
        if (index.isOdd) {
          // Connector line
          final stepBefore = (index ~/ 2) + 1;
          final isPassed = currentStep > stepBefore;
          return Expanded(
            child: Container(
              height: 1,
              margin: const EdgeInsets.only(bottom: 20),
              color: isPassed ? colorScheme.primary : const Color(0xFFE7E0EC),
            ),
          );
        }

        final step = index ~/ 2 + 1;
        final isCompleted = currentStep > step;
        final isActive = currentStep == step;

        return Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isCompleted || isActive
                    ? colorScheme.primary
                    : const Color(0xFFE7E0EC),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: isCompleted
                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                    : Text(
                        '$step',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isActive
                              ? Colors.white
                              : const Color(0xFF79747E),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              labels[step - 1],
              style: TextStyle(
                fontSize: 10,
                fontWeight:
                    isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive || isCompleted
                    ? colorScheme.primary
                    : const Color(0xFF79747E),
              ),
            ),
          ],
        );
      }),
    );
  }
}
