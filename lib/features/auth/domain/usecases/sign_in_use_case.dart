import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/storage/secure_token_storage.dart';
import '../entities/auth_tokens.dart';
import '../repositories/auth_repository.dart';

/// Validates login inputs and delegates to [AuthRepository.signIn].
///
/// Business rule: email and password must not be blank before making a
/// network call. On success, persists the returned tokens in
/// [SecureTokenStorage] so [AuthInterceptor] can attach them on subsequent
/// requests without being aware of the sign-in flow.
///
/// Author: edgar.muhamyangabo
/// Date: 2026-11-25
/// Project: flutter_tutorial
class SignInUseCase {
  const SignInUseCase(this._repository, this._secureStorage);

  final AuthRepository _repository;
  final SecureTokenStorage _secureStorage;

  Future<Either<Failure, AuthTokens>> call(
    String email,
    String password,
  ) async {
    if (email.trim().isEmpty) {
      return const Left(ValidationFailure('Email is required'));
    }

    final result = await _repository.signIn(email.trim(), password);
    await result.fold(
      (_) async {},
      (tokens) async {
        await _secureStorage.saveTokens(
          accessToken: tokens.accessToken,
          refreshToken: tokens.refreshToken,
        );
      },
    );
    return result;
  }
}
