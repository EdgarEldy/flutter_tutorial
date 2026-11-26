// Feature providers for the orders module.
// Wires datasources, repositories and use cases together using Riverpod.
//
// Author: edgar.muhamyangabo
// Date: 2026-11-26
// Project: flutter_tutorial
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../../core/providers/dio_provider.dart';
import '../../domain/repositories/order_repository.dart';
import '../../domain/usecases/get_order_by_id_use_case.dart';
import '../../domain/usecases/get_orders_use_case.dart';
import '../datasources/order_local_datasource.dart';
import '../datasources/order_remote_datasource.dart';
import '../repositories/order_repository_impl.dart';

part 'order_providers.g.dart';

@riverpod
OrderRemoteDatasource orderRemoteDatasource(Ref ref) =>
    OrderRemoteDatasourceImpl(ref.watch(dioProvider));

@riverpod
OrderLocalDatasource orderLocalDatasource(Ref ref) =>
    OrderLocalDatasourceImpl(ref.watch(databaseProvider).requireValue);

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
