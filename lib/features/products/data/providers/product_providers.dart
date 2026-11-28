// Feature providers for the products module.
// Wires datasources, repositories and use cases together using Riverpod.
// Each provider is a thin factory: no business logic lives here.
//
// Author: edgar.muhamyangabo
// Date: 2026-11-25
// Project: flutter_tutorial
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/providers/database_provider.dart';
import '../../../../core/providers/dio_provider.dart';
import '../../domain/repositories/category_repository.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/usecases/get_categories_use_case.dart';
import '../../domain/usecases/get_product_by_id_use_case.dart';
import '../../domain/usecases/get_products_use_case.dart';
import '../../domain/usecases/refresh_products_use_case.dart';
import '../datasources/category_local_datasource.dart';
import '../datasources/category_remote_datasource.dart';
import '../datasources/product_local_datasource.dart';
import '../datasources/product_remote_datasource.dart';
import '../repositories/category_repository_impl.dart';
import '../repositories/product_repository_impl.dart';

part 'product_providers.g.dart';

@riverpod
ProductRemoteDatasource productRemoteDatasource(Ref ref) =>
    ProductRemoteDatasourceImpl(ref.watch(dioProvider));

@riverpod
CategoryRemoteDatasource categoryRemoteDatasource(Ref ref) =>
    CategoryRemoteDatasourceImpl(ref.watch(dioProvider));

@riverpod
ProductLocalDatasource productLocalDatasource(Ref ref) {
  if (kIsWeb) return _WebProductLocalDatasource();
  return ProductLocalDatasourceImpl(ref.watch(databaseProvider).requireValue);
}

@riverpod
CategoryLocalDatasource categoryLocalDatasource(Ref ref) {
  if (kIsWeb) return _WebCategoryLocalDatasource();
  return CategoryLocalDatasourceImpl(ref.watch(databaseProvider).requireValue);
}

@riverpod
ProductRepository productRepository(Ref ref) => ProductRepositoryImpl(
  remote: ref.watch(productRemoteDatasourceProvider),
  local: ref.watch(productLocalDatasourceProvider),
);

@riverpod
CategoryRepository categoryRepository(Ref ref) => CategoryRepositoryImpl(
  remote: ref.watch(categoryRemoteDatasourceProvider),
  local: ref.watch(categoryLocalDatasourceProvider),
);

@riverpod
GetProductsUseCase getProductsUseCase(Ref ref) =>
    GetProductsUseCase(ref.watch(productRepositoryProvider));

@riverpod
GetProductByIdUseCase getProductByIdUseCase(Ref ref) =>
    GetProductByIdUseCase(ref.watch(productRepositoryProvider));

@riverpod
GetCategoriesUseCase getCategoriesUseCase(Ref ref) =>
    GetCategoriesUseCase(ref.watch(categoryRepositoryProvider));

@riverpod
RefreshProductsUseCase refreshProductsUseCase(Ref ref) =>
    RefreshProductsUseCase(ref.watch(productRepositoryProvider));

class _WebProductLocalDatasource implements ProductLocalDatasource {
  final List<Map<String, dynamic>> _products = [];

  @override
  Future<void> deleteAllProducts() async => _products.clear();

  @override
  Future<Map<String, dynamic>?> getProductById(int id) async {
    for (final product in _products) {
      if (product['id'] == id) return product;
    }
    return null;
  }

  @override
  Future<List<Map<String, dynamic>>> getProductImages(int productId) async {
    for (final product in _products) {
      if (product['id'] != productId) continue;
      final images = product['images'];
      if (images is! List) return [];
      return images
          .whereType<Map>()
          .map((image) => Map<String, dynamic>.from(image))
          .toList();
    }
    return [];
  }

  @override
  Future<List<Map<String, dynamic>>> getProducts() async =>
      List<Map<String, dynamic>>.from(_products);

  @override
  Future<void> upsertProducts(List<Map<String, dynamic>> rows) async {
    _products
      ..clear()
      ..addAll(rows.map((row) => Map<String, dynamic>.from(row)));
  }
}

class _WebCategoryLocalDatasource implements CategoryLocalDatasource {
  final List<Map<String, dynamic>> _categories = [];

  @override
  Future<List<Map<String, dynamic>>> getCategories() async =>
      List<Map<String, dynamic>>.from(_categories);

  @override
  Future<void> upsertCategories(List<Map<String, dynamic>> rows) async {
    _categories
      ..clear()
      ..addAll(rows.map((row) => Map<String, dynamic>.from(row)));
  }
}
