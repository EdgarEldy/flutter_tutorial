import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_tutorial/core/errors/failure.dart';
import 'package:flutter_tutorial/features/cart/data/providers/cart_providers.dart';
import 'package:flutter_tutorial/features/cart/domain/entities/cart.dart';
import 'package:flutter_tutorial/features/cart/domain/entities/order_summary.dart';
import 'package:flutter_tutorial/features/cart/domain/usecases/add_cart_item_use_case.dart';
import 'package:flutter_tutorial/features/cart/domain/usecases/checkout_use_case.dart';
import 'package:flutter_tutorial/features/cart/domain/usecases/get_cart_use_case.dart';
import 'package:flutter_tutorial/features/cart/domain/usecases/remove_cart_item_use_case.dart';
import 'package:flutter_tutorial/features/cart/domain/usecases/update_cart_item_use_case.dart';
import 'package:flutter_tutorial/features/cart/presentation/providers/cart_notifier.dart';

class MockGetCartUseCase extends Mock implements GetCartUseCase {}

class MockAddCartItemUseCase extends Mock implements AddCartItemUseCase {}

class MockUpdateCartItemUseCase extends Mock implements UpdateCartItemUseCase {}

class MockRemoveCartItemUseCase extends Mock implements RemoveCartItemUseCase {}

class MockCheckoutUseCase extends Mock implements CheckoutUseCase {}

void main() {
  late MockGetCartUseCase mockGetCart;
  late MockAddCartItemUseCase mockAddItem;
  late MockUpdateCartItemUseCase mockUpdateItem;
  late MockRemoveCartItemUseCase mockRemoveItem;
  late MockCheckoutUseCase mockCheckout;

  const testCartItem = CartItem(
    id: 1,
    productId: 10,
    productName: 'Test Product',
    unitPrice: 29.99,
    quantity: 2,
    subtotal: 59.98,
  );

  const testCart = Cart(
    id: 1,
    items: [testCartItem],
    totalAmount: 59.98,
  );

  const testOrder = OrderSummary(
    id: 42,
    status: 'PENDING',
    totalAmount: 59.98,
  );

  setUp(() {
    mockGetCart = MockGetCartUseCase();
    mockAddItem = MockAddCartItemUseCase();
    mockUpdateItem = MockUpdateCartItemUseCase();
    mockRemoveItem = MockRemoveCartItemUseCase();
    mockCheckout = MockCheckoutUseCase();
  });

  ProviderContainer makeContainer() {
    final container = ProviderContainer(overrides: [
      getCartUseCaseProvider.overrideWithValue(mockGetCart),
      addCartItemUseCaseProvider.overrideWithValue(mockAddItem),
      updateCartItemUseCaseProvider.overrideWithValue(mockUpdateItem),
      removeCartItemUseCaseProvider.overrideWithValue(mockRemoveItem),
      checkoutUseCaseProvider.overrideWithValue(mockCheckout),
    ]);
    addTearDown(container.dispose);
    return container;
  }

  test('_01_ShouldStartWithIsLoadingTrue_WhenNotifierIsFirstBuilt', () async {
    final completer = Completer<Either<Failure, Cart>>();
    when(() => mockGetCart.call()).thenAnswer((_) => completer.future);

    final container = makeContainer();
    final sub = container.listen(cartProvider, (_, _) {});
    addTearDown(sub.close);

    final state = container.read(cartProvider);

    expect(state.isLoading, isTrue);
    expect(state.cart, isNull);

    completer.complete(const Right(testCart));
  });

  test('_02_ShouldSetCart_WhenLoadCartSucceeds', () async {
    when(() => mockGetCart.call())
        .thenAnswer((_) async => const Right(testCart));

    final container = makeContainer();
    final sub = container.listen(cartProvider, (_, _) {});
    addTearDown(sub.close);

    container.read(cartProvider);
    await pumpEventQueue();

    final state = container.read(cartProvider);
    expect(state.isLoading, isFalse);
    expect(state.cart, isNotNull);
    expect(state.cart!.id, equals(1));
    expect(state.errorMessage, isNull);
  });

  test('_03_ShouldSetErrorMessage_WhenLoadCartFails', () async {
    when(() => mockGetCart.call())
        .thenAnswer((_) async => const Left(NetworkFailure('Network error')));

    final container = makeContainer();
    final sub = container.listen(cartProvider, (_, _) {});
    addTearDown(sub.close);

    container.read(cartProvider);
    await pumpEventQueue();

    final state = container.read(cartProvider);
    expect(state.isLoading, isFalse);
    expect(state.cart, isNull);
    expect(state.errorMessage, isNotNull);
    expect(state.errorMessage, equals('Network error'));
  });

  test('_04_ShouldUpdateCart_WhenAddItemSucceeds', () async {
    when(() => mockGetCart.call())
        .thenAnswer((_) async => const Right(testCart));
    when(() => mockAddItem.call(10, 2))
        .thenAnswer((_) async => const Right(testCart));

    final container = makeContainer();
    final sub = container.listen(cartProvider, (_, _) {});
    addTearDown(sub.close);

    container.read(cartProvider);
    await pumpEventQueue();

    await container.read(cartProvider.notifier).addItem(10, 2);

    final state = container.read(cartProvider);
    expect(state.cart, isNotNull);
    expect(state.errorMessage, isNull);
    verify(() => mockAddItem.call(10, 2)).called(1);
  });

  test('_05_ShouldSetErrorMessage_WhenAddItemFails', () async {
    when(() => mockGetCart.call())
        .thenAnswer((_) async => const Right(testCart));
    when(() => mockAddItem.call(10, 2)).thenAnswer(
      (_) async => const Left(ValidationFailure('Quantity must be greater than 0')),
    );

    final container = makeContainer();
    final sub = container.listen(cartProvider, (_, _) {});
    addTearDown(sub.close);

    container.read(cartProvider);
    await pumpEventQueue();

    await container.read(cartProvider.notifier).addItem(10, 2);

    final state = container.read(cartProvider);
    expect(state.errorMessage, isNotNull);
  });

  test('_06_ShouldUpdateCart_WhenUpdateItemSucceeds', () async {
    when(() => mockGetCart.call())
        .thenAnswer((_) async => const Right(testCart));
    when(() => mockUpdateItem.call(1, 3))
        .thenAnswer((_) async => const Right(testCart));

    final container = makeContainer();
    final sub = container.listen(cartProvider, (_, _) {});
    addTearDown(sub.close);

    container.read(cartProvider);
    await pumpEventQueue();

    await container.read(cartProvider.notifier).updateItem(1, 3);

    final state = container.read(cartProvider);
    expect(state.cart, isNotNull);
    expect(state.errorMessage, isNull);
    verify(() => mockUpdateItem.call(1, 3)).called(1);
  });

  test('_07_ShouldUpdateCart_WhenRemoveItemSucceeds', () async {
    when(() => mockGetCart.call())
        .thenAnswer((_) async => const Right(testCart));
    when(() => mockRemoveItem.call(1))
        .thenAnswer((_) async => const Right(testCart));

    final container = makeContainer();
    final sub = container.listen(cartProvider, (_, _) {});
    addTearDown(sub.close);

    container.read(cartProvider);
    await pumpEventQueue();

    await container.read(cartProvider.notifier).removeItem(1);

    final state = container.read(cartProvider);
    expect(state.cart, isNotNull);
    expect(state.errorMessage, isNull);
    verify(() => mockRemoveItem.call(1)).called(1);
  });

  test('_08_ShouldSetLastOrderAndClearCart_WhenCheckoutSucceeds', () async {
    when(() => mockGetCart.call())
        .thenAnswer((_) async => const Right(testCart));
    when(() => mockCheckout.call())
        .thenAnswer((_) async => const Right(testOrder));

    final container = makeContainer();
    final sub = container.listen(cartProvider, (_, _) {});
    addTearDown(sub.close);

    container.read(cartProvider);
    await pumpEventQueue();

    await container.read(cartProvider.notifier).checkout();

    final state = container.read(cartProvider);
    expect(state.isCheckingOut, isFalse);
    expect(state.cart, isNull);
    expect(state.lastOrder, isNotNull);
    expect(state.lastOrder!.id, equals(42));
    expect(state.errorMessage, isNull);
  });

  test('_09_ShouldSetErrorMessage_WhenCheckoutFails', () async {
    when(() => mockGetCart.call())
        .thenAnswer((_) async => const Right(testCart));
    when(() => mockCheckout.call())
        .thenAnswer((_) async => const Left(NetworkFailure('Checkout failed')));

    final container = makeContainer();
    final sub = container.listen(cartProvider, (_, _) {});
    addTearDown(sub.close);

    container.read(cartProvider);
    await pumpEventQueue();

    await container.read(cartProvider.notifier).checkout();

    final state = container.read(cartProvider);
    expect(state.isCheckingOut, isFalse);
    expect(state.errorMessage, equals('Checkout failed'));
    expect(state.lastOrder, isNull);
  });

  test('_10_ShouldSetLoadingAndReloadCart_WhenRefreshSucceeds', () async {
    when(() => mockGetCart.call())
        .thenAnswer((_) async => const Right(testCart));

    final container = makeContainer();
    final sub = container.listen(cartProvider, (_, _) {});
    addTearDown(sub.close);

    container.read(cartProvider);
    await pumpEventQueue();

    await container.read(cartProvider.notifier).refresh();
    await pumpEventQueue();

    final state = container.read(cartProvider);
    expect(state.isLoading, isFalse);
    expect(state.cart, isNotNull);
    expect(state.errorMessage, isNull);
  });

  test('_11_ShouldSetErrorMessage_WhenUpdateItemFails', () async {
    when(() => mockGetCart.call())
        .thenAnswer((_) async => const Right(testCart));
    when(() => mockUpdateItem.call(1, 0)).thenAnswer(
      (_) async => const Left(ValidationFailure('Quantity must be at least 1')),
    );

    final container = makeContainer();
    final sub = container.listen(cartProvider, (_, _) {});
    addTearDown(sub.close);

    container.read(cartProvider);
    await pumpEventQueue();

    await container.read(cartProvider.notifier).updateItem(1, 0);

    final state = container.read(cartProvider);
    expect(state.errorMessage, equals('Quantity must be at least 1'));
  });

  test('_12_ShouldSetErrorMessage_WhenRemoveItemFails', () async {
    when(() => mockGetCart.call())
        .thenAnswer((_) async => const Right(testCart));
    when(() => mockRemoveItem.call(1)).thenAnswer(
      (_) async => const Left(NetworkFailure('Remove failed')),
    );

    final container = makeContainer();
    final sub = container.listen(cartProvider, (_, _) {});
    addTearDown(sub.close);

    container.read(cartProvider);
    await pumpEventQueue();

    await container.read(cartProvider.notifier).removeItem(1);

    final state = container.read(cartProvider);
    expect(state.errorMessage, equals('Remove failed'));
  });

  test('_13_ShouldNotCallCheckoutAgain_WhenAlreadyCheckingOut', () async {
    when(() => mockGetCart.call())
        .thenAnswer((_) async => const Right(testCart));

    final completer = Completer<Either<Failure, OrderSummary>>();
    when(() => mockCheckout.call()).thenAnswer((_) => completer.future);

    final container = makeContainer();
    final sub = container.listen(cartProvider, (_, _) {});
    addTearDown(sub.close);

    container.read(cartProvider);
    await pumpEventQueue();

    final notifier = container.read(cartProvider.notifier);
    // ignore: discarded_futures
    notifier.checkout();
    // ignore: discarded_futures
    notifier.checkout();

    verify(() => mockCheckout.call()).called(1);
    completer.complete(const Right(testOrder));
  });
}
