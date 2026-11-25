import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../entities/product.dart';
import '../repositories/product_repository.dart';

/// Retrieves a single product by its identifier.
///
/// Author: edgar.muhamyangabo
/// Date: 2026-11-25
/// Project: flutter_tutorial
class GetProductByIdUseCase {
  const GetProductByIdUseCase(this._repository);

  final ProductRepository _repository;

  Future<Either<Failure, Product>> call(int id) =>
      _repository.getProductById(id);
}
