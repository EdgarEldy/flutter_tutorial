import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../entities/order_summary.dart';

/// Submits the current cart as an order via POST /api/v1/orders.
/// Requires the datasource directly because checkout bypasses the
/// cart repository and returns an OrderSummary, not a Cart.
///
/// Author: edgar.muhamyangabo
/// Date: 2026-11-26
/// Project: flutter_tutorial
abstract interface class CheckoutDatasource {
  /// Places the order from the current cart contents.
  Future<OrderSummary> checkout();
}

/// Triggers checkout and maps datasource results to domain types.
///
/// Author: edgar.muhamyangabo
/// Date: 2026-11-26
/// Project: flutter_tutorial
class CheckoutUseCase {
  const CheckoutUseCase(this._datasource);

  final CheckoutDatasource _datasource;

  Future<Either<Failure, OrderSummary>> call() async {
    try {
      final order = await _datasource.checkout();
      return Right(order);
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }
}
