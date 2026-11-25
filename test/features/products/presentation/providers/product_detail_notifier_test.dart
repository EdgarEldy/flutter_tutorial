import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_tutorial/core/errors/failure.dart';
import 'package:flutter_tutorial/features/products/data/providers/product_providers.dart';
import 'package:flutter_tutorial/features/products/domain/entities/product.dart';
import 'package:flutter_tutorial/features/products/domain/usecases/get_product_by_id_use_case.dart';
import 'package:flutter_tutorial/features/products/presentation/providers/product_detail_notifier.dart';

class MockGetProductByIdUseCase extends Mock
    implements GetProductByIdUseCase {}

void main() {
  late MockGetProductByIdUseCase mockGetProductById;

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
    mockGetProductById = MockGetProductByIdUseCase();
  });

  ProviderContainer makeContainer() {
    final container = ProviderContainer(
      overrides: [
        getProductByIdUseCaseProvider.overrideWithValue(mockGetProductById),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('_01_ShouldStartAsAsyncLoading_WhenNotifierIsFirstBuilt', () async {
    when(() => mockGetProductById.call(1))
        .thenAnswer((_) async => const Right(testProduct));

    final container = makeContainer();
    // listen() keeps the autoDispose provider alive throughout the test.
    final sub = container.listen(productDetailProvider(1), (prev, next) {});
    addTearDown(sub.close);

    expect(sub.read(), isA<AsyncLoading<Product>>());
  });

  test('_02_ShouldBeAsyncData_WhenProductLoadsSuccessfully', () async {
    when(() => mockGetProductById.call(1))
        .thenAnswer((_) async => const Right(testProduct));

    final container = makeContainer();
    final sub = container.listen(productDetailProvider(1), (prev, next) {});
    addTearDown(sub.close);

    await Future.delayed(Duration.zero);

    final state = container.read(productDetailProvider(1));
    expect(state, isA<AsyncData<Product>>());
    expect(state.value?.id, 1);
    expect(state.value?.name, 'Test Product');
  });

  test('_03_ShouldBeAsyncError_WhenProductLoadFails', () async {
    when(() => mockGetProductById.call(1)).thenAnswer(
      (_) async => const Left(NetworkFailure('Product not found')),
    );

    final container = makeContainer();
    final sub = container.listen(productDetailProvider(1), (prev, next) {});
    addTearDown(sub.close);

    await Future.delayed(Duration.zero);

    final state = container.read(productDetailProvider(1));
    expect(state, isA<AsyncError<Product>>());
  });
}
