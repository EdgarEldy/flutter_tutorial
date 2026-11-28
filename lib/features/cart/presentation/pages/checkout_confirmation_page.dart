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
class CheckoutConfirmationPage extends HookConsumerWidget {
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
      backgroundColor: colorScheme.surfaceContainerLow,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 56,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 24),
                    // Success icon hero
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_circle_outline,
                        size: 56,
                        color: colorScheme.primary,
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
                            color: colorScheme.shadow.withValues(alpha: 0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          OrderDetailRow(
                            label: 'Order #',
                            value: '${order.id}',
                            colorScheme: colorScheme,
                            textTheme: textTheme,
                          ),
                          const SizedBox(height: 12),
                          OrderDetailRow(
                            label: 'Status',
                            value: order.status,
                            colorScheme: colorScheme,
                            textTheme: textTheme,
                            valueColor: colorScheme.primary,
                          ),
                          const Divider(height: 24),
                          OrderDetailRow(
                            label: 'Total',
                            value: '\$${order.totalAmount.toStringAsFixed(2)}',
                            colorScheme: colorScheme,
                            textTheme: textTheme,
                            isBold: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
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
            );
          },
        ),
      ),
    );
  }
}

class OrderDetailRow extends StatelessWidget {
  const OrderDetailRow({
    super.key,
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
