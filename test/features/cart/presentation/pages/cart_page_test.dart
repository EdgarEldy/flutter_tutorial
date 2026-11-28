// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:flutter_tutorial/features/cart/domain/entities/cart.dart';
import 'package:flutter_tutorial/features/cart/presentation/pages/cart_page.dart';
import 'package:flutter_tutorial/features/cart/presentation/providers/cart_notifier.dart';
import 'package:flutter_tutorial/features/cart/presentation/providers/cart_state.dart';

class SpyCartNotifier extends CartNotifier {
  SpyCartNotifier(this._initial);

  final CartState _initial;
  int refreshCalls = 0;
  int updateItemCalls = 0;
  int? updatedItemId;
  int? updatedQuantity;
  int removeItemCalls = 0;
  int? removedItemId;
  int checkoutCalls = 0;

  @override
  CartState build() => _initial;

  @override
  Future<void> refresh() async {
    refreshCalls++;
  }

  @override
  Future<void> updateItem(int itemId, int quantity) async {
    updateItemCalls++;
    updatedItemId = itemId;
    updatedQuantity = quantity;
  }

  @override
  Future<void> removeItem(int itemId) async {
    removeItemCalls++;
    removedItemId = itemId;
  }

  @override
  Future<void> checkout() async {
    checkoutCalls++;
  }
}

const testItem = CartItem(
  id: 1,
  productId: 10,
  productName: 'Test Product',
  unitPrice: 29.99,
  quantity: 2,
  subtotal: 59.98,
);

const testCart = Cart(id: 1, items: [testItem], totalAmount: 59.98);

void main() {
  late SpyCartNotifier spyNotifier;
  late ProviderContainer container;

  setUp(() {
    spyNotifier = SpyCartNotifier(const CartState(isLoading: true));
  });

  Widget buildUnderTest({bool withRouter = false}) {
    container = ProviderContainer(
      overrides: [cartProvider.overrideWith(() => spyNotifier)],
    );
    addTearDown(container.dispose);

    final scoped = UncontrolledProviderScope(
      container: container,
      child: withRouter ? RouterApp() : const MaterialApp(home: CartPage()),
    );
    return scoped;
  }

  testWidgets('_01_ShouldShowLoadingIndicator_WhenCartIsLoading', (
    tester,
  ) async {
    await tester.pumpWidget(buildUnderTest());
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('_02_ShouldShowErrorAndRetry_WhenCartLoadFails', (tester) async {
    spyNotifier = SpyCartNotifier(
      const CartState(errorMessage: 'Network error'),
    );

    await tester.pumpWidget(buildUnderTest());
    await tester.pump();

    expect(find.text('Network error'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pump();

    expect(spyNotifier.refreshCalls, 1);
  });

  testWidgets('_03_ShouldShowEmptyState_WhenCartHasNoItems', (tester) async {
    spyNotifier = SpyCartNotifier(
      const CartState(cart: Cart(id: 1, items: [], totalAmount: 0)),
    );

    await tester.pumpWidget(buildUnderTest(withRouter: true));
    await tester.pump();

    expect(find.text('Your cart is empty'), findsOneWidget);
    expect(find.text('Add some products to get started'), findsOneWidget);
    expect(find.text('Browse products'), findsOneWidget);
  });

  testWidgets('_04_ShouldIncreaseQuantity_WhenIncrementIsTapped', (
    tester,
  ) async {
    spyNotifier = SpyCartNotifier(const CartState(cart: testCart));

    await tester.pumpWidget(buildUnderTest());
    await tester.pump();

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(spyNotifier.updateItemCalls, 1);
    expect(spyNotifier.updatedItemId, 1);
    expect(spyNotifier.updatedQuantity, 3);
  });

  testWidgets('_05_ShouldDecreaseQuantity_WhenDecrementIsTapped', (
    tester,
  ) async {
    spyNotifier = SpyCartNotifier(const CartState(cart: testCart));

    await tester.pumpWidget(buildUnderTest());
    await tester.pump();

    await tester.tap(find.byIcon(Icons.remove));
    await tester.pump();

    expect(spyNotifier.updateItemCalls, 1);
    expect(spyNotifier.updatedItemId, 1);
    expect(spyNotifier.updatedQuantity, 1);
  });

  testWidgets('_06_ShouldRemoveItem_WhenQuantityIsOneAndDecrementIsTapped', (
    tester,
  ) async {
    spyNotifier = SpyCartNotifier(
      const CartState(
        cart: Cart(
          id: 1,
          items: [
            CartItem(
              id: 2,
              productId: 10,
              productName: 'Test Product',
              unitPrice: 29.99,
              quantity: 1,
              subtotal: 29.99,
            ),
          ],
          totalAmount: 29.99,
        ),
      ),
    );

    await tester.pumpWidget(buildUnderTest());
    await tester.pump();

    await tester.tap(find.byIcon(Icons.remove));
    await tester.pump();

    expect(spyNotifier.removeItemCalls, 1);
    expect(spyNotifier.removedItemId, 2);
    expect(spyNotifier.updateItemCalls, 0);
  });

  testWidgets('_07_ShouldCallRemove_WhenDeleteButtonIsTapped', (tester) async {
    spyNotifier = SpyCartNotifier(const CartState(cart: testCart));

    await tester.pumpWidget(buildUnderTest());
    await tester.pump();

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pump();

    expect(spyNotifier.removeItemCalls, 1);
    expect(spyNotifier.removedItemId, 1);
  });

  testWidgets('_08_ShouldShowServerTotalInStickySummary_WhenCartLoads', (
    tester,
  ) async {
    spyNotifier = SpyCartNotifier(const CartState(cart: testCart));

    await tester.pumpWidget(buildUnderTest());
    await tester.pump();

    expect(find.byType(CartSummaryBar), findsOneWidget);
    expect(find.text('Total'), findsOneWidget);
    expect(find.text('\$59.98'), findsOneWidget);
    expect(find.text('Checkout'), findsOneWidget);
  });

  testWidgets('_09_ShouldCallCheckout_WhenCheckoutButtonIsTapped', (
    tester,
  ) async {
    spyNotifier = SpyCartNotifier(const CartState(cart: testCart));

    await tester.pumpWidget(buildUnderTest());
    await tester.pump();

    await tester.tap(find.text('Checkout'));
    await tester.pump();

    expect(spyNotifier.checkoutCalls, 1);
  });

  testWidgets('_10_ShouldDisableCheckoutAndShowProgress_WhenCheckingOut', (
    tester,
  ) async {
    spyNotifier = SpyCartNotifier(
      const CartState(cart: testCart, isCheckingOut: true),
    );

    await tester.pumpWidget(buildUnderTest());
    await tester.pump();

    final filledButton = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(filledButton.onPressed, isNull);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets(
    '_11_ShouldFit390ViewportAndExpose48dpControlsAndRefresh_WhenCartLoads',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      spyNotifier = SpyCartNotifier(const CartState(cart: testCart));

      await tester.pumpWidget(buildUnderTest());
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.byType(RefreshIndicator), findsOneWidget);
      expect(find.byType(QuantityControl), findsOneWidget);

      final iconButtons = tester.widgetList<IconButton>(
        find.byType(IconButton),
      );
      for (final button in iconButtons) {
        if (button.constraints != null) {
          expect(button.constraints!.maxWidth, greaterThanOrEqualTo(48));
          expect(button.constraints!.maxHeight, greaterThanOrEqualTo(48));
        }
      }
    },
  );
}

class RouterApp extends StatelessWidget {
  RouterApp({super.key});

  final GoRouter _router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (_, _) => const CartPage()),
      GoRoute(
        path: '/products',
        builder: (_, _) => const Scaffold(body: Text('Products')),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(routerConfig: _router);
  }
}
