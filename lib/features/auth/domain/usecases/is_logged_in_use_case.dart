import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../repositories/auth_repository.dart';

/// Checks whether a valid access token exists in secure storage.
/// No network call is made; purely a local check.
///
/// Author: edgar.muhamyangabo
/// Date: 2026-11-25
/// Project: flutter_tutorial
class IsLoggedInUseCase {
  const IsLoggedInUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, bool>> call() async {
    try {
      final loggedIn = await _repository.isLoggedIn();
      return Right(loggedIn);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
