// Feature providers for the products module.
// Wires datasources, repositories and use cases together using Riverpod.
// Each provider is a thin factory: no business logic lives here.
//
// Author: edgar.muhamyangabo
// Date: 2026-11-25
// Project: flutter_tutorial
import 'package:riverpod_annotation/riverpod_annotation.dart';
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
ProductLocalDatasource productLocalDatasource(Ref ref) =>
    ProductLocalDatasourceImpl(ref.watch(databaseProvider).requireValue);

@riverpod
CategoryLocalDatasource categoryLocalDatasource(Ref ref) =>
    CategoryLocalDatasourceImpl(ref.watch(databaseProvider).requireValue);

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
