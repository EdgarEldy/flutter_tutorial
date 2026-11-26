import 'package:fpdart/fpdart.dart' hide Order;
import '../../../../core/errors/failure.dart';
import '../entities/order.dart';
import '../repositories/order_repository.dart';

/// Returns the detail of a single order by its [id].
///
/// Author: edgar.muhamyangabo
/// Date: 2026-11-26
/// Project: flutter_tutorial
class GetOrderByIdUseCase {
  const GetOrderByIdUseCase(this._repository);

  final OrderRepository _repository;

  Future<Either<Failure, Order>> call(int id) =>
      _repository.getOrderById(id);
}
