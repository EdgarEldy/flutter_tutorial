// ignore_for_file: deprecated_member_use
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../providers/product_detail_notifier.dart';
import '../../../cart/presentation/providers/cart_notifier.dart';

/// Product detail page. Displays full product info, a quantity selector
/// and an Add to Cart placeholder button.
///
/// Author: edgar.muhamyangabo
/// Date: 2026-11-25
/// Project: flutter_tutorial
class ProductDetailPage extends HookConsumerWidget {
  const ProductDetailPage({super.key, required this.productId});

  final int productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(productDetailProvider(productId));
    final quantity = useState(1);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLow,
      body: productAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              e.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(color: colorScheme.error),
            ),
          ),
        ),
        data: (product) => CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              elevation: 0,
              surfaceTintColor: Colors.transparent,
              backgroundColor: Colors.transparent,
              leading: Padding(
                padding: const EdgeInsets.all(8),
                child: Material(
                  color: colorScheme.surface.withOpacity(0.8),
                  shape: const CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: BackButton(color: colorScheme.onSurface),
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: product.primaryImageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: product.primaryImageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, _) => _GradientPlaceholder(),
                        errorWidget: (_, _, _) => _GradientPlaceholder(),
                      )
                    : _GradientPlaceholder(),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  if (product.categoryName != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        product.categoryName!,
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  Text(
                    product.name,
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${product.unitPrice.toStringAsFixed(2)}',
                    style: textTheme.headlineMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (product.description != null &&
                      product.description!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      product.description!,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                  ],
                  const SizedBox(height: 28),
                  _QuantitySelector(
                    quantity: quantity.value,
                    onDecrement: () {
                      if (quantity.value > 1) quantity.value--;
                    },
                    onIncrement: () => quantity.value++,
                    colorScheme: colorScheme,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton.icon(
                      onPressed: () async {
                        final notifier =
                            ref.read(cartProvider.notifier);
                        await notifier.addItem(product.id, quantity.value);
                        if (!context.mounted) return;
                        final error = ref.read(cartProvider).errorMessage;
                        if (error != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(error),
                              backgroundColor:
                                  Theme.of(context).colorScheme.error,
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Added to cart'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.shopping_cart_outlined),
                      label: const Text('Add to Cart'),
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GradientPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            colorScheme.primaryContainer,
            colorScheme.secondaryContainer,
          ],
        ),
      ),
    );
  }
}

class _QuantitySelector extends StatelessWidget {
  const _QuantitySelector({
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
    required this.colorScheme,
  });

  final int quantity;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'Quantity',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const Spacer(),
        _CounterButton(
          icon: Icons.remove,
          onTap: onDecrement,
          colorScheme: colorScheme,
        ),
        SizedBox(
          width: 40,
          child: Text(
            '$quantity',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        _CounterButton(
          icon: Icons.add,
          onTap: onIncrement,
          colorScheme: colorScheme,
        ),
      ],
    );
  }
}

class _CounterButton extends StatelessWidget {
  const _CounterButton({
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
      iconSize: 20,
      constraints: const BoxConstraints.tightFor(width: 48, height: 48),
      style: IconButton.styleFrom(
        backgroundColor: colorScheme.primaryContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon: Icon(icon, size: 20, color: colorScheme.onPrimaryContainer),
    );
  }
}
