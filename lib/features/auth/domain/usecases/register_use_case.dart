import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Validates that passwords match, then delegates to [AuthRepository.register].
/// Returns [ValidationFailure] if passwords differ (client-side check).
///
/// Author: edgar.muhamyangabo
/// Date: 2026-11-25
/// Project: flutter_tutorial
class RegisterUseCase {
  const RegisterUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, User>> call({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    if (password != confirmPassword) {
      return const Left(ValidationFailure('Passwords do not match'));
    }

    return _repository.register(
      firstName: firstName,
      lastName: lastName,
      username: username,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
    );
  }
}
