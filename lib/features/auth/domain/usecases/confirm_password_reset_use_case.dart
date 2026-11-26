import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../repositories/password_reset_repository.dart';

/// Step 3 of the mobile password-reset flow: sets the new password using the OTP as token.
///
/// Author: edgar.muhamyangabo
/// Date: 2026-11-25
/// Project: flutter_tutorial
class ConfirmPasswordResetUseCase {
  const ConfirmPasswordResetUseCase(this._repository);

  final PasswordResetRepository _repository;

  Future<Either<Failure, Unit>> call(
    String otp,
    String newPassword,
    String confirmPassword,
  ) =>
      _repository.confirmReset(otp, newPassword, confirmPassword);
}
