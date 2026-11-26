import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_tutorial/core/errors/failure.dart';
import 'package:flutter_tutorial/features/cart/domain/entities/cart.dart';
import 'package:flutter_tutorial/features/cart/domain/repositories/cart_repository.dart';
import 'package:flutter_tutorial/features/cart/domain/usecases/get_cart_use_case.dart';

class MockCartRepository extends Mock implements CartRepository {}

void main() {
  late GetCartUseCase useCase;
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
    useCase = GetCartUseCase(mockRepository);
  });

  test('_01_ShouldReturnCart_WhenRepositorySucceeds', () async {
    when(() => mockRepository.getCart())
        .thenAnswer((_) async => const Right(testCart));

    final result = await useCase();

    expect(result.isRight(), isTrue);
    result.fold(
      (_) => fail('expected Right'),
      (cart) {
        expect(cart.id, equals(1));
        expect(cart.items, hasLength(1));
        expect(cart.totalAmount, equals(59.98));
      },
    );
    verify(() => mockRepository.getCart()).called(1);
  });

  test('_02_ShouldReturnLeft_WhenRepositoryFails', () async {
    when(() => mockRepository.getCart())
        .thenAnswer((_) async => const Left(NetworkFailure('Network error')));

    final result = await useCase();

    expect(result.isLeft(), isTrue);
    result.fold(
      (failure) => expect(failure, isA<NetworkFailure>()),
      (_) => fail('expected Left'),
    );
  });
}
