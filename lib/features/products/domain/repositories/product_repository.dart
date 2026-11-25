import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/pagination/paginated_result.dart';
import '../entities/product.dart';

/// Contract for product data access. Implementations are cache-first.
///
/// Author: edgar.muhamyangabo
/// Date: 2026-11-25
/// Project: flutter_tutorial
abstract interface class ProductRepository {
  /// Returns a paginated list of products, optionally filtered.
  Future<Either<Failure, PaginatedResult<Product>>> getProducts({
    int? categoryId,
    String? productName,
    double? minPrice,
    double? maxPrice,
    int page = 0,
    int size = 20,
  });

  /// Returns a single product by its [id].
  Future<Either<Failure, Product>> getProductById(int id);

  /// Forces a network refresh of the full product list.
  Future<Either<Failure, Unit>> refreshProducts();
}
