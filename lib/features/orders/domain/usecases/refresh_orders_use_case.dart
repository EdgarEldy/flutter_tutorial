import 'package:fpdart/fpdart.dart' hide Order;
import '../../../../core/errors/failure.dart';
import '../entities/order.dart';
import '../repositories/order_repository.dart';

/// Forces a full remote refresh of the orders cache.
///
/// Author: edgar.muhamyangabo
/// Date: 2026-11-26
/// Project: flutter_tutorial
class RefreshOrdersUseCase {
  const RefreshOrdersUseCase(this._repository);

  final OrderRepository _repository;

  Future<Either<Failure, List<Order>>> call() => _repository.refreshOrders();
}
