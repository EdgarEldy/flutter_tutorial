import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_tutorial/core/errors/failure.dart';
import 'package:flutter_tutorial/features/cart/domain/entities/cart.dart';
import 'package:flutter_tutorial/features/cart/domain/repositories/cart_repository.dart';
import 'package:flutter_tutorial/features/cart/domain/usecases/remove_cart_item_use_case.dart';

class MockCartRepository extends Mock implements CartRepository {}

void main() {
  late RemoveCartItemUseCase useCase;
  late MockCartRepository mockRepository;

  const testCart = Cart(
    id: 1,
    items: [],
    totalAmount: 0.0,
  );

  setUp(() {
    mockRepository = MockCartRepository();
    useCase = RemoveCartItemUseCase(mockRepository);
  });

  test('_01_ShouldReturnCart_WhenRepositorySucceeds', () async {
    when(() => mockRepository.removeItem(1))
        .thenAnswer((_) async => const Right(testCart));

    final result = await useCase(1);

    expect(result.isRight(), isTrue);
    result.fold(
      (_) => fail('expected Right'),
      (cart) => expect(cart.id, equals(1)),
    );
    verify(() => mockRepository.removeItem(1)).called(1);
  });

  test('_02_ShouldReturnLeft_WhenRepositoryFails', () async {
    when(() => mockRepository.removeItem(1))
        .thenAnswer((_) async => const Left(NetworkFailure('Network error')));

    final result = await useCase(1);

    expect(result.isLeft(), isTrue);
    result.fold(
      (failure) => expect(failure, isA<NetworkFailure>()),
      (_) => fail('expected Left'),
    );
  });
}
