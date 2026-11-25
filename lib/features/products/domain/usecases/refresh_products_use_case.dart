import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../repositories/product_repository.dart';

/// Forces a full remote refresh of the products cache.
///
/// Author: edgar.muhamyangabo
/// Date: 2026-11-25
/// Project: flutter_tutorial
class RefreshProductsUseCase {
  const RefreshProductsUseCase(this._repository);

  final ProductRepository _repository;

  Future<Either<Failure, Unit>> call() => _repository.refreshProducts();
}
