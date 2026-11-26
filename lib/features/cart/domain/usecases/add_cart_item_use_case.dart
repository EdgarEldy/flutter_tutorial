import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../entities/cart.dart';
import '../repositories/cart_repository.dart';

/// Adds a product to the cart after validating that quantity is positive.
///
/// Author: edgar.muhamyangabo
/// Date: 2026-11-26
/// Project: flutter_tutorial
class AddCartItemUseCase {
  const AddCartItemUseCase(this._repository);

  final CartRepository _repository;

  Future<Either<Failure, Cart>> call(int productId, int quantity) {
    if (quantity <= 0) {
      return Future.value(
        const Left(ValidationFailure('Quantity must be greater than 0')),
      );
    }
    return _repository.addItem(productId, quantity);
  }
}
