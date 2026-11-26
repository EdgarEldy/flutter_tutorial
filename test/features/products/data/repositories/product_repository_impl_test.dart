import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_tutorial/core/errors/failure.dart';
import 'package:flutter_tutorial/core/pagination/paginated_result.dart';
import 'package:flutter_tutorial/features/products/data/datasources/product_local_datasource.dart';
import 'package:flutter_tutorial/features/products/data/datasources/product_remote_datasource.dart';
import 'package:flutter_tutorial/features/products/data/models/product_model.dart';
import 'package:flutter_tutorial/features/products/data/repositories/product_repository_impl.dart';

class MockProductRemoteDatasource extends Mock
    implements ProductRemoteDatasource {}

class MockProductLocalDatasource extends Mock
    implements ProductLocalDatasource {}

DioException makeDioException() => DioException(
      requestOptions: RequestOptions(path: '/test'),
      message: 'Network error',
    );

void main() {
  late MockProductRemoteDatasource mockRemote;
  late MockProductLocalDatasource mockLocal;
  late ProductRepositoryImpl repo;

  const testProductModel = ProductModel(
    id: 1,
    productName: 'Test Product',
    unitPrice: 29.99,
    description: 'A test product',
    active: true,
    categoryId: 1,
    categoryName: 'Electronics',
  );

  final productRow = <String, dynamic>{
    'id': 1,
    'product_name': 'Test Product',
    'unit_price': 29.99,
    'description': 'A test product',
    'active': 1,
    'category_id': 1,
    'category_name': 'Electronics',
    'cached_at': 1700000000000,
  };

  PaginatedResult<ProductModel> paginatedModels([
    List<ProductModel>? products,
  ]) =>
      PaginatedResult<ProductModel>(
        content: products ?? [testProductModel],
        page: 0,
        size: 20,
        totalElements: 1,
        totalPages: 1,
      );

  setUp(() {
    mockRemote = MockProductRemoteDatasource();
    mockLocal = MockProductLocalDatasource();
    repo = ProductRepositoryImpl(remote: mockRemote, local: mockLocal);
  });

  group('getProducts', () {
    test('_01_ShouldReturnCachedData_WhenCacheIsNonEmpty', () async {
      when(() => mockLocal.getProducts())
          .thenAnswer((_) async => [productRow]);
      when(() => mockLocal.getProductImages(any()))
          .thenAnswer((_) async => []);
      // Stub remote for the background refresh triggered after cache hit.
      when(
        () => mockRemote.getProducts(
          categoryId: any(named: 'categoryId'),
          productName: any(named: 'productName'),
          minPrice: any(named: 'minPrice'),
          maxPrice: any(named: 'maxPrice'),
          page: any(named: 'page'),
          size: any(named: 'size'),
        ),
      ).thenAnswer((_) async => paginatedModels());
      when(() => mockLocal.upsertProducts(any())).thenAnswer((_) async {});

      final result = await repo.getProducts();

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('expected Right'),
        (paginated) {
          expect(paginated.content, hasLength(1));
          expect(paginated.content.first.id, 1);
        },
      );
    });

    test('_02_ShouldFetchFromNetworkAndSaveCache_WhenCacheIsEmpty', () async {
      when(() => mockLocal.getProducts()).thenAnswer((_) async => []);
      when(
        () => mockRemote.getProducts(
          categoryId: any(named: 'categoryId'),
          productName: any(named: 'productName'),
          minPrice: any(named: 'minPrice'),
          maxPrice: any(named: 'maxPrice'),
          page: any(named: 'page'),
          size: any(named: 'size'),
        ),
      ).thenAnswer((_) async => paginatedModels());
      when(() => mockLocal.upsertProducts(any())).thenAnswer((_) async {});

      final result = await repo.getProducts();

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('expected Right'),
        (paginated) => expect(paginated.content, hasLength(1)),
      );
      verify(() => mockLocal.upsertProducts(any())).called(1);
    });

    test(
      '_03_ShouldAlwaysGoToNetwork_WhenCategoryIdIsFiltered',
      () async {
        when(
          () => mockRemote.getProducts(
            categoryId: any(named: 'categoryId'),
            productName: any(named: 'productName'),
            minPrice: any(named: 'minPrice'),
            maxPrice: any(named: 'maxPrice'),
            page: any(named: 'page'),
            size: any(named: 'size'),
          ),
        ).thenAnswer((_) async => paginatedModels());

        final result = await repo.getProducts(categoryId: 2);

        expect(result.isRight(), isTrue);
        verifyNever(() => mockLocal.getProducts());
        verify(
          () => mockRemote.getProducts(
            categoryId: 2,
            productName: any(named: 'productName'),
            minPrice: any(named: 'minPrice'),
            maxPrice: any(named: 'maxPrice'),
            page: any(named: 'page'),
            size: any(named: 'size'),
          ),
        ).called(1);
      },
    );

    test(
      '_04_ShouldAlwaysGoToNetwork_WhenProductNameFiltered',
      () async {
        when(
          () => mockRemote.getProducts(
            categoryId: any(named: 'categoryId'),
            productName: any(named: 'productName'),
            minPrice: any(named: 'minPrice'),
            maxPrice: any(named: 'maxPrice'),
            page: any(named: 'page'),
            size: any(named: 'size'),
          ),
        ).thenAnswer((_) async => paginatedModels());

        final result = await repo.getProducts(productName: 'shirt');

        expect(result.isRight(), isTrue);
        verifyNever(() => mockLocal.getProducts());
        verify(
          () => mockRemote.getProducts(
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

    test(
      '_05_ShouldReturnLeft_WhenNetworkFailsAndCacheIsEmpty',
      () async {
        when(() => mockLocal.getProducts()).thenAnswer((_) async => []);
        when(
          () => mockRemote.getProducts(
            categoryId: any(named: 'categoryId'),
            productName: any(named: 'productName'),
            minPrice: any(named: 'minPrice'),
            maxPrice: any(named: 'maxPrice'),
            page: any(named: 'page'),
            size: any(named: 'size'),
          ),
        ).thenThrow(makeDioException());

        final result = await repo.getProducts();

        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<NetworkFailure>()),
          (_) => fail('expected Left'),
        );
      },
    );
  });

  group('getProductById', () {
    test('_06_ShouldReturnCachedProduct_WhenProductIsInCache', () async {
      when(() => mockLocal.getProductById(1))
          .thenAnswer((_) async => productRow);
      when(() => mockLocal.getProductImages(1)).thenAnswer((_) async => []);

      final result = await repo.getProductById(1);

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('expected Right'),
        (product) => expect(product.id, 1),
      );
      verifyNever(() => mockRemote.getProductById(any()));
    });

    test('_07_ShouldFetchFromRemote_WhenProductNotInCache', () async {
      when(() => mockLocal.getProductById(1)).thenAnswer((_) async => null);
      when(() => mockRemote.getProductById(1))
          .thenAnswer((_) async => testProductModel);

      final result = await repo.getProductById(1);

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('expected Right'),
        (product) => expect(product.id, 1),
      );
    });

    test('_08_ShouldReturnLeft_WhenRemoteFailsAndCacheEmpty', () async {
      when(() => mockLocal.getProductById(1)).thenAnswer((_) async => null);
      when(() => mockRemote.getProductById(1)).thenThrow(makeDioException());

      final result = await repo.getProductById(1);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<NetworkFailure>()),
        (_) => fail('expected Left'),
      );
    });
  });

  group('refreshProducts', () {
    test('_09_ShouldCallRemoteWithSize100_WhenRefreshing', () async {
      when(
        () => mockRemote.getProducts(
          page: 0,
          size: 100,
          categoryId: any(named: 'categoryId'),
          productName: any(named: 'productName'),
          minPrice: any(named: 'minPrice'),
          maxPrice: any(named: 'maxPrice'),
        ),
      ).thenAnswer(
        (_) async => const PaginatedResult<ProductModel>(
          content: [testProductModel],
          page: 0,
          size: 100,
          totalElements: 1,
          totalPages: 1,
        ),
      );
      when(() => mockLocal.upsertProducts(any())).thenAnswer((_) async {});

      final result = await repo.refreshProducts();

      expect(result.isRight(), isTrue);
      verify(
        () => mockRemote.getProducts(
          page: 0,
          size: 100,
          categoryId: any(named: 'categoryId'),
          productName: any(named: 'productName'),
          minPrice: any(named: 'minPrice'),
          maxPrice: any(named: 'maxPrice'),
        ),
      ).called(1);
      verify(() => mockLocal.upsertProducts(any())).called(1);
    });

    test('_10_ShouldReturnLeft_WhenRefreshNetworkFails', () async {
      when(
        () => mockRemote.getProducts(
          page: 0,
          size: 100,
          categoryId: any(named: 'categoryId'),
          productName: any(named: 'productName'),
          minPrice: any(named: 'minPrice'),
          maxPrice: any(named: 'maxPrice'),
        ),
      ).thenThrow(makeDioException());

      final result = await repo.refreshProducts();

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<NetworkFailure>()),
        (_) => fail('expected Left'),
      );
    });
  });
}
