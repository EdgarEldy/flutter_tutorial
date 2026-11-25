import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/repositories/password_reset_repository.dart';
import '../datasources/password_reset_remote_datasource.dart';

/// Concrete [PasswordResetRepository] backed by [PasswordResetRemoteDatasource].
///
/// Implements the 3-step mobile password-reset flow defined in the OpenAPI spec
/// under /api/v1/password-reset/. The web flow (/api/v1/auth/forgot-password)
/// is intentionally NOT called from this class.
///
/// Author: edgar.muhamyangabo
/// Date: 2026-11-25
/// Project: flutter_tutorial
class PasswordResetRepositoryImpl implements PasswordResetRepository {
  const PasswordResetRepositoryImpl(this._datasource);

  final PasswordResetRemoteDatasource _datasource;

  @override
  Future<Either<Failure, Unit>> sendOtp(String email) async {
    try {
      await _datasource.sendOtp(email);
      return const Right(unit);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> verifyOtp(String email, String otp) async {
    try {
      await _datasource.verifyOtp(email, otp);
      return const Right(unit);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> confirmReset(
    String otp,
    String newPassword,
    String confirmPassword,
  ) async {
    try {
      await _datasource.confirmReset(otp, newPassword, confirmPassword);
      return const Right(unit);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Failure _handleDioError(DioException e) {
    final statusCode = e.response?.statusCode;
    if (statusCode == 401) {
      return const UnauthorizedFailure();
    }
    if (statusCode != null && (statusCode == 400 || statusCode == 422)) {
      final message = e.response?.data?['message'] as String? ?? e.message ?? 'Request error';
      return ServerFailure(message, statusCode: statusCode);
    }
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return NetworkFailure(e.message ?? 'Network error');
    }
    final message = e.response?.data?['message'] as String? ?? e.message ?? 'Server error';
    return ServerFailure(message, statusCode: statusCode);
  }
}
