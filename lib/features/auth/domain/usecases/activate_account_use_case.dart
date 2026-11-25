import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Validates the activation code format (6 digits) and activates the account.
/// Business rule: code must match the regex \d{6} as defined in the API spec.
///
/// Author: edgar.muhamyangabo
/// Date: 2026-11-25
/// Project: flutter_tutorial
class ActivateAccountUseCase {
  const ActivateAccountUseCase(this._repository);

  final AuthRepository _repository;

  // Activation code must be exactly 6 digits as per the API spec (pattern: \d{6})
  Future<Either<Failure, User>> call(String email, String code) async {
    final digitOnly = RegExp(r'^\d{6}$');
    if (!digitOnly.hasMatch(code)) {
      return const Left(ValidationFailure('Activation code must be 6 digits'));
    }

    return _repository.activateAccount(email, code);
  }
}
