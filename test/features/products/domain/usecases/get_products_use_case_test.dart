import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_tutorial/core/errors/failure.dart';
import 'package:flutter_tutorial/core/pagination/paginated_result.dart';
import 'package:flutter_tutorial/features/products/domain/entities/product.dart';
import 'package:flutter_tutorial/features/products/domain/repositories/product_repository.dart';
import 'package:flutter_tutorial/features/products/domain/usecases/get_products_use_case.dart';

class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  late GetProductsUseCase useCase;
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

  PaginatedResult<Product> paginatedProducts([List<Product>? products]) =>
      PaginatedResult<Product>(
        content: products ?? [testProduct],
        page: 0,
        size: 20,
        totalElements: 1,
        totalPages: 1,
      );

  setUp(() {
    mockRepository = MockProductRepository();
    useCase = GetProductsUseCase(mockRepository);
  });

  test('_01_ShouldReturnRight_WhenRepositorySucceeds', () async {
    when(
      () => mockRepository.getProducts(
        categoryId: any(named: 'categoryId'),
        productName: any(named: 'productName'),
        minPrice: any(named: 'minPrice'),
        maxPrice: any(named: 'maxPrice'),
        page: any(named: 'page'),
        size: any(named: 'size'),
      ),
    ).thenAnswer((_) async => Right(paginatedProducts()));

    final result = await useCase();

    expect(result.isRight(), isTrue);
    result.fold(
      (_) => fail('expected Right'),
      (paginated) => expect(paginated.content, hasLength(1)),
    );
  });

  test('_02_ShouldReturnLeft_WhenRepositoryFails', () async {
    when(
      () => mockRepository.getProducts(
        categoryId: any(named: 'categoryId'),
        productName: any(named: 'productName'),
        minPrice: any(named: 'minPrice'),
        maxPrice: any(named: 'maxPrice'),
        page: any(named: 'page'),
        size: any(named: 'size'),
      ),
    ).thenAnswer((_) async => const Left(NetworkFailure('Network error')));

    final result = await useCase();

    expect(result.isLeft(), isTrue);
    result.fold(
      (failure) => expect(failure, isA<NetworkFailure>()),
      (_) => fail('expected Left'),
    );
  });

  test('_03_ShouldPassCategoryIdToRepository_WhenCategoryIdIsGiven', () async {
    when(
      () => mockRepository.getProducts(
        categoryId: any(named: 'categoryId'),
        productName: any(named: 'productName'),
        minPrice: any(named: 'minPrice'),
        maxPrice: any(named: 'maxPrice'),
        page: any(named: 'page'),
        size: any(named: 'size'),
      ),
    ).thenAnswer((_) async => Right(paginatedProducts()));

    await useCase(categoryId: 5);

    verify(
      () => mockRepository.getProducts(
        categoryId: 5,
        productName: any(named: 'productName'),
        minPrice: any(named: 'minPrice'),
        maxPrice: any(named: 'maxPrice'),
        page: any(named: 'page'),
        size: any(named: 'size'),
      ),
    ).called(1);
  });

  test(
    '_04_ShouldPassProductNameToRepository_WhenSearchQueryIsGiven',
    () async {
      when(
        () => mockRepository.getProducts(
          categoryId: any(named: 'categoryId'),
          productName: any(named: 'productName'),
          minPrice: any(named: 'minPrice'),
          maxPrice: any(named: 'maxPrice'),
          page: any(named: 'page'),
          size: any(named: 'size'),
        ),
      ).thenAnswer((_) async => Right(paginatedProducts()));

      await useCase(productName: 'shirt');

      verify(
        () => mockRepository.getProducts(
          categoryId: any(named: 'categoryId'),
          productName: 'shirt',
          minPrice: any(named: 'minPrice'),
          maxPrice: any(named: 'maxPrice'),
          page: any(named: 'page'),
          size: any(named: 'size'),
        ),
      ).called(1);
    },
  );
}
