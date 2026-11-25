import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../entities/category.dart';

/// Contract for category data access. Implementations are cache-first.
///
/// Author: edgar.muhamyangabo
/// Date: 2026-11-25
/// Project: flutter_tutorial
abstract interface class CategoryRepository {
  /// Returns the full list of categories.
  Future<Either<Failure, List<Category>>> getCategories();
}
