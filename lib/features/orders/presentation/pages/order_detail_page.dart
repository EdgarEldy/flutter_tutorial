// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../domain/entities/order.dart';
import '../providers/order_detail_notifier.dart';
import '../widgets/order_status_badge.dart';
import '../widgets/order_detail_cards.dart';

/// Order detail page showing tracking timeline, item list and order summary.
/// Receives [orderId] from the route and delegates loading to [OrderDetailNotifier].
///
/// Author: edgar.muhamyangabo
/// Date: 2026-11-26
/// Project: flutter_tutorial
class OrderDetailPage extends HookConsumerWidget {
  const OrderDetailPage({super.key, required this.orderId});

  final int orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderDetailProvider(orderId));
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                SizedBox(
                  width: 36,
                  height: 36,
                  child: Material(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(11),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => context.pop(),
                      child: Icon(
                        Icons.arrow_back,
                        size: 20,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    orderAsync.maybeWhen(
                      data: (order) => 'Order #${order.orderNumber}',
                      orElse: () => 'Order Detail',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                if (orderAsync.value != null)
                  OrderStatusBadge(status: orderAsync.value!.status),
              ],
            ),
          ),
          Expanded(
            child: orderAsync.when(
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
              data: (order) => _OrderDetailBody(order: order),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderDetailBody extends StatelessWidget {
  const _OrderDetailBody({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        OrderTrackingCard(status: order.status),
        const SizedBox(height: 16),
        OrderItemsCard(order: order),
        const SizedBox(height: 16),
        OrderSummaryCard(
          subtotal: order.items.fold(0, (sum, item) => sum + item.subtotal),
          totalAmount: order.totalAmount,
        ),
      ],
    );
  }
}
