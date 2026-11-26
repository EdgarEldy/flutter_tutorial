import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/pagination/paginated_result.dart';
import '../entities/product.dart';
import '../repositories/product_repository.dart';

/// Returns a paginated, optionally-filtered list of products.
///
/// Author: edgar.muhamyangabo
/// Date: 2026-11-25
/// Project: flutter_tutorial
class GetProductsUseCase {
  const GetProductsUseCase(this._repository);

  final ProductRepository _repository;

  Future<Either<Failure, PaginatedResult<Product>>> call({
    int? categoryId,
    String? productName,
    double? minPrice,
    double? maxPrice,
    int page = 0,
    int size = 20,
  }) =>
      _repository.getProducts(
        categoryId: categoryId,
        productName: productName,
        minPrice: minPrice,
        maxPrice: maxPrice,
        page: page,
        size: size,
      );
}
