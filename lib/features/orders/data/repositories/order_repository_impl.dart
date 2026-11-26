// ignore_for_file: prefer_initializing_formals
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart' hide Order;
import '../../../../core/errors/failure.dart';
import '../../domain/entities/order.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/order_local_datasource.dart';
import '../datasources/order_remote_datasource.dart';
import '../models/order_model.dart';

/// Cache-first implementation of [OrderRepository].
/// Serves cached orders immediately and refreshes in background;
/// falls back to network when cache is empty.
///
/// Author: edgar.muhamyangabo
/// Date: 2026-11-26
/// Project: flutter_tutorial
class OrderRepositoryImpl implements OrderRepository {
  const OrderRepositoryImpl({
    required OrderRemoteDatasource remote,
    required OrderLocalDatasource local,
  })  : _remote = remote,
        _local = local;

  final OrderRemoteDatasource _remote;
  final OrderLocalDatasource _local;

  @override
  Future<Either<Failure, List<Order>>> getOrders() async {
    try {
      final cached = await _local.getOrders();
      if (cached.isNotEmpty) {
        _refreshInBackground();
        return Right(await _buildFromCache(cached));
      }
      final models = await _remote.getOrders();
      await _local.upsertOrders(models);
      return Right(models.map((m) => m.toEntity()).toList());
    } on DioException catch (e) {
      return Left(NetworkFailure(e.message ?? 'Network error'));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Order>> getOrderById(int id) async {
    try {
      final cached = await _local.getOrderById(id);
      if (cached != null) {
        final items = await _local.getOrderItems(id);
        return Right(OrderModel.fromCacheRow(cached, items).toEntity());
      }
      final model = await _remote.getOrderById(id);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(NetworkFailure(e.message ?? 'Network error'));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  Future<List<Order>> _buildFromCache(
    List<Map<String, dynamic>> rows,
  ) async {
    final orders = <Order>[];
    for (final row in rows) {
      final id = row['id'] as int;
      final itemRows = await _local.getOrderItems(id);
      orders.add(OrderModel.fromCacheRow(row, itemRows).toEntity());
    }
    return orders;
  }

  void _refreshInBackground() {
    _doRefresh().ignore();
  }

  Future<void> _doRefresh() async {
    try {
      final models = await _remote.getOrders();
      await _local.upsertOrders(models);
    } catch (_) {
      // Background refresh failure is silent; stale cache remains usable.
    }
  }
}
