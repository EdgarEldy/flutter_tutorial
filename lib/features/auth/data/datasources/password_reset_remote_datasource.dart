import 'package:dio/dio.dart';
import '../models/confirm_reset_request_model.dart';
import '../models/send_otp_request_model.dart';
import '../models/verify_otp_request_model.dart';

/// Contract for the 3-step mobile password-reset flow.
/// Maps to /api/v1/password-reset/ endpoints in the OpenAPI spec.
///
/// Author: edgar.muhamyangabo
/// Date: 2026-11-25
/// Project: flutter_tutorial
abstract interface class PasswordResetRemoteDatasource {
  /// Sends an OTP to [email] via POST /mobile.
  Future<void> sendOtp(String email);

  /// Validates the OTP without consuming it via POST /verify-otp.
  Future<void> verifyOtp(String email, String otp);

  /// Resets the password using [otp] as the query token via POST /confirm.
  Future<void> confirmReset(String otp, String newPassword, String confirmPassword);
}

/// Dio-backed implementation of [PasswordResetRemoteDatasource].
///
/// Author: edgar.muhamyangabo
/// Date: 2026-11-25
/// Project: flutter_tutorial
class PasswordResetRemoteDatasourceImpl implements PasswordResetRemoteDatasource {
  const PasswordResetRemoteDatasourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<void> sendOtp(String email) async {
    await _dio.post<void>(
      'api/v1/password-reset/mobile',
      data: SendOtpRequestModel(email: email).toJson(),
    );
  }

  @override
  Future<void> verifyOtp(String email, String otp) async {
    await _dio.post<void>(
      'api/v1/password-reset/verify-otp',
      data: VerifyOtpRequestModel(email: email, otp: otp).toJson(),
    );
  }

  @override
  Future<void> confirmReset(
    String otp,
    String newPassword,
    String confirmPassword,
  ) async {
    await _dio.post<void>(
      'api/v1/password-reset/confirm',
      queryParameters: {'token': otp},
      data: ConfirmResetRequestModel(
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      ).toJson(),
    );
  }
}
