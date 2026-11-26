import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart' hide Order;
import 'package:mocktail/mocktail.dart';

import 'package:flutter_tutorial/core/errors/failure.dart';
import 'package:flutter_tutorial/features/orders/domain/entities/order.dart';
import 'package:flutter_tutorial/features/orders/domain/repositories/order_repository.dart';
import 'package:flutter_tutorial/features/orders/domain/usecases/refresh_orders_use_case.dart';

class MockOrderRepository extends Mock implements OrderRepository {}

void main() {
  late RefreshOrdersUseCase useCase;
  late MockOrderRepository mockRepository;

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
    mockRepository = MockOrderRepository();
    useCase = RefreshOrdersUseCase(mockRepository);
  });

  test('_01_ShouldReturnOrders_WhenRefreshSucceeds', () async {
    when(() => mockRepository.refreshOrders())
        .thenAnswer((_) async => const Right([testOrder]));

    final result = await useCase();

    expect(result.isRight(), isTrue);
    result.fold(
      (_) => fail('expected Right'),
      (orders) {
        expect(orders, hasLength(1));
        expect(orders.first.id, equals(1));
        expect(orders.first.orderNumber, equals('ORD-001'));
      },
    );
    verify(() => mockRepository.refreshOrders()).called(1);
  });

  test('_02_ShouldReturnLeft_WhenRefreshFails', () async {
    when(() => mockRepository.refreshOrders())
        .thenAnswer((_) async => const Left(NetworkFailure('Network error')));

    final result = await useCase();

    expect(result.isLeft(), isTrue);
    result.fold(
      (failure) => expect(failure, isA<NetworkFailure>()),
      (_) => fail('expected Left'),
    );
    verify(() => mockRepository.refreshOrders()).called(1);
  });
}
