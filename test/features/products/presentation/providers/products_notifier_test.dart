import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_tutorial/core/errors/failure.dart';
import 'package:flutter_tutorial/core/pagination/paginated_result.dart';
import 'package:flutter_tutorial/features/products/data/providers/product_providers.dart';
import 'package:flutter_tutorial/features/products/domain/entities/category.dart';
import 'package:flutter_tutorial/features/products/domain/entities/product.dart';
import 'package:flutter_tutorial/features/products/domain/usecases/get_categories_use_case.dart';
import 'package:flutter_tutorial/features/products/domain/usecases/get_products_use_case.dart';
import 'package:flutter_tutorial/features/products/presentation/providers/products_notifier.dart';

class MockGetProductsUseCase extends Mock implements GetProductsUseCase {}

class MockGetCategoriesUseCase extends Mock implements GetCategoriesUseCase {}

void main() {
  late MockGetProductsUseCase mockGetProducts;
  late MockGetCategoriesUseCase mockGetCategories;

  const testProduct = Product(
    id: 1,
    name: 'Test Product',
    unitPrice: 29.99,
    description: 'A test product',
    active: true,
    categoryId: 1,
    categoryName: 'Electronics',
  );

  const testCategory = Category(id: 1, name: 'Electronics');

  PaginatedResult<Product> paginatedProducts([List<Product>? products]) =>
      PaginatedResult<Product>(
        content: products ?? [testProduct],
        page: 0,
        size: 20,
        totalElements: 1,
        totalPages: 1,
      );

  void stubGetProducts({
    Either<Failure, PaginatedResult<Product>>? result,
  }) {
    when(
      () => mockGetProducts.call(
        categoryId: any(named: 'categoryId'),
        productName: any(named: 'productName'),
        minPrice: any(named: 'minPrice'),
        maxPrice: any(named: 'maxPrice'),
        page: any(named: 'page'),
        size: any(named: 'size'),
      ),
    ).thenAnswer((_) async => result ?? Right(paginatedProducts()));
  }

  void stubGetCategories({
    Either<Failure, List<Category>>? result,
  }) {
    when(() => mockGetCategories.call()).thenAnswer(
      (_) async => result ?? const Right([testCategory]),
    );
  }

  setUp(() {
    mockGetProducts = MockGetProductsUseCase();
    mockGetCategories = MockGetCategoriesUseCase();
  });

  /// Creates a container with mocked use cases and registers a persistent
  /// listener so the autoDispose provider is never disposed mid-test.
  ProviderContainer makeContainer() {
    final container = ProviderContainer(
      overrides: [
        getCategoriesUseCaseProvider.overrideWithValue(mockGetCategories),
        getProductsUseCaseProvider.overrideWithValue(mockGetProducts),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('_01_ShouldStartWithIsLoadingTrue_WhenNotifierIsFirstBuilt', () async {
    stubGetCategories();
    stubGetProducts();

    final container = makeContainer();
    // listen() keeps the autoDispose provider alive and returns current state.
    final sub = container.listen(productsProvider, (prev, next) {});
    addTearDown(sub.close);

    expect(sub.read().isLoading, isTrue);
  });

  test(
    '_02_ShouldLoadProductsAndCategories_WhenInitialLoadSucceeds',
    () async {
      stubGetCategories();
      stubGetProducts();

      final container = makeContainer();
      final sub = container.listen(productsProvider, (prev, next) {});
      addTearDown(sub.close);

      await Future.delayed(Duration.zero);

      final state = container.read(productsProvider);
      expect(state.isLoading, isFalse);
      expect(state.products, hasLength(1));
      expect(state.categories, hasLength(1));
      expect(state.errorMessage, isNull);
    },
  );

  test(
    '_03_ShouldSetErrorMessage_WhenInitialLoadFails',
    () async {
      stubGetCategories();
      stubGetProducts(
        result: const Left(NetworkFailure('Network error')),
      );

      final container = makeContainer();
      final sub = container.listen(productsProvider, (prev, next) {});
      addTearDown(sub.close);

      await Future.delayed(Duration.zero);

      final state = container.read(productsProvider);
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, isNotNull);
    },
  );

  test(
    '_04_ShouldSetCategoriesEmpty_WhenCategoriesUseCaseFails',
    () async {
      stubGetCategories(
        result: const Left(NetworkFailure('Categories unavailable')),
      );
      stubGetProducts();

      final container = makeContainer();
      final sub = container.listen(productsProvider, (prev, next) {});
      addTearDown(sub.close);

      await Future.delayed(Duration.zero);

      final state = container.read(productsProvider);
      expect(state.categories, isEmpty);
      expect(state.products, hasLength(1));
      expect(state.isLoading, isFalse);
    },
  );

  test('_05_ShouldFilterByCategory_WhenSetCategoryIsCalled', () async {
    stubGetCategories();
    stubGetProducts();

    final container = makeContainer();
    // Keep provider alive so _loadInitial() completes before setCategory().
    final sub = container.listen(productsProvider, (prev, next) {});
    addTearDown(sub.close);

    await Future.delayed(Duration.zero);

    await container.read(productsProvider.notifier).setCategory(2);

    final state = container.read(productsProvider);
    expect(state.selectedCategoryId, 2);
    expect(state.isLoading, isFalse);
    // Initial load called with null categoryId; only setCategory uses 2.
    verify(
      () => mockGetProducts.call(
        categoryId: 2,
        productName: any(named: 'productName'),
        minPrice: any(named: 'minPrice'),
        maxPrice: any(named: 'maxPrice'),
        page: any(named: 'page'),
        size: any(named: 'size'),
      ),
    ).called(1);
  });

  test('_06_ShouldFilterByQuery_WhenSetSearchQueryIsCalled', () async {
    stubGetCategories();
    stubGetProducts();

    final container = makeContainer();
    final sub = container.listen(productsProvider, (prev, next) {});
    addTearDown(sub.close);

    await Future.delayed(Duration.zero);

    await container.read(productsProvider.notifier).setSearchQuery('shirt');

    final state = container.read(productsProvider);
    expect(state.searchQuery, 'shirt');
    expect(state.isLoading, isFalse);
    // Initial load called with null productName; only setSearchQuery uses 'shirt'.
    verify(
      () => mockGetProducts.call(
        categoryId: any(named: 'categoryId'),
        productName: 'shirt',
        minPrice: any(named: 'minPrice'),
        maxPrice: any(named: 'maxPrice'),
        page: any(named: 'page'),
        size: any(named: 'size'),
      ),
    ).called(1);
  });

  test(
    '_07_ShouldSetIsRefreshing_WhenRefreshIsCalled',
    () async {
      stubGetCategories();
      stubGetProducts();

      final container = makeContainer();
      final sub = container.listen(productsProvider, (prev, next) {});
      addTearDown(sub.close);

      await Future.delayed(Duration.zero);

      await container.read(productsProvider.notifier).refresh();

      final state = container.read(productsProvider);
      expect(state.isRefreshing, isFalse);
      expect(state.products, hasLength(1));
      expect(state.errorMessage, isNull);
    },
  );

  test(
    '_08_ShouldSetErrorOnRefresh_WhenRefreshFails',
    () async {
      stubGetCategories();
      // Both initial load and refresh fail.
      stubGetProducts(result: const Left(NetworkFailure('Refresh failed')));

      final container = makeContainer();
      final sub = container.listen(productsProvider, (prev, next) {});
      addTearDown(sub.close);

      await Future.delayed(Duration.zero);

      await container.read(productsProvider.notifier).refresh();

      final state = container.read(productsProvider);
      expect(state.isRefreshing, isFalse);
      expect(state.errorMessage, isNotNull);
    },
  );
}
