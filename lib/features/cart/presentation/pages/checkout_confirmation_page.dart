// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../providers/cart_notifier.dart';

/// Order confirmation page shown immediately after a successful checkout.
/// Reads the last order from CartNotifier; navigates to orders or products.
///
/// Author: edgar.muhamyangabo
/// Date: 2026-11-26
/// Project: flutter_tutorial
class CheckoutConfirmationPage extends ConsumerWidget {
  const CheckoutConfirmationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartProvider);
    final order = cartState.lastOrder;

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (order == null) {
      // Safety net: if the user navigates here without an order
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('No order found.', style: textTheme.bodyLarge),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => context.go('/products'),
                child: const Text('Go to products'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              // Success icon hero
              const SizedBox(height: 0), // top spacer anchor
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: Color(0xFFDCFCE7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  size: 56,
                  color: Color(0xFF16A34A),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'Order Confirmed!',
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Your order has been placed successfully',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              // Order details card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.onSurface.withOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _OrderDetailRow(
                      label: 'Order #',
                      value: '${order.id}',
                      colorScheme: colorScheme,
                      textTheme: textTheme,
                    ),
                    const SizedBox(height: 12),
                    _OrderDetailRow(
                      label: 'Status',
                      value: order.status,
                      colorScheme: colorScheme,
                      textTheme: textTheme,
                      valueColor: const Color(0xFF16A34A),
                    ),
                    const Divider(height: 24),
                    _OrderDetailRow(
                      label: 'Total',
                      value: '\$${order.totalAmount.toStringAsFixed(2)}',
                      colorScheme: colorScheme,
                      textTheme: textTheme,
                      isBold: true,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Actions
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: () => context.go('/orders'),
                  child: const Text(
                    'View orders',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () => context.go('/products'),
                  child: const Text(
                    'Continue shopping',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderDetailRow extends StatelessWidget {
  const _OrderDetailRow({
    required this.label,
    required this.value,
    required this.colorScheme,
    required this.textTheme,
    this.valueColor,
    this.isBold = false,
  });

  final String label;
  final String value;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final Color? valueColor;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: (isBold ? textTheme.titleMedium : textTheme.bodyMedium)
              ?.copyWith(
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            color: valueColor ?? colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
