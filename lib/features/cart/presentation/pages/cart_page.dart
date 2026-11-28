// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../providers/cart_notifier.dart';
import '../../domain/entities/cart.dart';

/// Cart page showing all items, quantity controls, and a checkout button.
/// Cart state is fully server-authoritative; totals are never recalculated.
///
/// Author: edgar.muhamyangabo
/// Date: 2026-11-26
/// Project: flutter_tutorial
class CartPage extends HookConsumerWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Navigate to confirmation when lastOrder is set after checkout
    ref.listen(cartProvider, (previous, next) {
      if (previous?.lastOrder == null &&
          next.lastOrder != null &&
          context.mounted) {
        context.go('/checkout-confirmation');
      }
    });

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLow,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        toolbarHeight: 64,
        title: Text(
          'My Cart',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
      ),
      body: Builder(
        builder: (context) {
          if (cartState.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (cartState.errorMessage != null && cartState.cart == null) {
            return _ErrorState(
              message: cartState.errorMessage!,
              onRetry: () => ref.read(cartProvider.notifier).refresh(),
            );
          }

          final cart = cartState.cart;
          if (cart == null || cart.items.isEmpty) {
            return _EmptyCartState();
          }

          return Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => ref.read(cartProvider.notifier).refresh(),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    itemCount: cart.items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      return CartItemCard(
                        item: item,
                        onDecrement: () {
                          if (item.quantity > 1) {
                            ref
                                .read(cartProvider.notifier)
                                .updateItem(item.id, item.quantity - 1);
                          } else {
                            ref.read(cartProvider.notifier).removeItem(item.id);
                          }
                        },
                        onIncrement: () {
                          ref
                              .read(cartProvider.notifier)
                              .updateItem(item.id, item.quantity + 1);
                        },
                        onRemove: () {
                          ref.read(cartProvider.notifier).removeItem(item.id);
                        },
                      );
                    },
                  ),
                ),
              ),
              CartSummaryBar(
                totalAmount: cart.totalAmount,
                isCheckingOut: cartState.isCheckingOut,
                errorMessage: cartState.errorMessage,
                onCheckout: () => ref.read(cartProvider.notifier).checkout(),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _EmptyCartState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 80,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 20),
            Text(
              'Your cart is empty',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add some products to get started',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: () => context.go('/products'),
              icon: const Icon(Icons.storefront_outlined),
              label: const Text('Browse products'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

class CartItemCard extends StatelessWidget {
  const CartItemCard({
    super.key,
    required this.item,
    required this.onDecrement,
    required this.onIncrement,
    required this.onRemove,
  });

  final CartItem item;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.shopping_bag_outlined,
                size: 34,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.productName,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${item.unitPrice.toStringAsFixed(2)} / unit',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Subtotal: \$${item.subtotal.toStringAsFixed(2)}',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              children: [
                IconButton(
                  onPressed: onRemove,
                  icon: Icon(
                    Icons.delete_outline,
                    color: colorScheme.error,
                    size: 20,
                  ),
                  style: IconButton.styleFrom(
                    minimumSize: const Size(48, 48),
                    padding: EdgeInsets.zero,
                  ),
                ),
                const SizedBox(height: 4),
                QuantityControl(
                  quantity: item.quantity,
                  onDecrement: onDecrement,
                  onIncrement: onIncrement,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class QuantityControl extends StatelessWidget {
  const QuantityControl({
    super.key,
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
  });

  final int quantity;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _SmallButton(
          icon: Icons.remove,
          onTap: onDecrement,
          colorScheme: colorScheme,
        ),
        SizedBox(
          width: 32,
          child: Text(
            '$quantity',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        _SmallButton(
          icon: Icons.add,
          onTap: onIncrement,
          colorScheme: colorScheme,
        ),
      ],
    );
  }
}

class _SmallButton extends StatelessWidget {
  const _SmallButton({
    required this.icon,
    required this.onTap,
    required this.colorScheme,
  });

  final IconData icon;
  final VoidCallback onTap;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      constraints: const BoxConstraints.tightFor(width: 48, height: 48),
      iconSize: 18,
      style: IconButton.styleFrom(
        backgroundColor: colorScheme.primaryContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      icon: Icon(icon, size: 18, color: colorScheme.onPrimaryContainer),
    );
  }
}

class CartSummaryBar extends StatelessWidget {
  const CartSummaryBar({
    super.key,
    required this.totalAmount,
    required this.isCheckingOut,
    required this.onCheckout,
    this.errorMessage,
  });

  final double totalAmount;
  final bool isCheckingOut;
  final VoidCallback onCheckout;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(color: colorScheme.outlineVariant, width: 0.5),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (errorMessage != null) ...[
            Text(
              errorMessage!,
              style: textTheme.bodySmall?.copyWith(color: colorScheme.error),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '\$${totalAmount.toStringAsFixed(2)}',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 52,
            child: FilledButton(
              onPressed: isCheckingOut ? null : onCheckout,
              child: isCheckingOut
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colorScheme.onPrimary,
                      ),
                    )
                  : const Text(
                      'Checkout',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
