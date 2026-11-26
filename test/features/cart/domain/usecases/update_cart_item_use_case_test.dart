import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_tutorial/core/errors/failure.dart';
import 'package:flutter_tutorial/features/cart/domain/entities/cart.dart';
import 'package:flutter_tutorial/features/cart/domain/repositories/cart_repository.dart';
import 'package:flutter_tutorial/features/cart/domain/usecases/update_cart_item_use_case.dart';

class MockCartRepository extends Mock implements CartRepository {}

void main() {
  late UpdateCartItemUseCase useCase;
  late MockCartRepository mockRepository;

  const testCartItem = CartItem(
    id: 1,
    productId: 10,
    productName: 'Test Product',
    unitPrice: 29.99,
    quantity: 3,
    subtotal: 89.97,
  );

  const testCart = Cart(
    id: 1,
    items: [testCartItem],
    totalAmount: 89.97,
  );

  setUp(() {
    mockRepository = MockCartRepository();
    useCase = UpdateCartItemUseCase(mockRepository);
  });

  test('_01_ShouldReturnCart_WhenQuantityIsPositive', () async {
    when(() => mockRepository.updateItem(1, 3))
        .thenAnswer((_) async => const Right(testCart));

    final result = await useCase(1, 3);

    expect(result.isRight(), isTrue);
    result.fold(
      (_) => fail('expected Right'),
      (cart) => expect(cart.id, equals(1)),
    );
    verify(() => mockRepository.updateItem(1, 3)).called(1);
  });

  test('_02_ShouldReturnValidationFailure_WhenQuantityIsZero', () async {
    final result = await useCase(1, 0);

    expect(result.isLeft(), isTrue);
    result.fold(
      (failure) => expect(failure, isA<ValidationFailure>()),
      (_) => fail('expected Left'),
    );
    verifyNever(() => mockRepository.updateItem(any(), any()));
  });
  test('_03_ShouldReturnValidationFailure_WhenQuantityIsNegative', () async {
    final result = await useCase(1, -1);

    expect(result.isLeft(), isTrue);
    result.fold(
      (failure) => expect(failure, isA<ValidationFailure>()),
      (_) => fail('expected Left'),
    );
    verifyNever(() => mockRepository.updateItem(any(), any()));
  });

}
