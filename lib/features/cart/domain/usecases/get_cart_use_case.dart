import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../entities/cart.dart';
import '../repositories/cart_repository.dart';

/// Retrieves the current user's cart from the server.
///
/// Author: edgar.muhamyangabo
/// Date: 2026-11-26
/// Project: flutter_tutorial
class GetCartUseCase {
  const GetCartUseCase(this._repository);

  final CartRepository _repository;

  Future<Either<Failure, Cart>> call() => _repository.getCart();
}
