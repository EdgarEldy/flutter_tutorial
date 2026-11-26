import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_tutorial/core/errors/failure.dart';
import 'package:flutter_tutorial/features/cart/domain/entities/order_summary.dart';
import 'package:flutter_tutorial/features/cart/domain/usecases/checkout_use_case.dart';

class MockCheckoutDatasource extends Mock implements CheckoutDatasource {}

void main() {
  late CheckoutUseCase useCase;
  late MockCheckoutDatasource mockDatasource;

  const testOrder = OrderSummary(
    id: 42,
    status: 'PENDING',
    totalAmount: 59.98,
  );

  setUp(() {
    mockDatasource = MockCheckoutDatasource();
    useCase = CheckoutUseCase(mockDatasource);
  });

  test('_01_ShouldReturnOrderSummary_WhenCheckoutSucceeds', () async {
    when(() => mockDatasource.checkout()).thenAnswer((_) async => testOrder);

    final result = await useCase();

    expect(result.isRight(), isTrue);
    result.fold(
      (_) => fail('expected Right'),
      (order) {
        expect(order.id, equals(42));
        expect(order.status, equals('PENDING'));
        expect(order.totalAmount, equals(59.98));
      },
    );
    verify(() => mockDatasource.checkout()).called(1);
  });

  test('_02_ShouldReturnNetworkFailure_WhenDatasourceThrows', () async {
    when(() => mockDatasource.checkout())
        .thenThrow(Exception('Connection timeout'));

    final result = await useCase();

    expect(result.isLeft(), isTrue);
    result.fold(
      (failure) => expect(failure, isA<NetworkFailure>()),
      (_) => fail('expected Left'),
    );
  });
}
