// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:flutter_tutorial/features/orders/domain/entities/order.dart';
import 'package:flutter_tutorial/features/orders/presentation/pages/order_detail_page.dart';
import 'package:flutter_tutorial/features/orders/presentation/providers/order_detail_notifier.dart';
import 'package:flutter_tutorial/features/orders/presentation/widgets/order_detail_cards.dart';
import 'package:flutter_tutorial/features/orders/presentation/widgets/order_status_badge.dart';

void main() {
  const headphone = OrderItem(
    id: 1,
    productId: 10,
    productName: 'Wireless Headphones',
    unitPrice: 129.50,
    quantity: 2,
    subtotal: 259.00,
  );

  const keyboard = OrderItem(
    id: 2,
    productId: 11,
    productName: 'Mechanical Keyboard',
    unitPrice: 59.99,
    quantity: 1,
    subtotal: 59.99,
  );

  const confirmedOrder = Order(
    id: 1,
    orderNumber: 'ORD-001',
    status: OrderStatus.confirmed,
    totalAmount: 318.99,
    items: [headphone, keyboard],
  );

  Widget buildUnderTest(AsyncValue<Order> state, {int orderId = 1}) {
    final container = ProviderContainer(
      overrides: [
        orderDetailProvider(orderId).overrideWithValue(state),
      ],
    );
    addTearDown(container.dispose);

    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp(home: OrderDetailPage(orderId: orderId)),
    );
  }

  testWidgets('390x844: shows loading state', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(buildUnderTest(const AsyncLoading(), orderId: 10));
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('Order Detail'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows error state', (tester) async {
    await tester.pumpWidget(
      buildUnderTest(
        AsyncError<Order>('Order not found', StackTrace.current),
        orderId: 11,
      ),
    );
    await tester.pump();

    expect(find.text('Order Detail'), findsOneWidget);
    expect(find.text('Order not found'), findsOneWidget);
  });

  testWidgets(
    'renders status badge, tracking timeline, items and complete summary',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        buildUnderTest(const AsyncData(confirmedOrder)),
      );
      await tester.pump();

      expect(find.text('Order #ORD-001'), findsOneWidget);
      expect(find.byType(OrderStatusBadge), findsOneWidget);
      expect(find.text('Confirmed'), findsOneWidget);

      expect(find.text('Tracking'), findsOneWidget);
      expect(find.text('Order placed'), findsOneWidget);
      expect(find.text('Shipped'), findsOneWidget);
      expect(find.text('Delivered'), findsOneWidget);

      expect(find.byType(OrderTrackingCard), findsOneWidget);
      expect(find.byType(OrderItemsCard), findsOneWidget);
      expect(find.text('Items (2)'), findsOneWidget);
      expect(find.text('Wireless Headphones'), findsOneWidget);
      expect(find.text('x2'), findsOneWidget);
      expect(find.text('\$129.50'), findsOneWidget);
      expect(find.text('Mechanical Keyboard'), findsOneWidget);
      expect(find.text('x1'), findsOneWidget);
      expect(find.text('\$59.99'), findsOneWidget);

      expect(find.byType(OrderSummaryCard), findsOneWidget);
      expect(find.text('Summary'), findsOneWidget);
      expect(find.text('Subtotal'), findsOneWidget);
      expect(find.text('Shipping'), findsOneWidget);
      expect(find.text('Free'), findsOneWidget);
      expect(find.text('Total'), findsOneWidget);
      expect(find.text('\$318.99'), findsNWidgets(2));
    },
  );

  testWidgets('pending tracking marks only order placed as active', (
    tester,
  ) async {
    const pendingOrder = Order(
      id: 2,
      orderNumber: 'ORD-002',
      status: OrderStatus.pending,
      totalAmount: 129.50,
      items: [headphone],
    );

    await tester.pumpWidget(
      buildUnderTest(const AsyncData(pendingOrder), orderId: 2),
    );
    await tester.pump();

    expect(find.text('Processing'), findsOneWidget);
    expect(find.text('Order placed'), findsOneWidget);
    expect(find.text('Shipped'), findsOneWidget);
  });

  testWidgets('shows back button and its tap does not throw', (tester) async {
    final router = GoRouter(
      initialLocation: '/orders/3',
      routes: [
        GoRoute(
          path: '/orders',
          builder: (_, _) => const Scaffold(body: Text('Orders root')),
          routes: [
            GoRoute(
              path: ':id',
              builder: (_, _) =>
                  const OrderDetailPage(orderId: 3),
            ),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);

    final container = ProviderContainer(
      overrides: [
        orderDetailProvider(3).overrideWithValue(
          const AsyncData(confirmedOrder),
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pump();

    expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pump();

    expect(tester.takeException(), isNull);
  });
}
