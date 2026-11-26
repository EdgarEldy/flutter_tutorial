import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_tutorial/core/errors/failure.dart';
import 'package:flutter_tutorial/features/cart/domain/repositories/cart_repository.dart';
import 'package:flutter_tutorial/features/cart/domain/usecases/clear_cart_use_case.dart';

class MockCartRepository extends Mock implements CartRepository {}

void main() {
  late ClearCartUseCase useCase;
  late MockCartRepository mockRepository;

  setUp(() {
    mockRepository = MockCartRepository();
    useCase = ClearCartUseCase(mockRepository);
  });

  test('_01_ShouldReturnUnit_WhenRepositorySucceeds', () async {
    when(() => mockRepository.clearCart())
        .thenAnswer((_) async => const Right(unit));

    final result = await useCase();

    expect(result.isRight(), isTrue);
    result.fold(
      (_) => fail('expected Right'),
      (value) => expect(value, equals(unit)),
    );
    verify(() => mockRepository.clearCart()).called(1);
  });

  test('_02_ShouldReturnLeft_WhenRepositoryFails', () async {
    when(() => mockRepository.clearCart())
        .thenAnswer((_) async => const Left(NetworkFailure('Network error')));

    final result = await useCase();

    expect(result.isLeft(), isTrue);
    result.fold(
      (failure) => expect(failure, isA<NetworkFailure>()),
      (_) => fail('expected Left'),
    );
  });
}
