import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_tutorial/core/errors/failure.dart';
import 'package:flutter_tutorial/features/products/domain/repositories/product_repository.dart';
import 'package:flutter_tutorial/features/products/domain/usecases/refresh_products_use_case.dart';

class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  late RefreshProductsUseCase useCase;
  late MockProductRepository mockRepository;

  setUp(() {
    mockRepository = MockProductRepository();
    useCase = RefreshProductsUseCase(mockRepository);
  });

  test('_01_ShouldReturnRight_WhenRefreshSucceeds', () async {
    when(() => mockRepository.refreshProducts())
        .thenAnswer((_) async => const Right(unit));

    final result = await useCase();

    expect(result.isRight(), isTrue);
  });

  test('_02_ShouldReturnLeft_WhenRefreshFails', () async {
    when(() => mockRepository.refreshProducts()).thenAnswer(
      (_) async => const Left(NetworkFailure('Network error')),
    );

    final result = await useCase();

    expect(result.isLeft(), isTrue);
    result.fold(
      (failure) => expect(failure, isA<NetworkFailure>()),
      (_) => fail('expected Left'),
    );
  });
}
