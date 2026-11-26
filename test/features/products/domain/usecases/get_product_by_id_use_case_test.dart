import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_tutorial/core/errors/failure.dart';
import 'package:flutter_tutorial/features/products/domain/entities/product.dart';
import 'package:flutter_tutorial/features/products/domain/repositories/product_repository.dart';
import 'package:flutter_tutorial/features/products/domain/usecases/get_product_by_id_use_case.dart';

class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  late GetProductByIdUseCase useCase;
  late MockProductRepository mockRepository;

  const testProduct = Product(
    id: 1,
    name: 'Test Product',
    unitPrice: 29.99,
    description: 'A test product',
    active: true,
    categoryId: 1,
    categoryName: 'Electronics',
  );

  setUp(() {
    mockRepository = MockProductRepository();
    useCase = GetProductByIdUseCase(mockRepository);
  });

  test('_01_ShouldReturnRight_WhenProductExists', () async {
    when(() => mockRepository.getProductById(1))
        .thenAnswer((_) async => const Right(testProduct));

    final result = await useCase(1);

    expect(result.isRight(), isTrue);
    result.fold(
      (_) => fail('expected Right'),
      (product) => expect(product.id, 1),
    );
  });

  test('_02_ShouldReturnLeft_WhenProductNotFound', () async {
    when(() => mockRepository.getProductById(1))
        .thenAnswer((_) async => const Left(NetworkFailure('Not found')));

    final result = await useCase(1);

    expect(result.isLeft(), isTrue);
    result.fold(
      (failure) => expect(failure, isA<NetworkFailure>()),
      (_) => fail('expected Left'),
    );
  });
}
