// ignore_for_file: prefer_initializing_formals
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_local_datasource.dart';
import '../datasources/category_remote_datasource.dart';
import '../models/category_model.dart';

/// Cache-first implementation of [CategoryRepository].
/// Returns cached categories immediately; refreshes from network in background.
///
/// Author: edgar.muhamyangabo
/// Date: 2026-11-25
/// Project: flutter_tutorial
class CategoryRepositoryImpl implements CategoryRepository {
  const CategoryRepositoryImpl({
    required CategoryRemoteDatasource remote,
    required CategoryLocalDatasource local,
  })  : _remote = remote,
        _local = local;

  final CategoryRemoteDatasource _remote;
  final CategoryLocalDatasource _local;

  @override
  Future<Either<Failure, List<Category>>> getCategories() async {
    try {
      final cached = await _local.getCategories();
      if (cached.isNotEmpty) {
        _refreshInBackground();
        return Right(
          cached
              .map((row) => CategoryModel.fromCacheRow(row).toEntity())
              .toList(),
        );
      }

      final remote = await _remote.getCategories();
      await _local.upsertCategories(
        remote.map((m) => m.toCacheRow()).toList(),
      );
      return Right(remote.map((m) => m.toEntity()).toList());
    } on DioException catch (e) {
      return Left(NetworkFailure(e.message ?? 'Network error'));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  void _refreshInBackground() {
    _remote
        .getCategories()
        .then((models) => _local.upsertCategories(
              models.map((m) => m.toCacheRow()).toList(),
            ))
        .ignore();
  }
}
