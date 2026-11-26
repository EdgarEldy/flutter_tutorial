import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/cart.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_remote_datasource.dart';

/// Network-only implementation of [CartRepository].
/// The cart is fully server-authoritative; no local cache is used.
///
/// Author: edgar.muhamyangabo
/// Date: 2026-11-26
/// Project: flutter_tutorial
class CartRepositoryImpl implements CartRepository {
  const CartRepositoryImpl(this._remote);

  final CartRemoteDatasource _remote;

  @override
  Future<Either<Failure, Cart>> getCart() async {
    try {
      final model = await _remote.getCart();
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(NetworkFailure(e.message ?? 'Network error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Cart>> addItem(int productId, int quantity) async {
    try {
      final model = await _remote.addItem(productId, quantity);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(NetworkFailure(e.message ?? 'Network error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Cart>> updateItem(int itemId, int quantity) async {
    try {
      final model = await _remote.updateItem(itemId, quantity);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(NetworkFailure(e.message ?? 'Network error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Cart>> removeItem(int itemId) async {
    try {
      final model = await _remote.removeItem(itemId);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(NetworkFailure(e.message ?? 'Network error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> clearCart() async {
    try {
      await _remote.clearCart();
      return const Right(unit);
    } on DioException catch (e) {
      return Left(NetworkFailure(e.message ?? 'Network error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
