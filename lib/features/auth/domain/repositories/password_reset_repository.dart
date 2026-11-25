import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';

/// Contract for the mobile password-reset flow (3-step OTP process).
/// Uses /api/v1/password-reset/ endpoints, NOT the legacy web endpoints.
///
/// Author: edgar.muhamyangabo
/// Date: 2026-11-25
/// Project: flutter_tutorial
abstract interface class PasswordResetRepository {
  /// Sends an OTP to [email] via POST api/v1/password-reset/mobile.
  Future<Either<Failure, Unit>> sendOtp(String email);

  /// Validates the [otp] without consuming it. Used in step 2.
  Future<Either<Failure, Unit>> verifyOtp(String email, String otp);

  /// Confirms the reset using the [otp] as a query parameter (token).
  Future<Either<Failure, Unit>> confirmReset(
    String otp,
    String newPassword,
    String confirmPassword,
  );
}
