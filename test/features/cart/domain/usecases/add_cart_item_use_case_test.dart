import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_tutorial/core/errors/failure.dart';
import 'package:flutter_tutorial/features/cart/domain/entities/cart.dart';
import 'package:flutter_tutorial/features/cart/domain/repositories/cart_repository.dart';
import 'package:flutter_tutorial/features/cart/domain/usecases/add_cart_item_use_case.dart';

class MockCartRepository extends Mock implements CartRepository {}

void main() {
  late AddCartItemUseCase useCase;
  late MockCartRepository mockRepository;

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

  setUp(() {
    mockRepository = MockCartRepository();
    useCase = AddCartItemUseCase(mockRepository);
  });

  test('_01_ShouldReturnCart_WhenQuantityIsPositive', () async {
    when(() => mockRepository.addItem(10, 2))
        .thenAnswer((_) async => const Right(testCart));

    final result = await useCase(10, 2);

    expect(result.isRight(), isTrue);
    result.fold(
      (_) => fail('expected Right'),
      (cart) => expect(cart.id, equals(1)),
    );
    verify(() => mockRepository.addItem(10, 2)).called(1);
  });

  test('_02_ShouldReturnValidationFailure_WhenQuantityIsZero', () async {
    final result = await useCase(10, 0);

    expect(result.isLeft(), isTrue);
    result.fold(
      (failure) => expect(failure, isA<ValidationFailure>()),
      (_) => fail('expected Left'),
    );
    verifyNever(() => mockRepository.addItem(any(), any()));
  });

  test('_03_ShouldReturnValidationFailure_WhenQuantityIsNegative', () async {
    final result = await useCase(10, -1);

    expect(result.isLeft(), isTrue);
    result.fold(
      (failure) => expect(failure, isA<ValidationFailure>()),
      (_) => fail('expected Left'),
    );
    verifyNever(() => mockRepository.addItem(any(), any()));
  });
}
