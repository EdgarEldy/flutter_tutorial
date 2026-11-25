import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../entities/category.dart';
import '../repositories/category_repository.dart';

/// Retrieves the full list of product categories.
///
/// Author: edgar.muhamyangabo
/// Date: 2026-11-25
/// Project: flutter_tutorial
class GetCategoriesUseCase {
  const GetCategoriesUseCase(this._repository);

  final CategoryRepository _repository;

  Future<Either<Failure, List<Category>>> call() =>
      _repository.getCategories();
}
