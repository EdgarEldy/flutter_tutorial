import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../entities/cart.dart';

/// Contract for all cart read and write operations.
/// Implementations are server-authoritative: no offline writes.
///
/// Author: edgar.muhamyangabo
/// Date: 2026-11-26
/// Project: flutter_tutorial
abstract interface class CartRepository {
  /// Returns the authenticated user's cart.
  Future<Either<Failure, Cart>> getCart();

  /// Adds [quantity] units of [productId] to the cart.
  Future<Either<Failure, Cart>> addItem(int productId, int quantity);

  /// Updates the quantity of [itemId] to [quantity].
  Future<Either<Failure, Cart>> updateItem(int itemId, int quantity);

  /// Removes [itemId] from the cart.
  Future<Either<Failure, Cart>> removeItem(int itemId);

  /// Removes all items from the cart.
  Future<Either<Failure, Unit>> clearCart();
}
