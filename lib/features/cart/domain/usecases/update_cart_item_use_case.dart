import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../entities/cart.dart';
import '../repositories/cart_repository.dart';

/// Updates a cart item's quantity after validating that quantity is positive.
///
/// Author: edgar.muhamyangabo
/// Date: 2026-11-26
/// Project: flutter_tutorial
class UpdateCartItemUseCase {
  const UpdateCartItemUseCase(this._repository);

  final CartRepository _repository;

  Future<Either<Failure, Cart>> call(int itemId, int quantity) {
    if (quantity <= 0) {
      return Future.value(
        const Left(ValidationFailure('Quantity must be greater than 0')),
      );
    }
    return _repository.updateItem(itemId, quantity);
  }
}
