// ignore_for_file: prefer_initializing_formals
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/pagination/paginated_result.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_local_datasource.dart';
import '../datasources/product_remote_datasource.dart';
import '../models/product_model.dart';

/// Cache-first implementation of [ProductRepository].
/// Returns cached data immediately while refreshing in the background;
/// falls back to network when the cache is empty.
///
/// Author: edgar.muhamyangabo
/// Date: 2026-11-25
/// Project: flutter_tutorial
class ProductRepositoryImpl implements ProductRepository {
  const ProductRepositoryImpl({
    required ProductRemoteDatasource remote,
    required ProductLocalDatasource local,
  })  : _remote = remote,
        _local = local;

  final ProductRemoteDatasource _remote;
  final ProductLocalDatasource _local;

  @override
  Future<Either<Failure, PaginatedResult<Product>>> getProducts({
    int? categoryId,
    String? productName,
    double? minPrice,
    double? maxPrice,
    int page = 0,
    int size = 20,
  }) async {
    // For filtered/searched queries always go remote (cache is unfiltered).
    final isFiltered = categoryId != null ||
        (productName != null && productName.isNotEmpty) ||
        minPrice != null ||
        maxPrice != null;

    if (!isFiltered && page == 0) {
      try {
        final cached = await _local.getProducts();
        if (cached.isNotEmpty) {
          final models = await _buildModelsFromCache(cached);
          // Kick off a background refresh; ignore errors silently.
          _refreshInBackground();
          return Right(
            PaginatedResult<Product>(
              content: models.map((m) => m.toEntity()).toList(),
              page: 0,
              size: cached.length,
              totalElements: cached.length,
              totalPages: 1,
            ),
          );
        }
      } catch (_) {
        // Cache read failure is non-fatal; fall through to network.
      }
    }

    try {
      final result = await _remote.getProducts(
        categoryId: categoryId,
        productName: productName,
        minPrice: minPrice,
        maxPrice: maxPrice,
        page: page,
        size: size,
      );
      if (!isFiltered && page == 0) {
        await _saveToCache(result.content);
      }
      return Right(
        PaginatedResult<Product>(
          content: result.content.map((m) => m.toEntity()).toList(),
          page: result.page,
          size: result.size,
          totalElements: result.totalElements,
          totalPages: result.totalPages,
        ),
      );
    } on DioException catch (e) {
      return Left(NetworkFailure(e.message ?? 'Network error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Product>> getProductById(int id) async {
    try {
      final cached = await _local.getProductById(id);
      if (cached != null) {
        final imageRows = await _local.getProductImages(id);
        final model = ProductModel.fromCacheRow(cached, imageRows);
        return Right(model.toEntity());
      }
      final remote = await _remote.getProductById(id);
      return Right(remote.toEntity());
    } on DioException catch (e) {
      return Left(NetworkFailure(e.message ?? 'Network error'));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> refreshProducts() async {
    try {
      final result = await _remote.getProducts(page: 0, size: 100);
      await _saveToCache(result.content);
      return const Right(unit);
    } on DioException catch (e) {
      return Left(NetworkFailure(e.message ?? 'Network error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<List<ProductModel>> _buildModelsFromCache(
    List<Map<String, dynamic>> rows,
  ) async {
    final models = <ProductModel>[];
    for (final row in rows) {
      final id = row['id'] as int;
      final imageRows = await _local.getProductImages(id);
      models.add(ProductModel.fromCacheRow(row, imageRows));
    }
    return models;
  }

  Future<void> _saveToCache(List<ProductModel> models) async {
    final rows = models.map((m) {
      final row = m.toCacheRow();
      row['images'] = m.images
          .map((img) => img.toCacheRow(m.id))
          .toList();
      return row;
    }).toList();
    await _local.upsertProducts(rows);
  }

  void _refreshInBackground() {
    refreshProducts().ignore();
  }
}
