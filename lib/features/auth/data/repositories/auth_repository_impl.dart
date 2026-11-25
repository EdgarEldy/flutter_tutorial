import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/storage/secure_token_storage.dart';
import '../../domain/entities/auth_tokens.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/auth_response_model.dart';

/// Concrete [AuthRepository] backed by [AuthRemoteDatasource].
/// Maps models to domain entities; always clears local tokens on logout.
///
/// Author: edgar.muhamyangabo
/// Date: 2026-11-25
/// Project: flutter_tutorial
class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remote, this._secureStorage);

  final AuthRemoteDatasource _remote;
  final SecureTokenStorage _secureStorage;

  @override
  Future<Either<Failure, AuthTokens>> signIn(
    String email,
    String password,
  ) async {
    try {
      final model = await _remote.login(email, password);
      return Right(_toAuthTokens(model));
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> register({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final model = await _remote.register(
        firstName: firstName,
        lastName: lastName,
        username: username,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
      );
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    try {
      await _remote.logout();
      return const Right(unit);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthTokens>> refreshToken() async {
    try {
      final model = await _remote.refreshToken();
      return Right(_toAuthTokens(model));
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> getMe() async {
    try {
      final model = await _remote.getMe();
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> activateAccount(
    String email,
    String activationCode,
  ) async {
    try {
      final model = await _remote.activateAccount(email, activationCode);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = await _secureStorage.getAccessToken();
    return token != null;
  }

  AuthTokens _toAuthTokens(AuthResponseModel model) => AuthTokens(
        accessToken: model.accessToken,
        refreshToken: model.refreshToken,
        expiresIn: model.expiresIn,
      );

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
