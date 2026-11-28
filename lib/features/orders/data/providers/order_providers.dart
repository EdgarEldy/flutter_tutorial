// Feature providers for the orders module.
// Wires datasources, repositories and use cases together using Riverpod.
//
// Author: edgar.muhamyangabo
// Date: 2026-11-26
// Project: flutter_tutorial
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/database_provider.dart';
import '../../../../core/providers/dio_provider.dart';
import '../../domain/repositories/order_repository.dart';
import '../../domain/usecases/get_order_by_id_use_case.dart';
import '../../domain/usecases/get_orders_use_case.dart';
import '../../domain/usecases/refresh_orders_use_case.dart';
import '../datasources/order_local_datasource.dart';
import '../datasources/order_remote_datasource.dart';
import '../models/order_model.dart';
import '../repositories/order_repository_impl.dart';

part 'order_providers.g.dart';

@riverpod
OrderRemoteDatasource orderRemoteDatasource(Ref ref) =>
    OrderRemoteDatasourceImpl(ref.watch(dioProvider));

@riverpod
OrderLocalDatasource orderLocalDatasource(Ref ref) {
  if (kIsWeb) return _WebOrderLocalDatasource();
  return OrderLocalDatasourceImpl(ref.watch(databaseProvider).requireValue);
}

@riverpod
OrderRepository orderRepository(Ref ref) => OrderRepositoryImpl(
  remote: ref.watch(orderRemoteDatasourceProvider),
  local: ref.watch(orderLocalDatasourceProvider),
);

@riverpod
GetOrdersUseCase getOrdersUseCase(Ref ref) =>
    GetOrdersUseCase(ref.watch(orderRepositoryProvider));

@riverpod
GetOrderByIdUseCase getOrderByIdUseCase(Ref ref) =>
    GetOrderByIdUseCase(ref.watch(orderRepositoryProvider));

@riverpod
RefreshOrdersUseCase refreshOrdersUseCase(Ref ref) =>
    RefreshOrdersUseCase(ref.watch(orderRepositoryProvider));

class _WebOrderLocalDatasource implements OrderLocalDatasource {
  final List<OrderModel> _orders = [];

  @override
  Future<void> deleteAllOrders() async => _orders.clear();

  @override
  Future<List<Map<String, dynamic>>> getOrders() async =>
      _orders.map((order) => order.toCacheRow()).toList();

  @override
  Future<Map<String, dynamic>?> getOrderById(int id) async {
    for (final order in _orders) {
      if (order.id == id) return order.toCacheRow();
    }
    return null;
  }

  @override
  Future<List<Map<String, dynamic>>> getOrderItems(int orderId) async {
    for (final order in _orders) {
      if (order.id == orderId) {
        return order.items.map((item) => item.toCacheRow(orderId)).toList();
      }
    }
    return [];
  }

  @override
  Future<void> upsertOrders(List<OrderModel> models) async {
    _orders
      ..clear()
      ..addAll(models);
  }

  @override
  Future<void> upsertOrder(OrderModel model) async {
    final index = _orders.indexWhere((order) => order.id == model.id);
    if (index >= 0) {
      _orders[index] = model;
    } else {
      _orders.add(model);
    }
  }
}
