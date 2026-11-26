import 'package:fpdart/fpdart.dart' hide Order;
import '../../../../core/errors/failure.dart';
import '../entities/order.dart';

/// Contract for fetching customer orders from local cache or remote API.
///
/// Author: edgar.muhamyangabo
/// Date: 2026-11-26
/// Project: flutter_tutorial
abstract interface class OrderRepository {
  /// Returns the authenticated user's full order history.
  Future<Either<Failure, List<Order>>> getOrders();

  /// Returns the detail of a single order by [id].
  Future<Either<Failure, Order>> getOrderById(int id);
}
