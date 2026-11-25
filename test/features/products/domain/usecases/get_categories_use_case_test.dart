import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_tutorial/core/errors/failure.dart';
import 'package:flutter_tutorial/features/products/domain/entities/category.dart';
import 'package:flutter_tutorial/features/products/domain/repositories/category_repository.dart';
import 'package:flutter_tutorial/features/products/domain/usecases/get_categories_use_case.dart';

class MockCategoryRepository extends Mock implements CategoryRepository {}

void main() {
  late GetCategoriesUseCase useCase;
  late MockCategoryRepository mockRepository;

  const testCategory = Category(id: 1, name: 'Electronics');

  setUp(() {
    mockRepository = MockCategoryRepository();
    useCase = GetCategoriesUseCase(mockRepository);
  });

  test('_01_ShouldReturnCategories_WhenRepositorySucceeds', () async {
    when(() => mockRepository.getCategories())
        .thenAnswer((_) async => const Right([testCategory]));

    final result = await useCase();

    expect(result.isRight(), isTrue);
    result.fold(
      (_) => fail('expected Right'),
      (categories) {
        expect(categories, hasLength(1));
        expect(categories.first.name, 'Electronics');
      },
    );
  });

  test('_02_ShouldReturnLeft_WhenRepositoryFails', () async {
    when(() => mockRepository.getCategories())
        .thenAnswer((_) async => const Left(NetworkFailure('Network error')));

    final result = await useCase();

    expect(result.isLeft(), isTrue);
    result.fold(
      (failure) => expect(failure, isA<NetworkFailure>()),
      (_) => fail('expected Left'),
    );
  });
}
