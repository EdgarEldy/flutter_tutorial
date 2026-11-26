import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart' hide Order;
import 'package:mocktail/mocktail.dart';

import 'package:flutter_tutorial/core/errors/failure.dart';
import 'package:flutter_tutorial/features/orders/data/providers/order_providers.dart';
import 'package:flutter_tutorial/features/orders/domain/entities/order.dart';
import 'package:flutter_tutorial/features/orders/domain/usecases/get_order_by_id_use_case.dart';
import 'package:flutter_tutorial/features/orders/presentation/providers/order_detail_notifier.dart';

class MockGetOrderByIdUseCase extends Mock implements GetOrderByIdUseCase {}

void main() {
  late MockGetOrderByIdUseCase mockGetOrderById;

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

  setUp(() {
    mockGetOrderById = MockGetOrderByIdUseCase();
  });

  ProviderContainer makeContainer() {
    final container = ProviderContainer(overrides: [
      getOrderByIdUseCaseProvider.overrideWithValue(mockGetOrderById),
    ]);
    addTearDown(container.dispose);
    return container;
  }

  test('_01_ShouldStartAsAsyncLoading_WhenNotifierIsFirstBuilt', () async {
    when(() => mockGetOrderById.call(1))
        .thenAnswer((_) async => const Right(testOrder));

    final container = makeContainer();
    final sub = container.listen(orderDetailProvider(1), (prev, next) {});
    addTearDown(sub.close);

    expect(sub.read(), isA<AsyncLoading<Order>>());
  });

  test('_02_ShouldBeAsyncData_WhenOrderLoadsSuccessfully', () async {
    when(() => mockGetOrderById.call(1))
        .thenAnswer((_) async => const Right(testOrder));

    final container = makeContainer();
    final sub = container.listen(orderDetailProvider(1), (prev, next) {});
    addTearDown(sub.close);

    await Future.delayed(Duration.zero);

    final state = container.read(orderDetailProvider(1));
    expect(state, isA<AsyncData<Order>>());
    expect(state.value?.id, equals(1));
    expect(state.value?.orderNumber, equals('ORD-001'));
    expect(state.value?.status, equals(OrderStatus.pending));
  });

  test('_03_ShouldBeAsyncError_WhenOrderLoadFails', () async {
    when(() => mockGetOrderById.call(1)).thenAnswer(
      (_) async => const Left(NetworkFailure('Order not found')),
    );

    final container = makeContainer();
    final sub = container.listen(orderDetailProvider(1), (prev, next) {});
    addTearDown(sub.close);

    await Future.delayed(Duration.zero);

    final state = container.read(orderDetailProvider(1));
    expect(state, isA<AsyncError<Order>>());
  });
}
