// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:flutter_tutorial/features/cart/domain/entities/order_summary.dart';
import 'package:flutter_tutorial/features/cart/presentation/pages/checkout_confirmation_page.dart';
import 'package:flutter_tutorial/features/cart/presentation/providers/cart_notifier.dart';
import 'package:flutter_tutorial/features/cart/presentation/providers/cart_state.dart';

class SpyCartNotifier extends CartNotifier {
  SpyCartNotifier(this._initial);

  final CartState _initial;

  @override
  CartState build() => _initial;
}

void main() {
  const order = OrderSummary(
    id: 42,
    status: 'PENDING',
    totalAmount: 59.98,
  );

  Widget buildUnderTest(CartState state) {
    final spyNotifier = SpyCartNotifier(state);
    final container = ProviderContainer(
      overrides: [cartProvider.overrideWith(() => spyNotifier)],
    );
    addTearDown(container.dispose);

    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const CheckoutConfirmationPage(),
        ),
        GoRoute(
          path: '/orders',
          builder: (_, _) => const Scaffold(body: Text('Orders route')),
        ),
        GoRoute(
          path: '/products',
          builder: (_, _) => const Scaffold(body: Text('Products route')),
        ),
      ],
    );
    addTearDown(router.dispose);

    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(routerConfig: router),
    );
  }

  testWidgets(
    '_01_ShouldShowNoOrderFound_WhenLastOrderIsNull',
    (tester) async {
      await tester.pumpWidget(buildUnderTest(const CartState()));
      await tester.pump();

      expect(find.text('No order found.'), findsOneWidget);
      expect(find.text('Go to products'), findsOneWidget);
    },
  );

  testWidgets(
    '_02_ShouldShowOrderConfirmedAndDetails_WhenCheckoutSucceeds',
    (tester) async {
      await tester.pumpWidget(
        buildUnderTest(const CartState(lastOrder: order)),
      );
      await tester.pump();

      expect(find.text('Order Confirmed!'), findsOneWidget);
      expect(find.text('Your order has been placed successfully'), findsOneWidget);
      expect(find.text('Order #'), findsOneWidget);
      expect(find.text('42'), findsOneWidget);
      expect(find.text('Status'), findsOneWidget);
      expect(find.text('PENDING'), findsOneWidget);
      expect(find.text('Total'), findsOneWidget);
      expect(find.text('\$59.98'), findsOneWidget);
    },
  );

  testWidgets(
    '_03_ShouldNavigateToOrders_WhenViewOrdersIsTapped',
    (tester) async {
      await tester.pumpWidget(
        buildUnderTest(const CartState(lastOrder: order)),
      );
      await tester.pump();

      await tester.tap(find.text('View orders'));
      await tester.pumpAndSettle();

      expect(find.text('Orders route'), findsOneWidget);
    },
  );

  testWidgets(
    '_04_ShouldNavigateToProducts_WhenContinueShoppingIsTapped',
    (tester) async {
      await tester.pumpWidget(
        buildUnderTest(const CartState(lastOrder: order)),
      );
      await tester.pump();

      await tester.tap(find.text('Continue shopping'));
      await tester.pumpAndSettle();

      expect(find.text('Products route'), findsOneWidget);
    },
  );
}
