import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_tutorial/core/errors/failure.dart';
import 'package:flutter_tutorial/features/products/data/datasources/category_local_datasource.dart';
import 'package:flutter_tutorial/features/products/data/datasources/category_remote_datasource.dart';
import 'package:flutter_tutorial/features/products/data/models/category_model.dart';
import 'package:flutter_tutorial/features/products/data/repositories/category_repository_impl.dart';

class MockCategoryRemoteDatasource extends Mock
    implements CategoryRemoteDatasource {}

class MockCategoryLocalDatasource extends Mock
    implements CategoryLocalDatasource {}

DioException makeDioException() => DioException(
      requestOptions: RequestOptions(path: '/test'),
      message: 'Network error',
    );

void main() {
  late MockCategoryRemoteDatasource mockRemote;
  late MockCategoryLocalDatasource mockLocal;
  late CategoryRepositoryImpl repo;

  const testCategoryModel = CategoryModel(id: 1, categoryName: 'Electronics');

  final categoryRow = <String, dynamic>{
    'id': 1,
    'category_name': 'Electronics',
    'cached_at': 1700000000000,
  };

  setUp(() {
    mockRemote = MockCategoryRemoteDatasource();
    mockLocal = MockCategoryLocalDatasource();
    repo = CategoryRepositoryImpl(remote: mockRemote, local: mockLocal);
  });

  test('_01_ShouldReturnCachedCategories_WhenCacheIsNonEmpty', () async {
    when(() => mockLocal.getCategories())
        .thenAnswer((_) async => [categoryRow]);
    // Stub remote for the background refresh triggered after cache hit.
    when(() => mockRemote.getCategories())
        .thenAnswer((_) async => [testCategoryModel]);
    when(() => mockLocal.upsertCategories(any())).thenAnswer((_) async {});

    final result = await repo.getCategories();

    expect(result.isRight(), isTrue);
    result.fold(
      (_) => fail('expected Right'),
      (categories) {
        expect(categories, hasLength(1));
        expect(categories.first.name, 'Electronics');
      },
    );
  });

  test(
    '_02_ShouldFetchFromNetworkAndSave_WhenCacheIsEmpty',
    () async {
      when(() => mockLocal.getCategories()).thenAnswer((_) async => []);
      when(() => mockRemote.getCategories())
          .thenAnswer((_) async => [testCategoryModel]);
      when(() => mockLocal.upsertCategories(any())).thenAnswer((_) async {});

      final result = await repo.getCategories();

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('expected Right'),
        (categories) => expect(categories, hasLength(1)),
      );
      verify(() => mockLocal.upsertCategories(any())).called(1);
    },
  );

  test('_03_ShouldReturnLeft_WhenNetworkFails', () async {
    when(() => mockLocal.getCategories()).thenAnswer((_) async => []);
    when(() => mockRemote.getCategories()).thenThrow(makeDioException());

    final result = await repo.getCategories();

    expect(result.isLeft(), isTrue);
    result.fold(
      (failure) => expect(failure, isA<NetworkFailure>()),
      (_) => fail('expected Left'),
    );
  });
}
