import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/storage/secure_token_storage.dart';
import '../repositories/auth_repository.dart';

/// Signs out the user server-side and clears all local JWT tokens.
/// Always clears local tokens even if the server call fails.
///
/// Author: edgar.muhamyangabo
/// Date: 2026-11-25
/// Project: flutter_tutorial
class LogoutUseCase {
  const LogoutUseCase(this._repository, this._secureStorage);

  final AuthRepository _repository;
  final SecureTokenStorage _secureStorage;

  Future<Either<Failure, Unit>> call() async {
    // Always clear local tokens, even if the server call fails
    final result = await _repository.logout();
    await _secureStorage.clearTokens();
    return result.fold(
      (_) => const Right(unit),
      (_) => const Right(unit),
    );
  }
}
