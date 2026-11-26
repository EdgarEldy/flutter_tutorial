import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart' hide Order;
import 'package:mocktail/mocktail.dart';

import 'package:flutter_tutorial/core/errors/failure.dart';
import 'package:flutter_tutorial/features/orders/data/providers/order_providers.dart';
import 'package:flutter_tutorial/features/orders/domain/entities/order.dart';
import 'package:flutter_tutorial/features/orders/domain/usecases/get_orders_use_case.dart';
import 'package:flutter_tutorial/features/orders/domain/usecases/refresh_orders_use_case.dart';
import 'package:flutter_tutorial/features/orders/presentation/providers/orders_notifier.dart';

class MockGetOrdersUseCase extends Mock implements GetOrdersUseCase {}

class MockRefreshOrdersUseCase extends Mock implements RefreshOrdersUseCase {}

void main() {
  late MockGetOrdersUseCase mockGetOrdersUseCase;
  late MockRefreshOrdersUseCase mockRefreshOrdersUseCase;

  const testOrderItem = OrderItem(
    id: 1,
    productId: 10,
    productName: 'Test',
    unitPrice: 29.99,
    quantity: 2,
    subtotal: 59.98,
  );

  const testOrder = Order(
    id: 1,
    orderNumber: 'ORD-001',
    status: OrderStatus.pending,
    totalAmount: 59.98,
    items: [testOrderItem],
  );

  const updatedOrder = Order(
    id: 2,
    orderNumber: 'ORD-002',
    status: OrderStatus.confirmed,
    totalAmount: 99.99,
    items: [],
  );

  setUp(() {
    mockGetOrdersUseCase = MockGetOrdersUseCase();
    mockRefreshOrdersUseCase = MockRefreshOrdersUseCase();
  });

  ProviderContainer makeContainer() {
    final container = ProviderContainer(overrides: [
      getOrdersUseCaseProvider.overrideWithValue(mockGetOrdersUseCase),
      refreshOrdersUseCaseProvider
          .overrideWithValue(mockRefreshOrdersUseCase),
    ]);
    addTearDown(container.dispose);
    return container;
  }

  test('_01_ShouldStartWithIsLoadingTrue_WhenNotifierIsFirstBuilt', () async {
    final completer = Completer<Either<Failure, List<Order>>>();
    when(() => mockGetOrdersUseCase.call()).thenAnswer((_) => completer.future);

    final container = makeContainer();
    final sub = container.listen(ordersProvider, (_, _) {});
    addTearDown(sub.close);

    final state = container.read(ordersProvider);
    expect(state.isLoading, isTrue);
    expect(state.orders, isEmpty);

    completer.complete(const Right([testOrder]));
  });

  test('_02_ShouldSetOrders_WhenLoadSucceeds', () async {
    when(() => mockGetOrdersUseCase.call())
        .thenAnswer((_) async => const Right([testOrder]));

    final container = makeContainer();
    final sub = container.listen(ordersProvider, (_, _) {});
    addTearDown(sub.close);

    container.read(ordersProvider);
    await Future.delayed(Duration.zero);

    final state = container.read(ordersProvider);
    expect(state.isLoading, isFalse);
    expect(state.orders, hasLength(1));
    expect(state.orders.first.id, equals(1));
    expect(state.errorMessage, isNull);
  });

  test('_03_ShouldSetErrorMessage_WhenLoadFails', () async {
    when(() => mockGetOrdersUseCase.call())
        .thenAnswer((_) async => const Left(NetworkFailure('Network error')));

    final container = makeContainer();
    final sub = container.listen(ordersProvider, (_, _) {});
    addTearDown(sub.close);

    container.read(ordersProvider);
    await Future.delayed(Duration.zero);

    final state = container.read(ordersProvider);
    expect(state.isLoading, isFalse);
    expect(state.orders, isEmpty);
    expect(state.errorMessage, equals('Network error'));
  });

  test('_04_ShouldSetIsRefreshing_WhenRefreshCalled', () async {
    when(() => mockGetOrdersUseCase.call())
        .thenAnswer((_) async => const Right([testOrder]));

    final container = makeContainer();
    final sub = container.listen(ordersProvider, (_, _) {});
    addTearDown(sub.close);

    container.read(ordersProvider);
    await Future.delayed(Duration.zero);

    final completer = Completer<Either<Failure, List<Order>>>();
    when(() => mockRefreshOrdersUseCase.call())
        .thenAnswer((_) => completer.future);

    // ignore: discarded_futures
    container.read(ordersProvider.notifier).refresh();

    final state = container.read(ordersProvider);
    expect(state.isRefreshing, isTrue);

    completer.complete(const Right([testOrder]));
    await Future.delayed(Duration.zero);
  });

  test('_05_ShouldUpdateOrders_WhenRefreshSucceeds', () async {
    when(() => mockGetOrdersUseCase.call())
        .thenAnswer((_) async => const Right([testOrder]));

    final container = makeContainer();
    final sub = container.listen(ordersProvider, (_, _) {});
    addTearDown(sub.close);

    container.read(ordersProvider);
    await Future.delayed(Duration.zero);

    when(() => mockRefreshOrdersUseCase.call())
        .thenAnswer((_) async => const Right([updatedOrder]));

    await container.read(ordersProvider.notifier).refresh();

    final state = container.read(ordersProvider);
    expect(state.isRefreshing, isFalse);
    expect(state.orders, hasLength(1));
    expect(state.orders.first.id, equals(2));
    expect(state.orders.first.orderNumber, equals('ORD-002'));
    expect(state.errorMessage, isNull);
  });

  test('_06_ShouldSetErrorMessage_WhenRefreshFails', () async {
    when(() => mockGetOrdersUseCase.call())
        .thenAnswer((_) async => const Right([testOrder]));

    final container = makeContainer();
    final sub = container.listen(ordersProvider, (_, _) {});
    addTearDown(sub.close);

    container.read(ordersProvider);
    await Future.delayed(Duration.zero);

    when(() => mockRefreshOrdersUseCase.call()).thenAnswer(
      (_) async => const Left(NetworkFailure('Network error')),
    );

    await container.read(ordersProvider.notifier).refresh();

    final state = container.read(ordersProvider);
    expect(state.isRefreshing, isFalse);
    expect(state.errorMessage, equals('Network error'));
  });
}
