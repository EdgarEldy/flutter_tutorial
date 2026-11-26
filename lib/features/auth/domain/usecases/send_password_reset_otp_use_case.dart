import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../repositories/password_reset_repository.dart';

/// Step 1 of the mobile password-reset flow: requests an OTP sent to [email].
///
/// Author: edgar.muhamyangabo
/// Date: 2026-11-25
/// Project: flutter_tutorial
class SendPasswordResetOtpUseCase {
  const SendPasswordResetOtpUseCase(this._repository);

  final PasswordResetRepository _repository;

  Future<Either<Failure, Unit>> call(String email) =>
      _repository.sendOtp(email);
}
