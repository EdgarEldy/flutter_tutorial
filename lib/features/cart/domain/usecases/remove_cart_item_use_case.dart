import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../entities/cart.dart';
import '../repositories/cart_repository.dart';

/// Removes a single item from the cart by its ID.
///
/// Author: edgar.muhamyangabo
/// Date: 2026-11-26
/// Project: flutter_tutorial
class RemoveCartItemUseCase {
  const RemoveCartItemUseCase(this._repository);

  final CartRepository _repository;

  Future<Either<Failure, Cart>> call(int itemId) =>
      _repository.removeItem(itemId);
}
