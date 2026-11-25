import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../repositories/password_reset_repository.dart';

/// Step 2 of the mobile password-reset flow: validates the OTP without consuming it.
///
/// Author: edgar.muhamyangabo
/// Date: 2026-11-25
/// Project: flutter_tutorial
class VerifyPasswordResetOtpUseCase {
  const VerifyPasswordResetOtpUseCase(this._repository);

  final PasswordResetRepository _repository;

  Future<Either<Failure, Unit>> call(String email, String otp) =>
      _repository.verifyOtp(email, otp);
}
