// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:flutter_tutorial/features/orders/domain/entities/order.dart';
import 'package:flutter_tutorial/features/orders/presentation/pages/order_detail_page.dart';
import 'package:flutter_tutorial/features/orders/presentation/pages/order_list_page.dart';
import 'package:flutter_tutorial/features/orders/presentation/providers/orders_notifier.dart';
import 'package:flutter_tutorial/features/orders/presentation/providers/orders_state.dart';
import 'package:flutter_tutorial/features/orders/presentation/widgets/order_card.dart';
import 'package:flutter_tutorial/features/orders/presentation/widgets/order_status_badge.dart';
import 'package:flutter_tutorial/features/orders/presentation/providers/order_detail_notifier.dart';

class SpyOrdersNotifier extends OrdersNotifier {
  SpyOrdersNotifier(this.initial);

  final OrdersState initial;
  int refreshCalls = 0;

  @override
  OrdersState build() => initial;

  @override
  Future<void> refresh() async {
    refreshCalls++;
  }
}

void main() {
  const firstItem = OrderItem(
    id: 1,
    productId: 10,
    productName: 'Wireless Headphones',
    unitPrice: 129.50,
    quantity: 2,
    subtotal: 259.00,
  );

  const pendingOrder = Order(
    id: 1,
    orderNumber: 'ORD-001',
    status: OrderStatus.pending,
    totalAmount: 259.00,
    items: [firstItem],
  );

  const confirmedOrder = Order(
    id: 2,
    orderNumber: 'ORD-002',
    status: OrderStatus.confirmed,
    totalAmount: 99.99,
    items: [],
  );

  late SpyOrdersNotifier spyNotifier;
  late ProviderContainer container;

  Widget buildUnderTest({GoRouter? router}) {
    container = ProviderContainer(
      overrides: [ordersProvider.overrideWith(() => spyNotifier)],
    );
    addTearDown(container.dispose);

    final scoped = UncontrolledProviderScope(
      container: container,
      child: router == null
          ? const MaterialApp(home: OrderListPage())
          : MaterialApp.router(routerConfig: router),
    );
    return scoped;
  }

  setUp(() {
    spyNotifier = SpyOrdersNotifier(const OrdersState(isLoading: true));
  });

  testWidgets('390x844: shows loading state', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(buildUnderTest());
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('My Orders'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(RefreshIndicator), findsOneWidget);
  });

  testWidgets('shows error state and retry invokes refresh', (tester) async {
    spyNotifier = SpyOrdersNotifier(
      const OrdersState(isLoading: false, errorMessage: 'Network error'),
    );

    await tester.pumpWidget(buildUnderTest());
    await tester.pump();

    expect(find.text('Network error'), findsOneWidget);
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pump();

    expect(spyNotifier.refreshCalls, 1);
  });

  testWidgets('shows empty state when no orders exist', (tester) async {
    spyNotifier = SpyOrdersNotifier(
      const OrdersState(isLoading: false, orders: []),
    );

    await tester.pumpWidget(buildUnderTest());
    await tester.pump();

    expect(find.text('0 orders'), findsOneWidget);
    expect(find.text('No orders yet'), findsOneWidget);
    expect(find.byIcon(Icons.receipt_long_outlined), findsOneWidget);
  });

  testWidgets('renders order cards, item counts and status badges', (
    tester,
  ) async {
    spyNotifier = SpyOrdersNotifier(
      const OrdersState(
        isLoading: false,
        orders: [pendingOrder, confirmedOrder],
      ),
    );

    await tester.pumpWidget(buildUnderTest());
    await tester.pump();

    expect(find.text('2 orders'), findsOneWidget);
    expect(find.byType(OrderCard), findsNWidgets(2));
    expect(find.text('#ORD-001'), findsOneWidget);
    expect(find.text('2 items'), findsOneWidget);
    expect(find.text('\$259.00'), findsOneWidget);
    expect(find.text('#ORD-002'), findsOneWidget);
    expect(find.text('0 items'), findsOneWidget);
    expect(find.text('\$99.99'), findsOneWidget);
    expect(find.byType(OrderStatusBadge), findsNWidgets(2));
  });

  testWidgets('RefreshIndicator invokes refresh', (tester) async {
    spyNotifier = SpyOrdersNotifier(
      const OrdersState(isLoading: false, orders: [pendingOrder]),
    );

    await tester.pumpWidget(buildUnderTest());
    await tester.pump();

    final indicator = tester.widget<RefreshIndicator>(
      find.byType(RefreshIndicator),
    );
    await indicator.onRefresh();

    expect(spyNotifier.refreshCalls, 1);
  });

  testWidgets('tapping an order card navigates to its detail page', (
    tester,
  ) async {
    spyNotifier = SpyOrdersNotifier(
      const OrdersState(isLoading: false, orders: [pendingOrder]),
    );

    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const OrderListPage(),
        ),
        GoRoute(
          path: '/orders/:id',
          builder: (_, state) {
            final id = int.parse(state.pathParameters['id']!);
            return OrderDetailPage(orderId: id);
          },
        ),
      ],
    );
    addTearDown(router.dispose);

    container = ProviderContainer(
      overrides: [
        ordersProvider.overrideWith(() => spyNotifier),
        orderDetailProvider(1).overrideWithValue(
          const AsyncData(pendingOrder),
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
    await tester.pumpAndSettle();

    await tester.tap(find.byType(OrderCard));
    await tester.pumpAndSettle();

    expect(find.text('Order #ORD-001'), findsOneWidget);
  });
}
